page 71033625 "SPB DBraider Config API"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    Caption = 'Data Braider Endpoint Config API';
    DelayedInsert = true;
    EntityCaption = 'Endpoint Config';
    EntityName = 'endpointConfig';
    EntitySetName = 'endpointConfigs';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "SPB DBraider Config. Header";

    // NOTE: This page intentionally does NOT gate on SPB DBraider Setup.EnabledGlobally.
    // Administrators must be able to author endpoint configurations remotely BEFORE
    // enabling Data Braider globally. The runtime read/write APIs keep that gate.

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                // endpointType must stay ahead of the capability flags: its OnValidate sets
                // their type-appropriate defaults, which explicit values below may then override.
                field(endpointType; Rec."Endpoint Type")
                {
                    Caption = 'endpointType', Locked = true;
                }
                field(outputJsonType; Rec."Output JSON Type")
                {
                    Caption = 'outputJsonType', Locked = true;
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'enabled', Locked = true;
                }
                field(requirePK; Rec."Require PK")
                {
                    Caption = 'requirePK', Locked = true;
                }
                field(insertAllowed; Rec."Insert Allowed")
                {
                    Caption = 'insertAllowed', Locked = true;
                }
                field(modifyAllowed; Rec."Modify Allowed")
                {
                    Caption = 'modifyAllowed', Locked = true;
                }
                field(deleteAllowed; Rec."Delete Allowed")
                {
                    Caption = 'deleteAllowed', Locked = true;
                }
                field(preventReading; Rec."Prevent Reading")
                {
                    Caption = 'preventReading', Locked = true;
                }
                field(hideFromLists; Rec."Hide from Lists")
                {
                    Caption = 'hideFromLists', Locked = true;
                }
                field(pageSize; Rec."Page Size")
                {
                    Caption = 'pageSize', Locked = true;
                }
                field(loggingEnabled; Rec."Logging Enabled")
                {
                    Caption = 'loggingEnabled', Locked = true;
                }
                field(clearLogsCount; Rec."Clear Logs Count")
                {
                    Caption = 'clearLogsCount', Locked = true;
                }
                field(dataArchiveVersions; Rec."Data Archive Versions")
                {
                    Caption = 'dataArchiveVersions', Locked = true;
                }
                field(disableAutoModifiedAt; Rec."Disable Auto ModifiedAt")
                {
                    Caption = 'disableAutoModifiedAt', Locked = true;
                }
                field(disableAutoSystemId; Rec."Disable Auto SystemId")
                {
                    Caption = 'disableAutoSystemId', Locked = true;
                }
                field(disableRelatedId; Rec."Disable Related Id")
                {
                    Caption = 'disableRelatedId', Locked = true;
                }
                field(emitRawDiagnosticData; Rec."Emit Raw Diagnostic Data")
                {
                    Caption = 'emitRawDiagnosticData', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                    Editable = false;
                }
                part(lines; "SPB DBraider Config Line API")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'endpointLine';
                    EntitySetName = 'endpointLines';
                    SubPageLink = "Config. Code" = field(Code);
                }
            }
        }
    }
}
