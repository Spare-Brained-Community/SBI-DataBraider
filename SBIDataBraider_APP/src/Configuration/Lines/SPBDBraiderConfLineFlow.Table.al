table 71033610 "SPB DBraider ConfLine Flow"
{
    Caption = 'Endpoint Line FlowFields';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Config. Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "SPB DBraider Config. Line"."Line No." where("Config. Code" = field("Config. Code"));
        }

        field(4; "FlowField Line No."; Integer)
        {
            Caption = 'FlowField Line No.';
        }

        field(5; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';

            trigger OnLookup()
            begin
                Validate("Parent Table No.", OnLookupParentTable());
            end;

            trigger OnValidate()
            begin
                CalcFields("Parent Field Caption", "Parent Field Name");
            end;
        }
        field(6; "Parent FlowFilter Field No."; Integer)
        {
            Caption = 'Parent FlowFilter Field No.';
            TableRelation = Field."No." where(TableNo = field("Parent Table No."), Class = const(FlowFilter));

            trigger OnValidate()
            begin
                CalcFields("Parent Field Caption", "Parent Field Name");
            end;

            trigger OnLookup()
            begin
                Validate("Parent FlowFilter Field No.", LookupSourceField(Rec."Parent Table No.", Format(FieldClass::FlowFilter)));
            end;
        }

        field(7; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
        }
        field(8; "Source FlowFilter Field No."; Integer)
        {
            Caption = 'Source FlowFilter Field No.';
            TableRelation = Field."No." where(TableNo = field("Source Table No."), Class = const(Normal));

            trigger OnValidate()
            begin
                CalcFields("Source Field Caption", "Source Field Name");
            end;

            trigger OnLookup()
            begin
                Validate("Source FlowFilter Field No.", LookupSourceField(Rec."Source Table No.", Format(FieldClass::Normal)));
            end;
        }

        field(1000; "Parent Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Parent Table No."), "No." = field("Parent FlowFilter Field No.")));
            Caption = 'Parent Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1001; "Parent Field Name"; Text[250])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Parent Table No."), "No." = field("Parent FlowFilter Field No.")));
            Caption = 'Parent Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1002; "Parent Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Parent Table No.")));
            Caption = 'Parent Table Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1010; "Source Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Source Table No."), "No." = field("Source FlowFilter Field No.")));
            Caption = 'Source Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1011; "Source Field Name"; Text[250])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Source Table No."), "No." = field("Source FlowFilter Field No.")));
            Caption = 'Source Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1012; "Source Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Source Table No.")));
            Caption = 'Source Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Config. Code", "Config. Line No.", "FlowField Line No.")
        {
            Clustered = true;
        }
    }

    procedure OnLookupParentTable() TableNo: Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfigLine2: Record "SPB DBraider Config. Line";
        TableObjects: Page "Table Objects";
        NothingFound: Boolean;
        i: Integer;
        PossibleTableNo: Integer;
        PossibleValidParentTableNos: List of [Integer];
        PossibleValidTableFilterBuilder: TextBuilder;
    begin
        SPBDBraiderConfigLine2.Get(Rec."Config. Code", Rec."Config. Line No.");
        repeat
            SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigLine2."Config. Code");
            SPBDBraiderConfigLine.SetFilter("Line No.", '<%1', SPBDBraiderConfigLine2."Line No.");
            SPBDBraiderConfigLine.SetFilter(Indentation, '<%1', SPBDBraiderConfigLine2.Indentation);

            if SPBDBraiderConfigLine.FindLast() then begin
                if not PossibleValidParentTableNos.Contains(SPBDBraiderConfigLine."Source Table") then
                    PossibleValidParentTableNos.Add(SPBDBraiderConfigLine."Source Table");
                SPBDBraiderConfigLine2 := SPBDBraiderConfigLine;
            end else
                NothingFound := true;
        until NothingFound;

        // Now all the 'Possible Parents' are marked, so we can present that sub-list to the user
        for i := 1 to PossibleValidParentTableNos.Count do begin
            PossibleValidParentTableNos.Get(i, PossibleTableNo);
            PossibleValidTableFilterBuilder.Append(Format(PossibleTableNo));
            if i < PossibleValidParentTableNos.Count then
                PossibleValidTableFilterBuilder.Append('|');
        end;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetFilter("Object ID", PossibleValidTableFilterBuilder.ToText());
        TableObjects.SetTableView(AllObjWithCaption);
        TableObjects.Editable(false);
        TableObjects.LookupMode(true);
        if TableObjects.RunModal() = Action::LookupOK then begin
            TableObjects.GetRecord(AllObjWithCaption);
            TableNo := AllObjWithCaption."Object ID";
        end;
    end;

    internal procedure LookupSourceField(WhichTable: Integer): Integer
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
    begin
        exit(SPBDBraiderUtilities.LookupSourceField(WhichTable));
    end;

    internal procedure LookupSourceField(WhichTable: Integer; FieldClassFilter: Text): Integer
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
    begin
        exit(SPBDBraiderUtilities.LookupSourceField(WhichTable, FieldClassFilter));
    end;
}
