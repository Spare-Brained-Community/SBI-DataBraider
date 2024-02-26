page 71033606 "SPB DBraider Result Subpage"
{

    ApplicationArea = All;
    Caption = 'Data Braider Result Columns';
    PageType = ListPart;
    SourceTable = "SPB DBraider Resultset Col";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Row No."; Rec."Row No.")
                {
                    ToolTip = 'Which Row Number of the data braid this is.';
                }
                field("Column No."; Rec."Column No.")
                {
                    ToolTip = 'Which Column Number of the data braid this is.';
                }
                field("FieldCaption"; Rec."Field Name")
                {
                    ToolTip = 'The caption of the column.';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ToolTip = 'Which type of data is in this column';
                }
                field("Value as Text"; Rec."Value as Text")
                {
                    ToolTip = 'The value of the column represented as a Text value.';
                }
            }
        }
    }

    procedure SetTempData(var ResultCol: Record "SPB DBraider Resultset Col" temporary)
    begin
        if not Rec.IsTemporary then
            exit;

        Rec.DeleteAll();
        if ResultCol.FindSet() then
            repeat
                Rec.TransferFields(ResultCol);
                Rec.Insert();
            until ResultCol.Next() = 0;
    end;
}
