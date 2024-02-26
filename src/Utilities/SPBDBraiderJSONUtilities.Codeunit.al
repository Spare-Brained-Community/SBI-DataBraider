codeunit 71033604 "SPB DBraider JSON Utilities"
{
    SingleInstance = true;

    procedure JsonSafeTableFieldName(InputText: Text) OutputText: Text
    var
        preserveChars: Text;
    begin
        preserveChars := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        OutputText := DelChr(InputText, '=', DelChr(InputText, '=', preserveChars));
    end;

    procedure ConvertBraiderTypeToJsonType(BraiderType: Enum "SPB DBraider Field Data Type"): Text
    begin
        case BraiderType of
            BraiderType::Integer, BraiderType::Decimal:
                exit('number');
            BraiderType::Boolean:
                exit('boolean');
            else
                exit('string');
        end;
    end;

    procedure TestResultRun(ConfigCode: Code[20])
    var
        TempResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempResultRow: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderDataEngine: Codeunit "SPB DBraider Data Engine";
        ResultPreview: Page "SPB DBraider Results";
    begin
        SPBDBraiderDataEngine.GenerateData(ConfigCode);

        SPBDBraiderDataEngine.GetResults(TempResultRow, TempResultCol);

        Clear(ResultPreview);
        ResultPreview.SetTempData(TempResultRow, TempResultCol);
        ResultPreview.Run();
    end;

    procedure TestResultJson(ConfigCode: Code[20])
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        TempResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempResultRow: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderDataEngine: Codeunit "SPB DBraider Data Engine";
        JsonPreviewPage: Page "SPB DBraider Result JSON";
        SPBDBraiderIDatasetToText: Interface "SPB DBraider IDatasetToText";
        JsonPreview: Text;
    begin
        SPBDBraiderConfigHeader.Get(ConfigCode);
        SPBDBraiderDataEngine.GenerateData(ConfigCode);
        SPBDBraiderDataEngine.GetResults(TempResultRow, TempResultCol);
        SPBDBraiderIDatasetToText := SPBDBraiderConfigHeader."Output JSON Type";
        JsonPreview := SPBDBraiderIDatasetToText.ConvertToJSONText(TempResultRow, TempResultCol);
        Clear(JsonPreviewPage);
        JsonPreviewPage.SetTextToShow(JsonPreview);
        JsonPreviewPage.Run();
    end;

    internal procedure ExtractNumber(InputText: Text) OutputInt: Integer
    var
        preserveChars: Text;
    begin
        preserveChars := '0123456789';
        Evaluate(OutputInt, DelChr(InputText, '=', DelChr(InputText, '=', preserveChars)));
    end;

    internal procedure ExtractPathFromMatches(var TableName: Text; var FieldName: Text; var Matches: Record Matches)
    var
        TableFieldList: List of [Text];
    begin
        if Matches.FindFirst() then
            TableFieldList := Matches.ReadValue().Split('.');
        TableFieldList.Get(1, TableName);
        TableFieldList.Get(2, FieldName);
    end;


    // Strangely, I can't find any JSON Escape or Unescape functions in AL, so I've had to write my own.
    procedure EscapeJson(SampleJson: Text) EscapedJson: Text
    var
        BackslashChar: Char;
        BackspaceChar: Char;
        c: Char;
        CarriageReturnChar: Char;
        FormFeedChar: Char;
        ForwardSlashChar: Char;
        NewLineChar: Char;
        QuotationMarkChar: Char;
        TabChar: Char;
        i: Integer;
        EscapedJsonBuilder: TextBuilder;
    begin
        i := 1;
        EscapedJsonBuilder.Clear();

        //JSON Escape Characters
        QuotationMarkChar := 34;
        BackslashChar := 92;
        ForwardSlashChar := 47;
        BackspaceChar := 8;
        FormFeedChar := 12;
        NewLineChar := 10;
        CarriageReturnChar := 13;
        TabChar := 9;

        while i <= StrLen(SampleJson) do begin
            c := SampleJson[i];

            case c of
                QuotationMarkChar:
                    EscapedJsonBuilder.Append('\"');
                BackslashChar:
                    EscapedJsonBuilder.Append('\\');
                ForwardSlashChar:
                    EscapedJsonBuilder.Append('\/');
                NewLineChar:
                    EscapedJsonBuilder.Append('\n');
                CarriageReturnChar:
                    EscapedJsonBuilder.Append('\r');
                TabChar:
                    EscapedJsonBuilder.Append('\t');
                BackspaceChar:
                    EscapedJsonBuilder.Append('\b');
                FormFeedChar:
                    EscapedJsonBuilder.Append('\f');
                else
                    EscapedJsonBuilder.Append(c);
            end;
            i += 1;
        end;

        EscapedJson := EscapedJsonBuilder.ToText();
    end;

    procedure UnescapeJson(EscapedJson: Text) UnescapedJson: Text
    var
        BackslashChar: Char;
        BackspaceChar: Char;
        c: Char;
        CarriageReturnChar: Char;
        FormFeedChar: Char;
        ForwardSlashChar: Char;
        NewLineChar: Char;
        QuotationMarkChar: Char;
        TabChar: Char;
        i: Integer;
        UnescapedJsonBuilder: TextBuilder;
    begin
        i := 1;
        UnescapedJsonBuilder.Clear();

        //JSON Escape Characters
        QuotationMarkChar := 34;
        BackslashChar := 92;
        ForwardSlashChar := 47;
        BackspaceChar := 8;
        FormFeedChar := 12;
        NewLineChar := 10;
        CarriageReturnChar := 13;
        TabChar := 9;

        while i <= StrLen(EscapedJson) do begin
            c := EscapedJson[i];

            if c = '\' then begin
                i += 1;
                c := EscapedJson[i];

                case c of
                    '"':
                        UnescapedJsonBuilder.Append(QuotationMarkChar);
                    '\':
                        UnescapedJsonBuilder.Append(BackslashChar);
                    '/':
                        UnescapedJsonBuilder.Append(ForwardSlashChar);
                    'b':
                        UnescapedJsonBuilder.Append(BackspaceChar); // Backspace
                    'f':
                        UnescapedJsonBuilder.Append(FormFeedChar); // Form feed
                    'n':
                        UnescapedJsonBuilder.Append(NewLineChar); // New line
                    'r':
                        UnescapedJsonBuilder.Append(CarriageReturnChar); // Carriage return
                    't':
                        UnescapedJsonBuilder.Append(TabChar); // Tab
                    else
                        UnescapedJsonBuilder.Append(c);
                end;
            end
            else
                UnescapedJsonBuilder.Append(c);

            i += 1;
        end;
        UnescapedJson := UnescapedJsonBuilder.ToText();
    end;
}
