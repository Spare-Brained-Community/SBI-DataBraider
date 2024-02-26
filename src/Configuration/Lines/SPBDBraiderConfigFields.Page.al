page 71033604 "SPB DBraider Config. Fields"
{
    ApplicationArea = All;
    Caption = 'Endpoint Fields';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "SPB DBraider ConfLine Field";
    SourceTableView = sorting("Config. Code", "Config. Line No.", "Processing Order", "Field No.");
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Field No."; Rec."Field No.")
                {
                    Editable = false;
                    ToolTip = 'The Field No. of the field from the underlying table.';
                }
                field(Caption; Rec.Caption)
                {
                    Editable = false;
                    ToolTip = 'The field caption.';
                }
                field("Primary Key"; Rec."Primary Key")
                {
                    ToolTip = 'Specifies the field is part of the table''s primary key.';
                    Visible = false;
                }
                field(Included; Rec.Included)
                {
                    ToolTip = 'Should this field be included in the result set?';
                }
                field("Filter"; Rec.Filter)
                {
                    ToolTip = 'This filter will be applied to the table based on this field, excluding any *records* that are outside the filter.';
                }
                field("Write Enabled"; Rec."Write Enabled")
                {
                    Enabled = rec.Included;
                    ToolTip = 'Specifies the value of the Write Enabled field.';
                    Visible = WriteEndpoint;
                }
                field("Default Value"; Rec."Default Value")
                {
                    ToolTip = 'Specifies the value of the Default Value field.';
                    Visible = WriteEndpoint;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ToolTip = 'Specifies the value of the Mandatory field.';
                    Visible = WriteEndpoint;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(MarkSelectedToIncludeAction)
            {
                Caption = 'Include Selected';
                Image = TransferToLines;
                ToolTip = 'All fields selected will be included in the result set.';

                trigger OnAction()
                begin
                    MarkSelectedToInclude();
                end;
            }
            action(UnmarkSelectedAction)
            {
                Caption = 'Remove Selected';
                Image = CancelAllLines;
                ToolTip = 'All fields selected will be removed from the result set.';

                trigger OnAction()
                begin
                    UnmarkSelected();
                end;
            }
        }
        area(Navigation)
        {
            action(AdvSettingsAction)
            {
                ApplicationArea = All;
                Caption = 'Advanced Settings';
                Image = SetupList;
                RunObject = page "SPB DBraider Conf Field Adv";
                RunPageMode = Edit;
                RunPageOnRec = true;
                ToolTip = 'Open the advanced settings page for the selected field';
            }
        }

        area(Promoted)
        {
            group(MarkSelections)
            {
                Caption = 'Mark';
                ShowAs = SplitButton;
                actionref(MarkSelectedToIncludeAction_Promoted; MarkSelectedToIncludeAction)
                {
                }
                actionref(UnmarkSelectedAction_Promoted; UnmarkSelectedAction)
                {
                }
            }
            actionref(AdvSettingsAction_Promoted; AdvSettingsAction)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    begin
        if Rec.GetFilter("Config. Code") <> '' then
            if SPBDBraiderConfigHeader.Get(Rec.GetRangeMin("Config. Code")) then
                WriteEndpoint := SPBDBraiderConfigHeader.WriteableConfig();
    end;

    local procedure MarkSelectedToInclude()
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
    begin
        CurrPage.SetSelectionFilter(SPBDBraiderConfLineField);
        SPBDBraiderConfLineField.ModifyAll(Included, true, true);
    end;

    local procedure UnmarkSelected()
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
    begin
        CurrPage.SetSelectionFilter(SPBDBraiderConfLineField);
        SPBDBraiderConfLineField.ModifyAll(Included, false, true);
    end;

    var
        WriteEndpoint: Boolean;
}
