unit uFrmCFG;


interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ComCtrls, uFNT, uPAL, ExtCtrls, uFPG;

type
  TFrmCFG = class(TForm)
    TabControl1: TTabControl;
    gbPaleta: TGroupBox;
    rbFNT2PAL: TRadioButton;
    rbPAL2FNT: TRadioButton;
    sbLoadPAL: TSpeedButton;
    sbViewPAL: TSpeedButton;
    sbAccept: TSpeedButton;
    sbCancel: TSpeedButton;
    odPAL: TOpenDialog;
    Bevel1: TBevel;
    procedure rbPAL2FNTClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure sbAcceptClick(Sender: TObject);
    procedure rbFNT2PALClick(Sender: TObject);
    procedure sbCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbLoadPALClick(Sender: TObject);
    procedure sbViewPALClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   user_palette : boolean;
   palette : PByte;
  end;

var
  FrmCFG: TFrmCFG;

implementation

uses uFrmPalette;

{$R *.lfm}

procedure TFrmCFG.rbPAL2FNTClick(Sender: TObject);
begin
 sbLoadPAL.Enabled := rbPAL2FNT.Checked;
 sbViewPAL.Enabled := user_palette;
end;

procedure TFrmCFG.FormActivate(Sender: TObject);
begin
 rbPAL2FNTClick(Sender);
end;

procedure TFrmCFG.sbAcceptClick(Sender: TObject);
begin
 FrmCFG.ModalResult := mrOK;
end;

procedure TFrmCFG.rbFNT2PALClick(Sender: TObject);
begin
 rbPAL2FNTClick(Sender);
end;

procedure TFrmCFG.sbCancelClick(Sender: TObject);
begin
 ModalResult := mrCancel;
end;

procedure TFrmCFG.FormCreate(Sender: TObject);
begin
 user_palette := false;
end;

procedure TFrmCFG.sbLoadPALClick(Sender: TObject);
begin
 if odPAL.Execute then
  user_palette := load_PAL(palette,odPAL.FileName);

 if user_palette then
 begin
  sbViewPAL.Enabled := user_palette;
  Create_hpal;
 end;
end;

procedure TFrmCFG.sbViewPALClick(Sender: TObject);
begin
 frmPalette.ShowModal;
end;

end.
