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

unit uLoadImage;

interface

 uses
  LCLIntf, LCLType, SysUtils, Classes,  Graphics ,
  // Inserted by me
   dialogs, IntfGraphics, GraphType, FPimage, Types, uMAPGraphic;


 function loadImageFile( var bmp_dst : TMAPGraphic; filename : string ) : boolean;
 procedure getProportionalSize( var bmp_src : TBitMap; var newWidth, newHeight: integer );

implementation


procedure getProportionalSize( var bmp_src : TBitMap; var newWidth, newHeight: integer );
var
  width, height : integer;
begin

 width  := newWidth;
 height := newHeight;

 if bmp_src <> nil then begin
   if bmp_src.Width > bmp_src.Height then
   begin
    height := (bmp_src.Height * newWidth) div bmp_src.Width;
   end
   else
   begin
    width  := (bmp_src.Width * newHeight) div bmp_src.Height;
   end;
   newWidth:=width;
   newHeight:=height;
 end;
end;

function getBPP(var image :TBitmap) : Integer;
begin
  getBPP:= PIXELFORMAT_BPP[image.PixelFormat];
end;

function getBPP(var picture :TPicture) : Integer;
var
  tmp_pic : TPicture;
begin
 tmp_pic := TPicture.Create;
 tmp_pic.PNG:= TPortableNetworkGraphic.Create;
 if picture.Graphic.MimeType = tmp_pic.Graphic.MimeType then
 begin
   getBPP:=  picture.PNG.RawImage.Description.Depth;
 end else begin
   getBPP:=  picture.Bitmap.RawImage.Description.Depth;
 end;
 tmp_pic.Free;
end;

procedure loadInBitmap(var bitmap: TBitmap;  fileName : String);
var
  AImage: TLazIntfImage;
begin
  // create a TLazIntfImage with 32 bits per pixel, alpha 8bit, red 8 bit, green 8bit, blue 8bit,
  // Bits In Order: bit 0 is pixel 0, Top To Bottom: line 0 is top
  AImage := TLazIntfImage.Create(0,0);
  AImage.DataDescription:=GetDescriptionFromDevice(0);
  try
    // Load an image from disk.
    // It uses the file extension to select the right registered image reader.
    // The AImage will be resized to the width, height of the loaded image.
    AImage.LoadFromFile(fileName);
    Bitmap.LoadFromIntfImage(AImage);
  finally
    AImage.Free;
  end;
end;

procedure copyMaskToBitmap32(var bmp: TBitmap; icon: TIcon);
var
  tmpBMP : TBitmap;
  lazBmp : TLazIntfImage;
  lazMask: TLazIntfImage;
  ico_mask: TBitmap;
  k,j : integer;
  curColor : TFPColor;
  maskPtr : PRGBTriple;
begin
    lazBmp:= bmp.CreateIntfImage;
    tmpBMP := TBitmap.Create;
    tmpBMP.Handle:=icon.MaskHandle;

    ico_mask := TBitmap.Create;
    ico_mask.PixelFormat:=pf24bit;
    ico_mask.SetSize(bmp.width,bmp.height);
    ico_mask.canvas.Draw(0,0,tmpBMP);

    lazMask:= ico_mask.CreateIntfImage;

    for k := 0 to lazBmp.height - 1 do
    begin
       maskPtr:=lazMask.GetDataLineStart(k);
       for j := 0 to lazBmp.width - 1 do
       begin
         curColor:=lazBmp.Colors[j,k];
         curColor.alpha:= (255-maskPtr[j].rgbtBlue) shl 8;
         lazBmp.Colors[j,k]:=curColor;
       end;
    end;

    bmp.LoadFromIntfImage(lazBmp);

    lazBmp.free;
    lazMask.free;

end;

function loadImageFile( var bmp_dst : TMAPGraphic; filename : string ) : boolean;
var
 temp_pic : TPicture;
 bpp_src :integer;
begin
  result := false;
  if AnsiLowerCase(ExtractFileExt(Filename)) = '.map' then
  begin
    bmp_dst.LoadFromFile(Filename);
  end else begin
    temp_pic:= TPicture.Create;
    try
       temp_pic.LoadFromFile(Filename);
    Except
       exit;
    end;
    if temp_pic.Graphic.ClassType = TIcon.ClassType then
    begin
      temp_pic.Icon.Current:= temp_pic.Icon.GetBestIndexForSize(Size(600,600)) ;
      bpp_src:= PIXELFORMAT_BPP[temp_pic.Icon.PixelFormat];
      if bpp_src<32 then begin
         bmp_dst.PixelFormat:=pf32bit;
         bmp_dst.SetSize(temp_pic.Width,temp_pic.Height);
         bmp_dst.Canvas.Draw(0,0,temp_pic.Icon);
         copyMaskToBitmap32(TBitmap(bmp_dst),temp_pic.Icon);
      end else begin
         bmp_dst.LoadFromBitmapHandles(temp_pic.Icon.BitmapHandle,temp_pic.Icon.MaskHandle);
//         bmp_src.LoadFromIntfImage(bmp_src.CreateIntfImage);
      end;

    end
    else begin bmp_dst.Assign(temp_pic.bitmap); end;

    temp_pic.free;
  end;

  // Copiamos imagen
 if ((bmp_dst.Width <> 0) and (bmp_dst.Height <> 0)) then
 begin
  result := true;
 end
end;

end.