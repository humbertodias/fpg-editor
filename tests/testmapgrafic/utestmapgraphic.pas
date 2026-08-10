unit utestmapgraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, uMAPGraphic;

type

  { TfrmMAPGraphic }

  TfrmMAPGraphic = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    lbpp1: TLabel;
    lcdiv: TLabel;
    lbpp: TLabel;
    lcdiv1: TLabel;
    lcode1: TLabel;
    lname1: TLabel;
    lcode: TLabel;
    lncpoints: TLabel;
    lHeight: TLabel;
    lHeight1: TLabel;
    lncpoints1: TLabel;
    lname: TLabel;
    lWidth: TLabel;
    lWidth1: TLabel;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMAPGraphic: TfrmMAPGraphic;

implementation

{$R *.lfm}

{ TfrmMAPGraphic }

procedure TfrmMAPGraphic.Button1Click(Sender: TObject);
var
  mybmp: TMAPGraphic;
begin
  mybmp := TMAPGraphic.Create;
  mybmp.LoadFromFile(Edit1.Text);
  Image1.Picture.Bitmap.Assign(mybmp);
  //Image1.Picture.Bitmap.SetSize(mybmp.Width,mybmp.Height);
  //Image1.Picture.Bitmap.Canvas.Draw(0,0,mybmp);
  Image1.Picture.LoadFromFile('024.map');
  lWidth1.caption:=inttostr(mybmp.Width);
  lHeight1.caption:=inttostr(mybmp.Height);
  lbpp1.caption:=inttostr(mybmp.bitsPerPixel);
  lncpoints1.caption:=inttostr(mybmp.CPointsCount);
  lname1.Caption:=mybmp.Name;
  lcode1.Caption:=inttoStr(mybmp.Code);
  if mybmp.CDIVFormat then
     lcdiv1.Caption:='True'
  else
     lcdiv1.Caption:='False';
  mybmp.free;
end;

procedure TfrmMAPGraphic.Button2Click(Sender: TObject);
begin
  image1.Picture.SaveToFile(Edit1.Text);
end;

procedure TfrmMAPGraphic.FormCreate(Sender: TObject);
begin
  TPicture.RegisterFileFormat('map','DIV MAPs',TMAPGraphic);
end;

end.


