page 71033601 "SPB DBraider Configurations"
{
    AboutText = 'This list of Endpoints are what will be exposed as Custom APIs via the Data Braider API.';
    AboutTitle = 'Data Braider Endpoints';
    AdditionalSearchTerms = 'SBI,SPB,Databraider,DBraider';
    ApplicationArea = All;
    Caption = 'Data Braider API Endpoints';
    CardPageId = "SPB DBraider Configuration";
    ContextSensitiveHelpPage = 'configuration';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "SPB DBraider Config. Header";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'This is the Code that makes this entry unique. It is used in the URL to determine which dataset to use.';
                    AboutText = 'This field specifies the unique code for endpoint calls.';
                    AboutTitle = 'Code';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'If this is selected, the API will be enabled for this configuration.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'This is a reference field for your use in labelling the configuration.';
                }
                field("Last Run Duration"; Rec."Last Run Duration")
                {
                    ToolTip = 'Every time the API is called for this configuration, this field is updated to help diagnose any performance issues.';
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {
                    ToolTip = 'Specifies which Endpoint Type this Endpoint is.';
                    AboutText = 'You can select if this endpoint will allow modifications or be read-only.';
                    AboutTitle = 'Endpoint Type';
                }
                field(EndPointUrl; EndPointUri)
                {
                    Caption = 'Endpoint URL';
                    ExtendedDatatype = URL;
                    ToolTip = 'The URL of the Endpoint';
                    AboutText = 'This is a preview of what the URL might be to access this endpoint.';
                    AboutTitle = 'Endpoint URI';
                }
                field(Usage; Rec.Usage)
                {
                    ToolTip = 'Shows Total Usage of this Endpoint - use Limit Totals to control which months are included.';
                    Visible = false;
                }
                field("Rows Read"; Rec."Rows Read")
                {
                    ToolTip = 'Shows Total Number of Reads using this Endpoint - use Limit Totals to control which months are included';
                    Visible = false;
                }
                field("Rows Written"; Rec."Rows Written")
                {
                    ToolTip = 'Shows Total Number of Reads using this Endpoint - use Limit Totals to control which months are included.';
                    Visible = false;
                }
            }
            group(ROIInfo)
            {
                Caption = 'Data Braider ROI Information';
                Visible = ShowROIPanel;
                field(CreationHoursField; CreationHours)
                {
                    Caption = 'Creation Hours Saved';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'This shows the total number of development hours saved on API Creation by using the endpoints as configured.';
                    trigger OnDrillDown()
                    begin
                        ShowROIPage();
                    end;
                }
                field(MaintainHoursField; MaintainHours)
                {
                    Caption = 'Maintenance Hours Saved';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'This shows the total number of development hours saved on API Maintenance by using the endpoints as configured.';
                    trigger OnDrillDown()
                    begin
                        ShowROIPage();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Previews)
            {
                action(PreviewDataset)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This action is no longer supported from the list.';
                    ToolTip = 'This action is no longer supported from the list.';
                    Visible = false;

                    trigger OnAction()
                    begin
                        Rec.TestJson();
                    end;
                }
                action(GeneratePostmanAction)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Postman Collection';
                    Image = InteractionTemplate;
                    ToolTip = 'Generate a sample Postman Collection for the selected configurations.';

                    trigger OnAction()
                    var
                        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
                        SPBDBraiderGenPostman: Codeunit "SPB DBraider Gen. Postman";
                        UserChoice: Integer;
                        EnvironTypeQst: Label 'Would you like the Postman Collection configured for OnPrem/Docker or Cloud?';
                        EnvironTypeTok: Label 'OnPrem/Docker,Cloud';
                    begin
                        UserChoice := StrMenu(EnvironTypeTok, 1, EnvironTypeQst);
                        if UserChoice < 1 then
                            exit;
                        if StrMenu(EnvironTypeTok, 1, EnvironTypeQst) = 1 then
                            SPBDBraiderGenPostman.SetUseDockerAuth();
                        CurrPage.SetSelectionFilter(SPBDBraiderConfigHeader);
                        SPBDBraiderGenPostman.Run(SPBDBraiderConfigHeader);
                    end;
                }
                action(GeneratePowerBIQueryAction)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Power BI Query';
                    Enabled = Rec."Output JSON Type" = Rec."Output JSON Type"::Flat;
                    Image = PowerBI;
                    ToolTip = 'Generate a sample Power BI Query for the current configuration line. Only "Flat" JSON output is supported in this version.';

                    trigger OnAction()
                    var
                        SPBDBraiderGenPowerBI: Codeunit "SPB DBraider Gen PowerBI";
                    begin
                        SPBDBraiderGenPowerBI.Run(Rec);
                    end;
                }
                action(GeneratePowerAutomateAction)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Power Automate Flow';
                    Enabled = Rec."Output JSON Type" = Rec."Output JSON Type"::Flat;
                    Image = NextSet;
                    ToolTip = 'Generate a sample Power Automate Flow for the current configuration line. Only "Flat" JSON output is supported in this version.';

                    trigger OnAction()
                    var
                        SPBDBraiderGenAutomate: Codeunit "SPB DBraider Gen Automate";
                    begin
                        SPBDBraiderGenAutomate.Run(Rec);
                    end;
                }
            }
            group(ImportExport)
            {
                Caption = 'Import/Export';
                Image = ImportExport;

                action(Import)
                {
                    Caption = 'Import';
                    Image = Import;
                    RunObject = xmlport "SPB DBraider Import";
                    ToolTip = 'This step allows you to import Data Braider Configurations.';
                }
                action(Export)
                {
                    Caption = 'Export';
                    Image = Export;
                    ToolTip = 'This step allows you to export Data Braider Configurations.';

                    trigger OnAction()
                    var
                        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
                        SPBImportExport: XmlPort "SPB DBraider Export";
                    begin
                        Clear(SPBImportExport);
                        CurrPage.SetSelectionFilter(SPBDBraiderConfigHeader);
                        SPBImportExport.SetTableView(SPBDBraiderConfigHeader);
                        SPBImportExport.Run();
                    end;
                }
            }
            group(Support)
            {
                Caption = 'Support';
                Image = Help;
                action(WizardAction)
                {
                    Caption = 'Support Wizard';
                    Image = ViewServiceOrder;
                    ToolTip = 'Open the Data Braider Support Wizard';
                    RunObject = page "SPB Braider Support Wizard";
                }
            }
        }
        area(Navigation)
        {
            group(Information)
            {
                action(ShowROIAction)
                {
                    Caption = 'Show ROI';
                    Image = TotalValueInsured;
                    ToolTip = 'Show the ROI Information window for Data Braider.';
                    trigger OnAction()
                    begin
                        ShowROIPage();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Generators)
            {
                Caption = 'Generators';
                ShowAs = SplitButton;
                actionref(GeneratePostmanAction_Promoted; GeneratePostmanAction)
                {
                }
                actionref(GeneratePowerBIQueryAction_Promoted; GeneratePowerBIQueryAction)
                {
                }
                actionref(GeneratePowerAutomateAction_Promoted; GeneratePowerAutomateAction)
                {
                }
                actionref(PreviewDataset_Promoted; PreviewDataset)
                {
                    ObsoleteReason = 'This action is no longer supported from the list.';
                    ObsoleteState = Pending;
                }
            }
        }
    }

    views
    {
        view(ViewEnabled)
        {
            Caption = 'Enabled';
            Filters = where(Enabled = filter(true));
        }
        view(ViewWrite)
        {
            Caption = 'Write Endpoints';
            Filters = where("Endpoint Type" = filter("Per Record" | Batch));
        }
        view(ViewRead)
        {
            Caption = 'Read Endpoints';
            Filters = where("Endpoint Type" = filter("Read Only" | "Delta Read"));
        }
    }
    var
        SPBDBraiderROIBuilder: Codeunit "SPB DBraider ROI Builder";
        EndPointUri: Text;
        CreationHours: Decimal;
        MaintainHours: Decimal;
        ShowROIPanel: Boolean;

    trigger OnOpenPage()
    var
        SPBDraiderSetup: Record "SPB DBraider Setup";
        LicenseConnector: Codeunit "SPB DBraider Licensing";
    begin
        if SPBDraiderSetup.Get() then
            ShowROIPanel := not SPBDraiderSetup."Hide ROI Panel"
        else
            ShowROIPanel := true;

        LicenseConnector.CheckIfActive(true);
        CalculateRoi();
    end;

    trigger OnAfterGetRecord()
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
    begin
        Clear(EndPointUri);
        if Rec.Enabled then
            EndPointUri := SPBDBraiderUtilities.GetJsonEndpointURI(Rec);
    end;

    local procedure CalculateRoi()
    begin
        SPBDBraiderROIBuilder.GetTotalROI(CreationHours, MaintainHours);
    end;

    local procedure ShowROIPage()
    begin
        Page.Run(Page::"SPB DBraider ROI Detail");
    end;
}
