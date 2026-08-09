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
 
unit uColor16bits;



interface

uses
 LCLIntf, LCLType;

const
 FPG16_CDIV  = 3;


type
  TRGBTriple = record
   R, G, B : Byte;
  end;
  
  TRGBLine = Array[Word] of TRGBTriple;
  pRGBLine = ^TRGBLine;

 procedure Calculate_BGR( byte0, byte1 : Byte; var red, green, blue : Byte );
 procedure Calculate_RGB( byte0, byte1 : Byte; var red, green, blue : Byte );
 procedure Calculate_RGB16( byte0, byte1 : Byte; var red, green, blue : Byte );
 procedure set_BGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
 procedure set_RGB16( var byte0, byte1 : Byte; red, green, blue : Byte );

 procedure truncate_BGR2416( var rgb: TRGBTriple; FPG_type: LongInt );
 procedure truncate_BGR3216( var Red, Green, Blue : byte ; FPG_type: LongInt );

 function BGR16_RGB16( in2bytes : Word ) : Word;

implementation

// Calcula las componentes RGB almacenadas en 2 bytes como BGR
procedure Calculate_BGR( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 blue := byte0 and $F8; // me quedo 5 bits 11111000
 green := (byte0 shl 5) or ( (byte1 and $E0) shr 3); // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
 red := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes RGB almacenadas en 2 bytes como RGB
procedure Calculate_RGB( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 red := byte0 and $F8; // me quedo 5 bits 11111000
 green := (byte0 shl 5) or ( (byte1 and $E0) shr 3); // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
 blue := byte1 shl 3; // me quedo 5 bits
end;

procedure Calculate_RGB16( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 Calculate_RGB(byte0,byte1,red,green,blue);
 red := red shr 3;
 green := green shr 2;
 blue := blue shr 3;
end;

// Establece las componentes RGB almacenandolas en 2 bytes como BGR
procedure set_BGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 // F8 = 11111000
 // 1C = 00011100
 byte0 := (blue and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (red shr 3);
end;

// Establece las componentes RGB almacenandolas en 2 bytes como RGB
procedure set_RGB16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 // F8 = 11111000
 // 1C = 00011100
 byte0 := (red and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (blue shr 3);
end;

// Establece las componentes RGB almacenandolas en 2 bytes como BGR
procedure truncate_BGR2416( var rgb: TRGBTriple; FPG_type: LongInt );
var
 R, G, B : Byte;
begin
 R := rgb.R;
 G := rgb.G;
 B := rgb.B;

 rgb.R := rgb.R shr 3;
 rgb.G := rgb.G shr 2;
 rgb.B := rgb.B shr 3;

 rgb.R := rgb.R shl 3;
 rgb.G := rgb.G shl 2;
 rgb.B := rgb.B shl 3;

 // Si la conversión va ha procudir un color transparente lo corregimos
 if( (R <> 0) or (G <> 0) or (B <> 0) or (FPG_type = FPG16_CDIV) ) then
  if ( (rgb.R = 0) and (rgb.G = 0) and (rgb.B = 0) ) then
   rgb.G := 4;

 // Si la conversión va ha procudir un color transparente lo corregimos
 if( (R < 255) or (G <> 0) or (B < 255) or (FPG_type <> FPG16_CDIV) ) then
  if ( (rgb.R = 248) and (rgb.G = 0) and (rgb.B = 248) ) then
   rgb.G := 4;
end;


procedure truncate_BGR3216( var Red, Green, Blue : byte ; FPG_type: LongInt );
var
 R, G, B : Byte;
begin
 R := Red;
 G := Green;
 B := Blue;

// Asm: byte value exceeds bounds
// Red := ( Red shr 3 ) shl 3;
// Green := ( Green shr 2) shl 2;
// Blue := ( Blue shr 3) shl 3;
R := Byte((Cardinal(Red) shr 3) shl 3);
G := Byte((Cardinal(Green) shr 2) shl 2);
B := Byte((Cardinal(Blue) shr 3) shl 3);

 // Si la conversión va ha procudir un color transparente lo corregimos
 if( (R <> 0) or (G <> 0) or (B <> 0) or (FPG_type = FPG16_CDIV) ) then
  if ( (Red = 0) and (Green = 0) and (Blue = 0) ) then
   Green := 4;

 // Si la conversión va ha procudir un color transparente lo corregimos
 if( (R < 255) or (G <> 0) or (B < 255) or (FPG_type <> FPG16_CDIV) ) then
  if ( (Red = 248) and (Green = 0) and (Blue = 248) ) then
   Green := 4;
end;


function BGR16_RGB16( in2bytes : Word ) : Word;
var
 byte0, byte1  : Byte;
 R16, G16, B16 : Byte;
begin
 byte1 := in2bytes shr 8;
 byte0 := 255 and in2bytes;

 Calculate_BGR(byte0, byte1, R16, G16, B16);
 set_RGB16(byte0, byte1, R16, G16, B16);

 result := (byte1 shl 8) + byte0;
end;

end.
