codeunit 71033601 "SPB DBraider Convert to JSON"
{
    InherentPermissions = X;
    ObsoleteReason = 'This codeunit is obsolete. Use the SPB DBraider Convert to JSON flat or heirarchical (default) codeunits instead.';
    ObsoleteState = Pending;

    [Obsolete('Use the SPB DBraider Convert to JSON flat or heirarchical (default) codeunits instead.')]
    procedure Convert(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary;
        var BaseResultCol: Record "SPB DBraider Resultset Col" temporary) ResultText: Text;
    begin
        exit(SPBDBraidDStoJSONHierarchy.ConvertToJSONText(BaseResultRow, BaseResultCol));
    end;

    [Obsolete('Use the SPB DBraider Convert to JSON flat or heirarchical (default) codeunits instead.')]
    procedure ProcessData() ResultText: Text;
    var
        JsonRows: JsonArray;
    begin
        JsonRows := SPBDBraidDStoJSONHierarchy.ProcessDataHierarchyToJson();
        JsonRows.WriteTo(ResultText);
        exit(ResultText);
    end;

    var
        SPBDBraidDStoJSONHierarchy: Codeunit "SPB DBraid DStoJSON Hierarchy";
}
