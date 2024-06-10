page 71033603 "SPB DBraider Config. Line"
{

    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Endpoint Line';
    PageType = ListPart;
    SourceTable = "SPB DBraider Config. Line";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = "Source Table Name";

                field("Config. Code"; Rec."Config. Code")
                {
                    ToolTip = 'Specifies the value of the Config. Code field';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field';
                    Visible = false;
                }
                field("Source Table"; Rec."Source Table")
                {
                    ToolTip = 'Which Table ID data should be interacted with';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Source Table Name", "Field Count");
                    end;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    Editable = false;
                    ToolTip = 'The Table Name of the Source Table ID';
                }
                field("Field Count"; Rec."Field Count")
                {
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'How many fields are available to be included in the data braid.';

                    trigger OnDrillDown()
                    var
                        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
                        SPBDBraiderConfigFields: Page "SPB DBraider Config. Fields";
                    begin
                        SPBDBraiderConfLineField.SetRange("Config. Code", Rec."Config. Code");
                        SPBDBraiderConfLineField.SetRange("Config. Line No.", Rec."Line No.");
                        SPBDBraiderConfigFields.SetTableView(SPBDBraiderConfLineField);
                        SPBDBraiderConfigFields.RunModal();
                    end;
                }
                field("Included Fields"; Rec."Included Fields")
                {
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'How many fields have been selected to be included in the data braid.';

                    trigger OnDrillDown()
                    var
                        SPBDBraiderConfLineField: Record "SPB DBraider ConfLine Field";
                        SPBDBraiderConfigFields: Page "SPB DBraider Config. Fields";
                    begin
                        SPBDBraiderConfLineField.SetRange("Config. Code", Rec."Config. Code");
                        SPBDBraiderConfLineField.SetRange("Config. Line No.", Rec."Line No.");
                        SPBDBraiderConfLineField.SetRange(Included, true);
                        SPBDBraiderConfigFields.SetTableView(SPBDBraiderConfLineField);
                        SPBDBraiderConfigFields.RunModal();
                    end;
                }
                field("Relationship Configured"; Rec."Relationship Configured")
                {
                    Editable = false;
                    ToolTip = 'If there are any Relationship settings connecting this table to a "parent" table.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(FieldsButtons)
            {
                Caption = 'Field Settings';
                action(PackageFields)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fields';
                    Image = CheckList;
                    ToolTip = 'View the fields that can be used to include, exclude or even filter on.';

                    trigger OnAction()
                    begin
                        Rec.ShowFieldList(true);
                    end;
                }
                action(FlowFields)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'FlowFields';
                    Enabled = Rec.Indentation > 0;
                    Image = CheckList;
                    ToolTip = 'An advanced setting to allow inclusion of FlowField data from the Parent table filtered on the Children''s field values.';

                    trigger OnAction()
                    begin
                        Rec.ShowFlowFieldList(true);
                    end;
                }
            }
            group(Relationships)
            {
                Caption = 'Relationships';
                action(Relationship)
                {
                    Caption = 'Relationship';
                    Enabled = Rec.Indentation > 0;
                    Image = MapAccounts;
                    ToolTip = 'How this record is related to the parent table';

                    trigger OnAction()
                    var
                        ChildAllObj: Record AllObjWithCaption;
                        ParentAllObj: Record AllObjWithCaption;
                        DBRelation: Record "SPB DBraider ConfLine Relation";
                        DBRelationship: Page "SPB DBraider Config Rel.";
                    begin
                        DBRelation.SetRange("Config. Code", Rec."Config. Code");
                        DBRelation.SetRange("Config. Line No.", Rec."Line No.");
                        DBRelation.SetRange("Parent Table", Rec."Parent Table No.");
                        DBRelation.SetRange("Child Table", Rec."Source Table");

                        ParentAllObj.SetRange("Object Type", ParentAllObj."Object Type"::Table);
                        ParentAllObj.SetRange("Object ID", Rec."Parent Table No.");
                        if ParentAllObj.FindFirst() then;
                        ChildAllObj.SetRange("Object Type", ChildAllObj."Object Type"::Table);
                        ChildAllObj.SetRange("Object ID", Rec."Source Table");
                        if ChildAllObj.FindFirst() then;

                        Clear(DBRelationship);
                        DBRelationship.SetTableView(DBRelation);
                        DBRelationship.ShowParentChild(ParentAllObj."Object Name", ChildAllObj."Object Name");
                        DBRelationship.RunModal();

                        Rec.CheckRelationshipConfigured();
                    end;
                }
                action(IndentAction)
                {
                    Caption = 'Move Right';
                    Enabled = ConfigLineCount > 1;
                    Image = Indent;
                    ToolTip = 'Increase indent of this data item, making it a "child" entry.';

                    trigger OnAction()
                    var
                        IndentErr: Label 'You can not indent a single table.';
                    begin
                        if Rec.CheckIndentation() then begin
                            Rec.LockTable();
                            Rec.Indentation += 1;
                            Rec.UpdateParent();
                            Rec.CheckRelationshipConfigured();
                            Rec.Modify(true);
                        end else
                            Error(IndentErr);
                    end;
                }
                action(DecreaseIndentAction)
                {
                    Caption = 'Move Left';
                    Enabled = Rec.Indentation > 0;
                    Image = DecreaseIndent;
                    ToolTip = 'Decrease indent of this data item.';

                    trigger OnAction()
                    begin
                        if Rec.Indentation > 0 then begin
                            Rec.Indentation -= 1;
                            Rec.UpdateParent();
                            Rec.CheckRelationshipConfigured();
                            Rec.Modify(true);
                        end;
                    end;
                }
            }
        }
    }

    var
        ConfigLineCount: Integer;

    trigger OnAfterGetCurrRecord()
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
    begin
        SPBDBraiderConfigLine.SetRange("Config. Code", Rec."Config. Code");
        ConfigLineCount := SPBDBraiderConfigLine.Count();
    end;
}
