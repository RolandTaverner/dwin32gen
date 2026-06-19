module dwin32;

import std.digest : toHexString;
import std.file : exists, FileException, isDir, isFile, mkdirRecurse;
import std.path : buildPath, dirName, dirSeparator;
import std.stdio : File, writeln, writefln;

import args : printArgsHelp, parseArgsWithConfigFile;
import ps = painlessjson;

import climetadata.pe.storage : Storage;
import climetadata.mdtable.heaps;
import climetadata.mdtable.tables;
import climetadata.mdtable.type;
import climetadata.mdcollection.database;
import climetadata.mdcollection.entity;
import climetadata.mdcollection.entitytypes;

import options;

int main(string[] args)
{
	Options options;
    try
    {
        if (parseArgsWithConfigFile(options, args))
        {
            printArgsHelp(options, "CLI metadata JSON generator usage");
            return 1;
        }
    }
    catch(Exception e)
    {
        writeln("Error: ", e.message);
        printArgsHelp(options, "CLI metadata JSON generator usage");
        return 1;
    }

    if (options.meta.length == 0)
    {
        writeln("winmd file path can't be empty");
        return 1;
    }
    if (!exists(options.meta) || !isFile(options.meta))
    {
        writefln("%s is not a file or does not exist", options.meta);
        return 2;
    }

    if (options.outDir.length == 0)
    {
        writeln("Out direactory can't be empty");
        return 1;
    }
    if (exists(options.outDir) && !isDir(options.outDir))
    {
        writefln("%s is not a directory", options.outDir);
        return 2;
    }
    
    try
    {
        mkdirRecurse(options.outDir);
    }
    catch (FileException e)
    {
        writefln("can't create directory %s: %s", options.outDir, e.message);
        return 2;
    }

    auto storage = Storage(options.meta);
    writeln("Storage OK");
    auto tables = Tables(&storage);
    auto heaps = Heaps(storage.strings(), storage.guids(), storage.blobs());
    Database db = Database(&tables, &heaps);

    buildPath(options.outDir, "");

    dumpTable!(MDTableType.assembly)(db, options.outDir);
    dumpTable!(MDTableType.assemblyOS)(db, options.outDir);
    dumpTable!(MDTableType.assemblyProcessor)(db, options.outDir);
    dumpTable!(MDTableType.assemblyRef)(db, options.outDir);
    dumpTable!(MDTableType.assemblyRefOS)(db, options.outDir);
    // dumpTable!(MDTableType.assemblyRefProcessor)(db, options.outDir);
    // dumpTable!(MDTableType.classLayout)(db, options.outDir);
    // dumpTable!(MDTableType.constant)(db, options.outDir);
    // dumpTable!(MDTableType.customAttribute)(db, options.outDir);
    // dumpTable!(MDTableType.declSecurity)(db, options.outDir);
    // dumpTable!(MDTableType.event)(db, options.outDir);
    // dumpTable!(MDTableType.eventMap)(db, options.outDir);
    // dumpTable!(MDTableType.exportedType)(db, options.outDir);
    // dumpTable!(MDTableType.field)(db, options.outDir);
    // dumpTable!(MDTableType.fieldLayout)(db, options.outDir);
    // dumpTable!(MDTableType.fieldMarshal)(db, options.outDir);
    // dumpTable!(MDTableType.fieldRVA)(db, options.outDir);
    // dumpTable!(MDTableType.file)(db, options.outDir);
    // dumpTable!(MDTableType.genericParam)(db, options.outDir);
    // dumpTable!(MDTableType.genericParamConstraint)(db, options.outDir);
    // dumpTable!(MDTableType.implMap)(db, options.outDir);
    // dumpTable!(MDTableType.interfaceImpl)(db, options.outDir);
    // dumpTable!(MDTableType.manifestResource)(db, options.outDir);
    // dumpTable!(MDTableType.memberRef)(db, options.outDir);
    // dumpTable!(MDTableType.methodDef)(db, options.outDir);
    // dumpTable!(MDTableType.methodImpl)(db, options.outDir);
    // dumpTable!(MDTableType.methodSemantics)(db, options.outDir);
    // dumpTable!(MDTableType.methodSpec)(db, options.outDir);
    // dumpTable!(MDTableType.moduleRef)(db, options.outDir);
    // dumpTable!(MDTableType.module_)(db, options.outDir);
    // dumpTable!(MDTableType.nestedClass)(db, options.outDir);
    // dumpTable!(MDTableType.param)(db, options.outDir);
    // dumpTable!(MDTableType.property)(db, options.outDir);
    // dumpTable!(MDTableType.propertyMap)(db, options.outDir);
    // dumpTable!(MDTableType.standAloneSig)(db, options.outDir);
    // dumpTable!(MDTableType.typeDef)(db, options.outDir);
    // dumpTable!(MDTableType.typeRef)(db, options.outDir);
    // dumpTable!(MDTableType.typeSpec)(db, options.outDir);

    return 0;
}

void dumpTable(MDTableType md)(ref const Database db, in string outDir)
{
    auto collection = db.getCollection!md;
    if (collection.empty())
    {
        return;
    }

    auto filePath = buildPath(outDir, md.stringof ~ ".json");
    auto f = File(filePath, "w");
    f.writeln("{");
    f.writefln("\"table\": \"%s\",", md.stringof);
    f.writeln("\"rows\": [");

    bool isFirst = true;
    foreach(e; collection.items())
    {
        if (!isFirst)
        {
            f.writeln(",");
        }
        isFirst = false;

        string entityJson = entityToJSON(e);
        f.write(entityJson);
    }
    f.writeln("");

    f.writeln("]");
    f.writeln("}");
}

string entityToJSON(ref const AssemblyEntity e)
{
    struct AssemblyJS
    {
        uint HashAlgId;
        ulong Version;
        uint Flags;
        string PublicKey;
        string Name;
        string Culture;
    }

    AssemblyJS t = AssemblyJS(
        e.getHashAlgId(), 
        e.getVersion(),
        e.getFlags(),
        e.getPublicKey().toHexString(),
        e.getName(),
        e.getCulture(),
        );

    return ps.toJSON(t).toString();
}

string entityToJSON(ref const AssemblyOSEntity e)
{
    struct AssemblyOSJS
    {
        uint OSPlatformID;
        uint OSMajorVersion;
        uint OSMinorVersion;
    }

    AssemblyOSJS t = AssemblyOSJS(
        e.getOSPlatformID(), 
        e.getOSMajorVersion(),
        e.getOSMinorVersion(),
        );

    return ps.toJSON(t).toString();
}

string entityToJSON(ref const AssemblyProcessorEntity e)
{
    struct AssemblyProcessorJS
    {
        uint Processor;
    }

    AssemblyProcessorJS t = AssemblyProcessorJS(
        e.getProcessor(), 
        );

    return ps.toJSON(t).toString();
}

string entityToJSON(ref const AssemblyRefEntity e)
{
    struct AssemblyRefJS
    {
        ulong Version;
        uint Flags;
        string PublicKeyOrToken;
        string Name;
        string Culture;
        string HashValue;
    }

    AssemblyRefJS t = AssemblyRefJS(
        e.getVersion(),
        e.getFlags(),
        e.getPublicKeyOrToken().toHexString(),
        e.getName(),
        e.getCulture(),
        e.getHashValue().toHexString(),
        );

    return ps.toJSON(t).toString();
}

string entityToJSON(ref const AssemblyRefOSEntity e)
{
    struct AssemblyRefOSJS
    {
        uint OSPlatformId;
        uint OSMajorVersion;
        uint OSMinorVersion;
        uint AssemblyRef;
    }

    AssemblyRefOSJS t = AssemblyRefOSJS(
        e.getOSPlatformId(), 
        e.getOSMajorVersion(),
        e.getOSMinorVersion(),
        e._getIndexAssemblyRef().rowID,
        );

    return ps.toJSON(t).toString();
}

// string entityToJSON(MDTableType md)(ref const Entity!md e)
// {
    
//     return "{\"error\": \"unknown entity type\"}";
// }
