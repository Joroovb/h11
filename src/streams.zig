pub const ByteStream = struct {
    data: []const u8,
    cursor: usize,

    pub fn init(data: []const u8) ByteStream {
        return ByteStream{ .data = data, .cursor = 0 }; 
    }

    /// Read one line from the stream.
    /// Returns an empty line if CRLF is not found.
    pub fn readLine(self: *ByteStream) []const u8 {
        var start = self.cursor;
        var cursor = self.cursor;

        var lineFound = false;
        while (cursor < self.data.len) {
            if ((self.data[cursor] == '\n') and (self.data[cursor - 1] == '\r')) {
                cursor += 1;
                lineFound = true;
                break;
            }
            cursor += 1;
        }

        if (lineFound) {
            self.cursor = cursor;
            return self.data[start..cursor - 2];
        } else {
            return "";
        }
    }

    /// Read up to `size` bytes.
    /// FIXME: Currently implement just the cursor shift to be usable in the tests.
    pub fn read(self: *ByteStream, size: usize) void {
        self.cursor += size;
    }

    pub fn len(self: *ByteStream) usize {
        return self.data.len - cursor;
    }
};


const std = @import("std");
const testing = std.testing;


test "ReadLine - No CRLF returns an empty line" {
    var stream = ByteStream.init("HTTP/1.1 200 OK");

    var line = stream.readLine();

    testing.expect(std.mem.eql(u8, line, ""));
}

test "ReadLine - Read line returns the entire buffer" {
    var stream = ByteStream.init("HTTP/1.1 200 OK\r\n");
    var line = stream.readLine();

    testing.expect(std.mem.eql(u8, line, "HTTP/1.1 200 OK"));
}

test "ReadLine - Read line returns the remaining buffer" {
    var stream = ByteStream.init("HTTP/1.1 200 OK\r\n");
    stream.read(9);
    var line = stream.readLine();

    testing.expect(std.mem.eql(u8, line, "200 OK"));
}

test "ReadLine - Read lines one by one " {
    var stream = ByteStream.init("HTTP/1.1 200 OK\r\nServer: Apache\r\nContent-Length: 51\r\n");
    var firstLine = stream.readLine();
    var secondLine = stream.readLine();
    var thirdLine = stream.readLine();

    testing.expect(std.mem.eql(u8, firstLine, "HTTP/1.1 200 OK"));
    testing.expect(std.mem.eql(u8, secondLine, "Server: Apache"));
    testing.expect(std.mem.eql(u8, thirdLine, "Content-Length: 51"));
}