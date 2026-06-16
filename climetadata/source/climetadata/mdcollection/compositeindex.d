module climetadata.mdcollection.compositeindex;

public import std.variant : Algebraic;
public import climetadata.mdcollection.entitytypes;
import climetadata.mdcollection.bits;
import climetadata.mdcollection.database : Database;
import climetadata.mdtable.type;

struct CompositeIndex(CodedIndexType)
{
    public const uint codedIndex;

    public this(uint codedIndex)
    {
        this.codedIndex = codedIndex;
    }

    public this(uint decodedIndex, CodedIndexType value)
    {
        this.codedIndex = (decodedIndex << indexBits!CodedIndexType) | value;
    }

    public uint index() const
    {
        return codedIndex >> indexBits!CodedIndexType;
    }

    public CodedIndexType type() const
    {
        return cast(CodedIndexType)(codedIndex & ((1 << indexBits!CodedIndexType) - 1));
    }
}

// Refer to Common Language Infrastructure (CLI), Partition II: Metadata Definition and Semantics, II.24.2.6 #~ stream
// Order of enum values must be preserved !!!

//=============================================================================
// TypeDefOrRef coded index

@Bits(2)
enum TypeDefOrRef
{
    typeDef,
    typeRef,
    typeSpec,
}

public alias TypeDefOrRefValue = Algebraic!(TypeDefEntity, TypeRefEntity, TypeSpecEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == TypeDefOrRef))
{
    alias CodedIndexValueType = TypeDefOrRefValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == TypeDefOrRef)) 
{
    final switch (codedIndex.type())
    {
        case TypeDefOrRef.typeDef: return TypeDefOrRefValue(db.getCollection!(MDTableType.typeDef)[codedIndex.index()]);
        case TypeDefOrRef.typeRef: return TypeDefOrRefValue(db.getCollection!(MDTableType.typeRef)[codedIndex.index()]);
        case TypeDefOrRef.typeSpec: return TypeDefOrRefValue(db.getCollection!(MDTableType.typeSpec)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == TypeDefOrRef)) 
{
    static if (md == MDTableType.typeDef) alias getCodedIndexMember = TypeDefOrRef.typeDef;
    else static if (md == MDTableType.typeRef) alias getCodedIndexMember = TypeDefOrRef.typeRef;
    else static if (md == MDTableType.typeSpec) alias getCodedIndexMember = TypeDefOrRef.typeSpec;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(TypeDefOrRef) == TypeDefOrRefValue));
}

//=============================================================================
// HasConstant coded index

@Bits(2)
enum HasConstant
{
    field,
    param,
    property,
}

public alias HasConstantValue = Algebraic!(FieldEntity, ParamEntity, PropertyEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == HasConstant))
{
    alias CodedIndexValueType = HasConstantValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == HasConstant)) 
{
    final switch (codedIndex.type())
    {
        case HasConstant.field: return HasConstantValue(db.getCollection!(MDTableType.field)[codedIndex.index()]);
        case HasConstant.param: return HasConstantValue(db.getCollection!(MDTableType.param)[codedIndex.index()]);
        case HasConstant.property: return HasConstantValue(db.getCollection!(MDTableType.property)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == HasConstant)) 
{
    static if (md == MDTableType.field) alias getCodedIndexMember = HasConstant.field;
    else static if (md == MDTableType.param) alias getCodedIndexMember = HasConstant.param;
    else static if (md == MDTableType.property) alias getCodedIndexMember = HasConstant.property;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(HasConstant) == HasConstantValue));
}

//=============================================================================
// HasCustomAttribute coded index

@Bits(5)
enum HasCustomAttribute
{
    methodDef,
    field,
    typeRef,
    typeDef,
    param,
    interfaceImpl,
    memberRef,
    module_,
    permission,
    property,
    event,
    standAloneSig,
    moduleRef,
    typeSpec,
    assembly,
    assemblyRef,
    file,
    exportedType,
    manifestResource,
    genericParam,
    genericParamConstraint,
    methodSpec,
}

public alias HasCustomAttributeValue = Algebraic!(
    MethodDefEntity, FieldEntity, TypeRefEntity, TypeDefEntity, ParamEntity, InterfaceImplEntity, MemberRefEntity,
    ModuleEntity, DeclSecurityEntity, PropertyEntity, EventEntity, StandAloneSigEntity, ModuleRefEntity,
    TypeSpecEntity, AssemblyEntity, AssemblyRefEntity, FileEntity, ExportedTypeEntity, ManifestResourceEntity,
    GenericParamEntity, GenericParamConstraintEntity, MethodSpecEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == HasCustomAttribute))
{
    alias CodedIndexValueType = HasCustomAttributeValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == HasCustomAttribute)) 
{
    final switch (codedIndex.type())
    {
        case HasCustomAttribute.methodDef: return HasCustomAttributeValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
        case HasCustomAttribute.field: return HasCustomAttributeValue(db.getCollection!(MDTableType.field)[codedIndex.index()]);
        case HasCustomAttribute.typeRef: return HasCustomAttributeValue(db.getCollection!(MDTableType.typeRef)[codedIndex.index()]);
        case HasCustomAttribute.typeDef: return HasCustomAttributeValue(db.getCollection!(MDTableType.typeDef)[codedIndex.index()]);
        case HasCustomAttribute.param: return HasCustomAttributeValue(db.getCollection!(MDTableType.param)[codedIndex.index()]);
        case HasCustomAttribute.interfaceImpl: return HasCustomAttributeValue(db.getCollection!(MDTableType.interfaceImpl)[codedIndex.index()]);
        case HasCustomAttribute.memberRef: return HasCustomAttributeValue(db.getCollection!(MDTableType.memberRef)[codedIndex.index()]);
        case HasCustomAttribute.module_: return HasCustomAttributeValue(db.getCollection!(MDTableType.module_)[codedIndex.index()]);
        case HasCustomAttribute.permission: return HasCustomAttributeValue(db.getCollection!(MDTableType.declSecurity)[codedIndex.index()]);
        case HasCustomAttribute.property: return HasCustomAttributeValue(db.getCollection!(MDTableType.property)[codedIndex.index()]);
        case HasCustomAttribute.event: return HasCustomAttributeValue(db.getCollection!(MDTableType.event)[codedIndex.index()]);
        case HasCustomAttribute.standAloneSig: return HasCustomAttributeValue(db.getCollection!(MDTableType.standAloneSig)[codedIndex.index()]);
        case HasCustomAttribute.moduleRef: return HasCustomAttributeValue(db.getCollection!(MDTableType.moduleRef)[codedIndex.index()]);
        case HasCustomAttribute.typeSpec: return HasCustomAttributeValue(db.getCollection!(MDTableType.typeSpec)[codedIndex.index()]);
        case HasCustomAttribute.assembly: return HasCustomAttributeValue(db.getCollection!(MDTableType.assembly)[codedIndex.index()]);
        case HasCustomAttribute.assemblyRef: return HasCustomAttributeValue(db.getCollection!(MDTableType.assemblyRef)[codedIndex.index()]);
        case HasCustomAttribute.file: return HasCustomAttributeValue(db.getCollection!(MDTableType.file)[codedIndex.index()]);
        case HasCustomAttribute.exportedType: return HasCustomAttributeValue(db.getCollection!(MDTableType.exportedType)[codedIndex.index()]);
        case HasCustomAttribute.manifestResource: return HasCustomAttributeValue(db.getCollection!(MDTableType.manifestResource)[codedIndex.index()]);
        case HasCustomAttribute.genericParam: return HasCustomAttributeValue(db.getCollection!(MDTableType.genericParam)[codedIndex.index()]);
        case HasCustomAttribute.genericParamConstraint: return HasCustomAttributeValue(db.getCollection!(MDTableType.genericParamConstraint)[codedIndex.index()]);
        case HasCustomAttribute.methodSpec: return HasCustomAttributeValue(db.getCollection!(MDTableType.methodSpec)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == HasCustomAttribute)) 
{
    static if (md == MDTableType.methodDef) alias getCodedIndexMember = HasCustomAttribute.methodDef;
    else static if (md == MDTableType.field) alias getCodedIndexMember = HasCustomAttribute.field;
    else static if (md == MDTableType.typeRef) alias getCodedIndexMember = HasCustomAttribute.typeRef;
    else static if (md == MDTableType.typeDef) alias getCodedIndexMember = HasCustomAttribute.typeDef;
    else static if (md == MDTableType.param) alias getCodedIndexMember = HasCustomAttribute.param;
    else static if (md == MDTableType.interfaceImpl) alias getCodedIndexMember = HasCustomAttribute.interfaceImpl;
    else static if (md == MDTableType.memberRef) alias getCodedIndexMember = HasCustomAttribute.memberRef;
    else static if (md == MDTableType.module_) alias getCodedIndexMember = HasCustomAttribute.module_;
    else static if (md == MDTableType.declSecurity) alias getCodedIndexMember = HasCustomAttribute.permission;
    else static if (md == MDTableType.property) alias getCodedIndexMember = HasCustomAttribute.property;
    else static if (md == MDTableType.event) alias getCodedIndexMember = HasCustomAttribute.event;
    else static if (md == MDTableType.standAloneSig) alias getCodedIndexMember = HasCustomAttribute.standAloneSig;
    else static if (md == MDTableType.moduleRef) alias getCodedIndexMember = HasCustomAttribute.moduleRef;
    else static if (md == MDTableType.typeSpec) alias getCodedIndexMember = HasCustomAttribute.typeSpec;
    else static if (md == MDTableType.assembly) alias getCodedIndexMember = HasCustomAttribute.assembly;
    else static if (md == MDTableType.assemblyRef) alias getCodedIndexMember = HasCustomAttribute.assemblyRef;
    else static if (md == MDTableType.file) alias getCodedIndexMember = HasCustomAttribute.file;
    else static if (md == MDTableType.exportedType) alias getCodedIndexMember = HasCustomAttribute.exportedType;
    else static if (md == MDTableType.manifestResource) alias getCodedIndexMember = HasCustomAttribute.manifestResource;
    else static if (md == MDTableType.genericParam) alias getCodedIndexMember = HasCustomAttribute.genericParam;
    else static if (md == MDTableType.genericParamConstraint) alias getCodedIndexMember = HasCustomAttribute.genericParamConstraint;
    else static if (md == MDTableType.methodSpec) alias getCodedIndexMember = HasCustomAttribute.methodSpec;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(HasCustomAttribute) == HasCustomAttributeValue));
}

//=============================================================================
// HasFieldMarshal coded index

@Bits(1)
enum HasFieldMarshal
{
    field,
    param,
}

public alias HasFieldMarshalValue = Algebraic!(FieldEntity, ParamEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == HasFieldMarshal))
{
    alias CodedIndexValueType = HasFieldMarshalValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == HasFieldMarshal)) 
{
    final switch (codedIndex.type())
    {
        case HasFieldMarshal.field: return HasFieldMarshalValue(db.getCollection!(MDTableType.field)[codedIndex.index()]);
        case HasFieldMarshal.param: return HasFieldMarshalValue(db.getCollection!(MDTableType.param)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == HasFieldMarshal)) 
{
    static if (md == MDTableType.field) alias getCodedIndexMember = HasFieldMarshal.field;
    else static if (md == MDTableType.param) alias getCodedIndexMember = HasFieldMarshal.param;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(HasFieldMarshal) == HasFieldMarshalValue));
}

//=============================================================================
// HasDeclSecurity coded index

@Bits(2)
enum HasDeclSecurity
{
    typeDef,
    methodDef,
    assembly,
}

public alias HasDeclSecurityValue = Algebraic!(TypeDefEntity, MethodDefEntity, AssemblyEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == HasDeclSecurity))
{
    alias CodedIndexValueType = HasDeclSecurityValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == HasDeclSecurity)) 
{
    final switch (codedIndex.type())
    {
        case HasDeclSecurity.typeDef: return HasDeclSecurityValue(db.getCollection!(MDTableType.typeDef)[codedIndex.index()]);
        case HasDeclSecurity.methodDef: return HasDeclSecurityValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
        case HasDeclSecurity.assembly: return HasDeclSecurityValue(db.getCollection!(MDTableType.assembly)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == HasDeclSecurity)) 
{
    static if (md == MDTableType.typeDef) alias getCodedIndexMember = HasDeclSecurity.typeDef;
    else static if (md == MDTableType.methodDef) alias getCodedIndexMember = HasDeclSecurity.methodDef;
    else static if (md == MDTableType.assembly) alias getCodedIndexMember = HasDeclSecurity.assembly;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(HasDeclSecurity) == HasDeclSecurityValue));
}

//=============================================================================
// MemberRefParent coded index

@Bits(3)
enum MemberRefParent
{
    typeDef,
    typeRef,
    moduleRef,
    methodDef,
    typeSpec,
}

public alias MemberRefParentValue = Algebraic!(TypeDefEntity, TypeRefEntity, ModuleRefEntity, MethodDefEntity, TypeSpecEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == MemberRefParent))
{
    alias CodedIndexValueType = MemberRefParentValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == MemberRefParent)) 
{
    final switch (codedIndex.type())
    {
        case MemberRefParent.typeDef: return MemberRefParentValue(db.getCollection!(MDTableType.typeDef)[codedIndex.index()]);
        case MemberRefParent.typeRef: return MemberRefParentValue(db.getCollection!(MDTableType.typeRef)[codedIndex.index()]);
        case MemberRefParent.moduleRef: return MemberRefParentValue(db.getCollection!(MDTableType.moduleRef)[codedIndex.index()]);
        case MemberRefParent.methodDef: return MemberRefParentValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
        case MemberRefParent.typeSpec: return MemberRefParentValue(db.getCollection!(MDTableType.typeSpec)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == MemberRefParent)) 
{
    static if (md == MDTableType.typeDef) alias getCodedIndexMember = MemberRefParent.typeDef;
    else static if (md == MDTableType.typeRef) alias getCodedIndexMember = MemberRefParent.typeRef;
    else static if (md == MDTableType.moduleRef) alias getCodedIndexMember = MemberRefParent.moduleRef;
    else static if (md == MDTableType.methodDef) alias getCodedIndexMember = MemberRefParent.methodDef;
    else static if (md == MDTableType.typeSpec) alias getCodedIndexMember = MemberRefParent.typeSpec;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(MemberRefParent) == MemberRefParentValue));
}

//=============================================================================
// HasSemantics coded index

@Bits(1)
enum HasSemantics
{
    event,
    property,
}

public alias HasSemanticsValue = Algebraic!(EventEntity, PropertyEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == HasSemantics))
{
    alias CodedIndexValueType = HasSemanticsValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == HasSemantics)) 
{
    final switch (codedIndex.type())
    {
        case HasSemantics.event: return HasSemanticsValue(db.getCollection!(MDTableType.event)[codedIndex.index()]);
        case HasSemantics.property: return HasSemanticsValue(db.getCollection!(MDTableType.property)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == HasSemantics)) 
{
    static if (md == MDTableType.event) alias getCodedIndexMember = HasSemantics.event;
    else static if (md == MDTableType.property) alias getCodedIndexMember = HasSemantics.property;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(HasSemantics) == HasSemanticsValue));
}

//=============================================================================
// MethodDefOrRef coded index

@Bits(1)
enum MethodDefOrRef
{
    methodDef,
    memberRef,
}

public alias MethodDefOrRefValue = Algebraic!(MethodDefEntity, MemberRefEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == MethodDefOrRef))
{
    alias CodedIndexValueType = MethodDefOrRefValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == MethodDefOrRef)) 
{
    final switch (codedIndex.type())
    {
        case MethodDefOrRef.methodDef: return MethodDefOrRefValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
        case MethodDefOrRef.memberRef: return MethodDefOrRefValue(db.getCollection!(MDTableType.memberRef)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == MethodDefOrRef)) 
{
    static if (md == MDTableType.methodDef) alias getCodedIndexMember = MethodDefOrRef.methodDef;
    else static if (md == MDTableType.memberRef) alias getCodedIndexMember = MethodDefOrRef.memberRef;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(MethodDefOrRef) == MethodDefOrRefValue));
}

//=============================================================================
// MemberForwarded coded index

@Bits(1)
enum MemberForwarded
{
    field,
    methodDef,
}

public alias MemberForwardedValue = Algebraic!(FieldEntity, MethodDefEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == MemberForwarded))
{
    alias CodedIndexValueType = MemberForwardedValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == MemberForwarded)) 
{
    final switch (codedIndex.type())
    {
        case MemberForwarded.field: return MemberForwardedValue(db.getCollection!(MDTableType.field)[codedIndex.index()]);
        case MemberForwarded.methodDef: return MemberForwardedValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == MemberForwarded)) 
{
    static if (md == MDTableType.field) alias getCodedIndexMember = MemberForwarded.field;
    else static if (md == MDTableType.methodDef) alias getCodedIndexMember = MemberForwarded.methodDef;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(MemberForwarded) == MemberForwardedValue));
}

//=============================================================================
// Implementation coded index

@Bits(2)
enum Implementation
{
    file,
    assemblyRef,
    exportedType,
}

public alias ImplementationValue = Algebraic!(FileEntity, AssemblyRefEntity, ExportedTypeEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == Implementation))
{
    alias CodedIndexValueType = ImplementationValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == Implementation)) 
{
    final switch (codedIndex.type())
    {
        case Implementation.file: return ImplementationValue(db.getCollection!(MDTableType.file)[codedIndex.index()]);
        case Implementation.assemblyRef: return ImplementationValue(db.getCollection!(MDTableType.assemblyRef)[codedIndex.index()]);
        case Implementation.exportedType: return ImplementationValue(db.getCollection!(MDTableType.exportedType)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == Implementation)) 
{
    static if (md == MDTableType.file) alias getCodedIndexMember = Implementation.file;
    else static if (md == MDTableType.assemblyRef) alias getCodedIndexMember = Implementation.assemblyRef;
    else static if (md == MDTableType.exportedType) alias getCodedIndexMember = Implementation.exportedType;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(Implementation) == ImplementationValue));
}

//=============================================================================
// CustomAttributeType coded index

@Bits(3)
enum CustomAttributeType
{
    __notUsed1,
    __notUsed2,
    methodDef,
    memberRef,
    __notUsed3,
}

public alias CustomAttributeTypeValue = Algebraic!(MethodDefEntity, MemberRefEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == CustomAttributeType))
{
    alias CodedIndexValueType = CustomAttributeTypeValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == CustomAttributeType)) 
{
    final switch (codedIndex.type())
    {
        case CustomAttributeType.methodDef: return CustomAttributeTypeValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
        case CustomAttributeType.memberRef: return CustomAttributeTypeValue(db.getCollection!(MDTableType.memberRef)[codedIndex.index()]);
        case CustomAttributeType.__notUsed1, CustomAttributeType.__notUsed2, CustomAttributeType.__notUsed3:
            assert(false, "invalid member of CustomAttributeType coded index");
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == CustomAttributeType)) 
{
    static if (md == MDTableType.methodDef) alias getCodedIndexMember = CustomAttributeType.methodDef;
    else static if (md == MDTableType.memberRef) alias getCodedIndexMember = CustomAttributeType.memberRef;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(CustomAttributeType) == CustomAttributeTypeValue));
}

//=============================================================================
// ResolutionScope coded index

@Bits(2)
enum ResolutionScope
{
    module_,
    moduleRef,
    assemblyRef,
    typeRef,
}

public alias ResolutionScopeValue = Algebraic!(ModuleEntity, ModuleRefEntity, AssemblyRefEntity, TypeRefEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == ResolutionScope))
{
    alias CodedIndexValueType = ResolutionScopeValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == ResolutionScope)) 
{
    final switch (codedIndex.type())
    {
        case ResolutionScope.module_: return ResolutionScopeValue(db.getCollection!(MDTableType.module_)[codedIndex.index()]);
        case ResolutionScope.moduleRef: return ResolutionScopeValue(db.getCollection!(MDTableType.moduleRef)[codedIndex.index()]);
        case ResolutionScope.assemblyRef: return ResolutionScopeValue(db.getCollection!(MDTableType.assemblyRef)[codedIndex.index()]);
        case ResolutionScope.typeRef: return ResolutionScopeValue(db.getCollection!(MDTableType.typeRef)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == ResolutionScope)) 
{
    static if (md == MDTableType.module_) alias getCodedIndexMember = ResolutionScope.module_;
    else static if (md == MDTableType.moduleRef) alias getCodedIndexMember = ResolutionScope.moduleRef;
    else static if (md == MDTableType.assemblyRef) alias getCodedIndexMember = ResolutionScope.assemblyRef;
    else static if (md == MDTableType.typeRef) alias getCodedIndexMember = ResolutionScope.typeRef;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(ResolutionScope) == ResolutionScopeValue));
}

//=============================================================================
// TypeOrMethodDef coded index

@Bits(1)
enum TypeOrMethodDef
{
    typeDef,
    methodDef,
}

public alias TypeOrMethodDefValue = Algebraic!(TypeDefEntity, MethodDefEntity);

public template CodedIndexValueType(CodedIndexType) if (is(CodedIndexType == TypeOrMethodDef))
{
    alias CodedIndexValueType = TypeOrMethodDefValue;
}

public CodedIndexValueType!(CodedIndexType) getCodedIndexValue(CodedIndexType)(const Database* db, 
    in CompositeIndex!(CodedIndexType) codedIndex) 
if (is(CodedIndexType == TypeOrMethodDef)) 
{
    final switch (codedIndex.type())
    {
        case TypeOrMethodDef.typeDef: return TypeOrMethodDefValue(db.getCollection!(MDTableType.typeDef)[codedIndex.index()]);
        case TypeOrMethodDef.methodDef: return TypeOrMethodDefValue(db.getCollection!(MDTableType.methodDef)[codedIndex.index()]);
    }
}

public template getCodedIndexMember(CodedIndexType, MDTableType md) if (is(CodedIndexType == TypeOrMethodDef)) 
{
    static if (md == MDTableType.typeDef) alias getCodedIndexMember = TypeOrMethodDef.typeDef;
    else static if (md == MDTableType.methodDef) alias getCodedIndexMember = TypeOrMethodDef.methodDef;
    else static assert(false, "Invalid MDTableType");
}

unittest
{
    static assert (is(CodedIndexValueType!(TypeOrMethodDef) == TypeOrMethodDefValue));
}
