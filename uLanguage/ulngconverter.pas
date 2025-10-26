unit ulngConverter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, IniFiles, ulngTranslator;

type

  { TfrmLanguageConverter }

  TfrmLanguageConverter = class(TForm)
    bconvertir: TButton;
    bCerrar: TButton;
    eficheroAntiguo: TEdit;
    eficheroNuevo: TEdit;
    lblFicheroAntiguo: TLabel;
    lblFicheroNuevo: TLabel;
    OpenDialogFN: TOpenDialog;
    OpenDialogFA: TOpenDialog;
    sbFicheroAntiguo: TSpeedButton;
    sbFicheroNuevo: TSpeedButton;
    procedure bCerrarClick(Sender: TObject);
    procedure bconvertirClick(Sender: TObject);
    procedure bTraducirClick(Sender: TObject);
    procedure sbFicheroAntiguoClick(Sender: TObject);
    procedure sbFicheroNuevoClick(Sender: TObject);
    procedure convertLanguage;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmLanguageConverter: TfrmLanguageConverter;

const
 NUM_OF_STRINGS                 = 200;

resourcestring
  LNG_FILE_NO_EXIST = 'No existe el fichero:';
  LNG_FILE_REFERENCE_NO_EXIST = 'No existe el fichero de referencia:';
  LNG_CORRECT = 'Fichero creado correctamente';

implementation

{$R *.lfm}

{ TfrmLanguageConverter }

procedure TfrmLanguageConverter.sbFicheroAntiguoClick(Sender: TObject);
begin
  if OpenDialogFA.Execute then
     eficheroAntiguo.Text:=OpenDialogFA.FileName;
end;

procedure TfrmLanguageConverter.bconvertirClick(Sender: TObject);
begin
  convertLanguage;
end;

procedure TfrmLanguageConverter.bTraducirClick(Sender: TObject);
begin
  frmLangTranslator.Show;
end;

procedure TfrmLanguageConverter.bCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLanguageConverter.sbFicheroNuevoClick(Sender: TObject);
begin
    if OpenDialogFN.Execute then
     eficheroNuevo.Text:=OpenDialogFN.FileName;

end;

procedure TfrmLanguageConverter.convertLanguage;
var
 lngfileReference : TIniFile;
 lngfileOld : TIniFile;
 lngfileNew : TStringList;
 i,j : integer;
 tmpLine : String;
 tmpSentence : String;
 tmpSentenceRef : String;
 lineIndex: Integer;
 FilenameReference : String;
begin
 // Si no existe el fichero cambia al lenguaje por defecto
 if not FileExistsUTF8(eficheroAntiguo.Text) { *Converted from FileExists*  } then
 begin
   ShowMessage(LNG_FILE_NO_EXIST+' '+eficheroAntiguo.Text);
   exit;
 end;
 if not FileExistsUTF8(eficheroNuevo.Text) { *Converted from FileExists*  } then
 begin
   ShowMessage(LNG_FILE_NO_EXIST+' '+eficheroNuevo.Text);
   exit;
 end;
 FilenameReference:= 'lng'+DirectorySeparator+'Spanish.ini';
 if not FileExistsUTF8(FilenameReference) { *Converted from FileExists*  } then
 begin
   ShowMessage(LNG_FILE_REFERENCE_NO_EXIST+' '+FilenameReference);
   exit;
 end;

 lngfileReference := TIniFile.Create(FilenameReference);
 lngfileOld := TIniFile.Create(eficheroAntiguo.Text);

 lngfileNew := TStringList.Create;
 lngfileNew.LoadFromFile(eficheroNuevo.Text);

 //LNG_DESCRIPTION := lngfileOld.ReadString('LNG', 'Description', 'NULL');
 //LNG_INF := lngfileOld.ReadString('LNG', 'INFO', 'NULL');

 for i := 0 to NUM_OF_STRINGS - 1 do
 begin
  tmpSentenceRef := lngfileReference.ReadString('LNG', IntToStr(i), 'NULL');
  tmpLine := 'msgid "'+tmpSentenceRef+'"';
  lineIndex := -1;
  for j := 0 to lngfileNew.Count-1 do
  begin
    if tmpline = lngfileNew.Strings[j] then
    begin
       lineIndex := j;
       break;
    end;
  end;
  if lineIndex > -1 then
  begin
     tmpSentenceRef := lngfileOld.ReadString('LNG', IntToStr(i), 'NULL');
     lngfileNew.Strings[lineIndex+1] := 'msgstr "'+tmpSentenceRef+'"';
  end
 end;
 lngfileNew.SaveToFile(eficheroNuevo.Text);
 lngfileNew.Free;
 lngfileReference.Free;
 lngfileOld.Free;
 ShowMessage(LNG_CORRECT);

end;



end.

