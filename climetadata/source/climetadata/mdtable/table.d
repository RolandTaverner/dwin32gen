module climetadata.mdtable.table;

import std.exception : enforce;
import std.format : format;
import std.traits : isIntegral;
import std.typecons : Nullable, Tuple;

public import climetadata.mdtable.type;
public import climetadata.mdtable.row : Row;
public import climetadata.mdtable.value;
public import climetadata.mdtable.valuekind;

public alias ColumnKindSize = Tuple!(ValueKind, "kind", ubyte, "size");

public struct Table(MDTableType md)
{
    @disable this();

    public this(ref const(ubyte)[] tablesHeap, uint rowCount, ColumnKindSize[] colKS)
    {
        tableType = md;
        assert(colKS.length >= 1, "table must have at least 1 column");
        assert(colKS.length <= 6, "table must have 6 columns at most");
        assert(colKS[0].size != 0, "size of 1st column can't be 0");

        uint rowSize = 0;
        foreach (c; colKS)
        {
            assert(c.size <= 8, "column size must be 8 bytes at most");
            rowSize += c.size;
        }

        this.rowCount = rowCount;
        this.rowSize = rowSize;

        this.data = tablesHeap[0 .. rowCount * rowSize];
        tablesHeap = tablesHeap[rowCount * rowSize .. $];

        const(ColumnDesc)[] columnDescs = [];
        ushort offset = 0;
        foreach (c; colKS)
        {
            columnDescs ~= ColumnDesc(offset, c.size, c.kind);
            offset += c.size;
        }

        this.columns = columnDescs;
    }

    // getValue returns column value for row at index rowIndex. Row index is 0-based
    public Value!(T, K) getValue(T, ValueKind K)(uint rowIndex, uint column) const if (isIntegral!T)
    {
        enforce(rowIndex < rowCount, format("Invalid rowIndex (%d of %d)", rowIndex, rowCount));
        enforce(column < columns.length, format("Invalid column (%d of %d)", column, columns.length));
        auto colDesc = columns[column];
        assert(colDesc.size == 1 || colDesc.size == 2 || colDesc.size == 4 || colDesc.size == 8, "column size must be 1, 2, 4 or 8 bytes");
        assert(colDesc.size <= T.sizeof, "Value type size must be >= column size");
        assert(colDesc.kind == K, format("kind mismatch %s, expected %s for column %d at table %s, cols %s", K, colDesc.kind, column, md.stringof, columns));

        auto ptr = data.ptr + rowIndex * rowSize + colDesc.offset;

        T value;

        switch (colDesc.size)
        {
        case 1:
            value = cast(T)(*ptr);
            break;
        case 2:
            value = cast(T)(*cast(const(ushort)*) ptr);
            break;
        case 4:
            value = cast(T)(*cast(const(uint)*) ptr);
            break;
        default:
            value = cast(T)(*cast(const(ulong)*) ptr);
        }

        return Value!(T, K)(value);
    }

    // rowID is 1-based
    public Row!md opIndex(uint rowID) const
    {
        return Row!md(&this, rowID);
    }

    public TableListEnumerator!md items() const
    {
        static if (md == MDTableType.typeDef)
        {
            // In CLI metadata, the TypeDef table's first row is a mandatory dummy entry (Flags == 0x200000) representing a "null" type.
            // This entry is empty, serving as a placeholder to ensure that any TypeDef token value has a valid, non-zero entry,
            // acting as a null reference in the table.
            const uint startRowID = 2;
        }
        else
        {
            const uint startRowID = 1;
        }
        const uint endRowID = rowCount + 1;

        return TableListEnumerator!md(&this, startRowID, endRowID);
    }

    public TableListEnumerator!md list(uint startRowID, uint endRowID) const
    {
        assert(startRowID, "start rowID can't be 0");
        return TableListEnumerator!md(&this, startRowID, endRowID);
    }

    public TableListEnumerator!md emptyList() const
    {
        return .emptyList!md(&this);
    }

    public Row!md findParentFor(T)(in Value!(T, ValueKind.Index) referenceRowID, uint referenceColumn) const
    {
        assert(referenceRowID, "referenceRowID can't be 0");
        assert(referenceColumn < columns.length, "referenceColumn out of range");
        assert(columns[referenceColumn].kind == ValueKind.Index, "referenceColumn is not index column");

        enforce(rowCount != 0, format("Table %s is empty", md.stringof));

        uint rowID = 1;
        uint referenceValue = getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn);
        while (referenceValue < referenceRowID && rowID <= rowCount)
        {
            ++rowID;
            referenceValue = getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn);
        }

        enforce(referenceValue == referenceRowID,
            format("Missing parent reference to child (%s - %d)", md.stringof, referenceRowID));
        
        return this[rowID];
    }

    public TableRangeEnumerator!md range(T)(in Value!(T, ValueKind.Index) referenceRowID, uint referenceColumn) const
    {
        assert(referenceRowID != 0, "start referenceRowID can't be 0");
        assert(referenceColumn < columns.length, "referenceColumn out of range");
        assert(columns[referenceColumn].kind == ValueKind.Index, "referenceColumn is not index column");
        assert(columns[referenceColumn].size <= T.sizeof);

        return TableRangeEnumerator!md(&this, referenceRowID, referenceColumn);
    }

    public TableAllEnumerator!md all(T)(in Value!(T, ValueKind.Index) referenceRowID, uint referenceColumn) const
    {
        assert(referenceRowID != 0, "start referenceRowID can't be 0");
        assert(referenceColumn < columns.length, "referenceColumn out of range");
        assert(columns[referenceColumn].kind == ValueKind.Index, "referenceColumn is not index column");
        assert(columns[referenceColumn].size <= T.sizeof);

        return TableAllEnumerator!md(&this, referenceRowID, referenceColumn);
    }

    public TableCodedIndexRangeEnumerator!md codedIndexRange(T)(in Value!(T, ValueKind.CodedIndex) referenceCodedIndex, uint referenceColumn) const
    {
        assert(referenceCodedIndex != 0, "start referenceCodedIndex can't be 0");
        assert(referenceColumn < columns.length, "referenceColumn out of range");
        assert(columns[referenceColumn].kind == ValueKind.CodedIndex, "referenceColumn is not index column");
        assert(columns[referenceColumn].size <= T.sizeof);

        return TableCodedIndexRangeEnumerator!md(&this, referenceCodedIndex, referenceColumn);
    }

    public alias NullableRow = Nullable!(Row!md);
    
    public NullableRow findFirst(T)(in Value!(T, ValueKind.Index) referenceRowID, uint referenceColumn) const
    {
        auto findFirstRange = range!(T)(referenceRowID, referenceColumn);
        if (findFirstRange.empty())
        {
            return NullableRow.init;
        }
        return NullableRow(findFirstRange.front());
    }

    public NullableRow findFirstCodedIndex(T)(in Value!(T, ValueKind.CodedIndex) referenceCodedIndex, uint referenceColumn) const
    {
        auto findFirstRange = codedIndexRange!(T)(referenceCodedIndex, referenceColumn);
        if (findFirstRange.empty())
        {
            return NullableRow.init;
        }
        return NullableRow(findFirstRange.front());
    }

    const MDTableType tableType;
    private const uint rowSize;
    public const uint rowCount;
    public const(ColumnDesc[]) columns;
    private const(ubyte)[] data;
}

unittest
{
    const(ubyte)[] mockTablesHeap = [0, 1, 2, 3, 4, 5];
    auto testTable = Table!(MDTableType.unknown)(mockTablesHeap, 1,
        [
            ColumnKindSize(ValueKind.Unused, 2),
            ColumnKindSize(ValueKind.String, 4),
        ]);

    assert(testTable.columns.length == 2);

    assert(testTable.columns[0].offset == 0);
    assert(testTable.columns[0].size == 2);
    assert(testTable.columns[0].kind == ValueKind.Unused);

    assert(testTable.columns[1].offset == 2);
    assert(testTable.columns[1].size == 4);
    assert(testTable.columns[1].kind == ValueKind.String);
}

public struct ColumnDesc
{
    @disable this();

    public this(in ushort offset, in ushort size, in ValueKind kind)
    {
        this.offset = offset;
        this.size = size;
        this.kind = kind;
    }

    public const ushort offset; // bytes
    public const ushort size; // bytes
    public const ValueKind kind;
}

bool isLastRow(MDTableType md)(scope ref const Row!md row)
{
    assert(row.getRowID() > 0 && row.getRowID() <= row.getTable().rowCount, "rowID out of bounds");
    return row.getRowID() == row.getTable().rowCount;
}

Row!md getNextRow(MDTableType md)(ref const Row!md row)
{
    assert(!isLastRow(row), "can't get next row for last row");
    auto nextRowID = row.getRowID() + 1;
    return (*row.getTable())[nextRowID];
}

// Half-open sequence [startRowID, endRowID)
public struct TableListEnumerator(MDTableType md)
{
    @disable this();
    
    private this(const(Table!md*) table, uint startRowID, uint endRowID)
    {
        this.table = table;
        currentRowID = startRowID;
        this.endRowID = endRowID ? endRowID : (table.rowCount + 1);
    }

    pragma(inline, true)
    public bool empty() const
    {
        return currentRowID >= endRowID;
    }

    pragma(inline, true)
    public void popFront()
    {
        assert(currentRowID < endRowID, "end of the reached");
        ++currentRowID;
    }

    pragma(inline, true)
    public Row!md front() const
    {
        assert(currentRowID < endRowID, "can't get value from list");
        return Row!md(table, currentRowID);
    }

private:
    const Table!md* table;
    uint currentRowID;
    const uint endRowID;
}

public TableListEnumerator!md emptyList(MDTableType md)(const(Table!md*) table)
{
    return TableListEnumerator!md(table, table.rowCount + 2, table.rowCount + 1);
}

// Returns contiguos range of rows referencing the given referenceRowID in another table
public struct TableRangeEnumerator(MDTableType md)
{
    @disable this();

    private this(const(Table!md*) table, uint referenceRowID, uint referenceColumn)
    {
        assert(referenceColumn < table.columns.length, "referenceColumn out of range");
        assert(table.columns[referenceColumn].kind == ValueKind.Index, "referenceColumn is not index column");

        this.table = table;
        this.referenceRowID = referenceRowID;
        this.referenceColumn = referenceColumn;

        rowID = 1;
        while (rowID <= table.rowCount)
        {
            auto referenceColumnValue = table.getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn);
            if (referenceColumnValue == referenceRowID)
                break;
            ++rowID;
        }
    }

    pragma(inline, true)
    bool empty() const
    {
        return rowID > table.rowCount || table.getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn) != referenceRowID;
    }

    pragma(inline, true)
    void popFront()
    {
        ++rowID;
    }

    pragma(inline, true)
    public Row!md front() const
    {
        return (*table)[rowID];
    }

private:
    const Table!md* table;
    const uint referenceRowID;
    const uint referenceColumn;
    uint rowID;
}

public struct TableAllEnumerator(MDTableType md)
{
    @disable this();

    private this(const(Table!md*) table, uint referenceRowID, uint referenceColumn)
    {
        assert(referenceColumn < table.columns.length, "referenceColumn out of range");
        assert(table.columns[referenceColumn].kind == ValueKind.Index, "referenceColumn is not index column");

        this.table = table;
        this.referenceRowID = referenceRowID;
        this.referenceColumn = referenceColumn;

        rowID = 1;
        while (rowID <= table.rowCount)
        {
            auto referenceColumnValue = table.getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn);
            if (referenceColumnValue == referenceRowID)
                break;
            ++rowID;
        }
    }

    pragma(inline, true)
    bool empty() const
    {        
        return rowID > table.rowCount;
    }

    pragma(inline, true)
    void popFront()
    {
        ++rowID; 
        while (rowID <= table.rowCount)
        {
            auto referenceColumnValue = table.getValue!(uint, ValueKind.Index)(rowID - 1, referenceColumn);
            if (referenceColumnValue == referenceRowID)
                break;
            ++rowID;
        }
    }

    pragma(inline, true)
    public Row!md front() const
    {
        return (*table)[rowID];
    }

private:
    const Table!md* table;
    const uint referenceRowID;
    const uint referenceColumn;
    uint rowID;
}

// Returns contiguos range of rows referencing the given referenceCodedIndex in another table
public struct TableCodedIndexRangeEnumerator(MDTableType md)
{
    @disable this();

    private this(const(Table!md*) table, uint referenceCodedIndex, uint referenceColumn)
    {
        assert(referenceColumn < table.columns.length, "referenceColumn out of range");
        assert(table.columns[referenceColumn].kind == ValueKind.CodedIndex, "referenceColumn is not coded index column");

        this.table = table;
        this.referenceCodedIndex = referenceCodedIndex;
        this.referenceColumn = referenceColumn;
        rowID = 1;

        while (rowID <= table.rowCount)
        {
            auto referenceColumnValue = table.getValue!(uint, ValueKind.CodedIndex)(rowID - 1, referenceColumn);
            if (referenceColumnValue == referenceCodedIndex)
                break;
            ++rowID;
        }
    }

    pragma(inline, true)
    bool empty() const
    {
        return rowID > table.rowCount || table.getValue!(uint, ValueKind.CodedIndex)(rowID - 1, referenceColumn) != referenceCodedIndex;
    }

    pragma(inline, true)
    void popFront()
    {
        ++rowID;
    }

    pragma(inline, true)
    public Row!md front() const
    {
        return (*table)[rowID];
    }

private:
    const Table!md* table;
    const uint referenceCodedIndex;
    const uint referenceColumn;
    uint rowID;
}
