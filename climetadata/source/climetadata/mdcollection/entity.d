module climetadata.mdcollection.entity;

import std.exception : enforce;
import std.typecons : Nullable;
public import std.uuid : UUID;

import climetadata.mdcollection.attributes;
import climetadata.mdcollection.collection : CollectionListEnumerator, CollectionRangeEnumerator, CollectionAllEnumerator, CollectionCodedIndexRangeEnumerator;
import climetadata.mdcollection.compositeindex;
import climetadata.mdcollection.database : Database;
import climetadata.mdcollection.signature;
import climetadata.mdtable.heaps : Heaps;
import climetadata.mdtable.row : Row;
import climetadata.mdtable.table : emptyList, getNextRow, isLastRow, TableRangeEnumerator, TableAllEnumerator, TableCodedIndexRangeEnumerator;
import climetadata.mdtable.type;
import climetadata.mdtable.value;
import climetadata.utils.memcast;

public struct Entity(MDTableType md)
{
    @disable this();

    public this(in Row!md row, const Database* db)
    {
        this.row = row;
        this.db = db;
    }

    static if (md == MDTableType.module_)
    {
        mixin moduleFieldGetters!();
        mixin moduleFieldGettersExtra!();
    } 
    else static if (md == MDTableType.typeRef)
    {
        mixin typeRefFieldGetters!();
        mixin typeRefFieldGettersExtra!();
    }
    else static if (md == MDTableType.typeDef)
    {
        mixin typeDefFieldGetters!();
        mixin typeDefFieldGettersExtra!();
    }
    else static if (md == MDTableType.field)
    {
        mixin fieldFieldGetters!();
        mixin fieldFieldGettersExtra!();
    }
    else static if (md == MDTableType.methodDef)
    {
        mixin methodDefFieldGetters!();
        mixin methodDefFieldGettersExtra!();
    }
    else static if (md == MDTableType.param)
    {
        mixin paramFieldGetters!();
        mixin paramFieldGettersExtra!();
    }
    else static if (md == MDTableType.interfaceImpl)
    {
        mixin interfaceImplFieldGetters!();
        mixin interfaceImplFieldGettersExtra!();
    }
    else static if (md == MDTableType.memberRef)
    {
        mixin memberRefFieldGetters!();
        mixin memberRefFieldGettersExtra!();
    }
    else static if (md == MDTableType.constant)
    {
        mixin constantFieldGetters!();
        mixin constantFieldGettersExtra!();
    }
    else static if (md == MDTableType.customAttribute)
    {
        mixin customAttributeFieldGetters!();
        mixin customAttributeFieldGettersExtra!();
    }
    else static if (md == MDTableType.fieldMarshal)
    {
        mixin fieldMarshalFieldGetters!();
    }
    else static if (md == MDTableType.declSecurity)
    {
        mixin declSecurityFieldGetters!();
    }
    else static if (md == MDTableType.classLayout)
    {
        mixin classLayoutFieldGetters!();
    }
    else static if (md == MDTableType.fieldLayout)
    {
        mixin fieldLayoutFieldGetters!();
    }
    else static if (md == MDTableType.standAloneSig)
    {
        mixin standAloneSigFieldGetters!();
        mixin standAloneSigFieldGettersExtra!();
    }
    else static if (md == MDTableType.eventMap)
    {
        mixin eventMapFieldGetters!();
    }
    else static if (md == MDTableType.event)
    {
        mixin eventFieldGetters!();
        mixin eventFieldGettersExtra!();
    }
    else static if (md == MDTableType.propertyMap)
    {
        mixin propertyMapFieldGetters!();
    }
    else static if (md == MDTableType.property)
    {
        mixin propertyFieldGetters!();
        mixin propertyFieldGettersExtra!();
    }
    else static if (md == MDTableType.methodSemantics)
    {
        mixin methodSemanticsFieldGetters!();
    }
    else static if (md == MDTableType.methodImpl)
    {
        mixin methodImplFieldGetters!();
    }
    else static if (md == MDTableType.moduleRef)
    {
        mixin moduleRefFieldGetters!();
    }
    else static if (md == MDTableType.typeSpec)
    {
        mixin typeSpecFieldGetters!();
    }
    else static if (md == MDTableType.implMap)
    {
        mixin implMapFieldGetters!();
    }
    else static if (md == MDTableType.fieldRVA)
    {
        mixin fieldRVAFieldGetters!();
    }
    else static if (md == MDTableType.assembly)
    {
        mixin assemblyFieldGetters!();
    }
    else static if (md == MDTableType.assemblyProcessor)
    {
        mixin assemblyProcessorFieldGetters!();
    }
    else static if (md == MDTableType.assemblyOS)
    {
        mixin assemblyOSFieldGetters!();
    }
    else static if (md == MDTableType.assemblyRef)
    {
        mixin assemblyRefFieldGetters!();
    }
    else static if (md == MDTableType.assemblyRefProcessor)
    {
        mixin assemblyRefProcessorFieldGetters!();
    }
    else static if (md == MDTableType.assemblyRefOS)
    {
        mixin assemblyRefOSFieldGetters!();
    }
    else static if (md == MDTableType.file)
    {
        mixin fileFieldGetters!();
    }
    else static if (md == MDTableType.exportedType)
    {
        mixin exportedTypeFieldGetters!();
        mixin exportedTypeFieldGettersExtra!();
    }
    else static if (md == MDTableType.manifestResource)
    {
        mixin manifestResourceFieldGetters!();
    }
    else static if (md == MDTableType.nestedClass)
    {
        mixin nestedClassFieldGetters!();
    }
    else static if (md == MDTableType.genericParam)
    {
        mixin genericParamFieldGetters!();
    }
    else static if (md == MDTableType.methodSpec)
    {
        mixin methodSpecFieldGetters!();
    }
    else static if (md == MDTableType.genericParamConstraint)
    {
        mixin genericParamConstraintFieldGetters!();
    }

    pragma(inline, true)
    public bool isNull() const
    {
        return row.isNull();
    }

    @safe pure nothrow
    public bool opEquals()(auto ref const Entity!md other) const
    {
        return this.row == other.row;
    }

    @safe pure nothrow
    public int opCmp(ref const Entity!md other) const
    {
        if (this.row > other.row)
            return 1;
        if (this.row < other.row)
            return -1;
        return 0;
    }

    @safe pure nothrow
    public size_t toHash() const
    {
        return row.toHash();
    }

    public alias TableType = md;

    public uint getRowID() const
    {
        return row.getRowID();
    }

    // public ref const(Row!md) getRow() const
    // {
    //     return row;
    // }

private:
    const Row!md row;
    const Database* db;
}

//=============================================================================
// module entity getters

private mixin template moduleFieldGetters()
{
    //mixin DeclSimpleField!(MDTableType.module_, "Unused");
    mixin DeclSimpleField!(MDTableType.module_, "Name");
    mixin DeclSimpleField!(MDTableType.module_, "Mvid");
    mixin DeclSimpleField!(MDTableType.module_, "EncId");
    mixin DeclSimpleField!(MDTableType.module_, "EncBaseId");
}

// Extra props

private mixin template moduleFieldGettersExtra()
{
}

mixin DeclCodedIndexRangeProp!(MDTableType.module_, "Attributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// typeRef entity getters

private mixin template typeRefFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.typeRef, "TypeName");
    mixin DeclSimpleField!(MDTableType.typeRef, "TypeNamespace");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.typeRef, "ResolutionScope", ResolutionScope); // ModuleEntity, ModuleRefEntity, AssemblyRefEntity, TypeRefEntity

// Extra props

private mixin template typeRefFieldGettersExtra()
{
    // Nullable!TypeDefEntity resolve() const
    // {
    //     auto resolutionScope = getResolutionScope(this);
    //     if (auto m = resolutionScope.peek!ModuleEntity)
    //     {
    //         return db.typeDefCollection.findByName(getTypeNamespace(), getTypeName());
    //     }
    //     else if (auto tr = resolutionScope.peek!TypeRefEntity)
    //     {
    //         auto parent = tr.resolve();
    //         if (parent.isNull)
    //         {
    //             return parent;
    //         }
            
    //         foreach(n; parent.get.getAllNestedClassByEnclosing())
    //         {
    //             if (n.getNestedClass().getTypeName() == this.getTypeName())
    //             {
    //                 return Nullable!TypeDefEntity(n.getNestedClass());
    //             }
    //         }
    //     }

    //     return (Nullable!TypeDefEntity).init;
    // }

    Nullable!TypeDefEntity resolve(const Nullable!(const TypeDefEntity) enclosing) const
    {
        auto namespace = this.getTypeNamespace();
        auto name = this.getTypeName();
        
        auto parents = this.findParentsForTypeRef();

        // Try best match
        if (!enclosing.isNull)
        {
            foreach(parent; parents)
            {
                foreach(n; parent.getAllNestedClassByEnclosing())
                {
                    auto nested = n.getNestedClass();
                    if (nested.getTypeName() == name && nested.getTypeNamespace() == namespace && parent == enclosing)
                    {
                        return Nullable!TypeDefEntity(nested);
                    }
                    auto resolved = resolveRecursive(nested, namespace, name, enclosing);
                    if (!resolved.isNull)
                    {
                        return resolved;
                    }
                }
            }
        }

        auto emptyEnclosing = Nullable!(const TypeDefEntity).init;
        foreach(parent; parents)
        {
            foreach(n; parent.getAllNestedClassByEnclosing())
            {
                auto nested = n.getNestedClass();
                if (nested.getTypeName() == name && nested.getTypeNamespace() == namespace)
                {
                    return Nullable!TypeDefEntity(nested);
                }
                auto resolved = resolveRecursive(nested, namespace, name, emptyEnclosing);
                if (!resolved.isNull)
                {
                    return resolved;
                }
            }
        }

        return (Nullable!TypeDefEntity).init;
    }

    private TypeDefEntity[] findParentsForTypeRef() const
    {
        auto resolutionScope = getResolutionScope(this);

        if (resolutionScope.peek!ModuleEntity)
        {
            auto namespace = getTypeNamespace();
            auto name = getTypeName();
            return db.typeDefCollection.findAllByName(namespace, name);
        }
        else if (resolutionScope.peek!TypeRefEntity)
        {
            auto parent = resolutionScope.get!TypeRefEntity;
            return parent.findParentsForTypeRef();
        }

        return [];
    }

    private Nullable!TypeDefEntity resolveRecursive(scope ref const TypeDefEntity parent, 
        string namespace, string name, scope ref const Nullable!(const TypeDefEntity) enclosing) const
    {
        if (!enclosing.isNull)
        {
            foreach(n; parent.getAllNestedClassByEnclosing())
            {
                auto nested = n.getNestedClass();
                if (nested.getTypeName() == name && nested.getTypeNamespace() == namespace && parent == enclosing)
                {
                    return Nullable!TypeDefEntity(n.getNestedClass());
                }
                
                auto resolved = resolveRecursive(nested, namespace, name, enclosing);
                if (!resolved.isNull)
                {
                    return resolved;
                }
            }
        }
        else
        {
            foreach(n; parent.getAllNestedClassByEnclosing())
            {
                auto nested = n.getNestedClass();
                if (nested.getTypeName() == name && nested.getTypeNamespace() == namespace)
                {
                    return Nullable!TypeDefEntity(n.getNestedClass());
                }
                
                auto resolved = resolveRecursive(nested, namespace, name, enclosing);
                if (!resolved.isNull)
                {
                    return resolved;
                }
            }
        }

        return (Nullable!TypeDefEntity).init;
    }
}

mixin DeclCodedIndexRangeProp!(MDTableType.typeRef, "Attributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// typeDef entity getters

private mixin template typeDefFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.typeDef, "Flags", TypeAttributes);
    mixin DeclSimpleField!(MDTableType.typeDef, "TypeName");
    mixin DeclSimpleField!(MDTableType.typeDef, "TypeNamespace");
    mixin DeclListIndexField!(MDTableType.typeDef, "FieldList", MDTableType.field);
    mixin DeclListIndexField!(MDTableType.typeDef, "MethodList", MDTableType.methodDef);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.typeDef, "Extends", TypeDefOrRef); // TypeDefEntity, TypeRefEntity, TypeSpecEntity

// Extra props

private mixin template typeDefFieldGettersExtra()
{
    mixin DeclRangeProp!(MDTableType.typeDef, "Interfaces", MDTableType.interfaceImpl, "Class");

    // First nestedClass entity referencing typeDef in NestedClass column
    mixin DeclFindFirstProp!(MDTableType.typeDef, "FirstNestedClassByNested", MDTableType.nestedClass, "NestedClass");
    
    // All nestedClass entities referencing typeDef NestedClass column
    mixin DeclAllProp!(MDTableType.typeDef, "AllNestedClassByNested", MDTableType.nestedClass, "NestedClass"); 

    // All nestedClass entities referencing typeDef NestedClass column
    mixin DeclAllProp!(MDTableType.typeDef, "AllNestedClassByEnclosing", MDTableType.nestedClass, "EnclosingClass"); 

    // First classLayout entity referencing typeDef in NestedClass column
    mixin DeclFindFirstProp!(MDTableType.typeDef, "Layout", MDTableType.classLayout, "Parent");

    mixin DeclRangeProp!(MDTableType.typeDef, "MethodImplementations", MDTableType.methodImpl, "Class");

    public const(Nullable!(Entity!(MDTableType.typeDef))) enclosing() const
    {
        auto nestedClassEntity = getFirstNestedClassByNested();
        if (nestedClassEntity.isNull)
        {
            return Nullable!(Entity!(MDTableType.typeDef)).init;
        }
        
        return Nullable!(Entity!(MDTableType.typeDef))(nestedClassEntity.get.getEnclosingClass());
    }

    public Nullable!TypeDefOrRefValue extends() const
    {        
        alias V = Nullable!TypeDefOrRefValue;
        if (this.nullExtends())
        {
            return V.init;
        }
        auto r = this.getExtends();
        if (auto td = r.peek!TypeDefEntity)
        {
            return !td.isNull() ? V(r) : V.init;
        }
        return V(r);
    }

    public bool isEnum() const
    {
        auto row = extends();
        if (row.isNull)
            return false;
        if (row.get.peek!TypeRefEntity)
        {
            auto td = row.get.get!TypeRefEntity;
            return td.getTypeName() == "Enum" && td.getTypeNamespace() == "System";
        }
        else if (row.get.peek!TypeDefEntity)
        {
            auto td = row.get.get!TypeDefEntity;
            return td.getTypeName() == "Enum" && td.getTypeNamespace() == "System";
        }
        return false;            
    }

    public bool isDelegate() const
    {
        auto row = extends();
        if (row.isNull)
            return false;
        if (row.get.peek!TypeRefEntity)
        {
            auto td = row.get.get!TypeRefEntity;
            return td.getTypeName() == "MulticastDelegate" && td.getTypeNamespace() == "System";
        }
        else if (row.get.peek!TypeDefEntity)
        {
            auto td = row.get.get!TypeDefEntity;
            return td.getTypeName() == "MulticastDelegate" && td.getTypeNamespace() == "System";
        }
        return false;            
    }

    public bool isValueType() const
    {
        auto row = extends();
        if (row.isNull)
            return false;
        if (row.get.peek!TypeRefEntity)
        {
            auto td = row.get.get!TypeRefEntity;
            return td.getTypeName() == "ValueType" && td.getTypeNamespace() == "System";
        }
        else if (row.get.peek!TypeDefEntity)
        {
            auto td = row.get.get!TypeDefEntity;
            return td.getTypeName() == "ValueType" && td.getTypeNamespace() == "System";
        }
        return false;            
    }

    public bool isInterface() const
    {
        return getFlags().semantics == TypeSemantics.interface_;
    }

    public ElementType underlyingEnumType() const
    {
        ElementType result;
        foreach(field; getFieldList())
        {
            if (!field.getFlags().isLiteral && !field.getFlags().isStatic)
            {
                result = field.getSignature().typeSig.type.get!ElementType;
                break;
            }
        }

        enforce(result >= ElementType.boolean && result <= ElementType.u8, "Invalid enum underlying type");
        return result;
    }

    // First propertyMap entity referencing typeDef in Parent column
    mixin DeclFindFirstProp!(MDTableType.typeDef, "PropertyMap", MDTableType.propertyMap, "Parent");

    public auto properties() const
    {
        auto propMap = getPropertyMap();
        if (propMap.isNull)
        {
            return db.propertyCollection.emptyList();
        }

        return propMap.get.getPropertyList();
    }

    // First eventMap entity referencing typeDef in Parent column
    mixin DeclFindFirstProp!(MDTableType.typeDef, "EventMap", MDTableType.eventMap, "Parent");

    public auto events() const
    {
        auto eventMap = getEventMap();
        if (eventMap.isNull)
        {
            return db.eventCollection.emptyList();
        }

        return eventMap.get.getEventList();
    }

    public bool isNested() const
    {
        auto nc = getFirstNestedClassByNested();
        return !nc.isNull;
    }
}

mixin DeclCodedIndexRangeProp!(MDTableType.typeDef, "Attributes", MDTableType.customAttribute, "Parent");

mixin DeclCodedIndexRangeProp!(MDTableType.typeDef, "GenericParameters", MDTableType.genericParam, "Owner");

//=============================================================================
// field entity getters

private mixin template fieldFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.field, "Flags", FieldAttributes);
    mixin DeclSimpleField!(MDTableType.field, "Name");
    mixin DeclSignatureField!(MDTableType.field, "Signature", FieldSig);
}

// Extra props

private mixin template fieldFieldGettersExtra()
{
    mixin DeclFindParentProp!(MDTableType.field, "Parent", MDTableType.typeDef, "FieldList");
}

mixin DeclFindFirstCodedIndexProp!(MDTableType.field, "Constant", MDTableType.constant, "Parent");
mixin DeclFindFirstCodedIndexProp!(MDTableType.field, "Marshal", MDTableType.fieldMarshal, "Parent");

mixin DeclCodedIndexRangeProp!(MDTableType.field, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// methodDef entity getters

private mixin template methodDefFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.methodDef, "RVA");
    mixin DeclSimpleFieldAsType!(MDTableType.methodDef, "ImplFlags", MethodImplAttributes);
    mixin DeclSimpleFieldAsType!(MDTableType.methodDef, "Flags", MethodAttributes);
    mixin DeclSimpleField!(MDTableType.methodDef, "Name");
    mixin DeclSignatureField!(MDTableType.methodDef, "Signature", MethodDefSig);
    mixin DeclListIndexField!(MDTableType.methodDef, "ParamList", MDTableType.param);
}

// Extra props

private mixin template methodDefFieldGettersExtra()
{
    mixin DeclFindParentProp!(MDTableType.methodDef, "Parent", MDTableType.typeDef, "MethodList");
}

mixin DeclCodedIndexRangeProp!(MDTableType.methodDef, "GenericParameters", MDTableType.genericParam, "Owner");
mixin DeclFindFirstCodedIndexProp!(MDTableType.methodDef, "Implementation", MDTableType.implMap, "MemberForwarded");
mixin DeclFindFirstCodedIndexProp!(MDTableType.methodDef, "Attributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// param entity getters

private mixin template paramFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.param, "Flags", ParamAttributes);
    mixin DeclSimpleField!(MDTableType.param, "Sequence");
    mixin DeclSimpleField!(MDTableType.param, "Name");
}

// Extra props

private mixin template paramFieldGettersExtra()
{
}

mixin DeclFindFirstCodedIndexProp!(MDTableType.param, "Constant", MDTableType.constant, "Parent");
mixin DeclFindFirstCodedIndexProp!(MDTableType.param, "Marshal", MDTableType.fieldMarshal, "Parent");
mixin DeclCodedIndexRangeProp!(MDTableType.param, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// interfaceImpl entity getters

private mixin template interfaceImplFieldGetters()
{
    mixin DeclIndexField!(MDTableType.interfaceImpl, "Class", MDTableType.typeDef); // Primary key
}

mixin DeclCodedIndexFieldGetter!(MDTableType.interfaceImpl, "Interface", TypeDefOrRef);

// Extra props

private mixin template interfaceImplFieldGettersExtra()
{
}

mixin DeclCodedIndexRangeProp!(MDTableType.interfaceImpl, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// memberRef entity getters

private mixin template memberRefFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.memberRef, "Name");
    mixin DeclSignatureField!(MDTableType.memberRef, "Signature", MethodDefSig);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.memberRef, "Class", MemberRefParent);

// Extra props

private mixin template memberRefFieldGettersExtra()
{
}

mixin DeclCodedIndexRangeProp!(MDTableType.memberRef, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// constant entity getters

private mixin template constantFieldGetters()
{
    mixin DeclSimpleFieldAsEnum!(MDTableType.constant, "Type", ConstantType);
    mixin DeclSimpleField!(MDTableType.constant, "Value"); // Blob
}

mixin DeclCodedIndexFieldGetter!(MDTableType.constant, "Parent", HasConstant);  // Primary key

// Extra props

private mixin template constantFieldGettersExtra()
{
    public alias ConstantValue = Algebraic!(bool, byte, ubyte, short, ushort, int, uint, long, ulong, wchar, float, double, wstring, typeof(null));

    public auto value() const
    {
        auto t = getType();
        if (t == ConstantType.class_)
        {
            return ConstantValue(null); // TODO: is this correct?
        }
        else
        {
            auto data = getValue();
            if (t == ConstantType.string)
                return ConstantValue(asArray!(immutable(wchar))(data));
            switch(t)
            {
                case ConstantType.boolean:
                    return ConstantValue(asVal!bool(data));
                case ConstantType.char_:
                    return ConstantValue(asVal!wchar(data));
                case ConstantType.int8:
                    return ConstantValue(asVal!byte(data));
                case ConstantType.uint8:
                    return ConstantValue(asVal!ubyte(data));
                case ConstantType.int16:
                    return ConstantValue(asVal!short(data));
                case ConstantType.uint16:
                    return ConstantValue(asVal!ushort(data));
                case ConstantType.int32:
                    return ConstantValue(asVal!int(data));
                case ConstantType.uint32:
                    return ConstantValue(asVal!uint(data));
                case ConstantType.int64:
                    return ConstantValue(asVal!long(data));
                case ConstantType.uint64:
                    return ConstantValue(asVal!ulong(data));
                case ConstantType.float32:
                    return ConstantValue(asVal!float(data));
                case ConstantType.float64:
                    return ConstantValue(asVal!double(data));
                default:
                    assert(0);
            }
        }
    }      
}

//=============================================================================
// customAttribute entity getters

private mixin template customAttributeFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.customAttribute, "Value"); // Blob - CustomAttributeSig - use value() instead of direct getValue
}

mixin DeclCodedIndexFieldGetter!(MDTableType.customAttribute, "Parent", HasCustomAttribute); // Primary key
mixin DeclCodedIndexFieldGetter!(MDTableType.customAttribute, "Type", CustomAttributeType);

// Extra props

private mixin template customAttributeFieldGettersExtra()
{
    public TypeDefOrRefValue type() const
    {
        auto ctor = this.getType();
        if (ctor.peek!MethodDefEntity)
        {
            auto meth = ctor.get!MethodDefEntity;
            return TypeDefOrRefValue(meth.getParent());
        }

        auto mr = ctor.get!MemberRefEntity;
        auto parent = mr.getClass();
        if (parent.peek!TypeDefEntity)
        {
            return TypeDefOrRefValue(parent.get!TypeDefEntity);
        }
        return TypeDefOrRefValue(parent.get!TypeRefEntity);
    }

    public auto name() const
    {
        auto t = type();
        if (auto td = t.peek!TypeDefEntity)
        {
            return td.getTypeName();
        }
    
        return t.get!TypeRefEntity.getTypeName();
    }

    public auto value() const
    {
        auto view = getValue();
        auto ctor = this.getType();
        if (auto mdef = ctor.peek!MethodDefEntity)
        {
            return CustomAttributeSig(db, view, mdef.getSignature());
        }

        return CustomAttributeSig(db, view, ctor.get!MemberRefEntity.getSignature());
    }
}

//=============================================================================
// fieldMarshal entity getters

private mixin template fieldMarshalFieldGetters()
{
    mixin DeclSignatureField!(MDTableType.fieldMarshal, "NativeType", FieldMarshalSig);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.fieldMarshal, "Parent", HasFieldMarshal); // Primary key

//=============================================================================
// declSecurity entity getters

private mixin template declSecurityFieldGetters()
{
    mixin DeclSimpleFieldAsEnum!(MDTableType.declSecurity, "Action", SecurityAction);
    mixin DeclSignatureField!(MDTableType.declSecurity, "PermissionSet", PermissionSig);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.declSecurity, "Parent", HasDeclSecurity); // Primary key

//=============================================================================
// classLayout entity getters

private mixin template classLayoutFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.classLayout, "PackingSize");
    mixin DeclSimpleField!(MDTableType.classLayout, "ClassSize");
    mixin DeclIndexField!(MDTableType.classLayout, "Parent", MDTableType.typeDef); // Primary key
}

//=============================================================================
// fieldLayout entity getters

private mixin template fieldLayoutFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.fieldLayout, "Offset");
    mixin DeclIndexField!(MDTableType.fieldLayout, "Field", MDTableType.field); // Primary key
}

//=============================================================================
// standAloneSig entity getters

private mixin template standAloneSigFieldGetters()
{
    mixin DeclSignatureField!(MDTableType.standAloneSig, "Signature", MethodDefSig);
}

// Extra props

private mixin template standAloneSigFieldGettersExtra()
{
}

mixin DeclCodedIndexRangeProp!(MDTableType.standAloneSig, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// eventMap entity getters

private mixin template eventMapFieldGetters()
{
    mixin DeclIndexField!(MDTableType.eventMap, "Parent", MDTableType.typeDef);
    mixin DeclListIndexField!(MDTableType.eventMap, "EventList", MDTableType.event);
}

//=============================================================================
// event entity getters

private mixin template eventFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.event, "EventFlags", EventAttributes);
    mixin DeclSimpleField!(MDTableType.event, "Name");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.event, "EventType", TypeDefOrRef);

// Extra props

private mixin template eventFieldGettersExtra()
{
    mixin DeclFindParentProp!(MDTableType.event, "Parent", MDTableType.eventMap, "EventList");
}

mixin DeclCodedIndexRangeProp!(MDTableType.event, "CustomAttributes", MDTableType.customAttribute, "Parent");
mixin DeclCodedIndexRangeProp!(MDTableType.event, "Semantics", MDTableType.methodSemantics, "Association");

//=============================================================================
// propertyMap entity getters

private mixin template propertyMapFieldGetters()
{
    mixin DeclIndexField!(MDTableType.propertyMap, "Parent", MDTableType.typeDef);
    mixin DeclListIndexField!(MDTableType.propertyMap, "PropertyList", MDTableType.property);
}

//=============================================================================
// property entity getters

private mixin template propertyFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.property, "Flags", PropertyAttributes);
    mixin DeclSimpleField!(MDTableType.property, "Name");
    mixin DeclSignatureField!(MDTableType.property, "Type", PropertySig);
}

// Extra props

private mixin template propertyFieldGettersExtra()
{
    mixin DeclFindParentProp!(MDTableType.property, "Parent", MDTableType.propertyMap, "PropertyList");
}

mixin DeclCodedIndexRangeProp!(MDTableType.property, "CustomAttributes", MDTableType.customAttribute, "Parent");
mixin DeclCodedIndexRangeProp!(MDTableType.property, "Semantics", MDTableType.methodSemantics, "Association");
mixin DeclFindFirstCodedIndexProp!(MDTableType.property, "Constant", MDTableType.constant, "Parent");

//=============================================================================
// methodSemantics entity getters

private mixin template methodSemanticsFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.methodSemantics, "Semantics", SemanticsAttributes);
    mixin DeclIndexField!(MDTableType.methodSemantics, "Method", MDTableType.methodDef);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.methodSemantics, "Association", HasSemantics); // Primary key

//=============================================================================
// methodImpl entity getters

private mixin template methodImplFieldGetters()
{
    mixin DeclIndexField!(MDTableType.methodImpl, "Class", MDTableType.typeDef); // Primary key
}

mixin DeclCodedIndexFieldGetter!(MDTableType.methodImpl, "MethodBody", MethodDefOrRef);
mixin DeclCodedIndexFieldGetter!(MDTableType.methodImpl, "MethodDeclaration", MethodDefOrRef);

//=============================================================================
// moduleRef entity getters

private mixin template moduleRefFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.moduleRef, "Name");
}

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.moduleRef, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// typeSpec entity getters

private mixin template typeSpecFieldGetters()
{
    mixin DeclSignatureField!(MDTableType.typeSpec, "Signature", TypeSpecSig);
}

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.typeSpec, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// implMap entity getters

private mixin template implMapFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.implMap, "MappingFlags", PInvokeAttributes);
    mixin DeclSimpleField!(MDTableType.implMap, "ImportName");
    mixin DeclIndexField!(MDTableType.implMap, "ImportScope", MDTableType.moduleRef);
}

mixin DeclCodedIndexFieldGetter!(MDTableType.implMap, "MemberForwarded", MemberForwarded); // Primary key

//=============================================================================
// fieldRVA entity getters

private mixin template fieldRVAFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.fieldRVA, "RVA");
    mixin DeclIndexField!(MDTableType.fieldRVA, "Field", MDTableType.field); // Primary key
}

//=============================================================================
// assembly entity getters

private mixin template assemblyFieldGetters()
{
    mixin DeclSimpleFieldAsEnum!(MDTableType.assembly, "HashAlgId", AssemblyHashAlgorithm);
    mixin DeclSimpleField!(MDTableType.assembly, "Version"); // TODO:  as AssemblyVersion
    mixin DeclSimpleFieldAsType!(MDTableType.assembly, "Flags", AssemblyAttributes);
    mixin DeclSimpleField!(MDTableType.assembly, "PublicKey");
    mixin DeclSimpleField!(MDTableType.assembly, "Name");
    mixin DeclSimpleField!(MDTableType.assembly, "Culture");
}

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.assembly, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// assemblyProcessor entity getters

private mixin template assemblyProcessorFieldGetters()
{
    mixin DeclSimpleFieldAsEnum!(MDTableType.assemblyProcessor, "Processor", AssemblyArch);
}

//=============================================================================
// assemblyOS entity getters

private mixin template assemblyOSFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.assemblyOS, "OSPlatformID");
    mixin DeclSimpleField!(MDTableType.assemblyOS, "OSMajorVersion");
    mixin DeclSimpleField!(MDTableType.assemblyOS, "OSMinorVersion");
}

//=============================================================================
// assemblyRef entity getters

private mixin template assemblyRefFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.assemblyRef, "Version"); // TODO: as AssemblyVersion
    mixin DeclSimpleFieldAsType!(MDTableType.assemblyRef, "Flags", AssemblyAttributes);
    mixin DeclSimpleField!(MDTableType.assemblyRef, "PublicKeyOrToken");
    mixin DeclSimpleField!(MDTableType.assemblyRef, "Name");
    mixin DeclSimpleField!(MDTableType.assemblyRef, "Culture");
    mixin DeclSimpleField!(MDTableType.assemblyRef, "HashValue");
}

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.assemblyRef, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// assemblyRefProcessor entity getters

private mixin template assemblyRefProcessorFieldGetters()
{
    mixin DeclSimpleFieldAsEnum!(MDTableType.assemblyRefProcessor, "Processor", AssemblyArch);
    mixin DeclIndexField!(MDTableType.assemblyRefProcessor, "AssemblyRef", MDTableType.assemblyRef);
}

//=============================================================================
// assemblyRefOS entity getters

private mixin template assemblyRefOSFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.assemblyRefOS, "OSPlatformId");
    mixin DeclSimpleField!(MDTableType.assemblyRefOS, "OSMajorVersion");
    mixin DeclSimpleField!(MDTableType.assemblyRefOS, "OSMinorVersion");
    mixin DeclIndexField!(MDTableType.assemblyRefOS, "AssemblyRef", MDTableType.assemblyRef);
}

//=============================================================================
// file entity getters

private mixin template fileFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.file, "Flags");
    mixin DeclSimpleField!(MDTableType.file, "Name");
    mixin DeclSimpleField!(MDTableType.file, "HashValue");
}

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.file, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// exportedType entity getters

private mixin template exportedTypeFieldGetters()
{
    mixin DeclSimpleFieldAsType!(MDTableType.exportedType, "Flags", TypeAttributes);
    mixin DeclSimpleField!(MDTableType.exportedType, "TypeDefId");
    mixin DeclSimpleField!(MDTableType.exportedType, "TypeName");
    mixin DeclSimpleField!(MDTableType.exportedType, "TypeNamespace");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.exportedType, "Implementation", Implementation);

// Extra props

private mixin template exportedTypeFieldGettersExtra()
{
    // public Nullable!TypeDefEntity hint() const
    // {
    //     // TypeDefId (a 4-byte index into a TypeDef table of another module in this Assembly).
    //     // This column is used as a hint only. If the entry in the target TypeDef table matches the TypeName and TypeNamespace entries in this table,
    //     // resolution has succeeded. But if there is a mismatch, the CLI shall fall back to a search of the target TypeDef table.
    //     // Ignored and should be zero if Flags has IsTypeForwarder set.

    //     if (getFlags().isTypeForwarder())
    //     {
    //         return (Nullable!TypeDefEntity).init;
    //     }

    //     auto hintIndex = getTypeDefId();
    //     if (hintIndex == 0)
    //     {
    //         return (Nullable!TypeDefEntity).init;
    //     }

    //     if (table.db.typeDefTable.rowCount <= hintIndex)
    //     {
    //         auto td = table.db.typeDefTable[hintIndex];
    //         if (td.name == name && td.namespace == td.namespace)
    //             return Nullable!TypeDef(td);
    //     }
    //     return (Nullable!TypeDef).init;
    // }
}

mixin DeclCodedIndexRangeProp!(MDTableType.exportedType, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// manifestResource entity getters

private mixin template manifestResourceFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.manifestResource, "Offset");
    mixin DeclSimpleFieldAsEnum!(MDTableType.manifestResource, "Flags", ManifestVisibility);
    mixin DeclSimpleField!(MDTableType.manifestResource, "Name");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.manifestResource, "Implementation", Implementation); // Can be null

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.manifestResource, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// nestedClass entity getters

private mixin template nestedClassFieldGetters()
{
    mixin DeclIndexField!(MDTableType.nestedClass, "NestedClass", MDTableType.typeDef); // Primary key
    mixin DeclIndexField!(MDTableType.nestedClass, "EnclosingClass", MDTableType.typeDef);
}

//=============================================================================
// genericParam entity getters

private mixin template genericParamFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.genericParam, "Number");
    mixin DeclSimpleFieldAsType!(MDTableType.genericParam, "Flags", GenericAttributes);
    mixin DeclSimpleField!(MDTableType.genericParam, "Name");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.genericParam, "Owner", TypeOrMethodDef); // Primary key

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.genericParam, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
// methodSpec entity getters

private mixin template methodSpecFieldGetters()
{
    mixin DeclSimpleField!(MDTableType.methodSpec, "Instantiation");
}

mixin DeclCodedIndexFieldGetter!(MDTableType.methodSpec, "Method", MethodDefOrRef);

//=============================================================================
// genericParamConstraint entity getters

private mixin template genericParamConstraintFieldGetters()
{
    mixin DeclIndexField!(MDTableType.genericParamConstraint, "Owner", MDTableType.genericParam); // Primary key
}

mixin DeclCodedIndexFieldGetter!(MDTableType.genericParamConstraint, "Constraint", TypeDefOrRef);

// Extra props

mixin DeclCodedIndexRangeProp!(MDTableType.genericParamConstraint, "CustomAttributes", MDTableType.customAttribute, "Parent");

//=============================================================================
//=============================================================================
// Helpers
//=============================================================================
//=============================================================================

// Declares free function (find first for coded index field)
// Nullable!(Entity!mdTarget) get##PropName(in Entity!(md) entity) { ... }
private mixin template DeclFindFirstCodedIndexProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectRangePropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;
        immutable string entityType = "Entity!(" ~ tableType ~ ")";

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";
        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";
        immutable string targetEntityType = "Entity!(" ~ targetTableType ~ ")";

        immutable string targetEntityColumnCodedIndexType = TargetColumnName ~ "CodedIndexType!(" ~ targetTableType ~ ")";
        immutable string codedIndexMember = "getCodedIndexMember!(" ~ targetEntityColumnCodedIndexType ~ ", " ~ tableType ~ ")";

        immutable string returnType = "Nullable!(" ~ targetEntityType ~ ")";

        string decl = "";

        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.CodedIndex);\n";                        // target column is coded index
        decl ~= "static assert( is(typeof(" ~ codedIndexMember ~ ") == " ~ targetEntityColumnCodedIndexType ~ "));\n"; // and that coded index can point to this (md) entity

        decl ~= "public " ~ returnType ~ " get" ~ PropName ~ "(in " ~ entityType ~ " entity)\n";
        decl ~= "{\n";
        decl ~= "  const auto ci = CompositeIndex!(" ~ targetEntityColumnCodedIndexType ~ ")(entity.row.getRowID(), " ~ codedIndexMember ~ ");\n";
        decl ~= "  auto codedIndexValue = Value!(uint, ValueKind.CodedIndex)(ci.codedIndex);";
        decl ~= "  auto found = entity.db.getTable!(" ~ targetTableType ~ ")().findFirstCodedIndex!(uint)(codedIndexValue, " ~ targetColumn ~ ");\n";
        decl ~= "  return found.isNull ? " ~ returnType ~ ".init : " ~ returnType ~ "(" ~ targetEntityType ~"(found.get, entity.db));\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectRangePropGetter());   
}

// Declares free function (coded index field range getter)
// CollectionCodedIndexRangeEnumerator!mdTarget get##PropName(in Entity!(md) entity) { ... }
private mixin template DeclCodedIndexRangeProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectRangePropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;
        immutable string entityType = "Entity!(" ~ tableType ~ ")";

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";

        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";
        immutable string targetEntityColumnCodedIndexType = TargetColumnName ~ "CodedIndexType!(" ~ targetTableType ~ ")";

        immutable string rangeEnumeratorType = "CollectionCodedIndexRangeEnumerator!(" ~ targetTableType ~ ")";
        
        immutable string codedIndexMember = "getCodedIndexMember!(" ~ targetEntityColumnCodedIndexType ~ ", " ~ tableType ~ ")";

        string decl = "";

        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.CodedIndex);\n";                        // target column is coded index
        decl ~= "static assert( is(typeof(" ~ codedIndexMember ~ ") == " ~ targetEntityColumnCodedIndexType ~ "));\n"; // and that coded index can point to this (md) entity

        decl ~= "public " ~ rangeEnumeratorType ~ " get" ~ PropName ~ "(in " ~ entityType ~ " entity)\n";
        decl ~= "{\n";
        decl ~= "  const auto ci = CompositeIndex!(" ~ targetEntityColumnCodedIndexType ~ ")(entity.row.getRowID(), " ~ codedIndexMember ~ ");\n";

        decl ~= "  auto codedIndexValue = Value!(uint, ValueKind.CodedIndex)(ci.codedIndex);";
        decl ~= "  auto tableEnumerator = entity.db.getTable!(" ~ targetTableType ~ ")().codedIndexRange!(uint)(codedIndexValue, " ~ targetColumn ~ ");\n";
        decl ~= "  return " ~ rangeEnumeratorType ~ "(tableEnumerator, entity.db);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectRangePropGetter());   
}

private mixin template DeclFindParentProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectFindParentPropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";

        immutable string targetEntityType = "Entity!(" ~ targetTableType ~ ")";
        immutable string targetEntityColumnType = targetEntityType ~ "." ~ TargetColumnName ~ "EntityType";
        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";

        immutable string returnType = targetEntityType;

        string decl = "";
        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.Index);\n";         // target column is index
        decl ~= "static assert(" ~ targetEntityColumnType ~ ".TableType == " ~ tableType ~ ");\n"; // and that index references this (md) entity

        decl ~= "public " ~ targetEntityType ~ " get" ~ PropName ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  auto found = db.getTable!(" ~ targetTableType ~ ")().findParentFor!(uint)(Value!(uint, ValueKind.Index)(row.getRowID()), " ~ targetColumn ~ ");\n";
        decl ~= "  return " ~ targetEntityType ~"(found, db);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFindParentPropGetter());   
}

private mixin template DeclFindFirstProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectFindFirstPropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";

        immutable string targetEntityType = "Entity!(" ~ targetTableType ~ ")";
        immutable string targetEntityColumnType = targetEntityType ~ "." ~ TargetColumnName ~ "EntityType";
        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";

        immutable string returnType = "Nullable!(" ~ targetEntityType ~ ")";

        string decl = "";
        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.Index);\n";         // target column is index
        decl ~= "static assert(" ~ targetEntityColumnType ~ ".TableType == " ~ tableType ~ ");\n"; // and that index references this (md) entity

        decl ~= "public " ~ returnType ~ " get" ~ PropName ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  auto found = db.getTable!(" ~ targetTableType ~ ")().findFirst!(uint)(Value!(uint, ValueKind.Index)(row.getRowID()), " ~ targetColumn ~ ");\n";
        decl ~= "  return found.isNull ? " ~ returnType ~ ".init : " ~ returnType ~ "(" ~ targetEntityType ~"(found.get, db));\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFindFirstPropGetter());   
}

// Declares member function (range of rows in mdTarget table referencing this row)
// CollectionRangeEnumerator!mdTarget get##PropName() const { ... }
private mixin template DeclRangeProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectRangePropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";

        immutable string targetEntityColumnType = "Entity!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "EntityType";
        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";

        immutable string rangeEnumeratorType = "CollectionRangeEnumerator!(" ~ targetTableType ~ ")";

        string decl = "";
        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.Index);\n";         // target column is index
        decl ~= "static assert(" ~ targetEntityColumnType ~ ".TableType == " ~ tableType ~ ");\n"; // and that index references this (md) entity

        decl ~= "public " ~ rangeEnumeratorType ~ " get" ~ PropName ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  auto tableEnumerator = db.getTable!(" ~ targetTableType ~ ")().range!(uint)(Value!(uint, ValueKind.Index)(row.getRowID()), " ~ targetColumn ~ ");\n";
        decl ~= "  return " ~ rangeEnumeratorType ~ "(tableEnumerator, db);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectRangePropGetter());   
}

// Declares member function (all rows in mdTarget table referencing this row)
// CollectionAllEnumerator!mdTarget get##PropName() const { ... }
private mixin template DeclAllProp(alias md, string PropName, alias mdTarget, string TargetColumnName)
{
    enum injectAllPropGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetColumnValueType = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "ValueType";

        immutable string targetEntityColumnType = "Entity!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "EntityType";
        immutable string targetColumn = "Row!(" ~ targetTableType ~ ")." ~ TargetColumnName ~ "Column";

        immutable string rangeEnumeratorType = "CollectionAllEnumerator!(" ~ targetTableType ~ ")";

        string decl = "";
        decl ~= "static assert(" ~ targetColumnValueType ~ ".Kind == ValueKind.Index);\n";         // target column is index
        decl ~= "static assert(" ~ targetEntityColumnType ~ ".TableType == " ~ tableType ~ ");\n"; // and that index references this (md) entity

        decl ~= "public " ~ rangeEnumeratorType ~ " get" ~ PropName ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  auto tableEnumerator = db.getTable!(" ~ targetTableType ~ ")().all!(uint)(Value!(uint, ValueKind.Index)(row.getRowID()), " ~ targetColumn ~ ");\n";
        decl ~= "  return " ~ rangeEnumeratorType ~ "(tableEnumerator, db);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectAllPropGetter());   
}

// Declares free function (coded index field value getter)
// CodedIndexValueType!CodedIndexType get##Name() const { ... }
// bool null##Name() const { ... }
// alias Name##CodedIndexType = CodedIndexType
private mixin template DeclCodedIndexFieldGetter(alias md, string Name, CodedIndexType)
{
    enum injectCodedIndexFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;
        immutable string entityType = "Entity!(" ~ tableType ~ ")";

        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string columnCodedIndexTypeAlias = Name ~ "CodedIndexType";

        immutable string codedIndexValueType = "CodedIndexValueType!(" ~ CodedIndexType.stringof ~ ")";

        string decl = "";

        decl ~= "public template " ~ columnCodedIndexTypeAlias ~ "(MDTableType md) if (md == " ~ tableType ~")\n";
        decl ~= "{ alias " ~ columnCodedIndexTypeAlias ~ " = " ~ CodedIndexType.stringof ~ "; }\n";

        decl ~= "public bool null" ~ Name ~ "(in " ~ entityType ~ " entity)\n";
        decl ~= "{\n";
        decl ~= "  const auto columnValue = entity.row.get" ~ Name ~ "();\n";
        decl ~= "  const auto codedIndex = CompositeIndex!(" ~ CodedIndexType.stringof ~ ")(columnValue);\n";
        decl ~= "  return codedIndex.index() == 0;\n"; // TODO: also check > table.rowCount
        decl ~= "}\n";

        decl ~= "public " ~ codedIndexValueType ~ " get" ~ Name ~ "(in " ~ entityType ~ " entity)\n";
        decl ~= "{\n";
        decl ~= "  alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "  static assert(" ~ columnValueTypeAlias ~ ".Kind == ValueKind.CodedIndex);\n";
        decl ~= "  const auto columnValue = entity.row.get" ~ Name ~ "();\n";
        decl ~= "  const auto codedIndex = CompositeIndex!(" ~ CodedIndexType.stringof ~ ")(columnValue);\n";
        decl ~= "  assert(!null" ~ Name ~ "(entity), \"access to null coded index table " ~ tableType ~ " field " ~ Name ~ "\");\n";
        decl ~= "  return getCodedIndexValue!(" ~ CodedIndexType.stringof ~ ")(entity.db, codedIndex);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectCodedIndexFieldGetter());
}

struct CodedIndexFieldValueExtractor(CodedIndexType)
{
    alias ValueType = CodedIndexValueType!(CodedIndexType);

    public this(const Database* db)
    {
        this.db = db;
    }
    
    public ValueType getValue(in CompositeIndex!(CodedIndexType) codedIndex) const
    {
        return getCodedIndexValue!(CodedIndexType)(db, codedIndex);
    }

    private const Database* db;    
}

// Declares member function (list index field value getter)
// CollectionListEnumerator!mdTarget get##Name() const { ... }
// bool null##Name() const { ... }
private mixin template DeclListIndexField(alias md, string Name, alias mdTarget)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;
        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;
        immutable string targetEntityType = "Entity!(" ~ targetTableType ~ ")";
        immutable string targetEntityTypeAlias = Name ~ "EntityType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "static assert(" ~ columnValueTypeAlias ~ ".Kind == ValueKind.Index);\n";
        decl ~= "public alias " ~ targetEntityTypeAlias ~ " = " ~ targetEntityType ~ ";\n";

        decl ~= "public bool null" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  const auto columnValue = row.get" ~ Name ~ "();\n";
        decl ~= "  return columnValue == 0 || columnValue > db.getTable!(" ~ targetTableType ~ ")().rowCount;\n";
        decl ~= "}\n";

        decl ~= "public auto get" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  auto isNull = null" ~ Name ~ "();\n";
        decl ~= "  if (isNull) return CollectionListEnumerator!(" ~ targetTableType ~ ")(emptyList(" ~ "db.getTable!(" ~ targetTableType ~ ")()" ~ "), db);\n";
        decl ~= "  auto columnValue = row.get" ~ Name ~ "();\n";
        decl ~= "  auto isLast = isLastRow(row);\n";
        decl ~= "  if (isLast) return db.getCollection!(" ~ targetTableType ~ ").list(columnValue, 0);\n";
        decl ~= "  auto nextRow = getNextRow(row);\n";
        decl ~= "  auto nextColumnValue = nextRow.get" ~ Name ~ "();\n";
        decl ~= "  return db.getCollection!(" ~ targetTableType ~ ").list(columnValue, nextColumnValue);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

struct IndexValue
{
    MDTableType md;
    uint rowID;
}

// Declares member function (index field value getter)
// const(Entity!mdTarget) get##Name() const { ... }
// bool null##Name() const { ... }
private mixin template DeclIndexField(alias md, string Name, alias mdTarget)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;
        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string targetTableType = "MDTableType." ~ mdTarget.stringof;

        immutable string targetEntityType = "Entity!(" ~ targetTableType ~ ")";
        immutable string targetEntityTypeAlias = Name ~ "EntityType";

        immutable string extractorType = "IndexFieldValueExtractor!(" ~ columnValueType ~ ", " ~ targetTableType ~ ")";
        immutable string extractorTypeAlias = Name ~ "FieldValueExtractorType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "static assert(" ~ columnValueTypeAlias ~ ".Kind == ValueKind.Index);\n";
        decl ~= "public alias " ~ targetEntityTypeAlias ~ " = " ~ targetEntityType ~ ";\n";
        decl ~= "public alias " ~ extractorTypeAlias ~ " = " ~ extractorType ~ ";\n";

        decl ~= "public auto get" ~ Name ~ "() const\n";
        decl ~= "{ return " ~ extractorTypeAlias ~ "(db).getValue(row.get" ~ Name ~ "());" ~ " }\n";

        decl ~= "public bool null" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  const auto columnValue = row.get" ~ Name ~ "();\n";
        decl ~= "  return columnValue == 0 || columnValue > db.getTable!(" ~ targetTableType ~ ")().rowCount;\n";
        decl ~= "}\n";

        // Helper for JSON dump
        decl ~= "public IndexValue _getIndex" ~ Name ~ "() const\n";
        decl ~= "{ return IndexValue(" ~ targetTableType ~ ", row.get" ~ Name ~ "()); }\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

unittest
{
    alias InterfaceImplEntity = Entity!(MDTableType.interfaceImpl);

    static assert(is(InterfaceImplEntity.ClassFieldValueExtractorType == IndexFieldValueExtractor!(Value!(uint, ValueKind.Index), MDTableType.typeDef)));
}

// value is Value<T, K>
struct IndexFieldValueExtractor(value, MDTableType mdTarget) if (value.Kind == ValueKind.Index)
{
    public alias ReturnValueType = const(Entity!mdTarget);
    
    public this(const Database* db)
    {
        this.db = db;
    }
    
    ReturnValueType getValue(in value v) const
    {
        return db.getCollection!(mdTarget)[v];
    }

    private:
        const Database* db;
}

private mixin template DeclSignatureField(alias md, string Name, T)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string extractorType = "FieldValueExtractor!(" ~ columnValueTypeAlias ~ ")";
        immutable string extractorTypeAlias = Name ~ "FieldValueExtractorType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "public alias " ~ extractorTypeAlias ~ " = " ~ extractorType ~ ";\n";
        
        decl ~= "public T get" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  static assert(" ~ columnValueType ~ ".Kind == ValueKind.Blob);\n";
        decl ~= "  auto data = " ~ extractorTypeAlias ~ "(db.heaps()).getValue(row.get" ~ Name ~ "());\n";
        decl ~= "  return T(db, data);\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

// Declares member function (field value getter)
// GetSimpleFieldValueType!(ValueType!(T, K)) get##Name() const { ... }
//
// Example for string field 'Name' at 'module_' table:
//
// public alias NameColumnValueType = Row!(MDTableType.module_).NameValueType; // == Value!(MDTableType.module_, ValueKind.String)
// public alias NameFieldValueExtractorType = FieldValueExtractor!(NameColumnValueType);
// public auto getName() const // returns string because Row!(MDTableType.module_).NameValueType is Value(MDTableType.module_, ValueKind.String)
// {
//     return NameFieldValueExtractorType(db.heaps()).getValue(row.getName());
// }
private mixin template DeclSimpleField(alias md, string Name)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string extractorType = "FieldValueExtractor!(" ~ columnValueTypeAlias ~ ")";
        immutable string extractorTypeAlias = Name ~ "FieldValueExtractorType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "public alias " ~ extractorTypeAlias ~ " = " ~ extractorType ~ ";\n";
        
        decl ~= "public auto get" ~ Name ~ "() const\n";
        decl ~= "{ return " ~ extractorTypeAlias ~ "(db.heaps()).getValue(row.get" ~ Name ~ "());" ~ " }\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

unittest
{
    alias ModuleEntity = Entity!(MDTableType.module_);

    //static assert(is(GetSimpleFieldValueType!(ModuleEntity.UnusedColumnValueType) == ushort));
    static assert(is(GetSimpleFieldValueType!(ModuleEntity.NameColumnValueType) == string));
    static assert(is(GetSimpleFieldValueType!(ModuleEntity.MvidColumnValueType) == UUID));
    static assert(is(GetSimpleFieldValueType!(ModuleEntity.EncIdColumnValueType) == UUID));
    static assert(is(GetSimpleFieldValueType!(ModuleEntity.EncBaseIdColumnValueType) == UUID));
}

// Same as DeclSimpleField but returns T. Only for Integral columns.
private mixin template DeclSimpleFieldAsEnum(alias md, string Name, T)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string extractorType = "FieldValueExtractor!(" ~ columnValueTypeAlias ~ ")";
        immutable string extractorTypeAlias = Name ~ "FieldValueExtractorType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "public alias " ~ extractorTypeAlias ~ " = " ~ extractorType ~ ";\n";
        
        decl ~= "public T get" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  static assert(" ~ columnValueType ~ ".Kind == ValueKind.Integral);\n";
        decl ~= "  return cast(T)" ~ extractorTypeAlias ~ "(db.heaps()).getValue(row.get" ~ Name ~ "());\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

// Same as DeclSimpleField but returns T. Only for Integral columns.
private mixin template DeclSimpleFieldAsType(alias md, string Name, T)
{
    enum injectFieldGetter = ()
    {
        immutable string tableType = "MDTableType." ~ md.stringof;

        immutable string columnValueType = "Row!(" ~ tableType ~ ")." ~ Name ~ "ValueType";
        immutable string columnValueTypeAlias = Name ~ "ColumnValueType";

        immutable string extractorType = "FieldValueExtractor!(" ~ columnValueTypeAlias ~ ")";
        immutable string extractorTypeAlias = Name ~ "FieldValueExtractorType";

        string decl = "";
        decl ~= "public alias " ~ columnValueTypeAlias ~ " = " ~ columnValueType ~ ";\n";
        decl ~= "public alias " ~ extractorTypeAlias ~ " = " ~ extractorType ~ ";\n";
        
        decl ~= "public T get" ~ Name ~ "() const\n";
        decl ~= "{\n";
        decl ~= "  static assert(" ~ columnValueType ~ ".Kind == ValueKind.Integral);\n";
        decl ~= "  return T(" ~ extractorTypeAlias ~ "(db.heaps()).getValue(row.get" ~ Name ~ "()));\n";
        decl ~= "}\n";

        return decl;
    };

    mixin(injectFieldGetter());
}

// value is Value<T, K>
struct FieldValueExtractor(value)
{
    public alias ReturnValueType = GetSimpleFieldValueType!(value);
    
    public this(const (Heaps*) heaps)
    {
        this.heaps = heaps;
    }
    
    ReturnValueType getValue(in value v) const
    {
        static if (value.Kind == ValueKind.Integral)
        {
            return v;
        }
        else static if (value.Kind == ValueKind.Guid)
        {
            return heaps.getGuid(v);
        }
        else static if (value.Kind == ValueKind.String)
        {
            return heaps.getString(v);
        }
        else static if (value.Kind == ValueKind.Blob)
        {
            return heaps.getBlob(v);
        }
        else
        {
            static assert(false, "invalid value kind");
        }
    }

    private:
        const (Heaps*) heaps;
}

unittest
{
    Heaps heaps = Heaps([], [], []);

    alias TestIntegralExtractor = FieldValueExtractor!(Value!(ushort, ValueKind.Integral));
    TestIntegralExtractor te = TestIntegralExtractor(&heaps);

    auto integralVal = te.getValue(Value!(ushort, ValueKind.Integral)(42));
    assert(integralVal == 42);
}

unittest
{
    const(ubyte)[] stringsHeap = ['q', 0]; // one null-terminated string "q" at offset 0

    Heaps heaps = Heaps(stringsHeap, [], []);

    alias TestStringExtractor = FieldValueExtractor!(Value!(uint, ValueKind.String));
    TestStringExtractor te = TestStringExtractor(&heaps);

    auto stringVal = te.getValue(Value!(uint, ValueKind.String)(0));
    assert(stringVal == "q");
}

// value is Value<T, K>
template GetSimpleFieldValueType(value)
{
    static if (value.Kind == ValueKind.Integral)
    {
        alias GetSimpleFieldValueType = value.Type;
    } 
    else static if (value.Kind == ValueKind.Guid)
    {
        alias GetSimpleFieldValueType = UUID;
    }
    else static if (value.Kind == ValueKind.String)
    {
        alias GetSimpleFieldValueType = string;
    }
    else static if (value.Kind == ValueKind.Blob)
    {
        alias GetSimpleFieldValueType = const(ubyte)[];
    }
    else
    {
        alias GetSimpleFieldValueType = void;
    }
}

unittest
{
    alias Val1 = Value!(ushort, ValueKind.Integral);
    static assert(is(GetSimpleFieldValueType!(Val1) == ushort));

    alias Val2 = Value!(uint, ValueKind.String);
    static assert(is(GetSimpleFieldValueType!(Val2) == string));

    alias Val3 = Value!(uint, ValueKind.Guid);
    static assert(is(GetSimpleFieldValueType!(Val3) == UUID));

    alias Val4 = Value!(uint, ValueKind.Blob);
    static assert(is(GetSimpleFieldValueType!(Val4) == const(ubyte)[]));
}