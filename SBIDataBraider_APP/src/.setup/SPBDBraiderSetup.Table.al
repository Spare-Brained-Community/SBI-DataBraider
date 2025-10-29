table 71033600 "SPB DBraider Setup"
{
    Caption = 'Data Braider Setup';
    DataClassification = SystemMetadata;
    DrillDownPageId = "SPB DBraider Setup";
    LookupPageId = "SPB DBraider Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = false;
        }
        field(5; EnabledGlobally; Boolean)
        {
            Caption = 'Enabled Globally';
            InitValue = true;
        }
        field(10; "Default Page Size"; Integer)
        {
            Caption = 'Default Page Size';
            InitValue = 1000;
        }

        field(30; "Hide ROI Panel"; Boolean)
        {
            Caption = 'Hide ROI Panel';
            InitValue = false;
        }
        field(60; "Disable Auto ModifiedAt"; Boolean)
        {
            Caption = 'Disable Auto ModifiedAt';
            InitValue = false;
        }
        field(61; "Disable Auto SystemId"; Boolean)
        {
            Caption = 'Disable Auto SystemId';
            InitValue = false;
        }
        field(70; "Disable Auto-List"; Boolean)
        {
            Caption = 'Disable Auto-List';
            InitValue = false;
        }
        field(80; "Disable Related Id"; Boolean)
        {
            Caption = 'Disable Related Id';
            InitValue = false;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        if not Get() then
            InsertIfNotExists();
        RecordHasBeenRead := true;
    end;

    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}
