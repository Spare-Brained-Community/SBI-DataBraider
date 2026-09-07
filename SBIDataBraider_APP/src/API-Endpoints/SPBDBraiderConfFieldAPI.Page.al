page 71033627 "SPB DBraider Conf Field API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Endpoint Field API';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityCaption = 'Endpoint Field';
    EntityName = 'endpointField';
    EntitySetName = 'endpointFields';
    InsertAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "SPB DBraider ConfLine Field";

    // Field rows are auto-generated when an endpoint line is inserted; via the API
    // they are toggled/configured (PATCH), never inserted or deleted directly.

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(configCode; Rec."Config. Code")
                {
                    Caption = 'configCode', Locked = true;
                    Editable = false;
                }
                field(configLineNo; Rec."Config. Line No.")
                {
                    Caption = 'configLineNo', Locked = true;
                    Editable = false;
                }
                field(fieldNo; Rec."Field No.")
                {
                    Caption = 'fieldNo', Locked = true;
                    Editable = false;
                }
                field(tableNo; Rec."Table No.")
                {
                    Caption = 'tableNo', Locked = true;
                    Editable = false;
                }
                field(fieldName; Rec."Fixed Field Name")
                {
                    Caption = 'fieldName', Locked = true;
                    Editable = false;
                }
                field(fieldCaption; Rec."Fixed Field Caption")
                {
                    Caption = 'fieldCaption', Locked = true;
                    Editable = false;
                }
                field(fieldType; Rec."Field Type")
                {
                    Caption = 'fieldType', Locked = true;
                    Editable = false;
                }
                field(fieldClass; Rec."Field Class")
                {
                    Caption = 'fieldClass', Locked = true;
                    Editable = false;
                }
                field(primaryKey; Rec."Primary Key")
                {
                    Caption = 'primaryKey', Locked = true;
                    Editable = false;
                }
                field(included; Rec.Included)
                {
                    Caption = 'included', Locked = true;
                }
                field(writeEnabled; Rec."Write Enabled")
                {
                    Caption = 'writeEnabled', Locked = true;
                }
                field("filter"; Rec."Filter")
                {
                    Caption = 'filter', Locked = true;
                }
                field(defaultValue; Rec."Default Value")
                {
                    Caption = 'defaultValue', Locked = true;
                }
                field(mandatory; Rec.Mandatory)
                {
                    Caption = 'mandatory', Locked = true;
                }
                field(upsertMatch; Rec."Upsert Match")
                {
                    Caption = 'upsertMatch', Locked = true;
                }
                field(disableValidation; Rec."Disable Validation")
                {
                    Caption = 'disableValidation', Locked = true;
                }
                field(disableAutoSplitKey; Rec."Disable Auto-Split Key")
                {
                    Caption = 'disableAutoSplitKey', Locked = true;
                }
                field(modificationRevalidate; Rec."Modification Re-Validate")
                {
                    Caption = 'modificationRevalidate', Locked = true;
                }
                field(disableRelatedId; Rec."Disable Related Id")
                {
                    Caption = 'disableRelatedId', Locked = true;
                }
                field(manualFieldCaption; Rec."Manual Field Caption")
                {
                    Caption = 'manualFieldCaption', Locked = true;
                }
                field(processingOrder; Rec."Processing Order")
                {
                    Caption = 'processingOrder', Locked = true;
                }
                field(dateTimeTimezone; Rec."DateTime Timezone")
                {
                    Caption = 'dateTimeTimezone', Locked = true;
                }
            }
        }
    }
}
