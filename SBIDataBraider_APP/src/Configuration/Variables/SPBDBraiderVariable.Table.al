table 71033616 "SPB DBraider Variable"
{
    Caption = 'Data Braider Variable';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10; "Variable Scope"; Enum "SPB DBraider Variable Scope")
        {
            Caption = 'Variable Scope';
        }
        field(11; "Company Name"; Text[250])
        {
            Caption = 'Company Name';
            TableRelation = "Company".Name;
        }
        field(12; "User Name"; Text[50])
        {
            Caption = 'User Name';
            TableRelation = "User"."User Name";
            ValidateTableRelation = false;
        }
        field(20; Tag; Text[30])
        {
            Caption = 'Tag';
            trigger OnValidate()
            begin
                CheckRequirements();
                CheckTagUniqueByScope();
            end;
        }
        field(30; Value; Text[250])
        {
            Caption = 'Value';
            trigger OnValidate()
            begin
                CheckRequirements();
            end;
        }
        field(40; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ScopeTags; "Variable Scope", "Company Name", "User Name", Tag)
        {
        }
    }

    local procedure CheckTagUniqueByScope()
    var
        SPBDBraiderVariables2: Record "SPB DBraider Variable";
    begin
        case Rec."Variable Scope" of
            Rec."Variable Scope"::Environment:
                begin
                    // At environment, the tag must be unique completely
                    SPBDBraiderVariables2.SetRange("Variable Scope", Rec."Variable Scope");
                    SPBDBraiderVariables2.SetRange(Tag, Rec.Tag);
                    if not SPBDBraiderVariables2.IsEmpty() then
                        Error('The Tag must be unique within the same Scope.');
                end;
            Rec."Variable Scope"::Company:
                begin
                    // At company, the tag must be unique within the company
                    SPBDBraiderVariables2.SetRange("Variable Scope", Rec."Variable Scope");
                    SPBDBraiderVariables2.SetRange("Company Name", Rec."Company Name");
                    SPBDBraiderVariables2.SetRange(Tag, Rec.Tag);
                    if not SPBDBraiderVariables2.IsEmpty() then
                        Error('The Tag must be unique within the same Scope.');
                end;
            Rec."Variable Scope"::User:
                begin
                    // At user, the tag must be unique within the user
                    SPBDBraiderVariables2.SetRange("Variable Scope", Rec."Variable Scope");
                    SPBDBraiderVariables2.SetRange("User Name", Rec."User Name");
                    SPBDBraiderVariables2.SetRange(Tag, Rec.Tag);
                    if not SPBDBraiderVariables2.IsEmpty() then
                        Error('The Tag must be unique within the same Scope.');
                end;
            Rec."Variable Scope"::CompanyUser:
                begin
                    // At company and user, the tag must be unique within the company and user
                    SPBDBraiderVariables2.SetRange("Variable Scope", Rec."Variable Scope");
                    SPBDBraiderVariables2.SetRange("Company Name", Rec."Company Name");
                    SPBDBraiderVariables2.SetRange("User Name", Rec."User Name");
                    SPBDBraiderVariables2.SetRange(Tag, Rec.Tag);
                    if not SPBDBraiderVariables2.IsEmpty() then
                        Error('The Tag must be unique within the same Scope.');
                end;
        end;
    end;

    local procedure CheckRequirements()
    var
        ScopeRequirementMissingErr: Label '%1 is required with the Scope of %2.', Comment = '%1 is the required field, and %2 is the Scope.';
    begin
        case Rec."Variable Scope" of
            Rec."Variable Scope"::Company:
                if Rec."Company Name" = '' then
                    Error(ScopeRequirementMissingErr, Rec."Company Name", Format(Rec."Variable Scope"));
            Rec."Variable Scope"::User:
                if Rec."User Name" = '' then
                    Error(ScopeRequirementMissingErr, Rec."User Name", Format(Rec."Variable Scope"));
            Rec."Variable Scope"::CompanyUser:
                begin
                    if Rec."Company Name" = '' then
                        Error(ScopeRequirementMissingErr, Rec."Company Name", Format(Rec."Variable Scope"));
                    if Rec."User Name" = '' then
                        Error(ScopeRequirementMissingErr, Rec."User Name", Format(Rec."Variable Scope"));
                end;

        end;
    end;
}
