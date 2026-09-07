codeunit 71033630 "SPB DBraider Schema JSON"
{
    Access = Internal;

    procedure ReadItemSchema(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") Result: JsonObject
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
    begin
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange(Included, true);
        SPBDBraiderConfLineFields.SetAutoCalcFields("Table Name", "Field Name");
        Result := BuildFieldSchema(SPBDBraiderConfLineFields);
    end;

    procedure WriteBodySchema(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") Result: JsonObject
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
    begin
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange("Write Enabled", true);
        SPBDBraiderConfLineFields.SetAutoCalcFields("Table Name", "Field Name");
        Result := BuildFieldSchema(SPBDBraiderConfLineFields);
    end;

    procedure BuildFieldSchema(var SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field") Result: JsonObject
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        FieldSchemaObj: JsonObject;
        PropertiesObj: JsonObject;
        RequiredArr: JsonArray;
        PropertyName: Text;
    begin
        Result.Add('type', 'object');
        if SPBDBraiderConfLineFields.FindSet() then
            repeat
                Clear(FieldSchemaObj);
                case SPBDBraiderConfLineFields."Field Type" of
                    "SPB DBraider Field Data Type"::Boolean:
                        FieldSchemaObj.Add('type', 'boolean');
                    "SPB DBraider Field Data Type"::Decimal, "SPB DBraider Field Data Type"::Integer:
                        FieldSchemaObj.Add('type', 'number');
                    else
                        FieldSchemaObj.Add('type', 'string');
                end;
                // Vendor extension keys give API clients machine-usable authoring metadata
                // beyond plain JSON-Schema types (e.g. for navapi/Braider tooling).
                FieldSchemaObj.Add('x-spb-tableNo', SPBDBraiderConfLineFields."Table No.");
                FieldSchemaObj.Add('x-spb-fieldNo', SPBDBraiderConfLineFields."Field No.");
                FieldSchemaObj.Add('x-spb-writeEnabled', SPBDBraiderConfLineFields."Write Enabled");
                FieldSchemaObj.Add('x-spb-primaryKey', SPBDBraiderConfLineFields."Primary Key");
                // Use Manual Field Caption when set (it is already JSON-safe), otherwise use the field name
                PropertyName := SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name") + '.';
                if SPBDBraiderConfLineFields."Manual Field Caption" <> '' then
                    PropertyName += SPBDBraiderConfLineFields."Manual Field Caption"
                else
                    PropertyName += SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name");
                PropertiesObj.Add(PropertyName, FieldSchemaObj);
                if SPBDBraiderConfLineFields.Mandatory then
                    RequiredArr.Add(PropertyName);
            until SPBDBraiderConfLineFields.Next() < 1;
        Result.Add('properties', PropertiesObj);
        if RequiredArr.Count() > 0 then
            Result.Add('required', RequiredArr);
    end;
}
