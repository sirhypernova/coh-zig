const std = @import("std");
const win32 = @import("zigwin32").everything;
const zigwin32 = @import("zigwin32");
const mem = @import("memory.zig");
const mappings = @import("mappings.zig");
const constants = @import("constants.zig");
const Keybinds = @import("keybinds.zig");

pub fn EntityIterator(comptime filter: fn (
    ent: *mappings.Entity,
    game: *mappings.Game,
) bool) type {
    return struct {
        index: u64 = 0,
        innerList: mappings.List(mappings.Entity, mappings.SizeUnion{ .field = .{
            .offset = @ptrCast(@constCast(&[_]i64{-40})),
            .type = u64,
        } }, null),
        reader: mem.MemoryReader,
        game: mappings.Game,
        maxLen: u64 = 0,
        pub fn next(self: *@This()) mem.MemoryError!?mappings.Entity {
            if (self.index >= self.maxLen) {
                self.index = 0;
                return null;
            }
            return while (self.index < self.maxLen) : (self.index += 1) {
                var ent = try self.innerList.item(self.index);
                if (filter(&ent, &self.game)) {
                    self.index += 1;
                    break ent;
                }
            } else null;
        }

        pub fn reset(innerSelf: @This()) void {
            innerSelf.index = 0;
        }
    };
}

pub const EntityRefUnion = union(enum) {
    ptr: mappings.EntityRef,
    serialized: mappings.SerializedType(mappings.EntityRef),
};

pub fn getEntFromRef(reader: mem.MemoryReader, ref: EntityRefUnion) !mappings.Entity {
    const index: u64 = switch (ref) {
        .ptr => @intCast(try ref.ptr.getIndex()),
        .serialized => ref.serialized.index,
    };
    if (index > 512 or index == 0) return error.OutOfBounds;
    const ptr = try reader.followOffsetsToPointer(reader.modBaseAddr + mappings.base_entity_list + ((index - 1) * 8), @ptrCast(@constCast(&[_]i64{ 0, 0 })));

    return mappings.Entity{ .reader = reader, .baseAddr = ptr };
}

pub fn getRefFromEnt(ent: mappings.Entity) !mappings.SerializedType(mappings.EntityRef) {
    var ref = mappings.SerializedType(mappings.EntityRef){
        .index = 0,
        .uid = 0,
    };
    ref.index = try ent.getOwner();
    const db_id: u32 = @bitCast(try ent.getDbId());
    if (db_id > 0) {
        ref.uid = db_id | constants.DB_ID_BIT;
    } else {
        ref.uid = try ent.getEntId() & ~constants.DB_ID_BIT;
    }
    return ref;
}

pub fn followRef(reader: mem.MemoryReader, ref: EntityRefUnion) !void {
    const game = mappings.Game{ .reader = reader };
    var index: u32 = 0;
    var uid: u32 = 0;
    switch (ref) {
        .ptr => {
            index = @intCast(try ref.ptr.getIndex());
            uid = @intCast(try ref.ptr.getUid());
        },
        .serialized => {
            index = ref.serialized.index;
            uid = ref.serialized.uid;
        },
    }

    const control_state: mappings.ControlState = try game.getControlState();
    const following = try control_state.getFollowTarget();
    const movementCount = try control_state.getMovementControlUpdateCount();
    try reader.writeField(control_state, control_state.follow_movement_count, &movementCount);
    try reader.writeField(following, following.index, &index);
    try reader.writeField(following, following.uid, &uid);
    try reader.writeField(control_state, control_state.is_following, &@as(i32, 1));
}

pub fn sendCommand(game: mappings.Game, command: []const u8) !void {
    const keybinds = try game.getKeybinds();
    const keybind = try keybinds.item(Keybinds.INP_L);
    var buf: [256:0]u8 = undefined;
    try game.reader.writeField(keybind, keybind.command, try std.fmt.bufPrintZ(&buf, "_$${s}$$unbind l", .{command}));
    try game.reader.writeField(keybind, keybind.pressed, &@as(i32, 1));
}

pub fn isCritter(ent: *mappings.Entity) bool {
    const name = ent.getName() catch return false;
    defer ent.reader.allocator.free(name);
    const character = ent.getCharacter() catch return false;
    const origin = character.getOrigin() catch return false;
    defer ent.reader.allocator.free(origin);
    return std.mem.eql(u8, origin, "Villain_Origin");
}
