table 71033602 "SPB DBraider Config. Line"
{
    Caption = 'DBraider Config. Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }

        field(10; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                if "Line No." <> 0 then
                    if ("Source Table" <> 0) then begin
                        if ("Source Table" <> xRec."Source Table") then
                            DeleteRelatedData();
                        PopulateFieldList();
                    end else
                        DeleteRelatedData();
                CalcFields("Field Count");
            end;
        }
        field(11; "Source Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Source Table")));
            Caption = 'Source Table Name';
            FieldClass = FlowField;
        }

        field(20; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
        field(21; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(50; "Relation Type"; Enum "SPB DBraider Relation Type")
        {
            Caption = 'Relation Type';
            DataClassification = SystemMetadata;
        }

        field(55; "Relation Operation"; Enum "SPB DBraider Rel. Operation")
        {
            Caption = 'Relation Operation';
            DataClassification = SystemMetadata;
        }

        field(59; "Relationship Configured"; Boolean)
        {
            Caption = 'Relationship Configured';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(1000; "Field Count"; Integer)
        {
            CalcFormula = count("SPB DBraider ConfLine Field" where("Config. Code" = field("Config. Code"), "Config. Line No." = field("Line No.")));
            Caption = 'Field Count';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1001; "Included Fields"; Integer)
        {
            CalcFormula = count("SPB DBraider ConfLine Field" where("Config. Code" = field("Config. Code"), "Config. Line No." = field("Line No."), Included = const(true)));
            Caption = 'Included Fields';
            Editable = false;
            FieldClass = FlowField;
        }

    }
    keys
    {
        key(PK; "Config. Code", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CalcFields("Field Count");
        if "Field Count" = 0 then
            PopulateFieldList();
    end;

    trigger OnDelete()
    begin
        DeleteRelatedData();
    end;

    procedure CheckIndentation(): Boolean
    var
        DBraiderConfLine: Record "SPB DBraider Config. Line";
    begin
        DBraiderConfLine.SetRange("Config. Code", Rec."Config. Code");
        exit(DBraiderConfLine.Count() > 1);
    end;

    procedure UpdateParent()
    var
        ParentLine: Record "SPB DBraider Config. Line";
    begin
        if Rec.Indentation = 0 then begin
            Rec."Parent Table No." := 0;
            exit;
        end;

        //find the 'parent'
        ParentLine := Rec;
        repeat
#pragma warning disable AA0181
            ParentLine.Next(-1);  // This *could* throw an error if it can't find a Parent for some reason, and we're OK with that
                                  //Message(Format(ParentLine.Indentation));
#pragma warning restore AA0181
        until ((ParentLine.Indentation = (Rec.Indentation - 1)) or (ParentLine.Indentation = 0));
        Rec."Parent Table No." := ParentLine."Source Table";

        AttemptAutoMagicLink(Rec."Parent Table No.", Rec."Source Table");
    end;

    procedure PopulateFieldList()
    var
        DBraiderConfLineFieldSBI: Record "SPB DBraider ConfLine Field";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        RecRef: RecordRef;
        FieldsRef: FieldRef;
        i: Integer;
        PKFieldNumbers: List of [Integer];
    begin
        if Rec."Line No." <> 0 then begin
            DBraiderConfLineFieldSBI.SetRange("Config. Code", Rec."Config. Code");
            DBraiderConfLineFieldSBI.SetRange("Config. Line No.", Rec."Line No.");
            if DBraiderConfLineFieldSBI.IsEmpty then begin
                // Populate the dataset
                RecRef.Open("Source Table");
                PKFieldNumbers := SPBDBraiderUtilities.GetPrimaryKeyFields(RecRef);
                for i := 1 to RecRef.FieldCount do begin
                    FieldsRef := RecRef.FieldIndex(i);
                    DBraiderConfLineFieldSBI.Init();
                    DBraiderConfLineFieldSBI."Config. Code" := Rec."Config. Code";
                    DBraiderConfLineFieldSBI."Config. Line No." := Rec."Line No.";
                    DBraiderConfLineFieldSBI."Field No." := FieldsRef.Number;
                    DBraiderConfLineFieldSBI."Table No." := Rec."Source Table";
                    DBraiderConfLineFieldSBI."Processing Order" := 10;
                    DBraiderConfLineFieldSBI."Field Type" := SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FieldsRef.Type);
                    DBraiderConfLineFieldSBI."Field Class" := Format(FieldsRef.Class);
                    DBraiderConfLineFieldSBI."Primary Key" := PKFieldNumbers.Contains(FieldsRef.Number);
                    DBraiderConfLineFieldSBI.Insert(true);
                    // Because flowfields aren't searchable, we need to copy the caption to a Normal class field
                    DBraiderConfLineFieldSBI.CalcFields("Field Name", Caption);
                    DBraiderConfLineFieldSBI."Fixed Field Name" := DBraiderConfLineFieldSBI."Field Name";
                    DBraiderConfLineFieldSBI."Fixed Field Caption" := DBraiderConfLineFieldSBI.Caption;
                    DBraiderConfLineFieldSBI.Modify();
                end;

                Commit(); // To Allow running modally after
            end;
        end;
    end;

    procedure ShowFieldList(Editable: Boolean)
    var
        DBraiderConfLineFieldSBI: Record "SPB DBraider ConfLine Field";
        DBraiderConfigFieldsSBI: Page "SPB DBraider Config. Fields";
    begin
        Rec.TestField("Source Table");

        PopulateFieldList();
        Clear(DBraiderConfigFieldsSBI);
        DBraiderConfLineFieldSBI.SetRange("Config. Code", Rec."Config. Code");
        DBraiderConfLineFieldSBI.SetRange("Config. Line No.", Rec."Line No.");
        DBraiderConfigFieldsSBI.Editable(Editable);
        DBraiderConfigFieldsSBI.SetTableView(DBraiderConfLineFieldSBI);
        DBraiderConfigFieldsSBI.RunModal();
        Rec.CalcFields("Included Fields");
    end;

    procedure ShowFlowFieldList(Editable: Boolean)
    var
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Flow";
        SPBDBraiderConfFlowFields: Page "SPB DBraider Conf FlowFields";
    begin
        Rec.TestField("Source Table");

        SPBDBraiderConfLineFlow.SetRange("Config. Code", Rec."Config. Code");
        SPBDBraiderConfLineFlow.SetRange("Config. Line No.", Rec."Line No.");
        SPBDBraiderConfLineFlow.SetRange("Source Table No.", Rec."Source Table");
        SPBDBraiderConfFlowFields.Editable(Editable);
        SPBDBraiderConfFlowFields.SetTableView(SPBDBraiderConfLineFlow);
        SPBDBraiderConfFlowFields.RunModal();
    end;

    procedure CheckRelationshipConfigured()
    var
        DBRelation: Record "SPB DBraider ConfLine Relation";
        MissingInfo: Boolean;
    begin
        DBRelation.SetRange("Config. Code", Rec."Config. Code");
        DBRelation.SetRange("Config. Line No.", Rec."Line No.");
        if not DBRelation.IsEmpty then begin
            if DBRelation.FindSet(false) then
                repeat
                    MissingInfo := (DBRelation."Parent Field No." = 0) or (DBRelation."Child Field No." = 0);
                until DBRelation.Next() = 0
        end else
            MissingInfo := true;

        if MissingInfo then
            Rec."Relationship Configured" := false
        else
            Rec."Relationship Configured" := true;
        Rec.Modify(true);
    end;

    local procedure DeleteRelatedData()
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineRelation: Record "SPB DBraider ConfLine Relation";
    begin
        SPBDBraiderConfLineField.SetRange("Config. Code", Rec."Config. Code");
        SPBDBraiderConfLineField.SetRange("Config. Line No.", Rec."Line No.");
        SPBDBraiderConfLineField.DeleteAll(true);
        SPBDBraiderConfLineRelation.SetRange("Config. Code", Rec."Config. Code");
        SPBDBraiderConfLineRelation.SetRange("Config. Line No.", Rec."Line No.");
        SPBDBraiderConfLineRelation.DeleteAll(true);
        SPBDBraiderConfLineFlow.SetRange("Config. Code", Rec."Config. Code");
        SPBDBraiderConfLineFlow.SetRange("Config. Line No.", Rec."Line No.");
        SPBDBraiderConfLineFlow.DeleteAll(true);
    end;

    local procedure AttemptAutoMagicLink(ParentTableNo: Integer; SourceTable: Integer)
    var
        DBRelation: Record "SPB DBraider ConfLine Relation";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        FieldConnection: Dictionary of [Integer, Integer];
        NextRelLineNo: Integer;
        ParentField: Integer;
    begin

        // the relationships just changed, delete any auto-created links
        DBRelation.SetRange("Config. Code", Rec."Config. Code");
        DBRelation.SetRange("Config. Line No.", Rec."Line No.");
        DBRelation.SetRange("Manual Linking", false);
        DBRelation.DeleteAll();
        DBRelation.SetRange("Manual Linking");
        if DBRelation.FindLast() then
            NextRelLineNo := DBRelation."Relation Line No." + 10000
        else
            NextRelLineNo := 10000;

        //TODO: In a future version of BC, we should be able to get this data from a Virtual Table via a Codeunit, but not now
        FieldConnection := SPBDBraiderUtilities.AttemptToAutoRelate(ParentTableNo, SourceTable);
        foreach ParentField in FieldConnection.Keys() do begin
            DBRelation.Init();
            DBRelation."Config. Code" := Rec."Config. Code";
            DBRelation."Config. Line No." := Rec."Line No.";
            DBRelation."Relation Line No." := NextRelLineNo;
            NextRelLineNo += 10000;
            DBRelation."Parent Table" := ParentTableNo;
            DBRelation."Parent Field No." := ParentField;
            DBRelation."Child Table" := SourceTable;
            FieldConnection.Get(ParentField, DBRelation."Child Field No.");
            DBRelation."Manual Linking" := false;
            DBRelation.Insert(true);
        end;
    end;
}
