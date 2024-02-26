tableextension 71033600 "SPB DBraider JSON Buffer" extends "JSON Buffer"
{
    fields
    {
        field(71033600; "SPB Mapping Record"; Boolean)
        {
            Caption = 'Mapping Record';
            DataClassification = SystemMetadata;
        }
        field(71033601; "SPB Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(71033602; "SPB Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(71033603; "SPB Source Table Name"; Text[100])
        {
            Caption = 'Source Table Name';
            DataClassification = SystemMetadata;
        }
        field(71033604; "SPB Source Field Name"; Text[100])
        {
            Caption = 'Source Field Name';
            DataClassification = SystemMetadata;
        }
        field(71033605; "SPB Source Field Caption"; Text[100])
        {
            Caption = 'Source Field Caption';
            DataClassification = SystemMetadata;
        }
        field(71033606; "SPB Write Enabled"; Boolean)
        {
            Caption = 'Write Enabled';
            DataClassification = SystemMetadata;
        }
        field(71033607; "SPB Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = SystemMetadata;
        }

        field(71033608; "SPB Config. Code"; Code[20])
        {
            Caption = 'SPB Config. Code';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(71033609; "SPB Config. Line No."; Integer)
        {
            Caption = 'SPB Config. Line No.';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Line"."Line No." where("Config. Code" = field("SPB Config. Code"));
        }

        field(71033610; "SPB Config. Field No."; Integer)
        {
            Caption = 'SPB Config. Field No.';
            DataClassification = SystemMetadata;
        }

        field(71033611; "SPB Record Id"; Integer)
        {
            Caption = 'SPB Record Id';
            DataClassification = SystemMetadata;
        }

        field(71033612; "SPB Record Action"; Enum "SPB DBraider Change Action")
        {
            Caption = 'SPB Record Action';
            DataClassification = SystemMetadata;
        }
        field(71033613; "SPB Primary Key Field"; Boolean)
        {
            Caption = 'SPB Primary Key Field';
            DataClassification = SystemMetadata;
        }
        field(71033614; "SPB Disable Validate"; Option)
        {
            Caption = 'SPB Disable Validate';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Disable Initial,Disable All';
            OptionMembers = " ",DisableInitial,DisableAll;
        }
        field(71033615; "SPB Config. Depth"; Integer)
        {
            Caption = 'SPB Config. Depth';
            DataClassification = SystemMetadata;
        }
        field(71033616; "SPB Processing Order"; Integer)
        {
            Caption = 'SPB Processing Order';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(WriteProcessingOrder; "SPB Record Id", "SPB Processing Order", "SPB Field No.") { }
    }
}
