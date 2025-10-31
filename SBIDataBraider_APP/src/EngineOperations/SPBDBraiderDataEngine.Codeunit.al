codeunit 71033600 "SPB DBraider Data Engine"
{
    Permissions = tabledata "SPB DBraider Config. Header" = rm,
        tabledata "SPB DBraider Usage" = rim;

    var
        // Yup, no dynamic arrays, I hope 100 records of indentation depth covers us!
        BreadcrumbRecordConfigLine: array[100] of Record "SPB DBraider Config. Line";
        TempSPBDBraiderFilters: Record "SPB DBraider Filters" temporary;
        TempSPBDBraiderResultsetCol: Record "SPB DBraider Resultset Col" temporary;
        TempSPBDBraiderResultsetRow: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderSetup: Record "SPB DBraider Setup";
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
        BreadcrumbRecordRefArray: array[100] of RecordRef;
        RunForSpecificRecordRef: RecordRef;
        PageSize: Integer;
        StartFromPage: Integer;
        TopLevelRecordCount: Integer;
        FilterJson: Text;

    procedure GenerateData(ConfigCode: Code[20])
    var
        DBHeader: Record "SPB DBraider Config. Header";
        DBLine: Record "SPB DBraider Config. Line";
        DBLine2: Record "SPB DBraider Config. Line";
        DBField: Record "SPB DBraider ConfLine Field";
        TempSPBDBraiderResultsetRowTopLevel: Record "SPB DBraider Resultset Row" temporary;
        SPBDBraiderBuildDelta: Codeunit "SPB DBraider Build Delta";
        ParentLineRef: RecordRef;
        RunDuration: Duration;
        NextRowNo: Integer;
        EndTime: Time;
        StartTime: Time;
    begin
        SPBDBraiderSetup.GetRecordOnce();

        DBHeader.Get(ConfigCode);
        InitializePagination(DBHeader);
        DBLine.SetRange("Config. Code", ConfigCode);
        DBLine2.SetRange("Config. Code", ConfigCode);
        DBField.SetRange("Config. Code", ConfigCode);

        if DBHeader."Endpoint Type" in [DBHeader."Endpoint Type"::"Read Only", DBHeader."Endpoint Type"::"Delta Read"] then
            SPBDBraiderEvents.OnBeforeGenerateData(DBHeader, FilterJson);

        ValidateConfig(DBHeader);

        NextRowNo := 1;

        // Check for pagination settings
        if PageSize = 0 then
            PageSize := SPBDBraiderSetup."Default Page Size";

        StartTime := Time();
        DBLine.SetRange(Indentation, 0);
        // For each base level Line, generate the data!
        if DBLine.FindSet(false) then
            repeat
                AddDataFromConfigLine(TempSPBDBraiderResultsetRowTopLevel, DBHeader, DBLine, NextRowNo, ParentLineRef);
            until DBLine.Next() = 0;

        if RunForSpecificRecordRef.Number() <> 0 then
            MarkInclusionRecords();

        EndTime := Time();
        RunDuration := EndTime - StartTime;
        DBHeader."Last Run Duration" := RunDuration;
        DBHeader.Modify(true);
        if DBHeader."Endpoint Type" = DBHeader."Endpoint Type"::"Delta Read" then begin
            DBHeader.CalcFields("Has Archive Data");
            if DBHeader."Has Archive Data" then
                SPBDBraiderBuildDelta.BuildDeltaTags(DBHeader, TempSPBDBraiderResultsetRow, TempSPBDBraiderResultsetCol);

            // Delta read support - we have to have the snapshot *before* we cull it for delta results
            if DBHeader."Data Archive Versions" <> 0 then
                ArchiveDataset(DBHeader);
            // And now, before we sent the data off elsewhere, remove unchanged entries
            TempSPBDBraiderResultsetRow.SetRange("Delta Type", Enum::"SPB DBraider Delta Type"::" ");
            //TempSPBDBraiderResultsetRow.DeleteAll();
            TempSPBDBraiderResultsetRow.Reset();
        end;

        DBHeader.RegisterReadUsage(TempSPBDBraiderResultsetRow.Count());
        SPBDBraiderEvents.OnAfterGenerateData(DBHeader, TempSPBDBraiderResultsetRow, TempSPBDBraiderResultsetCol);
    end;

    procedure GenerateRecordData(ConfigCode: Code[20]; var newFilterRecordRef: RecordRef)
    begin
        RunForSpecificRecordRef := newFilterRecordRef;
        GenerateData(ConfigCode);
    end;

    procedure ValidateConfig(DBHeader: Record "SPB DBraider Config. Header")
    begin
        // This used to check for relationship configuration, but that is now optional, as it may be needed for flowfiltering
    end;

    /// <summary>
    /// A way of fetching the results of a data generation run, which is a pair of tables containing the rows and columns
    /// </summary>
    /// <param name="ResultRow">Temporary Record of the Resultset Row</param>
    /// <param name="ResultCol">Temporary Record of the Resultset Col</param>
    procedure GetResults(var ResultRow: Record "SPB DBraider Resultset Row" temporary;
        var ResultCol: Record "SPB DBraider Resultset Col" temporary)
    begin
        if TempSPBDBraiderResultsetRow.FindSet() then
            repeat
                ResultRow.TransferFields(TempSPBDBraiderResultsetRow);
                ResultRow.Insert();
            until TempSPBDBraiderResultsetRow.Next() = 0;

        if TempSPBDBraiderResultsetCol.FindSet() then
            repeat
                ResultCol.TransferFields(TempSPBDBraiderResultsetCol);
                ResultCol.Insert();
            until TempSPBDBraiderResultsetCol.Next() = 0;
    end;

    local procedure AddLineColumns(
        var DBField: Record "SPB DBraider ConfLine Field";
        var LineRef: RecordRef;
        var NextColNo: Integer;
        TopLevelRecordId: Guid
        )
    var
        VirtualField: Record Field;
        DBHeader: Record "SPB DBraider Config. Header";
        TempSPBDBraiderResultsetCol2: Record "SPB DBraider Resultset Col" temporary;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TypeHelper: Codeunit "Type Helper";
        RelatedTableRef: RecordRef;
        FldRef: FieldRef;
        RelatedTableFieldRef: FieldRef;
        RelatedTableSystemIdFieldRef: FieldRef;
        ThisDateTime: DateTime;
        RelatedTablePrimaryKeyFields: List of [Integer];
    begin
        DBField.SetRange(Included, true);
        if DBField.FindSet(false) then begin
            DBHeader.Get(DBField."Config. Code");
            repeat
                FldRef := LineRef.Field(DBField."Field No.");
                if FldRef.Class() = FieldClass::FlowField then
                    FldRef.CalcField();

                TempSPBDBraiderResultsetCol.Init();
                TempSPBDBraiderResultsetCol."Row No." := TempSPBDBraiderResultsetRow."Row No.";
                TempSPBDBraiderResultsetCol."Column No." := NextColNo;
                NextColNo += 1;
                TempSPBDBraiderResultsetCol."Field No." := FldRef.Number();
                TempSPBDBraiderResultsetCol."Field Name" := CopyStr(FldRef.Name(), 1, MaxStrLen(TempSPBDBraiderResultsetCol."Field Name"));
                if DBField."Manual Field Caption" <> '' then
                    TempSPBDBraiderResultsetCol."Forced Field Caption" := DBField."Manual Field Caption";
                TempSPBDBraiderResultsetCol."Value as Text" := Format(FldRef.Value());
                TempSPBDBraiderResultsetCol."Source SystemId" := LineRef.Field(LineRef.SystemIdNo()).Value();
                TempSPBDBraiderResultsetCol."Source Table" := LineRef.Number();
                TempSPBDBraiderResultsetCol."Field Class" := DBField."Field Class";
                if IsNullGuid(TopLevelRecordId) then
                    TempSPBDBraiderResultsetCol."Top-Level SystemId" := TempSPBDBraiderResultsetRow."Source SystemId"
                else
                    TempSPBDBraiderResultsetCol."Top-Level SystemId" := TopLevelRecordId;
                TempSPBDBraiderResultsetCol."FQ SystemId" := TempSPBDBraiderResultsetRow."FQ SystemId";
                if DBField."Field Class" = Format(FieldClass::FlowField) then
                    TempSPBDBraiderResultsetCol."Source SystemId" := TempSPBDBraiderResultsetRow."Source SystemId";  // For flowfields, they "belong" to the current record

                TempSPBDBraiderResultsetCol."Data Type" := SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FldRef.Type());
                case TempSPBDBraiderResultsetCol."Data Type" of
                    Enum::"SPB DBraider Field Data Type"::Boolean:
                        TempSPBDBraiderResultsetCol.BooleanCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Code:
                        TempSPBDBraiderResultsetCol.CodeCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Date:
                        TempSPBDBraiderResultsetCol.DateCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Time:
                        TempSPBDBraiderResultsetCol.TimeCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Datetime:
                        begin
                            ThisDateTime := FldRef.Value();
                            if DBField."DateTime Timezone" <> '' then
                                ThisDateTime := TypeHelper.ConvertDateTimeFromUTCToTimeZone(ThisDateTime, DBField."DateTime Timezone");
                            TempSPBDBraiderResultsetCol.DatetimeCell := ThisDateTime;
                            // Reassign this value in case we've adjusted it for timezone
                            TempSPBDBraiderResultsetCol."Value as Text" := Format(FldRef);
                        end;
                    Enum::"SPB DBraider Field Data Type"::Decimal:
                        TempSPBDBraiderResultsetCol.NumberCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Integer:
                        TempSPBDBraiderResultsetCol.NumberCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Option:
                        TempSPBDBraiderResultsetCol.NumberCell := FldRef.Value();
                    Enum::"SPB DBraider Field Data Type"::Guid:
                        TempSPBDBraiderResultsetCol.GuidCell := FldRef.Value();
                end;
                TempSPBDBraiderResultsetCol."Write Result Record" := (RunForSpecificRecordRef.Number() <> 0) and (RunForSpecificRecordRef.Number() = LineRef.Number());
                TempSPBDBraiderResultsetCol.Insert(true);

                if (not SPBDBraiderSetup."Disable Related Id") then begin //or (not DBHeader."Disable Related Id") then begin
                    VirtualField.Get(LineRef.Number(), FldRef.Number());
                    if VirtualField.RelationTableNo <> 0 then begin
                        RelatedTableRef.Open(VirtualField.RelationTableNo);
                        if VirtualField.RelationFieldNo <> 0 then
                            RelatedTableFieldRef := RelatedTableRef.Field(VirtualField.RelationFieldNo)
                        else begin
                            RelatedTablePrimaryKeyFields := SPBDBraiderUtilities.GetPrimaryKeyFields(RelatedTableRef);
                            RelatedTableFieldRef := RelatedTableRef.Field(RelatedTablePrimaryKeyFields.Get(RelatedTablePrimaryKeyFields.Count()));
                        end;
                        RelatedTableFieldRef.SetRange(Format(FldRef.Value()));
                        RelatedTableSystemIdFieldRef := RelatedTableRef.Field(RelatedTableRef.SystemIdNo());
                        if RelatedTableRef.FindFirst() then begin
                            // we'll add the Id version of the field to the columns dataset
                            TempSPBDBraiderResultsetCol2 := TempSPBDBraiderResultsetCol;
                            TempSPBDBraiderResultsetCol2."Data Type" := Enum::"SPB DBraider Field Data Type"::RelatedId;
                            TempSPBDBraiderResultsetCol2."Column No." := NextColNo - 1 + 1900000000;
                            TempSPBDBraiderResultsetCol2."Value as Text" := CopyStr(Format(RelatedTableSystemIdFieldRef.Value(), 0, 4).ToLower(), 1, MaxStrLen(TempSPBDBraiderResultsetCol2."Value as Text"));
                            TempSPBDBraiderResultsetCol2.GuidCell := RelatedTableSystemIdFieldRef.Value();
                            TempSPBDBraiderResultsetCol := TempSPBDBraiderResultsetCol2;
                            TempSPBDBraiderResultsetCol.Insert(true);
                        end;
                        RelatedTableRef.Close();
                    end;
                end;
            until DBField.Next() = 0;
        end;
        DBField.SetRange("Filter");
    end;

    local procedure AddDataFromConfigLine(
        TempSPBDBraiderResultsetRowTopLevel: Record "SPB DBraider Resultset Row" temporary;
        var DBHeader: Record "SPB DBraider Config. Header";
        var DBLine: Record "SPB DBraider Config. Line";
        var NextRowNo: Integer;
        var ParentLineRef: RecordRef)
    var
        DBChildLine: Record "SPB DBraider Config. Line";
        DBField: Record "SPB DBraider ConfLine Field";
        DBRelation: Record "SPB DBraider ConfLine Relation";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        SPBDBLicensing: Codeunit "SPB DBraider Licensing";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        LineRef: RecordRef;
        FldRef: FieldRef;
        ParentFldRef: FieldRef;
        IsDemoInstall: Boolean;
        PageSizeLimitReached: Boolean;
        i: Integer;
        NextColumnNo: Integer;
        SkipUntilRecord: Integer;
        ProcessedFilterText: Text;
    begin
        IsDemoInstall := SPBDBLicensing.IsDemoInstall();

        DBLine.CalcFields("Source Table Name");
        DBField.SetRange("Config. Code", DBLine."Config. Code");
        DBField.SetRange("Config. Line No.", DBLine."Line No.");

        // Get the table
        LineRef.Open(DBLine."Source Table");

        // Check for config filtering to apply (if any)
        DBField.SetFilter("Filter", '<>''''');
        if DBField.FindSet(false) then
            repeat
                FldRef := LineRef.Field(DBField."Field No.");
                ProcessedFilterText := DBField.Filter;
                SPBDBraiderUtilities.VariableSubstitution(ProcessedFilterText);
                FldRef.SetFilter(ProcessedFilterText);
            until DBField.Next() = 0;
        DBField.SetRange("Filter");

        // Check if we need to apply extra filters applied from external calls
        if RunForSpecificRecordRef.Number() = LineRef.Number() then begin
            LineRef.FilterGroup(10);
            CopyFiltersFromRecRefToRecRef(RunForSpecificRecordRef, LineRef);
            LineRef.FilterGroup(0);
        end;

        // Check for any API driven filter to apply (if any)
        TempSPBDBraiderFilters.SetRange("Table No.", DBLine."Source Table");
        if TempSPBDBraiderFilters.FindSet() then
            repeat
                // Filter group so they 'stack' with built-in ones
                LineRef.FilterGroup(11);
                FldRef := LineRef.Field(TempSPBDBraiderFilters."Field No.");
                ProcessedFilterText := TempSPBDBraiderFilters."Filter Text";
                SPBDBraiderUtilities.VariableSubstitution(ProcessedFilterText);
                FldRef.SetFilter(ProcessedFilterText);
                LineRef.FilterGroup(0);
            until TempSPBDBraiderFilters.Next() = 0;

        // If this Line is a Child of a table, apply the link/filter
        if DBLine."Parent Table No." <> 0 then begin
            DBRelation.SetRange("Config. Code", DBLine."Config. Code");
            DBRelation.SetRange("Config. Line No.", DBLine."Line No.");
            if DBRelation.FindSet(false) then
                repeat
                    // Apply each relationship filter
                    ParentFldRef := ParentLineRef.Field(DBRelation."Parent Field No.");
                    FldRef := LineRef.Field(DBRelation."Child Field No.");
                    FldRef.SetFilter(Format(ParentFldRef.Value()));
                until DBRelation.Next() = 0;
        end;

        // generate a Header row

        // If we're being asked for a page beyond the records that exist
        if (StartFromPage > 1) and (PageSize <> 0) and (DBLine."Parent Table No." = 0) then begin
            i := ((StartFromPage - 1) * PageSize) + 1;
            if LineRef.Count() < i then begin
                SPBDBraiderErrorSystem.AddError(1, 'The requested page is beyond the records that exist');
                LineRef.Close();
                exit;
            end;
        end;

        // Keep an eye on total records (within filters) for top level Config Lines
        if DBLine."Parent Table No." = 0 then
            TopLevelRecordCount += LineRef.Count();

        // Now iterate through the rows of the data
        if LineRef.FindSet(false) then begin
            // if there's a Pagination request to start later, try?
            SkipUntilRecord := ((StartFromPage - 1) * PageSize);
            i := 0;
            if (StartFromPage > 1) and (PageSize <> 0) and (DBLine."Parent Table No." = 0) then
                repeat
                    i += 1;
                until (LineRef.Next() < 0) or (i >= SkipUntilRecord);
            i := 0;
            repeat
                i += 1;
                // generate a row entry
                TempSPBDBraiderResultsetRow.Init();
                TempSPBDBraiderResultsetRow."Row No." := NextRowNo;
                NextRowNo += 1;
                NextColumnNo := 1;

                // Bail out after 5 records if a Demo key
                if IsDemoInstall and (NextRowNo > 50) then
                    exit;

                // Update the 'breadcrumb' arrays after all the filtering is done and the records are in position/ready
                BreadcrumbRecordConfigLine[DBLine.Indentation + 1] := DBLine;
                BreadcrumbRecordRefArray[DBLine.Indentation + 1] := LineRef.Duplicate();

                TempSPBDBraiderResultsetRow."Data Level" := DBLine."Line No.";
                TempSPBDBraiderResultsetRow."Header Row" := false;
                TempSPBDBraiderResultsetRow."Source Table" := DBLine."Source Table";
                TempSPBDBraiderResultsetRow."Primary Key String" := CopyStr(LineRef.GetPosition(true), 1, MaxStrLen(TempSPBDBraiderResultsetRow."Primary Key String"));
                TempSPBDBraiderResultsetRow."Source SystemId" := LineRef.Field(LineRef.SystemIdNo()).Value();
                TempSPBDBraiderResultsetRow."Belongs To Row No." := TempSPBDBraiderResultsetRowTopLevel."Row No.";
                if TempSPBDBraiderResultsetRow."Belongs To Row No." = 0 then
                    // "top level" record
                    TempSPBDBraiderResultsetRow."Top-Level SystemId" := TempSPBDBraiderResultsetRow."Source SystemId"
                else
                    // Tie all records to the top level
                    TempSPBDBraiderResultsetRow."Top-Level SystemId" := TempSPBDBraiderResultsetRowTopLevel."Source SystemId";
                TempSPBDBraiderResultsetRow."Config. Code" := DBLine."Config. Code";
                TempSPBDBraiderResultsetRow."FQ SystemId" := CopyStr(SPBDBraiderUtilities.BuildFQSI(BreadcrumbRecordRefArray, DBLine.Indentation + 1), 1, MaxStrLen(TempSPBDBraiderResultsetRow."FQ SystemId"));
                if (RunForSpecificRecordRef.Number() <> 0) then begin
                    // if we're running for a specific record, it's from the write engine.
                    TempSPBDBraiderResultsetRow."Data Mode" := TempSPBDBraiderResultsetRow."Data Mode"::Write;
                    if (RunForSpecificRecordRef.Number() = LineRef.Number()) then
                        if TempSPBDBraiderResultsetRow."Belongs To Row No." = 0 then
                            TempSPBDBraiderResultsetRow."Buffer Type" := Enum::"SPB DBraider Buffer Type"::Direct
                        else
                            TempSPBDBraiderResultsetRow."Buffer Type" := Enum::"SPB DBraider Buffer Type"::Child;
                end;
                TempSPBDBraiderResultsetRow.Insert(true);

                // add columns for the Given DBLine and LineRef
                AddLineColumns(DBField, LineRef, NextColumnNo, TempSPBDBraiderResultsetRowTopLevel."Source SystemId");

                // add FlowField data for the Given DBLine and LineRef
                AddFlowFieldColumns(DBLine, NextRowNo, NextColumnNo, LineRef, TempSPBDBraiderResultsetRowTopLevel."Source SystemId");

                // We include some key system fields
                AddSystemFields(DBHeader, LineRef);

                // Locate and process any 'children' lines
                DBChildLine.SetRange("Config. Code", DBLine."Config. Code");
                DBChildLine.SetRange("Parent Table No.", DBLine."Source Table");
                if DBChildLine.FindSet() then
                    repeat
                        AddDataFromConfigLine(TempSPBDBraiderResultsetRow, DBHeader, DBChildLine, NextRowNo, LineRef);
                    until DBChildLine.Next() = 0;

                PageSizeLimitReached := (PageSize <> 0) and (i >= PageSize);
            until PageSizeLimitReached or (LineRef.Next() = 0);
        end;

        LineRef.Close();
    end;

    local procedure AddFlowFieldColumns(
        var DBLine: Record "SPB DBraider Config. Line";
        var NextRowNo: Integer;
        var NextColNo: Integer;
        var CurrentLineRef: RecordRef;
        TopLevelRecordId: Guid
    )
    var
        DBField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Flow";
        FlowFieldSourceRecordRef: RecordRef;
        FilterValueFieldRef: FieldRef;
        ParentFlowFilterFieldRef: FieldRef;
        FlowFieldSourceFound: Boolean;
        i: Integer;
        ParentFlowfieldErr: Label 'Unable to find parent record for FlowField', Locked = true;
    begin
        SPBDBraiderConfLineFlow.SetRange("Config. Code", DBLine."Config. Code");
        SPBDBraiderConfLineFlow.SetRange("Config. Line No.", DBLine."Line No.");
        SPBDBraiderConfLineFlow.SetFilter("Parent Table No.", '<>%1', 0);
        if SPBDBraiderConfLineFlow.IsEmpty() then
            exit;

        // for each flow field setting
        if SPBDBraiderConfLineFlow.FindSet() then
            repeat
                // Cycle through the breadcrumb array to find the parent record, matching on the Parent Table No.
                for i := (DBLine.Indentation + 1) downto 1 do
                    if BreadcrumbRecordRefArray[i].Number() = SPBDBraiderConfLineFlow."Parent Table No." then begin
                        FlowFieldSourceRecordRef := BreadcrumbRecordRefArray[i].Duplicate();
                        FlowFieldSourceFound := true;
                    end;
            until SPBDBraiderConfLineFlow.Next() < 1;

        if FlowFieldSourceFound then begin
            // For each of the target FlowFields, there may be MULTIPLE layers of FlowFiltering per config line to apply.
            for i := (DBLine.Indentation + 1) downto 1 do begin
                SPBDBraiderConfLineFlow.Reset();
                SPBDBraiderConfLineFlow.SetRange("Config. Code", BreadcrumbRecordConfigLine[i]."Config. Code");
                SPBDBraiderConfLineFlow.SetRange("Config. Line No.", BreadcrumbRecordConfigLine[i]."Line No.");
                SPBDBraiderConfLineFlow.SetRange("Parent Table No.", FlowFieldSourceRecordRef.Number());
                if SPBDBraiderConfLineFlow.FindSet() then
                    repeat
                        // For the target FlowFilter for the Parent based on this configFlow entry
                        ParentFlowFilterFieldRef := FlowFieldSourceRecordRef.Field(SPBDBraiderConfLineFlow."Parent FlowFilter Field No.");

                        // The value of the filter comes from the value of that relevant record's field source, based on our "i" level
                        FilterValueFieldRef := BreadcrumbRecordRefArray[i].Field(SPBDBraiderConfLineFlow."Source FlowFilter Field No.");
                        ParentFlowFilterFieldRef.SetFilter(FilterValueFieldRef.Value());
                    until SPBDBraiderConfLineFlow.Next() < 1;
            end;

            // Now that we have it filtered, we'll add the FlowField columns from the *Parent* config to *this* level of data
            DBField.SetRange("Config. Code", BreadcrumbRecordConfigLine[i]."Config. Code");
            DBField.SetRange("Config. Line No.", BreadcrumbRecordConfigLine[i]."Line No.");
            DBField.SetRange("Field Class", Format(FieldClass::FlowField));
            AddLineColumns(DBField, FlowFieldSourceRecordRef, NextColNo, TopLevelRecordId);  // Calcfields is called inside this function
        end else
            Error(ParentFlowfieldErr);
    end;

    local procedure CopyFiltersFromRecRefToRecRef(var WhichRecordRef: RecordRef; LineRef: RecordRef)
    var
        FromFieldRef: FieldRef;
        ToFieldRef: FieldRef;
        i: Integer;
    begin
        for i := 1 to WhichRecordRef.FieldCount() do begin
            FromFieldRef := WhichRecordRef.FieldIndex(i);
            ToFieldRef := LineRef.FieldIndex(i);
            ToFieldRef.SetFilter(FromFieldRef.GetFilter());
        end;
    end;

    /// <summary>
    /// This procedure adds the following fields to every record:
    /// </summary>
    /// <param name="LineRef"></param>
    local procedure AddSystemFields(
        var DBHeader: Record "SPB DBraider Config. Header";
        var LineRef: RecordRef)
    var
        TypeHelper: Codeunit "Type Helper";
        ModifiedFieldRef: FieldRef;
        TimestampInMilliseconds: BigInteger;
        EpochDateTime: DateTime;
        RecordDateTime: DateTime;
        TimezoneOffset: Duration;
    begin
        // Include the Last Modified as an Epoch timestamp
        if not TypeHelper.GetUserTimezoneOffset(TimezoneOffset) then
            TimezoneOffset := 0;

        EpochDateTime := CreateDateTime(DMY2Date(1, 1, 1970), 0T);

        if (not DBHeader."Disable Auto ModifiedAt") and (not SPBDBraiderSetup."Disable Auto ModifiedAt") then begin
            // TimestampInMilliseconds := Timestamp * 1000;
            // ResultDateTime := EpochDateTime + TimestampInMilliseconds + TimezoneOffset;
            ModifiedFieldRef := LineRef.Field(LineRef.SystemModifiedAtNo());
            //Evaluate(RecordDateTime, ModifiedFieldRef.Value);
            RecordDateTime := ModifiedFieldRef.Value();

            // For pre-BC databases that upgraded, this field CAN be empty, so skip if so
            if RecordDateTime <> 0DT then begin
                TimestampInMilliseconds := Round((RecordDateTime - EpochDateTime + TimezoneOffset) / 1000, 1);

                TempSPBDBraiderResultsetCol.Init();
                TempSPBDBraiderResultsetCol."Row No." := TempSPBDBraiderResultsetRow."Row No.";
                TempSPBDBraiderResultsetCol."Column No." := LineRef.SystemModifiedAtNo();
                TempSPBDBraiderResultsetCol."Field Name" := 'lastModifiedAt';
                TempSPBDBraiderResultsetCol."Field No." := ModifiedFieldRef.Number();
                TempSPBDBraiderResultsetCol."Value as Text" := Format(TimestampInMilliseconds);
                TempSPBDBraiderResultsetCol.NumberCell := TimestampInMilliseconds;
                TempSPBDBraiderResultsetCol."Data Type" := TempSPBDBraiderResultsetCol."Data Type"::Integer;
                TempSPBDBraiderResultsetCol."Source SystemId" := TempSPBDBraiderResultsetRow."Source SystemId";
                TempSPBDBraiderResultsetCol."Top-Level SystemId" := TempSPBDBraiderResultsetRow."Top-Level SystemId";
                TempSPBDBraiderResultsetCol."Write Result Record" := (RunForSpecificRecordRef.Number() <> 0) and (RunForSpecificRecordRef.Number() = LineRef.Number());
                TempSPBDBraiderResultsetCol.Insert(true);
            end;
        end;

        if (not DBHeader."Disable Auto SystemId") and (not SPBDBraiderSetup."Disable Auto SystemId") then begin
            TempSPBDBraiderResultsetCol.Init();
            TempSPBDBraiderResultsetCol."Row No." := TempSPBDBraiderResultsetRow."Row No.";
            TempSPBDBraiderResultsetCol."Column No." := LineRef.SystemIdNo();
            TempSPBDBraiderResultsetCol."Field Name" := 'systemId';
            TempSPBDBraiderResultsetCol."Field No." := LineRef.SystemIdNo();
            TempSPBDBraiderResultsetCol."Value as Text" := CopyStr(Format(LineRef.Field(LineRef.SystemIdNo()).Value(), 0, 4).ToLower(), 1, MaxStrLen(TempSPBDBraiderResultsetCol."Value as Text"));
            TempSPBDBraiderResultsetCol.GuidCell := LineRef.Field(LineRef.SystemIdNo()).Value();
            TempSPBDBraiderResultsetCol."Data Type" := TempSPBDBraiderResultsetCol."Data Type"::Guid;
            TempSPBDBraiderResultsetCol."Source SystemId" := TempSPBDBraiderResultsetRow."Source SystemId";
            TempSPBDBraiderResultsetCol."Top-Level SystemId" := TempSPBDBraiderResultsetRow."Top-Level SystemId";
            TempSPBDBraiderResultsetCol."Write Result Record" := (RunForSpecificRecordRef.Number() <> 0) and (RunForSpecificRecordRef.Number() = LineRef.Number());
            TempSPBDBraiderResultsetCol.Insert(true);
        end;
    end;

    [Obsolete('This function is deprecated, please use the function with the FilterJson parameter')]
    procedure BuildFiltersFromJson(FilterJsonArray: JsonArray)
    begin
        BuildFiltersFromJson('', FilterJsonArray);
    end;

    procedure BuildFiltersFromJson(ConfigCode: Code[20]; FilterJsonArray: JsonArray)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DBChildLine: Record "SPB DBraider Config. Line";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        ProblemWithFilter: Boolean;
        i: Integer;
        PossibleFieldNo: Integer;
        PossibleTableNo: Integer;
        FilterObj: JsonObject;
        FilterTok: JsonToken;
        ValTok: JsonToken;
        FieldNotFoundLbl: Label 'Field %1 not found', Comment = '%1 = Field Name';
        FilterContentIssueLbl: Label 'Filter content issue: %1', Comment = '%1 = Error Text';
        TableNotFoundLbl: Label 'Table %1 not found', Comment = '%1 = Table Name';
        TableNotIncludedLbl: Label 'Table %1 is not included in the %2 endpoint', Comment = '%1 = Table Name, %2 is the Endpoint name.';
    begin
        TempSPBDBraiderFilters.DeleteAll();
        foreach FilterTok in FilterJsonArray do begin
            ProblemWithFilter := false;
            TempSPBDBraiderFilters.Init();
            FilterObj := FilterTok.AsObject();
            FilterObj.Get('table', ValTok);
            // We'll assume Table Number first, but if not found, we'll try to GetTableNoFromTableName
            if not Evaluate(TempSPBDBraiderFilters."Table No.", ValTok.AsValue().AsText()) then begin
                PossibleTableNo := GetTableNoFromTableName(ConfigCode, ValTok.AsValue().AsText());
                if PossibleTableNo <> 0 then
                    TempSPBDBraiderFilters."Table No." := PossibleTableNo
                else begin
                    ProblemWithFilter := true;
                    TempSPBDBraiderFilters."Table No." := 0;
                    TempSPBDBraiderFilters."Error Description" := CopyStr(StrSubstNo(TableNotFoundLbl, ValTok.AsValue().AsText()), 1, MaxStrLen(TempSPBDBraiderFilters."Error Description"));
                end;
            end;

            // Validate that the Table No involved exists
            AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
            AllObjWithCaption.SetRange("Object ID", TempSPBDBraiderFilters."Table No.");
            if AllObjWithCaption.IsEmpty() then begin
                ProblemWithFilter := true;
                TempSPBDBraiderFilters."Table No." := 0;
                TempSPBDBraiderFilters."Error Description" := CopyStr(TempSPBDBraiderFilters."Error Description" + StrSubstNo(TableNotFoundLbl, ValTok.AsValue().AsText()), 1, MaxStrLen(TempSPBDBraiderFilters."Error Description"));
            end;

            // Validate that the Table No involved is ON this endpoint's list of Config Lines
            if ConfigCode <> '' then begin // In the off chance someone is using the Deprecated old version with no config, we'll have to skip this check
                DBChildLine.SetRange("Config. Code", ConfigCode);
                DBChildLine.SetRange("Source Table", TempSPBDBraiderFilters."Table No.");
                if DBChildLine.IsEmpty() and not AllObjWithCaption.IsEmpty() then begin
                    ProblemWithFilter := true;
                    TempSPBDBraiderFilters."Table No." := 0;
                    TempSPBDBraiderFilters."Error Description" := CopyStr(TempSPBDBraiderFilters."Error Description" + StrSubstNo(TableNotIncludedLbl, ValTok.AsValue().AsText(), ConfigCode), 1, MaxStrLen(TempSPBDBraiderFilters."Error Description"));
                end;
            end;

            // We'll assume Field Number first, but if not found, we'll try to GetFieldNoFromFieldName, but only if Table evaluated correctly
            if TempSPBDBraiderFilters."Table No." <> 0 then begin
                FilterObj.Get('field', ValTok);
                if not Evaluate(TempSPBDBraiderFilters."Field No.", ValTok.AsValue().AsText()) then begin
                    PossibleFieldNo := GetFieldNoFromFieldName(ConfigCode, TempSPBDBraiderFilters."Table No.", ValTok.AsValue().AsText());
                    if PossibleFieldNo <> 0 then
                        TempSPBDBraiderFilters."Field No." := PossibleFieldNo
                    else begin
                        ProblemWithFilter := true;
                        TempSPBDBraiderFilters."Field No." := 0;
                        TempSPBDBraiderFilters."Error Description" := CopyStr(TempSPBDBraiderFilters."Error Description" + StrSubstNo(FieldNotFoundLbl, ValTok.AsValue().AsText()), 1, MaxStrLen(TempSPBDBraiderFilters."Error Description"));
                    end;
                end;
            end;

            // Now we'll even go one step further and try to evaluate the filter text if it's a valid filter
            if not ProblemWithFilter then begin
                FilterObj.Get('filter', ValTok);
                Evaluate(TempSPBDBraiderFilters."Filter Text", ValTok.AsValue().AsText());
                if not TestFilterOnTableField(TempSPBDBraiderFilters."Table No.", TempSPBDBraiderFilters."Field No.", TempSPBDBraiderFilters."Filter Text") then begin
                    ProblemWithFilter := true;
                    TempSPBDBraiderFilters."Error Description" := CopyStr(TempSPBDBraiderFilters."Error Description" + StrSubstNo(FilterContentIssueLbl, GetLastErrorText()), 1, MaxStrLen(TempSPBDBraiderFilters."Error Description"));
                    ClearLastError();  // We've handled the error, so clear it
                end
            end;

            TempSPBDBraiderFilters.Success := not ProblemWithFilter;
            TempSPBDBraiderFilters.Insert();
        end;

        // If there were any issues applying the filtering, now we'll load that info into SPBDBraiderErrorSystem
        TempSPBDBraiderFilters.SetRange(Success, false);
        if TempSPBDBraiderFilters.FindSet() then begin
            i := 0;  // shush AL00205
            SPBDBraiderErrorSystem.AddError(i, 'There were issues with the filters provided:');
            repeat
                i += 1;
                SPBDBraiderErrorSystem.AddError(i, TempSPBDBraiderFilters."Error Description");
            until TempSPBDBraiderFilters.Next() = 0;
        end;
        TempSPBDBraiderFilters.SetRange(Success);
    end;

    local procedure GetTableNoFromTableName(ConfigCode: Code[20]; TableName: Text): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DBChildLine: Record "SPB DBraider Config. Line";
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
    begin
        // First we'll try to find the table by name, or by caption, matching the BC Table naming.
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object Name", TableName);
        if AllObjWithCaption.FindFirst() then
            exit(AllObjWithCaption."Object ID");
        // Try the Caption as a fallback if the name didn't find anything
        AllObjWithCaption.SetRange("Object Name");
        AllObjWithCaption.SetRange("Object Caption", TableName);
        if AllObjWithCaption.FindFirst() then
            exit(AllObjWithCaption."Object ID");

        // If we still haven't found it, we'll try to find it in the Config Lines using the JSON'd name
        DBChildLine.SetRange("Config. Code", ConfigCode);
        DBChildLine.SetAutoCalcFields("Source Table Name");
        if DBChildLine.FindSet() then
            repeat
                if SPBDBraiderJSONUtilities.JsonSafeTableFieldName(DBChildLine."Source Table Name") = TableName then
                    exit(DBChildLine."Source Table");
            until DBChildLine.Next() < 1;
        exit(0);
    end;

    local procedure GetFieldNoFromFieldName(ConfigCode: Code[20]; TableNo: Integer; FieldName: Text): Integer
    var
        FieldData: Record Field;
        DBChildFields: Record "SPB DBraider ConfLine Field";
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
    begin
        // Try to match on the Field Name and Field Captions based on the BC information
        FieldData.SetRange(TableNo, TableNo);
        FieldData.SetRange(FieldName, FieldName);
        if FieldData.FindFirst() then
            exit(FieldData."No.");
        FieldData.SetRange(FieldName);
        FieldData.SetRange("Field Caption", FieldName);
        if FieldData.FindFirst() then
            exit(FieldData."No.");

        // If this fails, we'll try to find it in the Config Lines using the JSON'd name of the field or even the user's defined caption
        DBChildFields.SetRange("Config. Code", ConfigCode);
        DBChildFields.SetAutoCalcFields("Field Name", Caption);
        if DBChildFields.FindSet() then
            repeat
                if (SPBDBraiderJSONUtilities.JsonSafeTableFieldName(DBChildFields."Field Name") = FieldName)
                    or (SPBDBraiderJSONUtilities.JsonSafeTableFieldName(DBChildFields.Caption) = FieldName)
                    or (DBChildFields."Manual Field Caption" = FieldName)
                then
                    exit(DBChildFields."Field No.");
            until DBChildFields.Next() < 1;
        exit(0);
    end;

    [TryFunction]
    local procedure TestFilterOnTableField(TableNo: Integer; FieldNo: Integer; FilterText: Text)
    var
        TestRecordRef: RecordRef;
        TestFieldRef: FieldRef;
    begin
        TestRecordRef.Open(TableNo);
        TestFieldRef := TestRecordRef.Field(FieldNo);
        TestFieldRef.SetFilter(FilterText);
    end;

    local procedure ArchiveDataset(DBHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderDeltaCol: Record "SPB DBraider Delta Col";
        SPBDBraiderDeltaRow: Record "SPB DBraider Delta Row";
        VersionNo: Integer;
    begin
        DBHeader.CalcFields("Has Archive Data", "Max Version No.");
        if DBHeader."Has Archive Data" then begin
            // We need to do a bit of history version tidyup
            VersionNo := DBHeader."Max Version No." - DBHeader."Data Archive Versions";
            SPBDBraiderDeltaRow.SetRange("Config. Code", DBHeader."Code");
            SPBDBraiderDeltaRow.SetFilter("Version No.", '<%1', VersionNo);
            SPBDBraiderDeltaCol.SetRange("Config. Code", DBHeader."Code");
            SPBDBraiderDeltaCol.SetFilter("Version No.", '<%1', VersionNo);
            SPBDBraiderDeltaRow.DeleteAll();
            SPBDBraiderDeltaCol.DeleteAll();
            VersionNo := DBHeader."Max Version No." + 1;
        end else
            VersionNo := 1;

        // Now we'll copy the data from the Temp tables to the Archive tables
        TempSPBDBraiderResultsetRow.Reset();
        if TempSPBDBraiderResultsetRow.FindSet() then
            repeat
                SPBDBraiderDeltaRow.TransferFields(TempSPBDBraiderResultsetRow, true);
                SPBDBraiderDeltaRow."Config. Code" := DBHeader."Code";
                SPBDBraiderDeltaRow."Version No." := VersionNo;
                SPBDBraiderDeltaRow.Insert(true);
            until TempSPBDBraiderResultsetRow.Next() < 1;
        TempSPBDBraiderResultsetCol.Reset();
        if TempSPBDBraiderResultsetCol.FindSet() then
            repeat
                SPBDBraiderDeltaCol.TransferFields(TempSPBDBraiderResultsetCol, true);
                SPBDBraiderDeltaCol."Config. Code" := DBHeader."Code";
                SPBDBraiderDeltaCol."Version No." := VersionNo;
                SPBDBraiderDeltaCol.Insert(true);
            until TempSPBDBraiderResultsetCol.Next() < 1;
    end;

    /// <summary>
    /// This procedure will go through all Write Marked records and crawl UP the "Belongs-To Row No." chain to mark all the parent records as well.
    /// Then it will update the Column records to reflect this.
    /// </summary>
    local procedure MarkInclusionRecords()
    var
        RowNo: Integer;
        RowsToMark: List of [Integer];
    begin
        TempSPBDBraiderResultsetRow.SetRange("Buffer Type", Enum::"SPB DBraider Buffer Type"::Child);
        TempSPBDBraiderResultsetRow.SetFilter("Belongs To Row No.", '<>0');
        if TempSPBDBraiderResultsetRow.FindSet() then
            repeat
                GetRowChain(TempSPBDBraiderResultsetRow."Row No.", RowsToMark);
            until TempSPBDBraiderResultsetRow.Next() < 1;

        TempSPBDBraiderResultsetRow.Reset();
        foreach RowNo in RowsToMark do begin
            TempSPBDBraiderResultsetRow.SetRange("Row No.", RowNo);
            TempSPBDBraiderResultsetRow.ModifyAll("Buffer Type", Enum::"SPB DBraider Buffer Type"::Parent);
            TempSPBDBraiderResultsetRow.ModifyAll("Data Mode", TempSPBDBraiderResultsetRow."Data Mode"::Write);
            TempSPBDBraiderResultsetCol.SetRange("Row No.", RowNo);
            TempSPBDBraiderResultsetCol.ModifyAll("Write Result Record", true);
        end;
        TempSPBDBraiderResultsetRow.Reset();
        TempSPBDBraiderResultsetCol.Reset();
    end;

    local procedure GetRowChain(ForRowNo: Integer; var ParentChain: List of [Integer])
    var
        TempSPBDBraiderResultsetRow2: Record "SPB DBraider Resultset Row" temporary;
    begin
        TempSPBDBraiderResultsetRow2.Copy(TempSPBDBraiderResultsetRow, true);
        TempSPBDBraiderResultsetRow2.SetRange("Row No.", ForRowNo);
        if TempSPBDBraiderResultsetRow2.FindFirst() then
            if TempSPBDBraiderResultsetRow2."Belongs To Row No." <> 0 then begin
                ParentChain.Add(TempSPBDBraiderResultsetRow2."Belongs To Row No.");
                GetRowChain(TempSPBDBraiderResultsetRow2."Belongs To Row No.", ParentChain);
            end;
    end;

    internal procedure SetFilterJson(NewFilterJson: Text)
    begin
        FilterJson := NewFilterJson;
    end;

    internal procedure SetPagination(newStartFromPage: Integer)
    begin
        StartFromPage := newStartFromPage;
        PageSize := SPBDBraiderSetup."Default Page Size";
    end;

    internal procedure SetPagination(newStartFromPage: Integer; newPageSize: Integer)
    begin
        StartFromPage := newStartFromPage;
        PageSize := newPageSize;
    end;

    internal procedure InitializePagination(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    begin
        SPBDBraiderSetup.GetRecordOnce();
        if PageSize = 0 then
            if SPBDBraiderConfigHeader."Page Size" <> 0 then
                PageSize := SPBDBraiderConfigHeader."Page Size"
            else
                PageSize := SPBDBraiderSetup."Default Page Size";
    end;

    internal procedure GetPageInfo(var newStartFromPage: Integer; var newPageSize: Integer)
    begin
        newStartFromPage := StartFromPage;
        newPageSize := PageSize;
    end;

    internal procedure GetTopLevelRecordCount() newTopLevelRecordCount: Integer
    begin
        newTopLevelRecordCount := TopLevelRecordCount;
    end;
}
