codeunit 71033629 "SPB DBraider ROI Builder"
{
    Access = Internal;

    var
        TempSPBROIDetailLine: Record "SPB DBraider ROI Detail Line" temporary;
        AdditionalCreateHours: Decimal;
        AdditionalMaintainHours: Decimal;
        NextLineNo: Integer;

    procedure GetTotalROI(var CreationHours: Decimal; var MaintainHours: Decimal)
    begin
        BuildROIDetails();
        TempSPBROIDetailLine.SetFilter(Indentation, '>0');
        TempSPBROIDetailLine.CalcSums("Total Creation Hours", "Maintain Hours", "Support Hours");
        CreationHours := TempSPBROIDetailLine."Total Creation Hours";
        MaintainHours := TempSPBROIDetailLine."Maintain Hours" + TempSPBROIDetailLine."Support Hours";
    end;

    procedure BuildROIDetails()
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
        TempSPBROIDetailLine2: Record "SPB DBraider ROI Detail Line" temporary;
    begin
        TempSPBROIDetailLine.DeleteAll();
        if SPBDBraiderConfigHeader.FindSet() then
            repeat
                CalculateHeaderROI(SPBDBraiderConfigHeader);
            until SPBDBraiderConfigHeader.Next() < 1;

        // Now we need to 'sum' the line info back into the header for clarity for each endpoint
        TempSPBROIDetailLine2.Copy(TempSPBROIDetailLine, true);
        TempSPBROIDetailLine.SetFilter(Indentation, '0');
        TempSPBROIDetailLine2.SetFilter(Indentation, '>0');
        TempSPBROIDetailLine2.SetCurrentKey(Indentation, "Belongs To Line No.");
        if TempSPBROIDetailLine.FindSet() then
            repeat
                TempSPBROIDetailLine2.SetRange("Belongs To Line No.", TempSPBROIDetailLine."Line No.");
                TempSPBROIDetailLine2.CalcSums("Creation Hours", "Maintain Hours", "Consumption Hours", "Documentation Hours", "Support Hours", "Additional Creation Hours", "Additional Maintain Hours");
                TempSPBROIDetailLine.Validate("Creation Hours", TempSPBROIDetailLine2."Creation Hours");
                TempSPBROIDetailLine.Validate("Maintain Hours", TempSPBROIDetailLine2."Maintain Hours");
                TempSPBROIDetailLine.Validate("Consumption Hours", TempSPBROIDetailLine2."Consumption Hours");
                TempSPBROIDetailLine.Validate("Documentation Hours", TempSPBROIDetailLine2."Documentation Hours");
                TempSPBROIDetailLine.Validate("Support Hours", TempSPBROIDetailLine2."Support Hours");
                TempSPBROIDetailLine.Validate("Additional Creation Hours", TempSPBROIDetailLine2."Additional Creation Hours");
                TempSPBROIDetailLine.Validate("Additional Maintain Hours", TempSPBROIDetailLine2."Additional Maintain Hours");
                TempSPBROIDetailLine.Modify();
            until TempSPBROIDetailLine.Next() < 1;
        TempSPBROIDetailLine.Reset();
    end;

    procedure GetROIDetails(var TempOutputSPBROIDetailLine: Record "SPB DBraider ROI Detail Line" temporary)
    begin
        if TempSPBROIDetailLine.FindSet() then
            repeat
                TempOutputSPBROIDetailLine := TempSPBROIDetailLine;
                TempOutputSPBROIDetailLine.Insert();
            until TempSPBROIDetailLine.Next() < 1;
    end;

    procedure SetAdditionalHours(NewAdditionalCreationHours: Decimal; NewAdditionalMaintainHours: Decimal)
    begin
        AdditionalCreateHours := NewAdditionalCreationHours;
        AdditionalMaintainHours := NewAdditionalMaintainHours;
    end;

    local procedure CalculateHeaderROI(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header")
    var
        EndpointHeaderLineNo: Integer;
    begin
        TempSPBROIDetailLine.Init();
        TempSPBROIDetailLine."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBROIDetailLine.Description := StrSubstNo('Endpoint Total %1', SPBDBraiderConfigHeader.Code);
        EndpointHeaderLineNo := TempSPBROIDetailLine."Line No.";
        TempSPBROIDetailLine.Insert(true);

        TempSPBROIDetailLine.Init();
        TempSPBROIDetailLine."Line No." := NextLineNo;
        NextLineNo += 1;
        TempSPBROIDetailLine.Indentation := 1;
        TempSPBROIDetailLine.Description := 'Creation';
        case SPBDBraiderConfigHeader."Endpoint Type" of
            "SPB DBraider Endpoint Type"::"Read Only":
                begin
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.5);
                    TempSPBROIDetailLine.Validate("Consumption Hours", 0.5);
                    TempSPBROIDetailLine.Validate("Documentation Hours", 0.25);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.25);
                end;
            "SPB DBraider Endpoint Type"::"Per Record", "SPB DBraider Endpoint Type"::Batch:
                begin
                    TempSPBROIDetailLine.Validate("Creation Hours", 1);
                    TempSPBROIDetailLine.Validate("Consumption Hours", 0.75);
                    TempSPBROIDetailLine.Validate("Documentation Hours", 0.75);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.25);
                end;
        end;
        TempSPBROIDetailLine."Additional Creation Hours" := AdditionalCreateHours;
        TempSPBROIDetailLine."Additional Maintain Hours" := AdditionalMaintainHours;
        TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
        TempSPBROIDetailLine.Insert(true);

        // We want the Lines and Field information right after the creation
        CalculateLineROI(SPBDBraiderConfigHeader, EndpointHeaderLineNo);
        // But before the debugging, telemetry, etc

        if SPBDBraiderConfigHeader."Endpoint Type" in ["SPB DBraider Endpoint Type"::"Per Record", "SPB DBraider Endpoint Type"::Batch] then
            if (not SPBDBraiderConfigHeader."Insert Allowed") or
                (not SPBDBraiderConfigHeader."Modify Allowed") or
                (not SPBDBraiderConfigHeader."Delete Allowed")
            then begin
                TempSPBROIDetailLine.Init();
                TempSPBROIDetailLine."Line No." := NextLineNo;
                NextLineNo += 1;
                TempSPBROIDetailLine.Indentation := 1;
                TempSPBROIDetailLine.Description := 'Granular write-type controls in use';
                TempSPBROIDetailLine.Validate("Creation Hours", 0.5);
                TempSPBROIDetailLine.Validate("Maintain Hours", 0.25);
                TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                TempSPBROIDetailLine.Insert(true);
            end;

        if SPBDBraiderConfigHeader."Logging Enabled" then begin
            TempSPBROIDetailLine.Init();
            TempSPBROIDetailLine."Line No." := NextLineNo;
            NextLineNo += 1;
            TempSPBROIDetailLine.Indentation := 1;
            TempSPBROIDetailLine.Description := 'Logging enabled, making problem solving much faster.';
            if SPBDBraiderConfigHeader."Endpoint Type" in ["SPB DBraider Endpoint Type"::"Per Record", "SPB DBraider Endpoint Type"::Batch] then
                TempSPBROIDetailLine.Validate("Support Hours", 0.75)
            else
                TempSPBROIDetailLine.Validate("Support Hours", 2);
            TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
            TempSPBROIDetailLine.Insert(true);
        end;

        if SPBDBraiderConfigHeader."Emit Telemetry Include Body" or
            SPBDBraiderConfigHeader."Emit Telemetry Read Before" or
            SPBDBraiderConfigHeader."Emit Telemetry Read After" or
            SPBDBraiderConfigHeader."Emit Telemetry Write Before" or
            SPBDBraiderConfigHeader."Emit Telemetry Write After"
        then begin
            TempSPBROIDetailLine.Init();
            TempSPBROIDetailLine."Line No." := NextLineNo;
            NextLineNo += 1;
            TempSPBROIDetailLine.Indentation := 1;
            TempSPBROIDetailLine.Description := 'Telemetry enabled, making problem solving much faster.';
            TempSPBROIDetailLine.Validate("Support Hours", 2);
            TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
            TempSPBROIDetailLine.Insert(true);
        end;
    end;

    local procedure CalculateLineROI(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; EndpointHeaderLineNo: Integer)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        if SPBDBraiderConfigLine.Count() = 1 then begin
            SPBDBraiderConfigLine.FindFirst();
            CalculateFieldROI(SPBDBraiderConfigHeader, EndpointHeaderLineNo, SPBDBraiderConfigLine);
            exit;
        end;

        SPBDBraiderConfigLine.SetAutoCalcFields("Source Table Name");
        if SPBDBraiderConfigLine.FindSet() then
            repeat
                TempSPBROIDetailLine.Init();
                TempSPBROIDetailLine."Line No." := NextLineNo;
                NextLineNo += 1;
                TempSPBROIDetailLine.Indentation := 1;
                TempSPBROIDetailLine.Description := StrSubstNo('Additional Line %1', SPBDBraiderConfigLine."Source Table Name");
                TempSPBROIDetailLine.Validate("Creation Hours", 0.5);
                TempSPBROIDetailLine.Validate("Consumption Hours", 0.5);
                TempSPBROIDetailLine.Validate("Documentation Hours", 0.25);
                TempSPBROIDetailLine.Validate("Maintain Hours", 0.25);
                TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                TempSPBROIDetailLine.Insert(true);

                CalculateFieldROI(SPBDBraiderConfigHeader, EndpointHeaderLineNo, SPBDBraiderConfigLine);
            until SPBDBraiderConfigLine.Next() < 1;
    end;

    local procedure CalculateFieldROI(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; EndpointHeaderLineNo: Integer; SPBDBraiderConfigLine: Record "SPB DBraider Config. Line")
    var
        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlow: Record "SPB DBraider ConfLine Flow";
    begin
        // For field level info, we'll indent to 2.
        SPBDBraiderConfLineField.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        SPBDBraiderConfLineField.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
        SPBDBraiderConfLineField.SetAutoCalcFields("Field Name");
        if SPBDBraiderConfLineField.FindSet() then
            repeat
                if SPBDBraiderConfLineField.Included then begin
                    TempSPBROIDetailLine.Init();
                    TempSPBROIDetailLine."Line No." := NextLineNo;
                    NextLineNo += 1;
                    TempSPBROIDetailLine.Indentation := 2;
                    TempSPBROIDetailLine.Description := StrSubstNo('Field %1 included', SPBDBraiderConfLineField."Field Name");
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.05);
                    TempSPBROIDetailLine.Validate("Consumption Hours", 0.05);
                    TempSPBROIDetailLine.Validate("Documentation Hours", 0.05);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.05);
                    TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                    TempSPBROIDetailLine.Insert(true);
                end;

                if SPBDBraiderConfLineField.Filter <> '' then begin
                    TempSPBROIDetailLine.Init();
                    TempSPBROIDetailLine."Line No." := NextLineNo;
                    NextLineNo += 1;
                    TempSPBROIDetailLine.Indentation := 2;
                    TempSPBROIDetailLine.Description := StrSubstNo('Field %1 has a filter', SPBDBraiderConfLineField."Field Name");
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.15);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.05);
                    TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                    TempSPBROIDetailLine.Insert(true);
                end;

                if SPBDBraiderConfLineField."Write Enabled" then begin
                    TempSPBROIDetailLine.Init();
                    TempSPBROIDetailLine."Line No." := NextLineNo;
                    NextLineNo += 1;
                    TempSPBROIDetailLine.Indentation := 2;
                    TempSPBROIDetailLine.Description := StrSubstNo('Field %1 is write enabled', SPBDBraiderConfLineField."Field Name");
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.15);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.05);
                    TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                    TempSPBROIDetailLine.Insert(true);
                end;

                if SPBDBraiderConfLineField."Default Value" <> '' then begin
                    TempSPBROIDetailLine.Init();
                    TempSPBROIDetailLine."Line No." := NextLineNo;
                    NextLineNo += 1;
                    TempSPBROIDetailLine.Indentation := 2;
                    TempSPBROIDetailLine.Description := StrSubstNo('Field %1 has a default value', SPBDBraiderConfLineField."Field Name");
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.15);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.05);
                    TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                    TempSPBROIDetailLine.Insert(true);
                end;

                if SPBDBraiderConfLineField.Mandatory then begin
                    TempSPBROIDetailLine.Init();
                    TempSPBROIDetailLine."Line No." := NextLineNo;
                    NextLineNo += 1;
                    TempSPBROIDetailLine.Indentation := 2;
                    TempSPBROIDetailLine.Description := StrSubstNo('Field %1 is mandatory', SPBDBraiderConfLineField."Field Name");
                    TempSPBROIDetailLine.Validate("Creation Hours", 0.15);
                    TempSPBROIDetailLine.Validate("Maintain Hours", 0.05);
                    TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                    TempSPBROIDetailLine.Insert(true);
                end;


            until SPBDBraiderConfLineField.Next() < 1;

        SPBDBraiderConfLineFlow.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        SPBDBraiderConfLineFlow.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
        SPBDBraiderConfLineFlow.SetAutoCalcFields("Parent Field Name");
        if SPBDBraiderConfLineFlow.FindSet() then
            repeat
                TempSPBROIDetailLine.Init();
                TempSPBROIDetailLine."Line No." := NextLineNo;
                NextLineNo += 1;
                TempSPBROIDetailLine.Indentation := 2;
                TempSPBROIDetailLine.Description := StrSubstNo('FlowField %1', SPBDBraiderConfLineFlow."Parent Field Name");
                TempSPBROIDetailLine.Validate("Creation Hours", 0.75);
                TempSPBROIDetailLine.Validate("Maintain Hours", 0.25);
                TempSPBROIDetailLine."Belongs To Line No." := EndpointHeaderLineNo;
                TempSPBROIDetailLine.Insert(true);
            until SPBDBraiderConfLineFlow.Next() < 1;
    end;

}