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
