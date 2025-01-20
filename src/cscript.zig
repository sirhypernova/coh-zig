const std = @import("std");
const win32 = @import("zigwin32").everything;
const zigwin32 = @import("zigwin32");
const mem = @import("memory.zig");
const mappings = @import("mappings.zig");
const constants = @import("constants.zig");
const utils = @import("utils.zig");
const Keybinds = @import("keybinds.zig");

var reader: mem.MemoryReader = undefined;
var overlayInt: usize = undefined;
var initialized: bool = false;

var gameWindow: win32.HWND = undefined;
var monitor: win32.HMONITOR = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// begin snake stuff
const SnakeDot = struct {
    active: bool = false,
    framesLeft: u8 = 0,
    addedThisFrame: bool = false,
};
var snakeGame = struct {
    x: i32 = 0,
    y: i32 = 0,
    foodX: i32 = 0,
    foodY: i32 = 0,
    dir: u2 = 0,
    next_dir: u2 = 0,
    set_next_dir: bool = false,
    frame: u3 = 0,
    dots: [90]SnakeDot = undefined,
    length: u8 = 0,
    started: bool = false,
    gameOver: bool = false,
    queuedDirection: bool = false,
    ateFood: bool = false,
    gameOverFrame: u8 = 0,

    pub fn init(self: *@This()) !void {
        self.started = true;
        self.gameOver = false;
        self.gameOverFrame = 0;
        self.x = 5;
        self.y = 2;
        self.length = 0;
        self.ateFood = false;
        self.dir = 0;
        self.next_dir = 0;
        self.set_next_dir = false;
        self.nextFood();
        for (&self.dots) |*dot| {
            dot.* = SnakeDot{};
        }
    }

    pub fn addDot(self: *@This()) void {
        // convert x and y to index
        const index: usize = @intCast(self.x + (self.y * 10));
        self.dots[index].addedThisFrame = !self.dots[index].active;
        self.dots[index].active = true;
        self.dots[index].framesLeft = self.length;
    }

    pub fn resetTray(self: *@This()) !void {
        const game = mappings.Game{ .reader = reader };
        const win_defs = try game.getWinDefs();
        const trayStart: i32 = @intFromEnum(mappings.WindowNames.WDW_TRAY_1);
        const trayMax: i32 = @intFromEnum(mappings.WindowNames.WDW_TRAY_8);
        var trayIndex: i32 = 0;
        while (trayIndex + trayStart <= trayMax) : (trayIndex += 1) {
            const tray = try win_defs.item(@intCast(trayStart + trayIndex));
            const tray_loc = try tray.getLoc();
            const width = try tray_loc.getWidth();
            const height = try tray_loc.getHeight();
            try tray_loc.updatePos(1920 - width, 1080 - (height * (trayIndex + 4)));
        }
        const tray = try game.getTray();
        const tray_internals = try tray.getInternals();
        const slots = try tray_internals.getSlots();
        var slotsIterator = slots.iterator();
        var slotIndex: u64 = 0;
        while (try slotsIterator.next()) |slot| : (slotIndex += 1) {
            if (slotIndex == 90) break;
            try game.reader.writeField(slot, slot.type, &@intFromEnum(mappings.TrayItemTypes.MacroHideName));
            try game.reader.writeField(slot, slot.macro_image, "circulartab_2" ++ [_]u8{0});
            try game.reader.writeField(slot, slot.macro_cmd, &[_]u8{0});
        }
        if (self.started) try self.draw();
    }

    pub fn gameLoop(self: *@This()) !void {
        if (self.gameOver) return;
        var dotAdded: bool = false;
        for (&self.dots) |*dot| {
            if (dot.framesLeft > 0) {
                if (dot.addedThisFrame or self.ateFood) dotAdded = true;
                dot.framesLeft -= 1;
            } else dot.active = false;
            dot.addedThisFrame = false;
        }
        self.ateFood = false;
        if (!dotAdded and self.length > 3) {
            self.gameOver = true;
        }
        if (self.dir == 0) {
            self.y += 1;
            if (self.y == 9) self.gameOver = true;
        } else if (self.dir == 1) {
            self.y -= 1;
            if (self.y == -1) self.gameOver = true;
        } else if (self.dir == 2) {
            self.x -= 1;
            if (self.x == -1) self.gameOver = true;
        } else if (self.dir == 3) {
            self.x += 1;
            if (self.x == 10) self.gameOver = true;
        }
        if (self.gameOver) return;
        self.queuedDirection = false;
        if (self.set_next_dir) {
            self.dir = self.next_dir;
            self.set_next_dir = false;
        }
        self.addDot();
        if (self.x == self.foodX and self.y == self.foodY) {
            self.length += 1;
            self.addDot();
            self.ateFood = true;
            self.nextFood();
            if (self.length == 90) {
                self.gameOver = true;
            }
        }
    }

    pub fn nextFood(self: *@This()) void {
        var next_food_index: u8 = std.crypto.random.intRangeAtMost(u8, 0, 89);
        while (next_food_index == self.foodX + (self.foodY * 10) or self.dots[next_food_index].active) {
            next_food_index = std.crypto.random.intRangeAtMost(u8, 0, 89);
        }
        const foodX = next_food_index % 10;
        const foodY = next_food_index / 10;
        self.foodX = foodX;
        self.foodY = foodY;
    }

    pub fn draw(self: *@This()) !void {
        defer {
            self.frame += 1;
            if (self.frame > 4) self.frame = 0;
            if (self.gameOver and self.gameOverFrame < 90) {
                self.gameOverFrame += 1;
            } else if (self.gameOver) self.started = false;
        }
        if (self.gameOverFrame == 91) return;
        if (self.frame != 0 and !self.gameOver) return;
        try self.gameLoop();
        const game = mappings.Game{ .reader = reader };
        const tray = try game.getTray();
        const tray_internals = try tray.getInternals();
        const slots = try tray_internals.getSlots();
        var slotsIterator = slots.iterator();
        var slotIndex: u64 = 0;
        while (try slotsIterator.next()) |slot| : (slotIndex += 1) {
            if (slotIndex == 90) break;
            const x = slotIndex % 10;
            const y = slotIndex / 10;
            const active = self.dots[slotIndex].active;
            var slotName: [2:0]u8 = [_:0]u8{0} ** 2;
            _ = std.fmt.formatIntBuf(slotName[0..], slotIndex, 10, .lower, .{});
            if (self.gameOver) {
                const resetCommand = "bind button7 exec snakeInit";
                if (slotIndex == self.gameOverFrame and slotIndex != 44 and slotIndex != 45) {
                    try game.reader.writeField(slot, slot.macro_image, "Skulls_Morana_AuraOfFear" ++ [_]u8{0});
                    try game.reader.writeField(slot, slot.macro_cmd, resetCommand);
                } else {
                    if (self.gameOverFrame == 44 and slotIndex == 44) {
                        try game.reader.writeField(slot, slot.macro_image, "circulartab_2" ++ [_]u8{0});
                        try game.reader.writeField(slot, slot.type, &@intFromEnum(mappings.TrayItemTypes.Macro));
                        try game.reader.writeField(slot, slot.macro_name, "Score" ++ [_]u8{0});
                        try game.reader.writeField(slot, slot.macro_cmd, resetCommand);
                    } else if (self.gameOverFrame == 45 and slotIndex == 45) {
                        var score_buff: [2:0]u8 = [_:0]u8{0} ** 2;
                        _ = std.fmt.formatIntBuf(&score_buff, self.length, 10, .lower, .{});
                        try game.reader.writeField(slot, slot.macro_image, "circulartab_2" ++ [_]u8{0});
                        try game.reader.writeField(slot, slot.type, &@intFromEnum(mappings.TrayItemTypes.Macro));
                        try game.reader.writeField(slot, slot.macro_name, &score_buff);
                        try game.reader.writeField(slot, slot.macro_cmd, resetCommand);
                    }
                }
            } else {
                try game.reader.writeField(slot, slot.macro_image, blk: {
                    if (x == snakeGame.x and y == snakeGame.y) break :blk "LuminousAura_WhiteDwarfSmite" ++ [_]u8{0};
                    if (x == snakeGame.foodX and y == snakeGame.foodY) break :blk "Inspiration_Damage_Lvl_1" ++ [_]u8{0};
                    if (active) break :blk "LuminousAura_WhiteDwarfStrike" ++ [_]u8{0};
                    break :blk "circulartab_2" ++ [_]u8{0};
                });
            }
        }
    }
}{};

const Commands = enum {
    @"test",
    snakeResetTray,
    snakeInit,
    snakeUp,
    snakeDown,
    snakeLeft,
    snakeRight,

    pub fn execute(self: Commands, game: mappings.Game, args: []const u8) !void {
        _ = args; // autofix
        const player = try game.getPlayer();
        switch (self) {
            .@"test" => {
                const name = try player.getName();
                defer reader.allocator.free(name);
                std.debug.print("Name: {s}\n", .{name});
            },
            .snakeInit => {
                const name = try player.getName();
                defer reader.allocator.free(name);
                if (!std.mem.eql(u8, name, "What the snake?")) return;
                if (snakeGame.started) return;
                try snakeGame.resetTray();
                try snakeGame.init();
            },
            .snakeResetTray => {
                if (snakeGame.started) return;
                try snakeGame.resetTray();
            },
            .snakeUp => {
                if (snakeGame.dir != 1) {
                    if (snakeGame.queuedDirection) {
                        snakeGame.next_dir = 0;
                        snakeGame.set_next_dir = true;
                    } else snakeGame.dir = 0;
                    snakeGame.queuedDirection = true;
                }
            },
            .snakeDown => {
                if (snakeGame.dir != 0) {
                    if (snakeGame.queuedDirection) {
                        snakeGame.next_dir = 1;
                        snakeGame.set_next_dir = true;
                    } else snakeGame.dir = 1;
                    snakeGame.queuedDirection = true;
                }
            },
            .snakeLeft => {
                if (snakeGame.dir != 3) {
                    if (snakeGame.queuedDirection) {
                        snakeGame.next_dir = 2;
                        snakeGame.set_next_dir = true;
                    } else snakeGame.dir = 2;
                    snakeGame.queuedDirection = true;
                }
            },
            .snakeRight => {
                if (snakeGame.dir != 2) {
                    if (snakeGame.queuedDirection) {
                        snakeGame.next_dir = 3;
                        snakeGame.set_next_dir = true;
                    } else snakeGame.dir = 3;
                    snakeGame.queuedDirection = true;
                }
            },
        }
    }
};

const winHeight: i32 = 175;
const winLeftOffset: i32 = 597 + 10;

pub fn init(window: win32.HWND, memReader: mem.MemoryReader) !void {
    gameWindow = window;
    reader = memReader;

    initialized = true;

    const handle = win32.GetModuleHandleA(null);
    var windowRc: win32.RECT = undefined;
    _ = win32.GetWindowRect(gameWindow, &windowRc);
    monitor = win32.MonitorFromWindow(gameWindow, .NEAREST).?;

    const wnd_class = win32.WNDCLASSA{
        .style = .{ .HREDRAW = 1, .VREDRAW = 1 },
        .lpfnWndProc = &handleWindowHook,
        .hInstance = handle,
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = win32.GetStockObject(.BLACK_BRUSH),
        .lpszClassName = "CohOverlay",
        .cbWndExtra = 0,
        .cbClsExtra = 0,
        .hIcon = null,
        .lpszMenuName = null,
    };
    _ = win32.RegisterClassA(&wnd_class);
    defer _ = win32.UnregisterClassA("CohOverlay", handle);
    overlayInt = @intFromPtr(win32.CreateWindowExA(
        .{ .LAYERED = 1, .TOOLWINDOW = 1, .TRANSPARENT = 1, .TOPMOST = 1 },
        "CohOverlay",
        "CohOverlay",
        .{ .POPUP = 1, .VISIBLE = 1 },
        windowRc.left + winLeftOffset,
        windowRc.bottom - winHeight,
        350,
        winHeight,
        null,
        null,
        handle,
        null,
    ).?);
    const overlay: win32.HWND = @ptrFromInt(overlayInt);
    _ = win32.SetLayeredWindowAttributes(overlay, 0, 255, .{
        .ALPHA = 1,
        .COLORKEY = 1,
    });
    _ = win32.UpdateWindow(overlay);
}

var winVisible: bool = false;
var wasLoading = true;
var swappedMonitorTicks: u32 = 0;
pub fn mainLoop() !void {
    if (!initialized) return;
    if (overlayInt == 0) return;
    const overlay: win32.HWND = @ptrFromInt(overlayInt);
    var isCloaked: win32.BOOL = 0;
    _ = win32.DwmGetWindowAttribute(gameWindow, win32.DWMWA_CLOAKED, &isCloaked, @sizeOf(win32.BOOL));
    const hwndFore = win32.GetForegroundWindow();
    var windowRc: win32.RECT = undefined;
    _ = win32.GetWindowRect(gameWindow, &windowRc);
    if (swappedMonitorTicks > 0) {
        _ = win32.SetWindowPos(overlay, win32.HWND_TOPMOST, 0, 0, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 1 });
        swappedMonitorTicks -= 1;
    }

    const newMonitor = win32.MonitorFromWindow(gameWindow, .NEAREST).?;
    if (newMonitor != monitor) {
        monitor = newMonitor;
        _ = win32.SetWindowPos(overlay, win32.HWND_BOTTOM, windowRc.left + winLeftOffset, windowRc.bottom - winHeight, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 0 });
        swappedMonitorTicks = 10;
    }
    if ((hwndFore == gameWindow) and isCloaked != 2) {
        if (overlayInt == 0) return;
        if (!wasLoading) {
            _ = win32.InvalidateRect(overlay, null, 1);
            _ = win32.UpdateWindow(overlay);
        }
        if (!winVisible) {
            _ = win32.SetWindowPos(overlay, win32.HWND_TOPMOST, 0, 0, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 1 });
            winVisible = true;
        }
    } else if (winVisible) {
        _ = win32.SetWindowPos(overlay, win32.HWND_BOTTOM, 0, 0, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 1 });
        winVisible = false;
    }
    const game = mappings.Game{ .reader = reader };
    if (blk: {
        const state = try game.getState();
        const game_mode = try state.getGameMode();
        if (game_mode == 3) {
            try game.setKeybind(Keybinds.INP_BUTTON7, "nop" ++ [_]u8{0});
        }
        break :blk game_mode != 1; // 1 is in game, 2,4 is menu, 3 is loading
    }) {
        if (!wasLoading) {
            wasLoading = true;
            _ = win32.SetWindowPos(overlay, win32.HWND_BOTTOM, 0, 0, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 1 });
            // _ = win32.ShowWindow(overlay, win32.SW_HIDE);
        }
        return;
    }
    if (wasLoading) {
        wasLoading = false;
        // _ = win32.BringWindowToTop(overlay);
        _ = win32.SetWindowPos(overlay, win32.HWND_TOPMOST, 0, 0, 0, 0, .{ .NOACTIVATE = 1, .NOSIZE = 1, .NOMOVE = 1 });
        // _ = win32.ShowWindow(overlay, win32.SW_SHOW);
        const player = try game.getPlayer();
        _ = player; // autofix
    }
    // return;
    const btn7 = try game.getKeybind(Keybinds.INP_BUTTON7);
    defer reader.allocator.free(btn7);
    if (btn7.len == 0 or std.mem.eql(u8, btn7, "nop")) {
        if (snakeGame.started) try snakeGame.draw();
        return;
    }
    try game.setKeybind(Keybinds.INP_BUTTON7, "nop" ++ [_]u8{0});
    // std.debug.print("Button 7 command: {s}\n", .{btn7});
    const player = try game.getPlayer();
    const character = try player.getCharacter();
    const origin = try character.getOrigin();
    defer reader.allocator.free(origin);
    if (std.mem.eql(u8, origin, "Villain_Origin")) return;
    if (!std.mem.startsWith(u8, btn7, "exec ")) return; // maybe will do other parsing later
    var cmdSplit = std.mem.splitScalar(u8, btn7[5..], ' ');
    if (cmdSplit.next()) |cmd| {
        if (std.meta.stringToEnum(Commands, cmd)) |cmdEnum| {
            try cmdEnum.execute(game, cmdSplit.rest());
        } else {
            std.debug.print("Unknown command: {s}\n", .{cmd});
        }
    }
    if (snakeGame.started) try snakeGame.draw();
    // _ = result catch unreachable;
    // return .disarm;
}

pub fn handleWindowHook(hwnd: win32.HWND, msg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(std.os.windows.WINAPI) win32.LRESULT {
    // const overlay = hwnd;
    // _ = overlay; // autofix
    switch (msg) {
        win32.WM_PAINT => {
            const game = mappings.Game{ .reader = reader };
            const player = game.getPlayer() catch return 0;
            const playerCharacter = player.getCharacter() catch return 0;
            const influence = playerCharacter.getInfluence() catch return 0;

            const playerPos = player.getPos() catch return 0;
            const serializedPos = playerPos.serialize() catch return 0;
            // const playerName = player.getName() catch
            const target = game.getSelected() catch return 0;

            const targetName: []const u8 = blk: {
                if (target.baseAddr == 0) break :blk "None";
                const name = target.getName() catch break :blk "None";
                break :blk name;
            };
            const targetPos = if (target.baseAddr == 0) null else target.getPos() catch return 0;
            const serializedTargetPos = if (targetPos) |pos| pos.serialize() catch return 0 else null;

            defer if (!std.mem.eql(u8, targetName, "None")) reader.allocator.free(targetName);

            const targetDistance: f32 = blk: {
                if (target.baseAddr == 0) break :blk 0;
                if (target.baseAddr == player.baseAddr) break :blk 0;
                const dist = target.getDistance(player) catch break :blk 0;
                break :blk dist;
            };
            const targetHealth: f32 = blk: {
                if (target.baseAddr == 0) break :blk 0;
                // if (target.baseAddr == player.baseAddr) break :blk health;
                const character = target.getCharacter() catch break :blk 0;
                if (character.baseAddr == 0) break :blk 0;
                const tHealth = character.getCurrentHealth() catch break :blk 0;
                break :blk tHealth;
            };
            const targetMaxHealth: f32 = blk: {
                if (target.baseAddr == 0) break :blk 0;
                const character = target.getCharacter() catch break :blk 0;
                if (character.baseAddr == 0) break :blk 0;
                const tMaxHealth = character.getMaxHealth() catch break :blk 0;
                break :blk tMaxHealth;
            };
            const finalString = std.fmt.allocPrint(reader.allocator,
                \\
                \\
                \\Target: {s}
                \\Distance: {d:.2} Health: {d}/{d}
                \\Pos: x: {d:.2} y: {d:.2} z: {d:.2}
                \\
                \\
                \\
                \\
                \\Inf: {d}
                \\x: {d:.2} y: {d:.2} z: {d:.2}
            , .{
                targetName,
                targetDistance,
                targetHealth,
                targetMaxHealth,
                if (serializedTargetPos) |pos| pos.x else 0,
                if (serializedTargetPos) |pos| pos.y else 0,
                if (serializedTargetPos) |pos| pos.z else 0,
                influence,
                serializedPos.x,
                serializedPos.y,
                serializedPos.z,
            }) catch return 0;
            defer reader.allocator.free(finalString);
            var ps: win32.PAINTSTRUCT = undefined;
            const hdc = win32.BeginPaint(hwnd, @ptrCast(&ps));
            var rc: win32.RECT = undefined;
            _ = win32.GetClientRect(hwnd, &rc);
            _ = win32.SetTextColor(hdc, 0xFFFFFF);
            _ = win32.SetBkMode(hdc, .TRANSPARENT);
            _ = win32.DrawTextA(hdc, @ptrCast(finalString), @intCast(finalString.len), &rc, .{ .SINGLELINE = 0 });
            _ = win32.EndPaint(hwnd, @ptrCast(&ps));
        },
        win32.WM_DESTROY => {
            _ = win32.PostQuitMessage(0);
            // return 0;
        },
        else => {
            // std.debug.print("Got message {d}\n", .{msg});
        },
    }
    return win32.DefWindowProcA(hwnd, msg, wParam, lParam);
}
