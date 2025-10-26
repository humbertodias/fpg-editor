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
 
unit uBMP;

interface

uses LCLIntf, LCLType, Forms,  SysUtils, Classes, Dialogs, graphics,
  FileUtil,  ComCtrls;

type

uBMP_header = record
 code : Array [0 .. 1] of char;
 size,
 reserved,
 header_size,
 rest_header,
 width,
 height    : Integer;

 reserved0,
 bits_per_pixel : word;

 reserved1,
 body_size,
 reserved2,
 reserved3 : Integer;

 reserved4 : Array [0 .. 7] of byte;
end;

var
 BMP_header : uBMP_header;
 BMP_palette: Array [0 .. 1023] of byte;

 function  load_BMP_header (str : string): Boolean;
 procedure save_BMP(var bmp : TBitMap; str: string; var frmMain : TForm; var gFPG: TProgressBar );
 
 function is_BMP : Boolean;

implementation

 function load_BMP_header(str : string): boolean;
 var
  f : TFileStream;
 begin
  result := false;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
   Exit;

  f := TFileStream.Create(str, fmOpenRead);

  f.Read(BMP_header.code, 2);
  f.Read(BMP_header.size, 4);
  f.Read(BMP_header.reserved, 4);
  f.Read(BMP_header.header_size, 4);
  f.Read(BMP_header.rest_header, 4);
  f.Read(BMP_header.width, 4);
  f.Read(BMP_header.height, 4);

  f.Read(BMP_header.reserved0, 2);
  f.Read(BMP_header.bits_per_pixel, 2);

  f.Read(BMP_header.reserved1, 4);
  f.Read(BMP_header.body_size, 4);
  f.Read(BMP_header.reserved2, 4);
  f.Read(BMP_header.reserved3, 4);
  f.Read(BMP_header.reserved4, 8);

  f.free;

  result := true;
 end;

 function is_BMP : Boolean;
 begin
  is_BMP := false;

  if (BMP_header.code[0] = 'B') and (BMP_header.code[1] = 'M') and
     (BMP_header.bits_per_pixel = 8) then
   is_BMP := true;
 end;



 procedure save_BMP(var bmp : TBitMap; str: string; var frmMain : TForm; var gFPG: TProgressBar );
 var
  f : TFileStream;
  temp_longint, i, j, size : longint;
  sep       : Byte;
  data      : Array [0 .. 65000] of Byte;
 begin
  sep := bmp.Width mod 4;

  size := (bmp.Width * 3) + sep;

  try
   f := TFileStream.Create(str, fmCreate);
  except
   ShowMessage('SAVE_BMP : Can''t create : '+ str);
   Exit;
  end;

  f.Write('BM', 2);
  temp_longint := (bmp.Width * bmp.Height * 3) + 54 + (bmp.Height * sep);
  f.Write(temp_longint, 4);

  temp_longint := 0;
  f.Write(temp_longint, 4);

  temp_longint := 54;
  f.Write(temp_longint, 4);
  temp_longint := 40;
  f.Write(temp_longint, 4);
  temp_longint := bmp.Width;
  f.Write(temp_longint, 4);
  temp_longint := bmp.Height;
  f.Write(temp_longint, 4);

  temp_longint := 1;
  f.Write(temp_longint, 2);
  temp_longint := 24;
  f.Write(temp_longint, 2);

  temp_longint := 0;
  f.Write(temp_longint, 4);
  temp_longint := 0;
  f.Write(temp_longint, 4);

  temp_longint := 3000;
  f.Write(temp_longint, 4);
  temp_longint := 3000;
  f.Write(temp_longint, 4);
  temp_longint := 0;
  f.Write(temp_longint, 4);
  temp_longint := 0;
  f.Write(temp_longint, 4);

  temp_longint := 0;

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;

  for j := bmp.Height - 1 downto 0 do
  begin
   for i := 0 to bmp.Width - 1 do
    begin
     data[ (i * 3)     ] := GetBValue(bmp.Canvas.Pixels[i, j]);
     data[ (i * 3) + 1 ] := GetGValue(bmp.Canvas.Pixels[i, j]);
     data[ (i * 3) + 2 ] := GetRValue(bmp.Canvas.Pixels[i, j]);
    end;

   for i := bmp.Width * 3 to size do
    data[ i ] := 0;

   f.Write(data, size);

   // Activamos la barra de progresión
   gFPG.Position:= ((bmp.Height - 1 - j) * 100) div (bmp.Height - 1);
   gFPG.Repaint;
  end;
  gFPG.Hide;
  f.free;
 end;

end.