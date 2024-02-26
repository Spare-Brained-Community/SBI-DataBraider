codeunit 71033615 "SPB DBraider JSON Templ. Maker"
{
    TableNo = "SPB DBraider Config. Line";

    procedure GenerateTableToTemplate(var Rec: Record "SPB DBraider Config. Header"; MandatoryOnly: Boolean; TemplateActionType: Enum "SPB DBraider Change Action") JsonTemplateResult: Text;
    var
        TempBaseResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempBaseResultRow: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraidDStoJSONFlat: Codeunit "SPB DBraid DStoJSON Flat";
        JsonPrefix: JsonObject;
    begin

        BuildLineIntoTemporaryDataStructure(Rec, MandatoryOnly, TempBaseResultRow, TempBaseResultCol);

        JsonPrefix.Add('Action', Format(TemplateActionType));
        SPBDBraidDStoJSONFlat.SetJsonPrefix(JsonPrefix);
        JsonTemplateResult := SPBDBraidDStoJSONFlat.ConvertToJSONText(TempBaseResultRow, TempBaseResultCol);
    end;

    local procedure BuildLineIntoTemporaryDataStructure(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; MandatoryOnly: Boolean; var TempBaseResultRow: Record "SPB DBraider Resultset Row" temporary; var TempBaseResultCol: Record "SPB DBraider Resultset Col" temporary)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfigFields: Record "SPB DBraider ConfLine Field";
        NextReslRowNo: Integer;
        NextColNo: Integer;
    begin
        SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        if SPBDBraiderConfigLine.FindSet() then
            repeat
                SPBDBraiderConfigFields.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                SPBDBraiderConfigFields.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                SPBDBraiderConfigFields.SetRange(Included, true);
                SPBDBraiderConfigFields.SetRange("Write Enabled", true);
                if MandatoryOnly then
                    SPBDBraiderConfigFields.SetRange(Mandatory, true);

                NextReslRowNo += 1;

                // Generate a temporary Base Result Row, just a single one for the table
                TempBaseResultRow.Init();
                TempBaseResultRow."Row No." := NextReslRowNo;
                TempBaseResultRow."Data Level" := 10000;
                TempBaseResultRow."Config. Code" := SPBDBraiderConfigLine."Config. Code";
                TempBaseResultRow."Source Table" := SPBDBraiderConfigLine."Source Table";
                TempBaseResultRow.Insert();

                if SPBDBraiderConfigFields.FindSet() then begin
                    NextColNo := 1;
                    repeat
                        SPBDBraiderConfigFields.CalcFields("Field Name");
                        TempBaseResultCol.Init();
                        TempBaseResultCol."Row No." := NextReslRowNo;
                        TempBaseResultCol."Column No." := NextColNo;
                        NextColNo += 1;

                        TempBaseResultCol."Data Type" := SPBDBraiderConfigFields."Field Type";
                        TempBaseResultCol."Field No." := SPBDBraiderConfigFields."Field No.";
                        TempBaseResultCol."Field Name" := CopyStr(SPBDBraiderConfigFields."Field Name", 1, MaxStrLen(TempBaseResultCol."Field Name"));
                        case SPBDBraiderConfigFields."Field Type" of
                            Enum::"SPB DBraider Field Data Type"::Boolean:
                                TempBaseResultCol.BooleanCell := true;
                            Enum::"SPB DBraider Field Data Type"::Code:
                                TempBaseResultCol.CodeCell := '';
                            Enum::"SPB DBraider Field Data Type"::Date:
                                TempBaseResultCol.DateCell := Today();
                            Enum::"SPB DBraider Field Data Type"::Time:
                                TempBaseResultCol.TimeCell := Time();
                            Enum::"SPB DBraider Field Data Type"::Datetime:
                                TempBaseResultCol.DatetimeCell := CurrentDateTime();
                            Enum::"SPB DBraider Field Data Type"::Decimal:
                                TempBaseResultCol.NumberCell := 12.34;
                            Enum::"SPB DBraider Field Data Type"::Integer:
                                TempBaseResultCol.NumberCell := 5555;
                            Enum::"SPB DBraider Field Data Type"::Option:
                                TempBaseResultCol.NumberCell := 1;
                            Enum::"SPB DBraider Field Data Type"::Guid:
                                TempBaseResultCol.GuidCell := CreateGuid();
                        end;
                        TempBaseResultCol.Insert();
                    until SPBDBraiderConfigFields.Next() = 0;
                end;
            until SPBDBraiderConfigLine.Next() = 0;
    end;
}
