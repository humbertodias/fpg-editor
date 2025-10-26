unit uselectcolor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrmSelectColor }

  TfrmSelectColor = class(TForm)
    bCancelar: TButton;
    bAceptar: TButton;
    gbPalette: TGroupBox;
    pBotonera: TPanel;
    PColorReference: TPanel;
    PPaletteReference: TPanel;
    scrlbxPalette: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PColorReferenceClick(Sender: TObject);
  private
    { private declarations }
    PColor: array[0..255] of TPanel;
  public
    { public declarations }
    palette : PByte;
    selectedColor: TColor;
    selectedIndex: Integer;
    procedure setSelected(index :Integer);
    procedure fillPalette;
  end;

var
  frmSelectColor: TfrmSelectColor;

implementation

{$R *.lfm}

{ TfrmSelectColor }

procedure TfrmSelectColor.FormCreate(Sender: TObject);
var
  i,j : Integer;
  tmpPanel : TPanel;
  parentPanel : TPanel;

begin
  selectedIndex:= -1;
  for i:=0 to 7 do
  begin
    parentPanel:= TPanel.Create(Owner);
    parentPanel.Parent:=scrlbxPalette;
    parentPanel.height:=PPaletteReference.height;
    parentPanel.Align:=PPaletteReference.Align;
    parentPanel.BevelOuter:=bvNone;
    for j:=31 downto 0 do
    begin
      tmpPanel:= TPanel.Create(Owner);
      tmpPanel.OnClick:= @PColorReferenceClick;
      tmpPanel.Parent:=parentPanel;
      tmpPanel.BevelOuter:=bvNone;
      tmpPanel.Width:=PColorReference.Width;
      tmpPanel.Align:=PColorReference.Align;
      PColor[i*32+j]:=tmpPanel;
      PColor[i*32+j].Tag:=i*32+j;
    end;
  end;

end;



procedure TfrmSelectColor.fillPalette;
var
  i : Integer;
begin
   for i:=0 to 255 do
   begin
      PColor[i].color:=RGBToColor (palette[i*3],palette[i*3+1],palette[i*3+2]);
   end;
end;

procedure TfrmSelectColor.FormShow(Sender: TObject);
begin

end;

procedure TfrmSelectColor.PColorReferenceClick(Sender: TObject);
begin
  setSelected(TPanel(Sender).Tag);
  selectedColor:=TPanel(Sender).Color;
end;


procedure TfrmSelectColor.setSelected(index :Integer);
var
  i,j : Integer;
begin
   selectedIndex:=index;
   for i:=0 to 255 do
     if PColor[i].tag = index then
       PColor[i].BevelOuter:=bvRaised
     else
      PColor[i].BevelOuter:=bvNone;

end;

end.

