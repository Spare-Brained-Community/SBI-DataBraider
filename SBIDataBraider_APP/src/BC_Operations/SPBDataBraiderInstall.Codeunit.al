codeunit 71033602 "SPB DataBraider Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitSetupRecord();
    end;

    trigger OnInstallAppPerDatabase()
    begin
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

    local procedure CreateIsoVars()
    begin
        IsolatedStorage.Set('Usage', Format(0), DataScope::Module);
        IsolatedStorage.Set('ReadEndpoint', Format(0), DataScope::Module);
        IsolatedStorage.Set('WriteEndpoint', Format(0), DataScope::Module);
    end;
}
