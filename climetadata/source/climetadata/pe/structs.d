module climetadata.pe.structs;

// https://learn.microsoft.com/en-us/windows/win32/debug/pe-format

align(2) struct ImageDosHeader
{
    ushort e_signature; // Magic number ("MZ")
    ushort e_cblp; // Bytes on last page of file
    ushort e_cp; // Pages in file
    ushort e_crlc; // Relocations
    ushort e_cparhdr; // Size of header in paragraphs
    ushort e_minalloc; // Minimum extra paragraphs needed
    ushort e_maxalloc; // Maximum extra paragraphs needed
    ushort e_ss; // Initial (relative) SS value
    ushort e_sp; // Initial SP value
    ushort e_csum; // Checksum
    ushort e_ip; // Initial IP value
    ushort e_cs; // Initial (relative) CS value
    ushort e_lfarlc; // File address of relocation table
    ushort e_ovno; // Overlay number
    ushort[4] e_res; // Reserved words
    ushort e_oemid; // OEM identifier (for e_oeminfo)
    ushort e_oeminfo; // OEM information; e_oemid specific
    ushort[10] e_res2; // Reserved words
    int e_lfanew; // File address of new exe header (PE header)
}

unittest
{
    assert(ImageDosHeader.sizeof == 64);
}

align(4) struct ImageFileHeader
{
    ushort machine;
    ushort numberOfSections;
    uint timeDateStamp;
    uint pointerToSymbolTable;
    uint numberOfSymbols;
    ushort sizeOfOptionalHeader;
    ushort characteristics;
}

align(4) struct ImageDataDirectory
{
    uint virtualAddress;
    uint size;
}

unittest
{
    assert(ImageDataDirectory.sizeof == 8);
}

struct ImageOptionalHeader32
{
    ushort magic;
    ubyte majorLinkerVersion;
    ubyte minorLinkerVersion;
    uint sizeOfCode;
    uint sizeOfInitializedData;
    uint sizeOfUninitializedData;
    uint addressOfEntryPoint;
    uint baseOfCode;
    uint baseOfData;
    uint imageBase;
    uint sectionAlignment;
    uint fileAlignment;
    ushort majorOperatingSystemVersion;
    ushort minorOperatingSystemVersion;
    ushort majorImageVersion;
    ushort minorImageVersion;
    ushort majorSubsystemVersion;
    ushort minorSubsystemVersion;
    uint win32VersionValue;
    uint sizeOfImage;
    uint sizeOfHeaders;
    uint checkSum;
    ushort subsystem;
    ushort dllCharacteristics;
    uint sizeOfStackReserve;
    uint sizeOfStackCommit;
    uint sizeOfHeapReserve;
    uint sizeOfHeapCommit;
    uint loaderFlags;
    uint numberOfRvaAndSizes;
    ImageDataDirectory[16] dataDirectory;
}

align(4) struct ImageNTHeaders32
{
    uint signature;
    ImageFileHeader fileHeader;
    ImageOptionalHeader32 optionalHeader;
}

unittest
{
    assert(ImageNTHeaders32.sizeof == 248);
}

struct ImageOptionalHeader32Plus
{
    ushort magic;
    ubyte majorLinkerVersion;
    ubyte minorLinkerVersion;
    uint sizeOfCode;
    uint sizeOfInitializedData;
    uint sizeOfUninitializedData;
    uint addressOfEntryPoint;
    uint baseOfCode;
    ulong imageBase;
    uint sectionAlignment;
    uint fileAlignment;
    ushort majorOperatingSystemVersion;
    ushort minorOperatingSystemVersion;
    ushort majorImageVersion;
    ushort minorImageVersion;
    ushort majorSubsystemVersion;
    ushort minorSubsystemVersion;
    uint win32VersionValue;
    uint sizeOfImage;
    uint sizeOfHeaders;
    uint checkSum;
    ushort subsystem;
    ushort dllCharacteristics;
    ulong sizeOfStackReserve;
    ulong sizeOfStackCommit;
    ulong sizeOfHeapReserve;
    ulong sizeOfHeapCommit;
    uint loaderFlags;
    uint numberOfRvaAndSizes;
    ImageDataDirectory[16] dataDirectory;
}

align(4) struct ImageNTHeaders32Plus
{
    uint signature;
    ImageFileHeader fileHeader;
    ImageOptionalHeader32Plus optionalHeader;
}

struct ImageSectionHeader
{
    ubyte[8] name;
    union
    {
        uint physicalAddress;
        uint virtualSize;
    }

    uint virtualAddress;
    uint sizeOfRawData;
    uint pointerToRawData;
    uint pointerToRelocations;
    uint pointerToLinenumbers;
    ushort numberOfRelocations;
    ushort numberOfLinenumbers;
    uint characteristics;
}

align(1) struct ImageCor20Header
{
    uint cb;
    ushort majorRuntimeVersion;
    ushort minorRuntimeVersion;
    ImageDataDirectory metaData;
    uint flags;
    union
    {
        uint entryPointToken;
        uint entryPointRVA;
    }

    ImageDataDirectory resources;
    ImageDataDirectory strongNameSignature;
    ImageDataDirectory codeManagerTable;
    ImageDataDirectory vTableFixups;
    ImageDataDirectory exportAddressTableJumps;
    ImageDataDirectory managedNativeHeader;
}

// Metadata root
// The root of the physical metadata starts with a magic signature, several bytes of version and other
// miscellaneous information, followed by a count and an array of stream headers, one for each stream that is
// present. The actual encoded tables and heaps are stored in the streams, which immediately follow this array of
// headers.
// See Common Language Infrastructure (CLI), Partition II: Metadata Definition and Semantics, 24.2.1 Metadata root
align(1) struct CLIMetadataRoot
{
    uint signature; // must be 0x424a5342u
    ushort majorVersion;
    ushort minorVersion;
    uint reserver;
    uint length; // Number of bytes allocated to hold version string (including null terminator), call this x.
    // version string
    // streams count
    // stream headers array
}
