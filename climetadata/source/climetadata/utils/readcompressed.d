module climetadata.utils.readcompressed;

import std.exception : enforce;
import std.traits : isIntegral;

import climetadata.utils.memcast;

// Reads compressed integer
// See https://github.com/dotnet/coreclr/blob/e879597385221df7131042d1e0830b87f7632a01/src/inc/cor.h#L2090-L2514
T peekCompressed(T = uint)(const(ubyte)[] data) if (isIntegral!T)
{
    if ((data[0] & 0x80) == 0x00)
        return cast(T)(data[0]);
    else if ((data[0] & 0xc0) == 0x80)
        return cast(T)(((data[0] & 0x3f) << 8) | data[1]);
    else if ((data[0] & 0xe0) == 0xc0)
    {
        return cast(T) (((data[0] & 0x3f) << 24) 
                        | (data[1] << 16)
                        | (data[2] << 8)
                        | (data[3]));
    }
    enforce(false, "Invalid compressed encoding");
    assert(0);
}

// Reads compressed integer and advances data
// See https://github.com/dotnet/coreclr/blob/e879597385221df7131042d1e0830b87f7632a01/src/inc/cor.h#L2090-L2514
T readCompressed(T = uint)(ref const(ubyte)[] data) if (isIntegral!T)
{
    static assert(T.sizeof <= uint.sizeof);

    uint r;
    size_t len;

    if ((data[0] & 0x80) == 0x00)
    {
        len = 1;
        r = data[0];
    }
    else if ((data[0] & 0xc0) == 0x80)
    {
        len = 2;
        r = ((data[0] & 0x3f) << 8) | data[1];
    }
    else if ((data[0] & 0xe0) == 0xc0)
    {
        len = 4;
        r = ((data[0] & 0x3f) << 24) 
            | (data[1] << 16)
            | (data[2] << 8)
            | (data[3]);
    }

    enforce(len, "Invalid compressed encoding");

    data = data[len .. $];
    return cast(T)r;
}

bool readCompressedCond(T)(ref const(ubyte)[] data, T condVal) if (isIntegral!T)
{
    if (peekCompressed!T(data) == condVal)
    {
        readCompressed!T(data);
        return true;
    }
    return false;
}

T read(T)(ref const(ubyte)[] data)
{
    auto value = asVal!T(data);
    data = data[T.sizeof .. $];
    return value;
}

string readString(ref const(ubyte)[] data)
{
    auto len = readCompressed(data);    
    string r = (cast(immutable(char)*)(data.ptr))[0 .. len];
    data = data[len .. $];
    return r;
}

