unit ufrmprgeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynMemo, SynHighlighterCpp, Forms,
  Controls, Graphics, Dialogs, Menus, ActnList, ComCtrls, StdActns, StdCtrls,
  ExtCtrls, usynprghl, uTools, ufrmprgoptions, LConvEncoding,strutils
  ;



type

  { TfrmPRGEditor }

  TfrmPRGEditor = class(TForm)
    aCompile: TAction;
    aOptions: TAction;
    aExit: TAction;
    aExecute: TAction;
    aSave: TAction;
    ActionList: TActionList;
    cbCharset: TComboBox;
    cbConvert: TComboBox;
    EditCopy1: TEditCopy;
    EditCut1: TEditCut;
    EditDelete1: TEditDelete;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    lblCharset: TLabel;
    lblConvert: TLabel;
    ListBox1: TListBox;
    MainMenu: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    SearchFind1: TSearchFind;
    SearchFindFirst1: TSearchFindFirst;
    SearchFindNext1: TSearchFindNext;
    SearchReplace1: TSearchReplace;
    Splitter1: TSplitter;
    SynMemo1: TSynMemo;
    SynPrgHl1 :TSynPrgHl;
    procedure aCompileExecute(Sender: TObject);
    procedure aExecuteExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aOptionsExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure cbCharsetChange(Sender: TObject);
    procedure cbConvertChange(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TFindDialogFind(Sender: TObject);
    procedure TReplaceDialogFind(Sender: TObject);
    procedure TReplaceDialogReplace(Sender: TObject);
  private
    { private declarations }
    lastEncoding : String;
  public
    { public declarations }
    found : boolean;
  end;

var
  frmPRGEditor: TfrmPRGEditor;

resourcestring
  LNG_PRG_EDITOR ='Editor de Archivos de Programa';

implementation

{$R *.lfm}

{ TfrmPRGEditor }

procedure TfrmPRGEditor.FileOpen1Accept(Sender: TObject);
begin
  SynMemo1.Lines.LoadFromFile(FileOpen1.Dialog.FileName);
  SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.Text,cbCharset.Text, 'utf8');;

  Caption:=LNG_PRG_EDITOR + ' - ' + ExtractFileNameOnly(  FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.FileSaveAs1Accept(Sender: TObject);
begin
  SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.text, 'utf8',cbCharset.Text);;
  SynMemo1.Lines.SaveToFile(FileSaveAs1.Dialog.FileName);

  FileOpen1.Dialog.FileName:=FileSaveAs1.Dialog.FileName;
  Caption:=LNG_PRG_EDITOR + ' - ' + ExtractFileNameOnly(  FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.FormCreate(Sender: TObject);
begin
  Caption:=LNG_PRG_EDITOR;
  SynPrgHl1:= TSynPrgHl.Create(Owner);
  SynMemo1.Highlighter:=SynPrgHl1;
  lastEncoding:=cbCharset.Text;
end;

procedure TfrmPRGEditor.FormDestroy(Sender: TObject);
begin

end;


procedure setSelLength(var textComponent:TSynMemo; newValue:integer);
begin
     textComponent.SelEnd:=textComponent.SelStart+newValue ;
end;

procedure TfrmPRGEditor.TFindDialogFind(Sender: TObject);
var
  FindS,sourceStr: String;
  IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
  Res : integer;
  findDialog1 : TFindDialog;
  tmpMemo : TSynMemo;
  fpos : integer;
  (*Added backward search, loop search, and search from the curren position by DCelso*)
begin
  findDialog1:= TFindDialog(Sender);
  tmpMemo := SynMemo1;
  FLen := Length(findDialog1.FindText);
  SLen := Length(tmpMemo.Text);


  // INI DCelso
  if frDown in findDialog1.Options then
  begin
    FPOS := tmpMemo.SelEnd;
    SourceStr:=Copy(tmpMemo.Text,FPos+1,SLen-FPos);
    FindS := findDialog1.FindText;
  end
  else
  begin
    FPOS := tmpMemo.SelStart;
    SourceStr:=ReverseString(Copy(tmpMemo.Text,1,FPos-1));
    FindS := ReverseString(findDialog1.FindText);
  end;
  // END DCelso

 //following 'if' added by mike
  if frMatchcase in findDialog1.Options then
     IPos := Pos(FindS, SourceStr)
  else
     IPos := Pos(AnsiUpperCase(FindS),AnsiUpperCase(SourceStr));

  If IPos > 0 then begin
   if frDown in findDialog1.Options then     // DCelso
      FPos := FPos + IPos
   else
      FPos := FPos - IPos - FLen +1;
 //   Hoved.BringToFront;       {Edit control must have focus in }
//    tmpMemo.SetFocus;
//    Self.ActiveControl := tmpMemo;
    tmpMemo.SelStart:= FPos;  // -1;   mike   {Select the string found by POS}
    setSelLength(tmpMemo, FLen);     //tmpMemo.SelLength := FLen;
   if frDown in findDialog1.Options then     // DCelso
       FPos:=FPos+FLen-1   //mike - move just past end of found item
   else
      FPos:=FPos-FLen+1   // move just past end of found item in reverestring

  end
  Else
  begin
    // DCelso
    if (MessageDlg('Find','Text was not found! Continue from the begginin?'
           , mtInformation ,  [mbYes,mbNo],0)) = mrYes then
    begin
      if frDown in findDialog1.Options then
      begin
          tmpMemo.SelStart:=0;
          tmpMemo.SelEnd:=0;
      end
      else
      begin
        tmpMemo.SelStart:= SLen;
        tmpMemo.SelEnd:= SLen;
      end;
      TFindDialogFind(Sender);
    end;
  end;             //   - also do it before exec of dialog.

end;


procedure TfrmPRGEditor.TReplaceDialogFind(Sender: TObject);
var
  FindS: String;
  IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
  Res : integer;
  tmpMemo : TSynMemo;
  ReplaceDialog1 : TFindDialog ;
  FPos : Integer;
begin
  tmpMemo:=SynMemo1;
  ReplaceDialog1:= TFindDialog(Sender);
  {FPos is global}
  FLen := Length(ReplaceDialog1.FindText);
  SLen := Length(tmpMemo.Text);
  FindS := ReplaceDialog1.FindText;

 //following 'if' added by mike
  if frMatchcase in ReplaceDialog1.Options then
     IPos := Pos(FindS, Copy(tmpMemo.Text,FPos+1,SLen-FPos))
  else
     IPos := Pos(AnsiUpperCase(FindS),AnsiUpperCase( Copy(tmpMemo.Text,FPos+1,SLen-FPos)));

  If IPos > 0 then begin
    FPos := FPos + IPos;
 //   Hoved.BringToFront;       {Edit control must have focus in } - what is this? mike
    tmpMemo.SetFocus;
    Self.ActiveControl := tmpMemo;
    tmpMemo.SelStart:= FPos;  // removed -1;   mike   {Select the string found by POS}
    setSelLength(tmpMemo, FLen);     //tmpMemo.SelLength := FLen;
    FPos:=FPos+FLen-1;   //mike - move just past end of found item
  end
  Else
  begin
    If not (ReplaceDialog1.Options*[frReplaceAll] = [frReplaceAll]) then
        Res := MessageDlg('Replace','Text was not found!'
           , mtInformation ,  [mbOK],0);
    FPos := 0;     //mike  nb user might cancel dialog, so setting here is not enough
  end;             //   - also do it before exec of dialog.


end;

procedure TfrmPRGEditor.TReplaceDialogReplace(Sender: TObject);
var
    Res, replaceCount:integer;   //added by mike
    countInfo:string;
    tmpMemo : TSynMemo;
    ReplaceDialog1 : TReplaceDialog ;
 begin
  tmpMemo:=SynMemo1;
  ReplaceDialog1:= TReplaceDialog(Sender);
  If Found = False then       {If no search for string took place}
  begin
    TReplaceDialogFind(Sender); {Search for string, replace if found}
    If Length(tmpMemo.SelText) > 0 then
        tmpMemo.SelText :=  ReplaceDialog1.ReplaceText;
  end
  Else                          {If search ran, replace string}
  begin
    If Length(tmpMemo.SelText) > 0 then
        tmpMemo.SelText := ReplaceDialog1.ReplaceText;
  end;
  Found := False;
  setSelLength(tmpMemo, 0);    //tmpMemo.SelLength := 0;
  {Hvis Erstatt alle...}
  If (ReplaceDialog1.Options*[frReplaceAll] = [frReplaceAll]) then begin
      replaceCount:=0;
      Repeat
        TReplaceDialogFind(Sender); {Search for string, replace if found}
        If Length(tmpMemo.SelText) > 0 then begin
            tmpMemo.SelText := ReplaceDialog1.ReplaceText;
            replaceCount:=replaceCount+1;
        end;                                   //laz, syn
      until Found = False;
      if replaceCount>0 then
         replaceCount:=replaceCount+1;   //the first 1, then loop for rest  - mike
      countInfo:=inttostr(replaceCount)+'  replacements made.';
      Res := MessageDlg('Replace',pchar(countInfo)
           , mtInformation ,  [mbOK],0);

  end;

end;

procedure TfrmPRGEditor.aSaveExecute(Sender: TObject);
begin
  if FileOpen1.Dialog.FileName = '' then
     FileSaveAs1.Execute
  else
     SynMemo1.Lines.SaveToFile(FileOpen1.Dialog.FileName);
end;

procedure TfrmPRGEditor.cbCharsetChange(Sender: TObject);
begin
    SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.Text,'utf8',lastEncoding);
    SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.Text,cbCharset.Text, 'utf8');
    lastEncoding := cbCharset.Text;
end;

procedure TfrmPRGEditor.cbConvertChange(Sender: TObject);
begin
    SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.Text,'utf8',cbConvert.Text);
    SynMemo1.Lines.Text:= ConvertEncoding(SynMemo1.Lines.Text,cbConvert.Text, 'utf8');
    lastEncoding:=cbConvert.Text;
    cbCharset.itemindex:=cbConvert.itemindex;
end;

procedure TfrmPRGEditor.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPRGEditor.aOptionsExecute(Sender: TObject);
begin
  frmprgoptions.show;
end;

procedure TfrmPRGEditor.aCompileExecute(Sender: TObject);
begin
  RunExe(frmprgoptions.fneCompilador.FileName+' '+FileOpen1.Dialog.FileName, ExtractFileDir(FileOpen1.Dialog.FileName), GetTempDir(False)+'output.tmp' );
  ListBox1.Items.LoadFromFile(GetTempDir(False)+'output.tmp');
  ListBox1.visible:=(ListBox1.Items.Count>0);
end;

procedure TfrmPRGEditor.aExecuteExecute(Sender: TObject);
begin
    RunExe(frmprgoptions.fneInterprete.FileName+' '+ExtractFileNameWithoutExt(FileOpen1.Dialog.FileName) , ExtractFileDir(FileOpen1.Dialog.FileName),GetTempDir(False)+'output.tmp' );
    ListBox1.Items.LoadFromFile(GetTempDir(False)+'output.tmp');
    ListBox1.visible:=(ListBox1.Items.Count>0);
end;

end.

