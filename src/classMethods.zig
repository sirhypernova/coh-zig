const std = @import("std");
const win32 = @import("zigwin32").everything;
const zigwin32 = @import("zigwin32");
const mem = @import("memory.zig");
const mappings = @import("mappings.zig");
const constants = @import("constants.zig");
const utils = @import("utils.zig");
const Keybinds = @import("keybinds.zig");

// BEGIN Game
pub fn getKeybind(self: mappings.Game, key: u64) ![]const u8 {
    const keybinds = try self.getKeybinds();
    const keybind = try keybinds.item(key);
    const command = try keybind.getCommand();
    return command;
}

pub fn setKeybind(self: mappings.Game, key: u64, command: []const u8) !void {
    const keybinds = try self.getKeybinds();
    const keybind = try keybinds.item(key);
    try self.reader.writeField(keybind, keybind.command, command);
}

pub fn getMovement(self: mappings.Game) !mappings.Movement {
    const controlState: mappings.ControlState = try self.getControlState();
    return @bitCast(try controlState.getMovement());
}

pub fn setMovement(self: mappings.Game, movement: mappings.Movement) !void {
    const controlState: mappings.ControlState = try self.getControlState();
    try self.reader.writeField(controlState, controlState.movement, &movement.toNumber());
}

pub fn sendCommand(self: mappings.Game, command: []const u8) !void {
    return utils.sendCommand(self, command);
}

pub fn getCritters(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isCritter) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{ .reader = self.reader, .innerList = entities, .maxLen = try entities.len(), .game = self };
}

pub fn getEnemies(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isEnemy) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{
        .reader = self.reader,
        .innerList = entities,
        .maxLen = try entities.len(),
        .game = self,
    };
}

pub fn getAliveEnemies(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isAliveEnemy) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{
        .reader = self.reader,
        .innerList = entities,
        .maxLen = try entities.len(),
        .game = self,
    };
}

pub fn getAllies(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isAlly) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{
        .reader = self.reader,
        .innerList = entities,
        .maxLen = try entities.len(),
        .game = self,
    };
}

pub fn getNpcs(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isNpc) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{
        .reader = self.reader,
        .innerList = entities,
        .maxLen = try entities.len(),
        .game = self,
    };
}

pub fn getInteractables(self: mappings.Game) !utils.EntityIterator(mappings.Entity.isInteractable) {
    const game = mappings.Game{ .reader = self.reader };
    const entities = try game.getEntities();
    return .{
        .reader = self.reader,
        .innerList = entities,
        .maxLen = try entities.len(),
        .game = self,
    };
}

// BEGIN Entity
pub fn getRef(self: mappings.Entity) !mappings.SerializedType(mappings.EntityRef) {
    var ref = mappings.SerializedType(mappings.EntityRef){
        .index = 0,
        .uid = 0,
    };
    ref.index = try self.getOwner();
    const db_id: u32 = @bitCast(try self.getDbId());
    if (db_id > 0) {
        ref.uid = db_id | constants.DB_ID_BIT;
    } else {
        ref.uid = try self.getEntId() & ~constants.DB_ID_BIT;
    }
    return ref;
}

pub fn select(self: mappings.Entity) !void {
    const game = mappings.Game{ .reader = self.reader };
    try self.reader.write(self.reader.modBaseAddr + game.selected.offset[0], &self.baseAddr.?);
}

pub fn follow(self: mappings.Entity) !void {
    try utils.followRef(self.reader, utils.EntityRefUnion{ .serialized = try self.getRef() });
}

pub fn isCritter(self: *mappings.Entity, _: *mappings.Game) bool {
    const name = self.getName() catch return false;
    defer self.reader.allocator.free(name);
    const character = self.getCharacter() catch return false;
    const origin = character.getOrigin() catch return false;
    defer self.reader.allocator.free(origin);
    return std.mem.eql(u8, origin, "Villain_Origin");
}

pub fn isEnemy(self: *mappings.Entity, game: *mappings.Game) bool {
    const character = self.getCharacter() catch return false;
    const player = game.getPlayer() catch return false;
    return character.isEnemy(player.getCharacter() catch return false) catch return false;
}

pub fn isAliveEnemy(self: *mappings.Entity, game: *mappings.Game) bool {
    const character = self.getCharacter() catch return false;
    const player = game.getPlayer() catch return false;
    const currentHealth = character.getCurrentHealth() catch return false;
    return (character.isEnemy(player.getCharacter() catch return false) catch return false) and currentHealth > 0;
}

pub fn isAlly(self: *mappings.Entity, game: *mappings.Game) bool {
    return !self.isNpc(game) and !self.isEnemy(game);
}

pub fn isNpc(self: *mappings.Entity, _: *mappings.Game) bool {
    const character = self.getCharacter() catch return true;
    return character.baseAddr.? == 0;
}

pub fn isInteractable(self: *mappings.Entity, _: *mappings.Game) bool {
    const glowie = self.getGlowie() catch return false;
    return glowie != 0;
}
pub fn getDistance(self: mappings.Entity, other: mappings.Entity) !f32 {
    const selfPos = self.getPos() catch return std.math.inf(f32);
    return selfPos.getDistance(other.getPos() catch return std.math.inf(f32));
}

// BEGIN Vec3
pub fn serialize(self: mappings.Vec3) !mappings.SerializedType(mappings.Vec3) {
    return .{
        .x = try self.getX(),
        .y = try self.getY(),
        .z = try self.getZ(),
    };
}

pub fn getDistance1(self: mappings.Vec3, other: mappings.Vec3) !f32 {
    const selfPos = self.serialize() catch return 0;
    const otherPos = other.serialize() catch return 0;
    // std.debug.print("self addr: {x} inline: {any}\n", .{ self.baseAddr.?, self.isInline });
    // std.debug.print("other addr: {x}\n", .{other.baseAddr.?});
    // std.debug.print("selfPos: {d} {d} {d}\n", .{ selfPos.x, selfPos.y, selfPos.z });
    // std.debug.print("otherPos: {d} {d} {d}\n", .{ otherPos.x, otherPos.y, otherPos.z });
    return std.math.sqrt(std.math.pow(f32, selfPos.x - otherPos.x, 2) +
        std.math.pow(f32, selfPos.y - otherPos.y, 2) +
        std.math.pow(f32, selfPos.z - otherPos.z, 2));
}

// BEGIN Character
pub fn isEnemy1(self: mappings.Character, otherEnt: mappings.Character) !bool {
    const selfGroup = self.getGroup() catch return false;
    const otherGroup = otherEnt.getGroup() catch return false;
    const selfOther = self.getOther() catch return false;
    const otherOther = otherEnt.getOther() catch return false;
    if (selfGroup == 0) return selfOther != otherOther;
    return selfGroup != otherGroup;
}

// BEGIN EntityRef
pub fn follow1(self: mappings.EntityRef) !void {
    try utils.followRef(self.reader, utils.EntityRefUnion{ .ptr = self });
}

pub fn getEnt(self: mappings.EntityRef) !mappings.Entity {
    return utils.getEntFromRef(self.reader, utils.EntityRefUnion{ .ptr = self });
}

// BEGIN CustomWindowList
pub fn getWindow(self: mappings.CustomWindowList, name: []const u8) !mappings.CustomWindow {
    const game = mappings.Game{ .reader = self.reader };
    const windowList = try game.getCustomWindows();
    const windows = try windowList.getWindows();
    var windowIterator = windows.iterator();
    while (try windowIterator.next()) |window| {
        const windowName = try window.getName();
        defer self.reader.allocator.free(windowName);
        if (std.mem.eql(u8, windowName, name)) return window;
    }
    return error.WindowNotFound;
    // return window.getLoc();
}

pub fn getBaseWindow(self: mappings.CustomWindowList, name: []const u8) !mappings.WindowBase {
    const window = try self.getWindow(name);
    return try window.getBaseWindow();
}

// BEGIN CustomWindow
pub fn getBaseWindow1(self: mappings.CustomWindow) !mappings.WindowBase {
    const id = try self.getId();
    const game = mappings.Game{ .reader = self.reader };
    const win_defs = try game.getWinDefs();
    const window = try win_defs.item(@intCast(id));
    return window.getLoc();
}

// BEGIN WindowBase
pub fn updatePos(self: mappings.WindowBase, x: i32, y: i32) !void {
    try self.reader.writeField(self, self.x, &x);
    try self.reader.writeField(self, self.y, &y);
}

// BEGIN ContactStatus
pub fn getParsedBitfields(self: mappings.ContactStatus) !mappings.ContactBitfields {
    return @bitCast(try self.getBitfields());
}

pub fn setParsedBitfields(self: mappings.ContactStatus, bitfields: mappings.ContactBitfields) !void {
    try self.reader.writeField(self, self.bitfields, &@as(self.bitfields.type, @bitCast(bitfields)));
}

// BEGIN TaskStatus
pub fn getParsedBitfields1(self: mappings.TaskStatus) !mappings.TaskStatusBitfields {
    return @bitCast(try self.getBitfields());
}

pub fn setParsedBitfields1(self: mappings.TaskStatus, bitfields: mappings.TaskStatusBitfields) !void {
    try self.reader.writeField(self, self.bitfields, &@as(self.bitfields.type, @bitCast(bitfields)));
}
