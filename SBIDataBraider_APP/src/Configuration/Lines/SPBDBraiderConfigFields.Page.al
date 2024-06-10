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
                field("Fixed Field Name"; Rec."Fixed Field Name")
                {
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field("Fixed Field Caption"; Rec."Fixed Field Caption")
                {
                    ToolTip = 'Specifies the value of the Field Caption field.';
                }
                field("Manual Field Caption"; Rec."Manual Field Caption")
                {
                    ToolTip = 'Specifies caption to use when rendering the field data to outputs, such as JSON key value. Leave or set to blank to use the engine default.';
                    Visible = false;
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
                    AssistEdit = true;
                    ToolTip = 'This filter will be applied to the table based on this field, excluding any *records* that are outside the filter.';

                    trigger OnAssistEdit()
                    var
                        SPBDBraiderVariable: Record "SPB DBraider Variable";
                        SPBDBraiderVariables: Page "SPB DBraider Variables";
                    begin
                        // Take the existing text, but then let the user append a Tag from the Variables list
                        SPBDBraiderVariables.LookupMode(true);
                        if SPBDBraiderVariables.RunModal() = Action::LookupOK then begin
                            SPBDBraiderVariables.GetRecord(SPBDBraiderVariable);
                            if SPBDBraiderVariable.Tag <> '' then
                                Rec.Filter := CopyStr(Rec.Filter + ' ' + StrSubstNo('{{%1}}', SPBDBraiderVariable.Tag), 1, MaxStrLen(Rec.Filter));
                        end;
                    end;
                }
                field("Write Enabled"; Rec."Write Enabled")
                {
                    Enabled = rec.Included;
                    ToolTip = 'Specifies the value of the Write Enabled field.';
                    Visible = WriteEndpoint;
                }
                field("Default Value"; Rec."Default Value")
                {
                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Default Value field.';
                    Visible = WriteEndpoint;

                    trigger OnAssistEdit()
                    var
                        SPBDBraiderVariable: Record "SPB DBraider Variable";
                        SPBDBraiderVariables: Page "SPB DBraider Variables";
                    begin
                        // Take the existing text, but then let the user append a Tag from the Variables list
                        SPBDBraiderVariables.LookupMode(true);
                        if SPBDBraiderVariables.RunModal() = Action::LookupOK then begin
                            SPBDBraiderVariables.GetRecord(SPBDBraiderVariable);
                            if SPBDBraiderVariable.Tag <> '' then
                                Rec."Default Value" := CopyStr(Rec."Default Value" + ' ' + StrSubstNo('{{%1}}', SPBDBraiderVariable.Tag), 1, MaxStrLen(Rec.Filter));
                        end;
                    end;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ToolTip = 'Specifies the value of the Mandatory field.';
                    Visible = WriteEndpoint;
                }

                field(Caption; Rec.Caption)
                {
                    Caption = 'Caption (Obsolete)';
                    Editable = false;
                    Enabled = false;
                    ObsoleteReason = 'This field is replaced by the "Fixed Field Name" field.';
                    ObsoleteState = Pending;
                    ToolTip = 'The field caption.';
                    Visible = false;
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
