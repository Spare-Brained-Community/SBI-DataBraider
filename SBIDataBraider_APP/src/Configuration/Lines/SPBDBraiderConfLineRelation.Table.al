table 71033604 "SPB DBraider ConfLine Relation"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Config. Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Line"."Line No." where("Config. Code" = field("Config. Code"));
        }

        field(5; "Relation Line No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }


        field(10; "Parent Table"; Integer)
        {
            Caption = 'Parent Table';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Parent Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Parent Table")));
            Caption = 'Parent Table Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(20; "Child Table"; Integer)
        {
            Caption = 'Child Table';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; "Child Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Child Table")));
            Caption = 'Child Table Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(50; "Parent Field No."; Integer)
        {
            Caption = 'Parent Field';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." where(TableNo = field("Parent Table"));

            trigger OnValidate()
            begin
                CalcFields("Parent Field Caption");
            end;

            trigger OnLookup()
            begin
                Validate("Parent Field No.", LookupSourceField(Rec."Parent Table"));
            end;
        }

        field(51; "Parent Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Parent Table"), "No." = field("Parent Field No.")));
            Caption = 'Parent Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }

        field(70; "Child Field No."; Integer)
        {
            Caption = 'Child Field';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." where(TableNo = field("Child Table"));

            trigger OnValidate()
            begin
                CalcFields("Child Field Caption");
            end;

            trigger OnLookup()
            begin
                Validate("Child Field No.", LookupSourceField(Rec."Child Table"));
            end;
        }

        field(71; "Child Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Child Table"), "No." = field("Child Field No.")));
            Caption = 'Child Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }

        field(100; "Manual Linking"; Boolean)
        {
            Caption = 'Manual Linking';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Config. Code", "Config. Line No.", "Relation Line No.")
        {
            Clustered = true;
        }
    }


    procedure LookupSourceField(WhichTable: Integer): Integer
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
    begin
        exit(SPBDBraiderUtilities.LookupSourceField(WhichTable));
    end;
}