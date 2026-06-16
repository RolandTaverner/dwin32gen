module climetadata.mdcollection.bits;

import std.traits: getUDAs;

public template indexBits(T)
{
    enum indexBits = getUDAs!(T, Bits)[0].value;
}

public struct Bits
{
    int value;
}
