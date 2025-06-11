page 71033622 "SPB DBraider Wiz Submit"
{
    ApplicationArea = All;
    Caption = 'DBraider Wiz Submit';
    PageType = ListPart;
    SourceTable = "SPB DBraider Wiz Submit";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Include; Rec.Include)
                {
                    ToolTip = 'Specifies the value of the Include field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }

    procedure SetData(var NewRec: Record "SPB DBraider Wiz Submit")
    begin
        if not Rec.IsTemporary then
            exit;
        Rec.DeleteAll();
        if NewRec.FindSet() then
            repeat
                Rec := NewRec;
                Rec.Insert();
            until NewRec.Next() < 1;
        if Rec.FindFirst() then;
    end;

    procedure GetData(var DestRec: Record "SPB DBraider Wiz Submit")
    begin
        if not DestRec.IsTemporary then
            exit;
        DestRec.DeleteAll();
        if Rec.FindSet() then
            repeat
                DestRec := Rec;
                DestRec.Insert();
            until Rec.Next() < 1;
        if DestRec.FindFirst() then;
    end;
}
