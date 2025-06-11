page 71033618 "SPB Braider Support Wizard"
{
    Caption = 'Braider Support Wizard';
    PageType = NavigatePage;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;
    RefreshOnActivate = true;

    // Appreciated, Yun Zhu.  Page template roughly modified from https://yzhums.com/2883/

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '', Locked = true;
                Editable = false;
                Visible = TopBannerVisible and not SubmitActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(SubmitedBanner)
            {
                Caption = '', Locked = true;
                Editable = false;
                Visible = TopBannerVisible and SubmitActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group(WelcomeChunk)
                {
                    Caption = 'Welcome to the Data Braider Support Wizard';
                    Visible = Step1Visible;
                    group(Welcome)
                    {
                        ShowCaption = false;
                        InstructionalText = 'This tool will first check for common issues, then assist you in creating a support case.';
                    }
                }
            }

            group(Step2)
            {
                Caption = 'Select Endpoints';
                InstructionalText = 'This process is going to check for common issues.  Please select which endpoints you would like to include in the check.';
                Visible = Step2Visible;

                part(EndpointListPart; "SPB Braider SW EP")
                {
                    ApplicationArea = All;
                    Caption = 'Endpoints';
                }

            }
            group(Step3)
            {
                Caption = 'Scan For Issues';
                InstructionalText = 'Press the Start Scan button.  Please be patient as the scan progresses.  If there are detected issues, there will be suggested actions to correct the problem.';
                Visible = Step3Visible;

                part(ScanResultsPart; "SPB Support Wizard List")
                {
                    ApplicationArea = All;
                    Caption = 'Scans & Results';
                    UpdatePropagation = Both;
                }

            }


            group(Step4)
            {
                Caption = 'Submit a Support Case';
                InstructionalText = 'Below are the elements you can choose to include in the support case submission.  Note that file may include data in plaintext if Logs are selected, so please be mindful of any sensitive data.';
                Visible = Step4Visible;

                part(SubmissionList; "SPB DBraider Wiz Submit")
                {
                    ApplicationArea = All;
                    Caption = 'Support Case Submission';
                }
                group(CaseDetails)
                {
                    Caption = 'Case Details';
                    InstructionalText = 'Please provide a description of the issue you are experiencing and how to contact you.';

                    field("Case Details"; CaseDescription)
                    {
                        ApplicationArea = All;
                        Caption = 'Case Description';
                        MultiLine = true;
                        ShowCaption = false;
                        ShowMandatory = true;
                        ToolTip = 'Please provide a detailed description of the issue you are experiencing';

                        trigger OnValidate()
                        begin
                            CheckIfSubmitReady();
                        end;
                    }
                    field(CaseSeverity; CaseSeverity)
                    {
                        ApplicationArea = All;
                        Caption = 'Case Severity';
                        OptionCaption = ' ,Critical - Production Stopped,High - Production Impacted,Medium - Production Partially Impacted,Low - No Production Impact';
                        ToolTip = 'Please select the severity of the issue';

                        trigger OnValidate()
                        begin
                            CheckIfSubmitReady();
                        end;
                    }
                    field(CaseContactName; CaseContactName)
                    {
                        ApplicationArea = All;
                        Caption = 'Contact Name';
                        ShowMandatory = true;
                        ToolTip = 'Please provide a name for the case contact';

                        trigger OnValidate()
                        begin
                            CheckIfSubmitReady();
                        end;
                    }
                    field(CaseEmail; CaseEmail)
                    {
                        ApplicationArea = All;
                        Caption = 'Contact Email';
                        ShowMandatory = true;
                        ToolTip = 'Please provide an email address for the case contact';

                        trigger OnValidate()
                        begin
                            CheckIfSubmitReady();
                        end;
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionSubmit)
            {
                ApplicationArea = All;
                Caption = 'Submit';
                Enabled = SubmitActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction()
                begin
                    SubmitAction();
                end;
            }
        }
    }
    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    begin
        // Initialize the Endpoint list
        Rec.DeleteAll();
        if SPBDBraiderConfigHeader.FindSet() then
            repeat
                Rec := SPBDBraiderConfigHeader;
                Rec.Insert();
            until SPBDBraiderConfigHeader.Next() < 1;
        CurrPage.EndpointListPart.Page.SetData(SPBDBraiderConfigHeader);

        Step := Step::Start;
        EnableControls();
    end;

    trigger OnAfterGetRecord()
    begin
        // RefreshOnActivate is triggering this more often, as on Step 3 we need to know if the state of things has changed
        if Step = Step::Step3 then
            NextActionEnabled := SPBDBraiderWizState.IsWizardScanningComplete();

        if Step = Step::Submit then
            CheckIfSubmitReady();
    end;

    var
        CaseDescription: Text;
        CaseSeverity: Option " ","Critical - Production Stopped","High - Production Impacted","Medium - Production Partially Impacted","Low - No Production Impact";
        CaseContactName: Text;
        CaseEmail: Text;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        Step: Option Start,Step2,Step3,Submit;
        BackActionEnabled: Boolean;
        SubmitActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        SPBDBraiderWizState: Codeunit "SPB DBraider Wiz State";

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::Submit:
                ShowStep4();
        end;
    end;

    local procedure SubmitAction()
    var
        TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary;
        TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary;
        TempSPBDBraiderWizSubmit: Record "SPB DBraider Wiz Submit" temporary;
        SPBDBraiderSupportSubmit: Codeunit "SPB DBraider Support Submit";
    begin
        SPBDBraiderWizState.GetSelectedEndpoints(TempSelectedEndpoints);
        SPBDBraiderWizState.GetSPBDBraiderWizChecks(TempSPBDBraiderWizChecks);

        CurrPage.SubmissionList.Page.GetData(TempSPBDBraiderWizSubmit);
        SPBDBraiderSupportSubmit.SubmitSupportRequest(
            TempSelectedEndpoints, TempSPBDBraiderWizChecks, TempSPBDBraiderWizSubmit,
            CaseDescription, CaseSeverity, CaseContactName, CaseEmail);
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep1()
    begin
        Step1Visible := true;

        SubmitActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2()
    begin
        Step2Visible := true;
    end;

    local procedure ShowStep3()
    var
        TempSelectedEndpoints: Record "SPB DBraider Config. Header" temporary;
        TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary;
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
    begin
        // Find out what selected endpoints we have
        CurrPage.EndpointListPart.Page.GetSelectedEndpoints(TempSelectedEndpoints);
        SPBDBraiderWizState.SetSelectedEndpoints(TempSelectedEndpoints);

        // On this step, we'll need the Checks that will be run
        TempSPBDBraiderWizChecks.DeleteAll();
        SPBDBraiderEvents.OnSupportWizardChecksStarting(TempSelectedEndpoints, TempSPBDBraiderWizChecks);
        CurrPage.ScanResultsPart.Page.SetData(TempSPBDBraiderWizChecks);
        SPBDBraiderWizState.SetSPBDBraiderWizChecks(TempSPBDBraiderWizChecks);

        Step3Visible := true;
    end;

    local procedure ShowStep4()
    begin
        Step4Visible := true;

        PopulateSubmissionList();

        NextActionEnabled := false;
        SubmitActionEnabled := true;
    end;

    local procedure ResetControls()
    begin
        SubmitActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
        Step4Visible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure ValidateCaseDetails() Valid: Boolean
    begin
        // Check all the case values to ensure they have a value, setting Valid to true if they are all filled in
        Valid := (CaseDescription <> '') AND
                 (CaseSeverity <> CaseSeverity::" ") AND
                 (CaseContactName <> '') AND
                 (CaseEmail <> '');
    end;

    local procedure PopulateSubmissionList()
    var
        TempSPBDBraiderWizSubmit: Record "SPB DBraider Wiz Submit" temporary;
        SPBDBraiderSupportSubmit: Codeunit "SPB DBraider Support Submit";
    begin
        SPBDBraiderSupportSubmit.PopulateSubmissionList(TempSPBDBraiderWizSubmit);
        CurrPage.SubmissionList.Page.SetData(TempSPBDBraiderWizSubmit);
    end;

    local procedure CheckIfSubmitReady()
    begin
        SubmitActionEnabled := ValidateCaseDetails();
    end;
}