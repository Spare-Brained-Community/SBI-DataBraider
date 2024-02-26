codeunit 71033623 "SPB DB Supp - General Checks"
{
    Access = Internal;
    TableNo = "SPB DBraider WizChecks";

    var
        SetupDisableCheckTok: Label 'SETUPDISABLECHECK';
        SetupDisableCheckDescriptionTok: Label 'Braider Setup - Check Global Disabled';
        GlobalSetupDisableErr: Label 'Braider is globally disabled.';
        GlobalSetupSuggestionMsg: Label 'Enable Braider in the Data Braider Setup page.';

    trigger OnRun()
    begin
        case Rec."Check Code" of
            SetupDisableCheckTok:
                CheckSetupDisable(Rec);
        end;
    end;

    local procedure RegisterChecks(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        // Setup Disable Check
        TempSPBDBraiderWizChecks.Init();
        TempSPBDBraiderWizChecks."Check Code" := SetupDisableCheckTok;
        TempSPBDBraiderWizChecks.Description := SetupDisableCheckDescriptionTok;
        TempSPBDBraiderWizChecks."Check Codeunit" := Codeunit::"SPB DB Supp - General Checks";
        TempSPBDBraiderWizChecks.Insert();

    end;

    local procedure CheckSetupDisable(var Rec: Record "SPB DBraider WizChecks" temporary)
    var
        SPBBraiderSetup: Record "SPB DBraider Setup";
    begin
        SPBBraiderSetup.GetRecordOnce();
        if not SPBBraiderSetup.EnabledGlobally then begin
            Rec.Status := Rec.Status::Failed;
            Rec.Results := GlobalSetupDisableErr;
            Rec."Suggested Action" := GlobalSetupSuggestionMsg;
        end else
            Rec.Status := Rec.Status::Passed;
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnSupportWizardChecksStarting, '', false, false)]
    local procedure OnSupportWizardStartingRegisterChecks(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        RegisterChecks(TempSPBDBraiderWizChecks);
    end;


}
