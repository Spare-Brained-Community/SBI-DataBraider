table 71033603 "SPB DBraider ConfLine Field"
{
    DataCaptionFields = "Table Name", "Field Name";
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Config. Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "SPB DBraider Config. Line"."Line No." where("Config. Code" = field("Config. Code"));
        }

        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            begin
                ValidateFieldNo("Field No.");
            end;
        }


        field(10; Included; Boolean)
        {
            Caption = 'Included';
            trigger OnValidate()
            begin
                if not Included then
                    "Write Enabled" := false;
            end;
        }

        field(20; "Processing Order"; Integer)
        {
            Caption = 'Processing Order';
        }

        field(30; "Filter"; Text[250])
        {
            Caption = 'Filter';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                TestNewFilterText("Filter");
            end;
        }

        field(40; "Write Enabled"; Boolean)
        {
            Caption = 'Write Enabled';
        }
        field(41; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
        }
        field(42; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
        }
        field(43; "Upsert Match"; Boolean)
        {
            Caption = 'Upsert Match';
        }

        field(44; "Disable Validation"; Option)
        {
            Caption = 'Disable Validation';
            OptionCaption = ' ,Disable Initial,Disable All';
            OptionMembers = " ",DisableInitial,DisableAll;

            trigger OnValidate()
            var
                DisableAllCautionMsg: Label 'Using the ''Disable All'' option will disable all validation on this field. This can introduce dangerously malformed data and can result in significant expensive problems. Any damages from use of this function are your responsibility.\ \Are you CERTAIN you want to do this?';
            begin
                if "Disable Validation" = "Disable Validation"::DisableAll then
                    if not Confirm(DisableAllCautionMsg) then
                        "Disable Validation" := "Disable Validation"::" "
            end;
        }
        field(45; "Disable Auto-Split Key"; Boolean)
        {
            Caption = 'Disable Auto-Split Key';
        }
        field(50; "DateTime Timezone"; Text[250])
        {
            Caption = 'DateTime Timezone';

            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
                TestDateTime: DateTime;
            begin
                TestDateTime := CurrentDateTime();
                // We should get an error if the user enters an invalid name for a timezone, I think
                TestDateTime := TypeHelper.ConvertDateTimeFromUTCToTimeZone(TestDateTime, "DateTime Timezone");
            end;
        }

        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }

        field(110; "Field Type"; Enum "SPB DBraider Field Data Type")
        {
            Caption = 'Field Type';
        }
        field(120; "Field Class"; Text[100])
        {
            Caption = 'Field Class';
        }

        field(130; "Primary Key"; Boolean)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            Description = 'Denotes if a field is part of the primary key';
            Editable = false;
        }

        field(1000; Caption; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Caption';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1001; "Field Name"; Text[250])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1002; "Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Config. Code", "Config. Line No.", "Field No.")
        {
            Clustered = true;
        }
        key(Processing; "Config. Code", "Config. Line No.", "Processing Order", "Field No.")
        {

        }
    }


    local procedure TestNewFilterText(var FilterText: Text[250])
    var
        RecRef: RecordRef;
        FieldsRef: FieldRef;
    begin
        if (Rec."Table No." = 0) or (Rec."Field No." = 0) or (FilterText = '') then
            exit;

        // Get the Record ref for the table
        RecRef.Open(Rec."Table No.");

        // Get the FieldRef for this field
        FieldsRef := RecRef.Field(Rec."Field No.");

        // Apply the filter to it
        FieldsRef.SetFilter(FilterText);

        // update the filter to the 'processed' value
        FilterText := CopyStr(FieldsRef.GetFilter(), 1, MaxStrLen(FilterText));
    end;

    local procedure ValidateFieldNo(FieldNo: Integer)
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        RecRef: RecordRef;
        FieldsRef: FieldRef;
    begin
        if Rec."Table No." <> 0 then begin
            RecRef.Open(Rec."Table No.");
            FieldsRef := RecRef.Field(FieldNo);
            Rec."Field Type" := SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FieldsRef.Type);
            Rec."Field Class" := Format(FieldsRef.Class);
        end;
    end;
}