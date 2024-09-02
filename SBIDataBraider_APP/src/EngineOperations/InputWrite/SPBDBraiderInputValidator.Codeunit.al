codeunit 71033605 "SPB DBraider Input Validator"
{
    TableNo = "JSON Buffer";

    var
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";

    trigger OnRun()
    begin
        ProcessInputBuffer(Rec);
    end;

    procedure ProcessInputBuffer(var TempJsonBuffer: Record "JSON Buffer" temporary)
    var
        TempMapJsonBuffer: Record "JSON Buffer" temporary;
        TempStartRecordJsonBuffer: Record "JSON Buffer" temporary;
        TempMatches: Record Matches temporary;
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        Regex: Codeunit Regex;
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        TargetTableRecordRef: array[100] of RecordRef;
        AllDataValid: Boolean;
        CurrentDepth: Integer;
        CurrentInputRow: Integer;
        FieldNo: Integer;
        PriorDepth: Integer;
        PriorTableNo: Integer;
        TableNo: Integer;
        MandatoryFieldMissingLbl: Label 'Mandatory field %1.%2 is missing', Comment = '%1 = Table Name, %2 = Field Name';
        NotWriteEnabledLbl: Label 'Table.Field %1.%2 is not write enabled.', Comment = '%1 = Table Name, %2 = Field Name';
        PrimaryKeyMustBeFilledLbl: Label 'The following fields are all part of the primary key of %1 and must all be set: %2', Comment = '%1 = Table to match, %2 = Primary Key Field';
        TokenTypeLbl: Label '%1|%2|%3|%4|%5|%6', Comment = '%1 = Boolean, %2 = Decimal, %3 = Integer, %4 = String, %5 = Start Object, %6 = End Object';
        UnableToMatchTableAndFieldLbl: Label 'Unable to match on Table.Field %1.%2', Comment = '%1 = Table Name, %2 = Field Name';
        UnableToValidateTableAndFieldLbl: Label 'Unable to validate on Table.Field %1.%2. Reason: %3', Comment = '%1 = Table Name, %2 = Field Name, %3 = the BC error message';
        UnknownActionTypeLbl: Label 'Unknown Action Type: %1', Comment = '%1 = Action Type';
        ValidationOKLbl: Label 'Validation OK on Table.Field %1.%2', Comment = '%1 = Table Name, %2 = Field Name';
        MandatoryFields: List of [Integer];
        PrimaryKeyFields: List of [Integer];
        FieldNameToMatch: Text;
        TableNameToMatch: Text;
        TokenTypeFilter: Text;
    begin
        AllDataValid := true;
        TempMapJsonBuffer.Copy(TempJsonBuffer, true);
        TempMapJsonBuffer.SetRange("SPB Mapping Record", true);

        /* Iterate through the submitted data */
        TempJsonBuffer.SetRange("SPB Mapping Record", false);
        TokenTypeFilter := StrSubstNo(TokenTypeLbl, TempJsonBuffer."Token type"::Boolean,
            TempJsonBuffer."Token type"::Decimal, TempJsonBuffer."Token type"::Integer,
            TempJsonBuffer."Token type"::String, TempJsonBuffer."Token type"::"Start Object",
            TempJsonBuffer."Token type"::"End Object");
        TempJsonBuffer.SetFilter("Token type", TokenTypeFilter);
        if TempJsonBuffer.FindSet() then
            repeat
                if (TempJsonBuffer."SPB Config. Code" <> '') and (SPBDBraiderConfigHeader.Code <> TempJsonBuffer."SPB Config. Code") then
                    SPBDBraiderConfigHeader.Get(TempJsonBuffer."SPB Config. Code");

                case TempJsonBuffer."Token type" of
                    TempJsonBuffer."Token type"::"Start Object":
                        begin
                            // Beginning of a new 'record' of info.
                            CurrentInputRow := SPBDBraiderJSONUtilities.ExtractNumber(TempJsonBuffer.Path);
                            TempJsonBuffer."SPB Record Id" := CurrentInputRow;
                            TempJsonBuffer.Modify();
                            TempStartRecordJsonBuffer.Copy(TempJsonBuffer, true);
                        end;
                    TempJsonBuffer."Token type"::"End Object":
                        begin
                            TempJsonBuffer."SPB Record Id" := CurrentInputRow;
                            TempJsonBuffer.Modify();
                            if SPBDBraiderConfigHeader."Require PK" then
                                if not ValidatePrimaryKeyFields(TargetTableRecordRef[1]) then begin
                                    SPBDBraiderErrorSystem.AddError(CurrentInputRow, StrSubstNo(PrimaryKeyMustBeFilledLbl, TableNameToMatch, SPBDBraiderUtilities.GetPrimaryKeyFieldNames(TargetTableRecordRef[1])));  // note this does field names, not captions
                                    AllDataValid := false;
                                end;
                        end;
                    else begin
                        TempJsonBuffer."SPB Record Id" := CurrentInputRow;
                        TempJsonBuffer.Modify();
                        Clear(TableNo);
                        Clear(FieldNo);

                        // Check for an 'Action' Path, path will contain "[x].Action"
                        TempMatches.DeleteAll();
                        Regex.Match(UpperCase(TempJsonBuffer.Path), '\[\d*\]\.(ACTION)', 0, TempMatches);

                        if (TempMatches.FindFirst()) then begin
                            if not Evaluate(TempJsonBuffer."SPB Record Action", TempJsonBuffer.Value) then
                                SPBDBraiderErrorSystem.AddError(CurrentInputRow, StrSubstNo(UnknownActionTypeLbl, TempJsonBuffer.Value));
                            TempStartRecordJsonBuffer."SPB Record Action" := TempJsonBuffer."SPB Record Action";
                            TempStartRecordJsonBuffer.Modify();
                        end else begin
                            TempMatches.DeleteAll();
                            Regex.Match(TempJsonBuffer.Path, '(\w+)\.(\w+)', 0, TempMatches);
                            SPBDBraiderJSONUtilities.ExtractPathFromMatches(TableNameToMatch, FieldNameToMatch, TempMatches);
                            TempMapJsonBuffer.SetRange("SPB Source Table Name", TableNameToMatch);
                            if TempMapJsonBuffer.FindFirst() then
                                TableNo := TempMapJsonBuffer."SPB Table No.";

                            // Try to find which Field to match on by name first, then caption
                            TempMapJsonBuffer.SetFilter("SPB Source Field Name", FieldNameToMatch);
                            if TempMapJsonBuffer.FindFirst() then
                                FieldNo := TempMapJsonBuffer."SPB Field No."
                            else begin
                                TempMapJsonBuffer.SetRange("SPB Source Field Name");
                                TempMapJsonBuffer.SetFilter("SPB Source Field Caption", FieldNameToMatch);
                                if TempMapJsonBuffer.FindFirst() then
                                    FieldNo := TempMapJsonBuffer."SPB Field No."
                            end;
                            if FieldNo = 0 then begin
                                TempMapJsonBuffer.SetFilter("SPB Source Field Name", '@' + FieldNameToMatch);  //NOT Case sensitive
                                if TempMapJsonBuffer.FindFirst() then
                                    FieldNo := TempMapJsonBuffer."SPB Field No."
                                else begin
                                    TempMapJsonBuffer.SetRange("SPB Source Field Name");
                                    TempMapJsonBuffer.SetFilter("SPB Source Field Caption", '@' + FieldNameToMatch);  //NOT Case sensitive
                                    if TempMapJsonBuffer.FindFirst() then
                                        FieldNo := TempMapJsonBuffer."SPB Field No."
                                end;
                            end;
                            // Clear some mapping filters
                            TempMapJsonBuffer.SetRange("SPB Source Table Name");
                            TempMapJsonBuffer.SetRange("SPB Source Field Name");
                            TempMapJsonBuffer.SetRange("SPB Source Field Caption");


                            if (TableNo <> 0) and (FieldNo <> 0) then begin
                                CurrentDepth := TempMapJsonBuffer.Depth;
                                if TableNo <> PriorTableNo then begin
                                    if PriorTableNo <> 0 then begin
                                        if CurrentDepth <> 0 then
                                            PriorDepth := CurrentDepth;
                                        if PriorDepth <> 0 then
                                            TargetTableRecordRef[1].Close()
                                        else
                                            TargetTableRecordRef[1].Close();
                                    end;
                                    PriorTableNo := TableNo;
                                    TargetTableRecordRef[1].Open(TableNo, true);
                                    //ApplyDefaultsToRecord(TargetTableRecordRef[1], TempMapJsonBuffer."SPB Config. Code", TempMapJsonBuffer."SPB Config. Line No.");
                                    PrimaryKeyFields := SPBDBraiderUtilities.GetPrimaryKeyFields(TargetTableRecordRef[1]);
                                end;

                                // Update the Buffer entry with the Table/field no so we have it later, along with configs
                                TempJsonBuffer."SPB Table No." := TableNo;
                                TempJsonBuffer."SPB Source Table Name" := TempMapJsonBuffer."SPB Source Table Name";
                                TempJsonBuffer."SPB Source Field Name" := TempMapJsonBuffer."SPB Source Field Name";
                                TempJsonBuffer."SPB Field No." := FieldNo;
                                TempJsonBuffer."SPB Write Enabled" := TempMapJsonBuffer."SPB Write Enabled";
                                TempJsonBuffer."SPB Config. Code" := TempMapJsonBuffer."SPB Config. Code";
                                TempJsonBuffer."SPB Config. Line No." := TempMapJsonBuffer."SPB Config. Line No.";
                                TempJsonBuffer."SPB Config. Field No." := TempMapJsonBuffer."SPB Config. Field No.";
                                TempJsonBuffer."SPB Primary Key Field" := PrimaryKeyFields.Contains(FieldNo);
                                TempJsonBuffer."SPB Processing Order" := TempMapJsonBuffer."SPB Processing Order";
                                TempJsonBuffer.Modify();

                                // Update the "Start Object" record with the config code
                                TempStartRecordJsonBuffer."SPB Config. Code" := TempMapJsonBuffer."SPB Config. Code";
                                TempStartRecordJsonBuffer."SPB Config. Line No." := TempMapJsonBuffer."SPB Config. Line No.";
                                TempStartRecordJsonBuffer.Modify();
                                if (not TempMapJsonBuffer."SPB Write Enabled") and IsWriteAction(TempJsonBuffer, TempStartRecordJsonBuffer."SPB Record Action") then begin
                                    SPBDBraiderErrorSystem.AddError(CurrentInputRow, StrSubstNo(NotWriteEnabledLbl, TableNameToMatch, FieldNameToMatch));
                                    AllDataValid := false;
                                end
                                else
                                    if TempMapJsonBuffer."SPB Disable Validate" = TempMapJsonBuffer."SPB Disable Validate"::" " then begin
                                        ClearLastError();
                                        if SPBDBraiderUtilities.ValidateFieldTypeAndLength(TargetTableRecordRef[1], FieldNo, TempJsonBuffer.Value) then
                                            SPBDBraiderErrorSystem.AddDebug(CurrentInputRow, StrSubstNo(ValidationOKLbl, TableNameToMatch, FieldNameToMatch))
                                        else begin
                                            SPBDBraiderErrorSystem.AddError(CurrentInputRow, StrSubstNo(UnableToValidateTableAndFieldLbl, TableNameToMatch, FieldNameToMatch, GetLastErrorText()));
                                            AllDataValid := false;
                                        end;
                                    end;
                            end else begin
                                SPBDBraiderErrorSystem.AddError(CurrentInputRow, StrSubstNo(UnableToMatchTableAndFieldLbl, TableNameToMatch, FieldNameToMatch));
                                AllDataValid := false;
                            end;
                        end;
                    end;
                end;
            until TempJsonBuffer.Next() = 0;

        // For each record, check for mandatory fields if any
        TempJsonBuffer.Reset();
        TempJsonBuffer.SetRange("SPB Mapping Record", false);
        TempMapJsonBuffer.Reset();
        TempMapJsonBuffer.SetRange("SPB Mapping Record", true);
        TempStartRecordJsonBuffer.Reset();
        TempStartRecordJsonBuffer.SetRange("SPB Mapping Record", false);
        TempStartRecordJsonBuffer.SetRange("Token type", TempStartRecordJsonBuffer."Token type"::"Start Object");
        if TempStartRecordJsonBuffer.FindSet() then
            repeat
                // Build a List of the Field Numbers that are mandatory for this config line
                MandatoryFields := SPBDBraiderUtilities.GetMandatoryFieldsForConfig(TempStartRecordJsonBuffer."SPB Config. Code", TempStartRecordJsonBuffer."SPB Config. Line No.");
                if MandatoryFields.Count <> 0 then begin
                    // The TempMapJsonBuffer is a way to see what the Table/Field Names are, so prep the filters
                    TempMapJsonBuffer.SetRange("SPB Record Id", TempStartRecordJsonBuffer."SPB Record Id");
                    TempMapJsonBuffer.SetRange("SPB Config. Code", TempStartRecordJsonBuffer."SPB Config. Code");
                    TempMapJsonBuffer.SetRange("SPB Config. Line No.", TempStartRecordJsonBuffer."SPB Config. Line No.");

                    // Now, for each mandatory field, see if it exists in the submitted data for *this* record ID
                    TempJsonBuffer.SetRange("SPB Record Id", TempStartRecordJsonBuffer."SPB Record Id");
                    TempJsonBuffer.SetRange("SPB Config. Code", TempStartRecordJsonBuffer."SPB Config. Code");
                    TempJsonBuffer.SetRange("SPB Config. Line No.", TempStartRecordJsonBuffer."SPB Config. Line No.");
                    foreach FieldNo in MandatoryFields do begin
                        // Make sure our 'map' entry has the info we'll want
                        TempMapJsonBuffer.SetRange("SPB Field No.", FieldNo);
                        if TempMapJsonBuffer.FindFirst() then;
                        TempJsonBuffer.SetRange("SPB Config. Field No.", FieldNo);
                        // if the field isn't *present* at all, then it's missing
                        if not TempJsonBuffer.FindFirst() then begin
                            SPBDBraiderErrorSystem.AddError(TempStartRecordJsonBuffer."SPB Record Id", StrSubstNo(MandatoryFieldMissingLbl, TempMapJsonBuffer."SPB Source Table Name", TempMapJsonBuffer."SPB Source Field Name"));
                            AllDataValid := false;
                        end else
                            // if the field is present, but has no value, then it's also considered missing
                            if TempJsonBuffer.Value = '' then begin
                                SPBDBraiderErrorSystem.AddError(TempStartRecordJsonBuffer."SPB Record Id", StrSubstNo(MandatoryFieldMissingLbl, TempMapJsonBuffer."SPB Source Table Name", TempMapJsonBuffer."SPB Source Field Name"));
                                AllDataValid := false;
                            end;
                    end;
                end;
            until TempStartRecordJsonBuffer.Next() = 0;

        // Reset the filters
        TempJsonBuffer.Reset();
        TempJsonBuffer.SetRange("SPB Mapping Record", false);

        if not AllDataValid then
            Error('');
    end;

    local procedure ValidatePrimaryKeyFields(TargetTableRecordRef: RecordRef) AllFieldsOK: Boolean
    var
        TempSampleRecordRef: RecordRef;
        SampleFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
        i: Integer;
        TargetKeyRef: KeyRef;
    begin
        // Initialize a Temporary (and blank) rec from the same table to get the InitValue for comparison
        TempSampleRecordRef.Open(TargetTableRecordRef.Number, true);

        AllFieldsOK := true;

        TargetKeyRef := TargetTableRecordRef.KeyIndex(1);  // Primary Key
        for i := 1 to TargetKeyRef.FieldCount do begin
            TargetFieldRef := TargetKeyRef.FieldIndex(i);
            SampleFieldRef := TempSampleRecordRef.FieldIndex(i);
            AllFieldsOK := AllFieldsOK and (Format(TargetFieldRef.Value) <> Format(SampleFieldRef.Value));
        end;
    end;

    local procedure IsWriteAction(var TempJsonBuffer: Record "JSON Buffer" temporary; SPBRecordAction: Enum "SPB DBraider Change Action") WriteAction: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeIsWriteAction(SPBRecordAction, TempJsonBuffer, WriteAction, IsHandled);
        if not IsHandled then
            WriteAction := SPBRecordAction in [SPBRecordAction::Insert, SPBRecordAction::Update, SPBRecordAction::Upsert];
    end;

    local procedure ApplyDefaultsToRecord(var TargetTableRecordRef: RecordRef; SPBConfigCode: Code[20]; SPBConfigLineNo: Integer)
    var
        SPBDBraiderWriteData: Codeunit "SPB DBraider Write Data";
    begin
        SPBDBraiderWriteData.ApplyDefaults(SPBConfigCode, SPBConfigLineNo, TargetTableRecordRef);
    end;



    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsWriteAction(SPBRecordAction: Enum "SPB DBraider Change Action"; var TempJsonBuffer: Record "JSON Buffer" temporary; var WriteAction: Boolean; var IsHandled: Boolean)
    begin
    end;

}
