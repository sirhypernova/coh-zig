const std = @import("std");
const win32 = @import("zigwin32").everything;
const zigwin32 = @import("zigwin32");

const FieldDefinition = @import("mappings.zig").FieldDefinition;

pub const MemoryError = error{ OutOfMemory, FailedToReadMemory, FailedToWriteMemory, NotImplemented, OutOfBounds, FailedToReadList };

pub const MemoryReader = struct {
    handle: win32.HANDLE,
    modBaseAddr: u64,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, handle: win32.HANDLE, pid: u32) !MemoryReader {
        const modHandle = win32.CreateToolhelp32Snapshot(.{ .SNAPMODULE = 1 }, pid);
        const modEntry = allocator.create(win32.MODULEENTRY32) catch unreachable;
        defer allocator.destroy(modEntry);
        _ = win32.Module32First(modHandle, modEntry);

        const modBaseAddr = @intFromPtr(modEntry.modBaseAddr.?);
        return MemoryReader{
            .handle = handle,
            .modBaseAddr = modBaseAddr,
            .allocator = allocator,
        };
    }

    /// Reads a value from a memory address
    pub fn read(self: MemoryReader, addr: u64, comptime T: type) !T {
        var buffer: T = undefined;
        var bytesRead: usize = 0;

        // std.debug.print("Size of T: {d}\n", .{@sizeOf(T)});
        const success = win32.ReadProcessMemory(self.handle, @ptrFromInt(addr), @ptrCast(&buffer), @sizeOf(T), &bytesRead);
        if (success == 0) {
            // std.debug.print("addr: {x}\n", .{addr});
            // const err = win32.GetLastError();
            // std.debug.dumpCurrentStackTrace(null);
            // std.debug.print("Failed to read memory: {any}\n", .{err});
            return error.FailedToReadMemory;
        } else {
            return buffer;
        }
    }

    /// Follows a series of offsets to a pointer and returns the value
    pub fn followOffsets(self: MemoryReader, addr: u64, offsets: []i64, comptime T: type) !T {
        var offsetIndex: usize = 0;
        var newAddr: u64 = addr;
        while (offsetIndex < offsets.len) : (offsetIndex += 1) {
            const offset = offsets[offsetIndex];
            const addrSigned = @as(i64, @intCast(newAddr)) + offset;
            const finalAddr = @as(u64, @intCast(addrSigned));
            // std.debug.print("Offset: {d}\n", .{offset});
            // std.debug.print("FinalAddr: {x}\n", .{finalAddr});
            if (offsetIndex == offsets.len - 1) {
                return try self.read(finalAddr, T);
            } else {
                const nextAddr = try self.read(finalAddr, u64);
                newAddr = nextAddr;
            }
        }
        return error.FailedToReadMemory;
    }

    /// Follows a series of offsets to a pointer and returns the pointer
    pub fn followOffsetsToPointer(self: MemoryReader, addr: u64, offsets: []i64) !u64 {
        var offsetIndex: usize = 0;
        var newAddr: u64 = addr;
        // std.debug.print("offsets: {any}\n", .{offsets});
        while (offsetIndex < offsets.len) : (offsetIndex += 1) {
            const offset = offsets[offsetIndex];
            const addrSigned = @as(i64, @intCast(newAddr)) + offset;
            const finalAddr = @as(u64, @intCast(addrSigned));
            // std.debug.print("finalAddr: {x}\n", .{finalAddr});
            if (offsetIndex == offsets.len - 1) {
                return finalAddr;
            } else {
                const nextAddr = try self.read(finalAddr, u64);
                newAddr = nextAddr;
            }
        }
        return error.FailedToReadMemory;
    }

    /// Follows a series of offsets to a pointer and returns the string, up to a max length
    pub fn followOffsetsString(self: MemoryReader, addr: u64, offsets: []i64, comptime maxLength: ?usize) ![]u8 {
        const maxReadLength: usize = maxLength orelse 1024;
        // std.debug.print("s addr: {x}\n", .{addr});
        const startAddr = try self.followOffsetsToPointer(addr, offsets);
        var memLoc: usize = 0;
        var finalLoc: usize = 64;
        var strBuffer = try self.allocator.alloc(u8, maxReadLength);
        errdefer self.allocator.free(strBuffer);
        // defer self.allocator.free(strBuffer);
        @memcpy(strBuffer[memLoc..64], &try self.read(startAddr, [64]u8));
        memLoc += 64;
        for (strBuffer[0..], 0..) |c, i| {
            if (c == 0) {
                finalLoc = i;
                const finalBuffer = try self.allocator.alloc(u8, finalLoc);
                @memcpy(finalBuffer, strBuffer[0..finalLoc]);
                self.allocator.free(strBuffer);
                return finalBuffer;
            }
        }

        str: while (memLoc < maxReadLength) : (memLoc += 64) {
            const str = try self.read(startAddr + memLoc, [64]u8);
            @memcpy(strBuffer[memLoc .. memLoc + 64], &str);
            for (str, 0..) |c, i| {
                if (c == 0) {
                    finalLoc = memLoc + i;
                    break :str;
                }
            }
        }
        const finalBuffer = try self.allocator.alloc(u8, finalLoc);
        @memcpy(finalBuffer, strBuffer[0..finalLoc]);
        self.allocator.free(strBuffer);
        return finalBuffer;
    }

    /// Reads a value, using a field definition, from a memory address
    pub fn readField(self: MemoryReader, parent: anytype, field: FieldDefinition) !field.type {
        const readAddr = parent.baseAddr orelse self.modBaseAddr;
        if (field.ptr) {
            if (field.isInline) {
                var newOffsets: [field.offset.len + 1]i64 = [_]i64{0} ** (field.offset.len + 1);
                @memcpy(newOffsets[1..], field.offset);
                const ptr = if (newOffsets.len == 0) readAddr else try self.followOffsetsToPointer(readAddr, &newOffsets);
                return field.type{
                    .baseAddr = ptr,
                    .isInline = field.isInline,
                    .reader = self,
                };
            }
            const ptr = try self.followOffsetsToPointer(readAddr, field.offset);
            return field.type{
                .baseAddr = ptr,
                .isInline = field.isInline,
                .reader = self,
            };
        } else {
            const info = @typeInfo(field.type);
            switch (info) {
                .Pointer => {
                    if (info.Pointer.size == .Slice and info.Pointer.child == u8) {
                        // if (parent.baseAddr) |addr| {
                        //     std.debug.print("rf s addr: {x}\n", .{addr});
                        // }
                        const str = try self.followOffsetsString(readAddr, field.offset, null);
                        return str;
                    }
                },
                else => {},
            }
            // std.debug.print("is inline: {any}\n", .{field.isInline});
            // std.debug.print("field: {any}\n", .{field});
            if (parent.isInline) {
                const newOffsets = field.offset[0..(field.offset.len - 1)];
                // std.debug.print("new offsets: {any}\n", .{newOffsets});
                var ptr = if (newOffsets.len == 0) readAddr else try self.followOffsetsToPointer(readAddr, newOffsets);
                const offset = field.offset[field.offset.len - 1];
                if (offset > 0) {
                    ptr += offset;
                } else {
                    ptr -= @abs(offset);
                }
                // std.debug.print("ptr: {x} readAddr: {x}\n", .{ ptr, readAddr });
                // std.debug.print("type: {any}\n", .{field.type});
                // std.debug.print("offset: {d}\n", .{offset});
                // const addrSigned: i64 = @as(i64, @intCast(ptr)) + offset;
                // std.debug.print("addr signed: {d}\n", .{addrSigned});
                // const finalAddr = @as(u64, @intCast(addrSigned));
                return try self.read(ptr, field.type);
            }
            if (field.isInline) {
                const newOffsets = field.offset[0..(field.offset.len - 1)];
                // std.debug.print("new offsets: {any}\n", .{newOffsets});
                var ptr = if (newOffsets.len == 0) readAddr else try self.followOffsetsToPointer(readAddr, newOffsets);
                // std.debug.print("ptr: {x}\n", .{ptr});
                const offset = field.offset[field.offset.len - 1];
                // const addrSigned = @as(i64, @intCast(ptr)) + offset;
                // const finalAddr = @as(u64, @intCast(addrSigned));
                if (offset > 0) {
                    ptr += offset;
                } else {
                    ptr -= @abs(offset);
                }
                return field.type{
                    .baseAddr = ptr,
                    .isInline = field.isInline,
                    .reader = self,
                };
            }
            const val = try self.followOffsets(readAddr, field.offset, field.type);
            return val;
        }
        return error.NotImplemented;
    }
    /// Writes a value to a memory address
    pub fn write(self: MemoryReader, addr: u64, value: anytype) !void {
        var bytesWritten: usize = 0;
        const typeInfo = @typeInfo(@TypeOf(value));
        // std.debug.print("Type name {s}\n", .{@typeName(@TypeOf(value))});
        const byteSize = switch (typeInfo) {
            .Pointer => blk: {
                break :blk switch (typeInfo.Pointer.size) {
                    .One => @sizeOf(@TypeOf(value.*)),
                    .Slice => @sizeOf(typeInfo.Pointer.child) * value.len,
                    else => return error.OneOrSliceOnly,
                };
            },
            else => return error.MustBePointer,
        };
        // std.debug.print("Value: {any}\n", .{value});
        const success = win32.WriteProcessMemory(self.handle, @ptrFromInt(addr), @ptrCast(value), byteSize, &bytesWritten);
        if (success == 0) {
            // const err = win32.GetLastError();
            // std.debug.print("Failed to write memory: {any}\n", .{err});
            // std.debug.print("Value: {any}\n", .{value});
            return error.FailedToWriteMemory;
        }
    }

    /// Writes a value to a field, using a field definition, to a memory address
    pub fn writeField(self: MemoryReader, parent: anytype, field: FieldDefinition, value: anytype) !void {
        const readAddr = parent.baseAddr orelse self.modBaseAddr;
        if (field.ptr) {
            if (field.isInline) {
                var newOffsets: [field.offset.len + 1]i64 = [_]i64{0} ** (field.offset.len + 1);
                @memcpy(newOffsets[1..], field.offset);
                const ptr = if (newOffsets.len == 0) readAddr else try self.followOffsetsToPointer(readAddr, &newOffsets);
                try self.write(ptr, value);
                return;
            }
            const ptr = try self.followOffsetsToPointer(readAddr, field.offset);
            try self.write(ptr, value);
        } else {
            if (parent.isInline) {
                const newOffsets = field.offset[0..(field.offset.len - 1)];
                const ptr = if (newOffsets.len == 0) readAddr else try self.followOffsetsToPointer(readAddr, newOffsets);
                try self.write(ptr + field.offset[field.offset.len - 1], value);
                return;
            }
            const ptr = try self.followOffsetsToPointer(
                readAddr,
                field.offset,
            );
            try self.write(ptr, value);
        }
    }
};
