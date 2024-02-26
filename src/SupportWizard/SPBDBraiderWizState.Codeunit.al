codeunit 71033626 "SPB DBraider Wiz State"
{
    Access = Internal;
    SingleInstance = true;

    var
        TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary;
        TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary;

    procedure SetSelectedEndpoints(var NewSelectedEndpoints: Record "SPB DBraider Config. Header");
    begin
        if not TempSelectedEndpoints.IsTemporary then
            exit;
        TempSelectedEndpoints.DeleteAll();
        if NewSelectedEndpoints.FindSet() then
            repeat
                TempSelectedEndpoints := NewSelectedEndpoints;
                TempSelectedEndpoints.Insert();
            until NewSelectedEndpoints.Next() < 1;
        if TempSelectedEndpoints.FindFirst() then;
    end;

    procedure GetSelectedEndpoints(var NewSelectedEndpoints: Record "SPB DBraider Config. Header");
    begin
        NewSelectedEndpoints.DeleteAll();
        if TempSelectedEndpoints.FindSet() then
            repeat
                NewSelectedEndpoints := TempSelectedEndpoints;
                NewSelectedEndpoints.Insert();
            until TempSelectedEndpoints.Next() < 1;
    end;

    procedure SetSPBDBraiderWizChecks(var SPBDBraiderWizChecks: Record "SPB DBraider WizChecks");
    begin
        if not TempSPBDBraiderWizChecks.IsTemporary then
            exit;
        TempSPBDBraiderWizChecks.DeleteAll();
        if SPBDBraiderWizChecks.FindSet() then
            repeat
                TempSPBDBraiderWizChecks := SPBDBraiderWizChecks;
                TempSPBDBraiderWizChecks.Insert();
            until SPBDBraiderWizChecks.Next() < 1;
        if TempSPBDBraiderWizChecks.FindFirst() then;
    end;

    procedure GetSPBDBraiderWizChecks(var SPBDBraiderWizChecks: Record "SPB DBraider WizChecks");
    begin
        SPBDBraiderWizChecks.DeleteAll();
        if TempSPBDBraiderWizChecks.FindSet() then
            repeat
                SPBDBraiderWizChecks := TempSPBDBraiderWizChecks;
                SPBDBraiderWizChecks.Insert();
            until TempSPBDBraiderWizChecks.Next() < 1;
    end;

    procedure IsWizardScanningComplete(): Boolean;
    begin
        TempSPBDBraiderWizChecks.SetRange(Status, TempSPBDBraiderWizChecks.Status::" ");
        exit(TempSPBDBraiderWizChecks.IsEmpty);
    end;

}
