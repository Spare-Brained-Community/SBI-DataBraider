table 71033617 "SPBDBraider Event Notification"
{
    DataClassification = SystemMetadata;
    Caption = 'SPBDBraider Event Notifications';
    TableType = Temporary;

    fields
    {
        field(1; LineNo; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; TableNo; Integer)
        {
            Caption = 'Table No.';

        }
        field(10; "RecordID"; RecordId)
        {
            Caption = 'Record ID';
        }
        field(20; "Action"; Text[50])
        {
            Caption = 'Action';

        }
        field(30; Endpoint; Code[20])
        {
            Caption = 'DBraider Endpoint';
        }
        field(40; DeletedPK; Text[250])
        {
            Caption = 'Deleted Primary Key';
        }

    }

    keys
    {
        key(PK; LineNo)
        {
            Clustered = true;
        }
    }
}