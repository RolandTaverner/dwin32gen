module codegen.attributes.flexiblearray;

import climetadata.mdcollection.entitytypes : CustomAttributeEntity;

public struct FlexibleArrayAttribute
{
    @disable this();

    public this(Range)(Range r)
    {
        foreach(ca; r)
        {
            if (ca.name() == "FlexibleArrayAttribute")
            {
                flexibleArray = true;
            }
            else
            {
                unhandledAttributes ~= ca;
            }
        }
    }

    public bool getFlexibleArray() const
    {
        return flexibleArray;
    }

    public const(CustomAttributeEntity)[] getUnhandledAttributes() const
    {
        return unhandledAttributes;
    }

    private bool flexibleArray;
    private const(CustomAttributeEntity)[] unhandledAttributes;
}
