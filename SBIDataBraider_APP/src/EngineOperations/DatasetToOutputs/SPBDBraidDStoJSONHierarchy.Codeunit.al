codeunit 71033611 "SPB DBraid DStoJSON Hierarchy" implements "SPB DBraider IDatasetToText"
{
    Access = Internal;

    procedure ConvertToJSONText(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary): Text
    var
        DBHeader: Record "SPB DBraider Config. Header";
        JsonRows: JsonArray;
        JsonRoot: JsonObject;
        ResultTextLbl: Label 'No Result was found with the given filter(s)';
        ResultText: Text;
        ConfigCode: Code[20];
    begin
        if BaseResultCol.IsEmpty() or BaseResultRow.IsEmpty() then begin
            ResultText := ResultTextLbl;
            exit(ResultText);
        end;

        // Get config code from first row
        if BaseResultRow.FindFirst() then
            ConfigCode := BaseResultRow."Config. Code";

        JsonRows := ConvertToJSON(BaseResultRow, BaseResultCol);

        // Check if diagnostics should be emitted
        if DBHeader.Get(ConfigCode) and DBHeader."Emit Raw Diagnostic Data" then begin
            JsonRoot.Add('data', JsonRows);
            JsonRoot.Add('diagnostics', BuildDiagnostics(BaseResultRow, BaseResultCol));
            SPBDBraiderEvents.OnBeforeConvertJSONtoText(ConfigCode, JsonRows, ResultText);
            JsonRoot.WriteTo(ResultText);
            SPBDBraiderEvents.OnAfterConvertJSONtoText(ConfigCode, JsonRows, ResultText);
        end else begin
            SPBDBraiderEvents.OnBeforeConvertJSONtoText(ConfigCode, JsonRows, ResultText);
            JsonRows.WriteTo(ResultText);
            SPBDBraiderEvents.OnAfterConvertJSONtoText(ConfigCode, JsonRows, ResultText);
        end;
        exit(ResultText);
    end;

    procedure ConvertToJSON(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary) JsonRows: JsonArray
    var
        DBHeader: Record "SPB DBraider Config. Header";
    begin
        if BaseResultRow.FindSet() then
            repeat
                ResultRow[1] := BaseResultRow;
                ResultRow[1].Insert();
            until BaseResultRow.Next() = 0;

        if BaseResultCol.FindSet() then
            repeat
                ResultCol[1] := BaseResultCol;
                ResultCol[1].Insert();
            until BaseResultCol.Next() = 0;

        DBHeader.Get(BaseResultRow."Config. Code");
        JsonRows := ProcessDataHierarchyToJson();
        exit(JsonRows);
    end;

    internal procedure ProcessDataHierarchyToJson() JsonRows: JsonArray
    var
        IntValue: Integer;
        JsonCols: JsonObject;
        JsonRow: JsonObject;
        JsonFieldName: Text;
    begin
        dataLevel := 1;
        ResultRow[1].SetRange("Belongs To Row No.", 0);  // 'root' level
        if ResultRow[1].FindSet() then begin
            JsonRow.Add('level', 0);
            JsonRow.Add('sourceTableNumber', 0);
            JsonRow.Add('sourceTableName', '');
            JsonRow.Add('pkString', '');
            JsonRow.Add('sourceSystemId', '');
            JsonRow.Add('data', '');
            //TODO: Add _Delta to root level only if the endpoint needs it?
            //JsonRow.Add('_delta', '');
            repeat
                ResultRow[1].CalcFields("Source Table Name");
                JsonRow.Replace('level', ResultRow[1]."Data Level");
                JsonRow.Replace('sourceTableNumber', ResultRow[1]."Source Table");
                JsonRow.Replace('sourceTableName', ResultRow[1]."Source Table Name");
                JsonRow.Replace('pkString', ResultRow[1]."Primary Key String");
                JsonRow.Replace('sourceSystemId', DelChr(ResultRow[1]."Source SystemId", '=', '{}'));
                if ResultRow[1]."Delta Type" <> Enum::"SPB DBraider Delta Type"::" " then
                    JsonRow.Replace('_delta', Format(ResultRow[1]."Delta Type"));
                if JsonRow.Contains('children') then
                    JsonRow.Remove('children');
                ResultCol[1].SetRange("Row No.", ResultRow[1]."Row No.");
                if ResultCol[1].FindSet() then begin
                    Clear(JsonCols);
                    repeat
                        if ResultCol[1]."Forced Field Caption" <> '' then
                            JsonFieldName := ResultCol[1]."Forced Field Caption"
                        else
                            JsonFieldName := ResultCol[1]."Field Name";
                        case ResultCol[1]."Data Type" of
                            ResultCol[1]."Data Type"::Boolean:
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].BooleanCell);
                            ResultCol[1]."Data Type"::Date:
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].DateCell);
                            ResultCol[1]."Data Type"::Time:
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].TimeCell);
                            ResultCol[1]."Data Type"::Datetime:
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].DatetimeCell);
                            ResultCol[1]."Data Type"::Integer:
                                begin
                                    IntValue := Round(ResultCol[1].NumberCell, 1);
                                    JsonCols.Add(JsonEncode(JsonFieldName), IntValue);
                                end;
                            ResultCol[1]."Data Type"::Decimal:
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].NumberCell);
                            //ResultCol[1]."Data Type"::Guid:
                            //    JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1].GuidCell);
                            ResultCol[1]."Data Type"::RelatedId:
                                JsonCols.Add(JsonEncode(JsonFieldName) + '.id', ResultCol[1]."Value as Text");
                            else
                                JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[1]."Value as Text");
                        end;
                    until ResultCol[1].Next() = 0;
                    ResultRow[2].SetRange("Belongs To Row No.", ResultRow[1]."Row No.");
                    if ResultRow[2].FindSet() then
                        repeat
                            AddChildrenToJsonRow(JsonRow);
                        until ResultRow[2].Next() = 0;
                end;
                JsonRow.Replace('data', JsonCols.Clone());
                JsonRows.Add(JsonRow.Clone());
                Clear(JsonCols);
            until ResultRow[1].Next() = 0;
        end;

        ResultRow[1].SetRange("Belongs To Row No.");
    end;

    local procedure AddChildrenToJsonRow(var JsonParentRow: JsonObject)
    var
        IntValue: Integer;
        JsonRows: JsonArray;
        JsonCols: JsonObject;
        JsonRow: JsonObject;
        JsonFieldName: Text;
    begin
        dataLevel += 1;
        JsonRow.Add('level', 0);
        JsonRow.Add('sourceTableNumber', 0);
        JsonRow.Add('sourceTableName', '');
        JsonRow.Add('pkString', '');
        JsonRow.Add('sourceSystemId', '');
        JsonRow.Add('data', '');
        //TODO: Add _Delta to root level only if the endpoint needs it?
        //if ResultRow[dataLevel]."Delta Type" <> Enum::"SPB DBraider Delta Type"::" " then
        //JsonRow.Add('_delta', '');
        repeat
            ResultRow[dataLevel].CalcFields("Source Table Name");
            JsonRow.Replace('level', ResultRow[dataLevel]."Data Level");
            JsonRow.Replace('sourceTableNumber', ResultRow[dataLevel]."Source Table");
            JsonRow.Replace('sourceTableName', ResultRow[dataLevel]."Source Table Name");
            JsonRow.Replace('pkString', ResultRow[dataLevel]."Primary Key String");
            JsonRow.Replace('sourceSystemId', DelChr(ResultRow[dataLevel]."Source SystemId", '=', '{}'));
            if ResultRow[dataLevel]."Delta Type" <> Enum::"SPB DBraider Delta Type"::" " then
                JsonRow.Replace('_delta', Format(ResultRow[dataLevel]."Delta Type"));
            if JsonRow.Contains('children') then
                JsonRow.Remove('children');
            ResultCol[dataLevel].SetRange("Row No.", ResultRow[dataLevel]."Row No.");
            if ResultCol[dataLevel].FindSet() then begin
                Clear(JsonCols);
                repeat
                    if ResultCol[dataLevel]."Forced Field Caption" <> '' then
                        JsonFieldName := ResultCol[dataLevel]."Forced Field Caption"
                    else
                        JsonFieldName := ResultCol[dataLevel]."Field Name";
                    case ResultCol[dataLevel]."Data Type" of
                        ResultCol[dataLevel]."Data Type"::Boolean:
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].BooleanCell);
                        ResultCol[dataLevel]."Data Type"::Date:
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].DateCell);
                        ResultCol[dataLevel]."Data Type"::Time:
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].TimeCell);
                        ResultCol[dataLevel]."Data Type"::Datetime:
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].DatetimeCell);
                        ResultCol[dataLevel]."Data Type"::Integer:
                            begin
                                IntValue := Round(ResultCol[dataLevel].NumberCell, 1);
                                JsonCols.Add(JsonEncode(JsonFieldName), IntValue);
                            end;
                        ResultCol[dataLevel]."Data Type"::Decimal:
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].NumberCell);
                        ResultCol[dataLevel]."Data Type"::RelatedId:
                            JsonCols.Add(JsonEncode(JsonFieldName) + '.id', ResultCol[dataLevel]."Value as Text");
                        //ResultCol[dataLevel]."Data Type"::Guid:
                        //    JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel].GuidCell);
                        else
                            JsonCols.Add(JsonEncode(JsonFieldName), ResultCol[dataLevel]."Value as Text");
                    end;
                until ResultCol[dataLevel].Next() = 0;
                ResultRow[dataLevel + 1].SetRange("Belongs To Row No.", ResultRow[dataLevel]."Row No.");
                if ResultRow[dataLevel + 1].FindSet() then
                    repeat
                        AddChildrenToJsonRow(JsonRow);
                    until ResultRow[dataLevel + 1].Next() = 0;
            end;
            JsonRow.Replace('data', JsonCols.Clone());
            JsonRows.Add(JsonRow.Clone());
            Clear(JsonCols);
        until ResultRow[dataLevel].Next() = 0;
        JsonParentRow.Add('children', JsonRows.Clone());
        dataLevel -= 1;
    end;

    #region Utility
    procedure JsonEncode(InputText: Text) OutputText: Text
    var
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
    begin
        if InputText.EndsWith('timestamp') then
            exit(InputText);
        exit(SPBDBraiderJSONUtilities.JsonSafeTableFieldName(InputText))
    end;

    local procedure BuildDiagnostics(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary) DiagJson: JsonObject
    var
        RowsArray: JsonArray;
        ColsArray: JsonArray;
        RowJson: JsonObject;
        ColJson: JsonObject;
    begin
        // Build rows array
        if BaseResultRow.FindSet() then
            repeat
                Clear(RowJson);
                RowJson.Add('RowNo', BaseResultRow."Row No.");
                RowJson.Add('ConfigCode', BaseResultRow."Config. Code");
                RowJson.Add('BelongsToRowNo', BaseResultRow."Belongs To Row No.");
                RowJson.Add('BufferType', Format(BaseResultRow."Buffer Type"));
                RowJson.Add('DataMode', Format(BaseResultRow."Data Mode"));
                RowJson.Add('DeltaType', Format(BaseResultRow."Delta Type"));
                BaseResultRow.CalcFields("Source Table Name");
                RowJson.Add('SourceTableName', BaseResultRow."Source Table Name");
                RowsArray.Add(RowJson);
            until BaseResultRow.Next() = 0;

        // Build cols array
        if BaseResultCol.FindSet() then
            repeat
                Clear(ColJson);
                ColJson.Add('RowNo', BaseResultCol."Row No.");
                ColJson.Add('ColNo', BaseResultCol."Column No.");
                ColJson.Add('FieldName', BaseResultCol."Field Name");
                ColJson.Add('ForcedFieldCaption', BaseResultCol."Forced Field Caption");
                ColJson.Add('DataType', Format(BaseResultCol."Data Type"));
                ColJson.Add('ValueAsText', BaseResultCol."Value as Text");
                ColJson.Add('WriteResultRecord', BaseResultCol."Write Result Record");
                ColsArray.Add(ColJson);
            until BaseResultCol.Next() = 0;

        DiagJson.Add('rows', RowsArray);
        DiagJson.Add('cols', ColsArray);
        DiagJson.Add('rowCount', BaseResultRow.Count());
        DiagJson.Add('colCount', BaseResultCol.Count());
    end;
    #endregion Utility

    var
        ResultCol: array[50] of Record "SPB DBraider Resultset Col" temporary;
        ResultRow: array[50] of Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
        dataLevel: Integer;
}
