page 71033620 "SPB Support Wizard List"
{
    ApplicationArea = All;
    Caption = 'Support Wizard List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "SPB DBraider WizChecks";
    SourceTableView = sorting("Endpoint Code", "Check Code");
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(StatusIcon; Rec.GetIconForStatus(Rec.Status))
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field(Results; Rec.Results)
                {
                    ToolTip = 'Specifies the value of the Results field.';
                }
                field("Suggested Action"; Rec."Suggested Action")
                {
                    ToolTip = 'Specifies the value of the Suggested Action field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(StartScanAction)
            {
                ApplicationArea = All;
                Caption = 'Start Scan';
                Image = DefaultFault;
                ToolTip = 'Starts the scan of the selected wizard checks.';

                trigger OnAction()
                begin
                    StartScans();
                end;
            }
            action(DisregardCheck)
            {
                ApplicationArea = All;
                Caption = 'Disregard Check';
                Image = ChangeStatus;
                ToolTip = 'Disregards the selected wizard checks. This will allow you to ignore Detected problems and submit at ticket anyway.';

                trigger OnAction()
                var
                    TempSPBDraiderWizChecks: Record "SPB DBraider WizChecks" temporary;
                    SPBDBraiderWizState: Codeunit "SPB DBraider Wiz State";
                    SelectionPosition: Text;
                begin
                    SelectionPosition := Rec.GetPosition();
                    GetSelectedChecks(TempSPBDraiderWizChecks);
                    if TempSPBDraiderWizChecks.FindSet() then
                        repeat
                            TempSPBDraiderWizChecks.Status := Rec.Status::Skipped;
                            TempSPBDraiderWizChecks.Results := Format(Rec.Status);
                            TempSPBDraiderWizChecks."Suggested Action" := '';
                            TempSPBDraiderWizChecks.Modify(true);
                            if Rec.Get(TempSPBDraiderWizChecks."Check Code", TempSPBDraiderWizChecks."Endpoint Code") then begin
                                Rec.Status := TempSPBDraiderWizChecks.Status;
                                Rec.Results := TempSPBDraiderWizChecks.Results;
                                Rec."Suggested Action" := TempSPBDraiderWizChecks."Suggested Action";
                                Rec.Modify(true);
                            end;
                        until TempSPBDraiderWizChecks.Next() < 1;
                    SPBDBraiderWizState.SetSPBDBraiderWizChecks(TempSPBDraiderWizChecks);
                    Rec.SetPosition(SelectionPosition);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure SetData(var NewRec: Record "SPB DBraider WizChecks")
    begin
        if not Rec.IsTemporary then
            exit;
        Rec.DeleteAll();
        if NewRec.FindSet() then
            repeat
                Rec := NewRec;
                Rec.Insert();
            until NewRec.Next() < 1;
        if Rec.FindFirst() then;
    end;

    procedure GetSelectedChecks(var SelectedChecks: Record "SPB DBraider WizChecks")
    var
        SelectionPosition: Text;
    begin
        SelectedChecks.DeleteAll();
        SelectionPosition := Rec.GetPosition();
        if Rec.FindSet() then
            repeat
                SelectedChecks := Rec;
                SelectedChecks.Insert();
            until Rec.Next() < 1;
        CurrPage.SetSelectionFilter(SelectedChecks);
        if SelectedChecks.Count = 1 then begin
            SelectedChecks.Reset();
            SelectedChecks.SetPosition(SelectionPosition);
            SelectedChecks.SetRecFilter();
        end;
    end;

    local procedure StartScans()
    var
        WizardRunErr: Label 'Running the check failed with error: %1', Comment = '%1 is the error message from BC when running the check codeunit.';
    begin
        if Rec.FindSet() then
            repeat
                if not Codeunit.Run(Rec."Check Codeunit", Rec) then begin
                    Rec.Status := Rec.Status::Failed;
                    Rec.Results := CopyStr(StrSubstNo(WizardRunErr, GetLastErrorText()), 1, MaxStrLen(Rec.Results));
                    Rec.Modify(true);
                end;
            until Rec.Next() < 1;
        If Rec.FindFirst() then;
        CurrPage.Update(false);
    end;
}
