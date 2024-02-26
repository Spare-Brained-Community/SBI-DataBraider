codeunit 71033609 "SPB DBraider Telemetry"
{
    Access = Internal;
    // Utility functions to make calling into Telemetry data easier
    // Event to send Usage data

    Permissions = tabledata "SPB DBraider Usage" = rim;

    trigger OnRun()
    begin
        SendActivityTelemetry(true);
    end;

    #region Discoverability
    var
        SPBDBraiderReadOnlyLbl: Label 'Read Only Endpoints', Locked = true;
        SPBDBraiderWriteSingleLbl: Label 'Write Single Endpoints', Locked = true;

    procedure SendDiscoverFeature(DBHeader: Record "SPB DBraider Config. Header")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        case DBHeader."Endpoint Type" of
            DBHeader."Endpoint Type"::"Read Only":
                FeatureTelemetry.LogUptake('SPB1001', SPBDBraiderReadOnlyLbl, Enum::"Feature Uptake Status"::Discovered);
            DBHeader."Endpoint Type"::"Per Record":
                FeatureTelemetry.LogUptake('SPB2001', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::Discovered);
            DBHeader."Endpoint Type"::Batch:
                FeatureTelemetry.LogUptake('SPB2101', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::Discovered);
        end;
    end;


    procedure SendSetUpFeature(DBHeader: Record "SPB DBraider Config. Header")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        case DBHeader."Endpoint Type" of
            DBHeader."Endpoint Type"::"Read Only":
                FeatureTelemetry.LogUptake('SPB1002', SPBDBraiderReadOnlyLbl, Enum::"Feature Uptake Status"::"Set up");
            DBHeader."Endpoint Type"::"Per Record":
                FeatureTelemetry.LogUptake('SPB2002', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::"Set up");
            DBHeader."Endpoint Type"::Batch:
                FeatureTelemetry.LogUptake('SPB2102', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::"Set up");
        end;
    end;

    procedure SendUsedFeature(DBHeader: Record "SPB DBraider Config. Header")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        case DBHeader."Endpoint Type" of
            DBHeader."Endpoint Type"::"Read Only":
                FeatureTelemetry.LogUptake('SPB1003', SPBDBraiderReadOnlyLbl, Enum::"Feature Uptake Status"::Used);
            DBHeader."Endpoint Type"::"Per Record":
                FeatureTelemetry.LogUptake('SPB2003', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::Used);
            DBHeader."Endpoint Type"::Batch:
                FeatureTelemetry.LogUptake('SPB2103', SPBDBraiderWriteSingleLbl, Enum::"Feature Uptake Status"::Used);
        end;
    end;
    #endregion Discoverability


    #region UsageStats
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", 'OnSendDailyTelemetry', '', true, true)]
    local procedure SendDailyTelemetry()
    begin
        SendActivityTelemetry(true);
    end;

    internal procedure SendActivityTelemetry(DailySend: Boolean)
    var
        CompanyRec: Record Company;
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        Users: Record User;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        LastTelemetrySentDate: DateTime;
        ResultValue: Decimal;
        Results: Dictionary of [Text, Decimal];
        AvgReadsCMLbl: Label 'Avg. Reads (CM)', Locked = true;
        AvgReadsTotalLbl: Label 'Avg. Reads (Total)', Locked = true;
        AvgWritesCMLbl: Label 'Avg. Writes (CM)', Locked = true;
        AvgWritesTotalLbl: Label 'Avg. Writes (Total)', Locked = true;
        DBActiveUsersLbl: Label 'Active Users', Locked = true;
        DBCompaniesLbl: Label 'Companies', Locked = true;
        ReadEndpointsLbl: Label 'Read-Only Endpoints', Locked = true;
        TotalReadsCMLbl: Label 'Total. Reads (CM)', Locked = true;
        TotalReadsTotalLbl: Label 'Total. Reads (Total)', Locked = true;
        TotalWritesCMLbl: Label 'Total. Writes (CM)', Locked = true;
        TotalWritesTotalLbl: Label 'Total. Writes (Total)', Locked = true;
        WriteSingleEndpointsLbl: Label 'Write Single Endpoints', Locked = true;
        AlreadySent: List of [Code[20]];
        LastTelemetrySentDateText: Text;
    begin
        // If ISO storage date <1440minutes ago, exit
        if not DailySend then begin
            if IsolatedStorage.Get('DataBraider-Telementry', DataScope::Module, LastTelemetrySentDateText) then
                if Evaluate(LastTelemetrySentDate, LastTelemetrySentDateText) then;
            if (CurrentDateTime - LastTelemetrySentDate) < (24 * 60 * 60 * 1000) then
                exit;
        end else
            LastTelemetrySentDate := CurrentDateTime - (24 * 60 * 60 * 1000);

        // Braider Usage Info

        // # of Read Endpoints Configured
        SPBDBraiderConfigHeader.SetRange("Endpoint Type", Enum::"SPB DBraider Endpoint Type"::"Read Only");
        EmitTraceTag(ReadEndpointsLbl, SPBDBraiderConfigHeader.Count, 'SPB0101');

        // # of Write Single Endpoints Configured
        SPBDBraiderConfigHeader.SetRange("Endpoint Type", Enum::"SPB DBraider Endpoint Type"::"Per Record");
        EmitTraceTag(WriteSingleEndpointsLbl, SPBDBraiderConfigHeader.Count, 'SPB0102');

        SPBDBraiderUtilities.GetTelemetryFigures(Results);
        // # Avg Reads per Endpoint (CM)
        Results.Get('AvgReadsCM', ResultValue);
        EmitTraceTag(AvgReadsCMLbl, ResultValue, 'SPB0110');

        // # Avg Writes per Endpoint (CM)
        Results.Get('AvgWritesCM', ResultValue);
        EmitTraceTag(AvgWritesCMLbl, ResultValue, 'SPB0111');

        // # Avg Reads per Endpoint (Alltime)
        Results.Get('AvgReadsAlltime', ResultValue);
        EmitTraceTag(AvgReadsTotalLbl, ResultValue, 'SPB0112');

        // # Avg Writes per Endpoint (Alltime)
        Results.Get('AvgWritesAlltime', ResultValue);
        EmitTraceTag(AvgWritesTotalLbl, ResultValue, 'SPB0113');

        // # Total Reads (CM)
        Results.Get('TotalReadsCM', ResultValue);
        EmitTraceTag(TotalReadsCMLbl, ResultValue, 'SPB0114');

        // # Total Writes (CM)
        Results.Get('TotalWritesCM', ResultValue);
        EmitTraceTag(TotalWritesCMLbl, ResultValue, 'SPB0115');

        // # Total Reads (Alltime)
        Results.Get('TotalReadsAlltime', ResultValue);
        EmitTraceTag(TotalReadsTotalLbl, ResultValue, 'SPB0116');

        // # Total Writes (Alltime)
        Results.Get('TotalWritesAlltime', ResultValue);
        EmitTraceTag(TotalWritesTotalLbl, ResultValue, 'SPB0117');

        // filter on created/modified within past 24 hours
        SPBDBraiderConfigHeader.Reset();
        SPBDBraiderConfigHeader.SetFilter(SystemCreatedAt, '%1..', LastTelemetrySentDate);
        if SPBDBraiderConfigHeader.FindSet() then
            repeat
                EmitTraceTag(SPBDBraiderConfigHeader.Code, SPBDBraiderUtilities.GetEndpointTelemetryDataJson(SPBDBraiderConfigHeader), 'SPB0119');
                AlreadySent.Add(SPBDBraiderConfigHeader.Code);
            until SPBDBraiderConfigHeader.Next() < 1;
        SPBDBraiderConfigHeader.Reset();
        SPBDBraiderConfigHeader.SetFilter(SystemModifiedAt, '%1..', LastTelemetrySentDate);
        if SPBDBraiderConfigHeader.FindSet() then
            repeat
                if not AlreadySent.Contains(SPBDBraiderConfigHeader.Code) then begin
                    EmitTraceTag(SPBDBraiderConfigHeader.Code, SPBDBraiderUtilities.GetEndpointTelemetryDataJson(SPBDBraiderConfigHeader), 'SPB0119');
                    AlreadySent.Add(SPBDBraiderConfigHeader.Code);
                end;
            until SPBDBraiderConfigHeader.Next() < 1;

        // User/Company/DB info
        // # of Active Users in DB
        Users.SetRange(State, Users.State::Enabled);
        EmitTraceTag(DBActiveUsersLbl, Users.Count, 'SPB0120');

        // # of Companies in DB
        EmitTraceTag(DBCompaniesLbl, CompanyRec.Count, 'SPB0121');

        IsolatedStorage.Set('DataBraider-Telemetry', Format(LastTelemetrySentDate, 0, 9), DataScope::Module);
    end;

    local procedure EmitTraceTag(FeatureName: Text; FeatureCount: Variant; Tag: Text)
    var
        TelemetryDimension: Dictionary of [Text, Text];
        CustomCompanyNameLbl: Label 'CompanyName', Locked = true;
        CustomFeatureCountLbl: Label 'CustomFeatureCount', Locked = true;
        TraceTagTelemetryMsg: Label '%1: %2', Comment = '%1 = Feature Name; %2 = Feature Count', Locked = true;
        TraceTagMessage: Text;
    begin
        TraceTagMessage := StrSubstNo(TraceTagTelemetryMsg, FeatureName, FeatureCount);
        TelemetryDimension.Add(CustomFeatureCountLbl, Format(FeatureCount));
        //TODO: When MS will add the company name to log message this can be obsoleted
        TelemetryDimension.Add(CustomCompanyNameLbl, CompanyName);
        Session.LogMessage(Tag, TraceTagMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimension);
    end;

    #endregion UsageStats

    #region PerEndpointTelemetry

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnBeforeGenerateData, '', true, true)]
    local procedure OnBeforeGenerateData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text)
    var
        TraceTagMsg: Label 'SPB9001', Locked = true;
    begin
        if not DBHeader."Emit Telemetry Read Before" then
            exit;
        EmitEndpointTelemetry(DBHeader, 'OnBeforeGenerateData', TraceTagMsg, JsonInput);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnAfterFormatData, '', true, true)]
    local procedure OnAfterFormatData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonResult: Text)
    var
        TraceTagMsg: Label 'SPB9002', Locked = true;
    begin
        if not DBHeader."Emit Telemetry Read After" then
            exit;
        EmitEndpointTelemetry(DBHeader, 'OnAfterFormatData', TraceTagMsg, JsonResult);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnBeforeWriteData, '', true, true)]
    local procedure OnBeforeWriteData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text)
    var
        TraceTagMsg: Label 'SPB9010', Locked = true;
    begin
        if not DBHeader."Emit Telemetry Write Before" then
            exit;
        EmitEndpointTelemetry(DBHeader, 'OnBeforeWriteData', TraceTagMsg, JsonInput);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnAfterWriteData, '', true, true)]
    local procedure OnAfterWriteData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text; var JsonResult: Text; Success: Boolean)
    var
        ExtraDimensions: Dictionary of [Text, Text];
        TraceTagMsg: Label 'SPB9011', Locked = true;
    begin
        if not DBHeader."Emit Telemetry Write After" then
            exit;

        // Write functionality has some extra dimensions to include
        ExtraDimensions.Add('Success', Format(Success, 0, 9));
        if DBHeader."Emit Telemetry Include Body" then
            ExtraDimensions.Add('JsonInput', JsonInput);

        EmitEndpointTelemetry(DBHeader, 'OnAfterWriteData', TraceTagMsg, JsonResult, ExtraDimensions);
    end;

    local procedure EmitEndpointTelemetry(DBHeader: Record "SPB DBraider Config. Header"; EventName: Text; Tag: Text; RawContent: Text)
    var
        EmptyExtraDimensions: Dictionary of [Text, Text];
    begin
        EmitEndpointTelemetry(DBHeader, EventName, Tag, RawContent, EmptyExtraDimensions);
    end;

    local procedure EmitEndpointTelemetry(DBHeader: Record "SPB DBraider Config. Header"; EventName: Text; Tag: Text; RawContent: Text; ExtraDimensions: Dictionary of [Text, Text])
    var
        TelemetryDimension: Dictionary of [Text, Text];
        CustomCompanyNameLbl: Label 'CompanyName', Locked = true;
        EndpointCodeLbl: Label 'EndpointCode', Locked = true;
        EndpointTypeLbl: Label 'EndpointType', Locked = true;
        TraceTagTelemetryMsg: Label '%1: %2', Comment = '%1 = Endpoint Code; %2 = Event Name', Locked = true;
        TraceTagMessage: Text;
        i: Integer;
        thisKey: Text;
        thisValue: Text;
    begin
        TraceTagMessage := StrSubstNo(TraceTagTelemetryMsg, DBHeader.Code, EventName);
        TelemetryDimension.Add(CustomCompanyNameLbl, CompanyName);
        TelemetryDimension.Add(EndpointCodeLbl, DBHeader.Code);
        TelemetryDimension.Add(EndpointTypeLbl, Format(DBHeader."Endpoint Type"));
        if DBHeader."Emit Telemetry Include Body" then
            TelemetryDimension.Add('Body', RawContent);
        if ExtraDimensions.Count > 0 then
            for i := 1 to ExtraDimensions.Count do begin
                thisKey := ExtraDimensions.Keys.Get(i);
                thisValue := ExtraDimensions.Get(thisKey);
                TelemetryDimension.Add(thisKey, thisValue);
            end;
        // Note that the scope on this is "All" so that environmental telemetry gets these also
        Session.LogMessage(Tag, TraceTagMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimension);
    end;

    #endregion PerEndpointTelemetry
}
