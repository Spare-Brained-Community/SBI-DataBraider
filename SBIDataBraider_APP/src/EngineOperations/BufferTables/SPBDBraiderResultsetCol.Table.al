table 71033606 "SPB DBraider Resultset Col"
{
    Caption = 'DBraider Resultset Col';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Data Type"; Enum "SPB DBraider Field Data Type")
        {
            Caption = 'Data Type';
            DataClassification = SystemMetadata;
        }
        field(20; "Value as Text"; Text[250])
        {
            Caption = 'Value as Text';
            DataClassification = SystemMetadata;
        }
        field(30; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            DataClassification = SystemMetadata;
        }

        field(35; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(50; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Header";
        }
        field(100; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(120; "Field Class"; Text[100])
        {
            Caption = 'Field Class';
        }
        field(201; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
            DataClassification = SystemMetadata;
        }
        field(202; "Top-Level SystemId"; Guid)
        {
            Caption = 'Top-Level SystemId';
            DataClassification = SystemMetadata;
        }

        field(1000; TextCell; Text[250])
        {
            Caption = 'TextCell';
            DataClassification = SystemMetadata;
        }
        field(2000; CodeCell; Code[250])
        {
            Caption = 'CodeCell';
            DataClassification = SystemMetadata;
        }
        field(3000; NumberCell; Decimal)
        {
            Caption = 'NumberCell';
            DataClassification = SystemMetadata;
        }
        field(4000; DateCell; Date)
        {
            Caption = 'DateCell';
            DataClassification = SystemMetadata;
        }
        field(5000; TimeCell; Time)
        {
            Caption = 'TimeCell';
            DataClassification = SystemMetadata;
        }
        field(6000; DatetimeCell; DateTime)
        {
            Caption = 'DatetimeCell';
            DataClassification = SystemMetadata;
        }
        field(7000; BooleanCell; Boolean)
        {
            Caption = 'BooleanCell';
            DataClassification = SystemMetadata;
        }
        field(8000; GuidCell; Guid)
        {
            Caption = 'GuidCell';
            DataClassification = SystemMetadata;
        }
        field(25000; "FQ SystemId"; Text[400])
        {
            Caption = 'FQ SystemId';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Row No.", "Column No.")
        {
            Clustered = true;
        }
        key(TopLevel; "Top-Level SystemId") { }
    }

}
