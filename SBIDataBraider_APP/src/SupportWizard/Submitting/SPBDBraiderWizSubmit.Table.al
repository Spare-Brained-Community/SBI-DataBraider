table 71033615 "SPB DBraider Wiz Submit"
{
    Caption = 'DBraider Wiz Submit';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(11; Include; Boolean)
        {
            Caption = 'Include';
        }
    }
    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }
}
