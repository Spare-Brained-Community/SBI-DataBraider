page 71033615 "SPB DBraider Delta Versions"
{
    ApplicationArea = All;
    Caption = 'Data Braider Delta Versions';
    Editable = false;
    PageType = List;
    SourceTable = "SPB DBraider Delta Row";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Config. Code"; Rec."Config. Code")
                {
                    ToolTip = 'Specifies the value of the Config. Code field.';
                    Visible = false;
                }
                field("Version No."; Rec."Version No.")
                {
                    ToolTip = 'Specifies the value of the Version No. field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InspectDeltaAction)
            {
                Caption = 'Inspect Delta Version';
                Image = AddWatch;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Shows the data of the selected Delta Version';

                trigger OnAction()
                begin
                    ShowDeltaVersion(Rec);
                end;
            }
        }
    }

    internal procedure ShowDeltaVersion(var TempSPBDBraiderDeltaRow: Record "SPB DBraider Delta Row" temporary)
    var
        SPBDBraiderDeltaCol: Record "SPB DBraider Delta Col";
        SPBDBraiderDeltaRow: Record "SPB DBraider Delta Row";
        TempResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempResultRow: Record "SPB DBraider Resultset Row" temporary;
        ResultPreview: Page "SPB DBraider Results";
    begin
        // Convert the Delta Version back to Temporary Results tables
        SPBDBraiderDeltaRow.SetRange("Config. Code", TempSPBDBraiderDeltaRow."Config. Code");
        SPBDBraiderDeltaRow.SetRange("Version No.", TempSPBDBraiderDeltaRow."Version No.");
        if SPBDBraiderDeltaRow.FindSet() then
            repeat
                TempResultRow.TransferFields(SPBDBraiderDeltaRow, true);
                TempResultRow.Insert(true);
            until SPBDBraiderDeltaRow.Next() < 1;
        // and the columns for the row too
        SPBDBraiderDeltaCol.SetRange("Config. Code", TempSPBDBraiderDeltaRow."Config. Code");
        SPBDBraiderDeltaCol.SetRange("Version No.", TempSPBDBraiderDeltaRow."Version No.");
        if SPBDBraiderDeltaCol.FindSet() then
            repeat
                TempResultCol.TransferFields(SPBDBraiderDeltaCol, true);
                TempResultCol.Insert(true);
            until SPBDBraiderDeltaCol.Next() < 1;
        // and display that
        Clear(ResultPreview);
        ResultPreview.SetTempData(TempResultRow, TempResultCol);
        ResultPreview.Run();
    end;
}
