query 71033600 "SPB DBraider Delta Cols"
{
    QueryType = Normal;

    elements
    {
        dataitem(DataItemName; "SPB DBraider Delta Col")
        {
            /*
            column(TopLevelSystemId; "Top-Level SystemId") { }
            column(SourceSystemId; "Source SystemId") { }
            column(SourceTable; "Source Table") { }
            */
            column(FQ_SystemId; "FQ SystemId") { }
            column(FieldNo; "Field No.") { }
            column(FieldClass; "Field Class") { }
            column(ValueAsText; "Value as Text") { }

            filter(ConfigCode; "Config. Code")
            {

            }
            filter(VersionNo; "Version No.")
            {

            }
        }
    }
}