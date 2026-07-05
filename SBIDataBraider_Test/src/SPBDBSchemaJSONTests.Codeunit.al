codeunit 91101 "SPB DB Schema JSON Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure ReadItemSchemaEmitsIncludedFieldsWithTypesAndRequired()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderSchemaJSON: Codeunit "SPB DBraider Schema JSON";
        PropsToken: JsonToken;
        PropToken: JsonToken;
        ValueToken: JsonToken;
        RequiredToken: JsonToken;
        Schema: JsonObject;
        PropObj: JsonObject;
    begin
        BuildCustomerConfig(ConfigHeader, 'T-SCHEMA-R');

        Schema := SPBDBraiderSchemaJSON.ReadItemSchema(ConfigHeader);

        Assert.IsTrue(Schema.Get('properties', PropsToken), 'schema must have properties');
        // Customer."No." (field 1, PK, mandatory) -> property "Customer.No"
        Assert.IsTrue(PropsToken.AsObject().Get('Customer.No', PropToken), 'Customer.No must be present');
        PropObj := PropToken.AsObject();
        PropObj.Get('type', ValueToken);
        Assert.AreEqual('string', ValueToken.AsValue().AsText(), 'Code fields map to string');
        PropObj.Get('x-spb-fieldNo', ValueToken);
        Assert.AreEqual(1, ValueToken.AsValue().AsInteger(), 'x-spb-fieldNo carries the field number');
        PropObj.Get('x-spb-primaryKey', ValueToken);
        Assert.IsTrue(ValueToken.AsValue().AsBoolean(), 'x-spb-primaryKey flags PK fields');

        // "Credit Limit (LCY)" (field 20, Decimal) -> "Customer.CreditLimitLCY", type number
        Assert.IsTrue(PropsToken.AsObject().Get('Customer.CreditLimitLCY', PropToken), 'JSON-safe name strips punctuation');
        PropToken.AsObject().Get('type', ValueToken);
        Assert.AreEqual('number', ValueToken.AsValue().AsText(), 'Decimal fields map to number');

        Assert.IsTrue(Schema.Get('required', RequiredToken), 'mandatory fields populate required[]');
        Assert.AreEqual(1, RequiredToken.AsArray().Count(), 'exactly one mandatory field');
    end;

    [Test]
    procedure WriteBodySchemaFiltersToWriteEnabledFields()
    var
        ConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderSchemaJSON: Codeunit "SPB DBraider Schema JSON";
        PropsToken: JsonToken;
        PropToken: JsonToken;
        Schema: JsonObject;
    begin
        BuildCustomerConfig(ConfigHeader, 'T-SCHEMA-W');

        Schema := SPBDBraiderSchemaJSON.WriteBodySchema(ConfigHeader);

        Assert.IsTrue(Schema.Get('properties', PropsToken), 'schema must have properties');
        Assert.IsTrue(PropsToken.AsObject().Get('Customer.No', PropToken), 'write-enabled Customer.No included');
        Assert.IsFalse(PropsToken.AsObject().Get('Customer.CreditLimitLCY', PropToken), 'non-write-enabled fields are excluded from the write schema');
    end;

    local procedure BuildCustomerConfig(var ConfigHeader: Record "SPB DBraider Config. Header"; NewCode: Code[20])
    var
        ConfigLine: Record "SPB DBraider Config. Line";
        ConfLineField: Record "SPB DBraider ConfLine Field";
    begin
        if ConfigHeader.Get(NewCode) then
            ConfigHeader.Delete(true);
        ConfigHeader.Init();
        ConfigHeader.Code := NewCode;
        ConfigHeader.Validate("Endpoint Type", Enum::"SPB DBraider Endpoint Type"::"Per Record");
        ConfigHeader.Enabled := true;
        ConfigHeader.Insert(true);

        ConfigLine.Init();
        ConfigLine."Config. Code" := NewCode;
        ConfigLine."Line No." := 10000;
        ConfigLine.Validate("Source Table", Database::Customer);
        ConfigLine.Insert(true);

        // Customer."No." — included, write-enabled (auto: writeable config), mandatory
        ConfLineField.Get(NewCode, ConfigLine."Line No.", 1);
        ConfLineField.Validate(Included, true);
        ConfLineField.Validate(Mandatory, true);
        ConfLineField.Modify(true);

        // Customer."Credit Limit (LCY)" (20, Decimal) — included but NOT write-enabled
        ConfLineField.Get(NewCode, ConfigLine."Line No.", 20);
        ConfLineField.Validate(Included, true);
        ConfLineField."Write Enabled" := false;
        ConfLineField.Modify(true);
    end;
}
