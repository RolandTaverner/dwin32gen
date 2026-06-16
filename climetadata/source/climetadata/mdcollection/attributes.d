module climetadata.mdcollection.attributes;

import std.array : join;
import std.format: format;

public import climetadata.mdcollection.attributeprops;

public struct TypeAttributes
{
    @disable this();

    public this(uint bits)
    {
        this.bits = bits;
    }

    public TypeVisibility visibility() const
    {
        return cast(TypeVisibility)(bits & 0x7);
    }

    public TypeLayout layout() const
    {
        return cast(TypeLayout)(bits & 0x18);
    }

    public TypeSemantics semantics() const
    {
        return cast(TypeSemantics)(bits & 0x60);
    }

    public bool isAbstract() const
    {
        return (bits & 0x80) == 0x80;
    }

    public bool isSealed() const
    {
        return (bits & 0x100) == 0x100;
    }

    public bool hasSpecialName() const
    {
        return (bits & 0x400) == 0x400;
    }

    public bool isImport() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    public bool isSerializable() const
    {
        return (bits & 0x2000) == 0x2000;
    }

    public StringFormat format() const
    {
        return cast(StringFormat)(bits & 0x30000);
    }

    public bool beforeFieldInit() const
    {
        return (bits & 0x100000) == 0x100000;
    }

    public bool hasRuntimeSpecialName() const
    {
        return (bits & 0x800) == 0x800;
    }

    public bool hasSecurity() const
    {
        return (bits & 0x40000) == 0x40000;
    }

    public bool isTypeForwarder() const
    {
        return (bits & 0x200000) == 0x200000;
    }

    public bool isWindowsRuntime() const
    {
        return (bits & 0x4000) == 0x4000;
    }

    alias bits this;

    public const uint bits;
}

public struct FieldAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public MemberAccess access() const
    {
        return cast(MemberAccess)(bits & 0x7);
    }

    public bool isStatic() const
    {
        return (bits & 0x10) == 0x10;
    }

    public bool isInitOnly() const
    {
        return (bits & 0x20) == 0x20;
    }

    public bool isLiteral() const
    {
        return (bits & 0x40) == 0x40;
    }

    public bool dontSerialize() const
    {
        return (bits & 0x80) == 0x80;
    }

    public bool hasSpecialName() const
    {
        return (bits & 0x200) == 0x200;
    }

    public bool pInvokeImplemented() const
    {
        return (bits & 0x2000) == 0x2000;
    }

    public bool hasRuntimeSpecialName() const
    {
        return (bits & 0x400) == 0x400;
    }

    public bool hasFieldMarshal() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    public bool hasDefault() const
    {
        return (bits & 0x8000) == 0x8000;
    }

    public bool hasFieldRVA() const
    {
        return (bits & 0x100) == 0x100;
    }

    alias bits this;

    public const ushort bits;

    string toString() const
    {
        string[] props;
        props ~= format("%d", cast(uint)(access()));

        if (isStatic()) props ~= "isStatic";
        if (isInitOnly()) props ~= "isInitOnly";
        if (isLiteral()) props ~= "isLiteral";
        if (dontSerialize()) props ~= "dontSerialize";
        if (hasSpecialName()) props ~= "hasSpecialName";
        if (pInvokeImplemented()) props ~= "pInvokeImplemented";
        if (hasRuntimeSpecialName()) props ~= "hasRuntimeSpecialName";
        if (hasFieldMarshal()) props ~= "hasFieldMarshal";
        if (hasDefault()) props ~= "hasDefault";
        if (hasFieldRVA()) props ~= "hasFieldRVA";
        if (hasDefault()) props ~= "hasDefault";

        return props.join(", ");
    }
}

public struct MethodImplAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public CodeType codeType() const
    {
        return cast(CodeType)(bits & 0x03);
    }

    public bool isManaged() const
    {
        return (bits & 0x04) != 0x04;
    }

    public bool isForwardReference() const
    {
        return (bits & 0x10) == 0x10;
    }

    public bool preserveSignature() const
    {
        return (bits & 0x80) == 0x80;
    }

    public bool isInternalCall() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    public bool isSynchronized() const
    {
        return (bits & 0x20) == 0x20;
    }

    public bool dontInline() const
    {
        return (bits & 0x8) == 0x8;
    }

    alias bits this;

    public const ushort bits;
}

public struct MethodAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public MemberAccess access() const
    {
        return cast(MemberAccess)(bits & 0x7);
    }

    public bool isStatic() const
    {
        return (bits & 0x10) == 0x10;
    }

    public bool isFinal() const
    {
        return (bits & 0x20) == 0x20;
    }

    public bool isVirtual() const
    {
        return (bits & 0x40) == 0x40;
    }

    public bool hideBySig() const
    {
        return (bits & 0x80) == 0x80;
    }

    public bool reuseSlot() const
    {
        return (bits & 0x100) != 0x100;
    }

    public bool overrideAccess() const
    {
        return (bits & 0x200) == 0x200;
    }

    public bool isAbstract() const
    {
        return (bits & 0x400) == 0x400;
    }

    public bool hasSpecialName() const
    {
        return (bits & 0x800) == 0x800;
    }

    public bool pInvoke() const
    {
        return (bits & 0x2000) == 0x2000;
    }

    public bool hasRuntimeSpecialName() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    public bool hasSecurity() const
    {
        return (bits & 0x4000) == 0x4000;
    }

    public bool requiresSecurity() const
    {
        return (bits & 0x8000) == 0x8000;
    }

    alias bits this;

    public const ushort bits;
}

public struct ParamAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public MemberAccess access() const
    {
        return cast(MemberAccess)(bits & 0x7);
    }

    public bool isIn() const
    {
        return (bits & 0x01) == 0x01;
    }

    public bool isOut() const
    {
        return (bits & 0x02) == 0x02;
    }

    public bool isOptional() const
    {
        return (bits & 0x10) == 0x10;
    }

    public bool hasDefault() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    public bool hasFieldMarshal() const
    {
        return (bits & 0x2000) == 0x2000;
    }

    alias bits this;

    public const ushort bits;
}

public struct EventAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public bool hasSpecialName() const
    {
        return (bits & 0x0200) == 0x0200;
    }

    public bool hasRuntimeSpecialName() const
    {
        return (bits & 0x0400) == 0x0400;
    }

    alias bits this;

    public const ushort bits;
}

public struct PropertyAttributes
{
    @disable this();

    public this(ushort bits)
    {
        bits = bits;
    }

    public bool hasSpecialName() const
    {
        return (bits & 0x0200) == 0x0200;
    }

    public bool hasRuntimeSpecialName() const
    {
        return (bits & 0x0400) == 0x0400;
    }

    public bool hasDefault() const
    {
        return (bits & 0x1000) == 0x1000;
    }

    alias bits this;

    public const ushort bits;
}

public struct SemanticsAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public bool isSetter() const
    {
        return (bits & 0x0001) == 0x0001;
    }

    public bool isGetter() const
    {
        return (bits & 0x0002) == 0x0002;
    }

    public bool isOther() const
    {
        return (bits & 0x0004) == 0x0004;
    }

    public bool isAddOn() const
    {
        return (bits & 0x0008) == 0x0008;
    }

    public bool isRemoveOn() const
    {
        return (bits & 0x0010) == 0x0010;
    }

    public bool isFire() const
    {
        return (bits & 0x0020) == 0x0020;
    }

    alias bits this;

    public const ushort bits;
}

public struct PInvokeAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public PInvokeStringFormat stringFormat() const
    {
        return cast(PInvokeStringFormat)(bits & 0x6);
    }

    public BestFit bestFit() const
    {
        return cast(BestFit)(bits & 0x30);
    }

    public ThrowOnInvalidChar throwOnInvalidChar() const
    {
        return cast(ThrowOnInvalidChar)(bits & 0x3000);
    }

    public CallConv callConvention() const
    {
        return cast(CallConv)(bits & 0x0700);
    }

    public bool dontMangle() const
    {
        return (bits & 0x0001) == 0x0001;
    }

    public bool supportsLastError() const
    {
        return (bits & 0x0040) == 0x0040;
    }

    alias bits this;

    public const ushort bits;
}

public struct AssemblyAttributes
{
    @disable this();

    public this(uint bits)
    {
        this.bits = bits;
    }

    public AssemblyArch architecture() const
    {
        return cast(AssemblyArch)(bits & 0x70);
    }

    public bool hasPublicKey() const
    {
        return (bits & 0x0001) == 0x0001;
    }

    public bool disableTracking() const
    {
        return (bits & 0x8000) == 0x8000;
    }

    public bool disapleOptimization() const
    {
        return (bits & 0x4000) == 0x4000;
    }

    public bool isRetargetable() const
    {
        return (bits & 0x100) == 0x100;
    }

    public bool windowsRuntime() const
    {
        return (bits & 0x200) == 0x200;
    }

    alias bits this;

    public const uint bits;
}

public struct GenericAttributes
{
    @disable this();

    public this(ushort bits)
    {
        this.bits = bits;
    }

    public Variance variance() const
    {
        return cast(Variance)(bits & 0x03);
    }

    public Constraint constraint() const
    {
        return cast(Constraint)(bits & 0x1c);
    }

    alias bits this;

    public const ushort bits;
}
