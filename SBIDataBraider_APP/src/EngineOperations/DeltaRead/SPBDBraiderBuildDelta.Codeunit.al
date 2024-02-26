codeunit 71033616 "SPB DBraider Build Delta"
{
    Access = Internal;

    procedure BuildDeltaTags(
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        var ResultRow: Record "SPB DBraider Resultset Row" temporary;
        var ResultCol: Record "SPB DBraider Resultset Col" temporary
    )
    var
        TempDeltaCol: Record "SPB DBraider Resultset Col" temporary;
        TempDeltaRow: Record "SPB DBraider Resultset Row" temporary;
    begin
        // Build the baseline to compare against
        LoadDeltaArchive(SPBDBraiderConfigHeader, TempDeltaRow, TempDeltaCol);

        // Now do the comparison work
        CompareDatasets(SPBDBraiderConfigHeader,
            ResultRow, ResultCol,
            TempDeltaRow, TempDeltaCol);
    end;

    internal procedure LoadDeltaArchive(
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        var TempDeltaRow: Record "SPB DBraider Resultset Row" temporary;
        var TempDeltaCol: Record "SPB DBraider Resultset Col" temporary
    )
    var
        SPBDBraiderDeltaCol: Record "SPB DBraider Delta Col";
        SPBDBraiderDeltaRow: Record "SPB DBraider Delta Row";
        LastVersionNo: Integer;
    begin
        LastVersionNo := FilterSPBDraiderDeltaRowToLatest(SPBDBraiderConfigHeader.Code, SPBDBraiderDeltaRow);

        SPBDBraiderDeltaRow.SetFilter("Delta Type", '<>%1', SPBDBraiderDeltaRow."Delta Type"::Deleted);
        if SPBDBraiderDeltaRow.FindSet() then
            repeat
                TempDeltaRow.TransferFields(SPBDBraiderDeltaRow);
                TempDeltaRow.Insert();
            until SPBDBraiderDeltaRow.Next() < 1;

        SPBDBraiderDeltaCol.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        SPBDBraiderDeltaCol.SetRange("Version No.", LastVersionNo);
        if SPBDBraiderDeltaCol.FindSet() then
            repeat
                TempDeltaCol.TransferFields(SPBDBraiderDeltaCol);
                TempDeltaCol.Insert();
            until SPBDBraiderDeltaCol.Next() < 1;
    end;

    internal procedure CompareDatasets
    (
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        var TempNewResultRow: Record "SPB DBraider Resultset Row" temporary;
        var TempNewResultCol: Record "SPB DBraider Resultset Col" temporary;
        var TempDeltaRow: Record "SPB DBraider Resultset Row" temporary;
        var TempDeltaCol: Record "SPB DBraider Resultset Col" temporary
    )
    var
        TempResultRow2: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        ArchiveColsFSQI: Dictionary of [Text, Text];
        NextRowNo: Integer;
        ArchiveKeyTok: Label '%1-%2-%3', Locked = true;  // FQSI, Field No, Field Class
        AddedRecordsFSQI: List of [Text];
        ArchiveResultRecordsFQSI: List of [Text];
        ArchiveResultRecordsFSQI: List of [Text];
        DeletedArchiveRecordsFSQI: List of [Text];
        DeletedRecordsFSQI: List of [Text];
        ModifiedRecordsFSQI: List of [Text];
        NewResultRecordsFQSI: List of [Text];
        NewResultRecordsFSQI: List of [Text];
        ToCheckRecordsFSQI: List of [Text];
        CompareTo: Text;
        TempIteratorText: Text;
    begin
        // What this will do is:
        // For each top level record in the ResultRow
        //   Check for matching top level record in the Delta archive
        //   if not found, mark the data as 'added'
        //   if found, check each field for changes, mark 'Modified' if Modified
        // Then, for Delta archive record, we need to check the ResultRow for any not found to note 'deleted'

        //SPBDBraiderDeltaRow.SetRange("Data Level", 10000);  //top level
        if TempDeltaRow.FindSet() then
            repeat
                SafeAdd(ArchiveResultRecordsFQSI, TempDeltaRow."FQ SystemId");
            until TempDeltaRow.Next() < 1;

        TempResultRow2.Copy(TempNewResultRow, true);

        //ResultRow.SetRange("Data Level", 10000);  //top level
        if TempNewResultRow.FindSet() then
            repeat
                NewResultRecordsFQSI.Add(TempNewResultRow."FQ SystemId")
            until TempNewResultRow.Next() < 1;

        // Now we have two lists of top level records, one from the ResultRow and one from the Delta archive
        // We can more quickly compare the two lists to find the added and deleted records
        foreach TempIteratorText in NewResultRecordsFSQI do
            if not ArchiveResultRecordsFSQI.Contains(TempIteratorText) then
                SafeAdd(AddedRecordsFSQI, TempIteratorText)
            else
                SafeAdd(ToCheckRecordsFSQI, TempIteratorText);

        foreach TempIteratorText in ArchiveResultRecordsFQSI do
            if not NewResultRecordsFQSI.Contains(TempIteratorText) then
                SafeAdd(DeletedRecordsFSQI, TempIteratorText);

        // We need to pop the Temp Column data into a couple of to-compare Dictionaries
        if TempDeltaCol.FindSet() then
            repeat
                if not ArchiveColsFSQI.ContainsKey(StrSubstNo(ArchiveKeyTok, TempDeltaCol."FQ SystemId", TempDeltaCol."Field No.", TempDeltaCol."Field Class")) then
                    ArchiveColsFSQI.Add(StrSubstNo(ArchiveKeyTok, TempDeltaCol."FQ SystemId", TempDeltaCol."Field No.", TempDeltaCol."Field Class"), TempDeltaCol."Value as Text");
                if not DeletedArchiveRecordsFSQI.Contains(TempDeltaCol."FQ SystemId") then
                    DeletedArchiveRecordsFSQI.Add(TempDeltaCol."FQ SystemId");
            until TempDeltaCol.Next() < 1;

        // Now to do change checking.
        TempNewResultRow.Reset();
        foreach TempIteratorText in ToCheckRecordsFSQI do begin
            TempNewResultCol.SetRange("FQ SystemId", TempIteratorText);
            if TempNewResultCol.FindSet() then
                repeat
                    if ArchiveColsFSQI.Get(StrSubstNo(ArchiveKeyTok, TempNewResultCol."FQ SystemId", TempNewResultCol."Field No.", TempNewResultCol."Field Class"), CompareTo) then
                        if CompareTo <> TempNewResultCol."Value as Text" then
                            // if the record and field is present, and the value is different, include the record, as
                            // well as if fields have changed
                            SafeAdd(ModifiedRecordsFSQI, TempNewResultCol."FQ SystemId");
                until TempNewResultCol.Next() < 1;
        end;

        // And now finally, for each of our Added and Modified records, we'll tag the rows with the Delta Type
        TempNewResultRow.Reset();
        foreach TempIteratorText in AddedRecordsFSQI do begin
            TempNewResultRow.SetRange("FQ SystemId", TempIteratorText);
            TempNewResultRow.ModifyAll("Delta Type", TempNewResultRow."Delta Type"::Added);
        end;
        foreach TempIteratorText in ModifiedRecordsFSQI do begin
            TempNewResultRow.SetRange("FQ SystemId", TempIteratorText);
            TempNewResultRow.ModifyAll("Delta Type", TempNewResultRow."Delta Type"::Modified);
        end;

        // Now, we need to create 'grave markers' of Deleted Records, just a single row with the Source SystemId, using the Archive to re-hydrate
        if TempNewResultRow.FindLast() then
            NextRowNo := TempNewResultRow."Row No." + 1
        else
            NextRowNo := 1;
        foreach TempIteratorText in DeletedRecordsFSQI do begin
            TempDeltaRow.SetRange("FQ SystemId", TempIteratorText);
            if TempDeltaRow.FindSet() then
                repeat
                    TempNewResultRow.Init();
                    TempNewResultRow."FQ SystemId" := CopyStr(TempIteratorText, 1, MaxStrLen(TempNewResultRow."FQ SystemId"));
                    if DeletedArchiveRecordsFSQI.Contains(TempIteratorText) then begin
                        TempNewResultRow."Top-Level SystemId" := TempDeltaRow."Top-Level SystemId";
                        // We need to note which Row this belongs to for Heirarchy building.  We can try to get the Parent via a trimmed FQSI
                        TempResultRow2.SetRange("FQ SystemId", SPBDBraiderUtilities.TrimFQSI(TempIteratorText));
                        if TempResultRow2.FindFirst() then begin
                            TempNewResultRow."Belongs To Row No." := TempResultRow2."Row No.";
                            // And while here, mark the parent as ChildUpdates if not already
                            if TempResultRow2."Delta Type" = TempResultRow2."Delta Type"::" " then begin
                                TempResultRow2."Delta Type" := TempResultRow2."Delta Type"::ChildUpdates;
                                TempResultRow2.Modify();
                            end;
                        end;
                    end;
                    TempNewResultRow."Delta Type" := TempNewResultRow."Delta Type"::Deleted;
                    TempNewResultRow."Data Level" := TempDeltaRow."Data Level";
                    TempNewResultRow."Source Table" := TempDeltaRow."Source Table";
                    TempNewResultRow."Source Table Name" := TempDeltaRow."Source Table Name";
                    TempNewResultRow."Config. Code" := SPBDBraiderConfigHeader.Code;
                    TempNewResultRow."Primary Key String" := TempDeltaRow."Primary Key String"; // in case using the BC PK
                    TempNewResultRow."Row No." := NextRowNo;
                    NextRowNo += 1;
                    TempNewResultRow.Insert();
                until TempDeltaRow.Next() < 1;
        end;
        TempNewResultRow.Reset();

        // But if it's a Child that was A/D/M, then we need to tag the top level as well
        TempNewResultRow.Reset();
        TempNewResultRow.SetRange("Data Level", 10000);  //top level
        if TempNewResultRow.FindSet() then
            repeat
                TempResultRow2.SetFilter("Data Level", '<>%1', 10000);  //top level
                TempResultRow2.SetRange("Top-Level SystemId", TempNewResultRow."Source SystemId");
                TempResultRow2.SetFilter("Delta Type", '<>%1', TempResultRow2."Delta Type"::" ");
                if not TempResultRow2.IsEmpty then begin
                    TempNewResultRow."Delta Type" := TempNewResultRow."Delta Type"::ChildUpdates;
                    TempNewResultRow.Modify();
                end;
            until TempNewResultRow.Next() < 1;
        TempNewResultRow.Reset();

    end;

    local procedure FilterSPBDraiderDeltaRowToLatest(
        ConfigCode: Code[20];
        var SPBDBraiderDeltaRow: Record "SPB DBraider Delta Row"): Integer
    begin
        SPBDBraiderDeltaRow.SetRange("Config. Code", ConfigCode);
        if SPBDBraiderDeltaRow.FindLast() then begin
            SPBDBraiderDeltaRow.SetRange("Version No.", SPBDBraiderDeltaRow."Version No.");
            exit(SPBDBraiderDeltaRow."Version No.");
        end;
    end;

    local procedure SafeAdd(DestDict: List of [Guid]; NewValue: Guid)
    begin
        if not DestDict.Contains(NewValue) then
            DestDict.Add(NewValue);
    end;

    local procedure SafeAdd(DestDict: List of [Text]; NewValue: Text)
    begin
        if not DestDict.Contains(NewValue) then
            DestDict.Add(NewValue);
    end;
}