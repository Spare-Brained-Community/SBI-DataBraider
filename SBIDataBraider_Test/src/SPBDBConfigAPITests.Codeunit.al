codeunit 91100 "SPB DB Config API Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure EndpointTypeSetsCapabilityFlagsAndForcesFlat()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
    begin
        CreateHeader(ConfigHeader, 'T-CAPFLAGS', Enum::"SPB DBraider Endpoint Type"::"Per Record");

        Assert.IsTrue(ConfigHeader."Require PK", 'Per Record should set Require PK');
        Assert.IsTrue(ConfigHeader."Insert Allowed", 'Per Record should allow Insert');
        Assert.IsTrue(ConfigHeader."Modify Allowed", 'Per Record should allow Modify');
        Assert.IsTrue(ConfigHeader."Delete Allowed", 'Per Record should allow Delete');
        Assert.AreEqual(ConfigHeader."Output JSON Type"::Flat, ConfigHeader."Output JSON Type", 'Writeable endpoints must force Flat output');
    end;

    [Test]
    procedure ReadOnlyTypeClearsWriteFlags()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
    begin
        CreateHeader(ConfigHeader, 'T-READONLY', Enum::"SPB DBraider Endpoint Type"::"Read Only");

        Assert.IsFalse(ConfigHeader."Insert Allowed", 'Read Only must not allow Insert');
        Assert.IsFalse(ConfigHeader."Modify Allowed", 'Read Only must not allow Modify');
        Assert.IsFalse(ConfigHeader."Delete Allowed", 'Read Only must not allow Delete');
    end;

    [Test]
    procedure LineInsertAutoPopulatesFieldRows()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
        ConfigLine: Record "SPB DBraider Config. Line";
        ConfLineField: Record "SPB DBraider ConfLine Field";
    begin
        CreateHeader(ConfigHeader, 'T-FIELDS', Enum::"SPB DBraider Endpoint Type"::"Read Only");
        CreateLine(ConfigLine, ConfigHeader.Code, 10000, Database::Customer, 0);

        ConfLineField.SetRange("Config. Code", ConfigHeader.Code);
        ConfLineField.SetRange("Config. Line No.", ConfigLine."Line No.");
        Assert.IsTrue(ConfLineField.Count() > 50, 'Customer table should auto-populate many field rows');

        ConfLineField.SetRange("Field No.", 1);  // Customer."No." is PK field 1
        ConfLineField.FindFirst();
        Assert.IsTrue(ConfLineField."Primary Key", 'Field 1 (No.) should be flagged as Primary Key');
        Assert.IsFalse(ConfLineField.Included, 'Auto-populated fields start not Included');
    end;

    [Test]
    procedure IndentedLineResolvesParentAndAutoRelations()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
        HeaderLine: Record "SPB DBraider Config. Line";
        ChildLine: Record "SPB DBraider Config. Line";
        Relation: Record "SPB DBraider ConfLine Relation";
    begin
        CreateHeader(ConfigHeader, 'T-RELATE', Enum::"SPB DBraider Endpoint Type"::"Read Only");
        CreateLine(HeaderLine, ConfigHeader.Code, 10000, Database::"Sales Header", 0);
        CreateLine(ChildLine, ConfigHeader.Code, 20000, Database::"Sales Line", 1);

        Assert.AreEqual(Database::"Sales Header", ChildLine."Parent Table No.", 'UpdateParent should resolve the preceding less-indented line');

        Relation.SetRange("Config. Code", ConfigHeader.Code);
        Relation.SetRange("Config. Line No.", ChildLine."Line No.");
        Relation.SetRange("Manual Linking", false);
        Assert.IsFalse(Relation.IsEmpty(), 'Auto-magic linking should create relation rows for Sales Header -> Sales Line');

        ChildLine.CheckRelationshipConfigured();
        Assert.IsTrue(ChildLine."Relationship Configured", 'Relationship should be flagged configured after auto-linking');
    end;

    local procedure CreateHeader(var ConfigHeader: Record "SPB DBraider Config. Header"; NewCode: Code[20]; NewType: Enum "SPB DBraider Endpoint Type")
    begin
        if ConfigHeader.Get(NewCode) then
            ConfigHeader.Delete(true);
        ConfigHeader.Init();
        ConfigHeader.Code := NewCode;
        // Mirrors the API page's control order: type first, so capability flags get defaults
        ConfigHeader.Validate("Endpoint Type", NewType);
        ConfigHeader.Enabled := true;
        ConfigHeader.Insert(true);
    end;

    local procedure CreateLine(var ConfigLine: Record "SPB DBraider Config. Line"; ConfigCode: Code[20]; LineNo: Integer; TableNo: Integer; NewIndentation: Integer)
    begin
        ConfigLine.Init();
        ConfigLine."Config. Code" := ConfigCode;
        // Line No. must be set BEFORE Source Table validation for PopulateFieldList to run
        ConfigLine."Line No." := LineNo;
        ConfigLine.Validate("Source Table", TableNo);
        ConfigLine.Indentation := NewIndentation;
        ConfigLine.Insert(true);
        if NewIndentation > 0 then begin
            // The API line page drives this explicitly, same as the UI Move Right action
            ConfigLine.UpdateParent();
            ConfigLine.CheckRelationshipConfigured();
        end;
    end;
}
