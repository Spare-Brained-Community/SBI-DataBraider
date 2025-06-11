page 71033619 "SPB Braider SW EP"
{
    ApplicationArea = All;
    Caption = 'Endpoints';
    Editable = false;
    PageType = ListPart;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {
                    ToolTip = 'Specifies the value of the Endpoint Type field.';
                }
            }
        }
    }

    procedure SetData(var NewRec: Record "SPB DBraider Config. Header")
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

    procedure GetSelectedEndpoints(var SelectedEndpoints: Record "SPB DBraider Config. Header")
    var
        SelectionPosition: Text;
    begin
        SelectedEndpoints.DeleteAll();
        SelectionPosition := Rec.GetPosition();
        if Rec.FindSet() then
            repeat
                SelectedEndpoints := Rec;
                SelectedEndpoints.Insert();
            until Rec.Next() < 1;
        CurrPage.SetSelectionFilter(SelectedEndpoints);
        if SelectedEndpoints.Count = 1 then begin
            SelectedEndpoints.Reset();
            SelectedEndpoints.SetPosition(SelectionPosition);
            SelectedEndpoints.SetRecFilter();
        end;
    end;
}
