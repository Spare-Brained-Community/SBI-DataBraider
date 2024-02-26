page 71033617 "SPB Create Endpoints"
{
    ApplicationArea = All;
    Caption = 'Create Endpoints';
    PageType = List;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    AdditionalSearchTerms = 'SPB,SBI,DBraider,Data Braider';

    layout
    {
        area(Content)
        {
            repeater(EndpointSelections)
            {
                field("Code"; rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Endpoint Call Code';
                    editable = false;
                }
                field(Enabled; rec.Enabled)
                {
                    Caption = 'Create Data Braider Endpoints';
                    ApplicationArea = All;
                    ToolTip = 'Endpoint Enabled or not';
                    Editable = true;
                }

                field(Overwrite; rec."Logging Enabled") //Used on this page as "Overwrite"
                {
                    Caption = 'Overwrite';
                    ApplicationArea = All;
                    ToolTip = 'Overwrite Endpoint(s) with the same name';
                    Editable = true;
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ClearEndpoindSelection_Promoted; ClearEndpoindSelection)
            { }
            actionref(SelectAllEndpoindSelection_Promoted; SelectAllEndpoindSelection)
            { }
            actionref(AddSelectedEndpoints_Promoted; AddSelectedEndpoints)
            { }
        }
        area(Processing)
        {
            action(ClearEndpoindSelection)
            {
                ApplicationArea = All;
                Caption = 'Clear Selection';
                ToolTip = 'Clears All Endpoint Selections';
                Image = CancelFALedgerEntries;
                trigger OnAction()
                begin
                    rec.ModifyAll(Enabled, false);
                end;
            }
            action(SelectAllEndpoindSelection)
            {
                ApplicationArea = All;
                Caption = 'Select All Endpoints';
                ToolTip = 'Select All Endpoint Selections';
                Image = CancelFALedgerEntries;
                trigger OnAction()
                begin
                    rec.ModifyAll(Enabled, true);
                end;
            }
            action(SelectAllOverwrite)
            {
                ApplicationArea = All;
                Caption = 'Select All for Overwrite';
                ToolTip = 'This will set the overwrite flag for all enabled endpoints';
                Image = CancelFALedgerEntries;
                trigger OnAction()

                begin
                    rec.SetRange(Enabled, true);
                    rec.ModifyAll(rec."Logging Enabled", true);
                    rec.SetRange(Enabled);
                end;
            }
            action(AddSelectedEndpoints)
            {
                ApplicationArea = All;
                Caption = 'Create Selected Endpoints';
                ToolTip = 'Overwrite All Default Endpoints with Original Default';

                Image = CreateBinContent;
                trigger OnAction()
                begin
                    Rec.SetRange(Enabled, true);

                    if Rec.FindSet() then
                        repeat
                            SPBCreateEndpointCodeunit.CreateEndpoint(Rec);
                        until Rec.Next() = 0;
                    Rec.SetRange(Enabled);
                end;
            }
        }
    }

    var
        SPBCreateEndpointCodeunit: Codeunit "SPB Create Endpoints";
        EndpointEnumSelection: Enum "SPB Endpoint Automation";
        EndpointEnumSelectionText: Text;
        BaseEndpointNameTxt: Label 'Base Endpoint: %1';

    trigger OnOpenPage()
    begin
        foreach EndpointEnumSelectionText in EndpointEnumSelection.Names do begin
            rec.Init();
            rec.Code := format(EndpointEnumSelectionText);
            rec.Description := StrSubstNo(BaseEndpointNameTxt, CopyStr(format(EndpointEnumSelectionText), 4));
            rec.Enabled := false;
            rec.Insert();
        end;
    end;

}
