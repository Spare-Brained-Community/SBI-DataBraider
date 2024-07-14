page 71033607 "SPB DBraider Result JSON"
{
    ApplicationArea = All;
    Caption = 'Data Braider JSON Viewer';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(JSON)
            {
                Caption = 'JSON:';
                usercontrol(SPBJsonPrettyDisplay; "SPB JsonPrettyDisplay")
                {
                    trigger ControlReady()
                    begin
                        CurrPage.SPBJsonPrettyDisplay.setJsonText(JsonString);
                    end;
                }
            }
        }
    }

    procedure SetJSONToShow(JsonResult: JsonObject)
    begin
        JsonResult.WriteTo(JsonString);
    end;

    procedure SetJSONToShow(JsonResult: JsonArray)
    begin
        JsonResult.WriteTo(JsonString);
    end;

    procedure SetTextToShow(JsonText: Text)
    begin
        JsonString := JsonText;
    end;

    var
        JsonString: Text;
}
