codeunit 71033610 "SPB DBraider Usage Tracker"
{
    Access = Internal;
    Permissions = tabledata "SPB DBraider Config. Header" = rm,
        tabledata "SPB DBraider Usage" = rim;

    // Log Usage of an Endpoint to Isolated Storage, as we do not want to use a table for this
    internal procedure LogUsageToIso()
    var
    //DBraiderUsage: Record "SPB DBraider Usage";
    //DBLicense: Codeunit "SPB DBraider Licensing";
    begin
        //TODO: For testing only, need the correct filter from Licensing
        //INFO: Usage Support not yet implemented
        // DBraiderUsage.SetRange("Month Start Date", CalcDate('<-1M>', Today()), Today());
        // if DBraiderUsage.FindFirst() then begin
        //     DBraiderUsage.CalcSums("Call Tally", "Rows Read", "Rows Written");
        //     UpdateIsoStorage('Usage', DBraiderUsage."Call Tally");
        //     UpdateIsoStorage('WriteEndpoint', DBraiderUsage."Rows Written");
        //     UpdateIsoStorage('ReadEndpoint', DBraiderUsage."Rows Read");
        //     DBLicense.SendUsageToLicenseServer(Format(DBraiderUsage."Call Tally", 0, 9));
        // end;
    end;

    // local procedure UpdateIsoStorage(IsoKey: Text; newIsoValue: BigInteger)
    // begin
    //     IsolatedStorage.Set(IsoKey, Format(newIsoValue), DataScope::Module);
    // end;

    procedure ReturnIsoUsage(var UsageDict: Dictionary of [Text, Text])
    var
        IsoValue: Text;
    begin
        IsolatedStorage.Get('Usage', DataScope::Module, IsoValue);
        UsageDict.Add('Usage', IsoValue);

        IsolatedStorage.Get('WriteEndpoint', DataScope::Module, IsoValue);
        UsageDict.Add('Rows Written', IsoValue);

        IsolatedStorage.Get('ReadEndpoint', DataScope::Module, IsoValue);
        UsageDict.Add('Rows Read', IsoValue);
    end;

    // internal procedure ResetIsoUsage()
    // begin
    //     //INFO: This is for debugging purposes only
    //     IsolatedStorage.Set('Usage', '0', DataScope::Module);
    //     IsolatedStorage.Set('Rows Written', '0', DataScope::Module);
    //     IsolatedStorage.Set('Rows Read', '0', DataScope::Module);
    // end;

}
