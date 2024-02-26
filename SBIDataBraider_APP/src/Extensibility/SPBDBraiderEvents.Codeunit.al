codeunit 71033619 "SPB DBraider Events"
{
    Access = Internal;
    /* Since API calls are SUPPOSED to be fast, subscribers should take caution to add any extra DB operations */

    [IntegrationEvent(false, false)]
    procedure OnBeforeGenerateData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterGenerateData(var DBHeader: Record "SPB DBraider Config. Header"; var TempSPBDBraiderResultsetRow: Record "SPB DBraider Resultset Row" temporary; var TempSPBDBraiderResultsetCol: Record "SPB DBraider Resultset Col" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterFormatData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonResult: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeWriteData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterWriteData(var DBHeader: Record "SPB DBraider Config. Header"; var JsonInput: Text; var JsonResult: Text; Success: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterWritetoEventNotification(EventNote: Record "SPBDBraider Event Notification")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeConvertJSONtoText(var ConfigCode: Code[20]; var JsonRows: JsonArray; var ResultText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterConvertJSONtoText(var ConfigCode: Code[20]; var JsonRows: JsonArray; var ResultText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeMapFieldTypeToSPBFieldDataType(var IsHandled: Boolean; SourceFieldType: FieldType; var SPBFieldDataType: Enum "SPB DBraider Field Data Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnUnhandledPostmanEndpointType(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var isHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSupportWizardChecksStarting(var TempSPBDBraiderConfigHeader: Record "SPB DBraider Config. Header" temporary; var TempSPBDBraiderWizChecks: Record "SPB DBraider WizChecks" temporary)
    begin
    end;
}
