page 71033610 "SPB DBraider End. Logs"
{
    ApplicationArea = All;
    Caption = 'Data Braider Endpoint Logs';
    CardPageId = "SPB DBraider End. Log";
    Editable = false;
    PageType = List;
    SourceTable = "SPB DBraider Endpoint Log";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Config. Code"; Rec."Config. Code")
                {
                    ToolTip = 'Specifies the value of the Config. Code field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.';
                }
                field(Success; Rec.Success)
                {
                    ToolTip = 'Specifies the value of the Success field.';
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(RetryApiInput_Promoted; RetryApiInput) { }
        }

        area(Processing)
        {
            action(DeleteSelectedLogsAction)
            {
                ApplicationArea = All;
                Caption = 'Delete Selected Logs';
                Image = DeleteAllBreakpoints;
                ToolTip = 'Deletes Selected the log entries for this endpoint.';

                trigger OnAction()
                var
                    SPBDBraiderEndpointLog: Record "SPB DBraider Endpoint Log";
                begin
                    CurrPage.SetSelectionFilter(SPBDBraiderEndpointLog);
                    if not SPBDBraiderEndpointLog.IsEmpty() then
                        if Confirm('Are you sure you want to delete the selected log entries?', false) then
                            SPBDBraiderEndpointLog.DeleteAll();
                end;
            }

            action(RetryApiInput)
            {
                Caption = 'Retry API Request';
                Image = Recalculate;
                ToolTip = 'Retry the API call that generated this log entry, using the Json input.';

                trigger OnAction()
                var
                    RetryQst: Label 'Are you sure you want to retry the API call that generated this log entry?\ \Reminder: This will not send the response data to the original caller, so this is mainly useful for testing and diagnostics.';
                begin
                    if Confirm(RetryQst, false) then
                        Rec.RetryRequestJson();
                end;
            }
        }

    }
}
