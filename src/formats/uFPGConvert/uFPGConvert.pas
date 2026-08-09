(*
 *  FPG Editor : Edit FPG file from DIV2, FENIX and CDIV
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

unit uFPGConvert;


interface

uses LCLIntf, LCLType, ComCtrls, Graphics, Controls, SysUtils, Classes,
     ClipBrd, Forms,
     uFPG, uIniFile, uLanguage,
     uSort, uColor16bits, uFPGListView, IntfGraphics, Dialogs ;
     // uFrmPalette
const
 GMask = 63;

type
 two_bytes = record
  byte0, byte1 : byte;
 end;

var
 Table_FPG_Convert : array [0 .. 31, 0 .. 63, 0 .. 31] of LongWord;
 New_type          : Integer;

 procedure Convert_to_FPG1( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG8_DIV2( var lvFPG: TFPGListView;  var gFPG: TProgressBar);

 procedure Convert_to_FPG16_common( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG16_CDIV( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG16_FENIX( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG24( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
 procedure Convert_to_FPG32( var lvFPG: TFPGListView;  var gFPG: TProgressBar);

 procedure Init_Table_FPG_Convert;

resourcestring
  LNG_LOSTCOLORS = 'perdidos';
  LNG_SAVEDCOLORS = 'colores';

implementation

 procedure Init_Table_FPG_Convert;
 var
  r, g, b : byte;
 begin
  for r := 0 to 31 do
   for g := 0 to 63 do
    for b := 0 to 31 do
     Table_FPG_Convert[r, g, b] := 0;
 end;

procedure Convert_to_FPG8_DIV2( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count,
 byte0, byte1  : Word;
 R16, G16, B16 : Byte;
 i, j : Integer;
 sort_pixels : TList;
 sort_pixel  : Table_Sort;
 table_pixel  : array [0..65535] of Table_Sort;
 total_pixels, convert_pixels : LongWord;

 rgbLine : PRGBAQuad;

  lazBMP: TLazIntfImage;
  colorsSaved: Integer;
  colorsLost: Integer;

begin
 New_type := FPG8_DIV2;

 //Convert_to_FPG16_common(ilFPG, lvFPG, frmMain, gFPG );

 Init_Table_FPG_Convert;

 total_pixels   := 0;
 convert_pixels := 0;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count do
 begin
  with lvFPG.Fpg.images[count] do
  begin
   lazBMP:=CreateIntfImage;

   for j := 0 to height - 1 do
   begin
    rgbLine := lazBMP.GetDataLineStart(j);

    for i := 0 to width - 1 do
     begin
      R16 := rgbLine[i].Red shr 3;
      G16 := rgbLine[i].Green shr 2;
      B16 := rgbLine[i].Blue shr 3;

      Table_FPG_Convert[R16, G16, B16] := Table_FPG_Convert[R16, G16, B16] + 1;
     end;
   end;

   total_pixels := total_pixels + (width * height);

   //LoadFromIntfImage(lazBMP);
   lazBMP.free;

  end;

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;

 end;

 sort_pixels := TList.Create;

 // Ordenamos los resultados del analisis
 for count := 0 to 65535 do
 begin
  //Carga los datos
  byte0 := count shr 8;
  byte1 := count - (byte0 shl 8);

  //Extrae el RGB de 16bits
  Calculate_RGB16(byte0, byte1, R16, G16, B16);

  table_pixel[count].nSort := Table_FPG_Convert[R16, G16, B16];
  table_pixel[count].nLink := count;

  sort_pixels.Add(@table_pixel[count]);
 end;

 sort_pixels.Sort(@SortCompare);

 gFPG.Hide;

 // Establecemos la paleta de colores
 i := 65535;
 count := 1;

 FillChar(lvFPG.Fpg.palette,767,0); // todo a 0, por tanto primer color es negro


 while count < 256 do
 begin
  sort_pixel := Table_sort(sort_pixels.Items[i]^);
  i:=i -1; // para la siguiente iteración

  convert_pixels := convert_pixels + sort_pixel.nSort;
  // Se use al menos una vez
  if sort_pixel.nSort <> 0 then
  begin
   // y sea distinto del negro absoluto (que está en primera posicion ya)
   if sort_pixel.nLink <> 0 then
   begin
      // Carga los datos
     byte0 := sort_pixel.nLink shr 8;
     byte1 := sort_pixel.nLink - (byte0 shl 8);

     // Extrae el RGB de 16bits ya convertido en 0-255 valores
     Calculate_RGB(byte0, byte1, R16, G16, B16);
     lvFPG.Fpg.palette[  count * 3      ] := R16;
     lvFPG.Fpg.palette[ (count * 3) + 1 ] := G16;
     lvFPG.Fpg.palette[ (count * 3) + 2 ] := B16;
     count := count + 1;  // para el siguiente color a añadir a la paleta
   end;
  end else
     break; // como están ordenados si es 0 los demás que le siguen tambien, por tanto no hay mas colores
 end;

 colorsSaved := count;
 colorsLost:=0;
 while i> -1 do
 begin
   sort_pixel := Table_sort(sort_pixels.Items[i]^);
   i:=i -1; // para la siguiente iteración
   // Se use al menos una vez
   if sort_pixel.nSort <> 0 then
   begin
      colorsLost:= colorsLost+1;
   end else
      break;
 end;


 //frmPalette.fpg:= lvfpg.Fpg;
 //frmPalette.ShowModal;


 // Ordenamos los colores de la paleta
  lvFPG.Fpg.Sort_Palette;

 //FPG_Create_hpal;

 lvFPG.Fpg.FileFormat             := FPG8_DIV2;
 lvFPG.Fpg.Magic := 'fpg';
 //lvFPG.Fpg.loadpalette     := true;
 lvFPG.Fpg.update := true;

 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 //lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 //lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 // Creamos la tabla de conversión
 // lvFPG.Fpg.Create_table_16_to_8;
 for count:= 1 to lvFPG.Fpg.Count do
 begin
  lvFPG.Fpg.images[count].bitsPerPixel:=lvFPG.Fpg.getBPP;
  lvFPG.Fpg.images[count].bPalette:=lvFPG.Fpg.palette;
(*
  for i:= 0 to 255 do
  begin
   R16 := lvFPG.Fpg.images[count].bPalette[  i * 3      ];
   G16 := lvFPG.Fpg.images[count].bPalette[  i * 3     +1 ];
   B16 := lvFPG.Fpg.images[count].bPalette[  i * 3      +2];
   if R16+G16+B16 <> 0 then
      ShowMessage(inttostr(r16)+' '+inttostr(g16)+' '+inttostr(b16));
  end;
*)

  lvFPG.Fpg.images[count].simulate8bppIn32bpp;

  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;

 //total_pixels := total_pixels div 100;

 // Si la precisión sobrepasa el 100%
 if ( convert_pixels > total_pixels   ) then
 begin
  total_pixels := convert_pixels;
 end;

 lvFPG.Fpg.setDefaultGamut;

 MessageDlg( LNG_INFO, LNG_PALETTE_PRECISION + ' [ '
            + IntToStr( ( convert_pixels * 100) div total_pixels ) + '% ] ('+inttostr(colorsSaved)+' '+LNG_SAVEDCOLORS+'/'+inttostr(colorsLost)+' '+LNG_LOSTCOLORS+')',
            mtInformation,[mbOk],0);
end;

procedure Convert_to_FPG16_common( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count   : LongInt;
begin
 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count  do
 begin

  lvFPG.Fpg.images[count].bitsPerPixel:=16;

  if lvFPG.Fpg.FileFormat = FPG16_CDIV then
  begin
    lvFPG.Fpg.images[count].CDIVFormat:=true;
    lvFPG.Fpg.images[count].colorToTransparent(clPurple,true);
  end
  else begin
    lvFPG.Fpg.images[count].CDIVFormat:=false;
    lvFPG.Fpg.images[count].colorToTransparent(clBlack,true);
  end;

  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;


procedure Convert_to_FPG16_FENIX( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG16;
 // Actualizamos los datos del FPG
 lvFPG.Fpg.FileFormat             := FPG16;
 lvFPG.Fpg.Magic := 'f16';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;

 Convert_to_FPG16_common( lvFPG, gFPG);

end;

procedure Convert_to_FPG16_CDIV( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG16_CDIV;
 // Actualizamos los datos del FPG
 lvFPG.Fpg.FileFormat             := FPG16_CDIV;
 lvFPG.Fpg.Magic := 'c16';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;

 Convert_to_FPG16_common( lvFPG, gFPG);

end;

procedure Convert_to_FPG24( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count   : LongInt;
begin
 New_type := FPG24;

 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

 // Actualizamos los datos del FPG
 lvFPG.Fpg.FileFormat             := FPG24;
 lvFPG.Fpg.Magic := 'f24';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count  do
 begin
  lvFPG.Fpg.images[count].bitsPerPixel:=24;
  lvFPG.Fpg.images[count].colorToTransparent(clBlack);
  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;

end;

procedure Convert_to_FPG32( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
begin
 New_type := FPG32;

 // Actualizamos los datos del FPG
 lvFPG.Fpg.FileFormat             := FPG32;
 lvFPG.Fpg.Magic := 'f32';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;
end;

procedure Convert_to_FPG1( var lvFPG: TFPGListView;  var gFPG: TProgressBar);
var
 count   : LongInt;

begin
 New_type := FPG1;


 lvFPG.LargeImages.Clear;
 lvFPG.Items.Clear;

 lvFPG.LargeImages.Width  := inifile_sizeof_icon;
 lvFPG.LargeImages.Height := inifile_sizeof_icon;

  // Actualizamos los datos del FPG
 lvFPG.Fpg.FileFormat             := FPG1;
 lvFPG.Fpg.Magic := 'f01';
 lvFPG.Fpg.loadPalette     := false;
 lvFPG.Fpg.update := true;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for count:= 1 to lvFPG.Fpg.Count do
 begin
  lvFPG.Fpg.images[count].bitsPerPixel:=1;
  lvFPG.Fpg.images[count].simulate1bppIn32bpp;
  lvFPG.add_items( count);

  gFPG.Position:= (count * 100) div (lvFPG.Fpg.Count );
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;


end.