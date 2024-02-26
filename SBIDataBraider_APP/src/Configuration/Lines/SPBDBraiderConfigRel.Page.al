page 71033608 "SPB DBraider Config Rel."
{

    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Endpoint Relationship';
    PageType = List;
    SourceTable = "SPB DBraider ConfLine Relation";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(ConnectingInfo)
            {
                Caption = 'Setting the Connection between';
                field("Parent Table Name"; ShowParentNameAs)
                {
                    Caption = 'Parent Table';
                    Editable = false;
                    ToolTip = 'Which table is considered the Parent in this relationship.';
                }
                field("Child Table Name"; ShowChildNameAs)
                {
                    Caption = 'Child Table';
                    Editable = false;
                    ToolTip = 'Which table is considered the Child in this relationship.';
                }
            }
            repeater(General)
            {
                field("Parent Table"; Rec."Parent Table")
                {
                    ToolTip = 'Specifies the value of the Parent Table field';
                    Visible = false;
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {
                    ToolTip = 'Which Field to use from the Parent table as a connection point.';
                }
                field("Parent Field Caption"; Rec."Parent Field Caption")
                {
                    ToolTip = 'The Field Caption of the Parent Field selected in Parent Field No.';
                }
                field("Child Table"; Rec."Child Table")
                {
                    ToolTip = 'Specifies the value of the Child Table field';
                    Visible = false;
                }
                field("Child Field No."; Rec."Child Field No.")
                {
                    ToolTip = 'Which Field to use from the Child table as a connection point.';
                }
                field("Child Field Caption"; Rec."Child Field Caption")
                {
                    ToolTip = 'The Field Caption of the Child Field selected in Child Field No.';
                }
            }
        }
    }

    var
        ShowChildNameAs: Text;
        ShowParentNameAs: Text;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Parent Table" := Rec.GetRangeMin("Parent Table");
        Rec."Child Table" := Rec.GetRangeMin("Child Table");
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetManual();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SetManual();
    end;

    procedure ShowParentChild(newParentName: Text; newChildName: Text)
    begin
        ShowParentNameAs := newParentName;
        ShowChildNameAs := newChildName;
    end;

    local procedure SetManual()
    begin
        // If the user is adjusting or creating from this page, we'll mark it so no auto-regen routines clear it.
        Rec."Manual Linking" := true;
    end;
}
