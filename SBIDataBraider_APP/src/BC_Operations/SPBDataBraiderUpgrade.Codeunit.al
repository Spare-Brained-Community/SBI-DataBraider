codeunit 71033618 "SPB DataBraider Upgrade"
{
    Permissions = tabledata "SPB DBraider ConfLine Field" = M;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(v2d1ReasonLbl) then begin
            Performv2d1Upgrade();
            UpgradeTag.SetUpgradeTag(v2d1ReasonLbl);
        end;
    end;

    local procedure Performv2d1Upgrade()
    begin
        // Initialize isolated storage variables
        if not IsolatedStorage.Contains('Usage', DataScope::Module) then
            IsolatedStorage.Set('Usage', Format(0), DataScope::Module);
        if not IsolatedStorage.Contains('ReadEndpoint', DataScope::Module) then
            IsolatedStorage.Set('ReadEndpoint', Format(0), DataScope::Module);
        if not IsolatedStorage.Contains('WriteEndpoint', DataScope::Module) then
            IsolatedStorage.Set('WriteEndpoint', Format(0), DataScope::Module);

        UpdateFieldCaptions();
    end;

    internal procedure UpdateFieldCaptions()
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
    begin
        // For all the Config. Line Fields, we need to set the "Fixed" field values from the FlowFields
        SPBDBraiderConfLineField.SetAutoCalcFields("Field Name", Caption);
        if SPBDBraiderConfLineField.FindSet() then
            repeat
                SPBDBraiderConfLineField."Fixed Field Name" := SPBDBraiderConfLineField."Field Name";
                SPBDBraiderConfLineField."Fixed Field Caption" := SPBDBraiderConfLineField.Caption;
                SPBDBraiderConfLineField.Modify();
            until SPBDBraiderConfLineField.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(v2d1ReasonLbl);
    end;


    var
        v2d1ReasonLbl: Label 'SBI-V2.1-20240611', Locked = true;
}
