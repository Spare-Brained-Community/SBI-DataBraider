page 71033609 "SPB DBraider API JSON"
{
    APIGroup = 'databraider';
    APIPublisher = 'sparebrained';
    APIVersion = 'v2.0';
    ApplicationArea = All;
    Caption = 'Data Braider Read API';
    DelayedInsert = true;
    EntityName = 'read';
    EntitySetName = 'read';
    ODataKeyFields = Code;
    PageType = API;
    SourceTable = "SPB DBraider Config. Header";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(endpointType; Rec."Endpoint Type")
                {
                    Caption = 'Endpoint Type';
                }
                field(outputJSONType; Rec."Output JSON Type")
                {
                    Caption = 'Output JSON Type';
                }
                field(jsonResult; JsonResult)
                {
                    Caption = 'jsonResult', Locked = true;
                }
                field(filterJson; FilterJson)
                {
                    Caption = 'FilterJson', Locked = true;
                }
                field(pageStart; pageTostart)
                {
                    Caption = 'pageStart', Locked = true;
                }
                field(pageSize; pageSize)
                {
                    Caption = 'pageSize', Locked = true;
                }
                field(topLevelRecordCount; topLevelRecordCount)
                {
                    Caption = 'topLevelRecordCount', Locked = true;
                }
                field(includedRecordCount; includedRecordCount)
                {
                    Caption = 'includedRecordCount', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseConnector: Codeunit "SPB DBraider Licensing";
    begin
        Licensed := LicenseConnector.CheckIfActive(false);
        CheckIfGloballyEnbled();
        if not Rec.IsTemporary and GuiAllowed then
            Error(TempRecOnlyErr);
        if FilterJsonArray.Count <> 0 then
            Rec.Insert();
    end;

    trigger OnFindRecord(Which: Text): Boolean   //GET
    begin
        if not Rec.IsTemporary and GuiAllowed then
            Error(TempRecOnlyErr);

        if Licensed then begin
            if not DataInitialized then begin
                if Rec.GetFilter(Code) = '' then begin
                    if Rec.Code = '' then begin
                        if DBraiderSetup."Disable Auto-List" then
                            Error(ListingNotEnabledErr)
                        else
                            GenerateList()
                    end
                    else begin
                        Rec.SetRecFilter();
                        GenerateData();
                    end;
                end else
                    GenerateData();
                DataInitialized := true;
            end;
        end else begin
            JsonResult := UnlicensedErr;
            exit(true);
        end;

        exit(Rec.Find(Which));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean   //POST
    begin
        InsertMode := true;
        if FilterJson <> '' then
            FilterJsonArray.ReadFrom(FilterJson);
        Rec.SetRecFilter();
        GenerateData();
    end;

    procedure GenerateList()
    begin
        DBraiderConfig.SetRange(Enabled, true);
        DBraiderConfig.SetRange("Hide from Lists", false);
        if DBraiderConfig.FindSet() then
            repeat
                Rec.TransferFields(DBraiderConfig);
                Rec.Insert();
            until DBraiderConfig.Next() = 0;
    end;

    procedure GenerateData()
    var
        TempResultCol: Record "SPB DBraider Resultset Col" temporary;
        TempResultRow: Record "SPB DBraider Resultset Row" temporary;
        DBraiderEngine: Codeunit "SPB DBraider Data Engine";
        SPBDBraiderErrorSystem: Codeunit "SPB DBraider Error System";
        SPBDBraiderIDatasetToText: Interface "SPB DBraider IDatasetToText";
    begin
        SPBDBraiderErrorSystem.ReInitialize();
        DBraiderConfig.CopyFilters(Rec);
        DBraiderConfig.SetRange(Enabled, true);
        Rec.Reset();
        if DBraiderConfig.FindFirst() then begin  // Intentional: You can only get one result set, so findfirst.  If they filter on a range, first only!
                                                  //if DBraiderConfig.Get(Rec.Code) then begin
            Rec.DeleteAll();
            Rec.TransferFields(DBraiderConfig);
            // Apply any filters sent in via API
            if FilterJsonArray.Count > 0 then
                DBraiderEngine.BuildFiltersFromJson(DBraiderConfig.Code, FilterJsonArray);
            if FilterJson <> '' then
                DBraiderEngine.SetFilterJson(FilterJson);  // Passing this along for eventing

            // If the user provided some pagination info, apply that to the engine
            if pageTostart <> 0 then
                if pageSize <> 0 then
                    DBraiderEngine.SetPagination(pageTostart, pageSize)
                else
                    DBraiderEngine.SetPagination(pageTostart)
            else
                if pageSize <> 0 then
                    DBraiderEngine.SetPagination(1, pageSize);

            // If there were already errors, just from the Filtering, then we need to stop here and output that info
            if SPBDBraiderErrorSystem.HasErrors() then
                SPBDBraiderErrorSystem.WriteErrors(JsonResult)
            else begin
                // The filtering worked, so now we REALLY generate the dataset
                DBraiderEngine.GenerateData(DBraiderConfig.Code);

                // If there were errors, we need to stop here and output that info
                if SPBDBraiderErrorSystem.HasErrors() then
                    SPBDBraiderErrorSystem.WriteErrors(JsonResult)
                else begin
                    // Finally, everything is good, so we can get the results
                    DBraiderEngine.GetResults(TempResultRow, TempResultCol);

                    // Format the results through our interface
                    SPBDBraiderIDatasetToText := DBraiderConfig."Output JSON Type";
                    JsonResult := SPBDBraiderIDatasetToText.ConvertToJSONText(TempResultRow, TempResultCol);

                    // Now, we need to get the counts
                    topLevelRecordCount := DBraiderEngine.GetTopLevelRecordCount();
                    includedRecordCount := TempResultRow.Count();

                    // And fetch the Page info, in case the user didn't give us those values (pretty typical)
                    DBraiderEngine.GetPageInfo(pageTostart, pageSize);
                end;
            end;
            if not InsertMode then
                Rec.Insert();
        end else begin
            SPBDBraiderErrorSystem.AddError(1, 'No configuration found for this code.');
            SPBDBraiderErrorSystem.WriteErrors(JsonResult);
        end;
    end;

    local procedure CheckIfGloballyEnbled(): Boolean
    var
        DBNotEnabledErr: Label 'Data Braider is not enabled globally. Please check the Data Braider Setup.';
    begin
        DBraiderSetup.GetRecordOnce();
        if not DBraiderSetup.EnabledGlobally then
            Error(DBNotEnabledErr);
    end;

    var
        DBraiderConfig: Record "SPB DBraider Config. Header";
        DBraiderSetup: Record "SPB DBraider Setup";
        DataInitialized: Boolean;
        InsertMode: Boolean;
        Licensed: Boolean;
        includedRecordCount: Integer;
        pageSize: Integer;
        pageTostart: Integer;
        topLevelRecordCount: Integer;
        FilterJsonArray: JsonArray;
        TestJsonObject: JsonObject;
        ListingNotEnabledErr: Label 'This Data braider configuration does not provide a listing. Please call a specific endpoint.';
        TempRecOnlyErr: Label 'Page must be run with Temporary records only.';
        UnlicensedErr: Label 'This copy of Data Braider has not been licensed or the license is not activated.';
        FilterJson: Text;
        JsonResult: Text;
}
