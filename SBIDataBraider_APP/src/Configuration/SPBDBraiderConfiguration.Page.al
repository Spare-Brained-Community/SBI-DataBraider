page 71033602 "SPB DBraider Configuration"
{
    AboutText = 'This Endpoint configuration page is where you define the settings for the API Endpoint.  You can also define which tables and fields are included in the API.';
    AboutTitle = 'Data Braider Endpoint';
    ApplicationArea = All;
    Caption = 'Data Braider API Endpoint';
    ContextSensitiveHelpPage = 'configuration';
    PageType = Document;
    SourceTable = "SPB DBraider Config. Header";
    UsageCategory = None;

    layout
    {
        area(Content)
        {

            group(General)
            {
                AboutText = 'This area is where you define the basic settings for the API Endpoint';
                AboutTitle = 'General Settings';
                field("Code"; Rec.Code)
                {
                    Editable = AllowRename;
                    ToolTip = 'This is the Code that makes this entry unique. It is used in the URL to determine which dataset to use.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'This is a reference field for your use in labelling the configuration.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'If this is selected, the API will be enabled for this configuration.';
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {
                    ToolTip = 'Controls which Type of Endpoint this is.';

                    trigger OnValidate()
                    begin
                        IsReadOnly := not Rec.WriteableConfig();
                    end;
                }
                field("Output JSON Type"; Rec."Output JSON Type")
                {
                    Enabled = IsReadOnly;
                    ToolTip = 'Allows changing the Output JSON between Heirarchy (good for integrations) and Flat (good for Power Platform and Power BI).';
                }
                field("Last Run Duration"; Rec."Last Run Duration")
                {
                    Editable = false;
                    ToolTip = 'Every time the API is called for this configuration, this field is updated to help diagnose any performance issues.';
                }
                group(DemoWarning)
                {
                    InstructionalText = 'Demo Install, Limited Results Returned.';
                    ShowCaption = false;
                    Visible = IsDemoInstall;
                }
            }
            part(Lines; "SPB DBraider Config. Line")
            {
                AboutText = 'This area is where you define which table or tables are included.  You can also specify which fields.';
                AboutTitle = 'Endpoint Lines';
                SubPageLink = "Config. Code" = field(Code);
            }
            group(Writeback)
            {
                Caption = 'Write-Back Endpoint Settings';
                Enabled = not IsReadOnly;
                Visible = not IsReadOnly;
                field("Require PK"; Rec."Require PK")
                {
                    ToolTip = 'If this is selected, the API call must include a complete Primary Key. This is commonly needed for table that do not use the No. Series system.';
                }
                field("Insert Allowed"; Rec."Insert Allowed")
                {
                    ToolTip = 'Are Insert operations allowed via this endpoint?';
                }
                field("Modify Allowed"; Rec."Modify Allowed")
                {
                    ToolTip = 'Are Modify operations allowed via this endpoint?';
                }
                field("Delete Allowed"; Rec."Delete Allowed")
                {
                    ToolTip = 'Are Delete operations allowed via this endpoint?';
                }
                field("Prevent Reading"; Rec."Prevent Reading")
                {
                    ToolTip = 'If this is selected, the API will not allow reading of data from this endpoint, only responses to Writes.';
                }
            }
            group(Logging)
            {
                Caption = 'Logging';
                field("Logging Enabled"; Rec."Logging Enabled")
                {
                    ToolTip = 'Enables logging of all API calls to this endpoint, though not this does decrease performance and increase database size. Use cautiously.';
                }
                field("Clear Logs Count"; Rec."Clear Logs Count")
                {
                    Enabled = Rec."Logging Enabled";
                    ToolTip = 'Specifies the maximum number of Log Entries to keep for this endpoint.';
                }
                field("Clear Older Than"; Rec."Clear Older Than")
                {
                    Enabled = Rec."Logging Enabled";
                    ToolTip = 'Specifies the maximum age of entries to keep for this endpoint.';
                }
            }
            group(AdvancedSettings)
            {
                Caption = 'Advanced Settings';
                field("Page Size"; Rec."Page Size")
                {
                    ToolTip = 'Specifies the maximum number of records to return in a single API call. This is useful for performance tuning.  If set to zero (default), the Data Braider Setup value is used for page sizing instead.';
                }
                field("Disable Auto ModifiedAt"; Rec."Disable Auto ModifiedAt")
                {
                    ToolTip = 'Specifies if the "lastModifiedAt" field should NOT be included automatically for this endpoint. This is useful for performance tuning.  If set to zero (default), the Data Braider Setup value is used for page sizing instead.';
                }
                field("Disable Auto SystemId"; Rec."Disable Auto SystemId")
                {
                    ToolTip = 'Specifies if the "systemId" field should NOT be included automatically for this endpoint.';
                }
                field("Hide from Lists"; Rec."Hide from Lists")
                {
                    ToolTip = 'Specifies if this endpoint should be hidden from the list of available endpoints.';
                }
                field("Disable Related Id"; Rec."Disable Related Id")
                {
                    ToolTip = 'Specifies the value of the Disable Related Id field.', Comment = '%';
                }
            }
            group(Telemetry)
            {
                Caption = 'Telemetry Per Endpoint';
                InstructionalText = 'These settings are meant to enable Environmental Telemetry for a specific endpoint.  This is useful for performance tuning and diagnostics.  If you are not sure what these settings are for, please do not use them.';

                field("Emit Telemetry Read Before"; Rec."Emit Telemetry Read Before")
                {
                    Caption = 'Emit Telemetry - Read - OnBefore';
                    ToolTip = 'With this enabled, telemetry will be emitted before the read operation is performed.';
                }
                field("Emit Telemetry Read After"; Rec."Emit Telemetry Read After")
                {
                    Caption = 'Emit Telemetry - Read - OnAfter';
                    ToolTip = 'With this enabled, telemetry will be emitted after the read operation is performed.';
                }
                field("Emit Telemetry Write Before"; Rec."Emit Telemetry Write Before")
                {
                    Caption = 'Emit Telemetry - Write - OnBefore';
                    Enabled = not IsReadOnly;
                    ToolTip = 'With this enabled, telemetry will be emitted before the write operation is performed.';
                }
                field("Emit Telemetry Write After"; Rec."Emit Telemetry Write After")
                {
                    Caption = 'Emit Telemetry - Write - OnAfter';
                    Enabled = not IsReadOnly;
                    ToolTip = 'With this enabled, telemetry will be emitted after the write operation is performed.';
                }
                field("Emit Telemetry Include Body"; Rec."Emit Telemetry Include Body")
                {
                    Caption = 'Emit Telemetry - Include Body';
                    ToolTip = 'When sending the telemetry, include the body of the request.  This is useful for diagnostics, but can be a security/GDPR risk if not used properly.  Use with caution.';
                }
            }
            group(Audit)
            {
                Caption = 'Audit';
                Editable = false;

                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                }
                field(Usage; Rec.Usage)
                {
                    ToolTip = 'Shows Total Usage of this Endpoint - use Limit Totals to control which months are included.';
                }
                field("Rows Read"; Rec."Rows Read")
                {
                    ToolTip = 'Shows Total Number of Reads using this Endpoint - use Limit Totals to control which months are included';
                }
                field("Rows Written"; Rec."Rows Written")
                {
                    ToolTip = 'Shows Total Number of Reads using this Endpoint - use Limit Totals to control which months are included.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PreviewJson)
            {
                Caption = 'Preview Response';
                Image = VariableList;
                ToolTip = 'Display a visual copy of the resulting JSON from this endpoint. Very helpful for sending data samples and testing run times.';

                trigger OnAction()
                begin
                    Rec.TestJson();
                end;
            }
            /*
            action(WritebackJson)
            {
                Caption = 'Writeable JSON Templates';
                Image = VariableList;
                RunObject = page "SPB DBraider Write Template";
                RunPageLink = Code = field(Code);
                ToolTip = 'Display a tool for generating JSON using this endpoint. Very helpful for sending data samples and testing run times.';
            }
            */

            action(CopyFromAction)
            {
                Caption = 'Copy From';
                Ellipsis = true;
                Image = Copy;
                ToolTip = 'This allows you to Copy the complete Configuration from another, allowing easy reproduction and setup.';

                trigger OnAction()
                var
                    MissingEndpointNameErrorLbl: Label 'You need to enter an Endpoint Name before you can copy lines from another Endpoint, the ''Code'' field can not be blank.';
                begin
                    if Rec.Code = '' then //Added to preventing creating an endpoint with no name(Code).
                        Error(MissingEndpointNameErrorLbl)
                    else
                        CopyLinesFromOtherConfig();
                end;
            }

        }
        area(Navigation)
        {
            action(AnalyzeDataset)
            {
                Caption = 'Analyze Detail Results';
                Image = Debug;
                ToolTip = 'This is mainly meant for diagnostics by partners, seeing the raw data braid by rows and columns.';

                trigger OnAction()
                begin
                    Rec.TestRun();
                end;
            }
            action(EndpointLogAction)
            {
                Caption = 'Endpoint Logs';
                Image = InteractionLog;
                RunObject = page "SPB DBraider End. Logs";
                RunPageLink = "Config. Code" = field(Code);
                ToolTip = 'This allows you to see any logs for this Endpoint, including the JSON sent and received.';
            }
            /*
            action(ShowDeltaVersionsAction)
            {
                Caption = 'Show Delta Baseline Versions';
                Enabled = Rec."Endpoint Type" = Rec."Endpoint Type"::"Delta Read";
                Image = FARegisters;
                ToolTip = 'This will allow you to inspect the Delta Baseline Versions for this Endpoint.';
                Visible = false;

                trigger OnAction()
                begin
                    ShowDeltaVersions(Rec);
                end;
            }
            */
        }

        area(Promoted)
        {
            actionref(PreviewJson_Promoted; PreviewJson) { }
            actionref(EndpointLogRef; EndpointLogAction) { }
            actionref(CopyFromAction_Promoted; CopyFromAction)
            {
                ObsoleteReason = 'This action is no longer promoted.';
                ObsoleteState = Pending;
            }
        }
    }

    internal procedure CopyLinesFromOtherConfig()
    var
        CopyConfigFrom: Report "SPB DBraider Copy Config From";
    begin
        CopyConfigFrom.CopyLinesFromOtherConfig(Rec);
    end;

    /*local procedure ShowDeltaVersions(DBConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderDeltaRow: Record "SPB DBraider Delta Row";
        TempSPBDBraiderDeltaRow: Record "SPB DBraider Delta Row" temporary;
    begin
        SPBDBraiderDeltaRow.SetRange("Config. Code", DBConfigHeader.Code);
        if SPBDBraiderDeltaRow.FindSet() then
            repeat
                TempSPBDBraiderDeltaRow.TransferFields(SPBDBraiderDeltaRow, true);
                TempSPBDBraiderDeltaRow.Insert();
                SPBDBraiderDeltaRow.SetRange("Version No.", SPBDBraiderDeltaRow."Version No.");
                if SPBDBraiderDeltaRow.FindLast() then;
                SPBDBraiderDeltaRow.SetRange("Version No.");
            until SPBDBraiderDeltaRow.Next() < 1;

        Page.Run(Page::"SPB DBraider Delta Versions", TempSPBDBraiderDeltaRow);
    end;*/

    var
        AllowRename: Boolean;
        IsDemoInstall: Boolean;
        IsReadOnly: Boolean;

    trigger OnOpenPage()
    var
        SPBDBLicensing: Codeunit "SPB DBraider Licensing";
    begin
        IsDemoInstall := SPBDBLicensing.IsDemoInstall();

    end;

    trigger OnAfterGetRecord()
    begin
        IsReadOnly := not Rec.WriteableConfig();
        AllowRename := not Rec.HasExistingLines();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AllowRename := true;
        IsReadOnly := not Rec.WriteableConfig();
    end;
}
