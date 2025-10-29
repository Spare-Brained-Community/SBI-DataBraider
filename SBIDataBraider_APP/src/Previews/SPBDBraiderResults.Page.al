page 71033605 "SPB DBraider Results"
{
    ApplicationArea = All;
    Caption = 'Data Braider Result Rows';
    Editable = false;
    PageType = List;
    SourceTable = "SPB DBraider Resultset Row";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Row No."; Rec."Row No.")
                {
                    ToolTip = 'Specifies the value of the Row No. field';
                }
                field("Data Level"; Rec."Data Level")
                {
                    ToolTip = 'Specifies the value of the Data Level field';
                }
                field("Source Table"; Rec."Source Table")
                {
                    ToolTip = 'Specifies the value of the Source Table field';
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the value of the Source Table Name field';
                }
                field("Primary Key String"; Rec."Primary Key String")
                {
                    ToolTip = 'Specifies the value of the Primary Key String field';
                }
            }

            part(Lines; "SPB DBraider Result Subpage")
            {
                SubPageLink = "Row No." = field("Row No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PreviewAsJson)
            {
                Caption = 'Preview JSON';
                Image = VariableList;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Display a visual copy of the resulting JSON from this configuration. Very helpful for sending data samples and testing run times.';

                trigger OnAction()
                var
                    SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
                    JsonPreviewPage: Page "SPB DBraider Result JSON";
                    SPBDBraiderIDatasetToText: Interface "SPB DBraider IDatasetToText";
                    JsonPreview: Text;
                begin
                    SPBDBraiderConfigHeader.Get(Rec."Config. Code");
                    SPBDBraiderIDatasetToText := SPBDBraiderConfigHeader."Output JSON Type";
                    JsonPreview := SPBDBraiderIDatasetToText.ConvertToJSONText(Rec, TempSPBDBraiderResultsetCol);
                    Clear(JsonPreviewPage);
                    JsonPreviewPage.SetTextToShow(JsonPreview);
                    JsonPreviewPage.Run();
                end;
            }
        }
    }


    procedure SetTempData(var RowData: Record "SPB DBraider Resultset Row" temporary; var ColData: Record "SPB DBraider Resultset Col" temporary)
    begin
        if not Rec.IsTemporary() then
            exit;

        Rec.DeleteAll();
        if RowData.FindSet() then
            repeat
                Rec.TransferFields(RowData);
                Rec.Insert();
            until RowData.Next() = 0;

        if ColData.FindSet() then
            repeat
                TempSPBDBraiderResultsetCol.TransferFields(ColData);
                TempSPBDBraiderResultsetCol.Insert();
            until ColData.Next() = 0;

        CurrPage.Lines.Page.SetTempData(ColData);
    end;

    var
        TempSPBDBraiderResultsetCol: Record "SPB DBraider Resultset Col" temporary;
}
