page 71033626 "SPB DBraider Config Line API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Endpoint Line API';
    DelayedInsert = true;
    EntityCaption = 'Endpoint Line';
    EntityName = 'endpointLine';
    EntitySetName = 'endpointLines';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "SPB DBraider Config. Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(configCode; Rec."Config. Code")
                {
                    Caption = 'configCode', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'lineNo', Locked = true;
                }
                field(sourceTable; Rec."Source Table")
                {
                    Caption = 'sourceTable', Locked = true;
                }
                field(sourceTableName; Rec."Source Table Name")
                {
                    Caption = 'sourceTableName', Locked = true;
                    Editable = false;
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'indentation', Locked = true;
                }
                field(parentTableNo; Rec."Parent Table No.")
                {
                    Caption = 'parentTableNo', Locked = true;
                    Editable = false;
                }
                field(relationType; Rec."Relation Type")
                {
                    Caption = 'relationType', Locked = true;
                }
                field(relationOperation; Rec."Relation Operation")
                {
                    Caption = 'relationOperation', Locked = true;
                }
                field(relationshipConfigured; Rec."Relationship Configured")
                {
                    Caption = 'relationshipConfigured', Locked = true;
                    Editable = false;
                }
                field(fieldCount; Rec."Field Count")
                {
                    Caption = 'fieldCount', Locked = true;
                    Editable = false;
                }
                field(includedFields; Rec."Included Fields")
                {
                    Caption = 'includedFields', Locked = true;
                    Editable = false;
                }
                part(fields; "SPB DBraider Conf Field API")
                {
                    Caption = 'Fields', Locked = true;
                    EntityName = 'endpointField';
                    EntitySetName = 'endpointFields';
                    SubPageLink = "Config. Code" = field("Config. Code"), "Config. Line No." = field("Line No.");
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("Source Table");
        // Assign the Line No. before Insert so the table's OnInsert trigger can
        // auto-populate the ConfLine Field rows (it requires a non-zero Line No.).
        if Rec."Line No." = 0 then
            Rec."Line No." := NextLineNo();
        ValidateIndentation();
        Rec.Insert(true);
        if Rec.Indentation > 0 then begin
            // In the UI this happens via the Move Right action; the API must drive it explicitly.
            Rec.UpdateParent();
            Rec.CheckRelationshipConfigured();
        end;
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Indentation <> xRec.Indentation then begin
            ValidateIndentation();
            Rec.UpdateParent();
            Rec.CheckRelationshipConfigured();
        end;
        exit(true);
    end;

    [ServiceEnabled]
    procedure includeFields(fieldNumbers: Text)
    begin
        SetFieldsIncluded(fieldNumbers, true);
    end;

    [ServiceEnabled]
    procedure excludeFields(fieldNumbers: Text)
    begin
        SetFieldsIncluded(fieldNumbers, false);
    end;

    local procedure SetFieldsIncluded(fieldNumbers: Text; NewIncluded: Boolean)
    var
        DBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        FieldNoInt: Integer;
        FieldNoText: Text;
        InvalidFieldNoErr: Label 'Invalid field number ''%1''. Provide a comma-separated list of field numbers, e.g. ''1,2,20''.', Comment = '%1 = the list entry that could not be interpreted as a field number';
    begin
        foreach FieldNoText in fieldNumbers.Split(',') do begin
            if not Evaluate(FieldNoInt, FieldNoText.Trim()) then
                Error(InvalidFieldNoErr, FieldNoText);
            DBraiderConfLineField.Get(Rec."Config. Code", Rec."Line No.", FieldNoInt);
            DBraiderConfLineField.Validate(Included, NewIncluded);
            DBraiderConfLineField.Modify(true);
        end;
    end;

    local procedure NextLineNo(): Integer
    var
        DBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        DBraiderConfigLine.SetRange("Config. Code", Rec."Config. Code");
        if DBraiderConfigLine.FindLast() then
            exit(DBraiderConfigLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure ValidateIndentation()
    var
        PrevLine: Record "SPB DBraider Config. Line";
        IndentationJumpErr: Label 'Indentation %1 is not valid here: the previous line has indentation %2, so at most %3 is allowed.', Comment = '%1 = requested indentation, %2 = previous line indentation, %3 = previous line indentation + 1';
        NoParentLineErr: Label 'Indentation greater than zero requires a preceding line to act as the parent.';
    begin
        if Rec.Indentation <= 0 then
            exit;
        PrevLine.SetRange("Config. Code", Rec."Config. Code");
        PrevLine.SetFilter("Line No.", '<%1', Rec."Line No.");
        if not PrevLine.FindLast() then
            Error(NoParentLineErr);
        if Rec.Indentation > PrevLine.Indentation + 1 then
            Error(IndentationJumpErr, Rec.Indentation, PrevLine.Indentation, PrevLine.Indentation + 1);
    end;
}
