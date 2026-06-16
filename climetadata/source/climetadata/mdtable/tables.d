module climetadata.mdtable.tables;

import std.exception : enforce;
import std.format : format;

public import climetadata.mdtable.table;
public import climetadata.mdtable.type;
import climetadata.pe.storage;
import climetadata.utils.memcast;

struct Tables
{
    @disable this();
    @disable this(this);

    public this(in Storage* s)
    {
        storage = s;

        auto heapSizesBits = asVal!ubyte(storage.tables(), 6);
        const ubyte stringIndexSize = (heapSizesBits & 0x01) == 0x01 ? 4 : 2;
        const ubyte guidIndexSize = (heapSizesBits & 0x02) == 0x02 ? 4 : 2;
        const ubyte blobIndexSize = (heapSizesBits & 0x04) == 0x04 ? 4 : 2;

        // validTablesBits is a bit map
        ulong validTablesBits = asVal!ulong(storage.tables(), 8);

        auto tablesView = storage.tables()[24 .. $];
        uint[MDTableType] rowCounts;

        for (ubyte i; i < 64; ++i)
        {
            auto md = toMDTableType(i);

            if ((validTablesBits & 1UL) != 0)
            {
                enforce(md != MDTableType.unknown, format("Unknown metadata table (0x%02x)", i));
                rowCounts[md] = asVal!uint(tablesView);
                debug
                {
                    import std.conv;
                    import std.stdio;

                    writeln(i, " Table ", md.to!string, " rows ", rowCounts[md]);
                }
                tablesView = tablesView[4 .. $];
            } 
            else
            {
                rowCounts[md] = 0;
            }
            validTablesBits >>= 1;
        }

        const ubyte typeDefOrRefIndexSize
            = compositeIndexSize(rowCounts[MDTableType.typeDef], rowCounts[MDTableType.typeRef],
                rowCounts[MDTableType.typeSpec]);

        const ubyte hasConstantIndexSize
            = compositeIndexSize(rowCounts[MDTableType.field], rowCounts[MDTableType.param],
                rowCounts[MDTableType.property]);

        const ubyte hasCustomAttributeIndexSize
            = compositeIndexSize(rowCounts[MDTableType.methodDef], rowCounts[MDTableType.field],
                rowCounts[MDTableType.typeRef], rowCounts[MDTableType.typeDef],
                rowCounts[MDTableType.param], rowCounts[MDTableType.interfaceImpl],
                rowCounts[MDTableType.memberRef], rowCounts[MDTableType.module_],
                rowCounts[MDTableType.property], rowCounts[MDTableType.event],
                rowCounts[MDTableType.standAloneSig], rowCounts[MDTableType.moduleRef],
                rowCounts[MDTableType.typeSpec], rowCounts[MDTableType.assembly],
                rowCounts[MDTableType.assemblyRef], rowCounts[MDTableType.file],
                rowCounts[MDTableType.exportedType], rowCounts[MDTableType.manifestResource],
                rowCounts[MDTableType.genericParam], rowCounts[MDTableType.genericParamConstraint],
                rowCounts[MDTableType.methodSpec]);

        const ubyte hasFieldMarshalIndexSize
            = compositeIndexSize(rowCounts[MDTableType.field], rowCounts[MDTableType.param]);

        const ubyte hasDeclSecurityIndexSize
            = compositeIndexSize(rowCounts[MDTableType.typeDef], rowCounts[MDTableType.methodDef],
                rowCounts[MDTableType.assembly]);

        const ubyte memberRefParentIndexSize
            = compositeIndexSize(rowCounts[MDTableType.typeDef], rowCounts[MDTableType.typeRef],
                rowCounts[MDTableType.moduleRef],
                rowCounts[MDTableType.methodDef], rowCounts[MDTableType.typeSpec]);

        const ubyte hasSemanticsIndexSize
            = compositeIndexSize(rowCounts[MDTableType.event], rowCounts[MDTableType.property]);

        const ubyte methodDefOrRefIndexSize
            = compositeIndexSize(rowCounts[MDTableType.methodDef], rowCounts[MDTableType.memberRef]);

        const ubyte memberForwardedIndexSize
            = compositeIndexSize(rowCounts[MDTableType.field], rowCounts[MDTableType.methodDef]);

        const ubyte implementationIndexSize
            = compositeIndexSize(rowCounts[MDTableType.file], rowCounts[MDTableType.assemblyRef],
                rowCounts[MDTableType.exportedType]);

        const ubyte customAttributeTypeIndexSize
            = compositeIndexSize(rowCounts[MDTableType.methodDef], rowCounts[MDTableType.memberRef], 0, 0, 0);

        const ubyte resolutionScopeIndexSize
            = compositeIndexSize(rowCounts[MDTableType.module_], rowCounts[MDTableType.moduleRef],
                rowCounts[MDTableType.assemblyRef], rowCounts[MDTableType.typeRef]);

        const ubyte typeOrMethodDefIndexSize
            = compositeIndexSize(rowCounts[MDTableType.typeDef], rowCounts[MDTableType.methodDef]);

        // Attention: initialization order must be preserved because Table constructor updates tablesView

        moduleTable = Table!(MDTableType.module_)(tablesView, rowCounts[MDTableType.module_],
            [
                ColumnKindSize(ValueKind.Unused, 2), // Generation (a 2-byte value, reserved, shall be zero)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap) 
                ColumnKindSize(ValueKind.Guid, guidIndexSize), // Mvid (an index into the Guid heap; simply a Guid used to distinguish between two versions of the same module) 
                ColumnKindSize(ValueKind.Guid, guidIndexSize), // EncId (an index into the Guid heap; reserved, shall be zero)
                ColumnKindSize(ValueKind.Guid, guidIndexSize) // EncBaseId (an index into the Guid heap; reserved, shall be zero) 
            ]);

        typeRefTable = Table!(MDTableType.typeRef)(tablesView, rowCounts[MDTableType.typeRef],
            [
                ColumnKindSize(ValueKind.CodedIndex, resolutionScopeIndexSize), // ResolutionScope (an index into a Module, ModuleRef, AssemblyRef or TypeRef table, or null; more precisely, a ResolutionScope (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.String, stringIndexSize), // TypeName (an index into the String heap) 
                ColumnKindSize(ValueKind.String, stringIndexSize) // TypeNamespace (an index into the String heap) 
            ]);

        typeDefTable = Table!(MDTableType.typeDef)(tablesView, rowCounts[MDTableType.typeDef],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type TypeAttributes, §II.23.1.15) 
                ColumnKindSize(ValueKind.String, stringIndexSize), // TypeName (an index into the String heap) 
                ColumnKindSize(ValueKind.String, stringIndexSize), // TypeNamespace (an index into the String heap) 
                ColumnKindSize(ValueKind.CodedIndex, typeDefOrRefIndexSize), // Extends (an index into the TypeDef, TypeRef, or TypeSpec table; more precisely, a TypeDefOrRef (§II.24.2.6) coded index) 
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.field])), // FieldList (an index into the Field table; it marks the first of a contiguous run of Fields owned by this Type)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.methodDef])) // MethodList (an index into the MethodDef table; it marks the first of a continguous run of Methods owned by this Type)
            ]);

        fieldTable = Table!(MDTableType.field)(tablesView, rowCounts[MDTableType.field],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Flags (a 2-byte bitmask of type FieldAttributes, §II.23.1.5)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap) 
                ColumnKindSize(ValueKind.Blob, blobIndexSize) // Signature (an index into the Blob heap) 
            ]);

        methodDefTable = Table!(MDTableType.methodDef)(tablesView, rowCounts[MDTableType.methodDef],
            [
                ColumnKindSize(ValueKind.Integral, 4), // RVA (a 4-byte constant) 
                ColumnKindSize(ValueKind.Integral, 2), // ImplFlags (a 2-byte bitmask of type MethodImplAttributes, §II.23.1.10)
                ColumnKindSize(ValueKind.Integral, 2), // Flags (a 2-byte bitmask of type MethodAttributes, §II.23.1.10) 
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap) 
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Signature (an index into the Blob heap) 
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.param])) // ParamList (an index into the Param table)
            ]);

        paramTable = Table!(MDTableType.param)(tablesView, rowCounts[MDTableType.param],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Flags (a 2-byte bitmask of type ParamAttributes, §II.23.1.13) 
                ColumnKindSize(ValueKind.Integral, 2), // Sequence (a 2-byte constant) 
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap) 
            ]);

        interfaceImplTable = Table!(MDTableType.interfaceImpl)(tablesView, rowCounts[MDTableType.interfaceImpl],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // Class (an index into the TypeDef table) 
                ColumnKindSize(ValueKind.CodedIndex, typeDefOrRefIndexSize), // Interface (an index into the TypeDef, TypeRef, or TypeSpec table; more precisely, a TypeDefOrRef (§II.24.2.6) coded index)
            ]);

        memberRefTable = Table!(MDTableType.memberRef)(tablesView, rowCounts[MDTableType.memberRef],
            [
                ColumnKindSize(ValueKind.CodedIndex, memberRefParentIndexSize), // Class (an index into the MethodDef, ModuleRef,TypeDef, TypeRef, or TypeSpec tables; more precisely, a MemberRefParent (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Signature (an index into the Blob heap)
            ]);

        constantTable = Table!(MDTableType.constant)(tablesView, rowCounts[MDTableType.constant],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Type (a 1-byte constant, followed by a 1-byte padding zero); see §II.23.1.16
                ColumnKindSize(ValueKind.CodedIndex, hasConstantIndexSize), // Parent (an index into the Param, Field, or Property table; more precisely, a HasConstant (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Value (an index into the Blob heap)
            ]);

        customAttributeTable = Table!(MDTableType.customAttribute)(tablesView, rowCounts[MDTableType.customAttribute],
            [
                ColumnKindSize(ValueKind.CodedIndex, hasCustomAttributeIndexSize), // Parent (an index into a metadata table that has an associated HasCustomAttribute (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.CodedIndex, customAttributeTypeIndexSize), // Type (an index into the MethodDef or MemberRef table; more precisely, a CustomAttributeType (§II.24.2.6) coded index).
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Value (an index into the Blob heap)
            ]);

        fieldMarshalTable = Table!(MDTableType.fieldMarshal)(tablesView, rowCounts[MDTableType.fieldMarshal],
            [
                ColumnKindSize(ValueKind.CodedIndex, hasFieldMarshalIndexSize), // Parent (an index into Field or Param table; more precisely, a HasFieldMarshal (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // NativeType (an index into the Blob heap)
            ]);

        declSecurityTable = Table!(MDTableType.declSecurity)(tablesView, rowCounts[MDTableType.declSecurity],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Action (a 2-byte value)
                ColumnKindSize(ValueKind.CodedIndex, hasDeclSecurityIndexSize), // Parent (an index into the TypeDef, MethodDef, or Assembly table; more precisely, a HasDeclSecurity (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // PermissionSet (an index into the Blob heap)
            ]);

        classLayoutTable = Table!(MDTableType.classLayout)(tablesView, rowCounts[MDTableType.classLayout],
            [
                ColumnKindSize(ValueKind.Integral, 2), // PackingSize (a 2-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // ClassSize (a 4-byte constant)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // Parent (an index into the TypeDef table)
            ]);

        fieldLayoutTable = Table!(MDTableType.fieldLayout)(tablesView, rowCounts[MDTableType.fieldLayout],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Offset (a 4-byte constant)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.field])), // Field (an index into the Field table)
            ]);

        standAloneSigTable = Table!(MDTableType.standAloneSig)(tablesView, rowCounts[MDTableType.standAloneSig],
            [
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Signature (an index into the Blob heap)
            ]);

        eventMapTable = Table!(MDTableType.eventMap)(tablesView, rowCounts[MDTableType.eventMap],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // Parent (an index into the TypeDef table)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.event])), // EventList (an index into the Event table)
            ]);

        eventTable = Table!(MDTableType.event)(tablesView, rowCounts[MDTableType.event],
            [
                ColumnKindSize(ValueKind.Integral, 2), // EventFlags (a 2-byte bitmask of type EventAttributes, §II.23.1.4)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.CodedIndex, typeDefOrRefIndexSize), // EventType (an index into a TypeDef, a TypeRef, or TypeSpec table; more precisely, a TypeDefOrRef (§II.24.2.6) coded index)
            ]);

        propertyMapTable = Table!(MDTableType.propertyMap)(tablesView, rowCounts[MDTableType.propertyMap],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // Parent (an index into the TypeDef table)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.property])), // PropertyList (an index into the Property table)
            ]);

        propertyTable = Table!(MDTableType.property)(tablesView, rowCounts[MDTableType.property],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Flags (a 2-byte bitmask of type PropertyAttributes, §II.23.1.14)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Type (an index into the Blob heap) (The name of this column is misleading. It does not index a TypeDef or TypeRef table—instead it indexes the signature in the Blob heap of the Property)
            ]);

        methodSemanticsTable = Table!(MDTableType.methodSemantics)(tablesView, rowCounts[MDTableType.methodSemantics],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Semantics (a 2-byte bitmask of type MethodSemanticsAttributes, §II.23.1.12)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.methodDef])), // Method (an index into the MethodDef table)
                ColumnKindSize(ValueKind.CodedIndex, hasSemanticsIndexSize), // Association (an index into the Event or Property table; more precisely, a HasSemantics (§II.24.2.6) coded index)
            ]);

        methodImplTable = Table!(MDTableType.methodImpl)(tablesView, rowCounts[MDTableType.methodImpl],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // Class (an index into the TypeDef table)
                ColumnKindSize(ValueKind.CodedIndex, methodDefOrRefIndexSize), // MethodBody (an index into the MethodDef or MemberRef table; more precisely, a MethodDefOrRef (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.CodedIndex, methodDefOrRefIndexSize), // MethodDeclaration (an index into the MethodDef or MemberRef table; more precisely, a MethodDefOrRef (§II.24.2.6) coded index)
            ]);

        moduleRefTable = Table!(MDTableType.moduleRef)(tablesView, rowCounts[MDTableType.moduleRef],
            [
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
            ]);

        typeSpecTable = Table!(MDTableType.typeSpec)(tablesView, rowCounts[MDTableType.typeSpec],
            [
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Signature (index into the Blob heap, where the blob is formatted as specified in §II.23.2.14)
            ]);

        implMapTable = Table!(MDTableType.implMap)(tablesView, rowCounts[MDTableType.implMap],
            [
                ColumnKindSize(ValueKind.Integral, 2), // MappingFlags (a 2-byte bitmask of type PInvokeAttributes, §23.1.8)
                ColumnKindSize(ValueKind.CodedIndex, memberForwardedIndexSize), // MemberForwarded (an index into the Field or MethodDef table; more precisely, a MemberForwarded (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.String, stringIndexSize), // ImportName (an index into the String heap)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.moduleRef])), // ImportScope (an index into the ModuleRef table)
            ]);

        fieldRVATable = Table!(MDTableType.fieldRVA)(tablesView, rowCounts[MDTableType.fieldRVA],
            [
                ColumnKindSize(ValueKind.Integral, 4), // RVA (a 4-byte constant)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.field])), // Field (an index into Field table)
            ]);

        assemblyTable = Table!(MDTableType.assembly)(tablesView, rowCounts[MDTableType.assembly],
            [
                ColumnKindSize(ValueKind.Integral, 4), // HashAlgId (a 4-byte constant of type AssemblyHashAlgorithm, §II.23.1.1)
                ColumnKindSize(ValueKind.Integral, 8), // MajorVersion, MinorVersion, BuildNumber, RevisionNumber (each being 2-byte constants)
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type AssemblyFlags, §II.23.1.2)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // PublicKey (an index into the Blob heap)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Culture (an index into the String heap)
            ]);

        assemblyProcessorTable = Table!(MDTableType.assemblyProcessor)(tablesView,
            rowCounts[MDTableType.assemblyProcessor],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Processor (a 4-byte constant)
            ]);

        assemblyOSTable = Table!(MDTableType.assemblyOS)(tablesView, rowCounts[MDTableType.assemblyOS],
            [
                ColumnKindSize(ValueKind.Integral, 4), // OSPlatformID (a 4-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // OSMajorVersion (a 4-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // OSMinorVersion (a 4-byte constant)
            ]);

        assemblyRefTable = Table!(MDTableType.assemblyRef)(tablesView, rowCounts[MDTableType.assemblyRef],
            [
                ColumnKindSize(ValueKind.Integral, 8), // MajorVersion, MinorVersion, BuildNumber, RevisionNumber (each being 2-byte constants)
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type AssemblyFlags, §II.23.1.2)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // PublicKeyOrToken (an index into the Blob heap, indicating the public key or token that identifies the author of this Assembly)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Culture (an index into the String heap)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // HashValue (an index into the Blob heap)
            ]);

        assemblyRefProcessorTable = Table!(MDTableType.assemblyRefProcessor)(tablesView,
            rowCounts[MDTableType.assemblyRefProcessor],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Processor (a 4-byte constant)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.assemblyRef])), // AssemblyRef (an index into the AssemblyRef table)
            ]);

        assemblyRefOSTable = Table!(MDTableType.assemblyRefOS)(tablesView, rowCounts[MDTableType.assemblyRefOS],
            [
                ColumnKindSize(ValueKind.Integral, 4), // OSPlatformId (a 4-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // OSMajorVersion (a 4-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // OSMinorVersion (a 4-byte constant)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.assemblyRef])), // AssemblyRef (an index into the AssemblyRef table)
            ]);

        fileTable = Table!(MDTableType.file)(tablesView, rowCounts[MDTableType.file],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type FileAttributes, §II.23.1.6)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // HashValue (an index into the Blob heap)
            ]);

        exportedTypeTable = Table!(MDTableType.exportedType)(tablesView, rowCounts[MDTableType.exportedType],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type TypeAttributes, §II.23.1.15)
                ColumnKindSize(ValueKind.Integral, 4), // TypeDefId (a 4-byte index into a TypeDef table of another module in this Assembly)
                ColumnKindSize(ValueKind.String, stringIndexSize), // TypeName (an index into the String heap)
                ColumnKindSize(ValueKind.String, stringIndexSize), // TypeNamespace (an index into the String heap)
                ColumnKindSize(ValueKind.CodedIndex, implementationIndexSize), // Implementation. This is an index (more precisely, an Implementation (§II.24.2.6) coded index)
            ]);

        manifestResourceTable = Table!(MDTableType.manifestResource)(tablesView, rowCounts[MDTableType.manifestResource],
            [
                ColumnKindSize(ValueKind.Integral, 4), // Offset (a 4-byte constant)
                ColumnKindSize(ValueKind.Integral, 4), // Flags (a 4-byte bitmask of type ManifestResourceAttributes, §II.23.1.9)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (an index into the String heap)
                ColumnKindSize(ValueKind.CodedIndex, implementationIndexSize), // Implementation (an index into a File table, a AssemblyRef table, or null; more precisely, an Implementation (§II.24.2.6) coded index)
            ]);

        nestedClassTable = Table!(MDTableType.nestedClass)(tablesView, rowCounts[MDTableType.nestedClass],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // NestedClass (an index into the TypeDef table)
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.typeDef])), // EnclosingClass (an index into the TypeDef table)
            ]);

        genericParamTable = Table!(MDTableType.genericParam)(tablesView, rowCounts[MDTableType.genericParam],
            [
                ColumnKindSize(ValueKind.Integral, 2), // Number (the 2-byte index of the generic parameter, numbered left-to-right, from zero)
                ColumnKindSize(ValueKind.Integral, 2), // Flags (a 2-byte bitmask of type GenericParamAttributes, §II.23.1.7)
                ColumnKindSize(ValueKind.CodedIndex, typeOrMethodDefIndexSize), // Owner (an index into the TypeDef or MethodDef table, specifying the Type or Method to which this generic parameter applies; more precisely, a TypeOrMethodDef (§II.24.2.6) coded index)
                ColumnKindSize(ValueKind.String, stringIndexSize), // Name (a non-null index into the String heap, giving the name for the generic parameter. This is purely descriptive and is used only by source language compilers and by Reflection)
            ]);

        methodSpecTable = Table!(MDTableType.methodSpec)(tablesView, rowCounts[MDTableType.methodSpec],
            [
                ColumnKindSize(ValueKind.CodedIndex, typeOrMethodDefIndexSize), // Method (an index into the MethodDef or MemberRef table, specifying to which generic method this row refers; that is, which generic method this row is an instantiation of; more precisely, a MethodDefOrRef (§II.24.2.6) coded index) 
                ColumnKindSize(ValueKind.Blob, blobIndexSize), // Instantiation (an index into the Blob heap (§II.23.2.15), holding the signature of this instantiation)
            ]);

        genericParamConstraintTable = Table!(MDTableType.genericParamConstraint)(tablesView,
            rowCounts[MDTableType.genericParamConstraint],
            [
                ColumnKindSize(ValueKind.Index, indexSize(rowCounts[MDTableType.genericParam])), // Owner (an index into the GenericParam table, specifying to which generic parameter this row refers)
                ColumnKindSize(ValueKind.CodedIndex, typeDefOrRefIndexSize), // Constraint (an index into the TypeDef, TypeRef, or TypeSpec tables, specifying from which class this generic parameter is constrained to derive; or which interface this generic parameter is constrained to implement; more precisely, a TypeDefOrRef (§II.24.2.6) coded index) 
            ]);
    }

    public template getTable(MDTableType md)
    {
        static if (md == MDTableType.module_) alias getTable =                      moduleTable;
        else static if (md == MDTableType.typeRef) alias getTable =                 typeRefTable;
        else static if (md == MDTableType.typeDef) alias getTable =                 typeDefTable;
        else static if (md == MDTableType.field) alias getTable =                   fieldTable;
        else static if (md == MDTableType.methodDef) alias getTable =               methodDefTable;
        else static if (md == MDTableType.param) alias getTable =                   paramTable;
        else static if (md == MDTableType.interfaceImpl) alias getTable =           interfaceImplTable;
        else static if (md == MDTableType.memberRef) alias getTable =               memberRefTable;
        else static if (md == MDTableType.constant) alias getTable =                constantTable;
        else static if (md == MDTableType.customAttribute) alias getTable =         customAttributeTable;
        else static if (md == MDTableType.fieldMarshal) alias getTable =            fieldMarshalTable;
        else static if (md == MDTableType.declSecurity) alias getTable =            declSecurityTable;
        else static if (md == MDTableType.classLayout) alias getTable =             classLayoutTable;
        else static if (md == MDTableType.fieldLayout) alias getTable =             fieldLayoutTable;
        else static if (md == MDTableType.standAloneSig) alias getTable =           standAloneSigTable;
        else static if (md == MDTableType.eventMap) alias getTable =                eventMapTable;
        else static if (md == MDTableType.event) alias getTable =                   eventTable;
        else static if (md == MDTableType.propertyMap) alias getTable =             propertyMapTable;
        else static if (md == MDTableType.property) alias getTable =                propertyTable;
        else static if (md == MDTableType.methodSemantics) alias getTable =         methodSemanticsTable;
        else static if (md == MDTableType.methodImpl) alias getTable =              methodImplTable;
        else static if (md == MDTableType.moduleRef) alias getTable =               moduleRefTable;
        else static if (md == MDTableType.typeSpec) alias getTable =                typeSpecTable;
        else static if (md == MDTableType.implMap) alias getTable =                 implMapTable;
        else static if (md == MDTableType.fieldRVA) alias getTable =                fieldRVATable;
        else static if (md == MDTableType.assembly) alias getTable =                assemblyTable;
        else static if (md == MDTableType.assemblyProcessor) alias getTable =       assemblyProcessorTable;
        else static if (md == MDTableType.assemblyOS) alias getTable =              assemblyOSTable;
        else static if (md == MDTableType.assemblyRef) alias getTable =             assemblyRefTable;
        else static if (md == MDTableType.assemblyRefProcessor) alias getTable =    assemblyRefProcessorTable;
        else static if (md == MDTableType.assemblyRefOS) alias getTable =           assemblyRefOSTable;
        else static if (md == MDTableType.file) alias getTable =                    fileTable;
        else static if (md == MDTableType.exportedType) alias getTable =            exportedTypeTable;
        else static if (md == MDTableType.manifestResource) alias getTable =        manifestResourceTable;
        else static if (md == MDTableType.nestedClass) alias getTable =             nestedClassTable;
        else static if (md == MDTableType.genericParam) alias getTable =            genericParamTable;
        else static if (md == MDTableType.methodSpec) alias getTable =              methodSpecTable;
        else static if (md == MDTableType.genericParamConstraint) alias getTable =  genericParamConstraintTable;
        else static assert(false, "Unsupported table");
    }

    public const Table!(MDTableType.module_) moduleTable;
    public const Table!(MDTableType.typeRef) typeRefTable;
    public const Table!(MDTableType.typeDef) typeDefTable;
    public const Table!(MDTableType.field) fieldTable;
    public const Table!(MDTableType.methodDef) methodDefTable;
    public const Table!(MDTableType.param) paramTable;
    public const Table!(MDTableType.interfaceImpl) interfaceImplTable;
    public const Table!(MDTableType.memberRef) memberRefTable;
    public const Table!(MDTableType.constant) constantTable;
    public const Table!(MDTableType.customAttribute) customAttributeTable;
    public const Table!(MDTableType.fieldMarshal) fieldMarshalTable;
    public const Table!(MDTableType.declSecurity) declSecurityTable;
    public const Table!(MDTableType.classLayout) classLayoutTable;
    public const Table!(MDTableType.fieldLayout) fieldLayoutTable;
    public const Table!(MDTableType.standAloneSig) standAloneSigTable;
    public const Table!(MDTableType.eventMap) eventMapTable;
    public const Table!(MDTableType.event) eventTable;
    public const Table!(MDTableType.propertyMap) propertyMapTable;
    public const Table!(MDTableType.property) propertyTable;
    public const Table!(MDTableType.methodSemantics) methodSemanticsTable;
    public const Table!(MDTableType.methodImpl) methodImplTable;
    public const Table!(MDTableType.moduleRef) moduleRefTable;
    public const Table!(MDTableType.typeSpec) typeSpecTable;
    public const Table!(MDTableType.implMap) implMapTable;
    public const Table!(MDTableType.fieldRVA) fieldRVATable;
    public const Table!(MDTableType.assembly) assemblyTable;
    public const Table!(MDTableType.assemblyProcessor) assemblyProcessorTable;
    public const Table!(MDTableType.assemblyOS) assemblyOSTable;
    public const Table!(MDTableType.assemblyRef) assemblyRefTable;
    public const Table!(MDTableType.assemblyRefProcessor) assemblyRefProcessorTable;
    public const Table!(MDTableType.assemblyRefOS) assemblyRefOSTable;
    public const Table!(MDTableType.file) fileTable;
    public const Table!(MDTableType.exportedType) exportedTypeTable;
    public const Table!(MDTableType.manifestResource) manifestResourceTable;
    public const Table!(MDTableType.nestedClass) nestedClassTable;
    public const Table!(MDTableType.genericParam) genericParamTable;
    public const Table!(MDTableType.methodSpec) methodSpecTable;
    public const Table!(MDTableType.genericParamConstraint) genericParamConstraintTable;

private:
    const Storage* storage;
}

private MDTableType toMDTableType(ubyte index)
{
    switch (index)
    {
    case 0x00:
        return MDTableType.module_;
    case 0x01:
        return MDTableType.typeRef;
    case 0x02:
        return MDTableType.typeDef;
    case 0x04:
        return MDTableType.field;
    case 0x06:
        return MDTableType.methodDef;
    case 0x08:
        return MDTableType.param;
    case 0x09:
        return MDTableType.interfaceImpl;
    case 0x0a:
        return MDTableType.memberRef;
    case 0x0b:
        return MDTableType.constant;
    case 0x0c:
        return MDTableType.customAttribute;
    case 0x0d:
        return MDTableType.fieldMarshal;
    case 0x0e:
        return MDTableType.declSecurity;
    case 0x0f:
        return MDTableType.classLayout;
    case 0x10:
        return MDTableType.fieldLayout;
    case 0x11:
        return MDTableType.standAloneSig;
    case 0x12:
        return MDTableType.eventMap;
    case 0x14:
        return MDTableType.event;
    case 0x15:
        return MDTableType.propertyMap;
    case 0x17:
        return MDTableType.property;
    case 0x18:
        return MDTableType.methodSemantics;
    case 0x19:
        return MDTableType.methodImpl;
    case 0x1a:
        return MDTableType.moduleRef;
    case 0x1b:
        return MDTableType.typeSpec;
    case 0x1c:
        return MDTableType.implMap;
    case 0x1d:
        return MDTableType.fieldRVA;
    case 0x20:
        return MDTableType.assembly;
    case 0x21:
        return MDTableType.assemblyProcessor;
    case 0x22:
        return MDTableType.assemblyOS;
    case 0x23:
        return MDTableType.assemblyRef;
    case 0x24:
        return MDTableType.assemblyRefProcessor;
    case 0x25:
        return MDTableType.assemblyRefOS;
    case 0x26:
        return MDTableType.file;
    case 0x27:
        return MDTableType.exportedType;
    case 0x28:
        return MDTableType.manifestResource;
    case 0x29:
        return MDTableType.nestedClass;
    case 0x2a:
        return MDTableType.genericParam;
    case 0x2b:
        return MDTableType.methodSpec;
    case 0x2c:
        return MDTableType.genericParamConstraint;
    default:
        return MDTableType.unknown;
    }
}

private ubyte bitsNeeded(R...)(R rowCounts)
{
    static if (R.length == 1)
    {
        auto rc = rowCounts[0];
        if (!rc)
            return 0;
        ubyte r = 1;
        --rc;
        while (rc >>= 1)
            ++r;
        return r;
    }
    else
    {
        auto t1 = bitsNeeded(rowCounts[0]);
        auto t2 = bitsNeeded(rowCounts[1 .. $]);
        return t1 > t2 ? t1 : t2;
    }
}

private ubyte compositeIndexSize(R...)(R rowCounts)
{
    return (bitsNeeded(rowCounts) + bitsNeeded(R.length) <= 16) ? 2 : 4;
}

private ubyte indexSize(uint rowCount)
{
    return rowCount <= 0xffff ? 2 : 4;
}
