unit ulngConverter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ulngTranslator;

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

resourcestring
  LNG_INI_CONVERTER_REMOVED =
    'El conversor de idiomas .ini ha sido eliminado. Use los archivos .po en languages/.';

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
begin
  ShowMessage(LNG_INI_CONVERTER_REMOVED);
end;

end.
