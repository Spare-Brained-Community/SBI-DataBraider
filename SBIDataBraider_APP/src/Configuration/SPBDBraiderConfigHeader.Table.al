table 71033601 "SPB DBraider Config. Header"
{
    Caption = 'DBraider Config. Header';
    DataClassification = SystemMetadata;
    Permissions = tabledata "SPB DBraider Usage" = rim;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(20; "Last Run Duration"; Duration)
        {
            Caption = 'Last Run Duration';
        }
        field(30; "Endpoint Type"; Enum "SPB DBraider Endpoint Type")
        {
            Caption = 'Endpoint Type';
            ValuesAllowed = "Read Only", "Per Record", Batch;

            trigger OnValidate()
            begin
                DoTypeFormatValidation();
                case "Endpoint Type" of
                    "Endpoint Type"::"Read Only":
                        begin
                            "Require PK" := false;
                            "Insert Allowed" := false;
                            "Modify Allowed" := false;
                            "Delete Allowed" := false;
                        end;
                    "Endpoint Type"::"Per Record":
                        begin
                            "Require PK" := true;
                            "Insert Allowed" := true;
                            "Modify Allowed" := true;
                            "Delete Allowed" := true;
                        end;
                    "Endpoint Type"::"Batch":
                        begin
                            "Require PK" := true;
                            "Insert Allowed" := true;
                            "Modify Allowed" := true;
                            "Delete Allowed" := true;
                        end;
                    "Endpoint Type"::"Delta Read":
                        begin
                            "Require PK" := false;
                            "Insert Allowed" := false;
                            "Modify Allowed" := false;
                            "Delete Allowed" := false;
                        end;
                end;
            end;
        }

        field(35; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }

        field(40; "Require PK"; Boolean)
        {
            Caption = 'Require Entire Primary Key';
            InitValue = false;
        }

        field(50; "Insert Allowed"; Boolean)
        {
            Caption = 'Insert Allowed';
            InitValue = false;
        }
        field(51; "Modify Allowed"; Boolean)
        {
            Caption = 'Modify Allowed';
            InitValue = false;
        }
        field(52; "Delete Allowed"; Boolean)
        {
            Caption = 'Delete Allowed';
            InitValue = false;
        }
        field(53; "Prevent Reading"; Boolean)
        {
            Caption = 'Prevent Reading';
            InitValue = false;
        }

        field(60; "Disable Auto ModifiedAt"; Boolean)
        {
            Caption = 'Disable Auto ModifiedAt';
            InitValue = false;
        }
        field(61; "Disable Auto SystemId"; Boolean)
        {
            Caption = 'Disable Auto SystemId';
            InitValue = false;
        }
        field(62; "Hide from Lists"; Boolean)
        {
            Caption = 'Hide from Lists';
            InitValue = false;
        }
        field(80; "Disable Related Id"; Boolean)
        {
            Caption = 'Disable Related Id';
            InitValue = false;
        }

        field(100; "Output JSON Type"; Enum "SPB DBraider Output Json Type")
        {
            Caption = 'Output JSON Type';

            trigger OnValidate()
            begin
                DoTypeFormatValidation();
            end;
        }

        field(200; "Logging Enabled"; Boolean)
        {
            Caption = 'Logging Enabled';
        }
        field(201; "Clear Logs Count"; Integer)
        {
            Caption = 'Clear Logs Count';
            InitValue = 100;
            MaxValue = 10000;
            MinValue = 0;
        }
        field(202; "Clear Older Than"; DateFormula)
        {
            Caption = 'Clear Older Than';
        }
        field(210; "Page Size"; Integer)
        {
            BlankZero = true;
            Caption = 'Page Size';
            MaxValue = 200000;
            MinValue = 0;
        }

        field(220; "Emit Telemetry Read Before"; Boolean)
        {
            Caption = 'Emit Telemetry - Read OnBefore';
        }
        field(221; "Emit Telemetry Read After"; Boolean)
        {
            Caption = 'Emit Telemetry - Read OnAfter';
        }
        field(222; "Emit Telemetry Write Before"; Boolean)
        {
            Caption = 'Emit Telemetry - Write OnBefore';
        }
        field(223; "Emit Telemetry Write After"; Boolean)
        {
            Caption = 'Emit Telemetry - Write OnAfter';
        }
        field(225; "Emit Telemetry Include Body"; Boolean)
        {
            Caption = 'Emit Telemetry - Include Body';

            trigger OnValidate()
            var
                DataSafetyWarningMsg: Label 'Reminder: This will emit the contents of the request/response body to telemetry in plaintext, which is against best practice with real data. Ensure that this is allowed by your organization''s privacy policy and GDPR requirements.';
            begin
                if "Emit Telemetry Include Body" then
                    Message(DataSafetyWarningMsg)
            end;
        }

        field(250; "Data Archive Versions"; Integer)
        {
            Caption = 'Data Archive Versions';
            InitValue = 1;
            MaxValue = 10;
            MinValue = 0;
        }

        field(1000; Usage; Integer)
        {
            CalcFormula = sum("SPB DBraider Usage"."Call Tally" where("Endpoint Id" = field(SystemId), "Month Start Date" = field("Date Filter")));
            Caption = 'Usage';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1001; "Avg. Usage"; Integer)
        {
            CalcFormula = average("SPB DBraider Usage"."Call Tally" where("Endpoint Id" = field(SystemId), "Month Start Date" = field("Date Filter")));
            Caption = 'Avg. Usage';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteReason = 'Use Usage instead';
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
        }

        field(1002; "Rows Read"; BigInteger)
        {
            CalcFormula = sum("SPB DBraider Usage"."Rows Read" where("Endpoint Id" = field(SystemId), "Month Start Date" = field("Date Filter")));
            Caption = 'Rows Read';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1003; "Rows Written"; BigInteger)
        {
            CalcFormula = sum("SPB DBraider Usage"."Rows Written" where("Endpoint Id" = field(SystemId), "Month Start Date" = field("Date Filter")));
            Caption = 'Rows Written';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1010; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(1020; "Has Archive Data"; Boolean)
        {
            CalcFormula = exist("SPB DBraider Delta Row" where("Config. Code" = field(Code)));
            Caption = 'Has Archive Data';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1021; "Max Version No."; Integer)
        {
            CalcFormula = max("SPB DBraider Delta Row"."Version No." where("Config. Code" = field(Code)));
            Caption = 'Max Version No.';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, "Endpoint Type", Enabled, "Output JSON Type")
        {

        }
    }

    trigger OnDelete()
    begin
        DeleteRelatedData();
    end;

    local procedure DeleteRelatedData()
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineRelation: Record "SPB DBraider ConfLine Relation";
    begin
        SPBDBraiderConfigLine.SetRange("Config. Code", Rec.Code);
        SPBDBraiderConfigLine.DeleteAll(true);
        SPBDBraiderConfLineField.SetRange("Config. Code", Rec.Code);
        SPBDBraiderConfLineField.DeleteAll(true);
        SPBDBraiderConfLineRelation.SetRange("Config. Code", Rec.Code);
        SPBDBraiderConfLineRelation.DeleteAll(true);
        SPBDBraiderConfLineFlow.SetRange("Config. Code", Rec.Code);
        SPBDBraiderConfLineFlow.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        if HasExistingLines() then
            Error(NoRenameErr);
    end;

    internal procedure HasExistingLines(): Boolean
    var
        ConfigLines: Record "SPB DBraider Config. Line";
    begin
        ConfigLines.SetRange("Config. Code", Rec.Code);
        exit(not ConfigLines.IsEmpty);
    end;

    internal procedure WriteableConfig(): Boolean
    begin
        /* exit(Rec."Endpoint Type" in
            [Rec."Endpoint Type"::"Single Table",
            Rec."Endpoint Type"::Transaction]); */
        exit(Rec."Endpoint Type" in [Rec."Endpoint Type"::"Per Record", Rec."Endpoint Type"::Batch]);
    end;

    procedure TestRun()
    var
        SPBDBraiderSampleJsonMaker: Codeunit "SPB DBraider JSON Utilities";
    begin
        SPBDBraiderSampleJsonMaker.TestResultRun(Rec.Code);
    end;

    procedure TestJson()
    var
        SPBDBraiderSampleJsonMaker: Codeunit "SPB DBraider JSON Utilities";
    begin
        SPBDBraiderSampleJsonMaker.TestResultJson(Rec.Code);
    end;

    internal procedure RegisterUsage(ReadRecordCount: Integer; WrittenRecordCount: Integer)
    var
        DBraiderUsage: Record "SPB DBraider Usage";
        StartOfCurrMonth: Date;
    begin
        StartOfCurrMonth := CalcDate('<-CM>', Today());
        if DBraiderUsage.Get(Rec.SystemId, StartOfCurrMonth) then begin
            DBraiderUsage."Call Tally" += 1;
            DBraiderUsage."Rows Read" += ReadRecordCount;
            DBraiderUsage."Rows Written" += WrittenRecordCount;
            DBraiderUsage.Modify(true);
        end else begin
            DBraiderUsage.Init();
            DBraiderUsage."Endpoint Id" := Rec.SystemId;
            DBraiderUsage."Month Start Date" := StartOfCurrMonth;
            DBraiderUsage."Call Tally" := 1;
            DBraiderUsage."Rows Read" := ReadRecordCount;
            DBraiderUsage."Rows Written" := WrittenRecordCount;
            DBraiderUsage.Insert(true);
        end;
    end;

    internal procedure RegisterReadUsage(Count: Integer)
    begin
        RegisterUsage(Count, 0);
    end;

    internal procedure RegisterWriteUsage(Count: Integer)
    begin
        RegisterUsage(0, Count);
    end;

    internal procedure DoTypeFormatValidation()
    begin
        // Depending on the Endpoint Type, some related fields are required
        case Rec."Endpoint Type" of
            Rec."Endpoint Type"::"Per Record":
                Rec."Output JSON Type" := Rec."Output JSON Type"::Flat;  // Write transactions are per-record, so Flat output is required.
            Rec."Endpoint Type"::Batch:
                Rec."Output JSON Type" := Rec."Output JSON Type"::Flat;  // Write transactions are batch, so Flat output is required.
            Rec."Endpoint Type"::"Delta Read":

                Rec."Data Archive Versions" := 1; // Initialize to 1 for Delta Reads
                                                  // We then immediately generate the first dataset for subsequent Delta Reads
                                                  //DBraiderEngine.GenerateData(Rec.Code);
        end;
    end;

    var
        NoRenameErr: Label 'You cannot rename a Configuration that has been set up. (Header)';
}
