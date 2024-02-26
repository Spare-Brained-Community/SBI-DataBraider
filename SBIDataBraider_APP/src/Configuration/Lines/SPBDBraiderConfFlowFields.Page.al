page 71033614 "SPB DBraider Conf FlowFields"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Endpoint FlowFields';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "SPB DBraider ConfLine Flow";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Parent Table No."; Rec."Parent Table No.")
                {
                    ToolTip = 'Specifies the value of the Parent Table No. field.';
                }
                field("Parent Table Name"; Rec."Parent Table Name")
                {
                    ToolTip = 'Specifies the value of the Parent Table Name field.';
                }
                field("Parent FlowFilter Field No."; Rec."Parent FlowFilter Field No.")
                {
                    ToolTip = 'Specifies the value of the Parent FlowFilter Field No. field.';
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {
                    ToolTip = 'Specifies the value of the Parent Field Name field.';
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the value of the Source Table Name field.';
                }
                field("Source FlowFilter Field No."; Rec."Source FlowFilter Field No.")
                {
                    ToolTip = 'Specifies the value of the Source FlowFilter Field No. field.';
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the value of the Source Field Name field.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.FilterGroup(4);
        Rec."Source Table No." := Rec.GetRangeMin("Source Table No.");
        Rec.FilterGroup(0);
        Rec.CalcFields("Source Table Name");
    end;
}
