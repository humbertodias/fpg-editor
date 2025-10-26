unit ufrmprgoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons;

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
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmprgoptions: Tfrmprgoptions;

implementation

{$R *.lfm}

{ Tfrmprgoptions }

procedure Tfrmprgoptions.BtnAceptarClick(Sender: TObject);
begin
  close();
end;

procedure Tfrmprgoptions.BtnCancelarClick(Sender: TObject);
begin
  close();
end;

end.

