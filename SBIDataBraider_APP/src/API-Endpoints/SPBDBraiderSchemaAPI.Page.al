page 71033629 "SPB DBraider Schema API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Endpoint Schema API';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityCaption = 'Endpoint Schema';
    EntityName = 'endpointSchema';
    EntitySetName = 'endpointSchemas';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = Code;
    PageType = API;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;

    // Read-only schema introspection: JSON Schemas are computed per endpoint from the
    // ConfLine Field configuration (same builder as the Swagger accelerator).
    // Clients should GET by key — endpointSchemas('CODE') — as list GETs compute
    // schemas for every configured endpoint.
    // Unlike the read/write APIs there is no EnabledGlobally gate: this is an
    // authoring/introspection surface, usable while Data Braider is still disabled.

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(endpointType; Rec."Endpoint Type")
                {
                    Caption = 'endpointType', Locked = true;
                }
                field(outputJsonType; Rec."Output JSON Type")
                {
                    Caption = 'outputJsonType', Locked = true;
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'enabled', Locked = true;
                }
                field(readSchemaJson; ReadSchemaJson)
                {
                    Caption = 'readSchemaJson', Locked = true;
                }
                field(writeSchemaJson; WriteSchemaJson)
                {
                    Caption = 'writeSchemaJson', Locked = true;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        DBraiderConfig: Record "SPB DBraider Config. Header";
    begin
        if not DataInitialized then begin
            DBraiderConfig.CopyFilters(Rec);
            Rec.Reset();
            if DBraiderConfig.FindSet() then
                repeat
                    Rec.TransferFields(DBraiderConfig);
                    Rec.Insert();
                until DBraiderConfig.Next() = 0;
            DataInitialized := true;
        end;
        exit(Rec.Find(Which));
    end;

    trigger OnAfterGetRecord()
    var
        RealConfig: Record "SPB DBraider Config. Header";
        SPBDBraiderSchemaJSON: Codeunit "SPB DBraider Schema JSON";
        SchemaObj: JsonObject;
    begin
        ReadSchemaJson := '';
        WriteSchemaJson := '';
        if not RealConfig.Get(Rec.Code) then
            exit;
        // Included fields describe the read payload for every endpoint type.
        SchemaObj := SPBDBraiderSchemaJSON.ReadItemSchema(RealConfig);
        SchemaObj.WriteTo(ReadSchemaJson);
        // Write-enabled fields only exist meaningfully on writeable endpoint types.
        if RealConfig.WriteableConfig() then begin
            Clear(SchemaObj);
            SchemaObj := SPBDBraiderSchemaJSON.WriteBodySchema(RealConfig);
            SchemaObj.WriteTo(WriteSchemaJson);
        end;
    end;

    var
        DataInitialized: Boolean;
        ReadSchemaJson: Text;
        WriteSchemaJson: Text;
}
