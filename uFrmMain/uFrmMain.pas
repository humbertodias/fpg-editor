unit uFrmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ExtCtrls, LCLIntf, StdCtrls ,
  ufrmprgeditor, ufrmfpgeditor, uFrmMainFNT, ufrmZipFenix, uinifile,
  uFrmSplahs, ulngConverter, ulngTranslator, uFrmAbout
  ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    aBennu: TAction;
    aCDiv: TAction;
    aAbout: TAction;
    aDIV2: TAction;
    aFenix: TAction;
    aGemix: TAction;
    alngTranslator: TAction;
    aLngConvert: TAction;
    aZipCompress: TAction;
    afntGen: TAction;
    aFpgNew: TAction;
    aFpgOpen: TAction;
    aPrgOpen: TAction;
    aPrgNew: TAction;
    ActionList1: TActionList;
    Image1: TImage;
    MainMenu1: TMainMenu;
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
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    miLngTranslator: TMenuItem;
    miLngConvert: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    procedure aAboutExecute(Sender: TObject);
    procedure aBennuExecute(Sender: TObject);
    procedure aCDivExecute(Sender: TObject);
    procedure aDIV2Execute(Sender: TObject);
    procedure aFenixExecute(Sender: TObject);
    procedure afntGenExecute(Sender: TObject);
    procedure aFpgNewExecute(Sender: TObject);
    procedure aFpgOpenExecute(Sender: TObject);
    procedure aGemixExecute(Sender: TObject);
    procedure aLngConvertExecute(Sender: TObject);
    procedure alngTranslatorExecute(Sender: TObject);
    procedure aPrgNewExecute(Sender: TObject);
    procedure aPrgOpenExecute(Sender: TObject);
    procedure aZipCompressExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.aPrgNewExecute(Sender: TObject);
begin
  frmPRGEditor.Show;
end;

procedure TfrmMain.aFpgNewExecute(Sender: TObject);
begin
  frmFPGEditor.aNew.Execute;
  frmFPGEditor.Show;
end;

procedure TfrmMain.afntGenExecute(Sender: TObject);
begin
   frmMainFNT.Show;
end;

procedure TfrmMain.aCDivExecute(Sender: TObject);
begin
  OpenURL('http://cdiv.sourceforge.net/');
end;

procedure TfrmMain.aDIV2Execute(Sender: TObject);
begin
  OpenURL('http://www.div-arena.com/');
end;

procedure TfrmMain.aFenixExecute(Sender: TObject);
begin
   OpenURL('http://fenix.divsite.net/');
end;

procedure TfrmMain.aAboutExecute(Sender: TObject);
begin
      frmAbout.showModal;
end;

procedure TfrmMain.aBennuExecute(Sender: TObject);
begin
  OpenURL('http://bennugd.org/');
end;

procedure TfrmMain.aFpgOpenExecute(Sender: TObject);
begin
  frmFPGEditor.aOpen.Execute;
  frmFPGEditor.Show;
end;

procedure TfrmMain.aGemixExecute(Sender: TObject);
begin
     OpenURL('http://www.gemixstudio.com');
end;

procedure TfrmMain.aLngConvertExecute(Sender: TObject);
begin
  frmLanguageConverter.Show;
end;

procedure TfrmMain.alngTranslatorExecute(Sender: TObject);
begin
  frmLangTranslator.Show;
end;

procedure TfrmMain.aPrgOpenExecute(Sender: TObject);
begin
  frmPRGEditor.FileOpen1.Execute;
  frmPRGEditor.Show;
end;

procedure TfrmMain.aZipCompressExecute(Sender: TObject);
begin
  frmZipFenix.Show;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  load_inifile;
  miLngConvert.Visible:= (inifile_admin_tools = 1);
  miLngTranslator.Visible:= (inifile_admin_tools = 1);

end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  // Si se quiere mostrar la pantalla de incio
  if inifile_show_splash then
  begin
   Application.CreateForm(TfrmSplash, frmSplash);
   frmSplash.ShowModal;
   frmSplash.Destroy;
  end;


  // Si no hay un parametro
  if ParamCount <> 1 then
   Exit;

  // Comprobamos si existe o no
  if not FileExistsUTF8(ParamStr(1)) { *Converted from FileExists*  } then
   Exit;

  if (ExtractFileExt(ParamStr(1))='.fpg') or (ExtractFileExt(ParamStr(1))='.fnt') then
  begin
     frmFPGEditor.OpenFPG(ParamStr(1));
     frmFPGEditor.Show;
     Exit;
  end;

  if ExtractFileExt(ParamStr(1))='.prg' then
  begin
     frmPRGEditor.FileOpen1.Dialog.FileName:= ParamStr(1);
     frmPRGEditor.FileOpen1Accept(Sender);
     frmPRGEditor.Show;
  end;


end;

end.
