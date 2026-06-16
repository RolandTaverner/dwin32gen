module climetadata.mdtable.type;

public enum MDTableType
{
    assembly, // 0x20
    assemblyOS, // 0x22
    assemblyProcessor, // 0x21
    assemblyRef, // 0x23
    assemblyRefOS, // 0x25
    assemblyRefProcessor, // 0x24
    classLayout, // 0x0F 
    constant, // 0x0B
    customAttribute, // 0x0C
    declSecurity, // 0x0E
    event, // 0x14
    eventMap, // 0x12
    exportedType, // 0x27 
    field, // 0x04
    fieldLayout, // 0x10 
    fieldMarshal, // 0x0D
    fieldRVA, // 0x1D
    file, // 0x26
    genericParam, // 0x2A
    genericParamConstraint, // 0x2C 
    implMap, // 0x1C
    interfaceImpl, // 0x09
    manifestResource, // 0x28
    memberRef, // 0x0A
    methodDef, // 0x06
    methodImpl, // 0x19 
    methodSemantics, // 0x18
    methodSpec, // 0x2B
    moduleRef, // 0x1A
    module_, // 0x00
    nestedClass, // 0x29
    param, // 0x08
    property, // 0x17 
    propertyMap, // 0x15 
    standAloneSig, // 0x11
    typeDef, // 0x02 
    typeRef, // 0x01
    typeSpec, // 0x1B 
    unknown,
}
