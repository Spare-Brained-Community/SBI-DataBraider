codeunit 71033603 "SPB DBraider Licensing"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Data Braider is now a free, unlicensed product. Licensing checks are no longer required.';
    ObsoleteTag = '2.3.0.0';

    [Obsolete('Data Braider is now a free, unlicensed product. Licensing checks are no longer required.', '2.3.0.0')]
    procedure CheckIfActive(InactiveShowError: Boolean): Boolean
    begin
        exit(true);
    end;

    [Obsolete('Data Braider is now a free, unlicensed product. Licensing checks are no longer required.', '2.3.0.0')]
    internal procedure CheckIfUsageBased(InactiveShowError: Boolean): Boolean
    begin
        exit(false);
    end;

    [Obsolete('Data Braider is now a free, unlicensed product. Licensing checks are no longer required.', '2.3.0.0')]
    procedure IsDemoInstall(): Boolean
    begin
        exit(false);
    end;
}
