codeunit 71033628 "SPB DBraider Event Note Mgt"
{
    SingleInstance = true;
    Access = Internal;

    var
        EventNote: Record "SPBDBraider Event Notification";
        NextLineNo: Integer;

    internal procedure CreateEventNote(DBConfigCode: Code[20]; TableID: Integer; RecID: RecordId; ActionType: Text; DeletedPK: Text)
    begin
        if EventNote.FindLast() then
            NextLineNo := EventNote.LineNo + 1
        else
            NextLineNo := 1;
        EventNote.Init();
        EventNote.Endpoint := DBConfigCode;
        EventNote.TableNo := TableID;
        EventNote.RecordID := RecID;
        EventNote.Action := CopyStr(ActionType, 1, MaxStrLen(EventNote.Action));
        EventNote.DeletedPK := CopyStr(DeletedPK, 1, MaxStrLen(EventNote.DeletedPK));
        EventNote.LineNo := NextLineNo;
        EventNote.Insert(true);
    end;

    internal procedure GetEventNotes(var TempEventNotePass: Record "SPBDBraider Event Notification" temporary)
    begin
        TempEventNotePass.DeleteAll();
        if EventNote.FindSet() then
            repeat
                TempEventNotePass := EventNote;
                TempEventNotePass.Insert();
            until EventNote.Next() = 0;
        EventNote.DeleteAll();
    end;

    internal procedure DeleteEventNotes()
    begin
        EventNote.DeleteAll();
    end;
}