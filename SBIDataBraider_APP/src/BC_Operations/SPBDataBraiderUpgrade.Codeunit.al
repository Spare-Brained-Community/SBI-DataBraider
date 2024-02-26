codeunit 71033618 "SPB DataBraider Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
        InitIsoVars();
    end;

    local procedure InitIsoVars()

    begin
        if not IsolatedStorage.Contains('Usage', DataScope::Module) then
            IsolatedStorage.Set('Usage', Format(0), DataScope::Module);
        if not IsolatedStorage.Contains('ReadEndpoint', DataScope::Module) then
            IsolatedStorage.Set('ReadEndpoint', Format(0), DataScope::Module);
        if not IsolatedStorage.Contains('WriteEndpoint', DataScope::Module) then
            IsolatedStorage.Set('WriteEndpoint', Format(0), DataScope::Module);
    end;
}
