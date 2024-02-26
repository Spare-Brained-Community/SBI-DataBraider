report 71033600 "SPB DBraider Copy Config From"
{
    ApplicationArea = All;
    Caption = 'Copy Endpoint Configuration From';
    ProcessingOnly = true;
    UsageCategory = None;

    internal procedure CopyLinesFromOtherConfig(SPBDBraiderConfigHeaderDestination: Record "SPB DBraider Config. Header")
    var
        ConfigHeaderFrom: Record "SPB DBraider Config. Header";
        ConfigLinesFrom: Record "SPB DBraider Config. Line";
        ConfigLinesTo: Record "SPB DBraider Config. Line";
        ConfigFieldsFrom: Record "SPB DBraider ConfLine Field";
        ConfigFieldsTo: Record "SPB DBraider ConfLine Field";
        ConfigFlowsFrom: Record "SPB DBraider ConfLine Flow";
        ConfigFlowsTo: Record "SPB DBraider ConfLine Flow";
        ConfigRelFrom: Record "SPB DBraider ConfLine Relation";
        ConfigRelTo: Record "SPB DBraider ConfLine Relation";
        ConfigLinesList: Page "SPB DBraider Configurations";
        FilterOnConfHeaderCodeLbl: Label '<>%1', Comment = '%1 = DBraider Config Header Code';
    begin
        if SPBDBraiderConfigHeaderDestination.HasExistingLines() and not Confirm('You have existing lines on this Configuration, which will be deleted and replaced. Continue?', true) then
            exit
        else begin
            ConfigLinesTo.SetRange("Config. Code", SPBDBraiderConfigHeaderDestination.Code);
            ConfigLinesTo.DeleteAll(true);
            ConfigLinesTo.Reset();
            Commit();
        end;

        ConfigHeaderFrom.SetFilter(Code, StrSubstNo(FilterOnConfHeaderCodeLbl, SPBDBraiderConfigHeaderDestination.Code));
        ConfigLinesList.SetTableView(ConfigHeaderFrom);
        ConfigLinesList.LookupMode(true);
        if ConfigLinesList.RunModal() in [Action::LookupOK, Action::OK] then begin
            ConfigLinesList.GetRecord(ConfigHeaderFrom);

            // Lines
            ConfigLinesFrom.SetRange("Config. Code", ConfigHeaderFrom.Code);
            if ConfigLinesFrom.FindSet() then
                repeat
                    ConfigLinesTo := ConfigLinesFrom;
                    ConfigLinesTo."Config. Code" := SPBDBraiderConfigHeaderDestination.Code;
                    ConfigLinesTo.Insert(true);
                until ConfigLinesFrom.Next() = 0;

            // Relationships
            ConfigRelFrom.SetRange("Config. Code", ConfigHeaderFrom.Code);
            if ConfigRelFrom.FindSet() then
                repeat
                    ConfigRelTo := ConfigRelFrom;
                    ConfigRelTo."Config. Code" := SPBDBraiderConfigHeaderDestination.Code;
                    ConfigRelTo.Insert(true);
                until ConfigRelFrom.Next() = 0;

            // Fields
            ConfigFieldsFrom.SetRange("Config. Code", ConfigHeaderFrom.Code);
            if ConfigFieldsFrom.FindSet() then
                repeat
                    if not ConfigFieldsTo.Get(SPBDBraiderConfigHeaderDestination.Code, ConfigFieldsFrom."Config. Line No.", ConfigFieldsFrom."Field No.") then begin
                        ConfigFieldsTo := ConfigFieldsFrom;
                        //Update the PKs
                        ConfigFieldsTo."Config. Code" := SPBDBraiderConfigHeaderDestination.Code;
                        ConfigFieldsTo."Config. Line No." := ConfigFieldsFrom."Config. Line No.";
                        ConfigFieldsTo.Insert(true);
                    end;
                    ConfigFieldsTo.TransferFields(ConfigFieldsFrom, false);
                    ConfigFieldsTo.Validate("Field No.");
                    ConfigFieldsTo.Modify(true);  // Funky thing here, it may already exist, we're overwriting it

                until ConfigFieldsFrom.Next() = 0;

            // Flows
            ConfigFlowsFrom.SetRange("Config. Code", ConfigHeaderFrom.Code);
            if ConfigFlowsFrom.FindSet() then
                repeat
                    ConfigFlowsTo := ConfigFlowsFrom;
                    ConfigFlowsTo."Config. Code" := SPBDBraiderConfigHeaderDestination.Code;
                    ConfigFlowsTo.Insert(true);
                until ConfigFlowsFrom.Next() = 0;
        end;

        Message('Configuration copied successfully.');
    end;
}
