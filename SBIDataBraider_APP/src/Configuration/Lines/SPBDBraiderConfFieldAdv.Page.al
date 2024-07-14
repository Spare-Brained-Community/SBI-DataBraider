page 71033621 "SPB DBraider Conf Field Adv"
{
    ApplicationArea = All;
    Caption = 'Endpoint Field - Advanced Settings';
    PageType = Card;
    SourceTable = "SPB DBraider ConfLine Field";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Information)
            {
                Caption = 'Information';

                field("Table Name"; Rec."Table Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field(Caption; Rec.Caption)
                {
                    Editable = false;
                    ToolTip = 'The field caption.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Type field.';
                }
                field("Field Class"; Rec."Field Class")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Class field.';
                }
                field("Manual Field Caption"; Rec."Manual Field Caption")
                {
                    ToolTip = 'Specifies caption to use when rendering the field data to outputs, such as JSON key value. Leave or set to blank to use the engine default.';
                }
                field("Primary Key"; Rec."Primary Key")
                {
                    Editable = false;
                    ToolTip = 'Specifies the field is part of the table''s primary key.';
                }
            }
            group(EndpointSettings)
            {
                Caption = 'Endpoint Settings';

                field(Included; Rec.Included)
                {
                    ToolTip = 'Should this field be included in the result set?';
                }
                field("Write Enabled"; Rec."Write Enabled")
                {
                    ToolTip = 'Specifies if the field should be changeable via the API.  If this is not checked, the field will be read-only.';
                    Visible = WriteEndpoint;
                }
                field("Filter"; Rec."Filter")
                {
                    ToolTip = 'This filter will be applied to the table based on this field, excluding any *records* that are outside the filter.';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ToolTip = 'Allows you to specify a default value for this field.  This value will be used if no value is provided for this field. If the field is not Write Enabled, that will make this Default the mandatory value.';
                    Visible = WriteEndpoint;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ToolTip = 'Controls if this field is mandatory.  If this is checked, the field must have a value or an error will occur.  If this is not checked, the field can be empty.';
                    Visible = WriteEndpoint;
                }
                field("Processing Order"; Rec."Processing Order")
                {
                    ToolTip = 'Specifies the value of the Processing Order field. This is the order in which the fields are processed. Lower numbers are processed first. Fields sharing the same Processing Order will then be handled by Field No.';
                    Visible = WriteEndpoint;
                }
            }
            group(Validation)
            {
                Caption = 'Validation';
                InstructionalText = 'Warning: All settings on this tab are for advanced users only.  Please use caution when changing these settings - you can cause significant damage to your data.';
                Visible = WriteEndpoint;

                field("Disable Auto-Split Key"; Rec."Disable Auto-Split Key")
                {
                    Enabled = Rec."Primary Key";
                    ToolTip = 'If an Endpoint has a Primary Key that ends with an Integer, typically that is automatically assigned by the UI.  Data Braider mimics this behavior in the API.  This option disables that behavior.  This can be a dangerous option, as you will be responsible for providing this integer.  Please use caution when using this option.  This option is only available for fields that are part of the Primary Key.';
                }
                field("Disable Validation"; Rec."Disable Validation")
                {
                    ToolTip = 'Disabled Validation on this field, either the initial data type checking or the actual field validation itself. This can be a dangerous option.  Please use caution when using this option.';
                }
                field("Modification Re-Validate"; Rec."Modification Re-Validate")
                {
                    ToolTip = 'When a record is modified, should the field be re-validated if unchanged? This behvaior is typically not needed.';
                }
            }
            group("DateTime")
            {
                Caption = 'DateTime Settings';
                Visible = Rec."Field Type" = Rec."Field Type"::DateTime;

                field("DateTime Timezone"; Rec."DateTime Timezone")
                {
                    AssistEdit = true;
                    Editable = false;
                    ToolTip = 'In case you need the date time to be forcibly converted to a specific time zone.  Otherwise, it will be in UTC';

                    trigger OnAssistEdit()
                    var
                        TimeZone: Record "Time Zone";
                        TimeZonesLookup: Page "Time Zones Lookup";
                    begin
                        if Rec."DateTime Timezone" <> '' then begin
                            TimeZone.SetRange(ID, Rec."DateTime Timezone");
                            if TimeZone.FindFirst() then;
                            TimeZone.SetRange(ID);
                        end;
                        Clear(TimeZonesLookup);
                        TimeZonesLookup.SetTableView(TimeZone);
                        TimeZonesLookup.LookupMode(true);
                        if TimeZonesLookup.RunModal() = Action::LookupOK then begin
                            TimeZonesLookup.GetRecord(TimeZone);
                            Rec."DateTime Timezone" := TimeZone.ID;
                        end;
                    end;
                }
            }
        }
    }

    var
        WriteEndpoint: Boolean;

    trigger OnOpenPage()
    var
        SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header";
    begin
        if SPBDBraiderConfigHeader.Get(Rec."Config. Code") then
            WriteEndpoint := SPBDBraiderConfigHeader.WriteableConfig();
    end;
}
