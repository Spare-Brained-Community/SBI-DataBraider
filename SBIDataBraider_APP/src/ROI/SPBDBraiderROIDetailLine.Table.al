table 71033618 "SPB DBraider ROI Detail Line"
{
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            AutoIncrement = true;
        }
        field(2; Indentation; Integer)
        {
            Caption = 'Indentation';
        }
        field(3; "Belongs To Line No."; Integer)
        {
            Caption = 'Belongs To Line No.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(20; "Creation Hours"; Decimal)
        {
            Caption = 'Creation Hours';
            trigger OnValidate()
            begin
                CalcTotalCreationHours();
            end;
        }
        field(21; "Maintain Hours"; Decimal)
        {
            Caption = 'Maintain Hours';
        }
        field(25; "Consumption Hours"; Decimal)
        {
            Caption = 'Consumption Hours';
            trigger OnValidate()
            begin
                CalcTotalCreationHours();
            end;
        }
        field(26; "Documentation Hours"; Decimal)
        {
            Caption = 'Documentation Hours';
            trigger OnValidate()
            begin

                CalcTotalCreationHours();
            end;
        }
        field(28; "Support Hours"; Decimal)
        {
            Caption = 'Support Hours';
        }
        field(30; "Total Creation Hours"; Decimal)
        {
            Caption = 'Total Creation Hours';
        }

        field(40; "Additional Creation Hours"; Decimal)
        {
            Caption = 'Additional Hours';
        }
        field(41; "Additional Maintain Hours"; Decimal)
        {
            Caption = 'Additional Maintain Hours';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
        key(ChildLines; Indentation, "Belongs To Line No.")
        {
            SumIndexFields = "Creation Hours", "Maintain Hours", "Consumption Hours", "Documentation Hours", "Support Hours", "Additional Creation Hours", "Additional Maintain Hours";
        }
    }

    procedure CalcTotalCreationHours()
    begin
        "Total Creation Hours" := "Creation Hours" + "Consumption Hours" + "Documentation Hours";
    end;
}