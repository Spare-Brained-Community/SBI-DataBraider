codeunit 71033621 "SPB Create Endpoints"
{
    Access = Internal;

    var
        BankAccounts: Record "Bank Account";
        CompanyRec: Record Company;
        CompanyInformation: Record "Company Information";
        Contacts: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        CountryRegion: Record "Country/Region";
        Currency: Record "Currency";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        DefaultDim: Record "Default Dimension";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        Employee: Record Employee;
        GLAccount: Record "G/L Account";
        GLEntries: Record "G/L Entry";
        GeneralJournalBatches: Record "Gen. Journal Batch";
        GeneralJournalLines: Record "Gen. Journal Line";
        GeneralProductionPostingGroup: Record "Gen. Product Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemVariant: Record "Item Variant";
        Job: Record Job;
        Location: Record Location;
        Opportunity: Record "Opportunity";
        PaymentMethod: Record "Payment Method";
        PaymentTerms: Record "Payment Terms";
        PurchaseReceiptHeader: Record "Purch. Rcpt. Header";
        PurchaseReceiptLine: Record "Purch. Rcpt. Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ReturnReason: Record "Return Reason";
        SalesHeader: Record "Sales Header";
        SalesLines: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLines: Record "Sales Shipment Line";
        ShipmentMethod: Record "Shipment Method";
        TaxArea: Record "Tax Area";
        TaxGroup: Record "Tax Group";
        UnitOfMeasure: Record "Unit of Measure";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";

    procedure CreateEndpoint(var TempSPBDBraiderConfigHeader: Record "SPB DBraider Config. Header" temporary)
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    begin
        if TempSPBDBraiderConfigHeader."Logging Enabled" and SPBDBraiderConfigHeader.Get(TempSPBDBraiderConfigHeader.Code) then
            SPBDBraiderConfigHeader.Delete(true);
        if not SPBDBraiderConfigHeader.Get(TempSPBDBraiderConfigHeader.Code) then begin
            CreateFunctionalEndpoint(SPBDBraiderConfigHeader, TempSPBDBraiderConfigHeader.Code, TempSPBDBraiderConfigHeader.Description);
            CreateTableData(SPBDBraiderConfigHeader);
        end;
    end;

    procedure CreateFunctionalEndpoint(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; EndpointCode: Code[20]; EndpointDescription: Text[100])
    begin
        SPBDBraiderConfigHeader.Init();
        SPBDBraiderConfigHeader.Code := EndpointCode;
        SPBDBraiderConfigHeader.Description := EndpointDescription;
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Per Record");
        SPBDBraiderConfigHeader.Validate("Output JSON Type", SPBDBraiderConfigHeader."Output JSON Type"::Flat);
        SPBDBraiderConfigHeader.Insert(true);
    end;

    local procedure CreateTableData(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")

    begin
        case SPBDBraiderConfigHeader.Code of
            'SPB-glAccounts':
                CreateEndpointGLAccounts(SPBDBraiderConfigHeader);
            'SPB-bankAccounts':
                CreateEndpointBankAccounts(SPBDBraiderConfigHeader);
            'SPB-genLedEntries':
                CreateEndpointGeneralLedgerEntries(SPBDBraiderConfigHeader);
            'SPB-journals':
                CreateEndpointGeneralJournalBatches(SPBDBraiderConfigHeader);
            'SPB-journalLines':
                CreateEndpointGeneralJournalLines(SPBDBraiderConfigHeader);
            'SPB-contacts':
                CreateEndpointContacts(SPBDBraiderConfigHeader);
            'SPB-contactInfo':
                CreateEndpointContactInformation(SPBDBraiderConfigHeader);
            'SPB-customers':
                CreateEndpointCustomers(SPBDBraiderConfigHeader);
            'SPB-customerFinDets':
                CreateEndpointCustomerFinancialDetails(SPBDBraiderConfigHeader);
            'SPB-customerPayments':
                CreateEndpointCustomerPayments(SPBDBraiderConfigHeader);
            'SPB-returnReasons':
                CreateEndpointReturnReasons(SPBDBraiderConfigHeader);
            'SPB-customerSales':
                CreateEndpointCustomerSales(SPBDBraiderConfigHeader);
            'SPB-opportunities':
                CreateEndpointOpportunities(SPBDBraiderConfigHeader);
            'SPB-salesCrMemos':
                CreateEndpointCreateSalesCreditMemos(SPBDBraiderConfigHeader);
            'SPB-salesCrMemoLines':
                CreateEndpointSalesCreditMemoLines(SPBDBraiderConfigHeader);
            'SPB-salesInvoices':
                CreateEndpointSalesInvoices(SPBDBraiderConfigHeader);
            'SPB-salesInvLines':
                CreateEndpointSalesInvoiceLines(SPBDBraiderConfigHeader);
            'SPB-salesOrders':
                CreateEndpointSalesOrders(SPBDBraiderConfigHeader);
            'SPB-salesOrderLines':
                CreateEndpointSalesOrderLines(SPBDBraiderConfigHeader);
            'SPB-salesQuotes':
                CreateEndpointSalesQuotes(SPBDBraiderConfigHeader);
            'SPB-salesQuoteLines':
                CreateEndpointSalesQuoteLines(SPBDBraiderConfigHeader);
            'SPB-salesShipments':
                CreateEndpointPostedSalesShipments(SPBDBraiderConfigHeader);
            'SPB-salesShipLines':
                CreateEndpointPostedSalesShipmentLines(SPBDBraiderConfigHeader);
            'SPB-applyVendEntries':
                CreateEndpointVendorLedgerEntries(SPBDBraiderConfigHeader);
            'SPB-purchaseInvoices':
                CreateEndpointPurchaseInvoices(SPBDBraiderConfigHeader);
            'SPB-purchaseInvLines':
                CreateEndpointPurchaseInvoiceLines(SPBDBraiderConfigHeader);
            'SPB-purchaseOrders':
                CreateEndpointPurchaseOrders(SPBDBraiderConfigHeader);
            'SPB-purchaseOrdLines':
                CreateEndpointPurchaseOrderLines(SPBDBraiderConfigHeader);
            'SPB-purchaseReceipts':
                CreateEndpointPurchaseReceipts(SPBDBraiderConfigHeader);
            'SPB-purchaseRecLines':
                CreateEndpointPurchaseReceiptLines(SPBDBraiderConfigHeader);
            'SPB-vendors':
                CreateEndpointVendors(SPBDBraiderConfigHeader);
            'SPB-vendorPayments':
                CreateEndpointVendorPayments(SPBDBraiderConfigHeader);
            'SPB-vendPaymJournals':
                CreateEndpointVendorPaymentJournals(SPBDBraiderConfigHeader);
            'SPB-items':
                CreateEndpointItems(SPBDBraiderConfigHeader);
            'SPB-itemCategories':
                CreateEndpointItemCategories(SPBDBraiderConfigHeader);
            'SPB-itemLedgEntries':
                CreateEndpointItemLedgerEntries(SPBDBraiderConfigHeader);
            'SPB-itemVariants':
                CreateEndpointItemVariants(SPBDBraiderConfigHeader);
            'SPB-locations':
                CreateEndpointLocations(SPBDBraiderConfigHeader);
            'SPB-genProdPostGrps':
                CreateEndpointGeneralProductionPostingGroups(SPBDBraiderConfigHeader);
            'SPB-invPostGroups':
                CreateEndpointInventoryPostingGroups(SPBDBraiderConfigHeader);
            'SPB-employees':
                CreateEndpointEmployees(SPBDBraiderConfigHeader);
            'SPB-jobs':
                CreateEndpointJobs(SPBDBraiderConfigHeader);
            'SPB-companies':
                CreateEndpointCompanies(SPBDBraiderConfigHeader);
            'SPB-companyInfo':
                CreateEndpointCompanyInformation(SPBDBraiderConfigHeader);
            'SPB-countryRegions':
                CreateEndpointCountriesRegions(SPBDBraiderConfigHeader);
            'SPB-currencies':
                CreateEndpointCurrencies(SPBDBraiderConfigHeader);
            'SPB-defaultDims':
                CreateEndpointDefaultDimensions(SPBDBraiderConfigHeader);
            'SPB-dimensions':
                CreateEndpointDimensions(SPBDBraiderConfigHeader);
            'SPB-dimValues':
                CreateEndpointDimensionValues(SPBDBraiderConfigHeader);
            'SPB-paymentMethods':
                CreateEndpointPaymentMethods(SPBDBraiderConfigHeader);
            'SPB-paymentTerms':
                CreateEndpointPaymentTerms(SPBDBraiderConfigHeader);
            'SPB-shipmentMethods':
                CreateEndpointShipmentMethods(SPBDBraiderConfigHeader);
            'SPB-taxAreas':
                CreateEndpointTaxAreas(SPBDBraiderConfigHeader);
            'SPB-taxGroups':
                CreateEndpointTaxGroups(SPBDBraiderConfigHeader);
            'SPB-unitOfMeasures':
                CreateEndpointUnitOfMeasures(SPBDBraiderConfigHeader);
        end;

    end;

    procedure AddTableToEndpoint(
        var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        var SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        TableID: Integer)
    var
        SPBDBraiderConfigLine2: Record "SPB DBraider Config. Line";
        NextLineNo: Integer;
    begin
        SPBDBraiderConfigLine2.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        if SPBDBraiderConfigLine2.FindLast() then
            NextLineNo := SPBDBraiderConfigLine2."Line No." + 10000
        else
            NextLineNo := 10000;
        SPBDBraiderConfigLine.Init();
        SPBDBraiderConfigLine."Config. Code" := SPBDBraiderConfigHeader.Code;
        SPBDBraiderConfigLine."Line No." := NextLineNo;
        SPBDBraiderConfigLine.Validate("Source Table", TableID);
        SPBDBraiderConfigLine.Insert(true);
    end;

    procedure AddFieldToTable(
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        FieldNo: Integer;
        FilterString: Text[250];
        WriteEnabled: Boolean;
        IsMandatory: Boolean;
        UpsertEnabled: Boolean) SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field"
    begin
        if SPBDBraiderConfLineField.Get(SPBDBraiderConfigLine."Config. Code", SPBDBraiderConfigLine."Line No.", FieldNo) then begin
            SPBDBraiderConfLineField.Validate(Included, true);
            if FilterString <> '' then
                SPBDBraiderConfLineField.Validate(Filter, FilterString);
            SPBDBraiderConfLineField.Validate("Write Enabled", WriteEnabled);
            SPBDBraiderConfLineField.Validate("Mandatory", IsMandatory);
            SPBDBraiderConfLineField.Validate("Upsert Match", UpsertEnabled);
            SPBDBraiderConfLineField.Modify(true);
        end;
    end;

    local procedure CreateParentChild(SPBDBraiderConfigLine: Record "SPB DBraider Config. Line")
    begin
        if SPBDBraiderConfigLine.CheckIndentation() then begin
            SPBDBraiderConfigLine.LockTable();
            SPBDBraiderConfigLine.Indentation += 1;
            SPBDBraiderConfigLine.UpdateParent();
            SPBDBraiderConfigLine.CheckRelationshipConfigured();
            SPBDBraiderConfigLine.Modify(true);
        end
    end;

    procedure CreateEndpointUnitOfMeasures(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Unit of Measure");
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo("International Standard Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo(Symbol), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, UnitOfMeasure.FieldNo("Last Modified Date Time"), '', true, false, false);
    end;

    procedure CreateEndpointTaxGroups(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Balance Sheet Buffer");
        AddFieldToTable(SPBDBraiderConfigLine, TaxGroup.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxGroup.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxGroup.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxGroup.FieldNo("Last Modified DateTime"), '', true, false, false);
    end;

    procedure CreateEndpointTaxAreas(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Tax Area");
        AddFieldToTable(SPBDBraiderConfigLine, TaxArea.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxArea.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxArea.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, TaxArea.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointShipmentMethods(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Shipment Method");
        AddFieldToTable(SPBDBraiderConfigLine, ShipmentMethod.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ShipmentMethod.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ShipmentMethod.FieldNo("Description"), '', true, false, false);
    end;


    procedure CreateEndpointPaymentTerms(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Payment Terms");
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Due Date Calculation"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Discount Date Calculation"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Calc. Pmt. Disc. on Cr. Memos"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentTerms.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointPaymentMethods(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Payment Method");
        AddFieldToTable(SPBDBraiderConfigLine, PaymentMethod.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentMethod.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentMethod.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PaymentMethod.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointDimensionValues(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Dimension Value");
        AddFieldToTable(SPBDBraiderConfigLine, DimensionValue.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DimensionValue.FieldNo("Dimension Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DimensionValue.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DimensionValue.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DimensionValue.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointDimensions(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Dimension");
        AddFieldToTable(SPBDBraiderConfigLine, Dimension.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Dimension.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Dimension.FieldNo("Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Dimension.FieldNo("Last Modified Date Time"), '', true, false, false);


    end;

    procedure CreateEndpointDefaultDimensions(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Default Dimension");
        AddFieldToTable(SPBDBraiderConfigLine, DefaultDim.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DefaultDim.FieldNo("Parent Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DefaultDim.FieldNo(ParentId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DefaultDim.FieldNo("Dimension Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, DefaultDim.FieldNo("Dimension Value Code"), '', true, false, false);


    end;

    procedure CreateEndpointCurrencies(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::Currency);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo(Code), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo(Symbol), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo("Amount Decimal Places"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo("Amount Rounding Precision"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Currency.FieldNo("Last Modified Date Time"), '', true, false, false);


    end;

    procedure CreateEndpointCountriesRegions(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Country/Region");
        AddFieldToTable(SPBDBraiderConfigLine, CountryRegion.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CountryRegion.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CountryRegion.FieldNo("Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CountryRegion.FieldNo("Address Format"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CountryRegion.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointCompanyInformation(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Company Information");
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Fax No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Home Page"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("VAT Registration No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo("Last Modified Date Time"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyInformation.FieldNo(Picture), '', true, false, false);
    end;

    procedure CreateEndpointCompanies(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Company");
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo("Display Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo("Business Profile Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(SystemCreatedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(SystemCreatedBy), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CompanyRec.FieldNo(SystemModifiedBy), '', true, false, false);


    end;

    procedure CreateEndpointJobs(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Job");
        AddFieldToTable(SPBDBraiderConfigLine, Job.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Job.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Job.FieldNo("Description"), '', true, false, false);


    end;

    procedure CreateEndpointEmployees(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Employee");
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Search Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("First Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Middle Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Last Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Job Title"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Mobile Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Company E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Employment Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Termination Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Birth Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Statistics Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Employee.FieldNo("Last Modified Date Time"), '', true, false, false);


    end;

    procedure CreateEndpointInventoryPostingGroups(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Inventory Posting Group");
        AddFieldToTable(SPBDBraiderConfigLine, InventoryPostingGroup.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, InventoryPostingGroup.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, InventoryPostingGroup.FieldNo("Description"), '', true, false, false);


    end;

    procedure CreateEndpointGeneralProductionPostingGroups(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Gen. Product Posting Group");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralProductionPostingGroup.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralProductionPostingGroup.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralProductionPostingGroup.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralProductionPostingGroup.FieldNo("Def. VAT Prod. Posting Group"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralProductionPostingGroup.FieldNo("Auto Insert Default"), '', true, false, false);


    end;

    procedure CreateEndpointLocations(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Location");
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo(Contact), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Location.FieldNo("Home Page"), '', true, false, false);


    end;

    procedure CreateEndpointItemVariants(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Item Variant");
        AddFieldToTable(SPBDBraiderConfigLine, ItemVariant.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemVariant.FieldNo("Item Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemVariant.FieldNo("Item No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemVariant.FieldNo(Code), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemVariant.FieldNo("Description"), '', true, false, false);


    end;

    procedure CreateEndpointItemLedgerEntries(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Item Ledger Entry");
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Entry No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Item No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Entry Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Source No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Source Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo(Quantity), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Sales Amount (Actual)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo("Cost Amount (Actual)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemLedgerEntry.FieldNo(SystemModifiedAt), '', true, false, false);


    end;

    procedure CreateEndpointItemCategories(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Item Category");
        AddFieldToTable(SPBDBraiderConfigLine, ItemCategory.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemCategory.FieldNo("Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemCategory.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ItemCategory.FieldNo("Last Modified Date Time"), '', true, false, false);


    end;

    procedure CreateEndpointItems(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Item");
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Description"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Item Category Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo(Blocked), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo(GTIN), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo(Inventory), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Price Includes VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Unit Cost"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Tax Group Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Base Unit of Measure"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Gen. Prod. Posting Group Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Gen. Prod. Posting Group"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Inventory Posting Group Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Inventory Posting Group"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Item.FieldNo("Last DateTime Modified"), '', true, false, false);


    end;

    procedure CreateEndpointVendorPaymentJournals(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Balance Sheet Buffer");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Template Type"), 'Payment', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Journal Template Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(BalAccountId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Bal. Account No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Last Modified DateTime"), '', true, false, false);


    end;

    procedure CreateEndpointVendorPayments(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Gen. Journal Line");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Document Type"), 'Payment', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account Type"), 'Vendor', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Applies-to Doc. Type"), 'Invoice', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Journal Template Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Journal Batch Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Vendor Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Applies-to Invoice Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Last Modified DateTime"), '', true, false, false);


    end;

    procedure CreateEndpointVendors(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Vendor");
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Home Page"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("VAT Registration No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Payment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Tax Liable"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(Blocked), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo(Balance), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Balance (LCY)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Vendor.FieldNo("Last Modified Date Time"), '', true, false, false);


    end;

    procedure CreateEndpointPurchaseReceiptLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purch. Rcpt. Line");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Unit Cost"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptLine.FieldNo("Expected Receipt Date"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointPurchaseReceipts(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purch. Rcpt. Header");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Vendor Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Buy-from Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Pay-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo("Order No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseReceiptHeader.FieldNo(SystemModifiedAt), '', true, false, false);

        CreateEndpointPurchaseReceiptLines(SPBDBraiderConfigHeader);

    end;

    procedure CreateEndpointPurchaseOrderLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purchase Line");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Document Type"), 'Order', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Unit Cost"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Expected Receipt Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Qty. Received (Base)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Qty. Invoiced (Base)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Qty. to Invoice"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Qty. to Receive"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointPurchaseOrders(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purchase Header");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Document Type"), 'Order', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Vendor Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Prices Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Purchaser Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Requested Receipt Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Completely Received"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Status"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        CreateEndpointPurchaseOrderLines(SPBDBraiderConfigHeader);

    end;

    procedure CreateEndpointPurchaseInvoiceLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purchase Line");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Document Type"), 'Invoice', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Unit Cost"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Expected Receipt Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseLine.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointPurchaseInvoices(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Purchase Header");
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Document Type"), 'Invoice', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Vendor Invoice No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Vendor Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Buy-from Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Pay-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Vendor Order No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Prices Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo("Status"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, PurchaseHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        CreateEndpointPurchaseInvoiceLines(SPBDBraiderConfigHeader);

    end;

    procedure CreateEndpointVendorLedgerEntries(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Vendor Ledger Entry");
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Applying Entry"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Applies-to ID"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Document Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Vendor No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Vendor Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, VendorLedgerEntry.FieldNo("Remaining Amount"), '', true, false, false);


    end;

    procedure CreateEndpointPostedSalesShipmentLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Shipment Line");
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Document Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentLines.FieldNo("Shipment Date"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointPostedSalesShipments(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Shipment Header");
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("No."), 'Shipment', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Your Reference"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Bill-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Prices Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesShipmentHeader.FieldNo("Sell-to E-Mail"), '', true, false, false);

        CreateEndpointPostedSalesShipmentLines(SPBDBraiderConfigHeader);
    end;

    procedure CreateEndpointSalesQuoteLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Line");
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document Type"), 'Quote', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointSalesQuotes(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Header");
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Type"), 'Quote', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipment Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Quote Valid Until Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Quote Accepted Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to E-Mail"), '', true, false, false);

        CreateEndpointSalesQuoteLines(SPBDBraiderConfigHeader);
    end;

    procedure CreateEndpointSalesOrderLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Line");
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document Type"), 'Order', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Shipment Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity Shipped"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity Invoiced"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Qty. to Invoice"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Qty. to Ship"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointSalesOrders(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Header");
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Type"), 'Order', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipping Advice"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Requested Delivery Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Completely Shipped"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to E-Mail"), '', true, false, false);
        CreateEndpointSalesOrderLines(SPBDBraiderConfigHeader);

    end;

    procedure CreateEndpointSalesInvoiceLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Line");
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document Type"), 'Invoice', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Shipment Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointSalesInvoices(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Header");
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Type"), 'Invoice', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Your Reference"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Contact"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Ship-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Prices Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to E-Mail"), '', true, false, false);

        CreateEndpointSalesInvoiceLines(SPBDBraiderConfigHeader);
    end;

    procedure CreateEndpointSalesCreditMemoLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Line");
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document Type"), 'Credit Memo', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit of Measure Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Unit Price"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Quantity"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Line Discount %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("VAT %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Shipment Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesLines.FieldNo("Location Code"), '', true, false, false);

        CreateParentChild(SPBDBraiderConfigLine);
    end;

    procedure CreateEndpointCreateSalesCreditMemos(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Sales Header");
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Type"), 'Credit Memo', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Document Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Due Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to City"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Bill-to Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 1 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shortcut Dimension 2 Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Payment Terms Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Shipment Method Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Prices Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Invoice Discount Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Amount Including VAT"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo(SystemModifiedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, SalesHeader.FieldNo("Sell-to E-Mail"), '', true, false, false);

        CreateEndpointSalesCreditMemoLines(SPBDBraiderConfigHeader);

    end;

    procedure CreateEndpointOpportunities(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::Opportunity);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Contact No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Contact Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Contact Company Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(Status), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(Closed), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Creation Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Date Closed"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Calcd. Current Value (LCY)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Chances of Success %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Completed %"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Estimated Closing Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo("Estimated Value (LCY)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(SystemCreatedAt), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Opportunity.FieldNo(SystemModifiedAt), '', true, false, false);

    end;

    procedure CreateEndpointCustomerSales(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Cust. Ledger Entry");
        AddFieldToTable(SPBDBraiderConfigLine, CustLedgEntry.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CustLedgEntry.FieldNo("Customer No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CustLedgEntry.FieldNo("Customer Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CustLedgEntry.FieldNo("Sales (LCY)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, CustLedgEntry.FieldNo("Date Filter"), '', true, false, false);

    end;

    procedure CreateEndpointReturnReasons(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Return Reason");
        AddFieldToTable(SPBDBraiderConfigLine, ReturnReason.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ReturnReason.FieldNo(Code), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ReturnReason.FieldNo(Description), '', true, false, false);

    end;

    procedure CreateEndpointCustomerPayments(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Gen. Journal Line");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Journal Batch Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Customer Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account Type"), 'Customer', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Applies-to Invoice Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Applies-to Doc. No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Comment), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Last Modified DateTime"), '', true, false, false);

    end;

    procedure CreateEndpointCustomerFinancialDetails(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::Customer);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(Balance), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Balance Due"), '', true, false, false);

    end;

    procedure CreateEndpointCustomers(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::Customer);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Home Page"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Salesperson Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Balance Due"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Credit Limit (LCY)"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Tax Liable"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Tax Area ID"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Tax Area Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Registration Number"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Currency Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Currency Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Payment Terms Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Shipment Method Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Payment Method Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo(Blocked), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Customer.FieldNo("Last Modified Date Time"), '', true, false, false);

    end;

    procedure CreateEndpointContactInformation(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Contact Business Relation");
        AddFieldToTable(SPBDBraiderConfigLine, ContactBusinessRelation.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ContactBusinessRelation.FieldNo("Contact No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ContactBusinessRelation.FieldNo("Contact Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ContactBusinessRelation.FieldNo("Business Relation Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, ContactBusinessRelation.FieldNo("Link to Table"), '', true, false, false);

    end;

    procedure CreateEndpointContacts(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::Contact);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo(Type), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Company No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Company Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Contact Business Relation"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo(Address), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Address 2"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo(City), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Country/Region Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Post Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Mobile Phone No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("E-Mail"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Home Page"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Search Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Privacy Blocked"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Date of Last Interaction"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Last Date Modified"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, Contacts.FieldNo("Last Time Modified"), '', true, false, false);

    end;

    procedure CreateEndpointGeneralJournalLines(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Gen. Journal Line");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Journal Batch Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Journal Template Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Line No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Account No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("External Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Amount), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo(Comment), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Tax Group Code"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Bal. Account Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Balance Account Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalLines.FieldNo("Last Modified DateTime"), '', true, false, false);

    end;


    procedure CreateEndpointGeneralJournalBatches(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Gen. Journal Batch");
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Journal Template Name"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Last Modified DateTime"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo(BalAccountId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GeneralJournalBatches.FieldNo("Bal. Account No."), '', true, false, false);

    end;

    procedure CreateEndpointGeneralLedgerEntries(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigHeader.Validate("Endpoint Type", SPBDBraiderConfigHeader."Endpoint Type"::"Read Only");
        SPBDBraiderConfigHeader.Modify();

        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"G/L Entry");
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Entry No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Posting Date"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Document No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Document Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Account Id"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("G/L Account No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo(Description), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Debit Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Credit Amount"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLEntries.FieldNo("Last Modified DateTime"), '', true, false, false);
    end;

    procedure CreateEndpointBankAccounts(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"Bank Account");
        AddFieldToTable(SPBDBraiderConfigLine, BankAccounts.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, BankAccounts.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, BankAccounts.FieldNo(Name), '', true, false, false);
    end;

    procedure CreateEndpointGLAccounts(var SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        AddTableToEndpoint(SPBDBraiderConfigHeader, SPBDBraiderConfigLine, Database::"G/L Account");
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo(SystemId), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("No."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo(Name), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Account Category"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Account Subcategory Descript."), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo(Blocked), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Account Type"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Direct Posting"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Net Change"), '', true, false, false);
        AddFieldToTable(SPBDBraiderConfigLine, GLAccount.FieldNo("Last Modified Date Time"), '', true, false, false);
    end;
}
