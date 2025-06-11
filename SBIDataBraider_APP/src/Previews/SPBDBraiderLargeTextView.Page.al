page 71033616 "SPB DBraider Large Text View"
{
    ApplicationArea = All;
    Caption = 'Data Braider Content Preview';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(dynamicCaptionField; DynamicCaption)
            {
                Editable = false;
                MultiLine = true;
                ShowCaption = false;
            }
            group(JSON)
            {
                ShowCaption = false;
                usercontrol(SPBJsonPrettyDisplay; "SPB JsonPrettyDisplay")
                {
                    trigger ControlReady()
                    begin
                        CurrPage.SPBJsonPrettyDisplay.setBasicText(TextString);
                    end;
                }
            }
        }
    }

    procedure SetTextToShow(BasicText: Text)
    begin
        TextString := BasicText;
    end;

    procedure SetCaptionToShow(CaptionToShow: Text)
    begin
        DynamicCaption := CaptionToShow;
    end;

    var
        TextString: Text;
        DynamicCaption: Text;
}
