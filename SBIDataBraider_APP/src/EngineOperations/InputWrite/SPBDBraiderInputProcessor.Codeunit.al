codeunit 71033607 "SPB DBraider Input Processor"
{

    var
        TempEventNotes: Record "SPBDBraider Event Notification" temporary;
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        EventNoteMgt: Codeunit "SPB DBraider Event Note Mgt";
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";

    procedure ProcessWriteData(ConfigCode: Code[20]; JsonInput: Text) JsonResult: Text
    var
        TempJSONBuffer: Record "JSON Buffer" temporary;
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderInputValidator: Codeunit "SPB DBraider Input Validator";
        JsonResultArray: JsonArray;
        Error1Lbl: Label 'Validation failed: %1', Comment = '%1 = Last Error Message';
        NotEnabledErr: Label 'This endpoint could not be found or is not enabled.';
    begin
        SPBDBraiderErrorSystem.ReInitialize();

        SPBDBraiderConfigHeader.Get(ConfigCode);
        if not SPBDBraiderConfigHeader.Enabled then
            exit(NotEnabledErr);
        SPBDBraiderEvents.OnBeforeWriteData(SPBDBraiderConfigHeader, JsonInput);

        LoadDataIntoJSONBuffers(ConfigCode, JsonInput, TempJSONBuffer);

        /* Now we try to Validate, then Apply the data */
        Commit();
        if SPBDBraiderInputValidator.Run(TempJSONBuffer) then begin
            TempJSONBuffer.Reset();
            TempJSONBuffer.SetRange("SPB Mapping Record", false);
            case SPBDBraiderConfigHeader."Endpoint Type" of
                "SPB DBraider Endpoint Type"::Batch:
                    if TryToBatchWriteData(SPBDBraiderConfigHeader, TempJSONBuffer, JsonResultArray) then begin
                        SPBDBraiderEvents.OnBeforeConvertJSONtoText(SPBDBraiderConfigHeader.Code, JsonResultArray, JsonResult);
                        JsonResultArray.WriteTo(JsonResult);
                        SPBDBraiderEvents.OnAfterConvertJSONtoText(SPBDBraiderConfigHeader.Code, JsonResultArray, JsonResult);
                    end else
                        SPBDBraiderErrorSystem.WriteErrors(JsonResult);
                "SPB DBraider Endpoint Type"::"Per Record":
                    if TryToSingleWriteData(SPBDBraiderConfigHeader, TempJSONBuffer, JsonResultArray) then begin
                        SPBDBraiderEvents.OnBeforeConvertJSONtoText(SPBDBraiderConfigHeader.Code, JsonResultArray, JsonResult);
                        JsonResultArray.WriteTo(JsonResult);
                        SPBDBraiderEvents.OnAfterConvertJSONtoText(SPBDBraiderConfigHeader.Code, JsonResultArray, JsonResult);
                    end else
                        SPBDBraiderErrorSystem.WriteErrors(JsonResult);
            end
        end else begin
            SPBDBraiderErrorSystem.AddError(-1, StrSubstNo(Error1Lbl, GetLastErrorText()));
            SPBDBraiderErrorSystem.WriteErrors(JsonResult);
        end;
        SPBDBraiderEvents.OnAfterWriteData(SPBDBraiderConfigHeader, JsonInput, JsonResult, not SPBDBraiderErrorSystem.HasErrors());
    end;

    local procedure TryToBatchWriteData(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    var TempJSONBuffer: Record "JSON Buffer" temporary;
    var JsonResultArray: JsonArray) CompleteSuccess: Boolean;
    var
        SPBDBraiderWriteData: Codeunit "SPB DBraider Write Data";
        WriteFailLbl: Label 'Writing data failed: %1', Comment = '%1 = Last Error Message';
    begin
        CompleteSuccess := true;
        if SPBDBraiderWriteData.Run(TempJSONBuffer) then
            SPBDBraiderErrorSystem.AddArrayToResultArray(SPBDBraiderWriteData.GetResults(SPBDBraiderConfigHeader), JsonResultArray)
        else begin
            SPBDBraiderErrorSystem.AddError(-1, StrSubstNo(WriteFailLbl, GetLastErrorText()));
            CompleteSuccess := false;
        end;
        if CompleteSuccess then begin
            EventNoteMgt.GetEventNotes(TempEventNotes);
            SPBDBraiderEvents.OnAfterWritetoEventNotification(TempEventNotes);
        end;
    end;

    local procedure TryToSingleWriteData(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    var TempJSONBuffer: Record "JSON Buffer" temporary;
    var JsonResultArray: JsonArray) CompleteSuccess: Boolean;
    var
        TempContentJsonBuffer: Record "JSON Buffer" temporary;
        TempHeaderJsonBuffer: Record "JSON Buffer" temporary;
        SPBDBraiderWriteData: Codeunit "SPB DBraider Write Data";
        WriteFailLbl: Label 'Writing data failed: %1', Comment = '%1 = Last Error Message';
    begin
        CompleteSuccess := true;
        TempHeaderJsonBuffer.Copy(TempJSONBuffer, true);
        TempContentJsonBuffer.Copy(TempJSONBuffer, true);
        TempHeaderJsonBuffer.SetRange("Token type", TempHeaderJsonBuffer."Token type"::"Start Object");
        if TempHeaderJsonBuffer.FindSet() then
            repeat
                Commit();  // Due to Codeunit.Run, we have to commit per record
                TempContentJsonBuffer.FilterGroup(11);
                TempContentJsonBuffer.SetRange("SPB Record Id", TempHeaderJsonBuffer."SPB Record Id");
                TempContentJsonBuffer.FilterGroup(0);
                Clear(SPBDBraiderWriteData);
                if not SPBDBraiderWriteData.Run(TempContentJsonBuffer) then begin
                    SPBDBraiderErrorSystem.AddError(TempHeaderJsonBuffer."SPB Record Id", StrSubstNo(WriteFailLbl, GetLastErrorText()));
                    CompleteSuccess := false;
                end else
                    SPBDBraiderErrorSystem.AddArrayToResultArray(SPBDBraiderWriteData.GetResults(SPBDBraiderConfigHeader), JsonResultArray);
            until TempHeaderJsonBuffer.Next() = 0;

        if CompleteSuccess then begin
            EventNoteMgt.GetEventNotes(TempEventNotes);
            SPBDBraiderEvents.OnAfterWritetoEventNotification(TempEventNotes);
        end;
    end;

    internal procedure LoadDataIntoJSONBuffers(ConfigCode: Code[20]; JsonInput: Text; var TempJSONBuffer: Record "JSON Buffer" temporary)
    var
        NextBufferEntryNo: Integer;
    begin
        TempJSONBuffer.ReadFromText(JsonInput);
        if TempJSONBuffer.FindLast() then
            NextBufferEntryNo := TempJSONBuffer."Entry No." + 1
        else
            NextBufferEntryNo := 1;

        LoadMappingDataIntoJSONBuffers(ConfigCode, TempJSONBuffer, NextBufferEntryNo);
    end;

    internal procedure LoadMappingDataIntoJSONBuffers(ConfigCode: Code[20]; var TempJSONBuffer: Record "JSON Buffer" temporary; var NextBufferEntryNo: Integer)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
    begin
        /* We need to pass only one table to codeunits, soo.... */
        SPBDBraiderConfigLine.SetRange("Config. Code", ConfigCode);
        if SPBDBraiderConfigLine.FindSet() then
            repeat
                //Table into Path
                TempJSONBuffer.Init();
                TempJSONBuffer."Entry No." := NextBufferEntryNo;
                NextBufferEntryNo += 1;
                TempJSONBuffer."SPB Mapping Record" := true;
                SPBDBraiderConfigLine.CalcFields("Source Table Name");
                TempJSONBuffer."SPB Source Table Name" := CopyStr(SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfigLine."Source Table Name"), 1, MaxStrLen(TempJSONBuffer."SPB Source Table Name"));
                TempJSONBuffer."SPB Table No." := SPBDBraiderConfigLine."Source Table";

                TempJSONBuffer."SPB Config. Code" := SPBDBraiderConfigLine."Config. Code";
                TempJSONBuffer."SPB Config. Line No." := SPBDBraiderConfigLine."Line No.";
                TempJSONBuffer."SPB Config. Depth" := SPBDBraiderConfigLine.Indentation;
                TempJSONBuffer.Insert();
            until SPBDBraiderConfigLine.Next() = 0;
        SPBDBraiderConfLineField.SetRange("Config. Code", ConfigCode);
        if SPBDBraiderConfLineField.FindSet() then
            repeat
                SPBDBraiderConfigLine.Get(SPBDBraiderConfLineField."Config. Code", SPBDBraiderConfLineField."Config. Line No.");
                //Table into Path
                TempJSONBuffer.Init();
                TempJSONBuffer."Entry No." := NextBufferEntryNo;
                NextBufferEntryNo += 1;
                TempJSONBuffer."SPB Mapping Record" := true;
                SPBDBraiderConfLineField.CalcFields("Table Name", "Field Name", Caption);
                TempJSONBuffer."SPB Source Table Name" := CopyStr(SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField."Table Name"), 1, MaxStrLen(TempJSONBuffer."SPB Source Table Name"));
                TempJSONBuffer."SPB Source Field Name" := CopyStr(SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField."Field Name"), 1, MaxStrLen(TempJSONBuffer."SPB Source Field Name"));
                if SPBDBraiderConfLineField."Manual Field Caption" <> '' then
                    TempJSONBuffer."SPB Source Field Caption" := CopyStr(SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField."Manual Field Caption"), 1, MaxStrLen(TempJSONBuffer."SPB Source Field Caption"))
                else
                    TempJSONBuffer."SPB Source Field Caption" := CopyStr(SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField.Caption), 1, MaxStrLen(TempJSONBuffer."SPB Source Field Caption"));
                TempJSONBuffer."SPB Field No." := SPBDBraiderConfLineField."Field No.";
                TempJSONBuffer."SPB Write Enabled" := SPBDBraiderConfLineField."Write Enabled";
                TempJSONBuffer."SPB Default Value" := SPBDBraiderConfLineField."Default Value";
                TempJSONBuffer."SPB Disable Validate" := SPBDBraiderConfLineField."Disable Validation";

                TempJSONBuffer."SPB Config. Code" := SPBDBraiderConfLineField."Config. Code";
                TempJSONBuffer."SPB Config. Line No." := SPBDBraiderConfLineField."Config. Line No.";
                TempJSONBuffer."SPB Config. Field No." := SPBDBraiderConfLineField."Field No.";
                TempJSONBuffer."SPB Config. Depth" := SPBDBraiderConfigLine.Indentation;
                TempJSONBuffer."SPB Processing Order" := SPBDBraiderConfLineField."Processing Order";
                TempJSONBuffer.Insert();
            until SPBDBraiderConfLineField.Next() = 0;
    end;
}
