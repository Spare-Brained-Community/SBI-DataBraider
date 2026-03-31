codeunit 71033622 "SPB DBraider Gen. Swagger"
{
    Access = Internal;
    TableNo = "SPB DBraider Config. Header";

    var
        SPBDBraiderEvents: Codeunit "SPB DBraider Events";

    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        ComponentsObj: JsonObject;
        OpenApiJson: JsonObject;
        OutS: OutStream;
        PathsObj: JsonObject;
        SchemasObj: JsonObject;
        ServersArr: JsonArray;
        ServerObj: JsonObject;
        Filename: Text;
    begin
        // Build the OpenAPI 3.0 root object

        // openapi version
        OpenApiJson.Add('openapi', '3.0.0');

        // info object
        OpenApiJson.Add('info', InfoObject());

        // servers array - use the real BC SaaS cloud URI
        ServerObj.Add('url', GetServerUrl());
        ServersArr.Add(ServerObj);
        OpenApiJson.Add('servers', ServersArr);

        // paths object - loop through Config Headers
        if Rec.FindSet() then
            repeat
                AddConfigHeaderPaths(Rec, PathsObj, SchemasObj);
            until Rec.Next() < 1;
        OpenApiJson.Add('paths', PathsObj);

        // components object - securitySchemes + schemas
        ComponentsObj.Add('securitySchemes', SecuritySchemes());
        ComponentsObj.Add('schemas', SchemasObj);
        OpenApiJson.Add('components', ComponentsObj);

        // Download the resulting JSON to a file
        TempBlob.CreateOutStream(OutS, TextEncoding::UTF8);
        OpenApiJson.WriteTo(OutS);
        TempBlob.CreateInStream(InS);
        Filename := 'BraiderSwagger.json';
        DownloadFromStream(InS, 'Save Swagger File', '', 'JSON File (*.json)|*.json', Filename);
    end;

    #region SwaggerEssentials
    local procedure InfoObject() Result: JsonObject
    begin
        Result.Add('title', 'Data Braider API');
        Result.Add('version', '2.0');
    end;

    local procedure GetServerUrl(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        Company: Record Company;
        CompanyId: Text;
    begin
        Company.Get(CompanyName());
        // Format GUID as lowercase without braces for use in BC API URLs
        CompanyId := LowerCase(DelChr(Format(Company.SystemId, 0, 4), '=', '{}'));
        exit(StrSubstNo(
            'https://api.businesscentral.dynamics.com/v2.0/%1/%2/api/sparebrained/databraider/v2.0/companies(%3)',
            AzureADTenant.GetAadTenantId(),
            EnvironmentInformation.GetEnvironmentName(),
            CompanyId));
    end;

    local procedure GetTokenUrl(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        exit(StrSubstNo(
            'https://login.microsoftonline.com/%1/oauth2/v2.0/token',
            AzureADTenant.GetAadTenantId()));
    end;

    local procedure SecuritySchemes() Result: JsonObject
    var
        ClientCredentialsObj: JsonObject;
        FlowsObj: JsonObject;
        OAuth2Obj: JsonObject;
        ScopesObj: JsonObject;
    begin
        ScopesObj.Add('https://api.businesscentral.dynamics.com/.default', 'Business Central API access');
        ClientCredentialsObj.Add('tokenUrl', GetTokenUrl());
        ClientCredentialsObj.Add('scopes', ScopesObj);
        FlowsObj.Add('clientCredentials', ClientCredentialsObj);
        OAuth2Obj.Add('type', 'oauth2');
        OAuth2Obj.Add('flows', FlowsObj);
        Result.Add('OAuth2', OAuth2Obj);
    end;

    local procedure SecurityRequirement() Result: JsonArray
    var
        SecurityObj: JsonObject;
        ScopeArr: JsonArray;
    begin
        ScopeArr.Add('https://api.businesscentral.dynamics.com/.default');
        SecurityObj.Add('OAuth2', ScopeArr);
        Result.Add(SecurityObj);
    end;

    local procedure ReadResponse200(SchemaName: Text) Result: JsonObject
    var
        CodeSchemaObj: JsonObject;
        ContentObj: JsonObject;
        DescSchemaObj: JsonObject;
        IncludedCountSchemaObj: JsonObject;
        JsonResponseObj: JsonObject;
        JsonResultItemsObj: JsonObject;
        JsonResultSchemaObj: JsonObject;
        MediaTypeObj: JsonObject;
        ResponsePropertiesObj: JsonObject;
        ResponseSchemaObj: JsonObject;
        TopLevelCountSchemaObj: JsonObject;
    begin
        CodeSchemaObj.Add('type', 'string');
        DescSchemaObj.Add('type', 'string');
        JsonResultItemsObj.Add('$ref', '#/components/schemas/' + SchemaName);
        JsonResultSchemaObj.Add('type', 'array');
        JsonResultSchemaObj.Add('items', JsonResultItemsObj);
        TopLevelCountSchemaObj.Add('type', 'integer');
        IncludedCountSchemaObj.Add('type', 'integer');
        ResponsePropertiesObj.Add('code', CodeSchemaObj);
        ResponsePropertiesObj.Add('description', DescSchemaObj);
        ResponsePropertiesObj.Add('jsonResult', JsonResultSchemaObj);
        ResponsePropertiesObj.Add('topLevelRecordCount', TopLevelCountSchemaObj);
        ResponsePropertiesObj.Add('includedRecordCount', IncludedCountSchemaObj);
        ResponseSchemaObj.Add('type', 'object');
        ResponseSchemaObj.Add('properties', ResponsePropertiesObj);
        MediaTypeObj.Add('schema', ResponseSchemaObj);
        ContentObj.Add('application/json', MediaTypeObj);
        JsonResponseObj.Add('description', 'Successful response');
        JsonResponseObj.Add('content', ContentObj);
        Result.Add('200', JsonResponseObj);
    end;

    local procedure StringResponse200() Result: JsonObject
    var
        ContentObj: JsonObject;
        JsonResultObj: JsonObject;
        MediaTypeObj: JsonObject;
        SchemaObj: JsonObject;
    begin
        SchemaObj.Add('type', 'string');
        MediaTypeObj.Add('schema', SchemaObj);
        ContentObj.Add('application/json', MediaTypeObj);
        JsonResultObj.Add('description', 'Successful response');
        JsonResultObj.Add('content', ContentObj);
        Result.Add('200', JsonResultObj);
    end;
    #endregion SwaggerEssentials

    #region BraiderParts
    local procedure AddConfigHeaderPaths(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var PathsObj: JsonObject; var SchemasObj: JsonObject)
    var
        isHandled: Boolean;
    begin
        // Determine the type of Endpoint we are dealing with
        case SPBDBraiderConfigHeader."Endpoint Type" of
            Enum::"SPB DBraider Endpoint Type"::"Read Only":
                AddReadOnlyPaths(SPBDBraiderConfigHeader, PathsObj, SchemasObj);
            //INFO: Delta Read is not yet implemented
            // Enum::"SPB DBraider Endpoint Type"::"Delta Read":
            //     AddDeltaReadPaths(SPBDBraiderConfigHeader, PathsObj, SchemasObj);
            Enum::"SPB DBraider Endpoint Type"::"Per Record":
                AddWritePaths(SPBDBraiderConfigHeader, PathsObj, SchemasObj);
            Enum::"SPB DBraider Endpoint Type"::Batch:
                AddWritePaths(SPBDBraiderConfigHeader, PathsObj, SchemasObj);
            else begin
                isHandled := false;
                SPBDBraiderEvents.OnUnhandledPostmanEndpointType(SPBDBraiderConfigHeader, isHandled);
            end;
        end;
    end;

    local procedure AddReadOnlyPaths(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var PathsObj: JsonObject; var SchemasObj: JsonObject)
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        GetOperationObj: JsonObject;
        GetPathObj: JsonObject;
        PostOperationObj: JsonObject;
        PostPathObj: JsonObject;
        RequestBodyContentObj: JsonObject;
        RequestBodyMediaTypeObj: JsonObject;
        RequestBodyObj: JsonObject;
        RequestBodySchemaObj: JsonObject;
        RequestBodySchemaPropsObj: JsonObject;
        CodePropObj: JsonObject;
        FilterJsonPropObj: JsonObject;
        SchemaName: Text;
    begin
        SchemaName := SPBDBraiderConfigHeader."Code" + 'ReadItem';

        // Build the response schema for included fields and add it to components/schemas
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange(Included, true);
        SPBDBraiderConfLineFields.SetAutoCalcFields("Table Name", "Field Name");
        SchemasObj.Add(SchemaName, BuildFieldSchema(SPBDBraiderConfLineFields));

        // GET /read('{code}') — summary from Config Header Description, response 200 with schema
        GetOperationObj.Add('summary', SPBDBraiderConfigHeader.Description);
        GetOperationObj.Add('security', SecurityRequirement());
        GetOperationObj.Add('responses', ReadResponse200(SchemaName));
        GetPathObj.Add('get', GetOperationObj);
        PathsObj.Add('/read(''' + SPBDBraiderConfigHeader."Code" + ''')', GetPathObj);

        // POST /read — body: { code, filterJson }, response 200 with schema
        CodePropObj.Add('type', 'string');
        FilterJsonPropObj.Add('type', 'string');
        RequestBodySchemaPropsObj.Add('code', CodePropObj);
        RequestBodySchemaPropsObj.Add('filterJson', FilterJsonPropObj);
        RequestBodySchemaObj.Add('type', 'object');
        RequestBodySchemaObj.Add('properties', RequestBodySchemaPropsObj);
        RequestBodyMediaTypeObj.Add('schema', RequestBodySchemaObj);
        RequestBodyContentObj.Add('application/json', RequestBodyMediaTypeObj);
        RequestBodyObj.Add('required', true);
        RequestBodyObj.Add('content', RequestBodyContentObj);
        PostOperationObj.Add('summary', SPBDBraiderConfigHeader.Description + ' (Filtered)');
        PostOperationObj.Add('security', SecurityRequirement());
        PostOperationObj.Add('requestBody', RequestBodyObj);
        PostOperationObj.Add('responses', ReadResponse200(SchemaName));
        PostPathObj.Add('post', PostOperationObj);
        PathsObj.Add('/read/' + SPBDBraiderConfigHeader."Code", PostPathObj);
    end;

    //INFO: This is a placeholder for the Delta Read endpoint, which is not yet implemented
    // local procedure AddDeltaReadPaths(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var PathsObj: JsonObject; var SchemasObj: JsonObject)
    // begin

    // end;

    local procedure AddWritePaths(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var PathsObj: JsonObject; var SchemasObj: JsonObject)
    var
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        PostOperationObj: JsonObject;
        PostPathObj: JsonObject;
        RequestBodyContentObj: JsonObject;
        RequestBodyMediaTypeObj: JsonObject;
        RequestBodyObj: JsonObject;
        SchemaRefObj: JsonObject;
        SchemaName: Text;
    begin
        SchemaName := SPBDBraiderConfigHeader."Code" + 'WriteBody';

        // Build the schema for this endpoint and add it to components/schemas
        SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigHeader."Code");
        SPBDBraiderConfLineFields.SetRange("Write Enabled", true);
        SPBDBraiderConfLineFields.SetAutoCalcFields("Table Name", "Field Name");
        SchemasObj.Add(SchemaName, BuildFieldSchema(SPBDBraiderConfLineFields));

        // POST /write — body schema by reference
        SchemaRefObj.Add('$ref', '#/components/schemas/' + SchemaName);
        RequestBodyMediaTypeObj.Add('schema', SchemaRefObj);
        RequestBodyContentObj.Add('application/json', RequestBodyMediaTypeObj);
        RequestBodyObj.Add('required', true);
        RequestBodyObj.Add('content', RequestBodyContentObj);
        PostOperationObj.Add('summary', SPBDBraiderConfigHeader.Description);
        PostOperationObj.Add('security', SecurityRequirement());
        PostOperationObj.Add('requestBody', RequestBodyObj);
        PostOperationObj.Add('responses', StringResponse200());
        PostPathObj.Add('post', PostOperationObj);
        PathsObj.Add('/write/' + SPBDBraiderConfigHeader."Code", PostPathObj);
    end;

    local procedure BuildFieldSchema(var SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field") Result: JsonObject
    var
        SPBDBraiderJsonUtilities: Codeunit "SPB DBraider JSON Utilities";
        PropertiesObj: JsonObject;
        FieldSchemaObj: JsonObject;
    begin
        Result.Add('type', 'object');
        if SPBDBraiderConfLineFields.FindSet() then
            repeat
                Clear(FieldSchemaObj);
                case SPBDBraiderConfLineFields."Field Type" of
                    "SPB DBraider Field Data Type"::Boolean:
                        FieldSchemaObj.Add('type', 'boolean');
                    "SPB DBraider Field Data Type"::Decimal, "SPB DBraider Field Data Type"::Integer:
                        FieldSchemaObj.Add('type', 'number');
                    else
                        FieldSchemaObj.Add('type', 'string');
                end;
                PropertiesObj.Add(
                    SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Table Name") + '.' +
                    SPBDBraiderJsonUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name"),
                    FieldSchemaObj);
            until SPBDBraiderConfLineFields.Next() < 1;
        Result.Add('properties', PropertiesObj);
    end;
    #endregion BraiderParts
}
