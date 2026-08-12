unit ufrmprgoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons, uinifile, uTools;

type

  { Tfrmprgoptions }

  Tfrmprgoptions = class(TForm)
    BtnAceptar: TBitBtn;
    BtnCancelar: TBitBtn;
    fneCompilador: TFileNameEdit;
    fneInterprete: TFileNameEdit;
    lblCompilador: TLabel;
    lblInterprete: TLabel;
    Panel1: TPanel;
    procedure BtnAceptarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    procedure LoadFromIni;
  public
    { public declarations }
  end;

var
  frmprgoptions: Tfrmprgoptions;

implementation

{$R *.lfm}

{ Tfrmprgoptions }

procedure Tfrmprgoptions.LoadFromIni;
begin
  fneCompilador.FileName := ResolveBennuTool(inifile_prg_compiler);
  fneInterprete.FileName := ResolveBennuTool(inifile_prg_interpreter);
end;

procedure Tfrmprgoptions.FormShow(Sender: TObject);
begin
  LoadFromIni;
end;

procedure Tfrmprgoptions.BtnAceptarClick(Sender: TObject);
begin
  inifile_prg_compiler := Trim(fneCompilador.FileName);
  inifile_prg_interpreter := Trim(fneInterprete.FileName);
  if inifile_prg_compiler = '' then
    inifile_prg_compiler := 'bgdc';
  if inifile_prg_interpreter = '' then
    inifile_prg_interpreter := 'bgdi';
  write_inifile;
  Close;
end;

procedure Tfrmprgoptions.BtnCancelarClick(Sender: TObject);
begin
  LoadFromIni;
  Close;
end;

end.
