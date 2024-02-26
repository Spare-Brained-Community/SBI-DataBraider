page 71033611 "SPB DBraider Write API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    ApplicationArea = All;
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
        CheckIfLicensed();
        CheckIfGloballyEnbled();
        if Licensed then
            JsonResult := SBPDBraiderInputProcessor.ProcessWriteData(Rec.Code, JsonInput)
        else begin
            JsonResult := UnlicensedErr;
            exit(true);
        end;
    end;

    local procedure CheckIfLicensed()
    var
        LicenseConnector: Codeunit "SPB DBraider Licensing";
    begin
        Licensed := LicenseConnector.CheckIfActive(false);
        if not Rec.IsTemporary and GuiAllowed then
            Error(TempRecOnlyErr);
    end;

    local procedure CheckIfGloballyEnbled(): Boolean
    var
        DBraiderSetup: Record "SPB DBraider Setup";
        DBNotEnabledErr: Label 'Data Braider is not enabled globally. Please check the Data Braider Setup.';
    begin
        DBraiderSetup.Get();
        if not DBraiderSetup.EnabledGlobally then
            Error(DBNotEnabledErr);
    end;

    var
        Licensed: Boolean;
        TempRecOnlyErr: Label 'Page must be run with Temporary records only.';
        UnlicensedErr: Label 'This copy of Data Braider has not been licensed or the license is not activated.';
        JsonInput: Text;
        JsonResult: Text;
}
