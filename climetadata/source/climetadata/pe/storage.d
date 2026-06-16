module climetadata.pe.storage;

import std.exception : enforce;
import std.format : format;
import std.stdio : writeln;

import climetadata.pe.filemap : FileMap;
import structs = climetadata.pe.structs;
import climetadata.utils.memcast;

struct Storage
{
    @disable this();
    @disable this(this);

    public this(in string path)
    {
        fileMap = FileMap(path);
        enforce(fileMap.size() > structs.ImageDosHeader.sizeof, "File is too small to be a PE file");

        auto rawFileMem = fileMap.memory();

        // PE Format https://learn.microsoft.com/en-us/windows/win32/debug/pe-format

        auto dosHeader = asRef!(structs.ImageDosHeader)(rawFileMem);
        enforce(dosHeader.e_signature == 0x5a4d,
            format("Invalid PE signature (0x%04X)", dosHeader.e_signature));
        enforce(fileMap.size > dosHeader.e_lfanew + structs.ImageNTHeaders32.sizeof, "Invalid file size");

        auto ntHeader = asRef!(structs.ImageNTHeaders32)(rawFileMem, dosHeader.e_lfanew);
        enforce(ntHeader.optionalHeader.magic == 0x010B || ntHeader.optionalHeader.magic == 0x020B, 
            "invalid image type");
        enforce(ntHeader.fileHeader.numberOfSections > 0 && ntHeader.fileHeader.numberOfSections <= 100,
            format("Invalid number of sections (%d)", ntHeader.fileHeader.numberOfSections));

        const(structs.ImageSectionHeader)[] sectionHeaders;
        uint clrVA;
        size_t sectionHeadersOffset;
        if (ntHeader.optionalHeader.magic == 0x010B) // 32-bit image
        {
            clrVA = ntHeader.optionalHeader.dataDirectory[14].virtualAddress; // CLR header address
            sectionHeadersOffset = dosHeader.e_lfanew + structs.ImageNTHeaders32.sizeof;
        }
        else // 32-plus image
        {
            auto ntHeader32plus = asRef!(structs.ImageNTHeaders32Plus)(rawFileMem,
                dosHeader.e_lfanew);
            clrVA = ntHeader32plus.optionalHeader.dataDirectory[14].virtualAddress; // CLR header address
            sectionHeadersOffset = dosHeader.e_lfanew + structs.ImageNTHeaders32Plus.sizeof;
        }
        sectionHeaders = asArray!(structs.ImageSectionHeader)(rawFileMem, sectionHeadersOffset);
        sectionHeaders.length = ntHeader.fileHeader.numberOfSections;

        structs.ImageSectionHeader clrSectionHeader;
        enforce(sectionFromRVA(sectionHeaders, clrVA, clrSectionHeader), "CLI header is missing");

        auto cliHeaderOffset = offsetFromRVA(clrSectionHeader, clrVA);
        auto cliHeader = asRef!(structs.ImageCor20Header)(rawFileMem, cliHeaderOffset);
        enforce(cliHeader.cb == structs.ImageCor20Header.sizeof,
            format("Invalid CLI header size (%d bytes)", cliHeader.cb));

        enforce(sectionFromRVA(sectionHeaders, cliHeader.metaData.virtualAddress, clrSectionHeader), 
            "CLI metadata is missing");

        auto offset = offsetFromRVA(clrSectionHeader, cliHeader.metaData.virtualAddress);
        auto cliMagicNumber = asVal!uint(rawFileMem, offset);
        enforce(cliMagicNumber == 0x424a5342u, format("Invalid CLI metadata signature (0x%08X)", cliMagicNumber));
        auto cliMetadataRoot = asRef!(structs.CLIMetadataRoot)(rawFileMem, offset);
        enforce(cliMetadataRoot.signature == 0x424a5342u,
            format("Invalid CLI metadata signature (0x%08X)", cliMetadataRoot.signature));

        auto versionLength = cliMetadataRoot.length;

        auto streamCount = asVal!ushort(rawFileMem, offset + versionLength + 18);
        auto streamHeader = rawFileMem[offset + versionLength + 20 .. $]; // 1st stream header

        for (size_t i; i < streamCount; ++i)
        {
            auto stream = asRef!StreamRange(streamHeader);
            auto name = asString(streamHeader, 8);
            debug
            {
                writeln("Stream " ~ name ~ " found...");
            }

            auto heapBegin = offset + stream.offset;
            auto heapEnd = heapBegin + stream.size;

            if (name == "#Strings")
                stringsHeap = rawFileMem[heapBegin .. heapEnd];
            else if (name == "#Blob")
                blobsHeap = rawFileMem[heapBegin .. heapEnd];
            else if (name == "#GUID")
                guidsHeap = rawFileMem[heapBegin .. heapEnd];
            else if (name == "#~")
                tablesHeap = rawFileMem[heapBegin .. heapEnd];
            else
                enforce(name == "#US", "Unknown metadata stream (%s)", name);

            uint padding = 4 - name.length % 4;
            if (!padding)
                padding = 4;
            streamHeader = streamHeader[name.length + 8 + padding .. $]; // next stream header
        }
    }

    public ~this()
    {
    }

    pragma(inline, true)
    ref const(const(ubyte)[]) strings() const
    {
        return stringsHeap;
    }

    pragma(inline, true)
    ref const(const(ubyte)[]) blobs() const
    {
        return blobsHeap;
    }

    pragma(inline, true)
    ref const(const(ubyte)[]) guids() const
    {
        return guidsHeap;
    }

    pragma(inline, true)
    ref const(const(ubyte)[]) tables() const
    {
        return tablesHeap;
    }

private:
    FileMap fileMap;
    const(ubyte)[] stringsHeap;
    const(ubyte)[] blobsHeap;
    const(ubyte)[] guidsHeap;
    const(ubyte)[] tablesHeap;
}

struct TableDesc
{

}

private bool sectionFromRVA(const(structs.ImageSectionHeader)[] sectionHeaders,
    uint rva,
    ref structs.ImageSectionHeader section)
{
    for (size_t i; i < sectionHeaders.length; ++i)
    {
        if (sectionHeaders[i].virtualAddress <= rva
            && sectionHeaders[i].virtualAddress + sectionHeaders[i].virtualSize > rva)
        {
            section = sectionHeaders[i];
            return true;
        }
    }
    return false;
}

private uint offsetFromRVA(ref const structs.ImageSectionHeader sectionHeader, uint rva)
{
    return rva - sectionHeader.virtualAddress + sectionHeader.pointerToRawData;
}

private struct StreamRange
{
    uint offset;
    uint size;
}
