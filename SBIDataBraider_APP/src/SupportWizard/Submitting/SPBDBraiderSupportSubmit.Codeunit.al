codeunit 71033627 "SPB DBraider Support Submit"
{
    Access = Internal;

    var
        SPBDBraiderSetup: Record "SPB DBraider Setup";
        BraiderSetupDescTok: Label 'Data Braider Setup';
        ChecksDescTok: Label 'Support Wizard Check Results';
        EndpointExportsDescTok: Label 'Braider Endpoint Configurations';
        EnvUsageDataDescTok: Label 'Basic environment (version, cloud) and Braider-specific telemetry data';
        LogsDescTok: Label 'Braider Endpoint Logs';

    procedure PopulateSubmissionList(var TempSPBDBraiderWizSubmit: Record "SPB DBraider Wiz Submit" temporary)
    var
        NextLineNo: Integer;
    begin
        // This is to show what files will be submitted to SBI for the support case
        // This includes the Data Braider setup, the endpoint exports, the logs for the selected endpoints in step 2, the checks that were run in step 3,
        // as well as basic information about the environment and usage data
        TempSPBDBraiderWizSubmit.DeleteAll();
        NextLineNo := 1;

        // Data Braider Setup
        TempSPBDBraiderWizSubmit.Init();
        TempSPBDBraiderWizSubmit."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBDBraiderWizSubmit.Description := StrSubstNo(BraiderSetupDescTok);
        TempSPBDBraiderWizSubmit.Include := true;
        TempSPBDBraiderWizSubmit.Insert();

        // Endpoint Exports
        TempSPBDBraiderWizSubmit.Init();
        TempSPBDBraiderWizSubmit."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBDBraiderWizSubmit.Description := StrSubstNo(EndpointExportsDescTok);
        TempSPBDBraiderWizSubmit.Include := true;
        TempSPBDBraiderWizSubmit.Insert();

        // Logs
        TempSPBDBraiderWizSubmit.Init();
        TempSPBDBraiderWizSubmit."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBDBraiderWizSubmit.Description := StrSubstNo(LogsDescTok);
        TempSPBDBraiderWizSubmit.Include := true;
        TempSPBDBraiderWizSubmit.Insert();

        // Checks
        TempSPBDBraiderWizSubmit.Init();
        TempSPBDBraiderWizSubmit."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBDBraiderWizSubmit.Description := StrSubstNo(ChecksDescTok);
        TempSPBDBraiderWizSubmit.Include := true;
        TempSPBDBraiderWizSubmit.Insert();

        // Environment and Usage Data
        TempSPBDBraiderWizSubmit.Init();
        TempSPBDBraiderWizSubmit."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBDBraiderWizSubmit.Description := StrSubstNo(EnvUsageDataDescTok);
        TempSPBDBraiderWizSubmit.Include := true;
        TempSPBDBraiderWizSubmit.Insert();
    end;

    procedure SubmitSupportRequest(
        var TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary;
        var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary;
        var TempSPBDBraiderWizSubmit: Record "SPB DBraider Wiz Submit" temporary;
        CaseDescription: Text;
        CaseSeverity: Option " ","Critical - Production Stopped","High - Production Impacted","Medium - Production Not Impacted","Low - No Production Impact";
        CaseContactName: Text;
        CaseEmail: Text
    )
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        OutS: OutStream;
        ZipFileName: Text;
    begin
        SPBDBraiderSetup.GetRecordOnce();

        // Prep the archive for the files
        DataCompression.CreateZipArchive();
        ZipFileName := 'DataBraiderSupportCaseDetails.zip';

        TempSPBDBraiderWizSubmit.SetRange(Include, true);
        if TempSPBDBraiderWizSubmit.FindSet() then
            repeat
                case TempSPBDBraiderWizSubmit.Description of
                    StrSubstNo(BraiderSetupDescTok):
                        AddSetupToZip(DataCompression);
                    StrSubstNo(EndpointExportsDescTok):
                        AddEndpointExportsToZip(DataCompression, TempSelectedEndpoints);
                    StrSubstNo(LogsDescTok):
                        AddLogsToZip(DataCompression, TempSelectedEndpoints);
                    StrSubstNo(ChecksDescTok):
                        AddChecksToZip(DataCompression, TempSPBDBraiderWizChecks);
                    StrSubstNo(EnvUsageDataDescTok):
                        AddEnvUsageDataToZip(DataCompression);
                end;
            until TempSPBDBraiderWizSubmit.Next() < 1;

        // Now Time to prepare the ZIP to save/send
        TempBlob.CreateOutStream(OutS);
        DataCompression.SaveZipArchive(OutS);
        TempBlob.CreateInStream(InS);

        // Now we need to send the case to SBI
        SendSupportRequest(CaseDescription, CaseSeverity, CaseContactName, CaseEmail, ZipFileName, InS);
    end;

    local procedure AddSetupToZip(var DataCompression: Codeunit "Data Compression")
    var
        TempBlob: Codeunit "Temp Blob";
        SetupRecordRef: RecordRef;
        InS: InStream;
    begin
        SetupRecordRef.Open(Database::"SPB DBraider Setup");
        if SetupRecordRef.FindFirst() then begin
            ConvertRecordRefToCSV(SetupRecordRef, TempBlob);
            TempBlob.CreateInStream(InS);
            DataCompression.AddEntry(InS, 'DataBraiderSetup.csv');
        end;
    end;

    local procedure AddEndpointExportsToZip(var DataCompression: Codeunit "Data Compression"; var TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary)
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineRel: Record "SPB DBraider ConfLine Relation";
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Flow";
        TempBlob: Codeunit "Temp Blob";
        ThisRecordRef: RecordRef;
        InS: InStream;
    begin
        if TempSelectedEndpoints.FindSet() then
            repeat
                SPBDBraiderConfigHeader.Get(TempSelectedEndpoints.Code);
                ThisRecordRef.Open(Database::"SPB DBraider Config. Header");
                ThisRecordRef.GetTable(SPBDBraiderConfigHeader);
                ConvertRecordRefToCSV(ThisRecordRef, TempBlob);
                TempBlob.CreateInStream(InS);
                DataCompression.AddEntry(InS, SPBDBraiderConfigHeader."Code" + '\EndpointExport_' + SPBDBraiderConfigHeader."Code" + '.csv');
                ThisRecordRef.Close();

                // for each Config Line, we want to save the line, the fields, relations, and flows to CSV
                SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
                if SPBDBraiderConfigLine.FindSet() then
                    repeat
                        ThisRecordRef.Open(Database::"SPB DBraider Config. Line");
                        ThisRecordRef.GetTable(SPBDBraiderConfigLine);
                        ConvertRecordRefToCSV(ThisRecordRef, TempBlob);
                        TempBlob.CreateInStream(InS);
                        DataCompression.AddEntry(InS, SPBDBraiderConfigHeader."Code" + '\' + Format(SPBDBraiderConfigLine."Line No.") + '\EndpointLineExport_' + Format(SPBDBraiderConfigLine."Source Table") + '.csv');
                        ThisRecordRef.Close();

                        SPBDBraiderConfLineField.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                        SPBDBraiderConfLineField.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                        if SPBDBraiderConfLineField.FindSet() then
                            repeat
                                ThisRecordRef.Open(Database::"SPB DBraider ConfLine Field");
                                ThisRecordRef.GetTable(SPBDBraiderConfLineField);
                                ConvertRecordRefToCSV(ThisRecordRef, TempBlob);
                                TempBlob.CreateInStream(InS);
                                DataCompression.AddEntry(InS, SPBDBraiderConfigHeader."Code" + '\' + Format(SPBDBraiderConfigLine."Line No.") + '\EndpointLineExport_' + Format(SPBDBraiderConfigLine."Source Table") + '_Fields.csv');
                                ThisRecordRef.Close();
                            until SPBDBraiderConfLineField.Next() < 1;

                        SPBDBraiderConfLineRel.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                        SPBDBraiderConfLineRel.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                        if SPBDBraiderConfLineRel.FindSet() then
                            repeat
                                ThisRecordRef.Open(Database::"SPB DBraider ConfLine Relation");
                                ThisRecordRef.GetTable(SPBDBraiderConfLineRel);
                                ConvertRecordRefToCSV(ThisRecordRef, TempBlob);
                                TempBlob.CreateInStream(InS);
                                DataCompression.AddEntry(InS, SPBDBraiderConfigHeader."Code" + '\' + Format(SPBDBraiderConfigLine."Line No.") + '\EndpointLineExport_' + Format(SPBDBraiderConfigLine."Source Table") + '_Relations.csv');
                                ThisRecordRef.Close();
                            until SPBDBraiderConfLineRel.Next() < 1;

                        SPBDBraiderConfLineFlow.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                        SPBDBraiderConfLineFlow.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                        if SPBDBraiderConfLineFlow.FindSet() then
                            repeat
                                ThisRecordRef.Open(Database::"SPB DBraider ConfLine Flow");
                                ThisRecordRef.GetTable(SPBDBraiderConfLineFlow);
                                ConvertRecordRefToCSV(ThisRecordRef, TempBlob);
                                TempBlob.CreateInStream(InS);
                                DataCompression.AddEntry(InS, SPBDBraiderConfigHeader."Code" + '\' + Format(SPBDBraiderConfigLine."Line No.") + '\EndpointLineExport_' + Format(SPBDBraiderConfigLine."Source Table") + '_Flows.csv');
                                ThisRecordRef.Close();
                            until SPBDBraiderConfLineFlow.Next() < 1;
                    until SPBDBraiderConfigLine.Next() < 1;
            until TempSelectedEndpoints.Next() < 1;
    end;

    local procedure AddLogsToZip(var DataCompression: Codeunit "Data Compression"; var TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary)
    var
        SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
        TempBlob: Codeunit "Temp Blob";
        LogRecordRef: RecordRef;
        InS: InStream;
        OutS: OutStream;
    begin
        if TempSelectedEndpoints.FindSet() then
            repeat
                SPBDBraiderEndpointLog.SetAutoCalcFields("Raw Input", "Raw Output");
                SPBDBraiderEndpointLog.SetRange("Config. Code", TempSelectedEndpoints.Code);
                if SPBDBraiderEndpointLog.FindSet() then
                    repeat
                        // Export the log entry itself to CSV
                        LogRecordRef.Open(Database::"SPB DBraider Endpoint Log");
                        LogRecordRef.GetTable(SPBDBraiderEndpointLog);
                        ConvertRecordRefToCSV(LogRecordRef, TempBlob);
                        TempBlob.CreateInStream(InS);
                        DataCompression.AddEntry(InS, SPBDBraiderEndpointLog."Config. Code" + '\EndpointLog_' + Format(SPBDBraiderEndpointLog."Entry No.") + '.csv');

                        // We also want the blob of the "Raw Input" to save as a JSON file
                        Clear(TempBlob);
                        TempBlob.CreateOutStream(OutS);
                        SPBDBraiderEndpointLog."Raw Input".CreateInStream(InS);
                        CopyStream(OutS, InS);
                        TempBlob.CreateInStream(InS);
                        DataCompression.AddEntry(InS, SPBDBraiderEndpointLog."Config. Code" + '\EndpointLog_' + Format(SPBDBraiderEndpointLog."Entry No.") + '_RawInput.json');

                        // We also want the blob of the "Raw Output" to save as a JSON file
                        Clear(TempBlob);
                        TempBlob.CreateOutStream(OutS);
                        SPBDBraiderEndpointLog."Raw Output".CreateInStream(InS);
                        CopyStream(OutS, InS);
                        TempBlob.CreateInStream(InS);
                        DataCompression.AddEntry(InS, SPBDBraiderEndpointLog."Config. Code" + '\EndpointLog_' + Format(SPBDBraiderEndpointLog."Entry No.") + '_RawOutput.json');

                        LogRecordRef.Close();
                    until SPBDBraiderEndpointLog.Next() < 1;
            until TempSelectedEndpoints.Next() < 1;
    end;

    local procedure AddChecksToZip(var DataCompression: Codeunit "Data Compression"; var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    var
        TempBlob: Codeunit "Temp Blob";
        WizChecksRecordRef: RecordRef;
        InS: InStream;
    begin
        // Here we're just saving the results of the checks to a CSV file
        if TempSPBDBraiderWizChecks.FindSet() then
            repeat
                WizChecksRecordRef.Open(Database::"SPB DBraider WizChecks", true);
                WizChecksRecordRef.GetTable(TempSPBDBraiderWizChecks);
                ConvertRecordRefToCSV(WizChecksRecordRef, TempBlob);
                TempBlob.CreateInStream(InS);
                DataCompression.AddEntry(InS, 'Checks\' + Format(TempSPBDBraiderWizChecks."Check Code") + '-' + Format(TempSPBDBraiderWizChecks."Endpoint Code") + '.csv');
                WizChecksRecordRef.Close();
            until TempSPBDBraiderWizChecks.Next() < 1;
    end;

    local procedure AddEnvUsageDataToZip(var DataCompression: Codeunit "Data Compression")
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        AppSysConstants: Codeunit "Application System Constants";
        EnvironmentInfo: Codeunit "Environment Information";
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        NextLineNo: Integer;
        NavAppModuleInfo: ModuleInfo;
    begin
        NextLineNo := 1;

        // We want to save some information from the environment to a CSV file
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'OnPrem', Format(EnvironmentInfo.IsOnPrem(), 0, 9));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'IsProduction', Format(EnvironmentInfo.IsProduction(), 0, 9));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'IsSandBox', Format(EnvironmentInfo.IsSandbox(), 0, 9));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'ApplicationVersion', Format(AppSysConstants.ApplicationVersion()));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'ApplicationBuild', Format(AppSysConstants.ApplicationBuild()));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'PlatformProductVersion', Format(AppSysConstants.PlatformProductVersion()));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'PlatformFileVersion', Format(AppSysConstants.PlatformFileVersion()));

        // We also want some data about the current company
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'CompanyName', Format(CompanyName()));

        // We also want some data about Braider
        NavApp.GetCurrentModuleInfo(NavAppModuleInfo);
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'BraiderAppVersion', Format(NavAppModuleInfo.AppVersion()));
        WriteKeyValueToCSV(TempCSVBuffer, NextLineNo, 'BraiderDataVersion', Format(NavAppModuleInfo.DataVersion()));

        // now add the CSV to the zip
        TempCSVBuffer.SaveDataToBlob(TempBlob, ';');
        TempBlob.CreateInStream(InS);
        DataCompression.AddEntry(InS, 'EnvironmentInfo.csv');
    end;

    local procedure ConvertRecordRefToCSV(var RecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        FieldRef: FieldRef;
        i: Integer;
    begin
        TempCSVBuffer.Init();
        for i := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(i);
            if SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FieldRef.Type()) <> Enum::"SPB DBraider Field Data Type"::Unsupported then begin
                TempCSVBuffer.Init();
                TempCSVBuffer."Line No." := i;
                TempCSVBuffer."Field No." := 1;
                TempCSVBuffer.Value := CopyStr(FieldRef.Name(), 1, MaxStrLen(TempCSVBuffer.Value));
                TempCSVBuffer.Insert();

                TempCSVBuffer.Init();
                TempCSVBuffer."Line No." := i;
                TempCSVBuffer."Field No." := 2;
                TempCSVBuffer.Value := Format(FieldRef.Value(), 0, 9);
                TempCSVBuffer.Insert();
            end;
        end;
        TempCSVBuffer.SaveDataToBlob(TempBlob, ';');
    end;

    local procedure WriteKeyValueToCSV(var TempCSVBuffer: Record "CSV Buffer" temporary; var NextLineNo: Integer; CSVKey: Text; CSVValue: Text)
    begin
        TempCSVBuffer.Init();
        TempCSVBuffer."Line No." := NextLineNo;
        TempCSVBuffer."Field No." := 1;
        TempCSVBuffer.Value := CopyStr(CSVKey, 1, MaxStrLen(TempCSVBuffer.Value));
        TempCSVBuffer.Insert();

        TempCSVBuffer.Init();
        TempCSVBuffer."Line No." := NextLineNo;
        TempCSVBuffer."Field No." := 2;
        TempCSVBuffer.Value := CopyStr(CSVValue, 1, MaxStrLen(TempCSVBuffer.Value));
        TempCSVBuffer.Insert();
        NextLineNo += 1;
    end;

    // This function makes an API call to an SBI endpoint to submit the support case, including the ZIP file
    local procedure SendSupportRequest(CaseDescription: Text; CaseSeverity: Option; CaseContactName: Text; CaseEmail: Text; ZipFileName: Text; SupportFilesInStream: InStream)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        TempBlob: Codeunit "Temp Blob";
        IsSuccessful: Boolean;
        HttpClient: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        MultiPartBodyInStream: InStream;
        SubmitFailMsg: Label 'Something went wrong while submitting the support case.  Your data file was prepared, and will download.  Then the manual support case submission page will open - please submit the case manually.  Keep the file saved, as our support team will need it.';
        SubmitSuccessMsg: Label 'Support case submitted successfully!  Your contact will have received an email with your case number, %1', Comment = '%1 is the Case Number';
        SubmittingCaseMsg: Label 'Submitting support case to Spare Brained Ideas... Please hold.';
        SupportLogicAppURITok: Label 'https://prod2-28.swedencentral.logic.azure.com:443/workflows/b9a6081d03f44fe0a7a0e7ea8767643e/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=BlBZfPf3J0aVHKh9SZ8GLKRVVH6DVnvov5t5FXrZJz4', Comment = '%1 %2 %3 are coincidental', Locked = true;
        SupportManualURITok: Label 'https://forms.office.com/Pages/ResponsePage.aspx?id=tcPV_VeQJUmo5g8XfKujJiC9pSIa6rNOktCATZRNDRBUOVIwTzFTRlc3NDdGVlhFRkM3MkRUNVQySi4u', Locked = true;
        MultiPartBodyOutStream: OutStream;
        Boundary: Text;
        CaseId: Text;
        MultiPartBody: TextBuilder;
        Window: Dialog;
    begin
        TempBlob.CreateOutStream(MultiPartBodyOutStream);

        Boundary := CreateGuid();
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="caseDescription"');
        MultiPartBody.AppendLine('Content-Type: text/plain');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(CaseDescription);
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="caseSeverity"');
        MultiPartBody.AppendLine('Content-Type: text/plain');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(Format(CaseSeverity));
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="caseContactName"');
        MultiPartBody.AppendLine('Content-Type: text/plain');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(CaseContactName);
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="caseEmail"');
        MultiPartBody.AppendLine('Content-Type: text/plain');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(CaseEmail);
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="zipFileName"');
        MultiPartBody.AppendLine('Content-Type: text/plain');
        MultiPartBody.AppendLine();
        MultiPartBody.AppendLine(ZipFileName);
        MultiPartBody.AppendLine('--' + Format(Boundary));
        MultiPartBody.AppendLine('Content-Disposition: form-data; name="file"; filename="' + ZipFileName + '"');
        MultiPartBody.AppendLine('Content-Type: application/octet-stream');
        MultiPartBody.AppendLine();
        MultiPartBodyOutStream.WriteText(MultiPartBody.ToText());

        CopyStream(MultiPartBodyOutStream, SupportFilesInStream);

        MultiPartBody.AppendLine('--' + Format(Boundary) + '--');
        MultiPartBodyOutStream.WriteText(MultiPartBody.ToText());

        TempBlob.CreateInStream(MultiPartBodyInStream);
        Content.WriteFrom(MultiPartBodyInStream);

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'multipart/form-data; boundary="' + Format(Boundary) + '"');

        Window.Open(SubmittingCaseMsg);
        IsSuccessful := HttpClient.Post(SupportLogicAppURITok, Content, Response);
        Window.Close();

        if IsSuccessful then begin
            Response.Content().ReadAs(CaseId);
            Message(SubmitSuccessMsg, CaseId);
        end else begin
            if not ConfirmManagement.GetResponseOrDefault(SubmitFailMsg, true) then // Halting execution to let the user see what is about to happen
                exit;
            DownloadFromStream(SupportFilesInStream, 'Support Case Data File', '', '', ZipFileName);
            Hyperlink(SupportManualURITok);
        end;
    end;
}
