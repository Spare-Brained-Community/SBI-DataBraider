codeunit 71033608 "SPB DBraider Utilities"
{
    Access = Internal;


    [TryFunction]
    internal procedure TrySafeValidateValue(var DestinationRecordRef: RecordRef; FieldNo: Integer; NewValue: Variant)
    var
        DestinationFieldRef: FieldRef;
    begin
        DestinationFieldRef := DestinationRecordRef.Field(FieldNo);
        if DestinationFieldRef.Type = FieldType::Option then begin
            Evaluate(DestinationFieldRef, NewValue);
            DestinationFieldRef.Validate();
        end else
            DestinationFieldRef.Validate(NewValue);
    end;

    internal procedure ValidateValue(var DestinationRecordRef: RecordRef; FieldNo: Integer; NewValue: Variant)
    var
        DestinationFieldRef: FieldRef;
    begin
        DestinationFieldRef := DestinationRecordRef.Field(FieldNo);
        if DestinationFieldRef.Type = FieldType::Option then begin
            Evaluate(DestinationFieldRef, NewValue);
            DestinationFieldRef.Validate();
        end else
            DestinationFieldRef.Validate(NewValue);
    end;

    internal procedure ValidateFieldTypeAndLength(var DestinationRecordRef: RecordRef; FieldNo: Integer; NewValue: Variant): Boolean
    var
        DestinationFieldRef: FieldRef;
        dateValue: Date;
        dateTimeValue: DateTime;
        dec: Decimal;
        int: Integer;
        timeValue: Time;

    begin
        DestinationFieldRef := DestinationRecordRef.Field(FieldNo);
        case DestinationFieldRef.Type of
            FieldType::Code, FieldType::Text:
                exit(StrLen(NewValue) <= DestinationFieldRef.Length);
            FieldType::Integer:
                exit(Evaluate(int, NewValue));
            FieldType::Decimal:
                exit(Evaluate(dec, NewValue));
            FieldType::Date:
                exit(Evaluate(dateValue, NewValue));
            FieldType::Time:
                exit(Evaluate(timeValue, NewValue));
            FieldType::DateTime:
                exit(Evaluate(dateTimeValue, NewValue));
        end;
    end;

    internal procedure GetPrimaryKeyFieldNames(var TargetTableRecordRef: RecordRef) FieldNamesList: Text
    var
        TargetFieldRef: FieldRef;
        i: Integer;
        TargetKeyRef: KeyRef;
    begin
        TargetKeyRef := TargetTableRecordRef.KeyIndex(1);  // Primary Key
        for i := 1 to TargetKeyRef.FieldCount do begin
            TargetFieldRef := TargetKeyRef.FieldIndex(i);
            if FieldNamesList = '' then
                FieldNamesList := TargetFieldRef.Name
            else
                FieldNamesList := FieldNamesList + ', ' + TargetFieldRef.Name;
        end;
    end;

    internal procedure GetPrimaryKeyFields(var TargetTableRecordRef: RecordRef) FieldNumbers: List of [Integer]
    var
        TargetFieldRef: FieldRef;
        i: Integer;
        TargetKeyRef: KeyRef;
    begin
        TargetKeyRef := TargetTableRecordRef.KeyIndex(1);  // Primary Key
        for i := 1 to TargetKeyRef.FieldCount do begin
            TargetFieldRef := TargetKeyRef.FieldIndex(i);
            FieldNumbers.Add(TargetFieldRef.Number);
        end;
    end;

    internal procedure AttemptToAutoRelate(ParentTableNo: Integer; ChildTableNo: Integer) FieldConnection: Dictionary of [Integer, Integer]
    var
        Fields: Record Field;
        ParentTableRecordRef: RecordRef;
        ParentPKFieldNumber: Integer;
        ParentPKFieldNumbers: List of [Integer];
    begin
        // There is a Virtual Table for Table Relationship, which for some daffy reason Microsoft won't allow us to use in Cloud, so this is best fallback
        ParentTableRecordRef.Open(ParentTableNo);
        ParentPKFieldNumbers := GetPrimaryKeyFields(ParentTableRecordRef);
        foreach ParentPKFieldNumber in ParentPKFieldNumbers do begin
            Fields.SetRange(TableNo, ChildTableNo);
            Fields.SetRange(RelationTableNo, ParentTableNo);
            Fields.SetRange(RelationFieldNo, ParentPKFieldNumber);
            if Fields.FindFirst() then   //if it's related to a specific field
                FieldConnection.Add(Fields.RelationFieldNo, Fields."No.")
            else begin
                // Table relations to a single PK have a RelationFieldNo of 0
                Fields.SetRange(RelationFieldNo, 0);
                if Fields.FindFirst() then   //if it's related to a specific field
                    FieldConnection.Add(ParentPKFieldNumber, Fields."No.")
            end;
        end;

        if Fields.Count = 0 then
            // Suuuuuper ugly, hard-coding some of these because we have little choice
            case ParentTableNo of
                36:  // Sales Header


                    if (ChildTableNo = 37) then begin
                        FieldConnection.Add(1, 1);
                        FieldConnection.Add(3, 3);
                    end;
                38:  // Purchase Header


                    if (ChildTableNo = 39) then begin
                        FieldConnection.Add(1, 3);
                        FieldConnection.Add(3, 3);
                    end;
                110:  // Sales Shipment Header


                    if (ChildTableNo = 111) then
                        FieldConnection.Add(3, 3);
                112:  // Sales Invoice Header


                    if (ChildTableNo = 113) then
                        FieldConnection.Add(3, 3);
                114:  // Sales Credit Memo Header


                    if (ChildTableNo = 115) then
                        FieldConnection.Add(3, 3);
                120:  // Purchase Receipt Header


                    if (ChildTableNo = 121) then
                        FieldConnection.Add(3, 3);
                122:  // Purchase Invoice Header


                    if (ChildTableNo = 123) then
                        FieldConnection.Add(3, 3);
                124:  // Purchase Credit Memo Header


                    if (ChildTableNo = 125) then
                        FieldConnection.Add(3, 3);
            end;
    end;

    procedure GetMandatoryFieldsForConfig(ConfigCode: Code[20]; LineNo: Integer) Result: List of [Integer]
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
    begin
        SPBDBraiderConfigHeader.SetRange(Code, ConfigCode);
        if SPBDBraiderConfigHeader.FindFirst() then begin
            SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
            SPBDBraiderConfigLine.SetRange("Line No.", LineNo);
            if SPBDBraiderConfigLine.FindFirst() then begin
                SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                SPBDBraiderConfLineFields.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                SPBDBraiderConfLineFields.SetRange(Mandatory, true);
                if SPBDBraiderConfLineFields.FindSet() then
                    repeat
                        Result.Add(SPBDBraiderConfLineFields."Field No.");
                    until SPBDBraiderConfLineFields.Next() = 0;
            end;
        end;
    end;

    procedure GetTelemetryFigures(var Results: Dictionary of [Text, Decimal])
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        ReadsTally: BigInteger;
        WritesTally: BigInteger;
    begin
        // Gather current month figures first
        if SPBDBraiderConfigHeader.FindSet(false) then
            repeat
                SPBDBraiderConfigHeader.SetRange("Date Filter", CalcDate('<-CM>', Today), CalcDate('<CM>', Today));
                SPBDBraiderConfigHeader.CalcFields(Usage, "Rows Read", "Rows Written");
                ReadsTally += SPBDBraiderConfigHeader."Rows Read";
                WritesTally += SPBDBraiderConfigHeader."Rows Written";
            until SPBDBraiderConfigHeader.Next() = 0;
        Results.Set('TotalReadsCM', ReadsTally);
        Results.Set('TotalWritesCM', WritesTally);
        Results.Set('AvgReadsCM', Round(ReadsTally / SPBDBraiderConfigHeader.Count, 0.01));
        Results.Set('AvgWritesCM', Round(WritesTally / SPBDBraiderConfigHeader.Count, 0.01));

        // Gather total figures first
        if SPBDBraiderConfigHeader.FindSet(false) then
            repeat
                SPBDBraiderConfigHeader.SetRange("Date Filter");
                SPBDBraiderConfigHeader.CalcFields(Usage, "Rows Read", "Rows Written");
                ReadsTally += SPBDBraiderConfigHeader."Rows Read";
                WritesTally += SPBDBraiderConfigHeader."Rows Written";
            until SPBDBraiderConfigHeader.Next() = 0;
        Results.Set('TotalReadsAlltime', ReadsTally);
        Results.Set('TotalWritesAlltime', WritesTally);
        Results.Set('AvgReadsAlltime', Round(ReadsTally / SPBDBraiderConfigHeader.Count, 0.01));
        Results.Set('AvgWritesAlltime', Round(WritesTally / SPBDBraiderConfigHeader.Count, 0.01));
    end;

    procedure GetEndpointTelemetryDataJson(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") DataJson: Text;
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        DataStructureJsonArray: JsonArray;
        DataHeaderJsonObject: JsonObject;
        DataStructureJsonObject: JsonObject;
    begin
        DataHeaderJsonObject.Add('type', Format(SPBDBraiderConfigHeader."Endpoint Type"));
        DataHeaderJsonObject.Add('output', Format(SPBDBraiderConfigHeader."Output JSON Type"));
        DataHeaderJsonObject.Add('insert', Format(SPBDBraiderConfigHeader."Insert Allowed"));
        DataHeaderJsonObject.Add('modify', Format(SPBDBraiderConfigHeader."Modify Allowed"));
        DataHeaderJsonObject.Add('delete', Format(SPBDBraiderConfigHeader."Delete Allowed"));

        SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        if SPBDBraiderConfigLine.FindSet() then
            repeat
                SPBDBraiderConfigLine.CalcFields("Source Table Name");
                Clear(DataStructureJsonObject);
                DataStructureJsonObject.Add('table', SPBDBraiderConfigLine."Source Table");
                DataStructureJsonObject.Add('tablename', SPBDBraiderConfigLine."Source Table Name");
                DataStructureJsonObject.Add('fields', SPBDBraiderConfigLine."Field Count");
                DataStructureJsonObject.Add('fieldsincluded', SPBDBraiderConfigLine."Included Fields");
                DataStructureJsonObject.Add('line', SPBDBraiderConfigLine."Line No.");
                DataStructureJsonObject.Add('indentation', SPBDBraiderConfigLine.Indentation);
                DataStructureJsonArray.Add(DataStructureJsonObject.Clone());
            until SPBDBraiderConfigLine.Next() < 1;

        DataHeaderJsonObject.Add('structure', DataStructureJsonArray);

        DataHeaderJsonObject.WriteTo(DataJson);
    end;


    procedure GetJsonEndpointURI(DBHeader: Record "SPB DBraider Config. Header") Url: Text
    begin
        DBHeader.SetFilter(Code, '%1', DBHeader.Code);
        Url := GetUrl(ClientType::Api, CompanyName(), ObjectType::Page, Page::"SPB DBraider API JSON", DBHeader);
    end;

    procedure GetJsonEndpointUriNoId(DBHeader: Record "SPB DBraider Config. Header") Url: Text
    begin
        DBHeader.SetFilter(Code, '%1', DBHeader.Code);
        Url := GetUrl(ClientType::Api, CompanyName(), ObjectType::Page, Page::"SPB DBraider API JSON");
    end;

    procedure LookupSourceField(WhichTable: Integer): Integer
    begin
        exit(LookupSourceField(WhichTable, ''));
    end;

    procedure LookupSourceField(WhichTable: Integer; FieldClassFilter: Text): Integer
    var
        Fields: Record Field;
        FieldList: Page "Fields Lookup";
    begin
        Fields.SetRange(TableNo, WhichTable);
        if FieldClassFilter <> '' then
            Fields.SetFilter(Class, FieldClassFilter);
        Clear(FieldList);
        FieldList.LookupMode(true);
        FieldList.SetTableView(Fields);
        if FieldList.RunModal() in [Action::LookupOK, Action::OK] then begin
            FieldList.GetRecord(Fields);
            exit(Fields."No.");
        end;
        exit(0);
    end;

    procedure MapFieldTypeToSPBFieldDataType(SourceFieldType: FieldType) SPBFieldDataType: Enum "SPB DBraider Field Data Type"
    var
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        SPBDBraiderEvents.OnBeforeMapFieldTypeToSPBFieldDataType(IsHandled, SourceFieldType, SPBFieldDataType);
        if IsHandled then
            exit;
        case SourceFieldType of
            FieldType::Boolean:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Boolean;
            FieldType::Code:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Code;
            FieldType::Text:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Text;
            FieldType::Date:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Date;
            FieldType::Time:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Time;
            FieldType::DateTime:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Datetime;
            FieldType::Decimal:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Decimal;
            FieldType::Integer:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Integer;
            FieldType::Option:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Option;
            FieldType::Guid:
                SPBFieldDataType := "SPB DBraider Field Data Type"::Guid;
            else
                SPBFieldDataType := "SPB DBraider Field Data Type"::Unsupported;
        end;
    end;

    procedure BuildFQSI(var BreadcrumpRecordRefArray: array[100] of RecordRef; ToDepth: Integer) FQSI: Text;
    var
        i: Integer;
        FQSITextBuilder: TextBuilder;
    begin
        for i := 1 to ToDepth do begin
            if i > 1 then
                FQSITextBuilder.Append('.');
            FQSITextBuilder.Append(Format(BreadcrumpRecordRefArray[i].Field(BreadcrumpRecordRefArray[i].SystemIdNo).Value));
        end;
        FQSI := FQSITextBuilder.ToText();
    end;

    procedure TrimFQSI(InputFQSI: Text) FQSI: Text;
    var
        i: Integer;
        Parts: List of [Text];
        ThisPart: Text;
        FQSITextBuilder: TextBuilder;
    begin
        // Split the InputFSQI into an array of strings, split on the '.' character, then rejoin the array, excluding the last element. If there is only one element, return it.
        FQSI := '';
        if InputFQSI = '' then
            exit;
        Parts := InputFQSI.Split('.');
        if Parts.Count < 2 then
            exit(InputFQSI);
        for i := 1 to Parts.Count - 1 do begin
            if i > 1 then
                FQSITextBuilder.Append('.');
            Parts.Get(i, ThisPart);
            FQSITextBuilder.Append(ThisPart);
        end;
        FQSI := FQSITextBuilder.ToText();
    end;

    procedure VariableSubstitution(var TextToTransform: Text) HasSubstitutions: Boolean
    var
        SPBDBraiderVariable: Record "SPB DBraider Variable";
        Regex: Codeunit Regex;
        SplitParts: List of [Text];
        NewValue: Text;
        RegexPattern: Text;
        SplitPart: Text;
        NewTextBuilder: TextBuilder;
    begin
        // In this procedure, we will take a string, and using Regex replace any instances of {{%1}} with the value of the Tag field from the SPB DBraider Variable record

        // First, we need to find all instances of {{%1}} in the RawInputText
        RegexPattern := '\{\{|}}';
        Regex.Split(TextToTransform, RegexPattern, 0, SplitParts);

        // For each SplitParts, we'll then check the value of the Tag field in the SPB DBraider Variable record
        foreach SplitPart in SplitParts do
            if SplitPart <> '' then begin
                // Baseline filters
                SPBDBraiderVariable.Reset();
                SPBDBraiderVariable.SetRange(Tag, SplitPart);
                SPBDBraiderVariable.SetRange("Enabled", true);
                Clear(NewValue);

                // Check Environment scope first
                SPBDBraiderVariable.SetRange("Variable Scope", SPBDBraiderVariable."Variable Scope"::Environment);
                if SPBDBraiderVariable.FindFirst() then
                    NewValue := SPBDBraiderVariable.Value;

                // Now check Company given current company.  Company overrides Environment
                SPBDBraiderVariable.SetRange("Variable Scope", SPBDBraiderVariable."Variable Scope"::Company);
                SPBDBraiderVariable.SetRange("Company Name", CompanyName());
                if SPBDBraiderVariable.FindFirst() then
                    NewValue := SPBDBraiderVariable.Value;
                SPBDBraiderVariable.SetRange("Company Name");

                // Now check User given current user.  User overrides Company
                SPBDBraiderVariable.SetRange("Variable Scope", SPBDBraiderVariable."Variable Scope"::User);
                SPBDBraiderVariable.SetRange("User Name", UserId());
                if SPBDBraiderVariable.FindFirst() then
                    NewValue := SPBDBraiderVariable.Value;
                SPBDBraiderVariable.SetRange("User Name");

                // Finally, check Company and User.  Company and User overrides User
                SPBDBraiderVariable.SetRange("Variable Scope", SPBDBraiderVariable."Variable Scope"::CompanyUser);
                SPBDBraiderVariable.SetRange("Company Name", CompanyName());
                SPBDBraiderVariable.SetRange("User Name", UserId());
                if SPBDBraiderVariable.FindFirst() then
                    NewValue := SPBDBraiderVariable.Value;

                if NewValue <> '' then begin
                    NewTextBuilder.Append(NewValue);
                    HasSubstitutions := true;
                end else
                    NewTextBuilder.Append(SplitPart);
            end;

        TextToTransform := NewTextBuilder.ToText();
    end;
}
