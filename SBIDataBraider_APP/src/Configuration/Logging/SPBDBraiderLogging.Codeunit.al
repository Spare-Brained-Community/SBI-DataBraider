codeunit 71033614 "SPB DBraider Logging"
{
    Access = Internal;
    SingleInstance = true;  // We're dealing with API calls, so this is reset constantly, but useful for parking cross-event info

    var
        LogEntryCode: Code[20];
        LogEntryNo: Integer;

    local procedure CreateNextLogEntry(DBHeader: Record "SPB DBraider Config. Header"; InputText: Text): Integer
    var
        SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
        NextEntryNo: Integer;
        LogOutStream: OutStream;
    begin
        SPBDBraiderEndpointLog.SetRange("Config. Code", DBHeader.Code);
        if SPBDBraiderEndpointLog.FindLast() then
            NextEntryNo := SPBDBraiderEndpointLog."Entry No." + 1
        else
            NextEntryNo := 1;

        SPBDBraiderEndpointLog.Init();
        SPBDBraiderEndpointLog."Config. Code" := DBHeader.Code;
        SPBDBraiderEndpointLog."Entry No." := NextEntryNo;
        SPBDBraiderEndpointLog.User := CopyStr(UserId(), 1, MaxStrLen(SPBDBraiderEndpointLog.User));
        SPBDBraiderEndpointLog."Raw Input".CreateOutStream(LogOutStream);
        LogOutStream.WriteText(InputText);
        SPBDBraiderEndpointLog.Insert(true);
        exit(NextEntryNo);
    end;

    procedure DeleteLogEntries(DBHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
        OlderThenDate: Date;
    begin
        if not DBHeader."Logging Enabled" then
            exit;

        if Format(DBHeader."Clear Older Than") <> '' then begin
            OlderThenDate := CalcDate(DBHeader."Clear Older Than", Today());
            if OlderThenDate < Today() then begin //we can't delete future entries
                SPBDBraiderEndpointLog.SetRange("Config. Code", DBHeader.Code);
                SPBDBraiderEndpointLog.SetRange(SystemCreatedAt, 0DT, CreateDateTime(OlderThenDate, 0T));
                if SPBDBraiderEndpointLog.FindSet() then
                    SPBDBraiderEndpointLog.DeleteAll();
            end;
        end;

        if DBHeader."Clear Logs Count" > 0 then begin  //can not delete negitive entries
            Clear(SPBDBraiderEndpointLog);
            SPBDBraiderEndpointLog.SetRange("Config. Code", DBHeader.Code);
            if SPBDBraiderEndpointLog.Count > DBHeader."Clear Logs Count" then
                repeat
                    if SPBDBraiderEndpointLog.FindSet() then begin
                        SPBDBraiderEndpointLog.SetFilter("Entry No.", Format(SPBDBraiderEndpointLog."Entry No."));
                        SPBDBraiderEndpointLog.Delete(true);
                    end;
                    Clear(SPBDBraiderEndpointLog);
                    SPBDBraiderEndpointLog.SetRange("Config. Code", DBHeader.Code);
                until SPBDBraiderEndpointLog.Count = DBHeader."Clear Logs Count";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnBeforeGenerateData, '', false, false)]
    local procedure LogBeforeRead(DBHeader: Record "SPB DBraider Config. Header"; JsonInput: Text)
    begin
        if not DBHeader."Logging Enabled" then
            exit;

        LogEntryCode := DBHeader.Code;
        LogEntryNo := CreateNextLogEntry(DBHeader, JsonInput);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnAfterConvertJSONtoText, '', false, false)]
    local procedure LogAfterRead(ConfigCode: Code[20]; var JsonRows: JsonArray; var ResultText: Text)
    var
        DBHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        LogOutStream: OutStream;
    begin
        DBHeader.Get(ConfigCode);
        if not DBHeader."Logging Enabled" then
            exit;

        if not SPBDBraiderEndpointLog.Get(LogEntryCode, LogEntryNo) then
            exit;

        SPBDBraiderEndpointLog."Raw Output".CreateOutStream(LogOutStream);
        LogOutStream.WriteText(ResultText);
        SPBDBraiderEndpointLog.Success := not SPBDBraiderErrorSystem.HasErrors();
        SPBDBraiderEndpointLog.Modify(true);

        //Cleanup log entries
        DeleteLogEntries(DBHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnBeforeWriteData, '', false, false)]
    local procedure LogBeforeWrite(DBHeader: Record "SPB DBraider Config. Header"; JsonInput: Text)
    begin
        if not DBHeader."Logging Enabled" then
            exit;

        LogEntryCode := DBHeader.Code;
        LogEntryNo := CreateNextLogEntry(DBHeader, JsonInput);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnAfterWriteData, '', false, false)]
    local procedure LogAfterWrite(DBHeader: Record "SPB DBraider Config. Header"; JsonInput: Text; JsonResult: Text)
    var
        SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        LogOutStream: OutStream;
    begin
        if not DBHeader."Logging Enabled" then
            exit;

        if not SPBDBraiderEndpointLog.Get(LogEntryCode, LogEntryNo) then
            exit;

        SPBDBraiderEndpointLog."Raw Output".CreateOutStream(LogOutStream);
        LogOutStream.WriteText(JsonResult);
        SPBDBraiderEndpointLog.Success := not SPBDBraiderErrorSystem.HasErrors();
        SPBDBraiderEndpointLog.Modify(true);

        //Cleanup log entries
        DeleteLogEntries(DBHeader);
    end;
}
