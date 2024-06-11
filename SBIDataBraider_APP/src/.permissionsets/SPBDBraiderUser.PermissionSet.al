permissionset 71033601 "SPB DBraider User"
{
    Assignable = true;
    Caption = 'DataBraider User';

    Permissions =
        tabledata "SPB DBraider Setup" = R,
        tabledata "SPB DBraider Config. Header" = R,
        tabledata "SPB DBraider Config. Line" = R,
        tabledata "SPB DBraider ConfLine Field" = R,
        tabledata "SPB DBraider ConfLine Flow" = R,
        tabledata "SPB DBraider ConfLine Relation" = R,
        tabledata "SPB DBraider Resultset Col" = RIMD,
        tabledata "SPB DBraider Resultset Row" = RIMD,
        tabledata "SPB DBraider Filters" = RIMD,
        tabledata "SPB DBraider Usage" = RIM,
        tabledata "SPB DBraider Endpoint Log" = RIMD,
        tabledata "SPB DBraider Result Buffer" = RIMD,
        tabledata "SPB DBraider Env Variable" = R,
        tabledata "SPBDBraider Event Notification" = RIMD;
}