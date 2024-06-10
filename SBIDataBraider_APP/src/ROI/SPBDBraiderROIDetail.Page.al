page 71033623 "SPB DBraider ROI Detail"
{
    AboutText = 'This page is to help you understand the savings you can achieve by using Data Braider. We''ve pre-populated some values for you, but feel free to adjust them to match your organization''s needs.';
    AboutTitle = 'Data Braider ROI Calculator';
    ApplicationArea = All;
    Caption = 'Data Braider ROI Calculator';
    PageType = Worksheet;
    SourceTable = "SPB DBraider ROI Detail Line";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(CostResults)
            {
                AboutText = 'Based on the values you''ve entered and the endpoints created, here are the estimated costs for Custom API development of a similar result. Creation is typically one time, while maintaining is an annual or even monthly cost.';
                AboutTitle = 'Total and Cost Results';
                Caption = 'Total and Cost Results';
                //InstructionalText = 'Based on the values you''ve entered, here are the estimated costs for creating and maintaining your endpoints';
                field("Total Creation Hours"; TotalCreationHours)
                {
                    Caption = 'Creation Hours';
                    Editable = false;
                    ToolTip = 'Specifies the total number of hours required to create all endpoints.';
                }
                field("Total Maintain Hours"; TotalMaintainHours)
                {
                    Caption = 'Maintain Hours';
                    Editable = false;
                    ToolTip = 'Specifies the total number of hours required to maintain all endpoints.';
                }
                field("Total Additional Creation Hours"; TotalAdditionalCreationHours)
                {
                    Caption = 'Addtl. Creation Hours';
                    Editable = false;
                    ToolTip = 'Specifies the total number of additional hours required to create all endpoints.';
                }
                field("Total Additional Maintain Hours"; TotalAdditionalMaintainHours)
                {
                    Caption = 'Addtl. Maintain Hours';
                    Editable = false;
                    ToolTip = 'Specifies the total number of additional hours required to maintain all endpoints.';
                }
                field("Hourly Rate"; HourlyRate)
                {
                    AboutText = 'You can set what sort of average cost per hour you want to use for your resources. This will be used to calculate the total costs for creating and maintaining your endpoints.';
                    AboutTitle = 'Hourly Rate';
                    Caption = 'Hourly Rate';
                    ToolTip = 'Specifies the hourly rate for the resources working on the endpoints.';
                    trigger OnValidate()
                    begin
                        CalculateCosts();
                    end;
                }
                field("Total Create Cost"; TotalCreateCost)
                {
                    Caption = 'Create Cost';
                    Editable = false;
                    ToolTip = 'Specifies the total cost to create all endpoints.';
                }
                field("Total Maintain Cost"; TotalMaintainCost)
                {
                    Caption = 'Maintain Cost';
                    Editable = false;
                    ToolTip = 'Specifies the total cost to maintain all endpoints.';
                }
            }

            repeater(LineDetails)
            {
                Editable = false;
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                field(Indentation; Rec.Indentation)
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Indentation field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Creation Hours"; Rec."Creation Hours")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Creation Hours field.';
                }
                field("Consumption Hours"; Rec."Consumption Hours")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Consumption Hours field.';
                }
                field("Documentation Hours"; Rec."Documentation Hours")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Documentation Hours field.';
                }
                field("Maintain Hours"; Rec."Maintain Hours")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Maintain Hours field.';
                }
                field("Support Hours"; Rec."Support Hours")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Support Hours field.';
                }
            }
            group(AdditionalCostsSettings)
            {
                AboutText = 'If you and your partner/developer add things like specifications, deployment, project management, and other costs, you can add them here.  These are per-end endpoint. Don''t forget to factor in the hours you will spend on confirming delivery and other project management aspects.';
                AboutTitle = 'Additional Costs';
                Caption = 'Additional Costs and Settings';
                field("Additional Creation Hours"; AdditionalCreateHours)
                {
                    Caption = 'Addtl. Creation Hours';
                    ToolTip = 'Specifies how many hours to add per endpoint for creation related tasks. This could include things like specifications, deployment, project management, and other costs.';
                    trigger OnValidate()
                    begin
                        SPBDBraiderROIBuilder.SetAdditionalHours(AdditionalCreateHours, AdditionalMaintainHours);
                        UpdateCalculations();
                    end;
                }
                field("Additional Maintain Hours"; AdditionalMaintainHours)
                {
                    Caption = 'Addtl. Maintain Hours';
                    ToolTip = 'Specifies how many hours to add per endpoint for maintenance related tasks. This typically would include things like support, bug fixes, and other costs.';
                    trigger OnValidate()
                    begin
                        SPBDBraiderROIBuilder.SetAdditionalHours(AdditionalCreateHours, AdditionalMaintainHours);
                        UpdateCalculations();
                    end;
                }
            }

        }

    }

    var
        TempOutputSPBROIDetailLine: Record "SPB DBraider ROI Detail Line" temporary;
        SPBDBraiderROIBuilder: Codeunit "SPB DBraider ROI Builder";
        AdditionalCreateHours: Decimal;
        AdditionalMaintainHours: Decimal;
        TotalCreationHours: Decimal;
        TotalMaintainHours: Decimal;
        TotalAdditionalCreationHours: Decimal;
        TotalAdditionalMaintainHours: Decimal;
        HourlyRate: Decimal;
        TotalCreateCost: Decimal;
        TotalMaintainCost: Decimal;

    trigger OnInit()
    begin
        Rec.Insert();
        HourlyRate := 100;
    end;

    trigger OnOpenPage()
    begin
        UpdateCalculations();
    end;

    local procedure UpdateCalculations()
    begin
        Rec.DeleteAll();
        SPBDBraiderROIBuilder.BuildROIDetails();
        SPBDBraiderROIBuilder.GetROIDetails(Rec);
        if Rec.FindFirst() then;
        TempOutputSPBROIDetailLine.Copy(Rec, true);

        TempOutputSPBROIDetailLine.SetCurrentKey(Indentation);
        TempOutputSPBROIDetailLine.SetFilter(Indentation, '0');  // It comes pre-summed on Indentaion 0 lines
        TempOutputSPBROIDetailLine.CalcSums("Total Creation Hours", "Maintain Hours", "Support Hours", "Additional Creation Hours", "Additional Maintain Hours");

        TotalCreationHours := TempOutputSPBROIDetailLine."Total Creation Hours";
        TotalMaintainHours := TempOutputSPBROIDetailLine."Maintain Hours" + TempOutputSPBROIDetailLine."Support Hours";
        TotalAdditionalCreationHours := TempOutputSPBROIDetailLine."Additional Creation Hours";
        TotalAdditionalMaintainHours := TempOutputSPBROIDetailLine."Additional Maintain Hours";

        CalculateCosts();
    end;

    local procedure CalculateCosts()
    begin
        TotalCreateCost := (TotalCreationHours + TotalAdditionalCreationHours) * HourlyRate;
        TotalMaintainCost := (TotalMaintainHours + TotalAdditionalMaintainHours) * HourlyRate;
    end;

}