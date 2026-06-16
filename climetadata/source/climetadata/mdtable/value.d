module climetadata.mdtable.value;

import std.traits : isIntegral;

public import climetadata.mdtable.valuekind;

public struct Value(T, ValueKind K) if (isIntegral!T)
{
    public alias Kind = K;
    public alias Type = T;

    public this(in T value)
    {
        this.value = value;
    }

    alias value this;

    const T value;
}

unittest
{
    Value!(uint, ValueKind.Integral) v = 1;

    assert(v == 1);
    assert(v.value == 1);
}
