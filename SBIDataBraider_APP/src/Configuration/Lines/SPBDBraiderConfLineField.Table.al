table 71033603 "SPB DBraider ConfLine Field"
{
    DataCaptionFields = "Table Name", "Field Name";
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Config. Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "SPB DBraider Config. Line"."Line No." where("Config. Code" = field("Config. Code"));
        }

        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            begin
                ValidateFieldNo("Field No.");
            end;
        }


        field(10; Included; Boolean)
        {
            Caption = 'Included';
            trigger OnValidate()
            begin
                if not Included then
                    "Write Enabled" := false
                else
                    "Write Enabled" := WriteableConfig();  // Let's default to Write Enabled if the endpoint is writeable
            end;
        }

        field(20; "Processing Order"; Integer)
        {
            Caption = 'Processing Order';
        }

        field(30; "Filter"; Text[250])
        {
            Caption = 'Filter';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                TestNewFilterText("Filter");
            end;
        }

        field(40; "Write Enabled"; Boolean)
        {
            Caption = 'Write Enabled';
        }
        field(41; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
        }
        field(42; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
        }
        field(43; "Upsert Match"; Boolean)
        {
            Caption = 'Upsert Match';
        }

        field(44; "Disable Validation"; Option)
        {
            Caption = 'Disable Validation';
            OptionCaption = ' ,Disable Initial,Disable All';
            OptionMembers = " ",DisableInitial,DisableAll;

            trigger OnValidate()
            var
                DisableAllCautionMsg: Label 'Using the ''Disable All'' option will disable all validation on this field. This can introduce dangerously malformed data and can result in significant expensive problems. Any damages from use of this function are your responsibility.\ \Are you CERTAIN you want to do this?';
            begin
                if "Disable Validation" = "Disable Validation"::DisableAll then
                    if not Confirm(DisableAllCautionMsg) then
                        "Disable Validation" := "Disable Validation"::" "
            end;
        }
        field(45; "Disable Auto-Split Key"; Boolean)
        {
            Caption = 'Disable Auto-Split Key';
        }
        field(46; "Modification Re-Validate"; Boolean)
        {
            Caption = 'Modification Re-Validate';
        }
        field(50; "DateTime Timezone"; Text[250])
        {
            Caption = 'DateTime Timezone';

            trigger OnValidate()
            var
                TypeHelper: Codeunit "Type Helper";
                TestDateTime: DateTime;
            begin
                TestDateTime := CurrentDateTime();
                // We should get an error if the user enters an invalid name for a timezone, I think
                TestDateTime := TypeHelper.ConvertDateTimeFromUTCToTimeZone(TestDateTime, "DateTime Timezone");
            end;
        }

        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }

        field(110; "Field Type"; Enum "SPB DBraider Field Data Type")
        {
            Caption = 'Field Type';
        }
        field(120; "Field Class"; Text[100])
        {
            Caption = 'Field Class';
        }

        field(130; "Primary Key"; Boolean)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            Description = 'Denotes if a field is part of the primary key';
            Editable = false;
        }
        field(140; "Manual Field Caption"; Text[250])
        {
            Caption = 'Manual Field Caption';

            trigger OnValidate()
            var
                SPBDBraderConfLineField2: Record "SPB DBraider ConfLine Field";
                SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
                CaptionCollisionErr: Label 'The JSON version of this caption (%1) will collide with existing field "%2". Please adjust it.', Comment = 'The %1 will be replaced with the JSON Safe version of the caption, and the %2 will be replaced with the Field Name of the field that is colliding.';
                EmptyJsonSafeCaptionErr: Label 'Manual Field Caption, when made JSON Safe, is empty.  Please enter a valid caption.';
            begin
                if "Manual Field Caption" = '' then
                    exit;

                // Manual Field Caption HAS to be JSON compliant.  If it's not, we'll make it so.
                "Manual Field Caption" := CopyStr(SPBDBraiderJSONUtilities.JsonSafeTableFieldName("Manual Field Caption"), 1, MaxStrLen("Manual Field Caption"));

                // Make sure the Manual Field Caption has some value - if the JSON Safe version is empty, throw an error
                if "Manual Field Caption" = '' then
                    Error(EmptyJsonSafeCaptionErr);

                // This caption must ALSO not be in collision with any other field captions, so we'll loop through all the other fields on this ConfLine and
                // ensure that, when those field names are JsonSafe'd, they don't match this one.
                SPBDBraderConfLineField2.SetRange("Config. Code", Rec."Config. Code");
                SPBDBraderConfLineField2.SetRange("Config. Line No.", Rec."Config. Line No.");
                SPBDBraderConfLineField2.SetFilter("Field No.", StrSubstNo('<>%1', Rec."Field No."));
                SPBDBraderConfLineField2.SetAutoCalcFields("Field Name");
                if SPBDBraderConfLineField2.FindSet() then
                    repeat
                        if (SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraderConfLineField2."Field Name") = "Manual Field Caption") then
                            Error(CaptionCollisionErr, "Manual Field Caption", SPBDBraderConfLineField2."Field Name");
                        if (SPBDBraderConfLineField2."Manual Field Caption" = "Manual Field Caption") then
                            Error(CaptionCollisionErr, "Manual Field Caption", SPBDBraderConfLineField2."Field Name");
                    until SPBDBraderConfLineField2.Next() = 0;
            end;
        }

        field(150; "Fixed Field Name"; Text[250])
        {
            Caption = 'Field Name';
            Editable = false;
        }
        field(151; "Fixed Field Caption"; Text[250])
        {
            Caption = 'Field Caption';
            Editable = false;
        }


        field(1000; Caption; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Caption (FlowField)';
            Editable = false;
            FieldClass = FlowField;
        }

        field(1001; "Field Name"; Text[250])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Caption = 'Field Name (FlowField)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1002; "Table Name"; Text[30])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Config. Code", "Config. Line No.", "Field No.")
        {
            Clustered = true;
        }
        key(Processing; "Config. Code", "Config. Line No.", "Processing Order", "Field No.")
        {

        }
    }


    local procedure TestNewFilterText(var FilterText: Text[250])
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        RecRef: RecordRef;
        FieldsRef: FieldRef;
        HasVariableSubstitution: Boolean;
        RawFilterText: Text[250];
    begin
        if (Rec."Table No." = 0) or (Rec."Field No." = 0) or (FilterText = '') then
            exit;

        // Before we apply the filter, let's run it through the Variable engine in SPB DBraider Utilities
        RawFilterText := FilterText;
        HasVariableSubstitution := SPBDBraiderUtilities.VariableSubstitution(FilterText);

        // Get the Record ref for the table
        RecRef.Open(Rec."Table No.");

        // Get the FieldRef for this field
        FieldsRef := RecRef.Field(Rec."Field No.");

        // Apply the filter to it
        FieldsRef.SetFilter(FilterText);

        // update the filter to the 'processed' value, presuming no substitution happened
        if not HasVariableSubstitution then
            FilterText := CopyStr(FieldsRef.GetFilter(), 1, MaxStrLen(FilterText))
        else
            FilterText := RawFilterText;  // Restore the filter text to the input, as we don't want to save the substituted version
    end;

    local procedure ValidateFieldNo(FieldNo: Integer)
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        RecRef: RecordRef;
        FieldsRef: FieldRef;
    begin
        if Rec."Table No." <> 0 then begin
            RecRef.Open(Rec."Table No.");
            FieldsRef := RecRef.Field(FieldNo);
            Rec."Field Type" := SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FieldsRef.Type);
            Rec."Field Class" := Format(FieldsRef.Class);
        end;
    end;

    local procedure WriteableConfig(): Boolean
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    begin
        if not SPBDBraiderConfigHeader.Get("Config. Code") then
            exit(false);

        exit(SPBDBraiderConfigHeader.WriteableConfig());
    end;

    procedure RefreshFieldList()
    var
        DBraiderConfLineFieldSBI: Record "SPB DBraider ConfLine Field";
        DBraiderConfLineFieldSBI2: Record "SPB DBraider ConfLine Field";
        TempErrorMessage: Record "Error Message" temporary;
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        RecRef: RecordRef;
        FieldsRef: FieldRef;
        i: Integer;
        PKFieldNumbers: List of [Integer];
        RefreshCount: Integer;
        FieldsAddedLbl: Label '%1 fields added to the configuration.', Comment = '%1 = label is used to display the number of fields added to the configuration.';
        MissingFldDefErr: Label 'Field %1:%2 no longer exists in the table.', Comment = '%1 = Field No., %2 = Field Name';
    begin

        if Rec."Config. Line No." <> 0 then begin
            DBraiderConfLineFieldSBI.SetRange("Config. Code", Rec."Config. Code");
            DBraiderConfLineFieldSBI.SetRange("Config. Line No.", Rec."Config. Line No.");
            // Populate the dataset
            RecRef.Open("Table No.");
            PKFieldNumbers := SPBDBraiderUtilities.GetPrimaryKeyFields(RecRef);
            for i := 1 to RecRef.FieldCount do begin
                FieldsRef := RecRef.FieldIndex(i);
                if not DBraiderConfLineFieldSBI2.Get(Rec."Config. Code", Rec."Config. Line No.", FieldsRef.Number) then begin
                    DBraiderConfLineFieldSBI.Init();
                    DBraiderConfLineFieldSBI."Config. Code" := Rec."Config. Code";
                    DBraiderConfLineFieldSBI."Config. Line No." := Rec."Config. Line No.";
                    DBraiderConfLineFieldSBI."Field No." := FieldsRef.Number;
                    DBraiderConfLineFieldSBI."Table No." := Rec."Table No.";
                    DBraiderConfLineFieldSBI."Processing Order" := 10;
                    DBraiderConfLineFieldSBI."Field Type" := SPBDBraiderUtilities.MapFieldTypeToSPBFieldDataType(FieldsRef.Type);
                    DBraiderConfLineFieldSBI."Field Class" := Format(FieldsRef.Class);
                    DBraiderConfLineFieldSBI."Primary Key" := PKFieldNumbers.Contains(FieldsRef.Number);
                    DBraiderConfLineFieldSBI.CalcFields("Field Name", Caption);
                    DBraiderConfLineFieldSBI."Fixed Field Name" := DBraiderConfLineFieldSBI."Field Name";
                    DBraiderConfLineFieldSBI."Fixed Field Caption" := DBraiderConfLineFieldSBI.Caption;
                    DBraiderConfLineFieldSBI.Insert(true);
                    RefreshCount += 1;
                end;
            end;
            if RefreshCount <> 0 then
                Message(FieldsAddedLbl, RefreshCount);
        end;
        // Now, let's log any fields that are no longer in the table
        DBraiderConfLineFieldSBI2.CopyFilters(DBraiderConfLineFieldSBI);
        Clear(FieldsRef);
        if DBraiderConfLineFieldSBI2.FindSet() then
            repeat
                if not RecRef.FieldExist(DBraiderConfLineFieldSBI2."Field No.") then begin
                    TempErrorMessage.Init();
                    TempErrorMessage.ID := DBraiderConfLineFieldSBI2."Field No.";
                    TempErrorMessage."Table Name" := CopyStr(RecRef.Name, 1, MaxStrLen(TempErrorMessage."Table Name"));
                    TempErrorMessage."Table Number" := DBraiderConfLineFieldSBI2."Table No.";
                    TempErrorMessage."Field Name" := CopyStr(DBraiderConfLineFieldSBI2."Fixed Field Name", 1, MaxStrLen(TempErrorMessage."Field Name"));
                    TempErrorMessage."Field Number" := DBraiderConfLineFieldSBI2."Field No.";
                    TempErrorMessage."Message Type" := TempErrorMessage."Message Type"::Warning;
                    TempErrorMessage.Message := StrSubstNo(MissingFldDefErr, Format(DBraiderConfLineFieldSBI2."Field No."), DBraiderConfLineFieldSBI2."Fixed Field Name");
                    TempErrorMessage.Insert();
                end;
            until DBraiderConfLineFieldSBI2.Next() = 0;
        if not TempErrorMessage.IsEmpty then
            Page.RunModal(Page::"Error Messages", TempErrorMessage);
    end;

    procedure RemoveInvalidFields()
    var
        DBraiderConfLineFieldSBI: Record "SPB DBraider ConfLine Field";
        RecRef: RecordRef;
        ConfirmRemovalMsg: Label 'This will remove all fields that are no longer in the source table.  Are you sure you want to do this?';
    begin
        if Confirm(ConfirmRemovalMsg, true) then begin
            DBraiderConfLineFieldSBI.CopyFilters(Rec);
            if DBraiderConfLineFieldSBI.FindSet() then begin
                RecRef.Open(DBraiderConfLineFieldSBI."Table No.");
                repeat
                    if not RecRef.FieldExist(DBraiderConfLineFieldSBI."Field No.") then
                        DBraiderConfLineFieldSBI.Delete(true);
                until DBraiderConfLineFieldSBI.Next() = 0;
            end
        end;
    end;
}