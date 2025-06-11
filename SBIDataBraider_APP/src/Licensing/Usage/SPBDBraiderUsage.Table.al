table 71033608 "SPB DBraider Usage"
{
    Caption = 'Endpoint Usage';
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Endpoint Id"; Guid)
        {
            Caption = 'Endpoint Id';
        }
        field(2; "Month Start Date"; Date)
        {
            Caption = 'Month Start Date';
        }
        field(10; "Call Tally"; Integer)
        {
            Caption = 'Call Tally';
        }
        field(20; "Rows Read"; BigInteger)
        {
            Caption = 'Rows Read';
        }
        field(21; "Rows Written"; BigInteger)
        {
            Caption = 'Rows Written';
        }
    }
    keys
    {
        key(PK; "Endpoint Id", "Month Start Date")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ISOUsage.LogUsageToIso();
    end;

    trigger OnModify()
    begin
        ISOUsage.LogUsageToIso();
    end;

    var
        ISOUsage: Codeunit "SPB DBraider Usage Tracker";
}
