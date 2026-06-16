module climetadata.mdcollection.database;

import climetadata.mdcollection.collection;
import climetadata.mdtable.type;
import climetadata.mdtable.heaps : Heaps;
import climetadata.mdtable.tables : Tables;
import climetadata.mdtable.table : Table;

struct Database
{
    @disable this();

    public this(const Tables* tables, const Heaps* heaps)
    {
        _tables = tables;
        _heaps = heaps;

        moduleCollection = Collection!(MDTableType.module_)(&this);
        typeRefCollection = Collection!(MDTableType.typeRef)(&this);
        typeDefCollection = Collection!(MDTableType.typeDef)(&this);
        fieldCollection = Collection!(MDTableType.field)(&this);
        methodDefCollection = Collection!(MDTableType.methodDef)(&this);
        paramCollection = Collection!(MDTableType.param)(&this);
        interfaceImplCollection = Collection!(MDTableType.interfaceImpl)(&this);
        memberRefCollection = Collection!(MDTableType.memberRef)(&this);
        constantCollection = Collection!(MDTableType.constant)(&this);
        customAttributeCollection = Collection!(MDTableType.customAttribute)(&this);
        fieldMarshalCollection = Collection!(MDTableType.fieldMarshal)(&this);
        declSecurityCollection = Collection!(MDTableType.declSecurity)(&this);
        classLayoutCollection = Collection!(MDTableType.classLayout)(&this);
        fieldLayoutCollection = Collection!(MDTableType.fieldLayout)(&this);
        standAloneSigCollection = Collection!(MDTableType.standAloneSig)(&this);
        eventMapCollection = Collection!(MDTableType.eventMap)(&this);
        eventCollection = Collection!(MDTableType.event)(&this);
        propertyMapCollection = Collection!(MDTableType.propertyMap)(&this);
        propertyCollection = Collection!(MDTableType.property)(&this);
        methodSemanticsCollection = Collection!(MDTableType.methodSemantics)(&this);
        methodImplCollection = Collection!(MDTableType.methodImpl)(&this);
        moduleRefCollection = Collection!(MDTableType.moduleRef)(&this);
        typeSpecCollection = Collection!(MDTableType.typeSpec)(&this);
        implMapCollection = Collection!(MDTableType.implMap)(&this);
        fieldRVACollection = Collection!(MDTableType.fieldRVA)(&this);
        assemblyCollection = Collection!(MDTableType.assembly)(&this);
        assemblyProcessorCollection = Collection!(MDTableType.assemblyProcessor)(&this);
        assemblyOSCollection = Collection!(MDTableType.assemblyOS)(&this);
        assemblyRefCollection = Collection!(MDTableType.assemblyRef)(&this);
        assemblyRefProcessorCollection = Collection!(MDTableType.assemblyRefProcessor)(&this);
        assemblyRefOSCollection = Collection!(MDTableType.assemblyRefOS)(&this);
        fileCollection = Collection!(MDTableType.file)(&this);
        exportedTypeCollection = Collection!(MDTableType.exportedType)(&this);
        manifestResourceCollection = Collection!(MDTableType.manifestResource)(&this);
        nestedClassCollection = Collection!(MDTableType.nestedClass)(&this);
        genericParamCollection = Collection!(MDTableType.genericParam)(&this);
        methodSpecCollection = Collection!(MDTableType.methodSpec)(&this);
        genericParamConstraintCollection = Collection!(MDTableType.genericParamConstraint)(&this);
    }

    public const(Heaps*) heaps() const
    {
        return _heaps;
    }

    public const(Table!md*) getTable(MDTableType md)() const
    {
        return &_tables.getTable!(md);
    }

    public template getCollection(MDTableType md)
    {
        static if (md == MDTableType.module_) alias getCollection =                      moduleCollection;
        else static if (md == MDTableType.typeRef) alias getCollection =                 typeRefCollection;
        else static if (md == MDTableType.typeDef) alias getCollection =                 typeDefCollection;
        else static if (md == MDTableType.field) alias getCollection =                   fieldCollection;
        else static if (md == MDTableType.methodDef) alias getCollection =               methodDefCollection;
        else static if (md == MDTableType.param) alias getCollection =                   paramCollection;
        else static if (md == MDTableType.interfaceImpl) alias getCollection =           interfaceImplCollection;
        else static if (md == MDTableType.memberRef) alias getCollection =               memberRefCollection;
        else static if (md == MDTableType.constant) alias getCollection =                constantCollection;
        else static if (md == MDTableType.customAttribute) alias getCollection =         customAttributeCollection;
        else static if (md == MDTableType.fieldMarshal) alias getCollection =            fieldMarshalCollection;
        else static if (md == MDTableType.declSecurity) alias getCollection =            declSecurityCollection;
        else static if (md == MDTableType.classLayout) alias getCollection =             classLayoutCollection;
        else static if (md == MDTableType.fieldLayout) alias getCollection =             fieldLayoutCollection;
        else static if (md == MDTableType.standAloneSig) alias getCollection =           standAloneSigCollection;
        else static if (md == MDTableType.eventMap) alias getCollection =                eventMapCollection;
        else static if (md == MDTableType.event) alias getCollection =                   eventCollection;
        else static if (md == MDTableType.propertyMap) alias getCollection =             propertyMapCollection;
        else static if (md == MDTableType.property) alias getCollection =                propertyCollection;
        else static if (md == MDTableType.methodSemantics) alias getCollection =         methodSemanticsCollection;
        else static if (md == MDTableType.methodImpl) alias getCollection =              methodImplCollection;
        else static if (md == MDTableType.moduleRef) alias getCollection =               moduleRefCollection;
        else static if (md == MDTableType.typeSpec) alias getCollection =                typeSpecCollection;
        else static if (md == MDTableType.implMap) alias getCollection =                 implMapCollection;
        else static if (md == MDTableType.fieldRVA) alias getCollection =                fieldRVACollection;
        else static if (md == MDTableType.assembly) alias getCollection =                assemblyCollection;
        else static if (md == MDTableType.assemblyProcessor) alias getCollection =       assemblyProcessorCollection;
        else static if (md == MDTableType.assemblyOS) alias getCollection =              assemblyOSCollection;
        else static if (md == MDTableType.assemblyRef) alias getCollection =             assemblyRefCollection;
        else static if (md == MDTableType.assemblyRefProcessor) alias getCollection =    assemblyRefProcessorCollection;
        else static if (md == MDTableType.assemblyRefOS) alias getCollection =           assemblyRefOSCollection;
        else static if (md == MDTableType.file) alias getCollection =                    fileCollection;
        else static if (md == MDTableType.exportedType) alias getCollection =            exportedTypeCollection;
        else static if (md == MDTableType.manifestResource) alias getCollection =        manifestResourceCollection;
        else static if (md == MDTableType.nestedClass) alias getCollection =             nestedClassCollection;
        else static if (md == MDTableType.genericParam) alias getCollection =            genericParamCollection;
        else static if (md == MDTableType.methodSpec) alias getCollection =              methodSpecCollection;
        else static if (md == MDTableType.genericParamConstraint) alias getCollection =  genericParamConstraintCollection;
        else static assert(false, "Unsupported table");
    }

    public const Collection!(MDTableType.module_) moduleCollection;
    public const Collection!(MDTableType.typeRef) typeRefCollection;
    public const Collection!(MDTableType.typeDef) typeDefCollection;
    public const Collection!(MDTableType.field) fieldCollection;
    public const Collection!(MDTableType.methodDef) methodDefCollection;
    public const Collection!(MDTableType.param) paramCollection;
    public const Collection!(MDTableType.interfaceImpl) interfaceImplCollection;
    public const Collection!(MDTableType.memberRef) memberRefCollection;
    public const Collection!(MDTableType.constant) constantCollection;
    public const Collection!(MDTableType.customAttribute) customAttributeCollection;
    public const Collection!(MDTableType.fieldMarshal) fieldMarshalCollection;
    public const Collection!(MDTableType.declSecurity) declSecurityCollection;
    public const Collection!(MDTableType.classLayout) classLayoutCollection;
    public const Collection!(MDTableType.fieldLayout) fieldLayoutCollection;
    public const Collection!(MDTableType.standAloneSig) standAloneSigCollection;
    public const Collection!(MDTableType.eventMap) eventMapCollection;
    public const Collection!(MDTableType.event) eventCollection;
    public const Collection!(MDTableType.propertyMap) propertyMapCollection;
    public const Collection!(MDTableType.property) propertyCollection;
    public const Collection!(MDTableType.methodSemantics) methodSemanticsCollection;
    public const Collection!(MDTableType.methodImpl) methodImplCollection;
    public const Collection!(MDTableType.moduleRef) moduleRefCollection;
    public const Collection!(MDTableType.typeSpec) typeSpecCollection;
    public const Collection!(MDTableType.implMap) implMapCollection;
    public const Collection!(MDTableType.fieldRVA) fieldRVACollection;
    public const Collection!(MDTableType.assembly) assemblyCollection;
    public const Collection!(MDTableType.assemblyProcessor) assemblyProcessorCollection;
    public const Collection!(MDTableType.assemblyOS) assemblyOSCollection;
    public const Collection!(MDTableType.assemblyRef) assemblyRefCollection;
    public const Collection!(MDTableType.assemblyRefProcessor) assemblyRefProcessorCollection;
    public const Collection!(MDTableType.assemblyRefOS) assemblyRefOSCollection;
    public const Collection!(MDTableType.file) fileCollection;
    public const Collection!(MDTableType.exportedType) exportedTypeCollection;
    public const Collection!(MDTableType.manifestResource) manifestResourceCollection;
    public const Collection!(MDTableType.nestedClass) nestedClassCollection;
    public const Collection!(MDTableType.genericParam) genericParamCollection;
    public const Collection!(MDTableType.methodSpec) methodSpecCollection;
    public const Collection!(MDTableType.genericParamConstraint) genericParamConstraintCollection;

private:
    const Tables* _tables;
    const Heaps* _heaps;
}

unittest
{
    Database d = Database(null, null);
    //auto t = d.getTable!(MDTableType.module_)();
}
