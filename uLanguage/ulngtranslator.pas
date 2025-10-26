unit ulngTranslator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, ActnList;

type

  { TfrmLangTranslator }

  TfrmLangTranslator = class(TForm)
    aabrir: TAction;
    aguardar: TAction;
    aunir: TAction;
    acopiar: TAction;
    apegar: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    procedure aabrirExecute(Sender: TObject);
    procedure aguardarExecute(Sender: TObject);
    procedure aunirExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmLangTranslator: TfrmLangTranslator;

resourcestring
  LNG_MESSAGE_HELP_TRANSLATOR = 'Abre el archivo .po a traducir.\nCopia el cotenido al portapapeles.\n'+
  'Pégalo en tu traductor favorito y tradúcelo.\nCopia el texto traducido y pégalo en el cuadro de abajo.\n'+
  'Pulsa Unir.\nEscribe las dos siglas del idioma destino.\nFinalmente guarda el archivo.';
  LNG_MESSAGE_CORRECT_JOIN = 'Archivo Juntado Correctamente';
  LNG_MESSAGE_SAVED = 'Archivo Guardado Correctamente';

implementation

{$R *.lfm}

{ TfrmLangTranslator }


procedure TfrmLangTranslator.Button1Click(Sender: TObject);
begin
  ShowMessage(LNG_MESSAGE_HELP_TRANSLATOR);
end;

procedure TfrmLangTranslator.Button2Click(Sender: TObject);
begin
  aunir.Execute;
end;

procedure TfrmLangTranslator.Button3Click(Sender: TObject);
begin
  aguardar.Execute;
end;

procedure TfrmLangTranslator.FormCreate(Sender: TObject);
begin
  memo1.Lines.LoadFromFile('languages'+DirectorySeparator+'fpg-editor.po');
end;

procedure TfrmLangTranslator.Memo1Change(Sender: TObject);
begin

end;

procedure TfrmLangTranslator.MenuItem4Click(Sender: TObject);
begin
   Close;
end;


procedure TfrmLangTranslator.aabrirExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
     Memo1.Lines.LoadFromFile(OpenDialog1.FileName);

end;

procedure TfrmLangTranslator.aguardarExecute(Sender: TObject);
var
  filename : String;
begin
  //'languages'+DirectorySeparator+
  filename := 'fpg-editor.' + Edit1.Text + '.po';
  SaveDialog1.FileName:=filename;
  if SaveDialog1.Execute then
  begin
     Memo1.Lines.SaveToFile(SaveDialog1.FileName);
     ShowMessage(LNG_MESSAGE_SAVED);
  end;

end;

procedure TfrmLangTranslator.aunirExecute(Sender: TObject);
var
   j : Integer;
   tmpline :string;

begin
  memo1.Enabled:=false;
  memo2.Enabled:=false;
  for j := memo1.Lines.Count-1 downto 0 do
  begin
    tmpline := memo1.Lines.Strings[j];
    if AnsiPos(tmpline,'msgid "') > -1 then
    begin
      if  memo2.Lines.Strings[j+1] = 'msgstr ""' then
       memo1.Lines.Strings[j+1]:=memo2.Lines.Strings[j];
    end;
  end;
  ShowMessage(LNG_MESSAGE_CORRECT_JOIN);
  memo1.Enabled:=true;
  memo2.Enabled:=true;
end;

// ISO 639-1 	pt
// http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

end.

