codeunit 71033603 "SPB DBraider Licensing"
{

    var
        DemoProductKeyTxt: Label '23C4DBF2-4A92-4D2C-940B-E77B9D39A20F';

    procedure CheckIfActive(InactiveShowError: Boolean): Boolean
    var
        SPBDataBraiderInstall: Codeunit "SPB DataBraider Install";
        SPBLICCheckActive: Codeunit "SPBLIC Check Active";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // Usage later: exit(SPBLICCheckActive.CheckBasicSubmodule(AppInfo.Id, SPBDataBraiderInstall.GetAnnualUnlimitedModuleName(), InactiveShowError) or CheckIfUsageBased(InactiveShowError));
        exit(SPBLICCheckActive.CheckBasicSubmodule(AppInfo.Id, SPBDataBraiderInstall.GetAnnualUnlimitedModuleName(), InactiveShowError));
    end;

    internal procedure CheckIfUsageBased(InactiveShowError: Boolean): Boolean
    var
        SPBDataBraiderInstall: Codeunit "SPB DataBraider Install";
        SPBLICCheckActive: Codeunit "SPBLIC Check Active";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        //For usage later: exit(SPBLICCheckActive.CheckBasicSubmodule(AppInfo.Id, SPBDataBraiderInstall.GetUsageModuleName(), InactiveShowError));
        exit(false);
    end;

    procedure IsDemoInstall(): Boolean
    var
        LicenseSubscription: Record "SPBLIC Extension License";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(LicenseSubscription.Get(AppInfo.Id) and (LicenseSubscription."License Key" = DemoProductKeyTxt));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPBLIC Events", 'OnAfterActivationSuccess', '', true, true)]
    local procedure ActivatedSubscription(var SPBExtensionLicense: Record "SPBLIC Extension License"; var AppInfo: ModuleInfo)
    var
        DemoLimitationMsg: Label 'Data Braider has been activated with a Demo Product Key, so it will work, but only provide a small subset of records.';
        CurrentAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentAppInfo);

        if (SPBExtensionLicense."Entry Id" <> CurrentAppInfo.Id) then
            exit;

        if not SPBExtensionLicense.Activated then
            exit;

        if (SPBExtensionLicense."License Key" = DemoProductKeyTxt) and GuiAllowed then
            Message(DemoLimitationMsg);
    end;

    /*
    internal procedure SendUsageToLicenseServer(CurrentUsage: text)
    var
        LicenseSubscription: Record "SPBLIC Extension License";
        SPBUsageConnector: codeunit "SPBLIC UsageConnector";
        CurrentAppInfo: ModuleInfo;

    begin
        //INFO: Usage Licensing is not currently supported. This code is a placeholder for future development.
        //NavApp.GetCurrentModuleInfo(CurrentAppInfo);
        //LicenseSubscription.SetRange("Extension App Id", CurrentAppInfo.Id);
        //LicenseSubscription.SetRange("Subscription Type", LicenseSubscription."Subscription Type"::UsageBased);
        //if not LicenseSubscription.IsEmpty() then
        //    SPBUsageConnector.SendUsageToLicenseServer(LicenseSubscription, CurrentUsage);
    end;
    */
}
