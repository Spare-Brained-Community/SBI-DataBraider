interface "SPB DBraider IDatasetToText"
{
    procedure ConvertToJSONText(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary) ResultText: Text;

    procedure ConvertToJSON(var BaseResultRow: Record "SPB DBraider Resultset Row" temporary; var BaseResultCol: Record "SPB DBraider Resultset Col" temporary) JsonRows: JsonArray;
}
