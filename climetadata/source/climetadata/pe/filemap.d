module climetadata.pe.filemap;

version (Windows)
{
    import core.sys.windows.winbase;
    import core.sys.windows.winnt;
    import std.utf;
}
else version (Posix)
{
    import core.sys.posix.fcntl;
    import core.sys.posix.sys.mman;
    import core.sys.posix.sys.stat;
    import core.sys.posix.unistd;
}
else
{
    static assert(false, "Unsupported environment");
}

import std.exception : enforce;
import std.format : format;

// FileMap creates MMF using CreateFileMappingW (Windows) or mmap (Posix)
struct FileMap
{
private:
    version (Windows)
    {
        HANDLE fileHandle = INVALID_HANDLE_VALUE;
        HANDLE mapHandle = INVALID_HANDLE_VALUE;
    }
    else version (Posix)
    {
        int fileDescriptor = -1;
    }

    const(ubyte)* m_memory;
    size_t m_size;

public:

    @disable this();
    @disable this(this);
    @disable void opAssign(FileMap);

    this(in string fileName)
    {
        version (Windows)
        {
            fileHandle = CreateFileW(toUTF16z(fileName), GENERIC_READ, FILE_SHARE_READ, null, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, null);
            if (fileHandle == INVALID_HANDLE_VALUE)
            {
                auto err = GetLastError();
            }
            enforce(fileHandle != INVALID_HANDLE_VALUE, format("Cannot open file '%s'", fileName));
            LARGE_INTEGER sz;
            GetFileSizeEx(fileHandle, &sz);
            m_size = cast(size_t)(sz.QuadPart);
            if (m_size > 0)
            {
                mapHandle = CreateFileMappingW(fileHandle, null, PAGE_READONLY, 0, 0, null);
                enforce(mapHandle != INVALID_HANDLE_VALUE, format("Cannot map file '%s' into memory", fileName));
                m_memory = cast(ubyte*) MapViewOfFileEx(mapHandle, FILE_MAP_READ, 0, 0, 0, null);
                enforce(m_memory, "Cannot read file ''%s'");
            }
        }
        else version (Posix)
        {
            fileDescriptor = open(fileName.ptr, O_RDONLY, 0);
            enforce(fileHandle != -1, format("Cannot open file '%s'", fileName));
            stat_t stat;
            enforce(fstat(fd, &stat) >= 0, format("Cannot obtain file size for '%s'", fileName));
            m_size = cast(size_t)(stat.st_size);
            if (m_size > 0)
            {
                m_memory = mmap(null, size, PROT_READ, MAP_PRIVATE | MAP_POPULATE, fileDescriptor, 0);
                enforce(m_memory != MAP_FAILED, "Cannot read file ''%s'");
            }
        }
    }

    ~this()
    {
        version (Windows)
        {
            if (m_memory)
            {
                UnmapViewOfFile(m_memory);
                m_memory = null;
            }
            if (mapHandle != INVALID_HANDLE_VALUE)
            {
                CloseHandle(mapHandle);
                mapHandle = INVALID_HANDLE_VALUE;
            }
            if (fileHandle != INVALID_HANDLE_VALUE)
            {
                CloseHandle(fileHandle);
                fileHandle = INVALID_HANDLE_VALUE;
            }
        }
        else version (Posix)
        {
            if (m_memory)
                munmap(memory, size);
            if (fileDescriptor != -1)
                close(fileDescriptor);
        }
    }

    const(ubyte)[] memory() const
    {
        return m_memory[0 .. m_size];
    }

    size_t size() const
    {
        return m_size;
    }
}
