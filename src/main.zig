const std = @import("std");
const win32 = @import("zigwin32").everything;
const zigwin32 = @import("zigwin32");

const Mappings = @import("mappings.zig");
const MemoryReader = @import("memory.zig").MemoryReader;
const MemoryError = @import("memory.zig").MemoryError;
const utils = @import("utils.zig");
const Keybinds = @import("keybinds.zig");
const cScript = @import("cscript.zig");

usingnamespace zigwin32.zig;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var hook: ?win32.HHOOK = null;
var window: win32.HWND = undefined;
var pid: u32 = undefined;
var handle: win32.HANDLE = undefined;
var modBaseAddr: u64 = undefined;

var memoryReader: MemoryReader = undefined;

pub fn handleKeyboardHook(nCode: i32, wParam: win32.WPARAM, lParam: win32.KBDLLHOOKSTRUCT) callconv(std.os.windows.WINAPI) win32.LRESULT {
    const realLParam: isize = @bitCast(@intFromPtr(&lParam));
    if (nCode < 0) return win32.CallNextHookEx(hook.?, nCode, wParam, realLParam);
    const nextHook = win32.CallNextHookEx(hook.?, nCode, wParam, realLParam);
    // const char = std.mem.asBytes(&win32.MapVirtualKeyW(lParam.vkCode, win32.MAPVK_VK_TO_CHAR))[0..1];
    // std.debug.print("Key: {s}\n", .{char});
    // const vk: win32.VIRTUAL_KEY = @enumFromInt(lParam.vkCode);
    // std.debug.print("Key down\n", .{});
    if (wParam == win32.WM_KEYDOWN) {
        const vk: win32.VIRTUAL_KEY = @enumFromInt(lParam.vkCode);
        switch (vk) {
            .NUMPAD1 => {
                if (@intFromPtr(window) != 0) return nextHook;
                if (win32.GetForegroundWindow()) |hwnd| {
                    window = hwnd;
                    _ = win32.GetWindowThreadProcessId(hwnd, &pid);

                    handle = win32.OpenProcess(win32.PROCESS_ACCESS_RIGHTS{
                        .QUERY_INFORMATION = 1,
                        .VM_READ = 1,
                        .VM_WRITE = 1,
                        .VM_OPERATION = 1,
                    }, 0, pid) orelse unreachable;

                    memoryReader = try MemoryReader.init(allocator, handle, pid);

                    cScript.init(window, memoryReader) catch return nextHook;
                }
            },
            .NUMPAD2 => {
                // if (window != undefined) {
                //     _ = win32.PostMessageW(window, win32.WM_KEYDOWN, 65, 0);
                // }
            },
            .NUMPAD3 => {
                if (window != undefined) {
                    const memInfo = std.os.windows.GetProcessMemoryInfo(win32.GetCurrentProcess().?) catch unreachable;
                    std.debug.print("Memory: {d}\n", .{memInfo.WorkingSetSize});
                }
            },
            else => {},
        }
    }
    return nextHook;
}

pub fn main() !void {
    hook = win32.SetWindowsHookExW(win32.WH_KEYBOARD_LL, @ptrCast(&handleKeyboardHook), null, 0);
    defer _ = win32.UnhookWindowsHookEx(hook.?);

    _ = win32.SetTimer(null, 1, 30, null);
    var msg: win32.MSG = undefined;
    while (win32.GetMessageW(&msg, null, 0, 0) != 0) {
        if (msg.message == win32.WM_TIMER) {
            cScript.mainLoop() catch continue;
        }
    }
}
