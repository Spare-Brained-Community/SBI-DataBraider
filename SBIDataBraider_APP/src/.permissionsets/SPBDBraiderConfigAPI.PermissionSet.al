permissionset 71033602 "SPB DBraider ConfAPI"
{
    Assignable = true;
    Caption = 'DataBraider Config API', MaxLength = 30;
    // Grants remote endpoint-authoring rights (config CRUD + schema introspection)
    // without full Manager access. SECURITY: holders of this set can configure
    // endpoints exposing ANY table their license/table permissions reach — assign
    // to trusted integration principals only.
    Permissions =
        tabledata "SPB DBraider Setup" = R,
        tabledata "SPB DBraider Config. Header" = RIMD,
        tabledata "SPB DBraider Config. Line" = RIMD,
        tabledata "SPB DBraider ConfLine Field" = RIMD,
        tabledata "SPB DBraider ConfLine Flow" = RIMD,
        tabledata "SPB DBraider ConfLine Relation" = RIMD,
        table "SPB DBraider Config. Header" = X,
        table "SPB DBraider Config. Line" = X,
        table "SPB DBraider ConfLine Field" = X,
        table "SPB DBraider ConfLine Flow" = X,
        table "SPB DBraider ConfLine Relation" = X,
        codeunit "SPB DBraider Schema JSON" = X,
        codeunit "SPB DBraider JSON Utilities" = X,
        codeunit "SPB DBraider Utilities" = X,
        page "SPB DBraider Config API" = X,
        page "SPB DBraider Config Line API" = X,
        page "SPB DBraider Conf Field API" = X,
        page "SPB DBraider Conf Rel API" = X,
        page "SPB DBraider Schema API" = X,
        page "SPB DBraider Tables API" = X,
        page "SPB DBraider Fields API" = X;
}
