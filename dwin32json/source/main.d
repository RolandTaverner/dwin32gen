module dwin32;

import std.stdio;
import std.array;
import std.uni;
import std.string;
import std.file : exists, isDir, isFile, mkdirRecurse;
import std.conv;
import std.path : buildPath, dirName, dirSeparator;
import std.math;

import args : printArgsHelp, parseArgsWithConfigFile;

import climetadata.pe.storage : Storage;
import climetadata.mdtable.tables;
import climetadata.mdtable.heaps;
import climetadata.mdcollection.database;
import climetadata.mdcollection.entitytypes;
import climetadata.mdcollection.entity;

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

    auto storage = Storage(options.meta);
    writeln("Storage OK");
    auto tables = Tables(&storage);
    auto heaps = Heaps(storage.strings(), storage.guids(), storage.blobs());
    Database db = Database(&tables, &heaps);

    // Generator codeGen = Generator(&db, cfgIgnoredNamespaces, configNamespace, cfgCoreFileName, safeWords, skipInterfaces, skipMethods, outDirectory);

    // codeGen.generate();

    // writeln("generate() done");
    return 0;
}
