module codegen.attributes.common;

import std.exception : enforce;
import std.format : format;
import std.typecons : nullable, Nullable;

import climetadata.mdcollection.attributeprops : SupportedArchitecture;
import climetadata.mdcollection.entitytypes : CustomAttributeEntity;
import climetadata.mdcollection.signature : ElementSig;

public struct CommonAttributes
{
    @disable this();

    public this(Range)(Range r)
    {
        supportedArchitecture = SupportedArchitecture.All;

        foreach(ca; r)
        {
            if (ca.name() == "SupportedArchitectureAttribute")
            {
                this.supportedArchitecture = getSupportedArchitectureAttribute(ca);
            }
            else if (ca.name() == "DocumentationAttribute")
            {
                documentation = getDocumentationAttribute(ca);
            }
            else if (ca.name() == "AnsiAttribute")
            {
                ansi = true;
            }
            else if (ca.name() == "UnicodeAttribute")
            {
                unicode = true;
            }
            else if (ca.name() == "ObsoleteAttribute")
            {
                obsolete = getObsoleteAttribute(ca);
            }
            else
            {
                unhandledAttributes ~= ca;
            }
        }
    }

    public SupportedArchitecture getSupportedArchitecture() const
    {
        return supportedArchitecture;
    }

    public string getDocumentation() const
    {
        return documentation;
    }

    public const(CustomAttributeEntity)[] getUnhandledAttributes() const
    {
        return unhandledAttributes;
    }

    public bool getAnsi() const
    {
        return ansi;
    }

    public bool getUnicode() const
    {
        return unicode;
    }

    public Nullable!string getObsolete() const
    {
        return obsolete;
    }

    private SupportedArchitecture supportedArchitecture;
    private string documentation;
    private const(CustomAttributeEntity)[] unhandledAttributes;
    private bool ansi;
    private bool unicode;
    private Nullable!string obsolete;
}

private SupportedArchitecture getSupportedArchitectureAttribute(scope ref const CustomAttributeEntity ca)
{
    assert(ca.name() == "SupportedArchitectureAttribute");
    auto sig = ca.value();
    
    enforce(sig.fixed.length == 1, format("SupportedArchitectureAttribute contains %s FixedArgSig elements, expected 1", sig.fixed.length));

    auto element = sig.fixed[0].value.peek!ElementSig;
    assert(element != null);
    
    auto value = element.value.peek!uint;
    enforce(value != null, "SupportedArchitectureAttribute: can't get uint value");
    
    return cast(SupportedArchitecture)(*value);
}

private string getDocumentationAttribute(scope ref const CustomAttributeEntity ca)
{
    assert(ca.name() == "DocumentationAttribute");
    auto sig = ca.value();

    enforce(sig.fixed.length == 1, format("DocumentationAttribute contains %s FixedArgSig elements, expected 1", sig.fixed.length));

    auto element = sig.fixed[0].value.peek!ElementSig;
    assert(element != null);

    auto value = element.value.peek!string;
    enforce(value != null, "DocumentationAttribute: can't get string value");

    return *value;
}

private Nullable!string getObsoleteAttribute(scope ref const CustomAttributeEntity ca)
{
    assert(ca.name() == "ObsoleteAttribute");
    auto sig = ca.value();
    
    if (sig.fixed.length == 0)
    {
        return nullable("");
    }

    auto element = sig.fixed[0].value.peek!ElementSig;
    assert(element != null);
    
    auto value = element.value.peek!string;
    enforce(value != null, "ObsoleteAttribute: can't get string value");

    return nullable(*value);
}
