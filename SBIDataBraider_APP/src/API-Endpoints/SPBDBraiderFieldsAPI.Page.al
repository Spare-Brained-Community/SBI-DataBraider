page 71033632 "SPB DBraider Fields API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Available Fields API';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityCaption = 'Available Field';
    EntityName = 'availableField';
    EntitySetName = 'availableFields';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = TableNo, "No.";
    PageType = API;
    SourceTable = Field;

    // Lookup surface for remote endpoint authoring: clients call with
    // $filter=tableNo eq N to list the fields of a table (numbers, names, types).

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(tableNo; Rec.TableNo)
                {
                    Caption = 'tableNo', Locked = true;
                }
                field(fieldNo; Rec."No.")
                {
                    Caption = 'fieldNo', Locked = true;
                }
                field(name; Rec.FieldName)
                {
                    Caption = 'name', Locked = true;
                }
                field(caption; Rec."Field Caption")
                {
                    Caption = 'caption', Locked = true;
                }
                field(type; Rec."Type Name")
                {
                    Caption = 'type', Locked = true;
                }
                field(class; Rec.Class)
                {
                    Caption = 'class', Locked = true;
                }
                field(obsoleteState; Rec.ObsoleteState)
                {
                    Caption = 'obsoleteState', Locked = true;
                }
                field(isPartOfPrimaryKey; Rec.IsPartOfPrimaryKey)
                {
                    Caption = 'isPartOfPrimaryKey', Locked = true;
                }
            }
        }
    }
}
