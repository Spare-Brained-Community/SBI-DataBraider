page 71033600 "SPB DBraider Setup"
{
    AdditionalSearchTerms = 'SBI,SPB,Databraider,DBraider';
    ApplicationArea = All;
    Caption = 'Data Braider Setup';
    PageType = Card;
    SourceTable = "SPB DBraider Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Options';
                field(EnabledGlobally; Rec.EnabledGlobally)
                {
                    ToolTip = 'Enables the Data Braider globally.';
                }

                field("Hide ROI Panel"; Rec."Hide ROI Panel")
                {
                    ToolTip = 'Hides the ROI Panel in the Endpoint List.';
                }

                field("Default Page Size"; Rec."Default Page Size")
                {
                    ToolTip = 'Specifies the value of the Default Page Size field.';
                }

                field("Disable Auto ModifiedAt"; Rec."Disable Auto ModifiedAt")
                {
                    ToolTip = 'Specifies if the "lastModifiedAt" field should NOT be included automatically, globally.';
                }
                field("Disable Auto SystemId"; Rec."Disable Auto SystemId")
                {
                    ToolTip = 'Specifies if the "systemId" field should NOT be included automatically, globally.';
                }
                field("Disable Auto-List"; Rec."Disable Auto-List")
                {
                    ToolTip = 'Specifies if calls to the read endpoint with no Endpoint specified will produce a list, globally.';
                }
                field("Disable Related Id"; Rec."Disable Related Id")
                {
                    ToolTip = 'Specifies the value of the Disable Related Id field.', Comment = '%';
                }
            }
            group(FutureVersions)
            {
                InstructionalText = 'Future Functionality Planned.';
                ObsoleteReason = 'This placeholder section is no longer required.';
                ObsoleteState = Pending;
                ShowCaption = false;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            /*
            action(Usage)
            {
                ApplicationArea = All;
                Caption = 'Get Usage';
                Image = CalculateRemainingUsage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'This function will check the ISO usage.';
                Visible = false;  // need to hide this for screenshots before it does get removed later
                trigger OnAction()
                var
                    ISOUsage: Codeunit "SPB DBraider Usage Tracker";
                    ISODictionary: Dictionary of [Text, Text];
                    UsageTxt: Label 'Total Usage: %1\Total Rows Written: %2\Total Rows Read: %3';
                begin

                    ISOUsage.ReturnIsoUsage(ISODictionary);
                    Message(UsageTxt, ISODictionary.Get('Usage'), ISODictionary.Get('Rows Written'), ISODictionary.Get('Rows Read'));
                end;
            }
            //INFO: This is only used for debugging.
            // action(ResetUsage)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Reset Usage';
            //     Image = ResetStatus;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     ToolTip = 'This function will reset the ISO usage.';
            //     Visible = false;  // need to hide this for screenshots before it does get removed later
            //     trigger OnAction()
            //     var
            //         ISOUsage: Codeunit "SPB DBraider Usage Tracker";
            //         Resettxt: Label 'Usage has been reset.';
            //     begin
            //         ISOUsage.ResetIsoUsage();
            //         Message(Resettxt);
            //     end;
            // }
            */
            action(SetupEndpoints)
            {
                ApplicationArea = All;
                Caption = 'Setup Standard Endpoints';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "SPB Create Endpoints";
                ToolTip = 'This function will setup the Business Central standard endpoints.';
            }
            action(UpdateFieldCaptions)
            {
                ApplicationArea = All;
                Caption = 'Update Field Captions';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'This function will update the Field Captions.';
                Visible = false;  // need to hide this for screenshots before it does get removed later
                trigger OnAction()
                var
                    SPBDBraiderUpgrade: Codeunit "SPB DataBraider Upgrade";
                begin
                    SPBDBraiderUpgrade.UpdateFieldCaptions();
                end;
            }
        }
        area(Navigation)
        {
            action(VariablesAction)
            {
                ApplicationArea = All;
                Caption = 'Variables';
                Image = VariableList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "SPB DBraider Variables";
                ToolTip = 'This function will open the Variables page.';

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}
