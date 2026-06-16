module climetadata.mdcollection.attributeprops;

// sig
public enum UnmanagedType
{
    bool_ = 2,
    i1 = 3,
    u1 = 4,
    i2 = 5,
    u2 = 6,
    I4 = 7,
    u4 = 8,
    i8 = 9,
    u8 = 10,
    r4 = 11,
    r8 = 12,
    currency = 15,
    bStr = 19,
    lpStr = 20,
    lpwStr = 21,
    lptStr = 22,
    byValTStr = 23,
    iUnknown = 25,
    iDispatch = 26,
    struct_ = 27,
    interface_ = 28,
    safeArray = 29,
    byValArray = 30,
    sysInt = 31,
    sysUInt = 32,
    vbByRefStr = 34,
    ansiBStr = 35,
    tBStr = 36,
    variantBool = 37,
    functionPtr = 38,
    asAny = 40,
    lpArray = 42,
    lpStruct = 43,
    customMarshaler = 44,
    error = 45,
    iInspectable = 46,
    hString = 47,
    lpUTF8Str = 48,
}

public enum MemberAccess : ushort
{
    CompilerControlled = 0x0000,
    Private = 0x0001,
    FamAndAssem = 0x0002,
    Assembly = 0x0003,
    Family = 0x0004,
    FamOrAssem = 0x0005,
    Public = 0x0006,
}

public enum TypeVisibility
{
    NotPublic = 0x00000000,
    Public = 0x00000001,
    NestedPublic = 0x00000002,
    NestedPrivate = 0x00000003,
    NestedFamily = 0x00000004,
    NestedAssembly = 0x00000005,
    NestedFamANDAssem = 0x00000006,
    NestedFamORAssem = 0x00000007,
}

public enum ManifestVisibility : uint
{
    none = 0x0000,
    public_ = 0x0001,
    private_ = 0x0002,
}

public enum TypeLayout
{
    autoLayout = 0x00000000,
    sequentialLayout = 0x00000008,
    explicitLayout = 0x00000010,
}

public enum TypeSemantics
{
    class_ = 0x00000000,
    interface_ = 0x00000020,
}

public enum StringFormat
{
    AnsiClass = 0x00000000,
    UnicodeClass = 0x00010000,
    AutoClass = 0x00020000,
    CustomFormatClass = 0x00030000,
    CustomFormatMask = 0x00C00000,
}

public enum PInvokeStringFormat : ushort
{
    notSpecified = 0x0000,
    ansi = 0x0002,
    unicode = 0x0004,
    auto_ = 0x0006,
}

public enum BestFit : ushort
{
    useAssembly = 0x0000,
    enabled = 0x0010,
    disabled = 0x0020,
}

public enum ThrowOnInvalidChar : ushort
{
    useAssembly = 0x0000,
    enabled = 0x1000,
    disabled = 0x2000,
}

public enum CallConv : ushort
{
    winapi = 0x0100,
    cdecl = 0x0200,
    stdcall = 0x0300,
    thiscall = 0x0400,
    fastcall = 0x0500,
}

public enum CodeType : ushort
{
    IL = 0x0000,
    Native = 0x0001,
    OPTIL = 0x0002,
    Runtime = 0x0003,
}

public enum Managed : ushort
{
    Unmanaged = 0x0004,
    Managed = 0x0000,
}

public enum TableLayout : ushort
{
    ReuseSlot = 0x0000,
    NewSlot = 0x0100,
}

public enum GenericParamVariance : ushort
{
    None = 0x0000,
    Covariant = 0x0001,
    ContraVariant = 0x0002,
}

public enum GenericParamSpecialConstraint : ushort
{
    ReferenceTypeConstraint = 0x0004,
    NotNullableValueTypeConstraint = 0x0008,
    DefaultConstructorConstraint = 0x0010,
}

public enum ConstantType : ushort
{
    boolean = 0x02,
    char_ = 0x03,
    int8 = 0x04,
    uint8 = 0x05,
    int16 = 0x06,
    uint16 = 0x07,
    int32 = 0x08,
    uint32 = 0x09,
    int64 = 0x0a,
    uint64 = 0x0b,
    float32 = 0x0c,
    float64 = 0x0d,
    string = 0x0e,
    class_ = 0x12
}

public enum AssemblyHashAlgorithm
{
    None = 0x0000,
    Reserved_MD5 = 0x8003,
    SHA1 = 0x8004,
}

public enum AssemblyArch : uint
{
    none = 0x0000,
    msil = 0x0010,
    x86 = 0x0020,
    ia64 = 0x0030,
    amd64 = 0x0040,
}

public enum SecurityAction : ushort
{
    demand = 0x0002,
    assert_ = 0x0003,
    deny = 0x0004,
    permitOnly = 0x0005,
    linkDemand = 0x0006,
    inheritanceDemand = 0x0007,
    requestMinimum = 0x0008,
    requestOptional = 0x0009,
    requestRefuse = 0x0010,
}

public struct AssemblyVersion
{
    ushort majorVersion;
    ushort minorVersion;
    ushort buildNumber;
    ushort revisionNumber;
}

public enum Variance : ushort
{
    nonVariant = 0x0000,
    coVariant = 0x0001,
    contraVariant = 0x0002,
}

public enum Constraint : ushort
{
    special = 0x0000,
    reference = 0x0004,
    notNullable = 0x0008,
    defaultConstructor = 0x0010
}

// SupportedArchitectureAttribute CustomAttribute
public enum SupportedArchitecture : uint
{
    None = 0x00,
    X86 = 0x01,
    X64 = 0x02,
    Arm64 = 0x04,
    All = X64 | X86 | Arm64
}
