page 71033613 "SPB DBraider Write Template"
{
    ApplicationArea = All;
    Caption = 'Data Braider Write Template Tools';
    PageType = Card;
    SourceTable = "SPB DBraider Config. Header";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';
                field(ShowMandatoryOnly; ShowMandatoryOnly)
                {
                    Caption = 'Show Mandatory Only';
                    ToolTip = 'When generating the JSON Template, should it include only the mandatory fields?';
                }
                field(TemplateActionType; TemplateActionType)
                {
                    Caption = 'Template Action Type';
                    ToolTip = 'What type of action should be used in the template?';
                }
            }
            part("SPB DBraider Config. Line"; "SPB DBraider Config. Line")
            {
                Caption = 'Tables';
                SubPageLink = "Config. Code" = field(Code);
                UpdatePropagation = Both;
            }
            group(Template)
            {
                Caption = 'Template';
                usercontrol(SPBJsonPrettyDisplay; "SPB JsonPrettyDisplay")
                {
                    trigger ControlReady()
                    begin
                        previewControlReady := true;
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RegeneratePreviewAction)
            {
                Caption = 'Generate Readable Preview';
                Image = SuggestReconciliationLines;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Generate Readable Preview JSON based on the settings and selected table.';

                trigger OnAction()
                begin
                    GeneratePreview(ShowMandatoryOnly);
                end;
            }
        }
    }

    var
        previewControlReady: Boolean;
        resultsControlReady: Boolean;
        ShowMandatoryOnly: Boolean;
        TemplateActionType: Enum "SPB DBraider Change Action";
        JsonToOperateOn: Text;

    local procedure GeneratePreview(MandatoryOnly: Boolean)
    var
        SPBDBraiderJSONTemplMaker: Codeunit "SPB DBraider JSON Templ. Maker";
        JsonString: Text;
    begin
        if not previewControlReady then
            exit;

        JsonString := SPBDBraiderJSONTemplMaker.GenerateTableToTemplate(Rec, MandatoryOnly, TemplateActionType);
        CurrPage.SPBJsonPrettyDisplay.setJsonText(JsonString);
    end;

    local procedure EscapeJson()
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        JsonString: Text;
    begin
        if not resultsControlReady then
            exit;

        JsonString := SPBDBraiderJsonUtilities.EscapeJson(JsonToOperateOn);

        //CurrPage.SPBJsonOperationResults.setJsonText(JsonString);
    end;

    local procedure UnescapeJsonRequest()
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        JsonString: Text;
    begin
        if not resultsControlReady then
            exit;

        JsonString := SPBDBraiderJsonUtilities.UnescapeJson(JsonToOperateOn);

        //CurrPage.SPBJsonOperationResults.setJsonText(JsonString);
    end;

    local procedure UnescapeJsonResponse()
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        JsonString: Text;
    begin
        if not resultsControlReady then
            exit;

        JsonString := SPBDBraiderJsonUtilities.UnescapeJson(JsonToOperateOn);

        //CurrPage.SPBJsonOperationResults.setJsonText(JsonString);
    end;
}
