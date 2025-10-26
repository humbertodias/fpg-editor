(*
 *  FPG EDIT : Edit FPG file from DIV2, FENIX and CDIV 
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software 
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 *)

unit ufrmAnimate;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, uFPG,
  ExtCtrls, Spin, StdCtrls, uLanguage, uIniFile;

const
 sFPG = 0;
 sIMG = 1;

type

  { TfrmAnimate }

  TfrmAnimate = class(TForm)
    cbStretch: TCheckBox;
    cbProportional: TCheckBox;
    Image1: TImage;
    Panel1: TPanel;
    seMilliseconds: TSpinEdit;
    tAnimate: TTimer;
    procedure cbProportionalChange(Sender: TObject);
    procedure cbStretchChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure seMillisecondsChange(Sender: TObject);
    procedure tAnimateTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

    _lng_str : string;

    procedure _set_lng;
  public
    { Public declarations }
    fpg_animate : Array [1 .. 999] of boolean;
    img_animate : Array [1 .. 99 ] of TBitmap;
    num_of_images : integer;
    source : integer;
    i : integer;
    fpg : TFpg;
    procedure Draw_Image;
  end;

var
  frmAnimate: TfrmAnimate;

implementation

{$R *.lfm}

procedure TfrmAnimate._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;


end;

procedure TfrmAnimate.Draw_Image;
begin
 case source of
  sFPG :
  begin
   while (true) do
   begin
    i := i + 1;

    if fpg_animate[i] then
    begin
     Image1.Picture.Bitmap.Assign(Fpg.images[i]);
     break;
    end;

    if i = 999 then i := 0;
   end;

  end;
  sImg:
  begin
    i := i + 1;
    Image1.Picture.Bitmap.Assign(IMG_animate[i]);
    if i = num_of_images then i := 0;
  end;
 end;
end;


procedure TfrmAnimate.tAnimateTimer(Sender: TObject);
begin
 Draw_Image;
end;

procedure TfrmAnimate.FormShow(Sender: TObject);
begin
  _set_lng;
 i := 0;
 tAnimate.Enabled := true;
 seMilliseconds.Value:=tAnimate.Interval;

end;

procedure TfrmAnimate.seMillisecondsChange(Sender: TObject);
begin
   tAnimate.Enabled:=false;
   tAnimate.Interval:=seMilliseconds.Value;
   tAnimate.Enabled:=true;
end;

procedure TfrmAnimate.FormHide(Sender: TObject);
begin
   i := 0;
 tAnimate.Enabled := false;

 num_of_images := 0;
 Hide;
 ModalResult := mrOK;

end;

procedure TfrmAnimate.cbStretchChange(Sender: TObject);
begin
  Image1.Stretch:=cbStretch.Checked;
end;

procedure TfrmAnimate.cbProportionalChange(Sender: TObject);
begin
  image1.Proportional:=cbProportional.Checked;
end;

procedure TfrmAnimate.FormCreate(Sender: TObject);
begin
 source := sFPG;
end;

end.