enum 71033604 "SPB DBraider Endpoint Type"
{
    Extensible = true;

    value(0; "Read Only")
    {
        Caption = 'Read Only';
    }
    value(1; "Per Record")
    {
        Caption = 'Write - Per Record';
    }
    value(2; Batch)
    {
        Caption = 'Write - Batch Mode';
    }
    value(3; "Delta Read")
    {
        Caption = 'Delta Read';
    }

}
