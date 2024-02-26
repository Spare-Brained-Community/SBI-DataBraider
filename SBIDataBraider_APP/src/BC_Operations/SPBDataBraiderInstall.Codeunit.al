codeunit 71033602 "SPB DataBraider Install"
{
    Subtype = Install;

    var
        AnnualUnlimitedModuleNameTok: Label 'AnnualUnlimited';
        UsageModuleNameTok: Label 'UsageBased';

    trigger OnInstallAppPerCompany()
    begin
        InitSetupRecord();
    end;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterSubscription();
        CreateIsoVars();
    end;

    local procedure InitSetupRecord()
    var
        SetupRecord: Record "SPB DBraider Setup";
    begin
        if not SetupRecord.Get() then begin
            SetupRecord.Init();
            SetupRecord.Insert();
        end;
    end;

    local procedure RegisterSubscription()
    var
        SPBLicenseManagement: Codeunit "SPBLIC Extension Registration";
        SPBPlatforms: Enum "SPBLIC License Platform";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        // Register the Annual Unlimited Submodule
        SPBLicenseManagement.RegisterExtension(AppInfo,
          GetAnnualUnlimitedId(),                                                   // Submodule ID
          AnnualUnlimitedModuleNameTok,                                             // Submodule Name
          '184992',                                                         // Lemon Squeezy Product Code
          'https://store.sparebrained.com/checkout/buy/5d568110-6e8b-4d95-8f2b-9f1cd84fb8b2',                 // Lemon Squeezy Product URL
          'https://sparebrained.com/support',                               // Support Page link
          'invoices@sparebrained.com',                                      // Billing Support Email
                                                                            // Version update page: 
          'https://raw.githubusercontent.com/SpareBrainedIdeas/AppVersions/main/DataBraider/version.txt',
          'https://twitter.com/SpareBrained',                               // News Page
          30,                                                               // Grace days before activation is required in Prod and OnPrem
          60,                                                               // Grace days before activation is required in Sandboxes
          Version.Create('2.0.0.0'),                                        // Minimum version of the Licensing Extension required
          SPBPlatforms::LemonSqueezy,                                       // Which licensing platform to use         
          true);                                                             // Force an update of the existing settings.

        // Register the UsageBased Submodule
        // TODO: this will be added later
        /*
        SPBLicenseManagement.RegisterExtension(AppInfo,
          GetUsageID(),                                                     // Submodule ID
          UsageModuleNameTok,                                                  // Submodule Name
          'sgyJTR',                                                         // Lemon Squeezy Product Code
          'https://sparebrained.Lemon Squeezy.com/l/DataBraider',                 // Lemon Squeezy Product URL
          'https://sparebrained.com/support',                               // Support Page link
          'invoices@sparebrained.com',                                      // Billing Support Email
                                                                            // Version update page: 
          'https://raw.githubusercontent.com/SpareBrainedIdeas/AppVersions/main/DataBraider/version.txt',
          'https://twitter.com/SpareBrained',                               // News Page
          0,                                                                // Grace days before activation is required in Prod and OnPrem
          0,                                                               // Grace days before activation is required in Sandboxes
          Version.Create('2.0.0.0'),                                       // Minimum version of the Licensing Extension required
          SPBPlatforms::LemonSqueezy,                                      // Which licensing platform to use         
          true);                                                            // Force an update of the existing settings.
        */
    end;

    internal procedure GetAnnualUnlimitedId() SubmoduleId: Guid
    begin
        // This is the same as the Braider Extension App ID, as we implemented submodules after
        Evaluate(SubmoduleId, '4b65b5d6-3dc0-453e-9ad5-17a64e96a31f');
    end;

    internal procedure GetUsageID() SubmoduleId: Guid
    begin
        Evaluate(SubmoduleId, '2ea5d170-276c-47e7-bd66-f1ab1e812b7e');
    end;

    internal procedure GetAnnualUnlimitedModuleName() ModuleName: Text[100]
    begin
        exit(AnnualUnlimitedModuleNameTok);
    end;

    internal procedure GetUsageModuleName() ModuleName: Text[100]
    begin
        exit(UsageModuleNameTok);
    end;

    local procedure CreateIsoVars()
    begin
        IsolatedStorage.Set('Usage', Format(0), DataScope::Module);
        IsolatedStorage.Set('ReadEndpoint', Format(0), DataScope::Module);
        IsolatedStorage.Set('WriteEndpoint', Format(0), DataScope::Module);
    end;
}
