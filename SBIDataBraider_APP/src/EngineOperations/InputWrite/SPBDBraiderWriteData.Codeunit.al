codeunit 71033606 "SPB DBraider Write Data"
{
    TableNo = "JSON Buffer";

    var
        GlobalConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        EventNoteMgt: Codeunit "SPB DBraider Event Note Mgt";
        LastRecordPosition: Dictionary of [Integer, Text];
        RecordsAffected: Integer;
        JsonResultArray: JsonArray;

    trigger OnRun()
    begin
        ProcessInputBuffer(Rec);
    end;

    procedure ProcessInputBuffer(var TempHeaderJsonBuffer: Record "JSON Buffer" temporary)
    var
        TempContentJsonBuffer: Record "JSON Buffer" temporary;
        AllDataValid: Boolean;
        SPBDBraiderChangeAction: Enum "SPB DBraider Change Action";
        OperationNotAllowedLbl: Label 'The %1 operation is not allowed on the %2 endpoint.', Comment = '%1 = Record Action, %2 = Endpoint Config Code';
        TokenTypesLbl: Label '%1|%2|%3|%4', Comment = '%1 = Boolean, %2 = Decimal %3 = Integer %4 = String';
        ContentTokenTypeFilter: Text;
    begin
        AllDataValid := true;

        TempContentJsonBuffer.Copy(TempHeaderJsonBuffer, true);
        ContentTokenTypeFilter := StrSubstNo(TokenTypesLbl, TempContentJsonBuffer."Token type"::Boolean,
            TempContentJsonBuffer."Token type"::Decimal, TempContentJsonBuffer."Token type"::Integer,
            TempContentJsonBuffer."Token type"::String);
        TempContentJsonBuffer.SetFilter("Token type", ContentTokenTypeFilter);
        TempContentJsonBuffer.SetFilter("SPB Table No.", '<>0');  // Ensure we skip any JSON actions (strings)
        TempHeaderJsonBuffer.SetRange("Token type", TempHeaderJsonBuffer."Token type"::"Start Object");
        if TempHeaderJsonBuffer.FindSet() then
            repeat
                TempContentJsonBuffer.SetCurrentKey("SPB Record Id", "SPB Processing Order", "SPB Field No.");
                TempContentJsonBuffer.SetRange("SPB Record Id", TempHeaderJsonBuffer."SPB Record Id");
                TempContentJsonBuffer.FindFirst();

                if IsAllowedActionType(TempHeaderJsonBuffer) then
                    case TempHeaderJsonBuffer."SPB Record Action" of
                        SPBDBraiderChangeAction::Insert:
                            if not InsertContent(TempContentJsonBuffer) then
                                AllDataValid := false;
                        SPBDBraiderChangeAction::Update:
                            if not UpdateContent(TempContentJsonBuffer) then
                                AllDataValid := false;
                        SPBDBraiderChangeAction::Upsert:
                            if not UpsertContent(TempContentJsonBuffer) then
                                AllDataValid := false;
                        SPBDBraiderChangeAction::Delete:
                            if not DeleteContent(TempContentJsonBuffer) then
                                AllDataValid := false;
                        else begin
                            SPBDBraiderErrorSystem.AddError(TempContentJsonBuffer.GetRangeMin("SPB Record Id"), StrSubstNo(OperationNotAllowedLbl, TempHeaderJsonBuffer."SPB Record Action", TempHeaderJsonBuffer."SPB Config. Code"));
                            AllDataValid := false;
                        end;
                    end;
            until TempHeaderJsonBuffer.Next() = 0;

        // If anything went wrong that Validation missed, welp, we'll rollback
        if not AllDataValid then
            Error('');
    end;


    procedure FindRecordRefByContent(var TempContentJsonBuffer: Record "JSON Buffer" temporary; var TargetRecordRef: RecordRef; var PKPrintable: Text): Boolean
    var
        AllObjects: Record AllObj;
        FieldList: Record Field;
        TempFieldsJsonBuffer: Record "JSON Buffer" temporary;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TargetFieldRef: FieldRef;
        LocatedKeyFields: Dictionary of [Integer, Text];
        FieldNo: Integer;
        i: Integer;
        FieldNameAndValueLbl: Label '[%1]: ''%2''', Comment = '%1 = Field Caption, %2 = Field Value';
        MissingKeyFields: List of [Integer];
        PrimaryKeyFields: List of [Integer];
    begin
        TempFieldsJsonBuffer.Copy(TempContentJsonBuffer, true);

        // Safety Catch:
        if (TempContentJsonBuffer."SPB Table No." = 0) then
            exit(false);
        AllObjects.SetRange("Object Type", AllObjects."Object Type"::Table);
        AllObjects.SetRange("Object ID", TempContentJsonBuffer."SPB Table No.");
        if AllObjects.IsEmpty() then
            exit(false);


        TargetRecordRef.Open(TempContentJsonBuffer."SPB Table No.");
        PrimaryKeyFields := SPBDBraiderUtilities.GetPrimaryKeyFields(TargetRecordRef);

        for i := 1 to PrimaryKeyFields.Count() do begin
            PrimaryKeyFields.Get(i, FieldNo);
            TempFieldsJsonBuffer.SetRange("SPB Field No.", FieldNo);
            if TempFieldsJsonBuffer.FindFirst() then begin
                LocatedKeyFields.Add(FieldNo, TempFieldsJsonBuffer.GetValue());
                if FieldList.Get(TempContentJsonBuffer."SPB Table No.", FieldNo) then begin
                    if PKPrintable <> '' then
                        PKPrintable := PKPrintable + ', ';
                    PKPrintable := PKPrintable + StrSubstNo(FieldNameAndValueLbl, FieldList."Field Caption", TempFieldsJsonBuffer.GetValue())
                end;
            end else
                MissingKeyFields.Add(FieldNo);
        end;

        //TODO: This needs to lookup the fields by what's submitted, sure, BUT we may also be 'assuming' some part of the PK from the parent record.
        ApplyInferredParentData(TempContentJsonBuffer, TargetRecordRef, LocatedKeyFields, MissingKeyFields);

        if MissingKeyFields.Count() > 0 then
            exit(false);

        foreach FieldNo in LocatedKeyFields.Keys() do begin
            TargetFieldRef := TargetRecordRef.Field(FieldNo);
            TargetFieldRef.SetFilter(LocatedKeyFields.Get(FieldNo));
        end;

        exit(TargetRecordRef.FindFirst());
    end;

    local procedure InsertContent(var TempContentJsonBuffer: Record "JSON Buffer" temporary) AllDataValid: Boolean
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TargetRecordRef: RecordRef;
        UnableToInsertRecordLbl: Label 'Unable to insert the Record - %1 already exists.', Comment = '%1 = Primary Key String';
        PKString: Text;
    begin
        AllDataValid := true;
        if not FindRecordRefByContent(TempContentJsonBuffer, TargetRecordRef, PKString) then begin
            TargetRecordRef.Init();
            ApplyPossibleParentData(TempContentJsonBuffer, TargetRecordRef);
            ApplyDefaults(TempContentJsonBuffer."SPB Config. Code", TempContentJsonBuffer."SPB Config. Line No.", TargetRecordRef);
            CheckAndHandleAutoSplitKey(TempContentJsonBuffer, TargetRecordRef);
            if TempContentJsonBuffer.FindSet() then
                repeat
                    if TempContentJsonBuffer."SPB Field No." <> 0 then
                        ChooseValidateFieldValue(TempContentJsonBuffer, Enum::"SPB DBraider Change Action"::Insert, TargetRecordRef, TempContentJsonBuffer."SPB Field No.", TempContentJsonBuffer.Value);
                until TempContentJsonBuffer.Next() = 0;
            TargetRecordRef.Insert(true);
            TargetRecordRef.Find('='); // Refresh position after insert
            AddRecordRefToResults(TempContentJsonBuffer, 'insert', TargetRecordRef);
            SetLastRecord(TargetRecordRef);
            SPBDBraiderErrorSystem.AddResult(TempContentJsonBuffer.GetRangeMin("SPB Record Id"), StrSubstNo('', PKString));
            RecordsAffected += 1;
        end else begin
            SPBDBraiderErrorSystem.AddError(TempContentJsonBuffer.GetRangeMin("SPB Record Id"), StrSubstNo(UnableToInsertRecordLbl, PKString));
            AllDataValid := false;
        end;
    end;

    local procedure UpdateContent(var TempContentJsonBuffer: Record "JSON Buffer" temporary) AllDataValid: Boolean
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TargetRecordRef: RecordRef;
        UnableToUpdateRecLbl: Label 'Unable to update the Record - %1 does not exist.', Comment = '%1 = Primary Key String';
        PKString: Text;
    begin
        AllDataValid := true;
        if FindRecordRefByContent(TempContentJsonBuffer, TargetRecordRef, PKString) then begin
            TempContentJsonBuffer.SetRange("SPB Primary Key Field", false);
            if TempContentJsonBuffer.FindSet() then
                repeat
                    ChooseValidateFieldValue(TempContentJsonBuffer, Enum::"SPB DBraider Change Action"::Update, TargetRecordRef, TempContentJsonBuffer."SPB Field No.", TempContentJsonBuffer.Value);
                until TempContentJsonBuffer.Next() = 0;
            TargetRecordRef.Modify(true);
            TargetRecordRef.Find('='); // Refresh position after modify
            AddRecordRefToResults(TempContentJsonBuffer, 'modify', TargetRecordRef);
            SetLastRecord(TargetRecordRef);
            TempContentJsonBuffer.SetRange("SPB Primary Key Field");
            RecordsAffected += 1;
        end else begin
            SPBDBraiderErrorSystem.AddError(TempContentJsonBuffer.GetRangeMin("SPB Record Id"), StrSubstNo(UnableToUpdateRecLbl, PKString));
            AllDataValid := false;
        end;
    end;

    local procedure UpsertContent(var TempContentJsonBuffer: Record "JSON Buffer" temporary) AllDataValid: Boolean
    var
        TargetRecordRef: RecordRef;
        PKString: Text;
    begin
        AllDataValid := true;
        if FindRecordRefByContent(TempContentJsonBuffer, TargetRecordRef, PKString) then begin
            if not UpdateContent(TempContentJsonBuffer) then
                AllDataValid := false
        end else
            if not InsertContent(TempContentJsonBuffer) then
                AllDataValid := false;
    end;

    local procedure DeleteContent(var TempContentJsonBuffer: Record "JSON Buffer" temporary) AllDataValid: Boolean
    var
        TargetRecordRef: RecordRef;
        UnableToDeleteRecLbl: Label 'Unable to delete the Record - %1 does not exist.', Comment = '%1 = Primary Key String';
        PKString: Text;
    begin
        AllDataValid := true;
        if FindRecordRefByContent(TempContentJsonBuffer, TargetRecordRef, PKString) then begin
            TargetRecordRef.Delete(true);
            AddDeletedRecordToResults(PKString);
            EventNoteMgt.CreateEventNote('', TargetRecordRef.Number(), TargetRecordRef.RecordId(), 'delete', PKString);
            RecordsAffected += 1;
        end else begin
            SPBDBraiderErrorSystem.AddError(TempContentJsonBuffer.GetRangeMin("SPB Record Id"), StrSubstNo(UnableToDeleteRecLbl, PKString));
            AllDataValid := false;
        end;
    end;

    local procedure AddRecordRefToResults(var TempContentJsonBuffer: Record "JSON Buffer" temporary; ActionName: Text; var TargetRecordRef: RecordRef)
    var
        DBraiderConfig: Record "SPB DBraider Config. Header";
        TempResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempResultRow: Record "SPB DBraider Resultset Row" temporary;

        DBraiderEngine: Codeunit "SPB DBraider Data Engine";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        SpecificRecordRef: RecordRef;
        ConfigCodeToUse: Code[20];
        SPBDBraiderIDatasetToText: Interface "SPB DBraider IDatasetToText";
        JsonResult: JsonArray;
        ResultJsonObject: JsonObject;
        PrimaryKeyFields: List of [Integer];
        FieldNo: Integer;
        FieldRef: FieldRef;
        i: Integer;
        FilterDebugInfo: Text;
    begin
        Clear(DBraiderEngine);
        TempResultRow.DeleteAll();
        TempResultCol.DeleteAll();

        // Build filter manually using primary key fields instead of SetRecFilter
        SpecificRecordRef.Open(TargetRecordRef.Number());
        PrimaryKeyFields := SPBDBraiderUtilities.GetPrimaryKeyFields(TargetRecordRef);
        foreach FieldNo in PrimaryKeyFields do begin
            FieldRef := SpecificRecordRef.Field(FieldNo);
            FieldRef.SetFilter(Format(TargetRecordRef.Field(FieldNo).Value()));
        end;

        // Position the RecordRef on the found record
        if not SpecificRecordRef.FindFirst() then begin
            FilterDebugInfo := StrSubstNo('TargetPos=%1|TargetFilters=%2|SpecificFilters=%3|SpecificCount=%4|FindResult=FALSE',
                TargetRecordRef.GetPosition(), TargetRecordRef.GetFilters(), SpecificRecordRef.GetFilters(), SpecificRecordRef.Count());
            exit; // Can't generate data if we can't find the record
        end;

        // Debug: Store filter info after successful find
        FilterDebugInfo := StrSubstNo('TargetPos=%1|TargetFilters=%2|SpecificFilters=%3|SpecificCount=%4|FindResult=TRUE|SpecificPos=%5',
            TargetRecordRef.GetPosition(), TargetRecordRef.GetFilters(), SpecificRecordRef.GetFilters(), SpecificRecordRef.Count(),
            SpecificRecordRef.GetPosition());

        // Use Config Code from buffer if available, otherwise use global config header
        if TempContentJsonBuffer."SPB Config. Code" <> '' then
            ConfigCodeToUse := TempContentJsonBuffer."SPB Config. Code"
        else
            ConfigCodeToUse := GlobalConfigHeader.Code;

        if DBraiderConfig.Get(ConfigCodeToUse) then begin  // Intentional: You can only get one result set, so findfirst.  If they filter on a range, first only!
            DBraiderEngine.GenerateRecordData(DBraiderConfig.Code, SpecificRecordRef);
            DBraiderEngine.GetResults(TempResultRow, TempResultCol);

            // If filters result in zero result rows, inject a minimal placeholder row for serializer to carry Config Code.
            if TempResultRow.IsEmpty() then begin
                TempResultRow.Init();
                TempResultRow."Row No." := 1; // Minimal row id
                TempResultRow."Config. Code" := DBraiderConfig.Code;
                TempResultRow.Insert();
            end;

            OnBeforeWriteResultRecord(DBraiderConfig, TempContentJsonBuffer, TempResultRow, TempResultCol);

            SPBDBraiderIDatasetToText := DBraiderConfig."Output JSON Type";
            JsonResult := SPBDBraiderIDatasetToText.ConvertToJSON(TempResultRow, TempResultCol);
            Clear(ResultJsonObject);
            ResultJsonObject.Add('action', ActionName);
            ResultJsonObject.Add('data', JsonResult);

            // Add diagnostics if enabled
            if DBraiderConfig."Emit Raw Diagnostic Data" then
                ResultJsonObject.Add('diagnostics', BuildDiagnostics(TempResultRow, TempResultCol));

            // Add note if result set is empty (record written but doesn't match read filters)
            if JsonResult.Count() = 0 then begin
                TempResultCol.SetRange("Write Result Record", true);
                TempResultRow.SetRange("Buffer Type", Enum::"SPB DBraider Buffer Type"::Child);
                ResultJsonObject.Add('note', StrSubstNo('DIAG: TotalRows=%1, TotalCols=%2, WriteResultCols=%3, ChildRows=%4, TargetTable=%5 | %6',
                    TempResultRow.Count(), TempResultCol.Count(), TempResultCol.Count(), TempResultRow.Count(), TargetRecordRef.Number(),
                    FilterDebugInfo));
                TempResultCol.SetRange("Write Result Record");
                TempResultRow.SetRange("Buffer Type");
            end;

            JsonResultArray.Add(ResultJsonObject.Clone());
            EventNoteMgt.CreateEventNote(DBraiderConfig.Code, TargetRecordRef.Number(), TargetRecordRef.RecordId(), ActionName, '');
        end;
    end;

    local procedure AddDeletedRecordToResults(PKString: Text)
    var
        ResultJsonObject: JsonObject;
    begin
        ResultJsonObject.Add('action', 'delete');
        ResultJsonObject.Add('gravestonePK', PKString);
        JsonResultArray.Add(ResultJsonObject);
    end;

    internal procedure ApplyDefaultsToInserted(SPBConfigCode: Code[20]; SPBConfigLineNo: Integer; var TargetRecordRef: RecordRef)
    begin
        ApplyDefaults(SPBConfigCode, SPBConfigLineNo, TargetRecordRef);
        TargetRecordRef.Modify(true);
    end;

    internal procedure ApplyDefaults(SPBConfigCode: Code[20]; SPBConfigLineNo: Integer; var TargetRecordRef: RecordRef)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        ProcessedDefaultValue: Text;
    begin
        if SPBDBraiderConfigLine.Get(SPBConfigCode, SPBConfigLineNo) then begin
            SPBDBraiderConfLineField.SetRange("Config. Code", SPBConfigCode);
            SPBDBraiderConfLineField.SetRange("Config. Line No.", SPBConfigLineNo);
            SPBDBraiderConfLineField.SetFilter("Default Value", '<>%1', '');
            if SPBDBraiderConfLineField.FindSet() then
                repeat
                    ProcessedDefaultValue := SPBDBraiderConfLineField."Default Value";
                    SPBDBraiderUtilities.VariableSubstitution(ProcessedDefaultValue);
                    SPBDBraiderUtilities.TrySafeValidateValue(TargetRecordRef, SPBDBraiderConfLineField."Field No.", ProcessedDefaultValue);
                until SPBDBraiderConfLineField.Next() = 0;
        end;
    end;

    local procedure IsAllowedActionType(var TempHeaderJsonBuffer: Record "JSON Buffer" temporary): Boolean
    var
        SPBDBraiderConfig: Record "SPB DBraider Config. Header";
        ConfigCodeToUse: Code[20];
        SPBDBraiderChangeAction: Enum "SPB DBraider Change Action";
    begin
        // Use Config Code from buffer if available, otherwise use global config header
        if TempHeaderJsonBuffer."SPB Config. Code" <> '' then
            ConfigCodeToUse := TempHeaderJsonBuffer."SPB Config. Code"
        else
            ConfigCodeToUse := GlobalConfigHeader.Code;

        SPBDBraiderConfig.Get(ConfigCodeToUse);
        case TempHeaderJsonBuffer."SPB Record Action" of
            SPBDBraiderChangeAction::Insert:
                exit(SPBDBraiderConfig."Insert Allowed");
            SPBDBraiderChangeAction::Update:
                exit(SPBDBraiderConfig."Modify Allowed");
            SPBDBraiderChangeAction::Upsert:
                exit(SPBDBraiderConfig."Insert Allowed" and SPBDBraiderConfig."Modify Allowed");
            SPBDBraiderChangeAction::Delete:
                exit(SPBDBraiderConfig."Delete Allowed");
        end;
    end;

    local procedure ApplyPossibleParentData(var TempContentJsonBuffer: Record "JSON Buffer" temporary; var TargetRecordRef: RecordRef)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineRelation: Record "SPB DBraider ConfLine Relation";
        ParentRecordRef: RecordRef;
        ChildFieldRef: FieldRef;
        ParentFieldRef: FieldRef;
    begin
        if SPBDBraiderConfigLine.Get(TempContentJsonBuffer."SPB Config. Code", TempContentJsonBuffer."SPB Config. Line No.") then begin
            SPBDBraiderConfLineRelation.SetRange("Config. Code", TempContentJsonBuffer."SPB Config. Code");
            SPBDBraiderConfLineRelation.SetRange("Config. Line No.", TempContentJsonBuffer."SPB Config. Line No.");
            SPBDBraiderConfLineRelation.SetRange("Child Table", TempContentJsonBuffer."SPB Table No.");
            if SPBDBraiderConfLineRelation.FindSet() then
                repeat
                    // Get the Field configuration for the Child Field, as we need to see if we'll be validating the Parent Field.
                    SPBDBraiderConfLineField.SetRange("Config. Code", TempContentJsonBuffer."SPB Config. Code");
                    SPBDBraiderConfLineField.SetRange("Config. Line No.", TempContentJsonBuffer."SPB Config. Line No.");
                    SPBDBraiderConfLineField.SetRange("Field No.", SPBDBraiderConfLineRelation."Child Field No.");
                    SPBDBraiderConfLineField.FindFirst();

                    // Locate the Parent Table, then find the Record GUID in the Map.  Load the record ref,
                    // then apply the parent field value to the TargetRecordRef's child field.
                    if LastRecordPosition.ContainsKey(SPBDBraiderConfLineRelation."Parent Table") then begin
                        ParentRecordRef.Open(SPBDBraiderConfLineRelation."Parent Table");
                        ParentRecordRef.SetPosition(LastRecordPosition.Get(ParentRecordRef.Number()));
                        if ParentRecordRef.Find('=') then begin
                            ParentFieldRef := ParentRecordRef.Field(SPBDBraiderConfLineRelation."Parent Field No.");
                            ChildFieldRef := TargetRecordRef.Field(SPBDBraiderConfLineRelation."Child Field No.");
                            //TODO: Consider an Advanced Setting to control this behavior
                            if SPBDBraiderConfLineField."Disable Validation" = SPBDBraiderConfLineField."Disable Validation"::DisableAll then
                                ChildFieldRef.Value := ParentFieldRef.Value() else
                                ChildFieldRef.Validate(ParentFieldRef.Value());
                        end;
                        ParentRecordRef.Close();
                    end;
                //SPBDBraiderUtilities.TrySafeValidateValue(TargetRecordRef, SPBDBraiderConfLineRelation."Field No.", SPBDBraiderConfLineRelation."Default Value");
                until SPBDBraiderConfLineRelation.Next() = 0;
        end;
    end;

    local procedure ApplyInferredParentData(var TempContentJsonBuffer: Record "JSON Buffer" temporary; var TargetRecordRef: RecordRef; LocatedKeyFields: Dictionary of [Integer, Text]; MissingKeyFields: List of [Integer])
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineRelation: Record "SPB DBraider ConfLine Relation";
        ParentRecordRef: RecordRef;
        ChildFieldRef: FieldRef;
        ParentFieldRef: FieldRef;
        FieldNo: Integer;
        InferredFields: List of [Integer];
    begin
        // So, here we may have Missing Fields on the Child data.   Let's iterate through them and see if they're inferred from the parent.
        foreach FieldNo in MissingKeyFields do
            if SPBDBraiderConfigLine.Get(TempContentJsonBuffer."SPB Config. Code", TempContentJsonBuffer."SPB Config. Line No.") then begin
                SPBDBraiderConfLineRelation.SetRange("Config. Code", TempContentJsonBuffer."SPB Config. Code");
                SPBDBraiderConfLineRelation.SetRange("Config. Line No.", TempContentJsonBuffer."SPB Config. Line No.");
                SPBDBraiderConfLineRelation.SetRange("Child Table", TempContentJsonBuffer."SPB Table No.");
                SPBDBraiderConfLineRelation.SetRange("Child Field No.", FieldNo);
                if SPBDBraiderConfLineRelation.FindSet() then
                    repeat
                        // Locate the Parent Table, then find the Record GUID in the Map.  Load the record ref,
                        // then apply the parent field value to the TargetRecordRef's child field.
                        if LastRecordPosition.ContainsKey(SPBDBraiderConfLineRelation."Parent Table") then begin
                            ParentRecordRef.Open(SPBDBraiderConfLineRelation."Parent Table");
                            ParentRecordRef.SetPosition(LastRecordPosition.Get(ParentRecordRef.Number()));
                            if ParentRecordRef.Find('=') then begin
                                ParentFieldRef := ParentRecordRef.Field(SPBDBraiderConfLineRelation."Parent Field No.");
                                LocatedKeyFields.Add(FieldNo, ParentFieldRef.Value());
                                InferredFields.Add(FieldNo);
                            end;
                            ParentRecordRef.Close();
                        end;
                    until SPBDBraiderConfLineRelation.Next() = 0;
            end;
        foreach FieldNo in InferredFields do
            MissingKeyFields.Remove(FieldNo);
    end;

    local procedure ChooseValidateFieldValue(var TempContentJsonBuffer: Record "JSON Buffer" temporary; InternalActionType: Enum "SPB DBraider Change Action"; var DestinationRecordRef: RecordRef; FieldNo: Integer; NewValue: Variant)
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
    begin
        SPBDBraiderConfLineField.SetRange("Config. Code", TempContentJsonBuffer."SPB Config. Code");
        SPBDBraiderConfLineField.SetRange("Config. Line No.", TempContentJsonBuffer."SPB Config. Line No.");
        SPBDBraiderConfLineField.SetRange("Field No.", FieldNo);
        SPBDBraiderConfLineField.FindFirst();

        // If we're dealing with a Modify, and the field is unchanged, we may not want to re-validate it.
        if InternalActionType = InternalActionType::Update then
            if not SPBDBraiderConfLineField."Modification Re-Validate" then
                if Format(DestinationRecordRef.Field(FieldNo).Value()) = Format(NewValue) then
                    exit;

        if SPBDBraiderConfLineField."Disable Validation" = SPBDBraiderConfLineField."Disable Validation"::DisableAll then
            SPBDBraiderUtilities.SetUnvalidatedValue(DestinationRecordRef, TempContentJsonBuffer."SPB Field No.", TempContentJsonBuffer.Value)
        else
            SPBDBraiderUtilities.ValidateValue(DestinationRecordRef, TempContentJsonBuffer."SPB Field No.", TempContentJsonBuffer.Value)
    end;

    local procedure CheckAndHandleAutoSplitKey(var TempContentJsonBuffer: Record "JSON Buffer" temporary; TargetRecordRef: RecordRef)
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TargetRecordRef2: RecordRef;
        DestRecordLastFieldRef: FieldRef;
        TargetFieldRef1: FieldRef;
        TargetFieldRef2: FieldRef;
        i: Integer;
        LastFieldNo: Integer;
        NextLineNo: Integer;
        PrimaryKeyFields: List of [Integer];
    begin
        PrimaryKeyFields := SPBDBraiderUtilities.GetPrimaryKeyFields(TargetRecordRef);
        LastFieldNo := PrimaryKeyFields.Get(PrimaryKeyFields.Count());
        DestRecordLastFieldRef := TargetRecordRef.Field(LastFieldNo);
        if DestRecordLastFieldRef.Type() = FieldType::Integer then
            // Disable check from the Field settings on the ConfLine Field table
            if SPBDBraiderConfLineField.Get(TempContentJsonBuffer."SPB Config. Code", TempContentJsonBuffer."SPB Config. Line No.", LastFieldNo) then
                if SPBDBraiderConfLineField."Disable Auto-Split Key" then
                    exit;

        if Evaluate(i, Format(DestRecordLastFieldRef.Value())) then
            // if the last field is an integer with a value of zero:
            if i = 0 then begin
                // Find the 'last' record in the table with the other PK values if possible
                TargetRecordRef2.Open(TargetRecordRef.Number());
                if PrimaryKeyFields.Count() > 1 then
                    for i := 1 to (PrimaryKeyFields.Count() - 1) do begin
                        TargetFieldRef1 := TargetRecordRef.Field(PrimaryKeyFields.Get(i));
                        TargetFieldRef2 := TargetRecordRef2.Field(PrimaryKeyFields.Get(i));
                        TargetFieldRef2.SetFilter(Format(TargetFieldRef1.Value()));
                    end;
                if TargetRecordRef2.FindLast() then
                    Evaluate(NextLineNo, Format(TargetRecordRef2.Field(LastFieldNo).Value()))
                else
                    NextLineNo := 0;
                NextLineNo += 10000;
                DestRecordLastFieldRef.Validate(NextLineNo);
                TargetRecordRef2.Close();
            end;
    end;

    internal procedure GetResults(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"): JsonArray
    begin
        SPBDBraiderConfigHeader.RegisterWriteUsage(RecordsAffected);
        exit(JsonResultArray);
    end;

    internal procedure SetLastRecord(WhichTable: Integer; RecordPosition: Text)
    begin
        if not LastRecordPosition.ContainsKey(WhichTable) then
            LastRecordPosition.Add(WhichTable, RecordPosition)
        else
            LastRecordPosition.Set(WhichTable, RecordPosition);
    end;

    internal procedure SetLastRecord(WhichRecordRef: RecordRef)
    begin
        SetLastRecord(WhichRecordRef.Number(), WhichRecordRef.GetPosition());
    end;

    procedure SetConfigHeader(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    begin
        GlobalConfigHeader := SPBDBraiderConfigHeader;
    end;

    local procedure BuildDiagnostics(var TempResultRow: Record "SPB DBraider Resultset Row" temporary; var TempResultCol: Record "SPB DBraider Resultset Col" temporary) DiagJson: JsonObject
    var
        RowsArray: JsonArray;
        ColsArray: JsonArray;
        RowJson: JsonObject;
        ColJson: JsonObject;
    begin
        // Build rows array
        if TempResultRow.FindSet() then
            repeat
                Clear(RowJson);
                RowJson.Add('RowNo', TempResultRow."Row No.");
                RowJson.Add('ConfigCode', TempResultRow."Config. Code");
                RowJson.Add('BelongsToRowNo', TempResultRow."Belongs To Row No.");
                RowJson.Add('BufferType', Format(TempResultRow."Buffer Type"));
                RowJson.Add('DataMode', Format(TempResultRow."Data Mode"));
                RowJson.Add('DeltaType', Format(TempResultRow."Delta Type"));
                TempResultRow.CalcFields("Source Table Name");
                RowJson.Add('SourceTableName', TempResultRow."Source Table Name");
                RowsArray.Add(RowJson);
            until TempResultRow.Next() = 0;

        // Build cols array
        if TempResultCol.FindSet() then
            repeat
                Clear(ColJson);
                ColJson.Add('RowNo', TempResultCol."Row No.");
                ColJson.Add('ColNo', TempResultCol."Column No.");
                ColJson.Add('FieldName', TempResultCol."Field Name");
                ColJson.Add('ForcedFieldCaption', TempResultCol."Forced Field Caption");
                ColJson.Add('DataType', Format(TempResultCol."Data Type"));
                ColJson.Add('ValueAsText', TempResultCol."Value as Text");
                ColJson.Add('WriteResultRecord', TempResultCol."Write Result Record");
                ColsArray.Add(ColJson);
            until TempResultCol.Next() = 0;

        DiagJson.Add('rows', RowsArray);
        DiagJson.Add('cols', ColsArray);
        DiagJson.Add('rowCount', TempResultRow.Count());
        DiagJson.Add('colCount', TempResultCol.Count());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWriteResultRecord(DBraiderConfig: Record "SPB DBraider Config. Header"; var TempContentJsonBuffer: Record "JSON Buffer" temporary; var TempResultRow: Record "SPB DBraider Resultset Row" temporary; var TempResultCol: Record "SPB DBraider Resultset Col" temporary)
    begin
    end;
}
