page 71033611 "SPB DBraider Write API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Write API';
    DelayedInsert = true;
    EntityName = 'write';
    EntitySetName = 'write';
    ODataKeyFields = Code;
    PageType = API;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(jsonInput; JsonInput)
                {
                    Caption = 'jsonInput', Locked = true;
                }
                field(jsonResult; JsonResult)
                {
                    Caption = 'jsonResult', Locked = true;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SBPDBraiderInputProcessor: Codeunit "SPB DBraider Input Processor";
    begin
        CheckIfGloballyEnbled();
        if not Rec.IsTemporary() and GuiAllowed() then
            Error(TempRecOnlyErr);
        JsonResult := SBPDBraiderInputProcessor.ProcessWriteData(Rec.Code, JsonInput);
    end;

    local procedure CheckIfGloballyEnbled(): Boolean
    var
        DBraiderSetup: Record "SPB DBraider Setup";
        DBNotEnabledErr: Label 'Data Braider is not enabled globally. Please check the Data Braider Setup.';
    begin
        DBraiderSetup.GetRecordOnce();
        if not DBraiderSetup.EnabledGlobally then
            Error(DBNotEnabledErr);
    end;

    var
        TempRecOnlyErr: Label 'Page must be run with Temporary records only.';
        JsonInput: Text;
        JsonResult: Text;
}
