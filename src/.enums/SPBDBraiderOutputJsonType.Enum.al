enum 71033603 "SPB DBraider Output Json Type" implements "SPB DBraider IDatasetToText"
{
    DefaultImplementation = "SPB DBraider IDatasetToText" = "SPB DBraid DStoJSON Hierarchy";
    Extensible = true;
    UnknownValueImplementation = "SPB DBraider IDatasetToText" = "SPB DBraid DStoJSON Hierarchy";

    value(0; Hierarchy)
    {
        Caption = 'Hierarchy';
        Implementation = "SPB DBraider IDatasetToText" = "SPB DBraid DStoJSON Hierarchy";
    }
    value(1; Flat)
    {
        Caption = 'Flat';
        Implementation = "SPB DBraider IDatasetToText" = "SPB DBraid DStoJSON Flat";
    }
}
