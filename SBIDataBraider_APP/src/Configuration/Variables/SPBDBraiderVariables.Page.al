page 71033624 "SPB DBraider Variables"
{
    AboutText = 'These are variables, scoped to different levels, that can be used in Endpoint configurations for Filters and Default Values.';
    AboutTitle = 'Data Braider Variables';
    ApplicationArea = All;
    Caption = 'Data Braider Variables';
    PageType = List;
    SourceTable = "SPB DBraider Env Variable";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Variable Scope"; Rec."Variable Scope")
                {
                    ToolTip = 'Specifies the value of the Variable Scope field.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field.';
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the value of the User Name field.';
                }
                field(Tag; Rec.Tag)
                {
                    AboutText = 'When you define a Tag, you can use it in the Filter or Default Value fields of an Endpoint.  Surround it with two sets of curly braces, like this: {{Tag}}.';
                    AboutTitle = 'Tag';
                    ToolTip = 'Specifies the value of the Tag field.';
                }
                field(Value; Rec."Value")
                {
                    ToolTip = 'Specifies the value of the Value field.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
            }
        }
    }
}
