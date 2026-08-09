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

unit uFrmPalette;


interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, uFPG;

type
  TfrmPalette = class(TForm)
    imgPalette: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    fpg : TFpg;
  end;

var
  frmPalette: TfrmPalette;

implementation

{$R *.lfm}

procedure TfrmPalette.FormShow(Sender: TObject);
var
 i, j, k : integer;
 area : TRect;
begin
 j := -1;
 k := -1;

 for i:=0 to 255 do
 begin
  imgPalette.Picture.Bitmap.Canvas.Brush.Color :=
   RGB(FPG.palette[i * 3], FPG.palette[(i * 3) + 1], FPG.palette[(i * 3) + 2]);

  if ((i mod 16) = 0) then
  begin
   j := j + 1;
   k := -1;
  end;

  k := k + 1;

  area.Left   := k * 20;
  area.Top    := j * 20;
  area.Right  := area.Left + 20;
  area.Bottom := area.Top  + 20;

  imgPalette.Picture.Bitmap.Canvas.FillRect(area);
 end;
end;

procedure TfrmPalette.FormCreate(Sender: TObject);
begin
 imgPalette.Picture.Bitmap := TBitmap.Create;
 imgPalette.Picture.Bitmap.Width := 320;
 imgPalette.Picture.Bitmap.Height:= 320;
end;


end.