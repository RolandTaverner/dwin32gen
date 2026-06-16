module codegen.attributes.constant;

import std.algorithm.iteration : map;
import std.algorithm.searching : count;
import std.array : array, join, split;
import std.conv : to;
import std.string : indexOf, strip;
import std.exception : enforce;
import std.format : format;

import climetadata.mdcollection.entitytypes : CustomAttributeEntity;
import climetadata.mdcollection.signature : ElementSig;

public enum KnownConstantType
{
    UNKNOWN,
    PROPERTYKEY, // for PROPERTYKEY and DEVPROPKEY
    SID_IDENTIFIER_AUTHORITY, // for SID_IDENTIFIER_AUTHORITY
}

public struct ConstantAttribute
{
    @disable this();

    public this(Range)(Range r, KnownConstantType constType)
    {
        foreach(ca; r)
        {
            if (ca.name() == "ConstantAttribute")
            {
                constantValue = readConstantValue(ca, constType);
            }
            else
            {
                unhandledAttributes ~= ca;
            }
        }
    }

    public string getConstantValue() const
    {
        return constantValue;
    }

    public const(CustomAttributeEntity)[] getUnhandledAttributes() const
    {
        return unhandledAttributes;
    }

    private string constantValue;
    private const(CustomAttributeEntity)[] unhandledAttributes;
}

private string readConstantValue(scope ref const CustomAttributeEntity ca, KnownConstantType constType)
{
    assert(ca.name() == "ConstantAttribute");
    auto sig = ca.value();
    
    enforce(sig.fixed.length == 1, format("ConstantAttribute contains %s FixedArgSig elements, expected 1", sig.fixed.length));

    auto element = sig.fixed[0].value.peek!ElementSig;
    assert(element != null);
    enforce(element.value.peek!string != null, "ConstantAttribute fixed[0] FixedArgSig element's value is not string");
    const string strValue = element.value.get!string;

    final switch (constType)
    {
        case KnownConstantType.PROPERTYKEY:
            // PROPERTYKEY/DEVPROPKEY values are strings like "{4277826612, 57597, 19242, 144, 90, 125, 1, 39, 169, 240, 28}, 2"
            enforce(strValue.count('{') == 1, "ConstantAttribute: invalid PROPERTYKEY value: '{' count != 1");
            enforce(strValue.count('}') == 1, "ConstantAttribute: invalid PROPERTYKEY value: '}' count != 1");
            auto idxOpenBr = strValue.indexOf('{');
            auto idxCloseBr = strValue.indexOf('}');
            auto guidStr = strValue[idxOpenBr + 1 .. idxCloseBr];
            string[] guidParts = guidStr.split(",").map!(s => s.strip).array;
            enforce(guidParts.length == 11, format("ConstantAttribute (PROPERTYKEY): invalid GUID components count %s != 11", guidParts.length));
            string[] guidPartsHex = [
                format("%08X", to!uint(guidParts[0])),
                format("%04X", to!ushort(guidParts[1])),
                format("%04X", to!ushort(guidParts[2])),
                format("%02X", to!ubyte(guidParts[3])),
                format("%02X", to!ubyte(guidParts[4])),
                format("%02X", to!ubyte(guidParts[5])),
                format("%02X", to!ubyte(guidParts[6])),
                format("%02X", to!ubyte(guidParts[7])),
                format("%02X", to!ubyte(guidParts[8])),
                format("%02X", to!ubyte(guidParts[9])),
                format("%02X", to!ubyte(guidParts[10])),
                ];

            auto guidValue = guidPartsHex[0] 
                ~ "-" ~ guidPartsHex[1] 
                ~ "-" ~ guidPartsHex[2]
                ~ "-" ~ guidPartsHex[3] ~ guidPartsHex[4]
                ~ "-" ~ guidPartsHex[5 .. $].join();

            auto pidStr = strValue[idxCloseBr + 1 .. $];

            return "GUID(\"" ~ guidValue ~ "\")" ~ pidStr;
        case KnownConstantType.SID_IDENTIFIER_AUTHORITY:
            enforce(strValue.count('{') == 1, "ConstantAttribute: invalid SID_IDENTIFIER_AUTHORITY value: '{' count != 1");
            enforce(strValue.count('}') == 1, "ConstantAttribute: invalid SID_IDENTIFIER_AUTHORITY value: '}' count != 1");

            auto idxOpenBr = strValue.indexOf('{');
            auto idxCloseBr = strValue.indexOf('}');
            auto arrayStr = strValue[idxOpenBr + 1 .. idxCloseBr];
            return "[" ~ arrayStr ~ "]";
        case KnownConstantType.UNKNOWN:
            return strValue ~ "/* ConstantAttribute */";
    }
}
