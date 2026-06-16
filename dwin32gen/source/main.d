module dwin32;

import std.stdio;
import std.algorithm;
import std.path;
import std.array;
import std.uni;
import std.string;
import std.container;
import std.file;
import std.range : padLeft, chain;
import std.conv;
import std.path: buildPath;
import std.getopt;
import std.math;
import std.regex;

import climetadata.pe.storage : Storage;
import climetadata.mdtable.tables;
import climetadata.mdtable.heaps;
import climetadata.mdcollection.database;
import climetadata.mdcollection.entitytypes;
import climetadata.mdcollection.entity;
import codegen.generator : Generator;

// void dumpDocumentation(std.stdio.File f, string doc, int level)
// {    
//     auto len = maxLineWidth - 3 - level * 4;    

//     foreach(line; doc.wrap(len).splitter('\n'))
//     {
//         if (line.length)
//         {
//             f.write("".padLeft(' ', level * 4));
//             f.write("///");
//             f.writeln(line);        
//         }
//     }

// }

// void dumpDocumentationReturn(std.stdio.File f, string ret, int level)
// {    
//     auto len = maxLineWidth - 3 - level * 4;     

//     if (ret.length)
//     {
//         f.write("".padLeft(' ', level * 4));
//         f.write("///");
//         f.writeln("Returns:");
//         len -= 4;
    
//         foreach(line; ret.wrap(len).splitter('\n'))
//         {
//             f.write("".padLeft(' ', level * 4));
//             f.write("///");
//             f.write("".padLeft(' ', 4));
//             f.writeln(line);
//         }
//     }
// }

// void dumpDocumentationParams(std.stdio.File f, MDMatcher doc, int level)
// {    
//     auto len = maxLineWidth - 3 - level * 4; 
//     if (!doc.params.empty)
//     {
//         dumpDocumentation(f, "Params:", level);
//         len -= 4;
//         foreach(p; doc.params)
//         {
//             f.write("".padLeft(' ', level * 4));
//             f.write("///");
//             f.write("".padLeft(' ', 4));
//             f.write(p.name);
//             f.write(" = ");            
//             auto wrp = p.description.wrap(len).splitter('\n');
//             if (!wrp.empty)
//             {
//                 f.writeln(wrp.front);
//                 wrp.popFront();
//                 foreach(line; wrp)
//                 {
//                     if (line.length)
//                     {
//                         f.write("".padLeft(' ', level * 4));
//                         f.write("///");
//                         f.write("".padLeft(' ', 4));
//                         f.write("".padLeft(' ', p.name.length + 3));
//                         f.writeln(line);
//                     }
//                 }
//             }         
//         }
//     }
    

// }

string[string] safeWords;

bool[string] skipInterfaces;
bool[string] skipMethods;

enum linkCleanup = ctRegex!(`<a .*?href="(.*?)">(.*?)<\/a>`, "g");
enum spaceCleanup = ctRegex!(r"(\r\n)+|\r+|\n+|\t+|\s\s+", "g");

string cleanText( string s)
{
    return replaceAll(replaceAll(s, linkCleanup, "$2"), spaceCleanup, " ");
}

struct MDMatcher
{
    private enum returnsPattern = ctRegex!(r"## -returns(.*?)(?=##)", "gs");
    private enum uidPattern = ctRegex!(r"UID: (.*)", "g");
    private enum descriptionPatternSmall = ctRegex!(r"description: (.*)", "g");
    private enum descriptionPatternBig = ctRegex!(r"## -description(.*?)(?=##)", "gs");
    private enum titlePattern = ctRegex!(r"title: (.*)", "g");
    private enum paramPattern = ctRegex!(r"### -param(.*?)(?=#)", "gs");
    private enum fieldPattern = ctRegex!(r"### -field(.*?)(?=#)", "gs");
    private enum keywordsPattern = ctRegex!(r"keywords: (.*)", "g");
    private string content;

    public this(string s)
    {
        content = s;
    }

    public bool isEnum()
    {
        return uid.startsWith("NE:");
    }

    public bool isFunction()
    {
        return uid.startsWith("NF:");
    }

    public bool isStruct()
    {
        return uid.startsWith("NS:");
    }

    public bool isInterface()
    {
        return uid.startsWith("NN:");
    }

    public bool isCallback()
    {
        return uid.startsWith("NC:");
    }

    public bool isClass()
    {
        return uid.startsWith("NL:");
    }

    public bool isIOCTL()
    {
        return uid.startsWith("NI:");
    }

    public string returns()
    {
        auto match = matchFirst(content, returnsPattern);
        return match.empty ? null : cleanText(match[0][12 .. $]); 
    }

    public string uid()
    {
        auto match = matchFirst(content, uidPattern);
        return match.empty ? null : match[0][5 .. $]; 
    }

    public string title()
    {
        auto match = matchFirst(content, titlePattern);
        return match.empty ? null : match[0][7 .. $]; 
    }

    public string keyFromUID()
    {
        auto s = uid;

        if (s.length > 3 && s[2] == ':')
            s = s[3 .. $];
        auto p = s.indexOf('.');
        if (p > 0)
            s = s[p + 1 .. $];
        
        while (s.startsWith('_'))        
            s = s[1 .. $];

        return s;
    }

    public string keyFromTitle()
    {
        auto s = title();
        auto q = s.indexOf(' ');
        s = s.replace("::", ".");
        return q > 0 ? s[0 .. q] : s;
    }


    public string description()
    {
        auto match = matchFirst(content, descriptionPatternBig);
        if (!match.empty) 
            return match.empty ? null : cleanText(match[0][16 .. $]);
        match = matchFirst(content, descriptionPatternSmall);
        return match.empty ? null : cleanText(match[0][13 .. $]);
    }

    public auto keywords()
    {

        return matchAll(content, keywordsPattern)
            .map!(a => a.hit.stripLeft("[").strip("]"))
            .fold!((a, b) => a ~ "," ~ b)("")
            .splitter(',')
            .map!(a => a.stripLeft("\" '").strip("\" '"))
            .filter!(a => a.length && !a.any!(b => b == ' ' || b == '\\' || b == '/' || b == ':'))
            .array
            .sort
            .uniq;
    }

    public bool match(string id)
    {
        return keywords.any!(a => a == id);
    }

    public auto params()
    {
        return matchAll(content, paramPattern)            
            .map!(a => MDParam(a.hit));    

    }

    public auto fields()
    {
        return matchAll(content, fieldPattern)
            .map!(a => MDField(a.hit));            
    }
}

struct MDParam
{

    private enum namePattern = ctRegex!(r"(?<=^### -param )([A-Za-z0-9_]*)", "g");
    private enum descriptionPattern = ctRegex!(r"(?<=\n).*", "gs");

    private string content;

    this(string s)
    {
        this.content = s;
    }

    public string name()
    {
        auto match = matchFirst(content, namePattern);
        return match.empty ? null : match[0];
    }

    public string description()
    {
        auto match = matchFirst(content, descriptionPattern);
        return match.empty ? null : cleanText(match[0]);
    }
}

struct MDField
{

    private enum namePattern = ctRegex!(r"(?<=^### -field )([A-Za-z0-9_]*)", "g");
    private enum descriptionPattern = ctRegex!(r"(?<=\n).*", "gs");
    private string content;

    this(string s)
    {
        this.content = s;
    }

    public string name()
    {
        auto match = matchFirst(content, namePattern);
        return match.empty ? null : match[0];
    }

    public string description()
    {
        auto match = matchFirst(content, descriptionPattern);
        return match.empty ? null : cleanText(match[0]);
    }
}

MDMatcher[string] docMatcher;

MDMatcher* findDoc(string name)
{
    auto matcher = name in docMatcher;
    //takes tooooooooooo long
    //if (matcher)
    //    return matcher;
    //foreach(m; docMatcher.byKeyValue)
    //{
    //    if(m.value.match(name))
    //        return m.key in docMatcher;
    //}
    if (!matcher)
        writefln("No doc match: %s", name);
    return matcher;
}

int main(string[] args)
{
    string mdFileName;
    string outDirectory;
    string cfgIgnoreFileName;
    string cfgReplaceFileName;
    string cfgCoreFileName;
    string docsDirectory;
    GetoptResult info;

    enum usage = 
        "Usage: \n" ~
        "  dwin32gen --meta <filename> --core <filename>\n" ~
        "  dwin32gen --meta <filename> --core <filename> --out <dir> --ignore <filename> --replace <filename>";

    try
    {
        info = getopt(args,
            config.required, "meta|m",     "winmd file to process",                &mdFileName, 
                             "out|o",      "output directory (defaults to 'out')", &outDirectory,
                             "ignore|i",   "namespaces to ignore",                 &cfgIgnoreFileName,
                             "replace|r",  "namespaces to replace",                &cfgReplaceFileName,
                             "docs|d",     "generate documentation",               &docsDirectory,
            config.required, "core|c",     "core.d file to be copied",             &cfgCoreFileName,
        );
    }
    catch(GetOptException e)
    {
        writeln(e.msg);        
        writeln(usage);
        writeln("  dwin32gen -h for help");
        return -1;
    }
    
    if (info.helpWanted)
    {
        writeln(usage);
        defaultGetoptPrinter("Windows bindings generator for D",
                             info.options);
        
        return 0;
    }
  
    if (outDirectory.length == 0)
        outDirectory = "out";

    if (docsDirectory.length && !exists(docsDirectory))
    {
        writefln("Mising sdk docs (%s)", buildNormalizedPath(absolutePath(docsDirectory)));
        return -1;
    }
   
    if (!exists(cfgCoreFileName))
    {
        writefln("Mising core.d (%s)", buildNormalizedPath(absolutePath(cfgCoreFileName)));
        return -1;
    }

    string[string] configNamespace;

    if (cfgReplaceFileName.length)
    {
        auto cfgReplaceFile = std.stdio.File(cfgReplaceFileName);
    
        foreach(line; cfgReplaceFile.byLine(KeepTerminator.no))
        {
            auto items = line.strip('\r').strip('\n').split('=');
            configNamespace[items[0].toLower.idup] = items[1].toLower.idup;
        }
    }

    string[] cfgIgnoredNamespaces;

    if (cfgIgnoreFileName.length)
    {
        auto cfgIgnoreFile = std.stdio.File(cfgIgnoreFileName);
        cfgIgnoredNamespaces = cfgIgnoreFile.byLine(KeepTerminator.no).map!(a => a.strip('\r').strip('\n').idup).array;
    }

    safeWords = [
        "abstract" : "abstract_",
        "alias" : "alias_",
        "align" : "align_",
        "auto" : "auto_",
        "body" : "body_",
        "byte" : "byte_",
        "cast" : "cast_",
        "cdouble" : "cdouble_",
        "cent" : "cent_",
        "cfloat" : "cfloat_",
        "class" : "class_",
        "creal" : "creal_",
        "dchar" : "dchar_",
        "debug" : "debug_",
        "default" : "default_",
        "delegate" : "delegate_",
        "delete" : "delete_",
        "deprecated" : "deprecated_",
        "export" : "export_",
        "extern" : "extern_",
        "false" : "false_",
        "final" : "final_",
        "finally" : "finally_",
        "foreach" : "foreach_",
        "foreach_reverse" : "foreach_reverse_",
        "function" : "function_",
        "idouble" : "idouble_",
        "ifloat" : "ifloat_",
        "immutable" : "immutable_",
        "import" : "import_",
        "in" : "in_",
        "inout" : "inout_",
        "interface" : "interface_",
        "invariant" : "invariant_",
        "ireal" : "ireal_",
        "is" : "is_",
        "lazy" : "lazy_",
        "macro" : "macro_",
        "mixin" : "mixin_",
        "module" : "module_",
        "nothrow" : "nothrow_",
        "null" : "null_",
        "out" : "out_",
        "override" : "override_",
        "package" : "package_",
        "pragma" : "pragma_",
        "pure" : "pure_",
        "real" : "real_",
        "ref" : "ref_",
        "scope" : "scope_",
        "shared" : "shared_",
        "struct" : "struct_",
        "super" : "super_",
        "true" : "true_",
        "typeof" : "typeof_",
        "ubyte" : "ubyte_",
        "ucent" : "ucent_",
        "uint" : "uint_",
        "ulong" : "ulong_",
        "unittest" : "unittest_",
        "ushort" : "ushort_",
        "version" : "version_",
        "wchar" : "wchar_",
        "with" : "with_",
        "__FILE__" : "FILE",
        "__FILE_FULL_PATH__" : "FILE_FULL_PATH",
        "__MODULE__" : "MODULE",
        "__LINE__" : "LINE",
        "__FUNCTION__" : "FUNCTION",
        "__PRETTY_FUNCTION__" : "PRETTY_FUNCTION",
        "__gshared" : "gshared",
        "__traits" : "traits",
        "__vector" : "vector",
        "__parameters" : "parameters",
        "GUID" : "Guid",
    ];

    skipInterfaces = [
        "IGraphicsEffectD2D1Interop" : true,
        "ICompositorInterop" : true,
        "ICompositionCapabilitiesInteropFactory" : true,
        "ICompositorDesktopInterop" : true,
        "IDesktopWindowContentBridgeInterop" : true,
        "IUIAutomation6": true
    ];

    skipMethods = [
        "CreateDispatcherQueueController" : true,
        "StackWalk": true,
        "SymGetLineNext": true,
        "SymGetLinePrev": true,
        "SymUnDName": true,
        "SymRegisterCallback": true,
        "SymGetSymFromAddr": true,
        "SymGetSymFromName": true,
        "SymEnumerateSymbols": true,
        "SymEnumerateSymbolsW": true,
        "SymGetSymNext": true,
        "SymGetSymPrev": true,
        "SymEnumerateModules": true,
        "EnumerateLoadedModules": true,
        "SymGetModuleInfo": true,
        "SymGetModuleInfoW": true,
        "SymGetLineFromAddr": true,
        "SymGetLineFromName": true,
    ];

    if (docsDirectory.length)
    {
        writeln("Parsing SDK documentation...");
        foreach(md; dirEntries(docsDirectory, "??-*-*.md", SpanMode.depth, false))
        {
            auto matcher = MDMatcher(readText(md.name));
            auto k1 = matcher.keyFromUID;
            auto k2 = matcher.keyFromTitle;
            docMatcher[k1] = matcher;
            if (k2 != k1)
                docMatcher[k2] = matcher;
        }
        docMatcher.rehash();
    }

    auto storage = Storage(mdFileName);
    writeln("Storage OK");
    auto tables = Tables(&storage);
    auto heaps = Heaps(storage.strings(), storage.guids(), storage.blobs());
    Database db = Database(&tables, &heaps);

    Generator codeGen = Generator(&db, cfgIgnoredNamespaces, configNamespace, cfgCoreFileName, safeWords, skipInterfaces, skipMethods, outDirectory);

    codeGen.generate();

    writeln("generate() done");
    return 0;
}
