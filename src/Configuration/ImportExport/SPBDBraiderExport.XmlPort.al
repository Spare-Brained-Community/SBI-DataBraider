xmlport 71033601 "SPB DBraider Export"
{
    Caption = 'Data Braider - Endpoint Export';
    Direction = Export;

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(SPBDBraiderConfigHeader; "SPB DBraider Config. Header")
            {
                RequestFilterFields = Code;
                RequestFilterHeading = 'Endpoint Filters';

                fieldelement(Code; SPBDBraiderConfigHeader."Code")
                {
                }
                fieldelement(Description; SPBDBraiderConfigHeader.Description)
                {
                }
                fieldelement(LastRunDuration; SPBDBraiderConfigHeader."Last Run Duration")
                {
                }
                fieldelement(EndpointType; SPBDBraiderConfigHeader."Endpoint Type")
                {
                }
                fieldelement(RequirePK; SPBDBraiderConfigHeader."Require PK")
                {
                }
                fieldelement(InsertAllowed; SPBDBraiderConfigHeader."Insert Allowed")
                {
                }
                fieldelement(ModifyAllowed; SPBDBraiderConfigHeader."Modify Allowed")
                {
                }
                fieldelement(DeleteAllowed; SPBDBraiderConfigHeader."Delete Allowed")
                {
                }
                fieldelement(OutputJSONType; SPBDBraiderConfigHeader."Output JSON Type")
                {
                }

                tableelement(SPBDBraiderConfigLine; "SPB DBraider Config. Line")
                {
                    LinkFields = "Config. Code" = field("Code");
                    LinkTable = SPBDBraiderConfigHeader;
                    SourceTableView = sorting("Config. Code", "Line No.") order(ascending);
                    fieldelement(ConfigCode; SPBDBraiderConfigLine."Config. Code")
                    {
                    }
                    fieldelement(LineNo; SPBDBraiderConfigLine."Line No.")
                    {
                    }
                    fieldelement(SourceTable; SPBDBraiderConfigLine."Source Table")
                    {
                    }
                    fieldelement(SourceTableName; SPBDBraiderConfigLine."Source Table Name")
                    {
                    }
                    fieldelement(Indentation; SPBDBraiderConfigLine.Indentation)
                    {
                    }
                    fieldelement(ParentTableNo; SPBDBraiderConfigLine."Parent Table No.")
                    {
                    }
                    fieldelement(RelationType; SPBDBraiderConfigLine."Relation Type")
                    {
                    }
                    fieldelement(RelationOperation; SPBDBraiderConfigLine."Relation Operation")
                    {
                    }
                    fieldelement(RelationshipConfigured; SPBDBraiderConfigLine."Relationship Configured")
                    {
                    }
                }

                tableelement(SPBDBraiderConfLineField; "SPB DBraider ConfLine Field")
                {
                    LinkFields = "Config. Code" = field("Code");
                    LinkTable = SPBDBraiderConfigHeader;
                    SourceTableView = sorting("Config. Code", "Config. Line No.", "Field No.") order(ascending);
                    fieldelement(ConfigCode; SPBDBraiderConfLineField."Config. Code")
                    {
                    }
                    fieldelement(ConfigLineNo; SPBDBraiderConfLineField."Config. Line No.")
                    {
                    }
                    fieldelement(FieldNo; SPBDBraiderConfLineField."Field No.")
                    {
                    }
                    fieldelement(Included; SPBDBraiderConfLineField.Included)
                    {
                    }
                    fieldelement(ProcessingOrder; SPBDBraiderConfLineField."Processing Order")
                    {
                    }
                    fieldelement(Filter; SPBDBraiderConfLineField."Filter")
                    {
                    }
                    fieldelement(WriteEnabled; SPBDBraiderConfLineField."Write Enabled")
                    {
                    }
                    fieldelement(DefaultValue; SPBDBraiderConfLineField."Default Value")
                    {
                    }
                    fieldelement(Mandatory; SPBDBraiderConfLineField.Mandatory)
                    {
                    }
                    fieldelement(TableNo; SPBDBraiderConfLineField."Table No.")
                    {
                    }
                    fieldelement(PrimaryKey; SPBDBraiderConfLineField."Primary Key")
                    {
                    }
                }
                tableelement(SPBDBraiderConfLineFlow; "SPB DBraider ConfLine Flow")
                {
                    LinkFields = "Config. Code" = field("Code");
                    LinkTable = SPBDBraiderConfigHeader;
                    SourceTableView = sorting("Config. Code", "Config. Line No.", "FlowField Line No.") order(ascending);

                    fieldelement(ConfigCode; SPBDBraiderConfLineFlow."Config. Code")
                    {
                    }
                    fieldelement(ConfigLineNo; SPBDBraiderConfLineFlow."Config. Line No.")
                    {
                    }
                    fieldelement(FlowFieldLineNo; SPBDBraiderConfLineFlow."FlowField Line No.")
                    {
                    }
                    fieldelement(ParentTableNo; SPBDBraiderConfLineFlow."Parent Table No.")
                    {
                    }
                    fieldelement(ParentFlowFilterFieldNo; SPBDBraiderConfLineFlow."Parent FlowFilter Field No.")
                    {
                    }
                    fieldelement(SourceTableNo; SPBDBraiderConfLineFlow."Source Table No.")
                    {
                    }
                    fieldelement(SourceFlowFilterFieldNo; SPBDBraiderConfLineFlow."Source FlowFilter Field No.")
                    {
                    }
                }

                tableelement(SPBDBraiderConfLineRelation; "SPB DBraider ConfLine Relation")
                {
                    LinkFields = "Config. Code" = field("Code");
                    LinkTable = SPBDBraiderConfigHeader;
                    SourceTableView = sorting("Config. Code", "Config. Line No.", "Relation Line No.") order(ascending);
                    fieldelement(ConfigCode; SPBDBraiderConfLineRelation."Config. Code")
                    {
                    }
                    fieldelement(ConfigLineNo; SPBDBraiderConfLineRelation."Config. Line No.")
                    {
                    }
                    fieldelement(RelationLineNo; SPBDBraiderConfLineRelation."Relation Line No.")
                    {
                    }
                    fieldelement(ParentTable; SPBDBraiderConfLineRelation."Parent Table")
                    {
                    }
                    fieldelement(ChildTable; SPBDBraiderConfLineRelation."Child Table")
                    {
                    }
                    fieldelement(ParentFieldNo; SPBDBraiderConfLineRelation."Parent Field No.")
                    {
                    }
                    fieldelement(ChildFieldNo; SPBDBraiderConfLineRelation."Child Field No.")
                    {
                    }
                    fieldelement(ManualLinking; SPBDBraiderConfLineRelation."Manual Linking")
                    {
                    }
                }
            }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    InstructionalText = 'This step allows you to export Data Braider Configurations.';
                    ShowCaption = false;
                }
            }
        }
    }
}
