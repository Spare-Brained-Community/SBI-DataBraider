codeunit 71033612 "SPB DBraid DStoJSON Flat" implements "SPB DBraider IDatasetToText"
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
        HasRows: Boolean;
    begin
        // Copy result rows/cols into our internal arrays
        HasRows := BaseResultRow.FindSet();
        if HasRows then
            repeat
                ResultRow[1] := BaseResultRow;
                ResultRow[1].Insert();
            until BaseResultRow.Next() = 0;

        if BaseResultCol.FindSet() then
            repeat
                ResultCol[1] := BaseResultCol;
                ResultCol[1].Insert();
            until BaseResultCol.Next() = 0;

        // Guard: If no rows were generated (e.g. filters exclude written record), avoid Get() on blank Config Code.
        if not HasRows then begin
            // Return empty JsonRows (caller will embed action + empty data safely)
            exit(JsonRows);
        end;

        // Safe: At least one row exists; Config. Code should be populated.
        DBHeader.Get(ResultRow[1]."Config. Code");
        JsonRows := ProcessDataFlatToJson(DBHeader);
        exit(JsonRows);
    end;

    internal procedure ProcessDataFlatToJson(DBHeader: Record "SPB DBraider Config. Header") JsonRows: JsonArray
    var
        UseWriteResponseFiltering: Boolean;
        MaximumDepth: Integer;
        JsonCols: JsonObject;
    begin
        MaximumDepth := 0; // To shut up AA0205;

        // Depending on the configuration, we handle 'root' level differently.  If it's a writeable config, we only want Direct or Parent rows.
        UseWriteResponseFiltering := false;
        if DBHeader.WriteableConfig() then begin
            // Check to see if there's any *write* mode entries.
            ResultRow[1].SetRange("Data Mode", ResultRow[1]."Data Mode"::"Write");
            if ResultRow[1].IsEmpty() then
                if DBHeader."Prevent Reading" then begin
                    JsonCols.Add('Error', 'This endpoint is write-only and cannot be read from.');
                    JsonRows.Add(JsonCols.Clone());
                end else
                    ResultRow[1].SetRange("Belongs To Row No.", 0)  // 'root' level for read results from the Write endpoint
            else begin
                ResultRow[1].SetFilter("Buffer Type", '%1|%2', Enum::"SPB DBraider Buffer Type"::Direct, Enum::"SPB DBraider Buffer Type"::Parent);
                UseWriteResponseFiltering := true;
            end;
            ResultRow[1].SetRange("Data Mode");
        end else
            ResultRow[1].SetRange("Belongs To Row No.", 0);  // 'root' level of a Read endpoint
        if ResultRow[1].FindSet() then
            repeat
                dataLevel := 1;

                // Prep the columns
                Clear(JsonCols);
                /* 
                foreach FieldFullname in FieldList do
                    JsonCols.Add(FieldFullname, ''); */

                if JsonPrefixes.Keys().Count() <> 0 then
                    // This is a way to 'prepend' some values to the json, used by the WriteTemplate system
                    JsonCols := JsonPrefixes.Clone().AsObject();

                // Add this Row's fields to the Json:
                AddFieldColsToJsonCols(JsonCols, ResultRow[1]."Row No.");

                // And add children rows:
                if not UseWriteResponseFiltering then begin
                    // Check if this parent has children - if not, add the parent itself
                    ResultRow[2].SetRange("Belongs To Row No.", ResultRow[1]."Row No.");
                    if ResultRow[2].IsEmpty() then
                        JsonRows.Add(JsonCols.Clone())
                    else
                        AddChildrenRowsToJsonCols(JsonRows, JsonCols, ResultRow[1]."Row No.", MaximumDepth);
                    ResultRow[2].SetRange("Belongs To Row No.");
                end else
                    if ResultRow[1]."Buffer Type" = Enum::"SPB DBraider Buffer Type"::Parent then
                        AddChildrenRowsToJsonCols(JsonRows, JsonCols, ResultRow[1]."Row No.", MaximumDepth)
                    else
                        JsonRows.Add(JsonCols.Clone()); // If we're not adding the children, we need to add the row to the array

            // Add the new 'row' of columns to the array
            //JsonRows.Add(JsonCols.Clone());
            until ResultRow[1].Next() = 0;
        ResultRow[1].SetRange("Belongs To Row No.");
    end;

    local procedure AddChildrenRowsToJsonCols(var JsonRows: JsonArray; var JsonCols: JsonObject; ForWhichRowNo: Integer; MaximumDepth: Integer)
    var
        ChildJsonCols: JsonObject;
    begin
        dataLevel += 1;
        ResultRow[dataLevel].SetRange("Belongs To Row No.", ForWhichRowNo);
        if ResultRow[dataLevel].FindSet() then begin
            repeat
                // Each child gets its own JsonCols starting from parent's data
                ChildJsonCols := JsonCols.Clone().AsObject();

                // Add this layer to the data
                AddFieldColsToJsonCols(ChildJsonCols, ResultRow[dataLevel]."Row No.");

                // Add any children's data
                AddChildrenRowsToJsonCols(JsonRows, ChildJsonCols, ResultRow[dataLevel]."Row No.", MaximumDepth);

                // Add this complete child row (with parent data) to the array
                JsonRows.Add(ChildJsonCols.Clone());

            until ResultRow[dataLevel].Next() = 0;
        end;
        dataLevel -= 1;
    end;

    local procedure AddFieldColsToJsonCols(var JsonCols: JsonObject; ForWhichRowNo: Integer)
    var
        IntValue: Integer;
        TestJsonValue: JsonValue;
        Suffix: Text;
    begin
        ResultRow[dataLevel].CalcFields("Source Table Name");
        // Delta Read support
        if ResultRow[dataLevel]."Delta Type" <> Enum::"SPB DBraider Delta Type"::" " then begin
            TestJsonValue.SetValue(Format(ResultRow[dataLevel]."Delta Type"));
            SafeAddJsonCols(JsonCols, JsonEncode(ResultRow[dataLevel]."Source Table Name") + '._Delta', TestJsonValue);
            Clear(TestJsonValue);
        end else
            if JsonCols.Contains(JsonEncode(ResultRow[dataLevel]."Source Table Name") + '._Delta') then
                JsonCols.Remove(JsonEncode(ResultRow[dataLevel]."Source Table Name") + '._Delta');
        ResultCol[dataLevel].SetRange("Row No.", ForWhichRowNo);
        if ResultCol[dataLevel].FindSet() then
            repeat
                Clear(Suffix);
                TestJsonValue.SetValue(ResultCol[dataLevel]."Value as Text");
                case ResultCol[dataLevel]."Data Type" of
                    ResultCol[dataLevel]."Data Type"::Boolean:
                        TestJsonValue.SetValue(ResultCol[dataLevel].BooleanCell);
                    ResultCol[dataLevel]."Data Type"::Date:
                        TestJsonValue.SetValue(ResultCol[dataLevel].DateCell);
                    ResultCol[dataLevel]."Data Type"::Time:
                        TestJsonValue.SetValue(ResultCol[dataLevel].TimeCell);
                    ResultCol[dataLevel]."Data Type"::Datetime:
                        TestJsonValue.SetValue(ResultCol[dataLevel].DatetimeCell);
                    ResultCol[dataLevel]."Data Type"::Integer:
                        begin
                            IntValue := Round(ResultCol[dataLevel].NumberCell, 1);
                            TestJsonValue.SetValue(IntValue);
                        end;
                    ResultCol[dataLevel]."Data Type"::Decimal:
                        TestJsonValue.SetValue(ResultCol[dataLevel].NumberCell);
                    //ResultCol[dataLevel]."Data Type"::Guid:
                    //TestJsonValue.SetValue(ResultCol[dataLevel].GuidCell);  // Just use the text representation, please.
                    else
                        TestJsonValue.SetValue(ResultCol[dataLevel]."Value as Text");
                end;
                if ResultCol[dataLevel]."Data Type" = Enum::"SPB DBraider Field Data Type"::RelatedId then
                    Suffix := '.id';
                if ResultCol[dataLevel]."Forced Field Caption" <> '' then
                    SafeAddJsonCols(JsonCols, JsonEncode(ResultRow[dataLevel]."Source Table Name") + '.' + JsonEncode(ResultCol[dataLevel]."Forced Field Caption") + Suffix, TestJsonValue)
                else
                    SafeAddJsonCols(JsonCols, JsonEncode(ResultRow[dataLevel]."Source Table Name") + '.' + JsonEncode(ResultCol[dataLevel]."Field Name") + Suffix, TestJsonValue);
            until ResultCol[dataLevel].Next() = 0;
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

    procedure SafeAddJsonCols(var JsonCols: JsonObject; NewKey: Text; NewValue: JsonValue)
    begin
        if JsonCols.Contains(NewKey) then
            JsonCols.Replace(NewKey, NewValue)
        else
            JsonCols.Add(NewKey, NewValue);
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

    internal procedure SetJsonPrefix(newJsonPrefix: JsonObject)
    begin
        JsonPrefixes := newJsonPrefix;
    end;

    var
        ResultCol: array[50] of Record "SPB DBraider Resultset Col" temporary;
        ResultRow: array[50] of Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
        dataLevel: Integer;
        JsonPrefixes: JsonObject;
}
