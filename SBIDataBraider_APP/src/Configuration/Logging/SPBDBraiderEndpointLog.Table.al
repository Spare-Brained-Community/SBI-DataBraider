table 71033609 "SPB DBraider Endpoint Log"
{
    Caption = 'DBraider Endpoint Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            DataClassification = SystemMetadata;
            TableRelation = "SPB DBraider Config. Header".Code;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(3; User; Code[50])
        {
            Caption = 'User';
            TableRelation = User."User Name";
        }

        field(100; "Raw Input"; Blob)
        {
            Caption = 'Raw Input';
        }
        field(110; "Raw Output"; Blob)
        {
            Caption = 'Raw Output';
        }
        field(120; Success; Boolean)
        {
            Caption = 'Success';
        }
    }
    keys
    {
        key(PK; "Config. Code", "Entry No.") { }
    }

    procedure RetryRequestJson()
    var
        inS: InStream;
        LineOfText: Text;
        BlobTextBuilder: TextBuilder;
        RequestJsonString: Text;
        RequestDataErr: Label 'This Entry has invalid request data.';

    begin
        Rec.CalcFields("Raw Input");
        if rec."Raw Input".HasValue then begin
            Rec."Raw Input".CreateInStream(inS);
            while not inS.EOS do begin
                inS.ReadText(LineOfText);
                BlobTextBuilder.AppendLine(LineOfText);
            end;
            RequestJsonString := BlobTextBuilder.ToText();
        end;

        if DBHeader.Get("Config. Code") then
            case DBHeader."Endpoint Type" of
                "SPB DBraider Endpoint Type"::Batch, "SPB DBraider Endpoint Type"::"Per Record":
                    SBPDBraiderInputProcessor.ProcessWriteData(DBHeader.Code, RequestJsonString);
                "SPB DBraider Endpoint Type"::"Delta Read":
                    Error('Delta Read is not supported in this context');
                "SPB DBraider Endpoint Type"::"Read Only":
                    begin
                        if RequestJsonString <> '' then
                            SPBDBraiderDataEngine.SetFilterJson(RequestJsonString);
                        SPBDBraiderDataEngine.GenerateData(DBHeader.Code);
                    end;
            end;
    end;

    var
        DBHeader: Record "SPB DBraider Config. Header";
        SPBDBraiderDataEngine: Codeunit "SPB DBraider Data Engine";
        SBPDBraiderInputProcessor: Codeunit "SPB DBraider Input Processor";
}
