module climetadata.mdcollection.collection;

import std.algorithm : endsWith, startsWith;
import std.typecons : Nullable;

public import climetadata.mdtable.type;
import climetadata.mdtable.table : Table, TableListEnumerator, TableRangeEnumerator, TableAllEnumerator, TableCodedIndexRangeEnumerator;
import climetadata.mdcollection.database : Database;
import climetadata.mdcollection.entity : Entity;

struct Collection(MDTableType md)
{
    @disable this();

    public this(const Database* db)
    {
        this.table = db.getTable!(md);
        this.db = db;
    }

    // rowID is 1-based
    public Entity!md opIndex(uint rowID) const
    {
        return Entity!md((*table)[rowID], db);
    }

    public const(Table!md*) getTable() const
    {
        return table;
    }

    public CollectionListEnumerator!md items() const
    {
        return CollectionListEnumerator!md(table.items(), db);
    }

    public CollectionListEnumerator!md list(uint startRowID, uint endRowID) const
    {
        assert(startRowID);
        return CollectionListEnumerator!md(table.list(startRowID, endRowID), db);
    }

    public CollectionListEnumerator!md emptyList() const
    {
        return CollectionListEnumerator!(md)(table.emptyList(), db);
    }

    static if (md == MDTableType.typeDef) 
    {
        public Nullable!(Entity!(md)) findByName(string typeName) const
        {
            foreach(e; items())
            {
                auto name = e.getTypeName();
                auto namespace = e.getTypeNamespace();
                if (typeName.length == name.length + namespace.length + 1 && typeName.startsWith(namespace) && typeName.endsWith(name))
                {
                    return Nullable!(Entity!(md))(e);
                }
            }
            return Nullable!(Entity!(md)).init;
        }

        public Nullable!(Entity!(md)) findByName(string typeNamespace, string typeName) const
        {
            foreach(e; items())
            {
                auto name = e.getTypeName();
                auto namespace = e.getTypeNamespace();
                if (typeNamespace == namespace && typeName == name)
                {
                    return Nullable!(Entity!(md))(e);
                }
            }
            return Nullable!(Entity!(md)).init;
        }

        public Entity!(md)[] findAllByName(string typeNamespace, string typeName) const
        {
            Entity!(md)[] result;
            foreach(e; items())
            {
                auto name = e.getTypeName();
                auto namespace = e.getTypeNamespace();
                if (typeNamespace == namespace && typeName == name)
                {
                     result ~= e;
                }
            }
            return result;
        }
    }

    //public alias NullableEntity = Nullable!(Entity!md);

private:
    const Table!md* table;
    const Database* db;
}

// Wraps TableListEnumerator
public struct CollectionListEnumerator(MDTableType md)
{
    @disable this();
    
    public this(const TableListEnumerator!md tableEnumerator, const Database* db)
    {
        this.tableEnumerator = tableEnumerator;
        this.db = db;
    }

    pragma(inline, true)
    public bool empty() const
    {
        return tableEnumerator.empty();
    }

    pragma(inline, true)
    public void popFront()
    {
        tableEnumerator.popFront();
    }

    pragma(inline, true)
    public Entity!md front() const
    {
        return Entity!md(tableEnumerator.front(), db);
    }

private:
    TableListEnumerator!md tableEnumerator;
    const Database* db;
}

// Wraps TableRangeEnumerator
public struct CollectionRangeEnumerator(MDTableType md)
{
    @disable this();
    
    public this(const TableRangeEnumerator!md tableEnumerator, const Database* db)
    {
        this.tableEnumerator = tableEnumerator;
        this.db = db;
    }

    pragma(inline, true)
    public bool empty() const
    {
        return tableEnumerator.empty();
    }

    pragma(inline, true)
    public void popFront()
    {
        tableEnumerator.popFront();
    }

    pragma(inline, true)
    public Entity!md front() const
    {
        return Entity!md(tableEnumerator.front(), db);
    }

private:
    TableRangeEnumerator!md tableEnumerator;
    const Database* db;
}

// Wraps CollectionAllEnumerator
public struct CollectionAllEnumerator(MDTableType md)
{
    @disable this();
    
    public this(const TableAllEnumerator!md tableEnumerator, const Database* db)
    {
        this.tableEnumerator = tableEnumerator;
        this.db = db;
    }

    pragma(inline, true)
    public bool empty() const
    {
        return tableEnumerator.empty();
    }

    pragma(inline, true)
    public void popFront()
    {
        tableEnumerator.popFront();
    }

    pragma(inline, true)
    public Entity!md front() const
    {
        return Entity!md(tableEnumerator.front(), db);
    }

private:
    TableAllEnumerator!md tableEnumerator;
    const Database* db;
}

// Wraps TableCodedIndexRangeEnumerator
public struct CollectionCodedIndexRangeEnumerator(MDTableType md)
{
    @disable this();
    
    public this(const TableCodedIndexRangeEnumerator!md tableEnumerator, const Database* db)
    {
        this.tableEnumerator = tableEnumerator;
        this.db = db;
    }

    pragma(inline, true)
    public bool empty() const
    {
        return tableEnumerator.empty();
    }

    pragma(inline, true)
    public void popFront()
    {
        tableEnumerator.popFront();
    }

    pragma(inline, true)
    public Entity!md front() const
    {
        return Entity!md(tableEnumerator.front(), db);
    }

private:
    TableCodedIndexRangeEnumerator!md tableEnumerator;
    const Database* db;
}
