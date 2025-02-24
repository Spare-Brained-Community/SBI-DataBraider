controladdin "SPB JsonPrettyDisplay"
{
    HorizontalShrink = true;
    HorizontalStretch = true;
    MaximumHeight = 3000;
    MaximumWidth = 7000;
    MinimumHeight = 500;
    MinimumWidth = 700;
    RequestedHeight = 500;
    RequestedWidth = 700;
    Scripts = 'LargeTextDisplay/JsonPrettyDisplay/Script/main.js';
    StartupScript = 'LargeTextDisplay/JsonPrettyDisplay/Script/startup.js';

    StyleSheets = 'LargeTextDisplay/JsonPrettyDisplay/Stylesheet/style.css';
    VerticalShrink = true;
    VerticalStretch = true;

    event ControlReady();

    procedure init();

    procedure setJsonText(jsonText: Text);

    procedure setBasicText(basicText: Text);

    event resizedControl(newheight: Integer);
    procedure resizeIFrame(newheight: Integer);
}