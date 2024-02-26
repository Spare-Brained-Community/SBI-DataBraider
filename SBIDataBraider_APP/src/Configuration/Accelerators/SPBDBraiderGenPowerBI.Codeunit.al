codeunit 71033620 "SPB DBraider Gen PowerBI"
{
    Access = Internal;
    TableNo = "SPB DBraider Config. Header";

    var
        RenameFields: Boolean;

    trigger OnRun()
    var
        ResultBuilder: TextBuilder;
    begin
        Rec.TestField("Output JSON Type", Rec."Output JSON Type"::Flat);

        RenameFields := true;  // This was just to future proof the codeunit, but it's not used yet.  Always rename now.

        // The goal of this codeunit is to create a PowerBI Advanced Query (M Language) like the following sample from an endpoint named Sales Order:
        /*
let
    Source = OData.Feed("http://bcserver:7048/BC/api/sparebrained/databraider/v2.0/companies(57e88667-0c46-ee11-be71-6045bdac97e2)/read('SO')", null, [Implementation="2.0"]),
    Data = Source[jsonResult],
    #"Parsed JSON" = Json.Document(Data),
    #"Converted to Table" = Table.FromList(#"Parsed JSON", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded SalesOrders" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"SalesHeader.SelltoCustomerNo", "SalesHeader.No", "SalesHeader.ShiptoCode", "SalesHeader.OrderDate", "SalesHeader.PostingDate", "SalesHeader.DueDate", "SalesHeader.CurrencyCode", "SalesHeader.PricesIncludingVAT", "SalesHeader.Amount", "SalesHeader.AmountIncludingVAT", "SalesHeader.SelltoCustomerName", "SalesHeader.SelltoAddress", "SalesHeader.SelltoAddress2", "SalesHeader.SelltoCity", "SalesHeader.SelltoCountryRegionCode", "SalesHeader.timestamp", "SalesLine.Type", "SalesLine.No", "SalesLine.Description", "SalesLine.Quantity", "SalesLine.OutstandingQuantity", "SalesLine.UnitPrice", "SalesLine.UnitCostLCY", "SalesLine.LineDiscount", "SalesLine.LineDiscountAmount", "SalesLine.Amount", "SalesLine.AmountIncludingVAT", "SalesLine.LineAmount", "SalesLine.timestamp"}, {"SalesOrders.SalesHeader.SelltoCustomerNo", "SalesOrders.SalesHeader.No", "SalesOrders.SalesHeader.ShiptoCode", "SalesOrders.SalesHeader.OrderDate", "SalesOrders.SalesHeader.PostingDate", "SalesOrders.SalesHeader.DueDate", "SalesOrders.SalesHeader.CurrencyCode", "SalesOrders.SalesHeader.PricesIncludingVAT", "SalesOrders.SalesHeader.Amount", "SalesOrders.SalesHeader.AmountIncludingVAT", "SalesOrders.SalesHeader.SelltoCustomerName", "SalesOrders.SalesHeader.SelltoAddress", "SalesOrders.SalesHeader.SelltoAddress2", "SalesOrders.SalesHeader.SelltoCity", "SalesOrders.SalesHeader.SelltoCountryRegionCode", "SalesOrders.SalesHeader.timestamp", "SalesOrders.SalesLine.Type", "SalesOrders.SalesLine.No", "SalesOrders.SalesLine.Description", "SalesOrders.SalesLine.Quantity", "SalesOrders.SalesLine.OutstandingQuantity", "SalesOrders.SalesLine.UnitPrice", "SalesOrders.SalesLine.UnitCostLCY", "SalesOrders.SalesLine.LineDiscount", "SalesOrders.SalesLine.LineDiscountAmount", "SalesOrders.SalesLine.Amount", "SalesOrders.SalesLine.AmountIncludingVAT", "SalesOrders.SalesLine.LineAmount", "SalesOrders.SalesLine.timestamp"})
    #"Renamed Columns" = Table.RenameColumns(#"Expanded SalesOrders",{{"SalesOrders.SalesHeader.SelltoCustomerNo", "Sales Header - Sell-To Customer No."}, {"SalesOrders.SalesHeader.No", "Sales Header - Document No."}})
in
    #"Renamed Columns"
        */
        ResultBuilder.AppendLine('let');

        AddSourceLine(Rec, ResultBuilder);

        AddPreamble(ResultBuilder);

        AddEndpointLines(Rec, ResultBuilder);

        AddEndLines(Rec, ResultBuilder);

        DisplayResult(ResultBuilder);
    end;

    local procedure AddSourceLine(Rec: Record "SPB DBraider Config. Header"; ResultBuilder: TextBuilder)
    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        EndPointUri: Text;
    begin
        EndPointUri := SPBDBraiderUtilities.GetJsonEndpointURI(Rec);
        ResultBuilder.AppendLine('    Source = OData.Feed("' + EndPointUri + '", null, [Implementation="2.0"]),');
    end;

    local procedure AddPreamble(ResultBuilder: TextBuilder)
    begin
        ResultBuilder.AppendLine('    Data = Source[jsonResult],');
        ResultBuilder.AppendLine('    #"Braided JSON" = Json.Document(Data),');
        ResultBuilder.AppendLine('    #"Converted to Table" = Table.FromList(#"Braided JSON", Splitter.SplitByNothing(), null, null, ExtraValues.Error),');
    end;

    local procedure AddEndpointLines(Rec: Record "SPB DBraider Config. Header"; ResultBuilder: TextBuilder)
    var
        SPBDBraiderConfLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";
        FromName: List of [Text];
        ToName: List of [Text];
        FieldList: Text;
        FieldMappingList: Text;
        i: Integer;
    begin
        SPBDBraiderConfLine.SetRange("Config. Code", Rec.Code);
        if SPBDBraiderConfLine.FindSet() then
            repeat
                SPBDBraiderConfLineField.SetRange("Config. Code", Rec.Code);
                SPBDBraiderConfLineField.SetRange("Config. Line No.", SPBDBraiderConfLine."Line No.");
                SPBDBraiderConfLineField.SetRange(Included, true);
                SPBDBraiderConfLineField.SetAutoCalcFields("Table Name", "Field Name");
                if SPBDBraiderConfLineField.FindSet() then
                    repeat
                        FromName.Add(SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField."Table Name") + '.' + SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineField."Field Name"));
                        //ToName.Add(SPBDBraiderUtilities.GetFieldCaption(SPBDBraiderConfLineField."Table Name", SPBDBraiderConfLineField."Field Name"));
                        ToName.Add(SPBDBraiderConfLineField."Table Name" + ' - ' + SPBDBraiderConfLineField."Field Name");
                    until SPBDBraiderConfLineField.Next() < 1;
            until SPBDBraiderConfLine.Next() < 1;

        for i := 1 to FromName.Count do begin
            FieldList := FieldList + '"' + FromName.Get(i) + '"';
            if i < FromName.Count then
                FieldList := FieldList + ', ';
        end;
        ResultBuilder.AppendLine('    #"Expanded ' + Rec.Description + '" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {' + FieldList + '}),');

        // For i to FromName.Count do, also get the ToName of the same index, and then Add the FromName and ToName to the FieldMappingList in the format of {"FromName", "ToName"},
        for i := 1 to FromName.Count do begin
            FieldMappingList := FieldMappingList + '{"' + FromName.Get(i) + '", "' + ToName.Get(i) + '"}';
            if i < FromName.Count then
                FieldMappingList := FieldMappingList + ', ';
        end;

        ResultBuilder.AppendLine('    #"Renamed Columns" = Table.RenameColumns(#"Expanded ' + Rec.Description + '",{' + FieldMappingList + '})');
    end;

    local procedure AddEndLines(Rec: Record "SPB DBraider Config. Header"; ResultBuilder: TextBuilder)
    begin
        ResultBuilder.AppendLine('in');
        if RenameFields then
            ResultBuilder.AppendLine('    #"Renamed Columns"')
        else
            ResultBuilder.AppendLine('    #"Expanded ' + Rec.Description + '"');
    end;

    local procedure DisplayResult(ResultBuilder: TextBuilder)
    var
        SPBDBraiderLargeTextView: Page "SPB DBraider Large Text View";
        MLanguageText: Text;
        PowerBIInstructionTxt: Label 'Below is the M Language code to use in PowerBI to connect to the endpoint and braid the JSON data.  Copy the below code (click on the code, and use keyboard shortcuts to Select All and Copy, such as Ctrl+A then Ctrl+C) and paste it into the Advanced Query Editor in PowerBI.  After pasting, you may need to adjust the endpoint URL and the field names to match your environment.';
    begin
        MLanguageText := ResultBuilder.ToText();
        SPBDBraiderLargeTextView.SetTextToShow(MLanguageText);
        SPBDBraiderLargeTextView.SetCaptionToShow(PowerBIInstructionTxt);
        SPBDBraiderLargeTextView.RunModal();
    end;
}
