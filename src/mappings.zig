const std = @import("std");
const constants = @import("constants.zig");
const mem = @import("memory.zig");
const utils = @import("utils.zig");
const Keybinds = @import("keybinds.zig");

pub fn SerializedType(comptime T: type) type {
    const info = @typeInfo(T);
    return @Type(.{
        .Struct = .{
            .layout = .auto,
            .fields = blk: {
                var fields: [info.Struct.fields.len]std.builtin.Type.StructField = undefined;
                var prevOffsets: [info.Struct.fields.len][]i64 = undefined;
                var totalFields: usize = 0;
                addFields: for (info.Struct.fields) |field| {
                    if (field.type == FieldDefinition) {
                        defer totalFields += 1;
                        const pointer: *anyopaque = @constCast(field.default_value.?);
                        const defaultValue: FieldDefinition = @as(*FieldDefinition, @ptrCast(@alignCast(pointer))).*;
                        var curField: usize = 0;
                        while (curField < totalFields) : (curField += 1) {
                            if (std.mem.eql(i64, prevOffsets[curField], defaultValue.offset)) {
                                totalFields -= 1;
                                continue :addFields;
                            }
                        }
                        prevOffsets[totalFields] = defaultValue.offset;
                        fields[totalFields] = .{ .type = defaultValue.type, .name = field.name, .is_comptime = false, .default_value = null, .alignment = 0 };
                    }
                }
                break :blk fields[0..totalFields];
            },
            .decls = &.{},
            .is_tuple = false,
        },
    });
}

// zig fmt: off
pub const FieldDefinition = struct {
    offset: []i64,
    type: type,
    itemSize: ?[]u64 = null,
    ptr: bool = false,
    isInline: bool = false, 
};

pub const SizeUnion = union(enum) {
    constant: usize,
    field: FieldDefinition
};

const EntityRefUnion = union(enum) {
    ptr: EntityRef,
    serialized: SerializedType(EntityRef),
};

pub const WindowNames = enum(u8) {
    WDW_DOCK = 0,
    WDW_STAT_BARS,
    WDW_TARGET,
    WDW_TRAY,
    WDW_CHAT_BOX,
    WDW_POWERLIST,
    WDW_GROUP,
    WDW_COMPASS,
    WDW_MAP,
    WDW_CHAT_OPTIONS,
    // 10
    WDW_FRIENDS,
    WDW_CONTACT_DIALOG,
    WDW_INSPIRATION,
    WDW_SUPERGROUP,
    WDW_EMAIL,
    WDW_EMAIL_COMPOSE,
    WDW_CONTACT,
    WDW_MISSION,
    WDW_CLUE,
    WDW_TRADE,
    // 20
    WDW_QUIT,
    WDW_INFO,
    WDW_HELP,
    WDW_MISSION_SUMMARY,
    WDW_TARGET_OPTIONS,
    WDW_BROWSER,
    WDW_LFG,
    WDW_STORE,
    WDW_DIALOG,
    WDW_BETA_COMMENT,
    // 30
    WDW_PETITION,
    WDW_TITLE_SELECT,
    WDW_DEATH,
    WDW_MAP_SELECT,
    WDW_COSTUME_SELECT,
    WDW_ENHANCEMENT,
    WDW_BADGES,
    WDW_REWARD_CHOICE,
    WDW_CHAT_CHILD_1,
    WDW_CHAT_CHILD_2,
    // 40
    WDW_CHAT_CHILD_3,
    WDW_CHAT_CHILD_4,
    WDW_DEPRECATED_1, // can't use this any more because window doesn't exist
    WDW_ARENA_CREATE,
    WDW_ARENA_LIST,
    WDW_ARENA_RESULT,
    WDW_ARENA_JOIN,
    WDW_UNUSED_1, // unused
    WDW_RENDER_STATS,
    WDW_BASE_PROPS,
    // 50
    WDW_BASE_INVENTORY,
    WDW_BASE_ROOM,
    WDW_INVENTORY,
    WDW_SALVAGE,
    WDW_CONCEPTINV,
    WDW_RECIPEINV,
    WDW_INVENT,
    WDW_SUPERGROUP_LIST,
    WDW_PET,
    WDW_ARENA_GLADIATOR_PICKER,
    // 60
    WDW_WORKSHOP, // defunct, replaced by RECIPEINVENTORY
    WDW_OPTIONS,
    WDW_SGRAID_LIST,
    WDW_SGRAID_TIME,
    WDW_SGRAID_SIZE,
    WDW_EDITOR_UI_WINDOW_1,
    WDW_EDITOR_UI_WINDOW_2,
    WDW_EDITOR_UI_WINDOW_3,
    WDW_EDITOR_UI_WINDOW_4,
    WDW_EDITOR_UI_WINDOW_5,
    // 70
    WDW_CHANNEL_SEARCH,
    WDW_BASE_STORAGE,
    WDW_BASE_LOG,
    WDW_EDITOR_UI_WINDOW_6,
    WDW_EDITOR_UI_WINDOW_7,
    WDW_EDITOR_UI_WINDOW_8,
    WDW_EDITOR_UI_WINDOW_9,
    WDW_EDITOR_UI_WINDOW_10,
    WDW_PLAQUE,
    WDW_SGRAID_STARTTIME,
    // 80
    WDW_RAIDRESULT,
    WDW_RECIPEINVENTORY,
    WDW_AUCTIONHOUSE,
    WDW_STOREDSALVAGE,
    WDW_AMOUNTSLIDER,
    WDW_DEPRECATED_2, //was WDW_GENERICPAYMENT
    WDW_COMBATNUMBERS,
    WDW_COMBATMONITOR,
    WDW_TRIALREMINDER, 
    WDW_TRAY_1,
    // 90
    WDW_TRAY_2,
    WDW_TRAY_3,
    WDW_TRAY_4,
    WDW_TRAY_5,
    WDW_TRAY_6,
    WDW_TRAY_7,
    WDW_TRAY_8,    
    WDW_COLORPICKER,    
    WDW_PLAYERNOTE,
    WDW_RECENTTEAM,
    //100
    WDW_MISSIONMAKER,
    WDW_MISSIONSEARCH,
    WDW_MISSIONREVIEW,
    WDW_BADGEMONITOR,
    WDW_CUSTOMVILLAINGROUP,
    WDW_BASE_STORAGE_PERMISSIONS,
    WDW_ARENA_OPTIONS,
    WDW_MISSIONCOMMENT,
    WDW_INCARNATE,
    WDW_INCARNATE_BAR,        //    removed
    //110
    WDW_POP_HELP,
    WDW_POP_HELP_TEXT,
    WDW_SCRIPT_UI,
    WDW_AUCTION,
    WDW_KARMA_UI,
    WDW_LEAGUE,
    WDW_TURNSTILE,
    WDW_TURNSTILE_DIALOG,
    WDW_TRAY_RAZER,
    WDW_CONTACT_FINDER,
    //120
    WDW_LOYALTY_TREE,
    WDW_WEB_STORE, // not used anymore, enum left in here to maintain protocol compatibility
    WDW_MAIN_STORE_ACCESS, // not used anymore, enum left in here to maintain protocol compatibility
    WDW_LWC_UI,
    WDW_LOYALTY_TREE_ACCESS,
    WDW_SALVAGE_OPEN,
    WDW_CONVERT_ENHANCEMENT,
    WDW_NEW_FEATURES,

    MAX_WINDOW_COUNT,
};

pub const TrayItemTypes = enum(u8) {
    None = 0,
    Power,
    Inspiration,
    BodyItem,
    SpecializationPower,
    SpecializationInventory,
    Macro,
    RespecPile,
    Tab,
    ConceptInvItem,
    PetCommand,
    Salvage,
    Recipe,
    StoredInspiration,
    StoredEnhancement,
    StoredSalvage,
    StoredRecipe,
    MacroHideName,
    PersonalStorageSalvage,
    PlayerSlot,
    PlayerCreatedMission,
    PlayerCreatedDetail,
    GroupMember,

};

pub fn List(comptime T: type, comptime size: ?SizeUnion, comptime itemSize: ?u64) type {
    return struct {
        baseAddr: ?u64 = null,
        isInline: bool = false,
        reader: mem.MemoryReader,
        comptime returnType: type = T,

        pub fn len(self: @This()) !u64 {
            if (size) |s| {
                switch (s) {
                    .constant => {
                        return s.constant;
                    },
                    .field => {
                        return try self.reader.readField(self, s.field);
                    },
                }
            } else {
                return try self.reader.read(self.baseAddr.? - 0x10, u32);
            }
        }

        pub fn item(self: @This(), index: u64) mem.MemoryError!T {
            const maxLen = self.len() catch return error.FailedToReadList;
            if (index >= maxLen) {
                return error.OutOfBounds;
            }
            // std.debug.print("inline: {any}\n", .{self.isInline});
            const readAddr = self.baseAddr orelse self.reader.modBaseAddr;
            const info = @typeInfo(T);
            switch (info) {
                .Pointer => {
                    if (info.Pointer.size == .Slice and info.Pointer.child == u8) {
                        const str = try self.followOffsetsString(readAddr, @ptrCast(@constCast(&[_]i64{0})), null);
                        return str;
                    }
                },
                else => {},
            }
            if (itemSize) |s| {
                const ptr = try self.reader.followOffsetsToPointer(readAddr, @ptrCast(@constCast(&[_]u64{index*s})));
                return T{
                    .baseAddr = ptr,
                    .isInline = false,
                    .reader = self.reader,
                };
            }
            const ptr = try self.reader.followOffsetsToPointer(readAddr, @ptrCast(@constCast(&[_]i64{0})));
            const ptr2 = try self.reader.read(ptr + (index*8), u64);
            return T{
                .baseAddr = ptr2,
                .isInline = false,
                .reader = self.reader,
            };
        }

        pub fn iterator(self: @This()) struct {
            index: u64 = 0,
            list: @TypeOf(self),
            reader: mem.MemoryReader,
            maxLen: u64 = 0,
            pub fn next(innerSelf: *@This()) mem.MemoryError!?T {
                if (innerSelf.index >= innerSelf.maxLen) {
                    innerSelf.index = 0;
                    return null;
                }
                defer innerSelf.index += 1;
                return try innerSelf.list.item(innerSelf.index);
                
            }

            pub fn reset(innerSelf: @This()) void {
                innerSelf.index = 0;
            }
        } {
            return .{
                .list = self,
                .reader = self.reader,
                .maxLen = self.len() catch unreachable,
            };
        }
    };
}

pub fn MakeBitfield(comptime field: FieldDefinition, fieldNames: []const [:0]const u8) type {
    return @Type(.{
        .Struct = .{
            .layout = .@"packed",
            .backing_integer = field.type,
            .fields = blk: {
                const totalFields = @sizeOf(field.type)*8;
                var fields: [totalFields]std.builtin.Type.StructField = undefined;
                var currentField: usize = 0;
                while (currentField < totalFields) : (currentField += 1) {
                        const name = if (currentField < fieldNames.len) fieldNames[currentField] else std.fmt.comptimePrint("_{d}", .{currentField});
                        fields[currentField] = .{ .type = bool, .name = name, .is_comptime = false, .default_value = &false, .alignment = 0 };
                }
                break :blk fields[0..totalFields];
            },
            .decls = &.{},
            .is_tuple = false,
        },
    });
}

pub const ContactBitfields = packed struct(u32) {
    notifyPlayer: bool = false,
    hasTask: bool = false,
    canUseCell: bool = false,
    hasLocation: bool = false,
    isNewspaper: bool = false,
    onStoryArc: bool = false,
    onMiniArc: bool = false,
    wontInteract: bool = false,
    metaContact: bool = false,
    _: u23 = 0,

    pub fn toNumber(self: ContactBitfields) u32 {
        return @bitCast(self);
    }
};

pub const TaskStatusBitfields = packed struct(u32) {
    isComplete: bool = false,
    isMission: bool = false,
    hasRunningMission: bool = false,
    isSGMission: bool = false,
    hasLocation: bool = false,
    detailInvalid: bool = false,
    zoneTransfer: bool = false,
    teleportOnComplete: bool = false,
    enforceTimeLimit: bool = false,
    isAbandonable: bool = false,
    isZowie: bool = false,
    _: u21 = 0,

    pub fn toNumber(self: TaskStatusBitfields) u32 {
        return @bitCast(self);
    }
};

pub const EntityBitfields = packed struct(u32) {
    checked_coll_tracker: bool = false,
    logout_bad_connection: bool = false,
    noDrawOnClient: bool = false,
    contactOrPnpc: bool = false,
    alwaysCon: bool = false,
    seeThroughWalls: bool = false,
    aiAnimListUpdated: bool = false,
    commandablePet: bool = false,
    petDismissable: bool = false,
    contactArchitect: bool = false,
    custom_critter: bool = false,
    petByScript: bool = false,
    showOnMap: bool = false,
    dunno: bool = false,
    notSelectable: bool = false,
    doppelganger: bool = false,
    costume_is_mutable: bool = false,
    _: u15 = 0,

    pub fn toNumber(self: EntityBitfields) u32 {
        return @bitCast(self);
    }
};

pub const Movement = packed struct {
    forward: bool = false,
    backward: bool = false,
    left: bool = false,
    right: bool = false,
    up: bool = false,
    down: bool = false,
    _1: bool = false,
    _2: bool = false,

    pub fn toNumber(self: Movement) u8 {
        return @bitCast(self);
    }
};
// zig fmt: on

pub const base_entity_list = 0x117de68;
pub const Game = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime player: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xa07558, 0x0 })),
        .type = Entity,
        .ptr = true,
    },
    comptime selected: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xd223d8, 0x0 })),
        .type = Entity,
        .ptr = true,
    },
    comptime state: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15dc088})),
        .type = GameState,
        .ptr = true,
    },
    comptime is_following: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f9740})),
        .type = i32,
    },
    comptime following: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f9748})),
        .type = EntityRef,
        .ptr = true,
    },
    comptime num_entities: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x117de80})),
        .type = i32,
    },
    comptime entities: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x117dea8})),
        .type = List(Entity, SizeUnion{ .field = .{
            .offset = @ptrCast(@constCast(&[_]i64{-40})),
            .type = u64,
        } }, null),
        .ptr = true,
    },
    comptime tray: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xaafe98, 0x0 })),
        .type = Tray,
        .ptr = true,
    },
    comptime map_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xbfa484})),
        .type = i32,
    },
    comptime map_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15de374})),
        .type = []u8,
    },
    comptime chat_open: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd22388})),
        .type = i32,
    },
    comptime attrib_categories: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9b48a0})),
        .type = AttribCategoryList,
        .ptr = true,
    },
    comptime no_coll: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f96d0})),
        .type = i32,
    },
    comptime no_sync: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f96d4})),
        .type = i32,
    },
    comptime pitch: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f9648})),
        .type = f32,
    },
    comptime yaw: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f964c})),
        .type = f32,
    },
    comptime control_state: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15f9648})),
        .type = ControlState,
        .ptr = true,
    },
    comptime thumbtack: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa44a38})),
        .type = Vec3,
        .ptr = true,
    },
    comptime thumbtack_message: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa44a51})),
        .type = []u8,
    },
    comptime first_menu_option: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd31e00})),
        .type = []u8,
    },
    comptime custom_windows: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa44e30})),
        .type = CustomWindowList,
        .ptr = true,
    },
    comptime win_defs: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9b49d0})),
        .type = List(Window, SizeUnion{
            .constant = 153,
        }, 0x458),
        .ptr = true,
    },
    comptime keybinds: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15cfdd8})),
        .type = List(KeyBind, SizeUnion{
            .constant = 256,
        }, 0x88),
        .ptr = true,
    },
    comptime contacts: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa06cf8})),
        .type = ContactList,
        .ptr = true,
    },
    comptime waypoint_dest: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa449d0})),
        .type = Destination,
        .ptr = true,
    },
    comptime active_task_dest: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa449d0})),
        .type = Destination,
        .ptr = true,
    },
    comptime task_status_sets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa06cc8})),
        .type = TaskStatusSetList,
        .ptr = true,
    },
    comptime map_data: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8966d8})),
        .type = MapData,
        .ptr = true,
    },
    pub fn getPlayer(self: @This()) !Entity {
        return self.reader.readField(self, self.player);
    }
    pub fn getSelected(self: @This()) !Entity {
        return self.reader.readField(self, self.selected);
    }
    pub fn getState(self: @This()) !GameState {
        return self.reader.readField(self, self.state);
    }
    pub fn getIsFollowing(self: @This()) !i32 {
        return self.reader.readField(self, self.is_following);
    }
    pub fn getFollowing(self: @This()) !EntityRef {
        return self.reader.readField(self, self.following);
    }
    pub fn getNumEntities(self: @This()) !i32 {
        return self.reader.readField(self, self.num_entities);
    }
    pub fn getEntities(self: @This()) !List(Entity, SizeUnion{ .field = .{
        .offset = @ptrCast(@constCast(&[_]i64{-40})),
        .type = u64,
    } }, null) {
        return self.reader.readField(self, self.entities);
    }
    pub fn getTray(self: @This()) !Tray {
        return self.reader.readField(self, self.tray);
    }
    pub fn getMapId(self: @This()) !i32 {
        return self.reader.readField(self, self.map_id);
    }
    pub fn getMapName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.map_name);
    }
    pub fn getChatOpen(self: @This()) !i32 {
        return self.reader.readField(self, self.chat_open);
    }
    pub fn getAttribCategories(self: @This()) !AttribCategoryList {
        return self.reader.readField(self, self.attrib_categories);
    }
    pub fn getNoColl(self: @This()) !i32 {
        return self.reader.readField(self, self.no_coll);
    }
    pub fn getNoSync(self: @This()) !i32 {
        return self.reader.readField(self, self.no_sync);
    }
    pub fn getPitch(self: @This()) !f32 {
        return self.reader.readField(self, self.pitch);
    }
    pub fn getYaw(self: @This()) !f32 {
        return self.reader.readField(self, self.yaw);
    }
    pub fn getControlState(self: @This()) !ControlState {
        return self.reader.readField(self, self.control_state);
    }
    pub fn getThumbtack(self: @This()) !Vec3 {
        return self.reader.readField(self, self.thumbtack);
    }
    pub fn getThumbtackMessage(self: @This()) ![]u8 {
        return self.reader.readField(self, self.thumbtack_message);
    }
    pub fn getFirstMenuOption(self: @This()) ![]u8 {
        return self.reader.readField(self, self.first_menu_option);
    }
    pub fn getCustomWindows(self: @This()) !CustomWindowList {
        return self.reader.readField(self, self.custom_windows);
    }
    pub fn getWinDefs(self: @This()) !List(Window, SizeUnion{
        .constant = 153,
    }, 0x458) {
        return self.reader.readField(self, self.win_defs);
    }
    pub fn getKeybinds(self: @This()) !List(KeyBind, SizeUnion{
        .constant = 256,
    }, 0x88) {
        return self.reader.readField(self, self.keybinds);
    }
    pub fn getContacts(self: @This()) !ContactList {
        return self.reader.readField(self, self.contacts);
    }
    pub fn getWaypointDest(self: @This()) !Destination {
        return self.reader.readField(self, self.waypoint_dest);
    }
    pub fn getActiveTaskDest(self: @This()) !Destination {
        return self.reader.readField(self, self.active_task_dest);
    }
    pub fn getTaskStatusSets(self: @This()) !TaskStatusSetList {
        return self.reader.readField(self, self.task_status_sets);
    }
    pub fn getMapData(self: @This()) !MapData {
        return self.reader.readField(self, self.map_data);
    }
    pub fn getKeybind(self: Game, key: u64) ![]const u8 {
        const keybinds = try self.getKeybinds();
        const keybind = try keybinds.item(key);
        const command = try keybind.getCommand();
        return command;
    }

    pub fn setKeybind(self: Game, key: u64, command: []const u8) !void {
        const keybinds = try self.getKeybinds();
        const keybind = try keybinds.item(key);
        try self.reader.writeField(keybind, keybind.command, command);
    }

    pub fn getMovement(self: Game) !Movement {
        const controlState: ControlState = try self.getControlState();
        return @bitCast(try controlState.getMovement());
    }

    pub fn setMovement(self: Game, movement: Movement) !void {
        const controlState: ControlState = try self.getControlState();
        try self.reader.writeField(controlState, controlState.movement, &movement.toNumber());
    }

    pub fn sendCommand(self: Game, command: []const u8) !void {
        return utils.sendCommand(self, command);
    }

    pub fn getCritters(self: Game) !utils.EntityIterator(Entity.isCritter) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{ .reader = self.reader, .innerList = entities, .maxLen = try entities.len(), .game = self };
    }

    pub fn getEnemies(self: Game) !utils.EntityIterator(Entity.isEnemy) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{
            .reader = self.reader,
            .innerList = entities,
            .maxLen = try entities.len(),
            .game = self,
        };
    }

    pub fn getAliveEnemies(self: Game) !utils.EntityIterator(Entity.isAliveEnemy) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{
            .reader = self.reader,
            .innerList = entities,
            .maxLen = try entities.len(),
            .game = self,
        };
    }

    pub fn getAllies(self: Game) !utils.EntityIterator(Entity.isAlly) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{
            .reader = self.reader,
            .innerList = entities,
            .maxLen = try entities.len(),
            .game = self,
        };
    }

    pub fn getNpcs(self: Game) !utils.EntityIterator(Entity.isNpc) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{
            .reader = self.reader,
            .innerList = entities,
            .maxLen = try entities.len(),
            .game = self,
        };
    }

    pub fn getInteractables(self: Game) !utils.EntityIterator(Entity.isInteractable) {
        const game = Game{ .reader = self.reader };
        const entities = try game.getEntities();
        return .{
            .reader = self.reader,
            .innerList = entities,
            .maxLen = try entities.len(),
            .game = self,
        };
    }
};
pub const MapData = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime zoom: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime max_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = Vec3,
        .ptr = true,
    },
    comptime min_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = Vec3,
        .ptr = true,
    },
    pub fn getZoom(self: @This()) !f32 {
        return self.reader.readField(self, self.zoom);
    }
    pub fn getMaxPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.max_pos);
    }
    pub fn getMinPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.min_pos);
    }
};
pub const TaskStatusSet = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime db_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime difficulty: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime size: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime av: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime list: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = List(TaskStatus, null, null),
        .ptr = true,
    },
    pub fn getDbId(self: @This()) !i32 {
        return self.reader.readField(self, self.db_id);
    }
    pub fn getDifficulty(self: @This()) !i32 {
        return self.reader.readField(self, self.difficulty);
    }
    pub fn getSize(self: @This()) !i32 {
        return self.reader.readField(self, self.size);
    }
    pub fn getAv(self: @This()) !i32 {
        return self.reader.readField(self, self.av);
    }
    pub fn getList(self: @This()) !List(TaskStatus, null, null) {
        return self.reader.readField(self, self.list);
    }
};
pub const TaskStatus = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime owner_db_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime context: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime subhandle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime alliance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime difficulty: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = i32,
    },
    comptime description: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = []u8,
    },
    comptime owner: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x124})),
        .type = []u8,
    },
    comptime state: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x175})),
        .type = []u8,
    },
    comptime detail: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2a5})),
        .type = []u8,
    },
    comptime intro: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x50c6})),
        .type = []u8,
    },
    comptime filename: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x51c6})),
        .type = []u8,
    },
    comptime bitfields: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x52c8})),
        .type = u32,
    },
    comptime destination: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x52d0})),
        .type = Destination,
        .isInline = true,
    },
    pub fn getOwnerDbId(self: @This()) !i32 {
        return self.reader.readField(self, self.owner_db_id);
    }
    pub fn getContext(self: @This()) !i32 {
        return self.reader.readField(self, self.context);
    }
    pub fn getSubhandle(self: @This()) !i32 {
        return self.reader.readField(self, self.subhandle);
    }
    pub fn getLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.level);
    }
    pub fn getAlliance(self: @This()) !i32 {
        return self.reader.readField(self, self.alliance);
    }
    pub fn getDifficulty(self: @This()) !i32 {
        return self.reader.readField(self, self.difficulty);
    }
    pub fn getDescription(self: @This()) ![]u8 {
        return self.reader.readField(self, self.description);
    }
    pub fn getOwner(self: @This()) ![]u8 {
        return self.reader.readField(self, self.owner);
    }
    pub fn getState(self: @This()) ![]u8 {
        return self.reader.readField(self, self.state);
    }
    pub fn getDetail(self: @This()) ![]u8 {
        return self.reader.readField(self, self.detail);
    }
    pub fn getIntro(self: @This()) ![]u8 {
        return self.reader.readField(self, self.intro);
    }
    pub fn getFilename(self: @This()) ![]u8 {
        return self.reader.readField(self, self.filename);
    }
    pub fn getBitfields(self: @This()) !u32 {
        return self.reader.readField(self, self.bitfields);
    }
    pub fn getDestination(self: @This()) !Destination {
        return self.reader.readField(self, self.destination);
    }
    pub fn getParsedBitfields(self: TaskStatus) !TaskStatusBitfields {
        return @bitCast(try self.getBitfields());
    }

    pub fn setParsedBitfields(self: TaskStatus, bitfields: TaskStatusBitfields) !void {
        try self.reader.writeField(self, self.bitfields, &@as(self.bitfields.type, @bitCast(bitfields)));
    }
};
pub const Destination = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime nav_on: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime contact_type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = i32,
    },
    comptime color_b: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = i32,
    },
    comptime angle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = f32,
    },
    comptime map_location: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x2c, 0x0 })),
        .type = Vec2,
        .ptr = true,
    },
    comptime sep_location: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x34, 0x0 })),
        .type = Vec2,
        .ptr = true,
    },
    comptime view_location: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x3c, 0x0 })),
        .type = Vec2,
        .ptr = true,
    },
    comptime world_location: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x44, 0x0 })),
        .type = Mat4,
        .ptr = true,
    },
    comptime orig_world_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x74, 0x0 })),
        .type = Vec3,
        .ptr = true,
    },
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x81})),
        .type = []u8,
    },
    comptime map_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x181})),
        .type = []u8,
    },
    comptime uid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x394})),
        .type = i32,
    },
    comptime bitfields: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x398})),
        .type = u8,
    },
    comptime creation_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x39c})),
        .type = u32,
    },
    comptime dest_entity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x3a8, 0x0 })),
        .type = Entity,
        .ptr = true,
    },
    comptime source_file: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x3b0, 0x0 })),
        .type = []u8,
    },
    comptime dbid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3b8})),
        .type = u32,
    },
    comptime context: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3bc})),
        .type = i32,
    },
    comptime subhandle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c0})),
        .type = i32,
    },
    comptime handle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3b8})),
        .type = i32,
    },
    pub fn getNavOn(self: @This()) !i32 {
        return self.reader.readField(self, self.nav_on);
    }
    pub fn getType(self: @This()) !i32 {
        return self.reader.readField(self, self.type);
    }
    pub fn getContactType(self: @This()) !i32 {
        return self.reader.readField(self, self.contact_type);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getColor(self: @This()) !i32 {
        return self.reader.readField(self, self.color);
    }
    pub fn getColorB(self: @This()) !i32 {
        return self.reader.readField(self, self.color_b);
    }
    pub fn getAngle(self: @This()) !f32 {
        return self.reader.readField(self, self.angle);
    }
    pub fn getMapLocation(self: @This()) !Vec2 {
        return self.reader.readField(self, self.map_location);
    }
    pub fn getSepLocation(self: @This()) !Vec2 {
        return self.reader.readField(self, self.sep_location);
    }
    pub fn getViewLocation(self: @This()) !Vec2 {
        return self.reader.readField(self, self.view_location);
    }
    pub fn getWorldLocation(self: @This()) !Mat4 {
        return self.reader.readField(self, self.world_location);
    }
    pub fn getOrigWorldPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.orig_world_pos);
    }
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getMapName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.map_name);
    }
    pub fn getUid(self: @This()) !i32 {
        return self.reader.readField(self, self.uid);
    }
    pub fn getBitfields(self: @This()) !u8 {
        return self.reader.readField(self, self.bitfields);
    }
    pub fn getCreationTime(self: @This()) !u32 {
        return self.reader.readField(self, self.creation_time);
    }
    pub fn getDestEntity(self: @This()) !Entity {
        return self.reader.readField(self, self.dest_entity);
    }
    pub fn getSourceFile(self: @This()) ![]u8 {
        return self.reader.readField(self, self.source_file);
    }
    pub fn getDbid(self: @This()) !u32 {
        return self.reader.readField(self, self.dbid);
    }
    pub fn getContext(self: @This()) !i32 {
        return self.reader.readField(self, self.context);
    }
    pub fn getSubhandle(self: @This()) !i32 {
        return self.reader.readField(self, self.subhandle);
    }
    pub fn getHandle(self: @This()) !i32 {
        return self.reader.readField(self, self.handle);
    }
};
pub const ControlState = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime pitch: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime yaw: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime movement: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x34})),
        .type = u8,
    },
    comptime no_coll: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x88})),
        .type = i32,
    },
    comptime no_sync: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8c})),
        .type = i32,
    },
    comptime predict: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe0})),
        .type = i32,
    },
    comptime no_timeout: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe8})),
        .type = i32,
    },
    comptime autorun: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xec})),
        .type = i32,
    },
    comptime inp_vel_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf0})),
        .type = f32,
    },
    comptime max_speed_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf4})),
        .type = f32,
    },
    comptime is_following: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf8})),
        .type = i32,
    },
    comptime follow_target: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x100})),
        .type = EntityRef,
        .isInline = true,
    },
    comptime follow_movement_count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x108})),
        .type = i32,
    },
    comptime start_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x118})),
        .type = Vec3,
        .isInline = true,
    },
    comptime end_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x124})),
        .type = Vec3,
        .isInline = true,
    },
    comptime movement_control_update_count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1ca8})),
        .type = i32,
    },
    comptime zoom_in: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cb8})),
        .type = i32,
    },
    comptime zoom_out: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cbc})),
        .type = i32,
    },
    comptime look_up: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc0})),
        .type = i32,
    },
    comptime look_down: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc4})),
        .type = i32,
    },
    comptime no_ragdoll: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc8})),
        .type = i32,
    },
    comptime detached_camera: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1ccc})),
        .type = i32,
    },
    pub fn getPitch(self: @This()) !f32 {
        return self.reader.readField(self, self.pitch);
    }
    pub fn getYaw(self: @This()) !f32 {
        return self.reader.readField(self, self.yaw);
    }
    pub fn getMovement(self: @This()) !u8 {
        return self.reader.readField(self, self.movement);
    }
    pub fn getNoColl(self: @This()) !i32 {
        return self.reader.readField(self, self.no_coll);
    }
    pub fn getNoSync(self: @This()) !i32 {
        return self.reader.readField(self, self.no_sync);
    }
    pub fn getPredict(self: @This()) !i32 {
        return self.reader.readField(self, self.predict);
    }
    pub fn getNoTimeout(self: @This()) !i32 {
        return self.reader.readField(self, self.no_timeout);
    }
    pub fn getAutorun(self: @This()) !i32 {
        return self.reader.readField(self, self.autorun);
    }
    pub fn getInpVelScale(self: @This()) !f32 {
        return self.reader.readField(self, self.inp_vel_scale);
    }
    pub fn getMaxSpeedScale(self: @This()) !f32 {
        return self.reader.readField(self, self.max_speed_scale);
    }
    pub fn getIsFollowing(self: @This()) !i32 {
        return self.reader.readField(self, self.is_following);
    }
    pub fn getFollowTarget(self: @This()) !EntityRef {
        return self.reader.readField(self, self.follow_target);
    }
    pub fn getFollowMovementCount(self: @This()) !i32 {
        return self.reader.readField(self, self.follow_movement_count);
    }
    pub fn getStartPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.start_pos);
    }
    pub fn getEndPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.end_pos);
    }
    pub fn getMovementControlUpdateCount(self: @This()) !i32 {
        return self.reader.readField(self, self.movement_control_update_count);
    }
    pub fn getZoomIn(self: @This()) !i32 {
        return self.reader.readField(self, self.zoom_in);
    }
    pub fn getZoomOut(self: @This()) !i32 {
        return self.reader.readField(self, self.zoom_out);
    }
    pub fn getLookUp(self: @This()) !i32 {
        return self.reader.readField(self, self.look_up);
    }
    pub fn getLookDown(self: @This()) !i32 {
        return self.reader.readField(self, self.look_down);
    }
    pub fn getNoRagdoll(self: @This()) !i32 {
        return self.reader.readField(self, self.no_ragdoll);
    }
    pub fn getDetachedCamera(self: @This()) !i32 {
        return self.reader.readField(self, self.detached_camera);
    }
};
pub const KeyBind = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime key: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime modifier: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime secondary: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime pressed: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime command: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x38, 0x0 })),
        .type = []u8,
    },
    comptime command_pointer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = i64,
    },
    pub fn getKey(self: @This()) !i32 {
        return self.reader.readField(self, self.key);
    }
    pub fn getModifier(self: @This()) !i32 {
        return self.reader.readField(self, self.modifier);
    }
    pub fn getSecondary(self: @This()) !i32 {
        return self.reader.readField(self, self.secondary);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getPressed(self: @This()) !i32 {
        return self.reader.readField(self, self.pressed);
    }
    pub fn getCommand(self: @This()) ![]u8 {
        return self.reader.readField(self, self.command);
    }
    pub fn getCommandPointer(self: @This()) !i64 {
        return self.reader.readField(self, self.command_pointer);
    }
};
pub const Window = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime loc: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = WindowBase,
        .ptr = true,
    },
    comptime max_ht: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x7c})),
        .type = i32,
    },
    comptime max_wd: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x80})),
        .type = i32,
    },
    comptime min_ht: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x84})),
        .type = i32,
    },
    comptime min_wd: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x88})),
        .type = i32,
    },
    comptime drag_mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8c})),
        .type = i32,
    },
    comptime being_dragged: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x90})),
        .type = i32,
    },
    comptime mouse_down_x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x94})),
        .type = i32,
    },
    comptime mouse_down_y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x98})),
        .type = i32,
    },
    comptime relX: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9c})),
        .type = i32,
    },
    comptime relY: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa0})),
        .type = i32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xb8})),
        .type = i32,
    },
    comptime below: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xbc})),
        .type = i32,
    },
    comptime left: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc0})),
        .type = i32,
    },
    comptime flip: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc4})),
        .type = i32,
    },
    comptime opacity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc8})),
        .type = f32,
    },
    comptime min_opacity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xcc})),
        .type = f32,
    },
    comptime fade_timer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd0})),
        .type = f32,
    },
    comptime save: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd4})),
        .type = i32,
    },
    comptime force_color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd8})),
        .type = i32,
    },
    comptime no_close_button: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xdc})),
        .type = i32,
    },
    comptime use_title: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe0})),
        .type = i32,
    },
    comptime force_no_flip: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe4})),
        .type = i32,
    },
    comptime no_frame: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe8})),
        .type = i32,
    },
    comptime title: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xec})),
        .type = []u8,
    },
    comptime maximizable: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x120})),
        .type = i32,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x128, 0x0 })),
        .type = Window,
        .ptr = true,
    },
    comptime num_children: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x130})),
        .type = i32,
    },
    comptime open_child: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x134})),
        .type = i32,
    },
    comptime child_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x138})),
        .type = i32,
    },
    comptime children: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x144})),
        .type = List(ChildWindow, SizeUnion{
            .constant = 11,
        }, 0x48),
        .ptr = true,
    },
    pub fn getLoc(self: @This()) !WindowBase {
        return self.reader.readField(self, self.loc);
    }
    pub fn getMaxHt(self: @This()) !i32 {
        return self.reader.readField(self, self.max_ht);
    }
    pub fn getMaxWd(self: @This()) !i32 {
        return self.reader.readField(self, self.max_wd);
    }
    pub fn getMinHt(self: @This()) !i32 {
        return self.reader.readField(self, self.min_ht);
    }
    pub fn getMinWd(self: @This()) !i32 {
        return self.reader.readField(self, self.min_wd);
    }
    pub fn getDragMode(self: @This()) !i32 {
        return self.reader.readField(self, self.drag_mode);
    }
    pub fn getBeingDragged(self: @This()) !i32 {
        return self.reader.readField(self, self.being_dragged);
    }
    pub fn getMouseDownX(self: @This()) !i32 {
        return self.reader.readField(self, self.mouse_down_x);
    }
    pub fn getMouseDownY(self: @This()) !i32 {
        return self.reader.readField(self, self.mouse_down_y);
    }
    pub fn getRelX(self: @This()) !i32 {
        return self.reader.readField(self, self.relX);
    }
    pub fn getRelY(self: @This()) !i32 {
        return self.reader.readField(self, self.relY);
    }
    pub fn getRadius(self: @This()) !i32 {
        return self.reader.readField(self, self.radius);
    }
    pub fn getBelow(self: @This()) !i32 {
        return self.reader.readField(self, self.below);
    }
    pub fn getLeft(self: @This()) !i32 {
        return self.reader.readField(self, self.left);
    }
    pub fn getFlip(self: @This()) !i32 {
        return self.reader.readField(self, self.flip);
    }
    pub fn getOpacity(self: @This()) !f32 {
        return self.reader.readField(self, self.opacity);
    }
    pub fn getMinOpacity(self: @This()) !f32 {
        return self.reader.readField(self, self.min_opacity);
    }
    pub fn getFadeTimer(self: @This()) !f32 {
        return self.reader.readField(self, self.fade_timer);
    }
    pub fn getSave(self: @This()) !i32 {
        return self.reader.readField(self, self.save);
    }
    pub fn getForceColor(self: @This()) !i32 {
        return self.reader.readField(self, self.force_color);
    }
    pub fn getNoCloseButton(self: @This()) !i32 {
        return self.reader.readField(self, self.no_close_button);
    }
    pub fn getUseTitle(self: @This()) !i32 {
        return self.reader.readField(self, self.use_title);
    }
    pub fn getForceNoFlip(self: @This()) !i32 {
        return self.reader.readField(self, self.force_no_flip);
    }
    pub fn getNoFrame(self: @This()) !i32 {
        return self.reader.readField(self, self.no_frame);
    }
    pub fn getTitle(self: @This()) ![]u8 {
        return self.reader.readField(self, self.title);
    }
    pub fn getMaximizable(self: @This()) !i32 {
        return self.reader.readField(self, self.maximizable);
    }
    pub fn getParent(self: @This()) !Window {
        return self.reader.readField(self, self.parent);
    }
    pub fn getNumChildren(self: @This()) !i32 {
        return self.reader.readField(self, self.num_children);
    }
    pub fn getOpenChild(self: @This()) !i32 {
        return self.reader.readField(self, self.open_child);
    }
    pub fn getChildId(self: @This()) !i32 {
        return self.reader.readField(self, self.child_id);
    }
    pub fn getChildren(self: @This()) !List(ChildWindow, SizeUnion{
        .constant = 11,
    }, 0x48) {
        return self.reader.readField(self, self.children);
    }
};
pub const WindowBase = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime width: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime height: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime draggable_frame: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime locked: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = i32,
    },
    comptime start_shrunk: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = i32,
    },
    comptime back_color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = i32,
    },
    comptime sc: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = f32,
    },
    comptime maximized: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = i32,
    },
    pub fn getX(self: @This()) !i32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !i32 {
        return self.reader.readField(self, self.y);
    }
    pub fn getWidth(self: @This()) !i32 {
        return self.reader.readField(self, self.width);
    }
    pub fn getHeight(self: @This()) !i32 {
        return self.reader.readField(self, self.height);
    }
    pub fn getDraggableFrame(self: @This()) !i32 {
        return self.reader.readField(self, self.draggable_frame);
    }
    pub fn getLocked(self: @This()) !i32 {
        return self.reader.readField(self, self.locked);
    }
    pub fn getStartShrunk(self: @This()) !i32 {
        return self.reader.readField(self, self.start_shrunk);
    }
    pub fn getColor(self: @This()) !i32 {
        return self.reader.readField(self, self.color);
    }
    pub fn getBackColor(self: @This()) !i32 {
        return self.reader.readField(self, self.back_color);
    }
    pub fn getSc(self: @This()) !f32 {
        return self.reader.readField(self, self.sc);
    }
    pub fn getMaximized(self: @This()) !i32 {
        return self.reader.readField(self, self.maximized);
    }
    pub fn getMode(self: @This()) !i32 {
        return self.reader.readField(self, self.mode);
    }
    pub fn updatePos(self: WindowBase, x: i32, y: i32) !void {
        try self.reader.writeField(self, self.x, &x);
        try self.reader.writeField(self, self.y, &y);
    }
};
pub const ChildWindow = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime idx: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime window: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x4, 0x0 })),
        .type = Window,
        .ptr = true,
    },
    comptime opacity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = []u8,
    },
    comptime command: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x34, 0x0 })),
        .type = []u8,
    },
    comptime width: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = f32,
    },
    comptime scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = f32,
    },
    pub fn getIdx(self: @This()) !i32 {
        return self.reader.readField(self, self.idx);
    }
    pub fn getWindow(self: @This()) !Window {
        return self.reader.readField(self, self.window);
    }
    pub fn getOpacity(self: @This()) !f32 {
        return self.reader.readField(self, self.opacity);
    }
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getCommand(self: @This()) ![]u8 {
        return self.reader.readField(self, self.command);
    }
    pub fn getWidth(self: @This()) !f32 {
        return self.reader.readField(self, self.width);
    }
    pub fn getScale(self: @This()) !f32 {
        return self.reader.readField(self, self.scale);
    }
};
pub const CustomWindowList = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime windows: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(CustomWindow, null, null),
        .ptr = true,
    },
    pub fn getWindows(self: @This()) !List(CustomWindow, null, null) {
        return self.reader.readField(self, self.windows);
    }
    pub fn getWindow(self: CustomWindowList, name: []const u8) !CustomWindow {
        const game = Game{ .reader = self.reader };
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

    pub fn getBaseWindow(self: CustomWindowList, name: []const u8) !WindowBase {
        const window = try self.getWindow(name);
        return try window.getBaseWindow();
    }
};
pub const CustomWindow = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime file_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = f32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = f32,
    },
    comptime width: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = f32,
    },
    comptime height: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = f32,
    },
    comptime items: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = List(CustomWindowItem, null, null),
        .ptr = true,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime opened: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = i32,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getFileName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.file_name);
    }
    pub fn getX(self: @This()) !f32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !f32 {
        return self.reader.readField(self, self.y);
    }
    pub fn getWidth(self: @This()) !f32 {
        return self.reader.readField(self, self.width);
    }
    pub fn getHeight(self: @This()) !f32 {
        return self.reader.readField(self, self.height);
    }
    pub fn getItems(self: @This()) !List(CustomWindowItem, null, null) {
        return self.reader.readField(self, self.items);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getOpened(self: @This()) !i32 {
        return self.reader.readField(self, self.opened);
    }
    pub fn getBaseWindow(self: CustomWindow) !WindowBase {
        const id = try self.getId();
        const game = Game{ .reader = self.reader };
        const win_defs = try game.getWinDefs();
        const window = try win_defs.item(@intCast(id));
        return window.getLoc();
    }
};
pub const CustomWindowItem = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime command: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getCommand(self: @This()) ![]u8 {
        return self.reader.readField(self, self.command);
    }
};
pub const ContactList = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime contacts: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(ContactStatus, null, null),
        .ptr = true,
    },
    pub fn getContacts(self: @This()) !List(ContactStatus, null, null) {
        return self.reader.readField(self, self.contacts);
    }
};
pub const DestinationList = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime destinations: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(Destination, null, null),
        .ptr = true,
    },
    pub fn getDestinations(self: @This()) !List(Destination, null, null) {
        return self.reader.readField(self, self.destinations);
    }
};
pub const TaskStatusSetList = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime task_status_sets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(TaskStatusSet, null, null),
        .ptr = true,
    },
    pub fn getTaskStatusSets(self: @This()) !List(TaskStatusSet, null, null) {
        return self.reader.readField(self, self.task_status_sets);
    }
};
pub const ContactStatus = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime location_description: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime filename: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = []u8,
    },
    comptime call_override: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = []u8,
    },
    comptime ask_about_override: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = []u8,
    },
    comptime leave_override: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x28, 0x0 })),
        .type = []u8,
    },
    comptime image_override: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x30, 0x0 })),
        .type = []u8,
    },
    comptime npc_num: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = i32,
    },
    comptime handle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = i32,
    },
    comptime task_context: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = i32,
    },
    comptime task_subhandle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = i32,
    },
    comptime time_auto_revoke: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48})),
        .type = u32,
    },
    comptime current_cp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c})),
        .type = i32,
    },
    comptime friend_cp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x50})),
        .type = i32,
    },
    comptime confidant_cp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x54})),
        .type = i32,
    },
    comptime complete_cp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x58})),
        .type = i32,
    },
    comptime heist_cp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x5c})),
        .type = i32,
    },
    comptime tip_type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = u32,
    },
    comptime bitfields: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x64})),
        .type = u32,
    },
    comptime location: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x70})),
        .type = Destination,
        .isInline = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getLocationDescription(self: @This()) ![]u8 {
        return self.reader.readField(self, self.location_description);
    }
    pub fn getFilename(self: @This()) ![]u8 {
        return self.reader.readField(self, self.filename);
    }
    pub fn getCallOverride(self: @This()) ![]u8 {
        return self.reader.readField(self, self.call_override);
    }
    pub fn getAskAboutOverride(self: @This()) ![]u8 {
        return self.reader.readField(self, self.ask_about_override);
    }
    pub fn getLeaveOverride(self: @This()) ![]u8 {
        return self.reader.readField(self, self.leave_override);
    }
    pub fn getImageOverride(self: @This()) ![]u8 {
        return self.reader.readField(self, self.image_override);
    }
    pub fn getNpcNum(self: @This()) !i32 {
        return self.reader.readField(self, self.npc_num);
    }
    pub fn getHandle(self: @This()) !i32 {
        return self.reader.readField(self, self.handle);
    }
    pub fn getTaskContext(self: @This()) !i32 {
        return self.reader.readField(self, self.task_context);
    }
    pub fn getTaskSubhandle(self: @This()) !i32 {
        return self.reader.readField(self, self.task_subhandle);
    }
    pub fn getTimeAutoRevoke(self: @This()) !u32 {
        return self.reader.readField(self, self.time_auto_revoke);
    }
    pub fn getCurrentCp(self: @This()) !i32 {
        return self.reader.readField(self, self.current_cp);
    }
    pub fn getFriendCp(self: @This()) !i32 {
        return self.reader.readField(self, self.friend_cp);
    }
    pub fn getConfidantCp(self: @This()) !i32 {
        return self.reader.readField(self, self.confidant_cp);
    }
    pub fn getCompleteCp(self: @This()) !i32 {
        return self.reader.readField(self, self.complete_cp);
    }
    pub fn getHeistCp(self: @This()) !i32 {
        return self.reader.readField(self, self.heist_cp);
    }
    pub fn getTipType(self: @This()) !u32 {
        return self.reader.readField(self, self.tip_type);
    }
    pub fn getBitfields(self: @This()) !u32 {
        return self.reader.readField(self, self.bitfields);
    }
    pub fn getLocation(self: @This()) !Destination {
        return self.reader.readField(self, self.location);
    }
    pub fn getParsedBitfields(self: ContactStatus) !ContactBitfields {
        return @bitCast(try self.getBitfields());
    }

    pub fn setParsedBitfields(self: ContactStatus, bitfields: ContactBitfields) !void {
        try self.reader.writeField(self, self.bitfields, &@as(self.bitfields.type, @bitCast(bitfields)));
    }
};
pub const Entity = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime owner: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = u32,
    },
    comptime pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x40, 0x0, 0xc })),
        .type = Vec3,
        .isInline = true,
    },
    comptime motion: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x40, 0x0 })),
        .type = MotionState,
        .ptr = true,
    },
    comptime pl: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x48, 0x0 })),
        .type = EntPlayer,
        .ptr = true,
    },
    comptime fork: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x54})),
        .type = Mat4,
        .isInline = true,
    },
    comptime room_im_in: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xe58, 0x0 })),
        .type = DefTracker,
        .ptr = true,
    },
    comptime character: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xe88, 0x0 })),
        .type = Character,
        .ptr = true,
    },
    comptime translucency: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc60})),
        .type = f32,
    },
    comptime glowie: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc68})),
        .type = i32,
    },
    comptime ent_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x90})),
        .type = u32,
    },
    comptime db_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x94})),
        .type = i32,
    },
    comptime supergroup_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa0})),
        .type = i32,
    },
    comptime access_level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x104})),
        .type = i32,
    },
    comptime supergroup: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x158, 0x0 })),
        .type = Supergroup,
        .ptr = true,
    },
    comptime power_info: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xea8, 0x0 })),
        .type = PowerInfo,
        .ptr = true,
    },
    comptime group_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x1b48, 0x0 })),
        .type = []u8,
    },
    comptime sg_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x32f8})),
        .type = []u8,
    },
    comptime sg_icon: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3338})),
        .type = []u8,
    },
    comptime sg_color_primary: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x33b8})),
        .type = u32,
    },
    comptime sg_color_secondary: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x33bc})),
        .type = u32,
    },
    comptime buffs: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x33c0, 0x0 })),
        .type = List(PowerBuff, null, null),
        .ptr = true,
    },
    comptime bitflags: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3468})),
        .type = u32,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getOwner(self: @This()) !u32 {
        return self.reader.readField(self, self.owner);
    }
    pub fn getPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.pos);
    }
    pub fn getMotion(self: @This()) !MotionState {
        return self.reader.readField(self, self.motion);
    }
    pub fn getPl(self: @This()) !EntPlayer {
        return self.reader.readField(self, self.pl);
    }
    pub fn getFork(self: @This()) !Mat4 {
        return self.reader.readField(self, self.fork);
    }
    pub fn getRoomImIn(self: @This()) !DefTracker {
        return self.reader.readField(self, self.room_im_in);
    }
    pub fn getCharacter(self: @This()) !Character {
        return self.reader.readField(self, self.character);
    }
    pub fn getTranslucency(self: @This()) !f32 {
        return self.reader.readField(self, self.translucency);
    }
    pub fn getGlowie(self: @This()) !i32 {
        return self.reader.readField(self, self.glowie);
    }
    pub fn getEntId(self: @This()) !u32 {
        return self.reader.readField(self, self.ent_id);
    }
    pub fn getDbId(self: @This()) !i32 {
        return self.reader.readField(self, self.db_id);
    }
    pub fn getSupergroupId(self: @This()) !i32 {
        return self.reader.readField(self, self.supergroup_id);
    }
    pub fn getAccessLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.access_level);
    }
    pub fn getSupergroup(self: @This()) !Supergroup {
        return self.reader.readField(self, self.supergroup);
    }
    pub fn getPowerInfo(self: @This()) !PowerInfo {
        return self.reader.readField(self, self.power_info);
    }
    pub fn getGroupName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.group_name);
    }
    pub fn getSgName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.sg_name);
    }
    pub fn getSgIcon(self: @This()) ![]u8 {
        return self.reader.readField(self, self.sg_icon);
    }
    pub fn getSgColorPrimary(self: @This()) !u32 {
        return self.reader.readField(self, self.sg_color_primary);
    }
    pub fn getSgColorSecondary(self: @This()) !u32 {
        return self.reader.readField(self, self.sg_color_secondary);
    }
    pub fn getBuffs(self: @This()) !List(PowerBuff, null, null) {
        return self.reader.readField(self, self.buffs);
    }
    pub fn getBitflags(self: @This()) !u32 {
        return self.reader.readField(self, self.bitflags);
    }
    pub fn getRef(self: Entity) !SerializedType(EntityRef) {
        var ref = SerializedType(EntityRef){
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

    pub fn select(self: Entity) !void {
        const game = Game{ .reader = self.reader };
        try self.reader.write(self.reader.modBaseAddr + game.selected.offset[0], &self.baseAddr.?);
    }

    pub fn follow(self: Entity) !void {
        try utils.followRef(self.reader, utils.EntityRefUnion{ .serialized = try self.getRef() });
    }

    pub fn isCritter(self: *Entity, _: *Game) bool {
        const name = self.getName() catch return false;
        defer self.reader.allocator.free(name);
        const character = self.getCharacter() catch return false;
        const origin = character.getOrigin() catch return false;
        defer self.reader.allocator.free(origin);
        return std.mem.eql(u8, origin, "Villain_Origin");
    }

    pub fn isEnemy(self: *Entity, game: *Game) bool {
        const character = self.getCharacter() catch return false;
        const player = game.getPlayer() catch return false;
        return character.isEnemy(player.getCharacter() catch return false) catch return false;
    }

    pub fn isAliveEnemy(self: *Entity, game: *Game) bool {
        const character = self.getCharacter() catch return false;
        const player = game.getPlayer() catch return false;
        const currentHealth = character.getCurrentHealth() catch return false;
        return (character.isEnemy(player.getCharacter() catch return false) catch return false) and currentHealth > 0;
    }

    pub fn isAlly(self: *Entity, game: *Game) bool {
        return !self.isNpc(game) and !self.isEnemy(game);
    }

    pub fn isNpc(self: *Entity, _: *Game) bool {
        const character = self.getCharacter() catch return true;
        return character.baseAddr.? == 0;
    }

    pub fn isInteractable(self: *Entity, _: *Game) bool {
        const glowie = self.getGlowie() catch return false;
        return glowie != 0;
    }
    pub fn getDistance(self: Entity, other: Entity) !f32 {
        const selfPos = self.getPos() catch return std.math.inf(f32);
        return selfPos.getDistance(other.getPos() catch return std.math.inf(f32));
    }
};
pub const EntPlayer = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime tray: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x80, 0x0 })),
        .type = Tray,
        .ptr = true,
    },
    comptime comment: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x92c})),
        .type = []u8,
    },
    comptime last_inviter_dbid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9ac})),
        .type = i32,
    },
    comptime last_invite_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9b0})),
        .type = i32,
    },
    comptime taskforce_mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9d0})),
        .type = i32,
    },
    comptime current_costume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa00})),
        .type = i32,
    },
    comptime current_powerCust: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa04})),
        .type = i32,
    },
    comptime current_supercostume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa08})),
        .type = i32,
    },
    comptime num_costume_slots: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa0c})),
        .type = i32,
    },
    comptime num_costumes_stored: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa10})),
        .type = i32,
    },
    comptime last_costume_change: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa14})),
        .type = i32,
    },
    comptime helper_status: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x5940})),
        .type = i32,
    },
    pub fn getTray(self: @This()) !Tray {
        return self.reader.readField(self, self.tray);
    }
    pub fn getComment(self: @This()) ![]u8 {
        return self.reader.readField(self, self.comment);
    }
    pub fn getLastInviterDbid(self: @This()) !i32 {
        return self.reader.readField(self, self.last_inviter_dbid);
    }
    pub fn getLastInviteTime(self: @This()) !i32 {
        return self.reader.readField(self, self.last_invite_time);
    }
    pub fn getTaskforceMode(self: @This()) !i32 {
        return self.reader.readField(self, self.taskforce_mode);
    }
    pub fn getCurrentCostume(self: @This()) !i32 {
        return self.reader.readField(self, self.current_costume);
    }
    pub fn getCurrentPowerCust(self: @This()) !i32 {
        return self.reader.readField(self, self.current_powerCust);
    }
    pub fn getCurrentSupercostume(self: @This()) !i32 {
        return self.reader.readField(self, self.current_supercostume);
    }
    pub fn getNumCostumeSlots(self: @This()) !i32 {
        return self.reader.readField(self, self.num_costume_slots);
    }
    pub fn getNumCostumesStored(self: @This()) !i32 {
        return self.reader.readField(self, self.num_costumes_stored);
    }
    pub fn getLastCostumeChange(self: @This()) !i32 {
        return self.reader.readField(self, self.last_costume_change);
    }
    pub fn getHelperStatus(self: @This()) !i32 {
        return self.reader.readField(self, self.helper_status);
    }
};
pub const Supergroup = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = []u8,
    },
    comptime msg: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x140})),
        .type = []u8,
    },
    comptime motto: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x240})),
        .type = []u8,
    },
    comptime emblem: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x540})),
        .type = []u8,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getMsg(self: @This()) ![]u8 {
        return self.reader.readField(self, self.msg);
    }
    pub fn getMotto(self: @This()) ![]u8 {
        return self.reader.readField(self, self.motto);
    }
    pub fn getEmblem(self: @This()) ![]u8 {
        return self.reader.readField(self, self.emblem);
    }
};
pub const MotionState = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime vel: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = Vec3,
        .isInline = true,
    },
    comptime last_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = Vec3,
        .isInline = true,
    },
    comptime flying: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe4})),
        .type = u32,
    },
    pub fn getVel(self: @This()) !Vec3 {
        return self.reader.readField(self, self.vel);
    }
    pub fn getLastPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.last_pos);
    }
    pub fn getFlying(self: @This()) !u32 {
        return self.reader.readField(self, self.flying);
    }
};
pub const Vec2 = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    pub fn getX(self: @This()) !f32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !f32 {
        return self.reader.readField(self, self.y);
    }
};
pub const Vec3 = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime z: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime r: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime g: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime b: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    pub fn getX(self: @This()) !f32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !f32 {
        return self.reader.readField(self, self.y);
    }
    pub fn getZ(self: @This()) !f32 {
        return self.reader.readField(self, self.z);
    }
    pub fn getR(self: @This()) !f32 {
        return self.reader.readField(self, self.r);
    }
    pub fn getG(self: @This()) !f32 {
        return self.reader.readField(self, self.g);
    }
    pub fn getB(self: @This()) !f32 {
        return self.reader.readField(self, self.b);
    }
    pub fn serialize(self: Vec3) !SerializedType(Vec3) {
        return .{
            .x = try self.getX(),
            .y = try self.getY(),
            .z = try self.getZ(),
        };
    }

    pub fn getDistance(self: Vec3, other: Vec3) !f32 {
        const selfPos = self.serialize() catch return 0;
        const otherPos = other.serialize() catch return 0;
        // std.debug.print("self addr: {x} inline: {any}\n", .{ self.baseAddr.?, self.isInline });
        // std.debug.print("other addr: {x}\n", .{other.baseAddr.?});
        // std.debug.print("selfPos: {d} {d} {d}\n", .{ selfPos.x, selfPos.y, selfPos.z });
        // std.debug.print("otherPos: {d} {d} {d}\n", .{ otherPos.x, otherPos.y, otherPos.z });
        // std.math.hyp
        return std.math.sqrt(std.math.pow(f32, selfPos.x - otherPos.x, 2) +
            std.math.pow(f32, selfPos.y - otherPos.y, 2) +
            std.math.pow(f32, selfPos.z - otherPos.z, 2));
    }
};
pub const Vec4 = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime w: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime z: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    pub fn getW(self: @This()) !f32 {
        return self.reader.readField(self, self.w);
    }
    pub fn getX(self: @This()) !f32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !f32 {
        return self.reader.readField(self, self.y);
    }
    pub fn getZ(self: @This()) !f32 {
        return self.reader.readField(self, self.z);
    }
};
pub const Mat4 = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime a: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = Vec4,
        .isInline = true,
    },
    comptime b: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = Vec4,
        .isInline = true,
    },
    comptime c: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = Vec4,
        .isInline = true,
    },
    comptime pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = Vec4,
        .isInline = true,
    },
    pub fn getA(self: @This()) !Vec4 {
        return self.reader.readField(self, self.a);
    }
    pub fn getB(self: @This()) !Vec4 {
        return self.reader.readField(self, self.b);
    }
    pub fn getC(self: @This()) !Vec4 {
        return self.reader.readField(self, self.c);
    }
    pub fn getPos(self: @This()) !Vec4 {
        return self.reader.readField(self, self.pos);
    }
};
pub const DefTracker = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = Vec3,
        .isInline = true,
    },
    comptime mid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = Vec3,
        .isInline = true,
    },
    comptime def: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x40, 0x0 })),
        .type = GroupDef,
        .ptr = true,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x50, 0x0 })),
        .type = DefTracker,
        .ptr = true,
    },
    comptime entries: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x58})),
        .type = List(DefTracker, SizeUnion{ .field = .{
            .offset = @ptrCast(@constCast(&[_]i64{8})),
            .type = u64,
        } }, 0xd0),
        .ptr = true,
    },
    comptime count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = i32,
    },
    comptime def_mod_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x64})),
        .type = u32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x68})),
        .type = f32,
    },
    pub fn getPos(self: @This()) !Vec3 {
        return self.reader.readField(self, self.pos);
    }
    pub fn getMid(self: @This()) !Vec3 {
        return self.reader.readField(self, self.mid);
    }
    pub fn getDef(self: @This()) !GroupDef {
        return self.reader.readField(self, self.def);
    }
    pub fn getParent(self: @This()) !DefTracker {
        return self.reader.readField(self, self.parent);
    }
    pub fn getEntries(self: @This()) !List(DefTracker, SizeUnion{ .field = .{
        .offset = @ptrCast(@constCast(&[_]i64{8})),
        .type = u64,
    } }, 0xd0) {
        return self.reader.readField(self, self.entries);
    }
    pub fn getCount(self: @This()) !i32 {
        return self.reader.readField(self, self.count);
    }
    pub fn getDefModTime(self: @This()) !u32 {
        return self.reader.readField(self, self.def_mod_time);
    }
    pub fn getRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.radius);
    }
};
pub const GroupDef = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime members: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = GroupBoundsMembers,
        .isInline = true,
    },
    comptime count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c4})),
        .type = i32,
    },
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x1d0, 0x0 })),
        .type = []u8,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2a8})),
        .type = i32,
    },
    comptime beacon_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x668, 0x0 })),
        .type = []u8,
    },
    pub fn getMembers(self: @This()) !GroupBoundsMembers {
        return self.reader.readField(self, self.members);
    }
    pub fn getCount(self: @This()) !i32 {
        return self.reader.readField(self, self.count);
    }
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getBeaconName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.beacon_name);
    }
};
pub const Model = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime flags: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = u32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i16,
    },
    comptime vert_count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime tri_count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = i32,
    },
    pub fn getFlags(self: @This()) !u32 {
        return self.reader.readField(self, self.flags);
    }
    pub fn getRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.radius);
    }
    pub fn getId(self: @This()) !i16 {
        return self.reader.readField(self, self.id);
    }
    pub fn getVertCount(self: @This()) !i32 {
        return self.reader.readField(self, self.vert_count);
    }
    pub fn getTriCount(self: @This()) !i32 {
        return self.reader.readField(self, self.tri_count);
    }
};
pub const GroupBoundsMembers = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime min: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = Vec3,
        .isInline = true,
    },
    comptime max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = Vec3,
        .isInline = true,
    },
    comptime mid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = Vec3,
        .isInline = true,
    },
    comptime vis_dist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = f32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = f32,
    },
    comptime lod_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = f32,
    },
    comptime shadow_dist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = f32,
    },
    comptime recursive_count: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = i32,
    },
    pub fn getMin(self: @This()) !Vec3 {
        return self.reader.readField(self, self.min);
    }
    pub fn getMax(self: @This()) !Vec3 {
        return self.reader.readField(self, self.max);
    }
    pub fn getMid(self: @This()) !Vec3 {
        return self.reader.readField(self, self.mid);
    }
    pub fn getVisDist(self: @This()) !f32 {
        return self.reader.readField(self, self.vis_dist);
    }
    pub fn getRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.radius);
    }
    pub fn getLodScale(self: @This()) !f32 {
        return self.reader.readField(self, self.lod_scale);
    }
    pub fn getShadowDist(self: @This()) !f32 {
        return self.reader.readField(self, self.shadow_dist);
    }
    pub fn getRecursiveCount(self: @This()) !i32 {
        return self.reader.readField(self, self.recursive_count);
    }
};
pub const Character = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime origin: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x78, 0x0, 0x0 })),
        .type = []u8,
    },
    comptime class: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x80, 0x0, 0x0 })),
        .type = []u8,
    },
    comptime class_data: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x80, 0x0 })),
        .type = CharacterClass,
        .ptr = true,
    },
    comptime last_power: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xc88, 0x0 })),
        .type = Power,
        .ptr = true,
    },
    comptime queued_power: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xcd8, 0x0 })),
        .type = Power,
        .ptr = true,
    },
    comptime queued_target: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xce0})),
        .type = EntityRef,
        .isInline = true,
    },
    comptime default_power: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10d0, 0x0 })),
        .type = Power,
        .ptr = true,
    },
    comptime level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime cur_build: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime combat_level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = i32,
    },
    comptime xp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = i32,
    },
    comptime debt: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = i32,
    },
    comptime patrol_xp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48})),
        .type = i32,
    },
    comptime influence: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x5c})),
        .type = i32,
    },
    comptime other: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x88})),
        .type = i32,
    },
    comptime group: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8c})),
        .type = i32,
    },
    comptime target: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd58})),
        .type = EntityRef,
        .isInline = true,
    },
    comptime current_health: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10c})),
        .type = f32,
    },
    comptime attr_cur: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xbc})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime attr_mod: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x294})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime attr_max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x464})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime attr_str: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x634})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime attr_res: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x804})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime attr_last: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9d4})),
        .type = CharacterAttributes,
        .isInline = true,
    },
    comptime recalc_strengths: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xba8})),
        .type = i32,
    },
    comptime regen_timer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xbac})),
        .type = f32,
    },
    comptime max_health: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4b4})),
        .type = f32,
    },
    comptime absorb: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4b8})),
        .type = f32,
    },
    comptime endurance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x114})),
        .type = f32,
    },
    comptime max_endurance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4bc})),
        .type = f32,
    },
    comptime inherent_meter: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x234})),
        .type = f32,
    },
    comptime power_sets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xc40, 0x0 })),
        .type = List(PowerSet, null, null),
        .ptr = true,
    },
    comptime inspiration_columns: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1104})),
        .type = i32,
    },
    comptime inspiration_rows: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1108})),
        .type = i32,
    },
    comptime inspirations: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1110})),
        .type = List(BasePower, SizeUnion{
            .constant = 20,
        }, null),
        .isInline = true,
    },
    comptime boosts: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x11b8})),
        .type = List(Boost, SizeUnion{
            .constant = 70,
        }, null),
        .isInline = true,
    },
    comptime salvage: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x1418, 0x0 })),
        .type = List(SalvageInventoryItem, null, null),
        .ptr = true,
    },
    pub fn getOrigin(self: @This()) ![]u8 {
        return self.reader.readField(self, self.origin);
    }
    pub fn getClass(self: @This()) ![]u8 {
        return self.reader.readField(self, self.class);
    }
    pub fn getClassData(self: @This()) !CharacterClass {
        return self.reader.readField(self, self.class_data);
    }
    pub fn getLastPower(self: @This()) !Power {
        return self.reader.readField(self, self.last_power);
    }
    pub fn getQueuedPower(self: @This()) !Power {
        return self.reader.readField(self, self.queued_power);
    }
    pub fn getQueuedTarget(self: @This()) !EntityRef {
        return self.reader.readField(self, self.queued_target);
    }
    pub fn getDefaultPower(self: @This()) !Power {
        return self.reader.readField(self, self.default_power);
    }
    pub fn getLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.level);
    }
    pub fn getCurBuild(self: @This()) !i32 {
        return self.reader.readField(self, self.cur_build);
    }
    pub fn getCombatLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.combat_level);
    }
    pub fn getXp(self: @This()) !i32 {
        return self.reader.readField(self, self.xp);
    }
    pub fn getDebt(self: @This()) !i32 {
        return self.reader.readField(self, self.debt);
    }
    pub fn getPatrolXp(self: @This()) !i32 {
        return self.reader.readField(self, self.patrol_xp);
    }
    pub fn getInfluence(self: @This()) !i32 {
        return self.reader.readField(self, self.influence);
    }
    pub fn getOther(self: @This()) !i32 {
        return self.reader.readField(self, self.other);
    }
    pub fn getGroup(self: @This()) !i32 {
        return self.reader.readField(self, self.group);
    }
    pub fn getTarget(self: @This()) !EntityRef {
        return self.reader.readField(self, self.target);
    }
    pub fn getCurrentHealth(self: @This()) !f32 {
        return self.reader.readField(self, self.current_health);
    }
    pub fn getAttrCur(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_cur);
    }
    pub fn getAttrMod(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_mod);
    }
    pub fn getAttrMax(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_max);
    }
    pub fn getAttrStr(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_str);
    }
    pub fn getAttrRes(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_res);
    }
    pub fn getAttrLast(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_last);
    }
    pub fn getRecalcStrengths(self: @This()) !i32 {
        return self.reader.readField(self, self.recalc_strengths);
    }
    pub fn getRegenTimer(self: @This()) !f32 {
        return self.reader.readField(self, self.regen_timer);
    }
    pub fn getMaxHealth(self: @This()) !f32 {
        return self.reader.readField(self, self.max_health);
    }
    pub fn getAbsorb(self: @This()) !f32 {
        return self.reader.readField(self, self.absorb);
    }
    pub fn getEndurance(self: @This()) !f32 {
        return self.reader.readField(self, self.endurance);
    }
    pub fn getMaxEndurance(self: @This()) !f32 {
        return self.reader.readField(self, self.max_endurance);
    }
    pub fn getInherentMeter(self: @This()) !f32 {
        return self.reader.readField(self, self.inherent_meter);
    }
    pub fn getPowerSets(self: @This()) !List(PowerSet, null, null) {
        return self.reader.readField(self, self.power_sets);
    }
    pub fn getInspirationColumns(self: @This()) !i32 {
        return self.reader.readField(self, self.inspiration_columns);
    }
    pub fn getInspirationRows(self: @This()) !i32 {
        return self.reader.readField(self, self.inspiration_rows);
    }
    pub fn getInspirations(self: @This()) !List(BasePower, SizeUnion{
        .constant = 20,
    }, null) {
        return self.reader.readField(self, self.inspirations);
    }
    pub fn getBoosts(self: @This()) !List(Boost, SizeUnion{
        .constant = 70,
    }, null) {
        return self.reader.readField(self, self.boosts);
    }
    pub fn getSalvage(self: @This()) !List(SalvageInventoryItem, null, null) {
        return self.reader.readField(self, self.salvage);
    }
    pub fn isEnemy(self: Character, otherEnt: Character) !bool {
        const selfGroup = self.getGroup() catch return false;
        const otherGroup = otherEnt.getGroup() catch return false;
        const selfOther = self.getOther() catch return false;
        const otherOther = otherEnt.getOther() catch return false;
        if (selfGroup == 0) return selfOther != otherOther;
        return selfGroup != otherGroup;
    }
};
pub const CharacterClass = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime display_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime display_help: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = []u8,
    },
    comptime display_short_help: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = []u8,
    },
    comptime icon_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = []u8,
    },
    comptime icon: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x28, 0x0 })),
        .type = []u8,
    },
    comptime allowed_origin_names: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x30, 0x0 })),
        .type = []u8,
    },
    comptime special_restrictions: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x38, 0x0 })),
        .type = []u8,
    },
    comptime store_restrictions: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x40, 0x0 })),
        .type = []u8,
    },
    comptime locked_tooltip: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x48, 0x0 })),
        .type = []u8,
    },
    comptime product_code: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x50, 0x0 })),
        .type = []u8,
    },
    comptime reduction_class: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x58, 0x0 })),
        .type = []u8,
    },
    comptime reduce_as_av: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = i32,
    },
    comptime level_up_respecs: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x64})),
        .type = List(undefined, null, null),
        .isInline = true,
    },
    comptime connect_hp_and_status: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x70})),
        .type = i32,
    },
    comptime off_defiant_hit_points_attrib: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x78})),
        .type = i32,
    },
    comptime defiant_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x7c})),
        .type = f32,
    },
    comptime power_categories: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x80})),
        .type = List(PowerCategory, SizeUnion{
            .constant = 4,
        }, null),
        .isInline = true,
    },
    comptime attr_base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xa0, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime attr_min: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xa8, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime attr_strength_min: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xb0, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime attr_resistance_min: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xb8, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime num_levels: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc0})),
        .type = i32,
    },
    comptime attr_max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xc8, 0x0 })),
        .type = CharacterAttributes,
        .ptr = true,
    },
    comptime attr_max_max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xd0, 0x0 })),
        .type = CharacterAttributes,
        .ptr = true,
    },
    comptime attr_strength_max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xd8, 0x0 })),
        .type = CharacterAttributes,
        .ptr = true,
    },
    comptime attr_resistance_max: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xe0, 0x0 })),
        .type = CharacterAttributes,
        .ptr = true,
    },
    comptime attr_dimin_str: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xe8, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime attr_dimin_cur: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xf0, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime attr_dimin_res: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0xf8, 0x0 })),
        .type = List(CharacterAttributes, null, null),
        .ptr = true,
    },
    comptime named_tables: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x100, 0x0 })),
        .type = List(NamedTable, null, null),
        .ptr = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getDisplayName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_name);
    }
    pub fn getDisplayHelp(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_help);
    }
    pub fn getDisplayShortHelp(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_short_help);
    }
    pub fn getIconName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.icon_name);
    }
    pub fn getIcon(self: @This()) ![]u8 {
        return self.reader.readField(self, self.icon);
    }
    pub fn getAllowedOriginNames(self: @This()) ![]u8 {
        return self.reader.readField(self, self.allowed_origin_names);
    }
    pub fn getSpecialRestrictions(self: @This()) ![]u8 {
        return self.reader.readField(self, self.special_restrictions);
    }
    pub fn getStoreRestrictions(self: @This()) ![]u8 {
        return self.reader.readField(self, self.store_restrictions);
    }
    pub fn getLockedTooltip(self: @This()) ![]u8 {
        return self.reader.readField(self, self.locked_tooltip);
    }
    pub fn getProductCode(self: @This()) ![]u8 {
        return self.reader.readField(self, self.product_code);
    }
    pub fn getReductionClass(self: @This()) ![]u8 {
        return self.reader.readField(self, self.reduction_class);
    }
    pub fn getReduceAsAv(self: @This()) !i32 {
        return self.reader.readField(self, self.reduce_as_av);
    }
    pub fn getLevelUpRespecs(self: @This()) !List(undefined, null, null) {
        return self.reader.readField(self, self.level_up_respecs);
    }
    pub fn getConnectHpAndStatus(self: @This()) !i32 {
        return self.reader.readField(self, self.connect_hp_and_status);
    }
    pub fn getOffDefiantHitPointsAttrib(self: @This()) !i32 {
        return self.reader.readField(self, self.off_defiant_hit_points_attrib);
    }
    pub fn getDefiantScale(self: @This()) !f32 {
        return self.reader.readField(self, self.defiant_scale);
    }
    pub fn getPowerCategories(self: @This()) !List(PowerCategory, SizeUnion{
        .constant = 4,
    }, null) {
        return self.reader.readField(self, self.power_categories);
    }
    pub fn getAttrBase(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_base);
    }
    pub fn getAttrMin(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_min);
    }
    pub fn getAttrStrengthMin(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_strength_min);
    }
    pub fn getAttrResistanceMin(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_resistance_min);
    }
    pub fn getNumLevels(self: @This()) !i32 {
        return self.reader.readField(self, self.num_levels);
    }
    pub fn getAttrMax(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_max);
    }
    pub fn getAttrMaxMax(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_max_max);
    }
    pub fn getAttrStrengthMax(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_strength_max);
    }
    pub fn getAttrResistanceMax(self: @This()) !CharacterAttributes {
        return self.reader.readField(self, self.attr_resistance_max);
    }
    pub fn getAttrDiminStr(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_dimin_str);
    }
    pub fn getAttrDiminCur(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_dimin_cur);
    }
    pub fn getAttrDiminRes(self: @This()) !List(CharacterAttributes, null, null) {
        return self.reader.readField(self, self.attr_dimin_res);
    }
    pub fn getNamedTables(self: @This()) !List(NamedTable, null, null) {
        return self.reader.readField(self, self.named_tables);
    }
};
pub const NamedTable = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime values: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = List(undefined, null, null),
        .isInline = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getValues(self: @This()) !List(undefined, null, null) {
        return self.reader.readField(self, self.values);
    }
};
pub const MessageStore = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime locale_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    pub fn getLocaleId(self: @This()) !i32 {
        return self.reader.readField(self, self.locale_id);
    }
};
pub const SalvageInventoryItem = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime salvage: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = SalvageItem,
        .ptr = true,
    },
    comptime amount: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = u32,
    },
    pub fn getSalvage(self: @This()) !SalvageItem {
        return self.reader.readField(self, self.salvage);
    }
    pub fn getAmount(self: @This()) !u32 {
        return self.reader.readField(self, self.amount);
    }
};
pub const SalvageItem = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime sal_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = u32,
    },
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime name_full: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime icon: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x28, 0x0 })),
        .type = []u8,
    },
    comptime type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = i32,
    },
    comptime rarity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = i32,
    },
    comptime max_amount: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48})),
        .type = u32,
    },
    comptime sell_amount: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c})),
        .type = u32,
    },
    comptime flags: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x80})),
        .type = i32,
    },
    pub fn getSalId(self: @This()) !u32 {
        return self.reader.readField(self, self.sal_id);
    }
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getNameFull(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name_full);
    }
    pub fn getIcon(self: @This()) ![]u8 {
        return self.reader.readField(self, self.icon);
    }
    pub fn getType(self: @This()) !i32 {
        return self.reader.readField(self, self.type);
    }
    pub fn getRarity(self: @This()) !i32 {
        return self.reader.readField(self, self.rarity);
    }
    pub fn getMaxAmount(self: @This()) !u32 {
        return self.reader.readField(self, self.max_amount);
    }
    pub fn getSellAmount(self: @This()) !u32 {
        return self.reader.readField(self, self.sell_amount);
    }
    pub fn getFlags(self: @This()) !i32 {
        return self.reader.readField(self, self.flags);
    }
};
pub const CharacterAttributes = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime damageType1: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime damageType2: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime damageType3: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime damageType4: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    comptime damageType5: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = f32,
    },
    comptime damageType6: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = f32,
    },
    comptime damageType7: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = f32,
    },
    comptime damageType8: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = f32,
    },
    comptime damageType9: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = f32,
    },
    comptime damageType10: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = f32,
    },
    comptime damageType11: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = f32,
    },
    comptime damageType12: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = f32,
    },
    comptime damageType13: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = f32,
    },
    comptime damageType14: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x34})),
        .type = f32,
    },
    comptime damageType15: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = f32,
    },
    comptime damageType16: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = f32,
    },
    comptime damageType17: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = f32,
    },
    comptime damageType18: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = f32,
    },
    comptime damageType19: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48})),
        .type = f32,
    },
    comptime damageType20: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c})),
        .type = f32,
    },
    comptime health: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x50})),
        .type = f32,
    },
    comptime absorb: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x54})),
        .type = f32,
    },
    comptime endurance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x58})),
        .type = f32,
    },
    comptime insight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x5c})),
        .type = f32,
    },
    comptime rage: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = f32,
    },
    comptime toHit: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x64})),
        .type = f32,
    },
    comptime defenseType1: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x68})),
        .type = f32,
    },
    comptime defenseType2: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6c})),
        .type = f32,
    },
    comptime defenseType3: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x70})),
        .type = f32,
    },
    comptime defenseType4: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x74})),
        .type = f32,
    },
    comptime defenseType5: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x78})),
        .type = f32,
    },
    comptime defenseType6: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x7c})),
        .type = f32,
    },
    comptime defenseType7: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x80})),
        .type = f32,
    },
    comptime defenseType8: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x84})),
        .type = f32,
    },
    comptime defenseType9: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x88})),
        .type = f32,
    },
    comptime defenseType10: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8c})),
        .type = f32,
    },
    comptime defenseType11: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x90})),
        .type = f32,
    },
    comptime defenseType12: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x94})),
        .type = f32,
    },
    comptime defenseType13: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x98})),
        .type = f32,
    },
    comptime defenseType14: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9c})),
        .type = f32,
    },
    comptime defenseType15: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa0})),
        .type = f32,
    },
    comptime defenseType16: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa4})),
        .type = f32,
    },
    comptime defenseType17: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa8})),
        .type = f32,
    },
    comptime defenseType18: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xac})),
        .type = f32,
    },
    comptime defenseType19: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xb0})),
        .type = f32,
    },
    comptime defenseType20: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xb4})),
        .type = f32,
    },
    comptime defense: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xb8})),
        .type = f32,
    },
    comptime speedRunning: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xbc})),
        .type = f32,
    },
    comptime speedFlying: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc0})),
        .type = f32,
    },
    comptime speedSwimming: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc4})),
        .type = f32,
    },
    comptime speedJumping: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc8})),
        .type = f32,
    },
    comptime jumpHeight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xcc})),
        .type = f32,
    },
    comptime movementControl: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd0})),
        .type = f32,
    },
    comptime movementFriction: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd4})),
        .type = f32,
    },
    comptime stealth: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xd8})),
        .type = f32,
    },
    comptime stealthRadius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xdc})),
        .type = f32,
    },
    comptime stealthRadiusPlayer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe0})),
        .type = f32,
    },
    comptime perceptionRadius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe4})),
        .type = f32,
    },
    comptime regeneration: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xe8})),
        .type = f32,
    },
    comptime recovery: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xec})),
        .type = f32,
    },
    comptime insightRecovery: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf0})),
        .type = f32,
    },
    comptime threatLevel: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf4})),
        .type = f32,
    },
    comptime taunt: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xf8})),
        .type = f32,
    },
    comptime placate: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xfc})),
        .type = f32,
    },
    comptime confused: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x100})),
        .type = f32,
    },
    comptime afraid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x104})),
        .type = f32,
    },
    comptime terrorized: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x108})),
        .type = f32,
    },
    comptime held: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10c})),
        .type = f32,
    },
    comptime immobilized: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x110})),
        .type = f32,
    },
    comptime stunned: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x114})),
        .type = f32,
    },
    comptime sleep: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x118})),
        .type = f32,
    },
    comptime fly: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x11c})),
        .type = f32,
    },
    comptime jumppack: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x120})),
        .type = f32,
    },
    comptime teleport: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x124})),
        .type = f32,
    },
    comptime untouchable: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x128})),
        .type = f32,
    },
    comptime intangible: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x12c})),
        .type = f32,
    },
    comptime onlyAffectsSelf: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x130})),
        .type = f32,
    },
    comptime experienceGain: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x134})),
        .type = f32,
    },
    comptime influenceGain: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x138})),
        .type = f32,
    },
    comptime prestigeGain: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x13c})),
        .type = f32,
    },
    comptime nullBool: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x140})),
        .type = f32,
    },
    comptime knockup: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x144})),
        .type = f32,
    },
    comptime knockback: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x148})),
        .type = f32,
    },
    comptime repel: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14c})),
        .type = f32,
    },
    comptime accuracy: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x150})),
        .type = f32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x154})),
        .type = f32,
    },
    comptime arc: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x158})),
        .type = f32,
    },
    comptime range: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15c})),
        .type = f32,
    },
    comptime timeToActivate: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x160})),
        .type = f32,
    },
    comptime rechargeTime: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x164})),
        .type = f32,
    },
    comptime interruptTime: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x168})),
        .type = f32,
    },
    comptime enduranceDiscount: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x16c})),
        .type = f32,
    },
    comptime insightDiscount: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x170})),
        .type = f32,
    },
    comptime _something: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x174})),
        .type = f32,
    },
    comptime meter: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x178})),
        .type = f32,
    },
    comptime elusivity1: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x17c})),
        .type = f32,
    },
    comptime elusivity2: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x180})),
        .type = f32,
    },
    comptime elusivity3: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x184})),
        .type = f32,
    },
    comptime elusivity4: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x188})),
        .type = f32,
    },
    comptime elusivity5: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18c})),
        .type = f32,
    },
    comptime elusivity6: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x190})),
        .type = f32,
    },
    comptime elusivity7: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x194})),
        .type = f32,
    },
    comptime elusivity8: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x198})),
        .type = f32,
    },
    comptime elusivity9: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x19c})),
        .type = f32,
    },
    comptime elusivity10: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1a0})),
        .type = f32,
    },
    comptime elusivity11: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1a4})),
        .type = f32,
    },
    comptime elusivity12: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1a8})),
        .type = f32,
    },
    comptime elusivity13: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1ac})),
        .type = f32,
    },
    comptime elusivity14: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1b0})),
        .type = f32,
    },
    comptime elusivity15: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1b4})),
        .type = f32,
    },
    comptime elusivity16: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1b8})),
        .type = f32,
    },
    comptime elusivity17: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1bc})),
        .type = f32,
    },
    comptime elusivity18: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c0})),
        .type = f32,
    },
    comptime elusivity19: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c4})),
        .type = f32,
    },
    comptime elusivity20: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c8})),
        .type = f32,
    },
    comptime elusivityBase: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc})),
        .type = f32,
    },
    pub fn getDamageType1(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType1);
    }
    pub fn getDamageType2(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType2);
    }
    pub fn getDamageType3(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType3);
    }
    pub fn getDamageType4(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType4);
    }
    pub fn getDamageType5(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType5);
    }
    pub fn getDamageType6(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType6);
    }
    pub fn getDamageType7(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType7);
    }
    pub fn getDamageType8(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType8);
    }
    pub fn getDamageType9(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType9);
    }
    pub fn getDamageType10(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType10);
    }
    pub fn getDamageType11(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType11);
    }
    pub fn getDamageType12(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType12);
    }
    pub fn getDamageType13(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType13);
    }
    pub fn getDamageType14(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType14);
    }
    pub fn getDamageType15(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType15);
    }
    pub fn getDamageType16(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType16);
    }
    pub fn getDamageType17(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType17);
    }
    pub fn getDamageType18(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType18);
    }
    pub fn getDamageType19(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType19);
    }
    pub fn getDamageType20(self: @This()) !f32 {
        return self.reader.readField(self, self.damageType20);
    }
    pub fn getHealth(self: @This()) !f32 {
        return self.reader.readField(self, self.health);
    }
    pub fn getAbsorb(self: @This()) !f32 {
        return self.reader.readField(self, self.absorb);
    }
    pub fn getEndurance(self: @This()) !f32 {
        return self.reader.readField(self, self.endurance);
    }
    pub fn getInsight(self: @This()) !f32 {
        return self.reader.readField(self, self.insight);
    }
    pub fn getRage(self: @This()) !f32 {
        return self.reader.readField(self, self.rage);
    }
    pub fn getToHit(self: @This()) !f32 {
        return self.reader.readField(self, self.toHit);
    }
    pub fn getDefenseType1(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType1);
    }
    pub fn getDefenseType2(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType2);
    }
    pub fn getDefenseType3(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType3);
    }
    pub fn getDefenseType4(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType4);
    }
    pub fn getDefenseType5(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType5);
    }
    pub fn getDefenseType6(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType6);
    }
    pub fn getDefenseType7(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType7);
    }
    pub fn getDefenseType8(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType8);
    }
    pub fn getDefenseType9(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType9);
    }
    pub fn getDefenseType10(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType10);
    }
    pub fn getDefenseType11(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType11);
    }
    pub fn getDefenseType12(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType12);
    }
    pub fn getDefenseType13(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType13);
    }
    pub fn getDefenseType14(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType14);
    }
    pub fn getDefenseType15(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType15);
    }
    pub fn getDefenseType16(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType16);
    }
    pub fn getDefenseType17(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType17);
    }
    pub fn getDefenseType18(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType18);
    }
    pub fn getDefenseType19(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType19);
    }
    pub fn getDefenseType20(self: @This()) !f32 {
        return self.reader.readField(self, self.defenseType20);
    }
    pub fn getDefense(self: @This()) !f32 {
        return self.reader.readField(self, self.defense);
    }
    pub fn getSpeedRunning(self: @This()) !f32 {
        return self.reader.readField(self, self.speedRunning);
    }
    pub fn getSpeedFlying(self: @This()) !f32 {
        return self.reader.readField(self, self.speedFlying);
    }
    pub fn getSpeedSwimming(self: @This()) !f32 {
        return self.reader.readField(self, self.speedSwimming);
    }
    pub fn getSpeedJumping(self: @This()) !f32 {
        return self.reader.readField(self, self.speedJumping);
    }
    pub fn getJumpHeight(self: @This()) !f32 {
        return self.reader.readField(self, self.jumpHeight);
    }
    pub fn getMovementControl(self: @This()) !f32 {
        return self.reader.readField(self, self.movementControl);
    }
    pub fn getMovementFriction(self: @This()) !f32 {
        return self.reader.readField(self, self.movementFriction);
    }
    pub fn getStealth(self: @This()) !f32 {
        return self.reader.readField(self, self.stealth);
    }
    pub fn getStealthRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.stealthRadius);
    }
    pub fn getStealthRadiusPlayer(self: @This()) !f32 {
        return self.reader.readField(self, self.stealthRadiusPlayer);
    }
    pub fn getPerceptionRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.perceptionRadius);
    }
    pub fn getRegeneration(self: @This()) !f32 {
        return self.reader.readField(self, self.regeneration);
    }
    pub fn getRecovery(self: @This()) !f32 {
        return self.reader.readField(self, self.recovery);
    }
    pub fn getInsightRecovery(self: @This()) !f32 {
        return self.reader.readField(self, self.insightRecovery);
    }
    pub fn getThreatLevel(self: @This()) !f32 {
        return self.reader.readField(self, self.threatLevel);
    }
    pub fn getTaunt(self: @This()) !f32 {
        return self.reader.readField(self, self.taunt);
    }
    pub fn getPlacate(self: @This()) !f32 {
        return self.reader.readField(self, self.placate);
    }
    pub fn getConfused(self: @This()) !f32 {
        return self.reader.readField(self, self.confused);
    }
    pub fn getAfraid(self: @This()) !f32 {
        return self.reader.readField(self, self.afraid);
    }
    pub fn getTerrorized(self: @This()) !f32 {
        return self.reader.readField(self, self.terrorized);
    }
    pub fn getHeld(self: @This()) !f32 {
        return self.reader.readField(self, self.held);
    }
    pub fn getImmobilized(self: @This()) !f32 {
        return self.reader.readField(self, self.immobilized);
    }
    pub fn getStunned(self: @This()) !f32 {
        return self.reader.readField(self, self.stunned);
    }
    pub fn getSleep(self: @This()) !f32 {
        return self.reader.readField(self, self.sleep);
    }
    pub fn getFly(self: @This()) !f32 {
        return self.reader.readField(self, self.fly);
    }
    pub fn getJumppack(self: @This()) !f32 {
        return self.reader.readField(self, self.jumppack);
    }
    pub fn getTeleport(self: @This()) !f32 {
        return self.reader.readField(self, self.teleport);
    }
    pub fn getUntouchable(self: @This()) !f32 {
        return self.reader.readField(self, self.untouchable);
    }
    pub fn getIntangible(self: @This()) !f32 {
        return self.reader.readField(self, self.intangible);
    }
    pub fn getOnlyAffectsSelf(self: @This()) !f32 {
        return self.reader.readField(self, self.onlyAffectsSelf);
    }
    pub fn getExperienceGain(self: @This()) !f32 {
        return self.reader.readField(self, self.experienceGain);
    }
    pub fn getInfluenceGain(self: @This()) !f32 {
        return self.reader.readField(self, self.influenceGain);
    }
    pub fn getPrestigeGain(self: @This()) !f32 {
        return self.reader.readField(self, self.prestigeGain);
    }
    pub fn getNullBool(self: @This()) !f32 {
        return self.reader.readField(self, self.nullBool);
    }
    pub fn getKnockup(self: @This()) !f32 {
        return self.reader.readField(self, self.knockup);
    }
    pub fn getKnockback(self: @This()) !f32 {
        return self.reader.readField(self, self.knockback);
    }
    pub fn getRepel(self: @This()) !f32 {
        return self.reader.readField(self, self.repel);
    }
    pub fn getAccuracy(self: @This()) !f32 {
        return self.reader.readField(self, self.accuracy);
    }
    pub fn getRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.radius);
    }
    pub fn getArc(self: @This()) !f32 {
        return self.reader.readField(self, self.arc);
    }
    pub fn getRange(self: @This()) !f32 {
        return self.reader.readField(self, self.range);
    }
    pub fn getTimeToActivate(self: @This()) !f32 {
        return self.reader.readField(self, self.timeToActivate);
    }
    pub fn getRechargeTime(self: @This()) !f32 {
        return self.reader.readField(self, self.rechargeTime);
    }
    pub fn getInterruptTime(self: @This()) !f32 {
        return self.reader.readField(self, self.interruptTime);
    }
    pub fn getEnduranceDiscount(self: @This()) !f32 {
        return self.reader.readField(self, self.enduranceDiscount);
    }
    pub fn getInsightDiscount(self: @This()) !f32 {
        return self.reader.readField(self, self.insightDiscount);
    }
    pub fn getundefinedSomething(self: @This()) !f32 {
        return self.reader.readField(self, self._something);
    }
    pub fn getMeter(self: @This()) !f32 {
        return self.reader.readField(self, self.meter);
    }
    pub fn getElusivity1(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity1);
    }
    pub fn getElusivity2(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity2);
    }
    pub fn getElusivity3(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity3);
    }
    pub fn getElusivity4(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity4);
    }
    pub fn getElusivity5(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity5);
    }
    pub fn getElusivity6(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity6);
    }
    pub fn getElusivity7(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity7);
    }
    pub fn getElusivity8(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity8);
    }
    pub fn getElusivity9(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity9);
    }
    pub fn getElusivity10(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity10);
    }
    pub fn getElusivity11(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity11);
    }
    pub fn getElusivity12(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity12);
    }
    pub fn getElusivity13(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity13);
    }
    pub fn getElusivity14(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity14);
    }
    pub fn getElusivity15(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity15);
    }
    pub fn getElusivity16(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity16);
    }
    pub fn getElusivity17(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity17);
    }
    pub fn getElusivity18(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity18);
    }
    pub fn getElusivity19(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity19);
    }
    pub fn getElusivity20(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivity20);
    }
    pub fn getElusivityBase(self: @This()) !f32 {
        return self.reader.readField(self, self.elusivityBase);
    }
};
pub const EntityRef = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime index: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = u32,
    },
    comptime uid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = u32,
    },
    pub fn getIndex(self: @This()) !u32 {
        return self.reader.readField(self, self.index);
    }
    pub fn getUid(self: @This()) !u32 {
        return self.reader.readField(self, self.uid);
    }
    pub fn follow(self: EntityRef) !void {
        try utils.followRef(self.reader, utils.EntityRefUnion{ .ptr = self });
    }

    pub fn getEnt(self: EntityRef) !Entity {
        return utils.getEntFromRef(self.reader, utils.EntityRefUnion{ .ptr = self });
    }
};
pub const PowerRef = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime build: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime set: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime power: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    pub fn getBuild(self: @This()) !i32 {
        return self.reader.readField(self, self.build);
    }
    pub fn getSet(self: @This()) !i32 {
        return self.reader.readField(self, self.set);
    }
    pub fn getPower(self: @This()) !i32 {
        return self.reader.readField(self, self.power);
    }
};
pub const PowerBuff = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = BasePower,
        .ptr = true,
    },
    comptime desc: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = List(AttribDescription, null, null),
        .ptr = true,
    },
    comptime mag: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = f32,
    },
    comptime tooltip: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = ToolTip,
        .isInline = true,
    },
    comptime blink: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x90})),
        .type = i32,
    },
    comptime timer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x94})),
        .type = f32,
    },
    comptime uid: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x98})),
        .type = i32,
    },
    comptime delete_mark: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9c})),
        .type = i32,
    },
    comptime window: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xa0})),
        .type = i32,
    },
    pub fn getBase(self: @This()) !BasePower {
        return self.reader.readField(self, self.base);
    }
    pub fn getDesc(self: @This()) !List(AttribDescription, null, null) {
        return self.reader.readField(self, self.desc);
    }
    pub fn getMag(self: @This()) !f32 {
        return self.reader.readField(self, self.mag);
    }
    pub fn getTooltip(self: @This()) !ToolTip {
        return self.reader.readField(self, self.tooltip);
    }
    pub fn getBlink(self: @This()) !i32 {
        return self.reader.readField(self, self.blink);
    }
    pub fn getTimer(self: @This()) !f32 {
        return self.reader.readField(self, self.timer);
    }
    pub fn getUid(self: @This()) !i32 {
        return self.reader.readField(self, self.uid);
    }
    pub fn getDeleteMark(self: @This()) !i32 {
        return self.reader.readField(self, self.delete_mark);
    }
    pub fn getWindow(self: @This()) !i32 {
        return self.reader.readField(self, self.window);
    }
};
pub const ToolTip = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime window: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime menu: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime timer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime constant: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime reparse: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime updated: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = i32,
    },
    comptime flags: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime bounds: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = CBox,
        .isInline = true,
    },
    comptime rel_bounds: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = CBox,
        .isInline = true,
    },
    comptime txt: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x40, 0x0 })),
        .type = []u8,
    },
    comptime source_txt: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x48, 0x0 })),
        .type = []u8,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x50, 0x0 })),
        .type = ToolTipParent,
        .ptr = true,
    },
    comptime smf: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x58, 0x0 })),
        .type = SMFBlock,
        .ptr = true,
    },
    comptime allocated_self: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = i32,
    },
    comptime constant_wd: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x64})),
        .type = i32,
    },
    comptime back_color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x68})),
        .type = i32,
    },
    comptime x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6c})),
        .type = f32,
    },
    comptime y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x70})),
        .type = f32,
    },
    comptime disable_screen_scaling: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x74})),
        .type = i32,
    },
    pub fn getWindow(self: @This()) !i32 {
        return self.reader.readField(self, self.window);
    }
    pub fn getMenu(self: @This()) !i32 {
        return self.reader.readField(self, self.menu);
    }
    pub fn getTimer(self: @This()) !i32 {
        return self.reader.readField(self, self.timer);
    }
    pub fn getConstant(self: @This()) !i32 {
        return self.reader.readField(self, self.constant);
    }
    pub fn getReparse(self: @This()) !i32 {
        return self.reader.readField(self, self.reparse);
    }
    pub fn getUpdated(self: @This()) !i32 {
        return self.reader.readField(self, self.updated);
    }
    pub fn getFlags(self: @This()) !i32 {
        return self.reader.readField(self, self.flags);
    }
    pub fn getBounds(self: @This()) !CBox {
        return self.reader.readField(self, self.bounds);
    }
    pub fn getRelBounds(self: @This()) !CBox {
        return self.reader.readField(self, self.rel_bounds);
    }
    pub fn getTxt(self: @This()) ![]u8 {
        return self.reader.readField(self, self.txt);
    }
    pub fn getSourceTxt(self: @This()) ![]u8 {
        return self.reader.readField(self, self.source_txt);
    }
    pub fn getParent(self: @This()) !ToolTipParent {
        return self.reader.readField(self, self.parent);
    }
    pub fn getSmf(self: @This()) !SMFBlock {
        return self.reader.readField(self, self.smf);
    }
    pub fn getAllocatedSelf(self: @This()) !i32 {
        return self.reader.readField(self, self.allocated_self);
    }
    pub fn getConstantWd(self: @This()) !i32 {
        return self.reader.readField(self, self.constant_wd);
    }
    pub fn getBackColor(self: @This()) !i32 {
        return self.reader.readField(self, self.back_color);
    }
    pub fn getX(self: @This()) !f32 {
        return self.reader.readField(self, self.x);
    }
    pub fn getY(self: @This()) !f32 {
        return self.reader.readField(self, self.y);
    }
    pub fn getDisableScreenScaling(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_screen_scaling);
    }
};
pub const SMFBlock = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
};
pub const ToolTipParent = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime box: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = CBox,
        .isInline = true,
    },
    pub fn getBox(self: @This()) !CBox {
        return self.reader.readField(self, self.box);
    }
};
pub const CBox = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime lx: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime left: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime ly: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime top: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime hx: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime right: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime hy: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    comptime bottom: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    pub fn getLx(self: @This()) !f32 {
        return self.reader.readField(self, self.lx);
    }
    pub fn getLeft(self: @This()) !f32 {
        return self.reader.readField(self, self.left);
    }
    pub fn getLy(self: @This()) !f32 {
        return self.reader.readField(self, self.ly);
    }
    pub fn getTop(self: @This()) !f32 {
        return self.reader.readField(self, self.top);
    }
    pub fn getHx(self: @This()) !f32 {
        return self.reader.readField(self, self.hx);
    }
    pub fn getRight(self: @This()) !f32 {
        return self.reader.readField(self, self.right);
    }
    pub fn getHy(self: @This()) !f32 {
        return self.reader.readField(self, self.hy);
    }
    pub fn getBottom(self: @This()) !f32 {
        return self.reader.readField(self, self.bottom);
    }
};
pub const AttribDescription = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime display_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime tooltip: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = []u8,
    },
    comptime type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime style: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = i32,
    },
    comptime i_key: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = i32,
    },
    comptime off_attrib: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = i32,
    },
    comptime val: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = f32,
    },
    comptime buff_or_debuff: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = i32,
    },
    comptime contributers: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x30, 0x0 })),
        .type = List(AttribContributer, null, null),
        .ptr = true,
    },
    comptime hide: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = i32,
    },
    comptime show_base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = i32,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getDisplayName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_name);
    }
    pub fn getTooltip(self: @This()) ![]u8 {
        return self.reader.readField(self, self.tooltip);
    }
    pub fn getType(self: @This()) !i32 {
        return self.reader.readField(self, self.type);
    }
    pub fn getStyle(self: @This()) !i32 {
        return self.reader.readField(self, self.style);
    }
    pub fn getIKey(self: @This()) !i32 {
        return self.reader.readField(self, self.i_key);
    }
    pub fn getOffAttrib(self: @This()) !i32 {
        return self.reader.readField(self, self.off_attrib);
    }
    pub fn getVal(self: @This()) !f32 {
        return self.reader.readField(self, self.val);
    }
    pub fn getBuffOrDebuff(self: @This()) !i32 {
        return self.reader.readField(self, self.buff_or_debuff);
    }
    pub fn getContributers(self: @This()) !List(AttribContributer, null, null) {
        return self.reader.readField(self, self.contributers);
    }
    pub fn getHide(self: @This()) !i32 {
        return self.reader.readField(self, self.hide);
    }
    pub fn getShowBase(self: @This()) !i32 {
        return self.reader.readField(self, self.show_base);
    }
};
pub const AttribContributer = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = BasePower,
        .ptr = true,
    },
    comptime src_display_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime mag: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = f32,
    },
    comptime chance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = f32,
    },
    comptime svr_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime source: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = i32,
    },
    pub fn getBase(self: @This()) !BasePower {
        return self.reader.readField(self, self.base);
    }
    pub fn getSrcDisplayName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.src_display_name);
    }
    pub fn getMag(self: @This()) !f32 {
        return self.reader.readField(self, self.mag);
    }
    pub fn getChance(self: @This()) !f32 {
        return self.reader.readField(self, self.chance);
    }
    pub fn getSvrId(self: @This()) !i32 {
        return self.reader.readField(self, self.svr_id);
    }
    pub fn getSource(self: @This()) !i32 {
        return self.reader.readField(self, self.source);
    }
};
pub const AttribCategoryList = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime categories: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(AttribCategory, null, null),
        .ptr = true,
    },
    pub fn getCategories(self: @This()) !List(AttribCategory, null, null) {
        return self.reader.readField(self, self.categories);
    }
};
pub const AttribCategory = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime display_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime attribs: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = List(AttribDescription, null, null),
        .ptr = true,
    },
    pub fn getDisplayName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_name);
    }
    pub fn getAttribs(self: @This()) !List(AttribDescription, null, null) {
        return self.reader.readField(self, self.attribs);
    }
};
pub const PowerRechargeTimer = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime ref: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = PowerRef,
        .isInline = true,
    },
    comptime cooldown: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    pub fn getRef(self: @This()) !PowerRef {
        return self.reader.readField(self, self.ref);
    }
    pub fn getCooldown(self: @This()) !f32 {
        return self.reader.readField(self, self.cooldown);
    }
};
pub const Power = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = BasePower,
        .ptr = true,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = PowerSet,
        .ptr = true,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = i32,
    },
    comptime level_bought: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime available_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = f32,
    },
    comptime boosts: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x50, 0x0 })),
        .type = List(Boost, null, null),
        .ptr = true,
    },
    pub fn getBase(self: @This()) !BasePower {
        return self.reader.readField(self, self.base);
    }
    pub fn getParent(self: @This()) !PowerSet {
        return self.reader.readField(self, self.parent);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getLevelBought(self: @This()) !i32 {
        return self.reader.readField(self, self.level_bought);
    }
    pub fn getAvailableTime(self: @This()) !f32 {
        return self.reader.readField(self, self.available_time);
    }
    pub fn getBoosts(self: @This()) !List(Boost, null, null) {
        return self.reader.readField(self, self.boosts);
    }
};
pub const BasePower = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime name_full: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = []u8,
    },
    comptime name_pstring: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = []u8,
    },
    comptime icon_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x80, 0x0 })),
        .type = []u8,
    },
    comptime power_type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1d0})),
        .type = i32,
    },
    comptime accuracy: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x218})),
        .type = f32,
    },
    comptime max_targets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x238})),
        .type = i32,
    },
    comptime radius: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x254})),
        .type = f32,
    },
    comptime range: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x290})),
        .type = f32,
    },
    comptime activation_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x298})),
        .type = f32,
    },
    comptime recharge_time: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2a0})),
        .type = f32,
    },
    comptime endurance_cost: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2ac})),
        .type = f32,
    },
    comptime show_in_inventory: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2d0})),
        .type = i32,
    },
    comptime target_type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x33c})),
        .type = i32,
    },
    comptime boost_sets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x3a0, 0x0 })),
        .type = List(BoostSet, null, null),
        .ptr = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getNameFull(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name_full);
    }
    pub fn getNamePstring(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name_pstring);
    }
    pub fn getIconName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.icon_name);
    }
    pub fn getPowerType(self: @This()) !i32 {
        return self.reader.readField(self, self.power_type);
    }
    pub fn getAccuracy(self: @This()) !f32 {
        return self.reader.readField(self, self.accuracy);
    }
    pub fn getMaxTargets(self: @This()) !i32 {
        return self.reader.readField(self, self.max_targets);
    }
    pub fn getRadius(self: @This()) !f32 {
        return self.reader.readField(self, self.radius);
    }
    pub fn getRange(self: @This()) !f32 {
        return self.reader.readField(self, self.range);
    }
    pub fn getActivationTime(self: @This()) !f32 {
        return self.reader.readField(self, self.activation_time);
    }
    pub fn getRechargeTime(self: @This()) !f32 {
        return self.reader.readField(self, self.recharge_time);
    }
    pub fn getEnduranceCost(self: @This()) !f32 {
        return self.reader.readField(self, self.endurance_cost);
    }
    pub fn getShowInInventory(self: @This()) !i32 {
        return self.reader.readField(self, self.show_in_inventory);
    }
    pub fn getTargetType(self: @This()) !i32 {
        return self.reader.readField(self, self.target_type);
    }
    pub fn getBoostSets(self: @This()) !List(BoostSet, null, null) {
        return self.reader.readField(self, self.boost_sets);
    }
};
pub const AttribModTemplate = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime idx: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime display_attacker_hit: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x1c, 0x0 })),
        .type = []u8,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getIdx(self: @This()) !i32 {
        return self.reader.readField(self, self.idx);
    }
    pub fn getDisplayAttackerHit(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_attacker_hit);
    }
};
pub const PowerSet = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = BasePowerSet,
        .ptr = true,
    },
    comptime id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime powers: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = List(Power, null, null),
        .ptr = true,
    },
    pub fn getBase(self: @This()) !BasePowerSet {
        return self.reader.readField(self, self.base);
    }
    pub fn getId(self: @This()) !i32 {
        return self.reader.readField(self, self.id);
    }
    pub fn getPowers(self: @This()) !List(Power, null, null) {
        return self.reader.readField(self, self.powers);
    }
};
pub const BasePowerSet = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime name_full: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = PowerCategory,
        .ptr = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getNameFull(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name_full);
    }
    pub fn getParent(self: @This()) !PowerCategory {
        return self.reader.readField(self, self.parent);
    }
};
pub const PowerCategory = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    comptime display_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = []u8,
    },
    comptime display_help: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = []u8,
    },
    comptime display_short_help: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = []u8,
    },
    comptime source_file: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = []u8,
    },
    comptime power_sets: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x28, 0x0, 0x0 })),
        .type = List(BasePowerSet, null, null),
        .isInline = true,
    },
    comptime power_set_names: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x30, 0x0, 0x0 })),
        .type = List(undefined, null, null),
        .isInline = true,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
    pub fn getDisplayName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_name);
    }
    pub fn getDisplayHelp(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_help);
    }
    pub fn getDisplayShortHelp(self: @This()) ![]u8 {
        return self.reader.readField(self, self.display_short_help);
    }
    pub fn getSourceFile(self: @This()) ![]u8 {
        return self.reader.readField(self, self.source_file);
    }
    pub fn getPowerSets(self: @This()) !List(BasePowerSet, null, null) {
        return self.reader.readField(self, self.power_sets);
    }
    pub fn getPowerSetNames(self: @This()) !List(undefined, null, null) {
        return self.reader.readField(self, self.power_set_names);
    }
};
pub const PowerInfo = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime active: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(PowerRef, null, null),
        .ptr = true,
    },
    comptime recharging: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = List(PowerRechargeTimer, null, null),
        .ptr = true,
    },
    pub fn getActive(self: @This()) !List(PowerRef, null, null) {
        return self.reader.readField(self, self.active);
    }
    pub fn getRecharging(self: @This()) !List(PowerRechargeTimer, null, null) {
        return self.reader.readField(self, self.recharging);
    }
};
pub const Tray = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime current_trays: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime mode_alt2: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = i32,
    },
    comptime indexes: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime internals: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x20, 0x0 })),
        .type = TrayInternals,
        .ptr = true,
    },
    pub fn getCurrentTrays(self: @This()) !i32 {
        return self.reader.readField(self, self.current_trays);
    }
    pub fn getMode(self: @This()) !i32 {
        return self.reader.readField(self, self.mode);
    }
    pub fn getModeAlt2(self: @This()) !i32 {
        return self.reader.readField(self, self.mode_alt2);
    }
    pub fn getIndexes(self: @This()) !i32 {
        return self.reader.readField(self, self.indexes);
    }
    pub fn getInternals(self: @This()) !TrayInternals {
        return self.reader.readField(self, self.internals);
    }
};
pub const TrayInternals = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime slots: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = List(TrayObj, SizeUnion{
            .constant = 180,
        }, null),
        .ptr = true,
    },
    comptime server_slots: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x8, 0x0 })),
        .type = List(TrayObj, SizeUnion{
            .constant = 10,
        }, null),
        .ptr = true,
    },
    pub fn getSlots(self: @This()) !List(TrayObj, SizeUnion{
        .constant = 180,
    }, null) {
        return self.reader.readField(self, self.slots);
    }
    pub fn getServerSlots(self: @This()) !List(TrayObj, SizeUnion{
        .constant = 10,
    }, null) {
        return self.reader.readField(self, self.server_slots);
    }
};
pub const TrayObj = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime type: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime state: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = i32,
    },
    comptime scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = f32,
    },
    comptime show_recharge_indicator: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime tray: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x34})),
        .type = i32,
    },
    comptime slot: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = i32,
    },
    comptime power: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = i32,
    },
    comptime set: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = i32,
    },
    comptime auto: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = i32,
    },
    comptime macro_cmd: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60})),
        .type = []u8,
        .isInline = true,
    },
    comptime macro_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x160})),
        .type = []u8,
        .isInline = true,
    },
    comptime macro_image: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x180})),
        .type = []u8,
        .isInline = true,
    },
    pub fn getType(self: @This()) !i32 {
        return self.reader.readField(self, self.type);
    }
    pub fn getState(self: @This()) !i32 {
        return self.reader.readField(self, self.state);
    }
    pub fn getScale(self: @This()) !f32 {
        return self.reader.readField(self, self.scale);
    }
    pub fn getShowRechargeIndicator(self: @This()) !i32 {
        return self.reader.readField(self, self.show_recharge_indicator);
    }
    pub fn getTray(self: @This()) !i32 {
        return self.reader.readField(self, self.tray);
    }
    pub fn getSlot(self: @This()) !i32 {
        return self.reader.readField(self, self.slot);
    }
    pub fn getPower(self: @This()) !i32 {
        return self.reader.readField(self, self.power);
    }
    pub fn getSet(self: @This()) !i32 {
        return self.reader.readField(self, self.set);
    }
    pub fn getAuto(self: @This()) !i32 {
        return self.reader.readField(self, self.auto);
    }
    pub fn getMacroCmd(self: @This()) ![]u8 {
        return self.reader.readField(self, self.macro_cmd);
    }
    pub fn getMacroName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.macro_name);
    }
    pub fn getMacroImage(self: @This()) ![]u8 {
        return self.reader.readField(self, self.macro_image);
    }
};
pub const Boost = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime base: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = BasePower,
        .ptr = true,
    },
    comptime level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = i32,
    },
    comptime num_combines: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = i32,
    },
    comptime parent: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x10, 0x0 })),
        .type = Power,
        .ptr = true,
    },
    comptime parent_respec: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x18, 0x0 })),
        .type = Power,
        .ptr = true,
    },
    comptime index: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = i32,
    },
    comptime timer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = f32,
    },
    pub fn getBase(self: @This()) !BasePower {
        return self.reader.readField(self, self.base);
    }
    pub fn getLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.level);
    }
    pub fn getNumCombines(self: @This()) !i32 {
        return self.reader.readField(self, self.num_combines);
    }
    pub fn getParent(self: @This()) !Power {
        return self.reader.readField(self, self.parent);
    }
    pub fn getParentRespec(self: @This()) !Power {
        return self.reader.readField(self, self.parent_respec);
    }
    pub fn getIndex(self: @This()) !i32 {
        return self.reader.readField(self, self.index);
    }
    pub fn getTimer(self: @This()) !f32 {
        return self.reader.readField(self, self.timer);
    }
};
pub const BoostSet = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{ 0x0, 0x0 })),
        .type = []u8,
    },
    pub fn getName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.name);
    }
};
pub const GameState = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime fullscreen: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = i32,
    },
    comptime fullscreen_toggle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = i32,
    },
    comptime stop_inactive_display: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x18})),
        .type = i32,
    },
    comptime inactive_display: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c})),
        .type = i32,
    },
    comptime allow_frames_buffered: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20})),
        .type = i32,
    },
    comptime screen_x: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x24})),
        .type = i32,
    },
    comptime screen_y: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x28})),
        .type = i32,
    },
    comptime refresh_rate: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x2c})),
        .type = i32,
    },
    comptime screen_x_restored: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x30})),
        .type = i32,
    },
    comptime screen_y_restored: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x34})),
        .type = i32,
    },
    comptime screen_x_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38})),
        .type = i32,
    },
    comptime screen_y_pos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3c})),
        .type = i32,
    },
    comptime fov: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x40})),
        .type = f32,
    },
    comptime fov_1st: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x44})),
        .type = f32,
    },
    comptime fov_3rd: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48})),
        .type = f32,
    },
    comptime fov_custom: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c})),
        .type = f32,
    },
    comptime fov_thisframe: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x50})),
        .type = f32,
    },
    comptime ortho: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x54})),
        .type = i32,
    },
    comptime ortho_zoom: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x58})),
        .type = i32,
    },
    comptime safemode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x5c})),
        .type = i32,
    },
    comptime camera_shake: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x88})),
        .type = f32,
    },
    comptime camera_shake_falloff: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8c})),
        .type = f32,
    },
    comptime camera_blur: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x90})),
        .type = f32,
    },
    comptime camera_blur_falloff: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x94})),
        .type = f32,
    },
    comptime floor_info: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x98})),
        .type = i32,
    },
    comptime wireframe: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x9c})),
        .type = i32,
    },
    comptime showhelp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x120})),
        .type = i32,
    },
    comptime freemouse: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x124})),
        .type = i32,
    },
    comptime netgraph: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x128})),
        .type = i32,
    },
    comptime bitgraph: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x12c})),
        .type = i32,
    },
    comptime net_floaters: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x130})),
        .type = i32,
    },
    comptime fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x134})),
        .type = f32,
    },
    comptime max_fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x138})),
        .type = i32,
    },
    comptime max_inactive_fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x13c})),
        .type = i32,
    },
    comptime max_menu_fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x140})),
        .type = i32,
    },
    comptime show_fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x144})),
        .type = f32,
    },
    comptime show_active_volume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x148})),
        .type = i32,
    },
    comptime graph_fps: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14c})),
        .type = i32,
    },
    comptime sli_clear: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x150})),
        .type = i32,
    },
    comptime sli_fbos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x154})),
        .type = u32,
    },
    comptime sli_limit: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x158})),
        .type = u32,
    },
    comptime use_nv_fence: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x15c})),
        .type = i32,
    },
    comptime gpu_markers: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x160})),
        .type = i32,
    },
    comptime frame_delay: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x164})),
        .type = i32,
    },
    comptime verbose: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x168})),
        .type = i32,
    },
    comptime tcp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x16c})),
        .type = i32,
    },
    comptime port: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x170})),
        .type = i32,
    },
    comptime address: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x174})),
        .type = []u8,
    },
    comptime edit: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x274})),
        .type = i32,
    },
    comptime cs_address: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x278})),
        .type = []u8,
    },
    comptime auth_address: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x378})),
        .type = []u8,
    },
    comptime max_color_tracker_verts: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x478})),
        .type = i32,
    },
    comptime full_relight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x47c})),
        .type = i32,
    },
    comptime use_new_color_picker: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x480})),
        .type = i32,
    },
    comptime game_mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x484})),
        .type = i32,
    },
    comptime group_def_version: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x488})),
        .type = i32,
    },
    comptime power_looping_sounds_go_forever: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x48c})),
        .type = i32,
    },
    comptime part_vis_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x490})),
        .type = f32,
    },
    comptime max_particles: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x494})),
        .type = i32,
    },
    comptime max_particles_fill: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x498})),
        .type = i32,
    },
    comptime splat_shadow_bias: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x49c})),
        .type = f32,
    },
    comptime disable_simple_shadows: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4a0})),
        .type = i32,
    },
    comptime lod_bias: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4a4})),
        .type = f32,
    },
    comptime disable_sky: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4a8})),
        .type = i32,
    },
    comptime fx_sound_volume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4ac})),
        .type = f32,
    },
    comptime music_sound_volume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4b0})),
        .type = f32,
    },
    comptime vo_sound_volume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4b4})),
        .type = f32,
    },
    comptime sound_mute_flags: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4b8})),
        .type = i32,
    },
    comptime max_sound_channels: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4bc})),
        .type = i32,
    },
    comptime max_sound_spheres: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c0})),
        .type = i32,
    },
    comptime max_pcm_cache_mb: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c4})),
        .type = f32,
    },
    comptime max_sound_cache_mb: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4c8})),
        .type = f32,
    },
    comptime max_ogg_to_pcm: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4cc})),
        .type = i32,
    },
    comptime ignore_sound_ramp: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4d0})),
        .type = i32,
    },
    comptime sound_debug_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4d4})),
        .type = []u8,
    },
    comptime mip_level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x514})),
        .type = i32,
    },
    comptime actual_mip_level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x518})),
        .type = i32,
    },
    comptime entity_mip_level: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x51c})),
        .type = i32,
    },
    comptime reduce_min: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x520})),
        .type = i32,
    },
    comptime tex_anisotropic: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x52c})),
        .type = i32,
    },
    comptime antialiasing: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x530})),
        .type = i32,
    },
    comptime vis_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x540})),
        .type = f32,
    },
    comptime lod_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x544})),
        .type = f32,
    },
    comptime lod_fade_range: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x548})),
        .type = f32,
    },
    comptime draw_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x54c})),
        .type = f32,
    },
    comptime gamma: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x550})),
        .type = f32,
    },
    comptime shadow_vol: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x554})),
        .type = i32,
    },
    comptime no_stencil_shadows: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x558})),
        .type = i32,
    },
    comptime fancy_trees: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x55c})),
        .type = i32,
    },
    comptime no_fancy_water: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x560})),
        .type = i32,
    },
    comptime bloom_weight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x608})),
        .type = f32,
    },
    comptime bloom_scale: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x60c})),
        .type = i32,
    },
    comptime dof_weight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x610})),
        .type = f32,
    },
    comptime water_mode: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x650})),
        .type = i32,
    },
    comptime use_view_cache: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x654})),
        .type = i32,
    },
    comptime enable_vbos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x658})),
        .type = i32,
    },
    comptime enable_vbos_for_particles: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x65c})),
        .type = i32,
    },
    comptime disable_vbos: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x660})),
        .type = i32,
    },
    comptime disable_vbos_for_particles: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x664})),
        .type = i32,
    },
    comptime fog_color: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x668})),
        .type = Vec3,
        .ptr = true,
    },
    comptime fog_dist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x674})),
        .type = Vec2,
        .ptr = true,
    },
    comptime dof_values: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x67c})),
        .type = DOFValues,
        .ptr = true,
    },
    comptime sky_fade1: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x694})),
        .type = i32,
    },
    comptime sky_fade2: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x698})),
        .type = i32,
    },
    comptime sky_fade_weight: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x69c})),
        .type = f32,
    },
    comptime showtime: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6a0})),
        .type = i32,
    },
    comptime nearz: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6a4})),
        .type = f32,
    },
    comptime farz: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6a8})),
        .type = f32,
    },
    comptime flip_y_projection: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6ac})),
        .type = i32,
    },
    comptime fog_deferring: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6b0})),
        .type = i32,
    },
    comptime no_fog: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x6b4})),
        .type = i32,
    },
    comptime cam_dist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1c90})),
        .type = f32,
    },
    comptime edit_npc: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc0})),
        .type = i32,
    },
    comptime map_test: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc4})),
        .type = i32,
    },
    comptime cryptic: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cc8})),
        .type = i32,
    },
    comptime base_map_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1ccc})),
        .type = i32,
    },
    comptime intro_zone: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cd0})),
        .type = i32,
    },
    comptime team_area: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x1cd4})),
        .type = i32,
    },
    comptime see_everything: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20c0})),
        .type = i32,
    },
    comptime has_ent_debug_info: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20c4})),
        .type = i32,
    },
    comptime ent_debug_client: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20c8})),
        .type = i32,
    },
    comptime debug_collision: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20cc})),
        .type = i32,
    },
    comptime script_debug_client: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20d0})),
        .type = i32,
    },
    comptime quick_login: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20d4})),
        .type = i32,
    },
    comptime ask_quick_login: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20d8})),
        .type = i32,
    },
    comptime disable_2d_graphics: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20dc})),
        .type = i32,
    },
    comptime disable_game_ui: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20e0})),
        .type = i32,
    },
    comptime viewing_cutscene: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x20e4})),
        .type = i32,
    },
    comptime pending_ts_map_xfer: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21a0})),
        .type = i32,
    },
    comptime place_entity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21a4})),
        .type = i32,
    },
    comptime super_vis: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21a8})),
        .type = i32,
    },
    comptime select_any_entity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21ac})),
        .type = i32,
    },
    comptime camera_follow_entity: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21b0})),
        .type = EntityRef,
        .ptr = true,
    },
    comptime camera_shared_slave: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21b8})),
        .type = i32,
    },
    comptime camera_shared_master: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21bc})),
        .type = i32,
    },
    comptime can_set_cursor: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21c0})),
        .type = i32,
    },
    comptime reload_costume: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21c4})),
        .type = i32,
    },
    comptime show_mouse_coords: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21c8})),
        .type = i32,
    },
    comptime tt_debug: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21cc})),
        .type = i32,
    },
    comptime show_players: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21d0})),
        .type = i32,
    },
    comptime show_pointers: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21d4})),
        .type = i32,
    },
    comptime tutorial: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21d8})),
        .type = i32,
    },
    comptime always_mission: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21dc})),
        .type = i32,
    },
    comptime no_map_fog: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21e0})),
        .type = i32,
    },
    comptime screenshot_ui: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21e4})),
        .type = i32,
    },
    comptime world_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x21e8})),
        .type = []u8,
    },
    comptime mission_map: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x23f0})),
        .type = i32,
    },
    comptime map_instance_id: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x23f4})),
        .type = i32,
    },
    comptime shard_name: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x23fc})),
        .type = []u8,
    },
    comptime chat_handle: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x38a0})),
        .type = []u8,
    },
    comptime chat_shard: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3920})),
        .type = []u8,
    },
    comptime g_friend_hide: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x39a0})),
        .type = i32,
    },
    comptime g_tell_hide: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x39a4})),
        .type = i32,
    },
    comptime cursor_cache: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3dd4})),
        .type = i32,
    },
    comptime conor_hack: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3e28})),
        .type = i32,
    },
    comptime auto_perf: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3e48})),
        .type = i32,
    },
    comptime use_vsync: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3e7c})),
        .type = i32,
    },
    comptime enable: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3f78})),
        .type = i32,
    },
    comptime outlines: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3f88})),
        .type = i32,
    },
    comptime lighting: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3f8c})),
        .type = i32,
    },
    comptime suppress_filters: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x3f90})),
        .type = i32,
    },
    pub fn getFullscreen(self: @This()) !i32 {
        return self.reader.readField(self, self.fullscreen);
    }
    pub fn getFullscreenToggle(self: @This()) !i32 {
        return self.reader.readField(self, self.fullscreen_toggle);
    }
    pub fn getStopInactiveDisplay(self: @This()) !i32 {
        return self.reader.readField(self, self.stop_inactive_display);
    }
    pub fn getInactiveDisplay(self: @This()) !i32 {
        return self.reader.readField(self, self.inactive_display);
    }
    pub fn getAllowFramesBuffered(self: @This()) !i32 {
        return self.reader.readField(self, self.allow_frames_buffered);
    }
    pub fn getScreenX(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_x);
    }
    pub fn getScreenY(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_y);
    }
    pub fn getRefreshRate(self: @This()) !i32 {
        return self.reader.readField(self, self.refresh_rate);
    }
    pub fn getScreenXRestored(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_x_restored);
    }
    pub fn getScreenYRestored(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_y_restored);
    }
    pub fn getScreenXPos(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_x_pos);
    }
    pub fn getScreenYPos(self: @This()) !i32 {
        return self.reader.readField(self, self.screen_y_pos);
    }
    pub fn getFov(self: @This()) !f32 {
        return self.reader.readField(self, self.fov);
    }
    pub fn getFov1st(self: @This()) !f32 {
        return self.reader.readField(self, self.fov_1st);
    }
    pub fn getFov3rd(self: @This()) !f32 {
        return self.reader.readField(self, self.fov_3rd);
    }
    pub fn getFovCustom(self: @This()) !f32 {
        return self.reader.readField(self, self.fov_custom);
    }
    pub fn getFovThisframe(self: @This()) !f32 {
        return self.reader.readField(self, self.fov_thisframe);
    }
    pub fn getOrtho(self: @This()) !i32 {
        return self.reader.readField(self, self.ortho);
    }
    pub fn getOrthoZoom(self: @This()) !i32 {
        return self.reader.readField(self, self.ortho_zoom);
    }
    pub fn getSafemode(self: @This()) !i32 {
        return self.reader.readField(self, self.safemode);
    }
    pub fn getCameraShake(self: @This()) !f32 {
        return self.reader.readField(self, self.camera_shake);
    }
    pub fn getCameraShakeFalloff(self: @This()) !f32 {
        return self.reader.readField(self, self.camera_shake_falloff);
    }
    pub fn getCameraBlur(self: @This()) !f32 {
        return self.reader.readField(self, self.camera_blur);
    }
    pub fn getCameraBlurFalloff(self: @This()) !f32 {
        return self.reader.readField(self, self.camera_blur_falloff);
    }
    pub fn getFloorInfo(self: @This()) !i32 {
        return self.reader.readField(self, self.floor_info);
    }
    pub fn getWireframe(self: @This()) !i32 {
        return self.reader.readField(self, self.wireframe);
    }
    pub fn getShowhelp(self: @This()) !i32 {
        return self.reader.readField(self, self.showhelp);
    }
    pub fn getFreemouse(self: @This()) !i32 {
        return self.reader.readField(self, self.freemouse);
    }
    pub fn getNetgraph(self: @This()) !i32 {
        return self.reader.readField(self, self.netgraph);
    }
    pub fn getBitgraph(self: @This()) !i32 {
        return self.reader.readField(self, self.bitgraph);
    }
    pub fn getNetFloaters(self: @This()) !i32 {
        return self.reader.readField(self, self.net_floaters);
    }
    pub fn getFps(self: @This()) !f32 {
        return self.reader.readField(self, self.fps);
    }
    pub fn getMaxFps(self: @This()) !i32 {
        return self.reader.readField(self, self.max_fps);
    }
    pub fn getMaxInactiveFps(self: @This()) !i32 {
        return self.reader.readField(self, self.max_inactive_fps);
    }
    pub fn getMaxMenuFps(self: @This()) !i32 {
        return self.reader.readField(self, self.max_menu_fps);
    }
    pub fn getShowFps(self: @This()) !f32 {
        return self.reader.readField(self, self.show_fps);
    }
    pub fn getShowActiveVolume(self: @This()) !i32 {
        return self.reader.readField(self, self.show_active_volume);
    }
    pub fn getGraphFps(self: @This()) !i32 {
        return self.reader.readField(self, self.graph_fps);
    }
    pub fn getSliClear(self: @This()) !i32 {
        return self.reader.readField(self, self.sli_clear);
    }
    pub fn getSliFbos(self: @This()) !u32 {
        return self.reader.readField(self, self.sli_fbos);
    }
    pub fn getSliLimit(self: @This()) !u32 {
        return self.reader.readField(self, self.sli_limit);
    }
    pub fn getUseNvFence(self: @This()) !i32 {
        return self.reader.readField(self, self.use_nv_fence);
    }
    pub fn getGpuMarkers(self: @This()) !i32 {
        return self.reader.readField(self, self.gpu_markers);
    }
    pub fn getFrameDelay(self: @This()) !i32 {
        return self.reader.readField(self, self.frame_delay);
    }
    pub fn getVerbose(self: @This()) !i32 {
        return self.reader.readField(self, self.verbose);
    }
    pub fn getTcp(self: @This()) !i32 {
        return self.reader.readField(self, self.tcp);
    }
    pub fn getPort(self: @This()) !i32 {
        return self.reader.readField(self, self.port);
    }
    pub fn getAddress(self: @This()) ![]u8 {
        return self.reader.readField(self, self.address);
    }
    pub fn getEdit(self: @This()) !i32 {
        return self.reader.readField(self, self.edit);
    }
    pub fn getCsAddress(self: @This()) ![]u8 {
        return self.reader.readField(self, self.cs_address);
    }
    pub fn getAuthAddress(self: @This()) ![]u8 {
        return self.reader.readField(self, self.auth_address);
    }
    pub fn getMaxColorTrackerVerts(self: @This()) !i32 {
        return self.reader.readField(self, self.max_color_tracker_verts);
    }
    pub fn getFullRelight(self: @This()) !i32 {
        return self.reader.readField(self, self.full_relight);
    }
    pub fn getUseNewColorPicker(self: @This()) !i32 {
        return self.reader.readField(self, self.use_new_color_picker);
    }
    pub fn getGameMode(self: @This()) !i32 {
        return self.reader.readField(self, self.game_mode);
    }
    pub fn getGroupDefVersion(self: @This()) !i32 {
        return self.reader.readField(self, self.group_def_version);
    }
    pub fn getPowerLoopingSoundsGoForever(self: @This()) !i32 {
        return self.reader.readField(self, self.power_looping_sounds_go_forever);
    }
    pub fn getPartVisScale(self: @This()) !f32 {
        return self.reader.readField(self, self.part_vis_scale);
    }
    pub fn getMaxParticles(self: @This()) !i32 {
        return self.reader.readField(self, self.max_particles);
    }
    pub fn getMaxParticlesFill(self: @This()) !i32 {
        return self.reader.readField(self, self.max_particles_fill);
    }
    pub fn getSplatShadowBias(self: @This()) !f32 {
        return self.reader.readField(self, self.splat_shadow_bias);
    }
    pub fn getDisableSimpleShadows(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_simple_shadows);
    }
    pub fn getLodBias(self: @This()) !f32 {
        return self.reader.readField(self, self.lod_bias);
    }
    pub fn getDisableSky(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_sky);
    }
    pub fn getFxSoundVolume(self: @This()) !f32 {
        return self.reader.readField(self, self.fx_sound_volume);
    }
    pub fn getMusicSoundVolume(self: @This()) !f32 {
        return self.reader.readField(self, self.music_sound_volume);
    }
    pub fn getVoSoundVolume(self: @This()) !f32 {
        return self.reader.readField(self, self.vo_sound_volume);
    }
    pub fn getSoundMuteFlags(self: @This()) !i32 {
        return self.reader.readField(self, self.sound_mute_flags);
    }
    pub fn getMaxSoundChannels(self: @This()) !i32 {
        return self.reader.readField(self, self.max_sound_channels);
    }
    pub fn getMaxSoundSpheres(self: @This()) !i32 {
        return self.reader.readField(self, self.max_sound_spheres);
    }
    pub fn getMaxPcmCacheMb(self: @This()) !f32 {
        return self.reader.readField(self, self.max_pcm_cache_mb);
    }
    pub fn getMaxSoundCacheMb(self: @This()) !f32 {
        return self.reader.readField(self, self.max_sound_cache_mb);
    }
    pub fn getMaxOggToPcm(self: @This()) !i32 {
        return self.reader.readField(self, self.max_ogg_to_pcm);
    }
    pub fn getIgnoreSoundRamp(self: @This()) !i32 {
        return self.reader.readField(self, self.ignore_sound_ramp);
    }
    pub fn getSoundDebugName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.sound_debug_name);
    }
    pub fn getMipLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.mip_level);
    }
    pub fn getActualMipLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.actual_mip_level);
    }
    pub fn getEntityMipLevel(self: @This()) !i32 {
        return self.reader.readField(self, self.entity_mip_level);
    }
    pub fn getReduceMin(self: @This()) !i32 {
        return self.reader.readField(self, self.reduce_min);
    }
    pub fn getTexAnisotropic(self: @This()) !i32 {
        return self.reader.readField(self, self.tex_anisotropic);
    }
    pub fn getAntialiasing(self: @This()) !i32 {
        return self.reader.readField(self, self.antialiasing);
    }
    pub fn getVisScale(self: @This()) !f32 {
        return self.reader.readField(self, self.vis_scale);
    }
    pub fn getLodScale(self: @This()) !f32 {
        return self.reader.readField(self, self.lod_scale);
    }
    pub fn getLodFadeRange(self: @This()) !f32 {
        return self.reader.readField(self, self.lod_fade_range);
    }
    pub fn getDrawScale(self: @This()) !f32 {
        return self.reader.readField(self, self.draw_scale);
    }
    pub fn getGamma(self: @This()) !f32 {
        return self.reader.readField(self, self.gamma);
    }
    pub fn getShadowVol(self: @This()) !i32 {
        return self.reader.readField(self, self.shadow_vol);
    }
    pub fn getNoStencilShadows(self: @This()) !i32 {
        return self.reader.readField(self, self.no_stencil_shadows);
    }
    pub fn getFancyTrees(self: @This()) !i32 {
        return self.reader.readField(self, self.fancy_trees);
    }
    pub fn getNoFancyWater(self: @This()) !i32 {
        return self.reader.readField(self, self.no_fancy_water);
    }
    pub fn getBloomWeight(self: @This()) !f32 {
        return self.reader.readField(self, self.bloom_weight);
    }
    pub fn getBloomScale(self: @This()) !i32 {
        return self.reader.readField(self, self.bloom_scale);
    }
    pub fn getDofWeight(self: @This()) !f32 {
        return self.reader.readField(self, self.dof_weight);
    }
    pub fn getWaterMode(self: @This()) !i32 {
        return self.reader.readField(self, self.water_mode);
    }
    pub fn getUseViewCache(self: @This()) !i32 {
        return self.reader.readField(self, self.use_view_cache);
    }
    pub fn getEnableVbos(self: @This()) !i32 {
        return self.reader.readField(self, self.enable_vbos);
    }
    pub fn getEnableVbosForParticles(self: @This()) !i32 {
        return self.reader.readField(self, self.enable_vbos_for_particles);
    }
    pub fn getDisableVbos(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_vbos);
    }
    pub fn getDisableVbosForParticles(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_vbos_for_particles);
    }
    pub fn getFogColor(self: @This()) !Vec3 {
        return self.reader.readField(self, self.fog_color);
    }
    pub fn getFogDist(self: @This()) !Vec2 {
        return self.reader.readField(self, self.fog_dist);
    }
    pub fn getDofValues(self: @This()) !DOFValues {
        return self.reader.readField(self, self.dof_values);
    }
    pub fn getSkyFade1(self: @This()) !i32 {
        return self.reader.readField(self, self.sky_fade1);
    }
    pub fn getSkyFade2(self: @This()) !i32 {
        return self.reader.readField(self, self.sky_fade2);
    }
    pub fn getSkyFadeWeight(self: @This()) !f32 {
        return self.reader.readField(self, self.sky_fade_weight);
    }
    pub fn getShowtime(self: @This()) !i32 {
        return self.reader.readField(self, self.showtime);
    }
    pub fn getNearz(self: @This()) !f32 {
        return self.reader.readField(self, self.nearz);
    }
    pub fn getFarz(self: @This()) !f32 {
        return self.reader.readField(self, self.farz);
    }
    pub fn getFlipYProjection(self: @This()) !i32 {
        return self.reader.readField(self, self.flip_y_projection);
    }
    pub fn getFogDeferring(self: @This()) !i32 {
        return self.reader.readField(self, self.fog_deferring);
    }
    pub fn getNoFog(self: @This()) !i32 {
        return self.reader.readField(self, self.no_fog);
    }
    pub fn getCamDist(self: @This()) !f32 {
        return self.reader.readField(self, self.cam_dist);
    }
    pub fn getEditNpc(self: @This()) !i32 {
        return self.reader.readField(self, self.edit_npc);
    }
    pub fn getMapTest(self: @This()) !i32 {
        return self.reader.readField(self, self.map_test);
    }
    pub fn getCryptic(self: @This()) !i32 {
        return self.reader.readField(self, self.cryptic);
    }
    pub fn getBaseMapId(self: @This()) !i32 {
        return self.reader.readField(self, self.base_map_id);
    }
    pub fn getIntroZone(self: @This()) !i32 {
        return self.reader.readField(self, self.intro_zone);
    }
    pub fn getTeamArea(self: @This()) !i32 {
        return self.reader.readField(self, self.team_area);
    }
    pub fn getSeeEverything(self: @This()) !i32 {
        return self.reader.readField(self, self.see_everything);
    }
    pub fn getHasEntDebugInfo(self: @This()) !i32 {
        return self.reader.readField(self, self.has_ent_debug_info);
    }
    pub fn getEntDebugClient(self: @This()) !i32 {
        return self.reader.readField(self, self.ent_debug_client);
    }
    pub fn getDebugCollision(self: @This()) !i32 {
        return self.reader.readField(self, self.debug_collision);
    }
    pub fn getScriptDebugClient(self: @This()) !i32 {
        return self.reader.readField(self, self.script_debug_client);
    }
    pub fn getQuickLogin(self: @This()) !i32 {
        return self.reader.readField(self, self.quick_login);
    }
    pub fn getAskQuickLogin(self: @This()) !i32 {
        return self.reader.readField(self, self.ask_quick_login);
    }
    pub fn getDisable2dGraphics(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_2d_graphics);
    }
    pub fn getDisableGameUi(self: @This()) !i32 {
        return self.reader.readField(self, self.disable_game_ui);
    }
    pub fn getViewingCutscene(self: @This()) !i32 {
        return self.reader.readField(self, self.viewing_cutscene);
    }
    pub fn getPendingTsMapXfer(self: @This()) !i32 {
        return self.reader.readField(self, self.pending_ts_map_xfer);
    }
    pub fn getPlaceEntity(self: @This()) !i32 {
        return self.reader.readField(self, self.place_entity);
    }
    pub fn getSuperVis(self: @This()) !i32 {
        return self.reader.readField(self, self.super_vis);
    }
    pub fn getSelectAnyEntity(self: @This()) !i32 {
        return self.reader.readField(self, self.select_any_entity);
    }
    pub fn getCameraFollowEntity(self: @This()) !EntityRef {
        return self.reader.readField(self, self.camera_follow_entity);
    }
    pub fn getCameraSharedSlave(self: @This()) !i32 {
        return self.reader.readField(self, self.camera_shared_slave);
    }
    pub fn getCameraSharedMaster(self: @This()) !i32 {
        return self.reader.readField(self, self.camera_shared_master);
    }
    pub fn getCanSetCursor(self: @This()) !i32 {
        return self.reader.readField(self, self.can_set_cursor);
    }
    pub fn getReloadCostume(self: @This()) !i32 {
        return self.reader.readField(self, self.reload_costume);
    }
    pub fn getShowMouseCoords(self: @This()) !i32 {
        return self.reader.readField(self, self.show_mouse_coords);
    }
    pub fn getTtDebug(self: @This()) !i32 {
        return self.reader.readField(self, self.tt_debug);
    }
    pub fn getShowPlayers(self: @This()) !i32 {
        return self.reader.readField(self, self.show_players);
    }
    pub fn getShowPointers(self: @This()) !i32 {
        return self.reader.readField(self, self.show_pointers);
    }
    pub fn getTutorial(self: @This()) !i32 {
        return self.reader.readField(self, self.tutorial);
    }
    pub fn getAlwaysMission(self: @This()) !i32 {
        return self.reader.readField(self, self.always_mission);
    }
    pub fn getNoMapFog(self: @This()) !i32 {
        return self.reader.readField(self, self.no_map_fog);
    }
    pub fn getScreenshotUi(self: @This()) !i32 {
        return self.reader.readField(self, self.screenshot_ui);
    }
    pub fn getWorldName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.world_name);
    }
    pub fn getMissionMap(self: @This()) !i32 {
        return self.reader.readField(self, self.mission_map);
    }
    pub fn getMapInstanceId(self: @This()) !i32 {
        return self.reader.readField(self, self.map_instance_id);
    }
    pub fn getShardName(self: @This()) ![]u8 {
        return self.reader.readField(self, self.shard_name);
    }
    pub fn getChatHandle(self: @This()) ![]u8 {
        return self.reader.readField(self, self.chat_handle);
    }
    pub fn getChatShard(self: @This()) ![]u8 {
        return self.reader.readField(self, self.chat_shard);
    }
    pub fn getGFriendHide(self: @This()) !i32 {
        return self.reader.readField(self, self.g_friend_hide);
    }
    pub fn getGTellHide(self: @This()) !i32 {
        return self.reader.readField(self, self.g_tell_hide);
    }
    pub fn getCursorCache(self: @This()) !i32 {
        return self.reader.readField(self, self.cursor_cache);
    }
    pub fn getConorHack(self: @This()) !i32 {
        return self.reader.readField(self, self.conor_hack);
    }
    pub fn getAutoPerf(self: @This()) !i32 {
        return self.reader.readField(self, self.auto_perf);
    }
    pub fn getUseVsync(self: @This()) !i32 {
        return self.reader.readField(self, self.use_vsync);
    }
    pub fn getEnable(self: @This()) !i32 {
        return self.reader.readField(self, self.enable);
    }
    pub fn getOutlines(self: @This()) !i32 {
        return self.reader.readField(self, self.outlines);
    }
    pub fn getLighting(self: @This()) !i32 {
        return self.reader.readField(self, self.lighting);
    }
    pub fn getSuppressFilters(self: @This()) !i32 {
        return self.reader.readField(self, self.suppress_filters);
    }
};
pub const DOFValues = struct {
    baseAddr: ?u64 = null,
    isInline: bool = false,
    reader: mem.MemoryReader,
    comptime focusDistance: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x0})),
        .type = f32,
    },
    comptime focusValue: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x4})),
        .type = f32,
    },
    comptime nearValue: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x8})),
        .type = f32,
    },
    comptime nearDist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0xc})),
        .type = f32,
    },
    comptime farValue: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x10})),
        .type = f32,
    },
    comptime farDist: FieldDefinition = .{
        .offset = @ptrCast(@constCast(&[_]i64{0x14})),
        .type = f32,
    },
    pub fn getFocusDistance(self: @This()) !f32 {
        return self.reader.readField(self, self.focusDistance);
    }
    pub fn getFocusValue(self: @This()) !f32 {
        return self.reader.readField(self, self.focusValue);
    }
    pub fn getNearValue(self: @This()) !f32 {
        return self.reader.readField(self, self.nearValue);
    }
    pub fn getNearDist(self: @This()) !f32 {
        return self.reader.readField(self, self.nearDist);
    }
    pub fn getFarValue(self: @This()) !f32 {
        return self.reader.readField(self, self.farValue);
    }
    pub fn getFarDist(self: @This()) !f32 {
        return self.reader.readField(self, self.farDist);
    }
};
