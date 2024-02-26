table 71033607 "SPB DBraider Filters"
{
    Caption = 'SBP DBraider Filters';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Filter Text"; Text[250])
        {
            Caption = 'Filter Text';
            DataClassification = SystemMetadata;
        }
        field(10; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = SystemMetadata;
        }
        field(20; "Error Description"; Text[200])
        {
            Caption = 'Error Description';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

}
