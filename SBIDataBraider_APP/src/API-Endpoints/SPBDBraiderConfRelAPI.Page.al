page 71033628 "SPB DBraider Conf Rel API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Endpoint Relation API';
    DelayedInsert = true;
    EntityCaption = 'Endpoint Relation';
    EntityName = 'endpointRelation';
    EntitySetName = 'endpointRelations';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "SPB DBraider ConfLine Relation";

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
                field(configLineNo; Rec."Config. Line No.")
                {
                    Caption = 'configLineNo', Locked = true;
                }
                field(relationLineNo; Rec."Relation Line No.")
                {
                    Caption = 'relationLineNo', Locked = true;
                    Editable = false;
                }
                field(parentTableNo; Rec."Parent Table")
                {
                    Caption = 'parentTableNo', Locked = true;
                    Editable = false;
                }
                field(childTableNo; Rec."Child Table")
                {
                    Caption = 'childTableNo', Locked = true;
                    Editable = false;
                }
                field(parentFieldNo; Rec."Parent Field No.")
                {
                    Caption = 'parentFieldNo', Locked = true;
                }
                field(parentFieldCaption; Rec."Parent Field Caption")
                {
                    Caption = 'parentFieldCaption', Locked = true;
                    Editable = false;
                }
                field(childFieldNo; Rec."Child Field No.")
                {
                    Caption = 'childFieldNo', Locked = true;
                }
                field(childFieldCaption; Rec."Child Field Caption")
                {
                    Caption = 'childFieldCaption', Locked = true;
                    Editable = false;
                }
                field(manualLinking; Rec."Manual Linking")
                {
                    Caption = 'manualLinking', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        OwningLine: Record "SPB DBraider Config. Line";
    begin
        OwningLine := GetOwningLine();
        // Parent/Child Table are Editable=false at table level (page input is blocked),
        // so the API derives them from the owning line in code.
        Rec."Parent Table" := OwningLine."Parent Table No.";
        Rec."Child Table" := OwningLine."Source Table";
        Rec."Manual Linking" := true;
        if Rec."Relation Line No." = 0 then
            Rec."Relation Line No." := NextRelationLineNo();
        Rec.Insert(true);
        OwningLine.CheckRelationshipConfigured();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        OwningLine: Record "SPB DBraider Config. Line";
    begin
        OwningLine := GetOwningLine();
        Rec.Modify(true);
        OwningLine.CheckRelationshipConfigured();
        exit(false);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        OwningLine: Record "SPB DBraider Config. Line";
    begin
        OwningLine := GetOwningLine();
        Rec.Delete(true);
        OwningLine.CheckRelationshipConfigured();
        exit(false);
    end;

    local procedure GetOwningLine(): Record "SPB DBraider Config. Line"
    var
        OwningLine: Record "SPB DBraider Config. Line";
    begin
        Rec.TestField("Config. Code");
        Rec.TestField("Config. Line No.");
        OwningLine.Get(Rec."Config. Code", Rec."Config. Line No.");
        exit(OwningLine);
    end;

    local procedure NextRelationLineNo(): Integer
    var
        DBRelation: Record "SPB DBraider ConfLine Relation";
    begin
        DBRelation.SetRange("Config. Code", Rec."Config. Code");
        DBRelation.SetRange("Config. Line No.", Rec."Config. Line No.");
        if DBRelation.FindLast() then
            exit(DBRelation."Relation Line No." + 10000);
        exit(10000);
    end;
}
