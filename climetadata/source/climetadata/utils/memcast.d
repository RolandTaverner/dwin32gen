module climetadata.utils.memcast;

const(T)[] asArray(T)(const(ubyte)[] rawMem, size_t offset = 0)
{
    return (cast(const(T)*)(rawMem.ptr + offset))[0 .. rawMem.length / T.sizeof];
}

ref const(T) asRef(T)(const(ubyte)[] rawMem, size_t offset = 0)
{
    return *cast(const(T)*) rawMem.ptr[offset .. offset + T.sizeof];
}

string asString(const(ubyte)[] rawMem, size_t offset = 0)
{
    size_t zero = 0;
    auto p = rawMem.ptr + offset;
    while (p[zero])
        ++zero;
    return (cast(immutable(char)*)(p))[0 .. zero];
}

T asVal(T)(const(ubyte)[] rawMem, size_t offset = 0)
{
    return *cast(T*) rawMem.ptr[offset .. offset + T.sizeof];
}
