codeunit 71033612 "SPB DBraid DStoJSON Flat" implements "SPB DBraider IDatasetToText"
{
    Access = Internal;

    procedure ConvertToJSONText(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary): Text
    var
        JsonRows: JsonArray;
        ResultTextLbl: Label 'No Result was found with the given filter(s)';
        ResultText: Text;
    begin
        if BaseResultCol.IsEmpty or BaseResultRow.IsEmpty then begin
            ResultText := ResultTextLbl;
            exit(ResultText);
        end;

        JsonRows := ConvertToJSON(BaseResultRow, BaseResultCol);
        SPBDBraiderEvents.OnBeforeConvertJSONtoText(BaseResultRow."Config. Code", JsonRows, ResultText);
        JsonRows.WriteTo(ResultText);
        SPBDBraiderEvents.OnAfterConvertJSONtoText(BaseResultRow."Config. Code", JsonRows, ResultText);
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
        JsonRows := ProcessDataFlatToJson();
        exit(JsonRows);
    end;

    internal procedure ProcessDataFlatToJson() JsonRows: JsonArray;
    var
        MaximumDepth: Integer;
        JsonCols: JsonObject;
    begin
        MaximumDepth := 0; // To shut up AA0205;
        // Build complete table.field dictionary of possible values so we have all columns
        /* DBLine.SetRange("Config. Code", ResultRow[1]."Config. Code");
        if DBLine.FindSet() then
            repeat
                DBField.SetRange("Config. Code", ResultRow[1]."Config. Code");
                DBField.SetRange("Config. Line No.", DBLine."Line No.");
                DBField.SetRange(Included, true);
                if DBField.FindSet() then
                    repeat
                        DBLine.CalcFields("Source Table Name");
                        DBField.CalcFields(Caption, "Field Name");
                        FieldList.Add(JsonEncode(DBLine."Source Table Name") + '.' + JsonEncode(DBField."Field Name"));
                    until DBField.Next() = 0;
                //also force add the timestamp entry:
                FieldList.Add(JsonEncode(DBLine."Source Table Name") + '.timestamp');
                if DBLine.Indentation > MaximumDepth then
                    MaximumDepth := DBLine.Indentation + 1;
            until DBLine.Next() = 0; */

        // For each top level row, call a recusive 'add data to JsonRow' function

        ResultRow[1].SetRange("Belongs To Row No.", 0);  // 'root' level
        if ResultRow[1].FindSet() then
            repeat
                dataLevel := 1;

                // Prep the columns
                Clear(JsonCols);
                /* 
                foreach FieldFullname in FieldList do
                    JsonCols.Add(FieldFullname, ''); */

                if JsonPrefixes.Keys.Count <> 0 then
                    // This is a way to 'prepend' some values to the json, used by the WriteTemplate system
                    JsonCols := JsonPrefixes.Clone().AsObject();

                // Add this Row's fields to the Json:
                AddFieldColsToJsonCols(JsonCols, ResultRow[1]."Row No.");

                // And add children rows:
                AddChildrenRowsToJsonCols(JsonRows, JsonCols, ResultRow[1]."Row No.", MaximumDepth);

            // Add the new 'row' of columns to the array
            //JsonRows.Add(JsonCols.Clone());
            until ResultRow[1].Next() = 0;
        ResultRow[1].SetRange("Belongs To Row No.");
    end;

    local procedure AddChildrenRowsToJsonCols(var JsonRows: JsonArray; var JsonCols: JsonObject; ForWhichRowNo: Integer; MaximumDepth: Integer)
    var
    begin
        dataLevel += 1;
        ResultRow[dataLevel].SetRange("Belongs To Row No.", ForWhichRowNo);
        if ResultRow[dataLevel].FindSet() then
            repeat
                // Add this layer to the data
                AddFieldColsToJsonCols(JsonCols, ResultRow[dataLevel]."Row No.");

                // Add any children's data
                AddChildrenRowsToJsonCols(JsonRows, JsonCols, ResultRow[dataLevel]."Row No.", MaximumDepth);

            until ResultRow[dataLevel].Next() = 0;

        if dataLevel > MaximumDepth then
            JsonRows.Add(JsonCols.Clone());
        dataLevel -= 1;
    end;

    local procedure AddFieldColsToJsonCols(var JsonCols: JsonObject; ForWhichRowNo: Integer)
    var
        IntValue: Integer;
        TestJsonValue: JsonValue;
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
                if ResultCol[dataLevel]."Forced Field Caption" <> '' then
                    SafeAddJsonCols(JsonCols, JsonEncode(ResultRow[dataLevel]."Source Table Name") + '.' + JsonEncode(ResultCol[dataLevel]."Forced Field Caption"), TestJsonValue)
                else
                    SafeAddJsonCols(JsonCols, JsonEncode(ResultRow[dataLevel]."Source Table Name") + '.' + JsonEncode(ResultCol[dataLevel]."Field Name"), TestJsonValue);
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
