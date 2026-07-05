page 71033631 "SPB DBraider Tables API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Available Tables API';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityCaption = 'Available Table';
    EntityName = 'availableTable';
    EntitySetName = 'availableTables';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = "Object ID";
    PageType = API;
    SourceTable = AllObjWithCaption;
    SourceTableView = where("Object Type" = const(Table));

    // Lookup surface for remote endpoint authoring: lets clients resolve valid
    // table numbers/names before creating endpoint lines.

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(tableNo; Rec."Object ID")
                {
                    Caption = 'tableNo', Locked = true;
                }
                field(name; Rec."Object Name")
                {
                    Caption = 'name', Locked = true;
                }
                field(caption; Rec."Object Caption")
                {
                    Caption = 'caption', Locked = true;
                }
            }
        }
    }
}
