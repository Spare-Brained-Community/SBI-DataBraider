codeunit 71033624 "SPB DB Supp - Endpoint Check"
{
    Access = Internal;
    TableNo = "SPB DBraider WizChecks";

    var
        EndpointDisableCheckTok: Label 'EPDISABLECHECK';
        EndpointDisableCheckDescriptionTok: Label 'Endpoint (%1) Settings - Check Disabled', Comment = '%1 is the Endpoint Code';
        EndpointFieldCheckTok: Label 'EPFIELDCHECK';
        EndpointFieldCheckDescriptionTok: Label 'Endpoint (%1) Settings - Field Check', Comment = '%1 is the Endpoint Code';
        EndpointRelationshipCheckTok: Label 'EPRELATIONCHECK';
        EndpointRelationshipCheckDescriptionTok: Label 'Endpoint (%1) Settings - Relationship Check', Comment = '%1 is the Endpoint Code';
        EndpointNotFoundErr: Label 'Endpoint (%1) not found', Comment = '%1 is the Endpoint Code';
        EndpointNotFoundSuggestionMsg: Label 'Check the Endpoint Code and try again.  If not found, create the endpoint.';
        EndpointNoLinesErr: Label 'Endpoint (%1) has no lines', Comment = '%1 is the Endpoint Code';
        EndpointNoLinesSuggestionMsg: Label 'Open the Endpoint and add lines (tables) to the endpoint.';

    trigger OnRun()
    begin
        case Rec."Check Code" of
            EndpointDisableCheckTok:
                CheckEndpointDisabled(Rec);
            EndpointFieldCheckTok:
                CheckEndpointFields(Rec);
            EndpointRelationshipCheckTok:
                CheckEndpointRelationships(Rec);
        end;
    end;

    local procedure RegisterChecks(var TempSPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        if TempSPBDBraiderConfigHeader.FindSet() then
            repeat
                // Check if the endpoint is disabled
                RegisterCheck(TempSPBDBraiderWizChecks, TempSPBDBraiderConfigHeader."Code", EndpointDisableCheckTok, EndpointDisableCheckDescriptionTok);

                // Check if the endpoint has fields
                RegisterCheck(TempSPBDBraiderWizChecks, TempSPBDBraiderConfigHeader."Code", EndpointFieldCheckTok, EndpointFieldCheckDescriptionTok);

                // Check if the endpoint has relationships
                RegisterCheck(TempSPBDBraiderWizChecks, TempSPBDBraiderConfigHeader."Code", EndpointRelationshipCheckTok, EndpointRelationshipCheckDescriptionTok);
            until TempSPBDBraiderConfigHeader.Next() < 1;
    end;

    local procedure RegisterCheck(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary; EndpointCode: Code[20]; CheckCode: Code[20]; Description: Text[200])
    begin
        if TempSPBDBraiderWizChecks.Get(CheckCode, EndpointCode) then
            exit;
        TempSPBDBraiderWizChecks.Init();
        TempSPBDBraiderWizChecks."Check Code" := CheckCode;
        TempSPBDBraiderWizChecks."Endpoint Code" := EndpointCode;
        TempSPBDBraiderWizChecks."Description" := StrSubstNo(Description, EndpointCode);
        TempSPBDBraiderWizChecks."Check Codeunit" := Codeunit::"SPB DB Supp - Endpoint Check";
        TempSPBDBraiderWizChecks.Insert();
    end;

    local procedure RegisterSuccess(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        TempSPBDBraiderWizChecks.Status := TempSPBDBraiderWizChecks.Status::Passed;
        TempSPBDBraiderWizChecks.Modify();
    end;

    local procedure RegisterSkipped(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        TempSPBDBraiderWizChecks.Status := TempSPBDBraiderWizChecks.Status::Skipped;
        TempSPBDBraiderWizChecks.Modify();
    end;

    local procedure RegisterFailure(var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary; ResultMessage: Text[250]; Suggestion: Text[250])
    begin
        TempSPBDBraiderWizChecks.Status := TempSPBDBraiderWizChecks.Status::Failed;
        TempSPBDBraiderWizChecks.Results := ResultMessage;
        TempSPBDBraiderWizChecks."Suggested Action" := Suggestion;
        TempSPBDBraiderWizChecks.Modify();
    end;

    local procedure CheckEndpointDisabled(var Rec: Record "SPB DBraider WizChecks" temporary)
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        EndpointDisabledErr: Label 'Endpoint (%1) is disabled', Comment = '%1 is the Endpoint Code';
        EndpointEnableSuggestionMsg: Label 'Open the Endpoint and select the Enable field to enable the endpoint';
    begin
        if SPBDBraiderConfigHeader.Get(Rec."Endpoint Code") then
            if not SPBDBraiderConfigHeader."Enabled" then
                RegisterFailure(Rec, StrSubstNo(EndpointDisabledErr, Rec."Endpoint Code"), EndpointEnableSuggestionMsg)
            else
                RegisterSuccess(Rec)
        else
            RegisterFailure(Rec, StrSubstNo(EndpointNotFoundErr, Rec."Endpoint Code"), EndpointNotFoundSuggestionMsg);
    end;

    local procedure CheckEndpointFields(var Rec: Record "SPB DBraider WizChecks" temporary)
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderConfLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        EndpointNoFieldsErr: Label 'Endpoint (%1) has no fields at all for Table %2', Comment = '%1 is the Endpoint Code, %2 is the Table Name';
        EndpointNoFieldsSuggestionMsg: Label 'Open the Endpoint. Remove and re-add the table to have the field list regenerate.';
        EndpointNoFieldsIncludedErr: Label 'Endpoint (%1) has no fields included for Table %2', Comment = '%1 is the Endpoint Code, %2 is the Table Name';
        EndpointNoFieldsIncludedSuggestionMsg: Label 'Open the Endpoint. Select Included for fields for the table.';
    begin
        SPBDBraiderConfLine.SetAutoCalcFields("Source Table Name");
        if SPBDBraiderConfigHeader.Get(Rec."Endpoint Code") then begin
            SPBDBraiderConfLine.SetRange(SPBDBraiderConfLine."Config. Code", SPBDBraiderConfigHeader."Code");
            if SPBDBraiderConfLine.FindSet() then
                repeat
                    SPBDBraiderConfLineField.SetRange(SPBDBraiderConfLineField."Config. Code", SPBDBraiderConfLine."Config. Code");
                    SPBDBraiderConfLineField.SetRange(SPBDBraiderConfLineField."Config. Line No.", SPBDBraiderConfLine."Line No.");
                    if not SPBDBraiderConfLineField.IsEmpty() then begin
                        // Check for any fields enabled
                        SPBDBraiderConfLineField.SetRange(SPBDBraiderConfLineField.Included, true);
                        if not SPBDBraiderConfLineField.IsEmpty() then
                            RegisterSuccess(Rec)
                        else
                            RegisterFailure(Rec, StrSubstNo(EndpointNoFieldsIncludedErr, Rec."Endpoint Code", SPBDBraiderConfLine."Source Table Name"), EndpointNoFieldsIncludedSuggestionMsg)
                    end else
                        RegisterFailure(Rec, StrSubstNo(EndpointNoFieldsErr, Rec."Endpoint Code", SPBDBraiderConfLine."Source Table Name"), EndpointNoFieldsSuggestionMsg);
                until SPBDBraiderConfLine.Next() < 1
            else
                RegisterFailure(Rec, StrSubstNo(EndpointNoLinesErr, Rec."Endpoint Code"), EndpointNoLinesSuggestionMsg);
        end else
            RegisterFailure(Rec, StrSubstNo(EndpointNotFoundErr, Rec."Endpoint Code"), EndpointNotFoundSuggestionMsg);
    end;

    local procedure CheckEndpointRelationships(var Rec: Record "SPB DBraider WizChecks" temporary)
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderConfLine: Record "SPB DBraider Config. Line";
        RelationshipConfiguredErr: Label 'Endpoint (%1) has relationships problems.', Comment = '%1 is the Endpoint Code';
        RelationshipConfiguredSuggestionMsg: Label 'Open the Endpoint and add relationships to the endpoint.'; // Not "See a counselor"
    begin
        SPBDBraiderConfLine.SetAutoCalcFields("Source Table Name");
        if SPBDBraiderConfigHeader.Get(Rec."Endpoint Code") then begin
            SPBDBraiderConfLine.SetRange(SPBDBraiderConfLine."Config. Code", SPBDBraiderConfigHeader."Code");
            // if there is only 1 config line, then there are no relationships, and we can mark this as a Skipped test
            if SPBDBraiderConfLine.Count = 1 then
                RegisterSkipped(Rec)
            else begin
                SPBDBraiderConfLine.SetFilter(Indentation, '>0');
                SPBDBraiderConfLine.SetRange("Relationship Configured", false);
                if SPBDBraiderConfLine.IsEmpty() then
                    RegisterSuccess(Rec)
                else
                    RegisterFailure(Rec, StrSubstNo(RelationshipConfiguredErr, Rec."Endpoint Code"), RelationshipConfiguredSuggestionMsg);
            end;
        end else
            RegisterFailure(Rec, StrSubstNo(EndpointNotFoundErr, Rec."Endpoint Code"), EndpointNotFoundSuggestionMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SPB DBraider Events", OnSupportWizardChecksStarting, '', false, false)]
    local procedure OnSupportWizardStartingRegisterChecks(var TempSPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
        RegisterChecks(TempSPBDBraiderConfigHeader, TempSPBDBraiderWizChecks);
    end;
}
