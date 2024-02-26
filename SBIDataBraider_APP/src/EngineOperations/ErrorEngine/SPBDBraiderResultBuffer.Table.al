table 71033613 "SPB DBraider Result Buffer"
{
    Caption = 'DBraider Result Buffer';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(10; "Result Type"; Enum "SPB DBraider Result Type")
        {
            Caption = 'Result Type';
        }

        field(20; Result; Text[1024])
        {
            Caption = 'Result';
        }
    }
    keys
    {
        key(PK; "Row No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
