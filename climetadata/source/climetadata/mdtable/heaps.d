module climetadata.mdtable.heaps;

public import std.uuid : UUID;

import climetadata.utils.memcast;
import climetadata.utils.readcompressed;

public struct Heaps
{
    @disable this();

    public this(const(ubyte)[] stringsHeap, const(ubyte)[] guidsHeap, const(ubyte)[] blobsHeap)
    {
        strings = StringsHeap(stringsHeap);
        guids = GuidsHeap(guidsHeap);
        blobs = BlobsHeap(blobsHeap);
    }

    pragma(inline, true)
    public string getString(uint offset) const
    {
        return strings.get(offset);
    }

    pragma(inline, true)
    public UUID getGuid(uint rowID) const
    {
        return guids.get(rowID);
    }

    pragma(inline, true)
    public const(ubyte)[] getBlob(uint offset) const
    {
        return blobs.get(offset);
    }

private:
    const StringsHeap strings;
    const GuidsHeap guids;
    const BlobsHeap blobs;
}

struct StringsHeap
{
    @disable this();

    public this(const(ubyte)[] heap)
    {
        stringsHeap = heap;
    }

    pragma(inline, true)
    public string get(uint offset) const
    {
        return asString(stringsHeap, offset);
    }

    private const(ubyte)[] stringsHeap;
}

struct GuidsHeap
{
    @disable this();

    public this(const(ubyte)[] heap)
    {
        guidsHeap = heap;
    }

    pragma(inline, true)
    UUID get(uint rowID) const
    {
        if (!rowID)
            return UUID.init;

        auto index = rowID - 1;
        return asRef!UUID(guidsHeap[index * UUID.sizeof .. index * UUID.sizeof + UUID.sizeof]);
    }

    private const(ubyte)[] guidsHeap;
}

struct BlobsHeap
{
    @disable this();

    public this(const(ubyte)[] heap)
    {
        blobsHeap = heap;
    }

    pragma(inline, true)
    const(ubyte)[] get(uint offset) const
    {
        auto blob = blobsHeap[offset .. $];
        auto size = readCompressed(blob);
        return blob[0 .. size];
    }

    private const(ubyte)[] blobsHeap;
}
