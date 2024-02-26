codeunit 71033617 "SPB DBraider Gen. Postman"
{
    Access = Internal;
    TableNo = "SPB DBraider Config. Header";

    var
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";
        UseDockerAuth: Boolean;

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        ItemJsonArray: JsonArray;
        CollectionJson: JsonObject;
        OutS: OutStream;
        Filename: Text;
    begin
        // We can be passed one or more config headers.  Prepare the Collection Level Object
        CollectionJson.Add('info', CollectionInfo());

        // We always add the "Basic" /api/companies Request for easy testing
        ItemJsonArray.Add(BasicRequest());

        // Loop through the Config Headers, adding each to the Collection Level Object
        if Rec.FindSet() then
            repeat
                ItemJsonArray.Add(ConfigHeader(Rec));
            until Rec.Next() < 1;
        CollectionJson.Add('item', ItemJsonArray);

        // Now we need to add the Auth object to the Collection Level Object
        if UseDockerAuth then
            CollectionJson.Add('auth', AuthDocker())
        else
            CollectionJson.Add('auth', AuthCloud());

        // Add the event object to the Collection Level Object
        CollectionJson.Add('event', PostmanEvents());

        // Depending on the Docker vs Cloud, add the variables to the Collection Level Object
        if UseDockerAuth then
            CollectionJson.Add('variable', VariablesDocker())
        else
            CollectionJson.Add('variable', VariablesCloud());

        // Finally, download the resulting Json to a file
        TempBlob.CreateOutStream(OutS, TextEncoding::UTF8);
        CollectionJson.WriteTo(OutS);
        TempBlob.CreateInStream(InS);
        Filename := 'BraiderCollection.json';
        DownloadFromStream(InS, 'Save Collection File', '', 'JSON File (*.json)|*.json', Filename);
    end;

    procedure SetUseDockerAuth()
    begin
        UseDockerAuth := true;
    end;

    #region PostmanEssentials
    local procedure CollectionInfo() Result: JsonObject
    begin
        Result.Add('_postman_id', Format(CreateGuid(), 0, 4).ToLower()); // lowercase guid with no brackets
        Result.Add('name', 'Data Braider Collection');
        Result.Add('schema', 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json');
    end;

    local procedure BasicRequest() Result: JsonObject
    var
        HeaderArr: JsonArray;
        HostArr: JsonArray;
        PathArr: JsonArray;
        ResponseArr: JsonArray;
        RequestObj: JsonObject;
        UrlObj: JsonObject;
    begin
        HostArr.Add('{{baseuri}}');
        PathArr.Add('v2.0');
        PathArr.Add('companies');

        UrlObj.Add('raw', '{{baseuri}}/v2.0/companies');
        UrlObj.Add('host', HostArr);
        UrlObj.Add('path', PathArr);

        RequestObj.Add('method', 'GET');
        RequestObj.Add('url', UrlObj);
        RequestObj.Add('header', HeaderArr);

        Result.Add('name', 'Companies');
        Result.Add('request', RequestObj);
        Result.Add('response', ResponseArr);
    end;

    local procedure AuthDocker() Result: JsonObject
    var
        BasicArr: JsonArray;
    begin
        BasicArr.Add(QuickCreateJsonObject('password', '{{dockerpassword}}', 'string'));
        BasicArr.Add(QuickCreateJsonObject('username', '{{dockeruser}}', 'string'));
        Result.Add('type', 'basic');
        Result.Add('basic', BasicArr);
    end;

    local procedure AuthCloud() Result: JsonObject
    var
        OAuth2Arr: JsonArray;
        AccessTokenUrlObj: JsonObject;
        AddTokenToObj: JsonObject;
        ClientAuthObj: JsonObject;
        ClientIdObj: JsonObject;
        ClientSecretObj: JsonObject;
        GrantTypeObj: JsonObject;
        ScopeObj: JsonObject;
        TokenNameObj: JsonObject;
    begin
        ClientSecretObj := QuickCreateJsonObject('clientSecret', '{{clientsecret}}', 'string');
        ClientAuthObj := QuickCreateJsonObject('client_authentication', 'body', 'string');
        AccessTokenUrlObj := QuickCreateJsonObject('accessTokenUrl', 'https://login.microsoftonline.com/{{tenantid}}/oauth2/v2.0/token', 'string');
        ClientIdObj := QuickCreateJsonObject('clientId', '{{clientId}}', 'string');
        ScopeObj := QuickCreateJsonObject('scope', 'https://api.businesscentral.dynamics.com/.default', 'string');
        GrantTypeObj := QuickCreateJsonObject('grant_type', 'client_credentials', 'string');
        TokenNameObj := QuickCreateJsonObject('tokenName', 'BC Client Credentials Flow', 'string');
        AddTokenToObj := QuickCreateJsonObject('addTokenTo', 'header', 'string');
        OAuth2Arr.Add(ClientSecretObj);
        OAuth2Arr.Add(ClientAuthObj);
        OAuth2Arr.Add(AccessTokenUrlObj);
        OAuth2Arr.Add(ClientIdObj);
        OAuth2Arr.Add(ScopeObj);
        OAuth2Arr.Add(GrantTypeObj);
        OAuth2Arr.Add(TokenNameObj);
        OAuth2Arr.Add(AddTokenToObj);
        Result.Add('type', 'oauth2');
        Result.Add('oauth2', OAuth2Arr);
    end;

    local procedure PostmanEvents() Result: JsonArray
    var
        EmptyValue: JsonArray;
        EventArr: JsonArray;
        PreRequestObj: JsonObject;
        PreRequestScriptObj: JsonObject;
        TestObj: JsonObject;
        TestScriptObj: JsonObject;
    begin
        EmptyValue.Add('""');
        PreRequestScriptObj.Add('type', 'text/javascript');
        PreRequestScriptObj.Add('exec', EmptyValue);
        PreRequestObj.Add('listen', 'prerequest');
        PreRequestObj.Add('script', PreRequestScriptObj);
        TestScriptObj.Add('type', 'text/javascript');
        TestScriptObj.Add('exec', EmptyValue);
        TestObj.Add('listen', 'test');
        TestObj.Add('script', TestScriptObj);
        EventArr.Add(PreRequestObj);
        EventArr.Add(TestObj);
        Result := EventArr;
    end;

    local procedure VariablesDocker() Result: JsonArray
    var
        VariableArr: JsonArray;
        BaseUriObj: JsonObject;
        CompanyIdObj: JsonObject;
        DockerPasswordObj: JsonObject;
        DockerUserObj: JsonObject;
    begin
        BaseUriObj := QuickCreateJsonObject('baseuri', 'yourserver', 'string');
        CompanyIdObj := QuickCreateJsonObject('companyid', '', 'string');
        DockerUserObj := QuickCreateJsonObject('dockeruser', 'admin', 'string');
        DockerPasswordObj := QuickCreateJsonObject('dockerpassword', 'P@ssw0rd', 'string');
        VariableArr.Add(BaseUriObj);
        VariableArr.Add(CompanyIdObj);
        VariableArr.Add(DockerUserObj);
        VariableArr.Add(DockerPasswordObj);
        Result := VariableArr;
    end;

    local procedure VariablesCloud() Result: JsonArray
    var
        OAuth2Arr: JsonArray;
        AccessTokenUrlObj: JsonObject;
        AddTokenToObj: JsonObject;
        AuthObj: JsonObject;
        ClientAuthObj: JsonObject;
        ClientIdObj: JsonObject;
        ClientSecretObj: JsonObject;
        GrantTypeObj: JsonObject;
        ScopeObj: JsonObject;
        TenantIdObj: JsonObject;
        TokenNameObj: JsonObject;
        TypeObj: JsonObject;
    begin
        ClientSecretObj := QuickCreateJsonObject('clientSecret', '{{clientsecret}}', 'string');
        ClientAuthObj := QuickCreateJsonObject('client_authentication', 'body', 'string');
        AccessTokenUrlObj := QuickCreateJsonObject('accessTokenUrl', 'https://login.microsoftonline.com/{{tenantid}}/oauth2/v2.0/token', 'string');
        ClientIdObj := QuickCreateJsonObject('clientId', '{{clientId}}', 'string');
        ScopeObj := QuickCreateJsonObject('scope', 'https://api.businesscentral.dynamics.com/.default', 'string');
        GrantTypeObj := QuickCreateJsonObject('grant_type', 'client_credentials', 'string');
        TenantIdObj := QuickCreateJsonObject('tenantid', '{{tenantid}}', 'string');
        TokenNameObj := QuickCreateJsonObject('tokenName', 'BC Client Credentials Flow', 'string');
        AddTokenToObj := QuickCreateJsonObject('addTokenTo', 'header', 'string');
        OAuth2Arr.Add(ClientSecretObj);
        OAuth2Arr.Add(ClientAuthObj);
        OAuth2Arr.Add(AccessTokenUrlObj);
        OAuth2Arr.Add(ClientIdObj);
        OAuth2Arr.Add(ScopeObj);
        OAuth2Arr.Add(GrantTypeObj);
        OAuth2Arr.Add(TenantIdObj);
        OAuth2Arr.Add(TokenNameObj);
        OAuth2Arr.Add(AddTokenToObj);
        TypeObj.Add('type', 'oauth2');
        TypeObj.Add('oauth2', OAuth2Arr);
        AuthObj.Add('auth', TypeObj);
        Result.Add(AuthObj);
    end;
    #endregion PostmanEssentials

    #region BraiderParts
    local procedure ConfigHeader(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"): JsonObject
    var
        isHandled: Boolean;
    begin
        // We need to determine the type of Endpoint we are dealing with, and while this is a candidate
        // for Interface/Enum, just going to go old school Case/Event
        case SPBDBraiderConfigHeader."Endpoint Type" of
            Enum::"SPB DBraider Endpoint Type"::"Read Only":
                exit(ReadOnlyEndpoint(SPBDBraiderConfigHeader));
            //INFO: Delta Read is not yet implemented
            // Enum::"SPB DBraider Endpoint Type"::"Delta Read":
            //     exit(DeltaReadEndpoint(SPBDBraiderConfigHeader));
            Enum::"SPB DBraider Endpoint Type"::"Per Record":
                exit(PerRecordEndpoint(SPBDBraiderConfigHeader));
            Enum::"SPB DBraider Endpoint Type"::Batch:
                exit(BatchEndpoint(SPBDBraiderConfigHeader));
            else begin
                isHandled := false;
                SPBDBraiderEvents.OnUnhandledPostmanEndpointType(SPBDBraiderConfigHeader, isHandled);
            end;
        end;
    end;

    local procedure ReadOnlyEndpoint(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") Result: JsonObject
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        RequestJsonArray: JsonArray;
        ResponseJsonArray: JsonArray;
        BasicRequestObj: JsonObject;
        FilterRequestObj: JsonObject;
    begin
        // We'll create a JSON object for the Request Folder, which is what we'll return in the Result
        Result.Add('name', SPBDBraiderConfigHeader."Code");

        // For a read only endpoint, we'll create two sample requests - a basic list, and a filtered list

        // First, we'll create the basic list request
        BasicRequestObj.Add('name', SPBDBraiderConfigHeader.Description);
        BasicRequestObj.Add('event', NewEventArray());
        BasicRequestObj.Add('request', NewGetRequest(SPBDBraiderConfigHeader."Code"));
        BasicRequestObj.Add('response', ResponseJsonArray);
        RequestJsonArray.Add(BasicRequestObj);

        // Next, we'll create the filtered list request.  We'll need a PK field, so we'll use the first one we find
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange(Included, true);
        if SPBDBraiderConfLineFields.FindFirst() then
            SPBDBraiderConfLineFields.CalcFields("Table Name", "Field Name");
        FilterRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Filtered)');
        FilterRequestObj.Add('event', NewEventArray());
        FilterRequestObj.Add('request', NewFilterPost(SPBDBraiderConfigHeader."Code",
            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name"),
            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name"),
            '*'));
        FilterRequestObj.Add('response', ResponseJsonArray);
        RequestJsonArray.Add(FilterRequestObj);

        // We'll add the RequestJsonArray to the result
        Result.Add('item', RequestJsonArray);
    end;

    //INFO: This is a placeholder for the Delta Read endpoint, which is not yet implemented
    // local procedure DeltaReadEndpoint(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") Result: JsonObject
    // begin

    // end;

    local procedure PerRecordEndpoint(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"): JsonObject
    begin
        // From a Postman perspective, there's no difference between Write types
        exit(WriteEndpoint(SPBDBraiderConfigHeader));
    end;

    local procedure BatchEndpoint(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"): JsonObject
    begin
        // From a Postman perspective, there's no difference between Write types
        exit(WriteEndpoint(SPBDBraiderConfigHeader));
    end;

    local procedure WriteEndpoint(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") Result: JsonObject
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        RequestJsonArray: JsonArray;
        ResponseJsonArray: JsonArray;
        WriteRequestObj: JsonObject;
    begin
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange("Write Enabled", true);
        SPBDBraiderConfLineFields.SetAutoCalcFields("Table Name", "Field Name");

        // We'll create a JSON object for the Request Folder, which is what we'll return in the Result
        Result.Add('name', SPBDBraiderConfigHeader."Code");

        // If Insert is allowed, we'll want an Insert example, both for Mandatory only and one for All Write Enabled Fields
        if SPBDBraiderConfigHeader."Insert Allowed" then begin
            SPBDBraiderConfLineFields.SetRange(Mandatory, true);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (INSERT-Mandatory)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Insert));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
            Clear(WriteRequestObj);

            SPBDBraiderConfLineFields.SetRange(Mandatory);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (INSERT-All)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Insert));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
            Clear(WriteRequestObj);
        end;

        // If Update is allowed, we'll want an Update example
        if SPBDBraiderConfigHeader."Modify Allowed" then begin
            SPBDBraiderConfLineFields.SetRange(Mandatory, true);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Update-Mandatory)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Update));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
            Clear(WriteRequestObj);

            SPBDBraiderConfLineFields.SetRange(Mandatory);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Update-All)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Update));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
            Clear(WriteRequestObj);
        end;

        // If Delete is allowed, we'll want a Delete example, which only the PK fields make sense for here.
        if SPBDBraiderConfigHeader."Delete Allowed" then begin
            SPBDBraiderConfLineFields.SetRange("Primary Key", true);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Delete)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Delete));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
            Clear(WriteRequestObj);
        end;

        // If both Insert and Update are allowed, we'll want an Upsert example
        if SPBDBraiderConfigHeader."Insert Allowed" and SPBDBraiderConfigHeader."Modify Allowed" then begin
            SPBDBraiderConfLineFields.SetRange(Mandatory, true);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Upsert-Mandatory)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Upsert));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());

            Clear(WriteRequestObj);
            SPBDBraiderConfLineFields.SetRange(Mandatory);
            WriteRequestObj.Add('name', SPBDBraiderConfigHeader.Description + ' (Upsert-All)');
            WriteRequestObj.Add('event', NewEventArray());
            WriteRequestObj.Add('request', BuildWriteTemplate(SPBDBraiderConfLineFields, Enum::"SPB DBraider Change Action"::Upsert));
            WriteRequestObj.Add('response', ResponseJsonArray);
            RequestJsonArray.Add(WriteRequestObj.Clone());
        end;

        Result.Add('item', RequestJsonArray);
    end;

    local procedure BuildWriteTemplate(var SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field"; ChangeAction: Enum "SPB DBraider Change Action") Result: JsonObject
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        ActionLbl: Label '[{"Action":"%1",', Locked = true, Comment = '%1 is the Change Action, e.g. Insert, Update, Delete, Upsert';
        TableFieldTypeLbl: Label '"%1.%2":%3,', Locked = true, Comment = '%1 is the Table Name, %2 is the Field Name, %3 is the format';
        TableFieldLbl: Label '"%1.%2":"",', Locked = true, Comment = '%1 is the Table Name, %2 is the Field Name';
        TemplateBuilder: TextBuilder;
        SampleBody: Text;
        HeaderArr: JsonArray;
        HostArr: JsonArray;
        PathArr: JsonArray;
        RawArr: JsonArray;
        BodyObj: JsonObject;
        IfMatchObj: JsonObject;
        LanguageObj: JsonObject;
        OptionsObj: JsonObject;
        UrlObj: JsonObject;
    begin
        TemplateBuilder.Append(StrSubstNo(Actionlbl, ChangeAction));
        if SPBDBraiderConfLineFields.FindSet() then
            repeat
                case SPBDBraiderConfLineFields."Field Type" of
                    "SPB DBraider Field Data Type"::Boolean:
                        TemplateBuilder.Append(StrSubstNo(TableFieldTypeLbl,
                            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name"),
                            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name"),
                            Format(false, 0, 9)));
                    "SPB DBraider Field Data Type"::Decimal, "SPB DBraider Field Data Type"::Integer:
                        TemplateBuilder.Append(StrSubstNo(TableFieldTypeLbl,
                                SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name"),
                                SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name"),
                                Format(123, 0, 9)));
                    else
                        TemplateBuilder.Append(StrSubstNo(TableFieldLbl,
                            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name"),
                            SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name")));
                end;
            until SPBDBraiderConfLineFields.Next() < 1;
        // Remove the trailing comma
        TemplateBuilder.Length(TemplateBuilder.Length() - 1);
        TemplateBuilder.Append('}]');
        SampleBody := TemplateBuilder.ToText().Replace('"', '\"');

        IfMatchObj := QuickCreateJsonObject('If-Match', '*', 'text');
        HeaderArr.Add(IfMatchObj);
        LanguageObj.Add('language', 'json');
        OptionsObj.Add('raw', LanguageObj);
        BodyObj.Add('mode', 'raw');
        BodyObj.Add('raw', '{"code": "' + SPBDBraiderConfLineFields."Config. Code" + '","jsonInput": "' + SampleBody + '"}');
        BodyObj.Add('options', OptionsObj);
        RawArr.Add('{{baseuri}}/sparebrained/databraider/v2.0/companies({{companyid}})/read');
        HostArr.Add('{{baseuri}}');
        PathArr.Add('sparebrained');
        PathArr.Add('databraider');
        PathArr.Add('v2.0');
        PathArr.Add('companies({{companyid}})');
        PathArr.Add('read');
        UrlObj.Add('raw', RawArr);
        UrlObj.Add('host', HostArr);
        UrlObj.Add('path', PathArr);

        Result.Add('method', 'POST');
        Result.Add('header', HeaderArr);
        Result.Add('body', BodyObj);
        Result.Add('url', UrlObj);
    end;

    local procedure NewGetRequest(ConfigCode: Text) Result: JsonObject
    var
        HeaderArr: JsonArray;
        HostArr: JsonArray;
        PathArr: JsonArray;
        RawArr: JsonArray;
        UrlObj: JsonObject;
    begin
        RawArr.Add('{{baseuri}}/sparebrained/databraider/v2.0/companies({{companyid}})/read(''' + ConfigCode + ''')');
        HostArr.Add('{{baseuri}}');
        PathArr.Add('sparebrained');
        PathArr.Add('databraider');
        PathArr.Add('v2.0');
        PathArr.Add('companies({{companyid}})');
        PathArr.Add('read(''' + ConfigCode + ''')');
        UrlObj.Add('raw', RawArr);
        UrlObj.Add('host', HostArr);
        UrlObj.Add('path', PathArr);

        Result.Add('method', 'GET');
        Result.Add('header', HeaderArr);
        Result.Add('url', UrlObj);
    end;

    local procedure NewEventArray() Result: JsonArray
    var
        ExecArr: JsonArray;
        ListenObj: JsonObject;
        ScriptObj: JsonObject;
    begin
        ExecArr.Add('template = `');
        ExecArr.Add('<pre><code>{{response}}</code></pre>');
        ExecArr.Add('`;');
        ExecArr.Add('');
        ExecArr.Add('// Set visualizer');
        ExecArr.Add('pm.visualizer.set(template, {');
        ExecArr.Add('    // Pass the response body parsed as JSON as `data`');
        ExecArr.Add('    response: JSON.stringify(JSON.parse(pm.response.json().jsonResult), undefined, 2)');
        ExecArr.Add('}); ');

        ScriptObj.Add('exec', ExecArr);
        ScriptObj.Add('type', 'text/javascript');
        ListenObj.Add('listen', 'test');
        ListenObj.Add('script', ScriptObj);
        Result.Add(ListenObj);
    end;

    local procedure NewFilterPost(ConfigCode: Text; TableName: Text; FieldName: Text; Filter: Text)
    Result: JsonObject
    var
        HeaderArr: JsonArray;
        HostArr: JsonArray;
        PathArr: JsonArray;
        RawArr: JsonArray;
        BodyObj: JsonObject;
        IfMatchObj: JsonObject;
        LanguageObj: JsonObject;
        OptionsObj: JsonObject;
        UrlObj: JsonObject;
        SampleFilterTok: Label '[{\"table\":\"%1\",\"field\":\"%2\",\"filter\":\"%3\"}]', Locked = true;
    //SampleFilterTok: Label '[{"table":"%1","field":"%2","filter":"%3"}]', Locked = true;
    begin
        IfMatchObj := QuickCreateJsonObject('If-Match', '*', 'text');
        HeaderArr.Add(IfMatchObj);
        LanguageObj.Add('language', 'json');
        OptionsObj.Add('raw', LanguageObj);
        BodyObj.Add('mode', 'raw');
        //BodyObj.Add('raw', '{\r\n    \"code\": \"' + ConfigCode + '\",\r\n    \"filterJson\": \"' + StrSubstNo(SampleFilterTok, TableName, FieldName, Filter) + '\"\r\n}');
        BodyObj.Add('raw', '{"code": "' + ConfigCode + '","filterJson": "' + StrSubstNo(SampleFilterTok, TableName, FieldName, Filter) + '"}');
        BodyObj.Add('options', OptionsObj);
        RawArr.Add('{{baseuri}}/sparebrained/databraider/v2.0/companies({{companyid}})/read');
        HostArr.Add('{{baseuri}}');
        PathArr.Add('sparebrained');
        PathArr.Add('databraider');
        PathArr.Add('v2.0');
        PathArr.Add('companies({{companyid}})');
        PathArr.Add('read');
        UrlObj.Add('raw', RawArr);
        UrlObj.Add('host', HostArr);
        UrlObj.Add('path', PathArr);

        Result.Add('method', 'POST');
        Result.Add('header', HeaderArr);
        Result.Add('body', BodyObj);
        Result.Add('url', UrlObj);
    end;
    #endregion BraiderParts

    local procedure QuickCreateJsonObject(newkey: Text; newvalue: Text; newtype: Text) Result: JsonObject
    begin
        Result.Add('key', newkey);
        Result.Add('value', newvalue);
        Result.Add('type', newtype);
    end;

    //INFO: Not yet implemented
    // local procedure GenerateCollectionDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateReadOnlyDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateReadOnlyFilteredDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateInsertDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateUpdateDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateDeleteDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;

    // local procedure GenerateUpsertDocumentation(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header") ResultText: Text
    // begin

    // end;
}
