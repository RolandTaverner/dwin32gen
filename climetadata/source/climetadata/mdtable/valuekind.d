module climetadata.mdtable.valuekind;

public enum ValueKind
{
    Unused,
    Integral, // Integer number
    Guid, // Index in Guids heap
    String, // offset in Strings heap
    Blob, // offset in Blobs heap
    Index, // Index in some table
    CodedIndex // Coded index in some tables
}
