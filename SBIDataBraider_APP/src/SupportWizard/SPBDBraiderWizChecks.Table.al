table 71033614 "SPB DBraider WizChecks"
{
    Caption = 'DBraider WizChecks';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Check Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
        }
        field(10; Description; Text[200])
        {
            Caption = 'Description';
        }
        field(20; "Check Codeunit"; Integer)
        {
            Caption = 'Check Codeunit';
        }
        field(100; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = " ","Passed","Failed","Skipped";
            OptionCaption = ' ,Passed,Failed,Skipped';
        }
        field(110; Results; Text[250])
        {
            Caption = 'Results';
        }
        field(120; "Suggested Action"; Text[250])
        {
            Caption = 'Suggested Action';
        }
    }
    keys
    {
        key(PK; "Check Code", "Endpoint Code")
        {
            Clustered = true;
        }
        key(ByEndpoint; "Endpoint Code", "Check Code")
        {
        }
    }

    internal procedure GetIconForStatus(WhichStatus: Option): Text[250]
    begin
        case Status of
            Rec.Status::Passed:
                exit('✅');
            Rec.Status::Failed:
                exit('❌');
            Rec.Status::Skipped:
                exit('🛇');
            else
                exit('');
        end;
    end;
}
