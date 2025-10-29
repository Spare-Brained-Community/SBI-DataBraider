table 71033612 "SPB DBraider Delta Col"
{
    Caption = 'DBraider Delta Col';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
        }
        field(2; "Column No."; Integer)
        {
            Caption = 'Column No.';
        }
        field(10; "Data Type"; Enum "SPB DBraider Field Data Type")
        {
            Caption = 'Data Type';
        }
        field(20; "Value as Text"; Text[250])
        {
            Caption = 'Value as Text';
        }
        field(30; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
        }

        field(35; "Field No."; Integer)
        {
            Caption = 'Field No.';
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
        field(120; "Field Class"; Text[100])
        {
            Caption = 'Field Class';
        }
        field(201; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
        }
        field(202; "Top-Level SystemId"; Guid)
        {
            Caption = 'Top-Level SystemId';
        }

        field(1000; TextCell; Text[250])
        {
            Caption = 'TextCell';
        }
        field(2000; CodeCell; Code[250])
        {
            Caption = 'CodeCell';
        }
        field(3000; NumberCell; Decimal)
        {
            Caption = 'NumberCell';
        }
        field(4000; DateCell; Date)
        {
            Caption = 'DateCell';
        }
        field(5000; TimeCell; Time)
        {
            Caption = 'TimeCell';
        }
        field(6000; DatetimeCell; DateTime)
        {
            Caption = 'DatetimeCell';
        }
        field(7000; BooleanCell; Boolean)
        {
            Caption = 'BooleanCell';
        }
        field(8000; GuidCell; Guid)
        {
            Caption = 'GuidCell';
        }
        field(25000; "FQ SystemId"; Text[400])
        {
            Caption = 'FQ SystemId';
        }
    }
    keys
    {
        key(PK; "Config. Code", "Version No.", "Row No.", "Column No.")
        {
            Clustered = true;
        }
        key(TopLevel; "Top-Level SystemId") { }
    }

}
