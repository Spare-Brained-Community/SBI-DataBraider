codeunit 71033613 "SPB DBraider Error System"
{
    Access = Internal;
    SingleInstance = true;

    var
        //TempLoggingExcelBuffer: Record "Excel Buffer" temporary;
        TempSPBDBraiderResultBuffer: Record "SPB DBraider Result Buffer" temporary;

    procedure ReInitialize()
    begin
        TempSPBDBraiderResultBuffer.Reset();
        TempSPBDBraiderResultBuffer.DeleteAll();
    end;

    procedure HasErrors(): Boolean
    begin
        TempSPBDBraiderResultBuffer.SetRange("Result Type", Enum::"SPB DBraider Result Type"::Error);
        exit(not TempSPBDBraiderResultBuffer.IsEmpty());
    end;

    procedure AddDebug(RowNo: Integer; ResultMessage: Text)
    begin
        AddEntry(RowNo, ResultMessage, Enum::"SPB DBraider Result Type"::Debug);
    end;

    procedure AddResult(RowNo: Integer; ResultMessage: Text)
    begin
        AddEntry(RowNo, ResultMessage, Enum::"SPB DBraider Result Type"::Result);
    end;

    procedure AddError(RowNo: Integer; ResultMessage: Text)
    begin
        AddEntry(RowNo, ResultMessage, Enum::"SPB DBraider Result Type"::Error);
    end;

    procedure AddEntry(RowNo: Integer; ResultMessage: Text; ResultType: Enum "SPB DBraider Result Type")
    var
        NextRowLineNo: Integer;
    begin
        TempSPBDBraiderResultBuffer.Reset();
        if TempSPBDBraiderResultBuffer.FindLast() then
            NextRowLineNo := TempSPBDBraiderResultBuffer."Line No." + 1
        else
            NextRowLineNo := 1;

        TempSPBDBraiderResultBuffer.Reset();
        TempSPBDBraiderResultBuffer.Init();
        TempSPBDBraiderResultBuffer."Row No." := RowNo;
        TempSPBDBraiderResultBuffer."Line No." := NextRowLineNo;
        TempSPBDBraiderResultBuffer."Result Type" := ResultType;
        TempSPBDBraiderResultBuffer.Result := CopyStr(ResultMessage, 1, MaxStrLen(TempSPBDBraiderResultBuffer.Result));
        TempSPBDBraiderResultBuffer.Insert();
    end;

    procedure WriteDebugResults(var JsonResult: Text)
    begin
        WriteResults(JsonResult, true, true, true);
    end;

    procedure WriteResults(var JsonResult: Text)
    begin
        WriteResults(JsonResult, true, false, false);
    end;

    procedure WriteErrors(var JsonResult: Text)
    begin
        WriteResults(JsonResult, false, true, false);
    end;

    procedure WriteResults(var JsonResult: Text; ResultEntry: Boolean; ErrorEntry: Boolean; DebugEntry: Boolean)
    var
        ResultArray: JsonArray;
        ResultObj: JsonObject;
    begin
        TempSPBDBraiderResultBuffer.Reset();
        if TempSPBDBraiderResultBuffer.FindSet() then
            repeat
                if ((TempSPBDBraiderResultBuffer."Result Type" = Enum::"SPB DBraider Result Type"::Error) and ErrorEntry)
                    or ((TempSPBDBraiderResultBuffer."Result Type" = Enum::"SPB DBraider Result Type"::Result) and ResultEntry)
                    or ((TempSPBDBraiderResultBuffer."Result Type" = Enum::"SPB DBraider Result Type"::Debug) and DebugEntry)
                then begin
                    ResultObj.Add('Row', TempSPBDBraiderResultBuffer."Row No.");
                    ResultObj.Add('Column', TempSPBDBraiderResultBuffer."Line No.");
                    ResultObj.Add('Error', TempSPBDBraiderResultBuffer."Result Type" = Enum::"SPB DBraider Result Type"::Error);
                    ResultObj.Add('Detail', TempSPBDBraiderResultBuffer.Result);
                    ResultArray.Add(ResultObj.Clone());
                    Clear(ResultObj);
                end;
            until TempSPBDBraiderResultBuffer.Next() = 0;
        ResultArray.WriteTo(JsonResult);
    end;

    procedure AddArrayToResultArray(NewJsonArray: JsonArray; var ResultArray: JsonArray)
    var
        ThisJsonToken: JsonToken;
    begin
        foreach ThisJsonToken in NewJsonArray do
            ResultArray.Add(ThisJsonToken.Clone());
    end;

    procedure GetBufferedErrors(): Record "SPB DBraider Result Buffer" temporary;
    begin
        exit(TempSPBDBraiderResultBuffer);
    end;

    procedure GetErrorsAsString(): Text
    var
        ErrorList: TextBuilder;
    begin
        ErrorList.Clear();
        TempSPBDBraiderResultBuffer.Reset();
        if TempSPBDBraiderResultBuffer.FindSet() then
            repeat
                if TempSPBDBraiderResultBuffer."Result Type" = Enum::"SPB DBraider Result Type"::Error then
                    ErrorList.AppendLine(TempSPBDBraiderResultBuffer.Result + '|');
            until TempSPBDBraiderResultBuffer.Next() = 0;
        exit(ErrorList.ToText());
    end;
}
