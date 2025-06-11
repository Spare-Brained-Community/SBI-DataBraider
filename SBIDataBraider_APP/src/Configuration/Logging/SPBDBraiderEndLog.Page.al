page 71033612 "SPB DBraider End. Log"
{
    ApplicationArea = All;
    Caption = 'Data Braider Endpoint Log';
    DeleteAllowed = true;
    Editable = false;
    PageType = Card;
    SourceTable = "SPB DBraider Endpoint Log";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Config. Code"; Rec."Config. Code")
                {
                    ToolTip = 'Specifies the value of the Config. Code field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.';
                }
                field(Success; Rec.Success)
                {
                    ToolTip = 'Specifies the value of the Success field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
            }
            group(Input)
            {
                Caption = 'Input:';
                usercontrol(SPBJsonPrettyDisplayInput; "SPB JsonPrettyDisplay")
                {
                    trigger ControlReady()
                    begin
                        InputControlReady := true;
                        CurrPage.SPBJsonPrettyDisplayInput.setJsonText(InputJsonString);
                    end;
                }
            }
            group(Output)
            {
                Caption = 'Output:';
                usercontrol(SPBJsonPrettyDisplayOutput; "SPB JsonPrettyDisplay")
                {
                    trigger ControlReady()
                    begin
                        OutputControlReady := true;
                        CurrPage.SPBJsonPrettyDisplayOutput.setJsonText(OutputJsonString);
                    end;
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
            action(RetryApiInput)
            {
                Caption = 'Retry API Request';
                Image = Recalculate;
                ToolTip = 'Retry the API call that generated this log entry, using the Json input.';

                trigger OnAction()
                var
                    RetryQst: Label 'Are you sure you want to retry the API call that generated this log entry?';
                begin
                    if Confirm(RetryQst, false) then
                        Rec.RetryRequestJson();
                end;
            }
        }
    }

    var
        InputControlReady: Boolean;
        OutputControlReady: Boolean;
        InputJsonString: Text;
        OutputJsonString: Text;

    trigger OnInit()
    begin
        InputJsonString := '{"test": "value"}';
        OutputJsonString := '{"test": "value"}';
    end;

    trigger OnAfterGetRecord()
    var
        inS: InStream;
        LineOfText: Text;
        BlobTextBuilder: TextBuilder;
        InputJsonStringMsg: Label '{"Message": "There is no request data for this log entry.  This could be due to you are performing a Read on a Write endpoint. i.e the endpoint using a GET method, rather then a POST."}'; //TODO: TEST_APP Possibly Rewrite default message to reflect DBraider, not Postman
    begin
        InputJsonString := InputJsonStringMsg; //This will get overridden if there is data in the BLOB field
        Rec.CalcFields("Raw Input", "Raw Output");

        // Read the contents of the "Raw Input" and "Raw Output" BLOB fields into texts
        if Rec."Raw Input".HasValue() then begin
            Rec."Raw Input".CreateInStream(inS);
            while not inS.EOS() do begin
                inS.ReadText(LineOfText);
                BlobTextBuilder.AppendLine(LineOfText);
            end;
            InputJsonString := BlobTextBuilder.ToText();
        end;


        BlobTextBuilder.Clear();
        Clear(inS);
        Clear(LineOfText);
        if Rec."Raw Output".HasValue() then begin
            Rec."Raw Output".CreateInStream(inS);
            while not inS.EOS() do begin
                inS.ReadText(LineOfText);
                BlobTextBuilder.AppendLine(LineOfText);
            end;
            OutputJsonString := BlobTextBuilder.ToText();
        end;
        Clear(inS);

        // Push the contents of the "Raw Input" and "Raw Output" BLOB fields into the "Input" and "Output" text fields, if they're ready
        if InputControlReady then
            CurrPage.SPBJsonPrettyDisplayInput.setJsonText(InputJsonString);
        if OutputControlReady then
            CurrPage.SPBJsonPrettyDisplayOutput.setJsonText(OutputJsonString);
    end;
}
