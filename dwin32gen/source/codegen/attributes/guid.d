module codegen.attributes.guid;

import std.exception : enforce;
import std.format : format;
import std.typecons : nullable, Nullable;
import std.uuid : UUID;

import climetadata.mdcollection.entitytypes : CustomAttributeEntity;
import climetadata.mdcollection.signature : ElementSig;

public struct GuidAttribute
{
    @disable this();

    public this(Range)(Range r)
    {
        foreach(ca; r)
        {
            if (ca.name() == "GuidAttribute")
            {
                guid = nullable(readGuid(ca));
            }
            else
            {
                unhandledAttributes ~= ca;
            }
        }
    }

    public Nullable!UUID getGuid() const
    {
        return guid;
    }

    public const(CustomAttributeEntity)[] getUnhandledAttributes() const
    {
        return unhandledAttributes;
    }

    private Nullable!UUID guid;
    private const(CustomAttributeEntity)[] unhandledAttributes;
}

private UUID readGuid(scope ref const CustomAttributeEntity ca)
{
    assert(ca.name() == "GuidAttribute");
    auto sig = ca.value();

    enforce(sig.fixed.length == 11, format("GuidAttribute contains %s FixedArgSig elements, expected 11", sig.fixed.length));

    assert(sig.fixed[0].value.get!ElementSig.value.peek!uint != null);
    assert(sig.fixed[1].value.get!ElementSig.value.peek!ushort != null);
    assert(sig.fixed[2].value.get!ElementSig.value.peek!ushort != null);
    assert(sig.fixed[3].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[4].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[5].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[6].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[7].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[8].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[9].value.get!ElementSig.value.peek!ubyte != null);
    assert(sig.fixed[10].value.get!ElementSig.value.peek!ubyte != null);

    auto a = sig.fixed[0].value.get!ElementSig.value.get!uint;
    auto b = sig.fixed[1].value.get!ElementSig.value.get!ushort;
    auto c = sig.fixed[2].value.get!ElementSig.value.get!ushort;
    auto d = sig.fixed[3].value.get!ElementSig.value.get!ubyte;
    auto e = sig.fixed[4].value.get!ElementSig.value.get!ubyte;
    auto f = sig.fixed[5].value.get!ElementSig.value.get!ubyte;
    auto g = sig.fixed[6].value.get!ElementSig.value.get!ubyte;
    auto h = sig.fixed[7].value.get!ElementSig.value.get!ubyte;
    auto i = sig.fixed[8].value.get!ElementSig.value.get!ubyte;
    auto j = sig.fixed[9].value.get!ElementSig.value.get!ubyte;
    auto k = sig.fixed[10].value.get!ElementSig.value.get!ubyte;

    ubyte a0 = (a >> (0 * 8)) & 0xFF; 
    ubyte a1 = (a >> (1 * 8)) & 0xFF;
    ubyte a2 = (a >> (2 * 8)) & 0xFF;
    ubyte a3 = (a >> (3 * 8)) & 0xFF;

    ubyte b0 = (b >> (0 * 8)) & 0xFF; 
    ubyte b1 = (b >> (1 * 8)) & 0xFF;

    ubyte c0 = (c >> (0 * 8)) & 0xFF; 
    ubyte c1 = (c >> (1 * 8)) & 0xFF;

    auto guid = UUID(a3, a2, a1, a0, b1, b0, c1, c0, d, e, f, g, h, i, j, k);

    return guid;
}
