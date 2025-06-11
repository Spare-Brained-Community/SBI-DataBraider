table 71033611 "SPB DBraider Delta Row"
{
    Caption = 'DBraider Delta';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
        }
        field(10; "Data Level"; Integer)
        {
            Caption = 'Data Level';
        }
        field(20; Keyname; Text[50])
        {
            Caption = 'Keyname';
        }
        field(30; "Header Row"; Boolean)
        {
            Caption = 'Header Row';
        }
        field(40; "Belongs To Row No."; Integer)
        {
            Caption = 'Belongs To Row No.';
        }
        field(50; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "SPB DBraider Config. Header";
        }
        field(51; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }

        field(100; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(110; "Source Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Source Table")));
            Caption = 'Source Table Name';
            FieldClass = FlowField;
            Editable = false;
        }

        field(200; "Primary Key String"; Text[250])
        {
            Caption = 'Primary Key String';
        }
        field(201; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
        }
        field(202; "Top-Level SystemId"; Guid)
        {
            Caption = 'Top-Level SystemId';
        }
        field(300; "Delta Type"; Enum "SPB DBraider Delta Type")
        {
            Caption = 'Delta Type';
        }
        field(25000; "FQ SystemId"; Text[400])
        {
            Caption = 'FQ SystemId';
        }
    }
    keys
    {
        key(PK; "Config. Code", "Version No.", "Row No.")
        {
            Clustered = true;
        }
        key(DataLevel; "Data Level") { }
        key(TopLevel; "Top-Level SystemId") { }
    }

}
