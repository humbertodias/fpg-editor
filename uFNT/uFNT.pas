unit uFNT;

{$mode objfpc}{$H+}

interface

uses LCLIntf, LCLType, SysUtils, classes, graphics, Dialogs,
     IntfGraphics, uIniFile,FileUtil,uMAPGraphic;

type
 // Estructura datos de una letra
 FNT_CHAR_INFO_R = record
   Width  : longint; // Ancho
   Height : longint; // Alto
   Vertical_Offset: longint; // Desplazamiento vertical
   File_Offset : longint; // Desplazamiento en el archivo
 end;

  // Estructura datos de una letra
 FNX_CHAR_INFO_R = record
   Width  : longint; // Ancho
   Height : longint; // Alto
   Width_Offset  : longint; // Ancho
   Height_Offset : longint; // Alto
   Horizontal_Offset: longint; // Desplazamiento vertical
   Vertical_Offset: longint; // Desplazamiento vertical
   file_Offset : longint; // Desplazamiento en el archivo
 end;

  // Estructura cabecera de Tipografía
 FNT_HEADER_R = record
   file_type : array [0 .. 2] of char; {fnt}
   code  : array [0 .. 3] of byte;
   version : byte;    // Versión ,0
   palette : Array [0 .. 767] of byte; // Paleta
   Gamuts: array [0 .. 15] of MAPGamut;
   types   : longint; // Tipos
   char_info: Array [0 .. 255] of FNT_CHAR_INFO_R; // Datos de las letras
 end;
 // Estructura cabecera de Tipografía
 FNX_HEADER_R = record
   file_type : array [0 .. 2] of char; {fnx}
   code  : array [0 .. 3] of byte;
   version : byte;    // Versión 1,8,16,24,32
   palette : Array [0 .. 767] of byte; // Paleta
   Gamuts: array [0 .. 15] of MAPGamut;
   charset   : longint; // Tipos
   char_info: Array [0 .. 255] of FNX_CHAR_INFO_R; // Datos de las letras
 end;

 FNT_CHAR_DATA_R = record
  Bitmap     : TBitMap;
  ischar  : Boolean;
 end;

 FNT_CONTAINER_R = record
  hpal   : HPALETTE;
  header   : FNX_HEADER_R;
  width  : longint;
  height : longint;
  vertical_offset: longint;
  view_height : longint;
  sizeof      : longint;
  char_data : Array [ 0 .. 255] of FNT_CHAR_DATA_R; // Bitmap de la letra
 end;


 function  load_fnt( str : string ) : boolean;
 function  save_fnt( str : string ; bpp : integer ) : boolean;
 function  isFNTLoad( ) : boolean;
 function  Find_Color(index, rc, gc, bc : integer): integer;
 function sizeofheader (): longint;
 procedure unload_fnt;

 procedure Create_hpal;


  procedure set_BGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
  procedure set_RGB16( var byte0, byte1 : Byte; red, green, blue : Byte );
  procedure Calculate_BGR16( byte0, byte1 : Byte; var red, green, blue : Byte );
  function CopyPalette(Source: hPalette): hPalette;
  procedure SetFNTSetup;
  function FNT_Test(str: string): boolean;
  var
   fnt_container : FNT_CONTAINER_R;

implementation

function  isFNTLoad( ) : boolean;
var
 i : integer;
begin

 result := false;

 for i := 0 to 255 do
  if fnt_container.char_data[i].ischar then
  begin
   result := true;
   Exit;
  end;
end;

procedure Create_hpal;
 var
  pal : PLogPalette;
  i   : LongInt;
 begin
  pal := nil;

  try
    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);

    pal^.palVersion    := $300;
    pal^.palNumEntries := 256;

    for i := 0 to 255 do
    begin
     pal^.palPalEntry[i].peRed   := fnt_container.HEADER.palette[(i*3)    ];
     pal^.palPalEntry[i].peGreen := fnt_container.HEADER.palette[(i*3) + 1];
     pal^.palPalEntry[i].peBlue  := fnt_container.HEADER.palette[(i*3) + 2];
     pal^.palPalEntry[i].peFlags := 0;
    end;

    fnt_container.hpal := CreatePalette(pal^);

  finally
    FreeMem(pal);
  end;
 end;

function CopyPalette(Source: hPalette): hPalette;
var
LP: ^TLogPalette;
NumEntries: integer;
begin
Result := 0;
GetMem(LP, Sizeof(TLogPalette) + 256*Sizeof(TPaletteEntry));
try
  with LP^ do
    begin
    palVersion := $300;
    palNumEntries := 256;
    NumEntries := GetPaletteEntries(Source, 0, 256, palPalEntry);
    if NumEntries > 0 then
      begin
      palNumEntries := NumEntries;
      Result := CreatePalette(LP^);
      end;
    end;
finally
  FreeMem(LP, Sizeof(TLogPalette) + 256*Sizeof(TPaletteEntry));
end;
end;


//Comprobamos si es un archivo FNT sin comprimir
function FNT_Test(str: string): boolean;
var
  f: TFileStream;
  header : FNX_HEADER_R;
begin
  Result := False;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(str, fmOpenRead);
  except
    Exit;
  end;

  try
    f.Read(header.file_type, 3);
    f.Read(header.code, 4);
    f.Read(header.version, 1);
  finally
    f.Free;
  end;

  // Ficheros de 8 bit DIV
  if (header.file_type[0] = 'f') and (header.file_type[1] = 'n') and
    (header.file_type[2] = 't') and (header.code[0] = 26) and
    (header.code[1] = 13) and (header.code[2] = 10) and
    (header.code[3] = 0) then
    Result := True;

  // Ficheros Fenix
  if (header.file_type[0] = 'f') and (header.file_type[1] = 'n') and
    (header.file_type[2] = 'x') and (header.code[0] = 26) and
    (header.code[1] = 13) and (header.code[2] = 10) and
    (header.code[3] = 0) then
    Result := True;

end;

function load_fnt( str : string ) : boolean;
var
 f      : TFileStream;
 i, k , j , z, n   : LongInt;
 pSrc   : pByteArray;
 // para 1 bit
 byte_line  : Array [ 0 .. 16383 ] of byte;
 lineBit : byte;
 lenLineBits : integer;
 lazBMP : TLazIntfImage;

begin
  unload_fnt;
  result  := false;

  f := TFileStream.Create(str, fmOpenRead);

  try
   f.Read(fnt_container.HEADER.file_type, 3);
   f.Read(fnt_container.HEADER.code , 4);
   f.Read(fnt_container.HEADER.version  , 1);

   if (fnt_container.HEADER.file_type[2] = 't') or ( fnt_container.HEADER.version = 8 ) then begin
     f.Read(fnt_container.HEADER.palette  , 768);
     f.Read(fnt_container.HEADER.gamuts    , 576);
     // pasamos a 8 bits por color la paleta
     for i := 0 to 767 do
      fnt_container.HEADER.palette[i] := fnt_container.HEADER.palette[i] shl 2;

   end else begin
       FillByte(fnt_container.HEADER.palette , 768, 0);
       FillByte(fnt_container.HEADER.gamuts , 576, 0);

   end;

   f.Read(fnt_container.HEADER.charset    , 4);

   if fnt_container.HEADER.file_type[2] = 't' then begin
    for i := 0 to 255 do begin
      f.Read(fnt_container.header.char_info[i].width , 4);
      f.Read(fnt_container.header.char_info[i].height , 4);
      f.Read(fnt_container.header.char_info[i].vertical_offset , 4);
      f.Read(fnt_container.header.char_info[i].file_offset , 4);
    end;
   end else
    f.Read(fnt_container.header.char_info , 7168);

  except
   fileclose(f.Handle);
   //f.Free;
   Exit;
  end;

  // Si no es una Tipografía
  if (fnt_container.HEADER.file_type[0] <> 'f') or (fnt_container.HEADER.file_type[1] <> 'n') or
      ((fnt_container.HEADER.file_type[2] <> 't') and (fnt_container.HEADER.file_type[2] <> 'x')) or (fnt_container.HEADER.code [0] <> 26 ) or
     (fnt_container.HEADER.code [1] <> 13 ) or (fnt_container.HEADER.code [2] <> 10 ) or
     (fnt_container.HEADER.code [3] <> 0) then
  begin
   showmessage('El fichero (.FNT) no es un formato valido.');
   fileclose(f.Handle);
   Exit;
  end;

  // Ponemos la versión a 8 bits para FNTs tipo DIV y facilitar hacer cosas comunes a FNX de 8 bits
  if fnt_container.header.file_type[2] = 't' then
          fnt_container.header.version := 8;

  //Create_hpal;

  for i := 0 to 255 do
  begin

    if( (fnt_container.header.char_info[i].file_offset = 0) or
	(fnt_container.header.char_info[i].width  = 0     ) or
	(fnt_container.header.char_info[i].height = 0) ) then continue ;

    with fnt_container.CHAR_DATA[i] do
    begin
      f.seek(fnt_container.header.char_info[i].file_offset, soFromBeginning);

      FreeAndNil(Bitmap);
      Bitmap:= TBitmap.Create;

      Bitmap.PixelFormat := pf32bit;
      Bitmap.Width   := fnt_container.header.char_info[i].Width;
      Bitmap.Height  := fnt_container.header.char_info[i].Height;

      ischar := true;

      // para 1 bit
      lenLineBits:=Bitmap.Width div 8;
      if (Bitmap.Width mod 8) <> 0 then
        lenLineBits:=lenLineBits+1;

      lazBMP:=Bitmap.CreateIntfImage;

      for k := 0 to lazBMP.Height - 1 do
      begin
       pSrc := lazBMP.GetDataLineStart(k);
        case fnt_container.header.version of
          1:
          begin
              for j := 0 to lenLineBits - 1 do
              begin
                f.Read(lineBit, 1);
                for n := 0 to 7 do
                begin
                  z := (j * 8) + n;
                  if z < lazBMP.Width then
                  begin
                    if (lineBit and 128) = 128 then
                    begin
                      pSrc^[z * 4] := 255;
                      pSrc^[(z * 4) + 1] := 255;
                      pSrc^[(z * 4) + 2] := 255;
                      pSrc^[(z * 4) + 3] := 255;
                    end
                    else
                    begin
                      pSrc^[z * 4] := 0;
                      pSrc^[(z * 4) + 1] := 0;
                      pSrc^[(z * 4) + 2] := 0;
                      pSrc^[(z * 4) + 3] := 0;
                    end;
                    lineBit := lineBit shl 1;
                  end
                  else
                    break;
                end;
              end;
          end;
          8:
          begin
            f.Read(byte_line, lazBMP.Width );
            for j:=0 to lazBMP.Width -1  do
            begin
               pSrc^[j*4+3] := 255;
               if  byte_line[j] = 0 then
                   pSrc^[j*4+3] := 0;
               pSrc^[j*4+2] := fnt_container.header.palette[byte_line[j] * 3];
               pSrc^[j*4+1] := fnt_container.header.palette[byte_line[j] * 3 + 1];
               pSrc^[j*4] := fnt_container.header.palette[byte_line[j] * 3 + 2];
            end;
          end;

          16:
          begin
           f.Read(byte_line, lazBMP.Width * 2);
           for j:=0 to lazBMP.Width -1  do
           begin
               Calculate_BGR16(byte_line[j*2+1], byte_line[j*2],
                 pSrc^[j * 4], pSrc^[(j * 4) + 1],
                 pSrc^[(j * 4) + 2]);
               pSrc^[j*4+3] := 255;
               if (byte_line[j*2+1] + byte_line[j*2]) =0 then
                    pSrc^[j*4+3] := 0;
           end;
          end;
          24:
          begin
           f.Read(byte_line, lazBMP.Width * 3);
           for j:=0 to lazBMP.Width -1  do
           begin
               pSrc^[j*4+2] := byte_line[j*3+2];
               pSrc^[j*4+1] := byte_line[j*3+1];
               pSrc^[j*4] := byte_line[j*3];
               pSrc^[j*4+3] := 255;
               if (byte_line[j*3+2] + byte_line[j*3] + byte_line[j*3]) = 0 then
                  pSrc^[j*4+3] := 0
           end;
          end;
          32:
          begin
            f.Read(pSrc^, lazBMP.Width * 4);
          end;
        end; // case
      end;
      Bitmap.LoadFromIntfImage(lazBmp);
      lazBMP.free;
    end;
  end;
  // ¿Espacio en blanco?
  //fnt_container.header.char_info[32].width := fnt_container.width shr 1;

  fileclose(f.Handle);
  //f.Free;
  load_fnt := true;
  SetFNTSetup;
end;

 function decreaseTColor(color : TColor): TColor;
 begin
  Result:= RGB(GetRValue(color) AND $F8,GetGValue(color) AND $FC,GetBValue(color) AND $F8 ) ;
 end;

 function save_fnt( str : string ; bpp : integer) : boolean;
 var
  f : TFileStream;
  i,j, k,h : LongInt;
  pSrc : pByteArray;
  // for 1 bpp
  byteFor1bpp : byte;
  widthForFPG1 : integer;
  insertedBits : integer;

  byte_line  : Array [ 0 .. 16383 ] of byte;
  char_info_fixed: Array [0 .. 255] of FNX_CHAR_INFO_R; // Datos de las letras
  lazBMP : TLazIntfImage;

 begin
  result := false;
  try
   f := TFileStream.Create(str, fmCreate);
  except
   Exit;
  end;

  case bpp of
    0:
      fnt_container.HEADER.version := 1;
    1:
      fnt_container.HEADER.version := 8;
    2:
      fnt_container.HEADER.version := 16;
    3:
      fnt_container.HEADER.version := 24;
    4:
      fnt_container.HEADER.version := 32;
  end;

  // convertimos paleta a 6 bits por color para guardarla
  if fnt_container.HEADER.version = 8 then
  begin
    for i := 0 to 767 do
      fnt_container.HEADER.Palette[i] := fnt_container.HEADER.Palette[i] shr 2;
  end;

  f.Write(fnt_container.HEADER.file_type, 3);
  f.Write(fnt_container.HEADER.code , 4);
  f.Write(fnt_container.HEADER.version  , 1);
  if fnt_container.HEADER.version = 8 then
  begin
    f.Write(fnt_container.HEADER.palette  , 768);
    f.Write(fnt_container.HEADER.gamuts    , 576);
  end;
  f.Write(fnt_container.HEADER.charset    , 4);

  // reconvertimos paleta a 8 bits por color para mostrar los colores en pantalla
  // y usar find_color más adelante
  if fnt_container.HEADER.version = 8 then
  begin
    for i := 0 to 767 do
      fnt_container.HEADER.Palette[i] := fnt_container.HEADER.Palette[i] shl 2;
  end;

  k:=0;
  h:=sizeofheader();
  for i := 0 to 255 do
  begin
    char_info_fixed[i]:=fnt_container.header.char_info[i];
    char_info_fixed[i].Width_Offset:=char_info_fixed[i].Width;
    char_info_fixed[i].Height_Offset:=char_info_fixed[i].Height;
    if ( char_info_fixed[i].width <> 0) then
    begin
     char_info_fixed[i].file_offset:=h;
     if (fnt_container.HEADER.version = 1) then begin
      widthForFPG1:= char_info_fixed[i].width div 8;
      if (char_info_fixed[i].width mod 8) <>0 then
         widthForFPG1:= widthForFPG1 +1;
      h:= h+ (widthForFPG1 * char_info_fixed[i].height);
     end else begin
      h:=h + char_info_fixed[i].width* char_info_fixed[i].height * fnt_container.HEADER.version div 8 ;
     end;
     fnt_container.header.char_info[i]:=char_info_fixed[i];
    end;
  end;

  f.Write(fnt_container.header.char_info , 7168);

  for i := 0 to 255 do begin
   if( fnt_container.char_data[i].ischar ) then
   begin

    lazBMP:= fnt_container.char_data[i].Bitmap.CreateIntfImage;

    for k := 0 to lazBMP.Height - 1 do
    begin
     pSrc := lazBMP.GetDataLineStart(k);
     case fnt_container.HEADER.version of
       1:
        begin
            insertedBits := 0;
            byteFor1bpp := 0;
            for j := 0 to fnt_container.header.char_info[i].Width - 1 do
            begin
             if (pSrc^[j * 4+3] shr 7) = 1 then
              begin
                byteFor1bpp := byteFor1bpp or 1; // bit más alto en 8 bits
              end;
              insertedBits := insertedBits + 1;
              if (insertedBits = 8) then
              begin
                f.Write(byteFor1bpp, 1);
                byteFor1bpp := 0;
                insertedBits := 0;
              end else
                byteFor1bpp := byteFor1bpp shl 1;
            end;
            if insertedBits > 0 then
            begin
              byteFor1bpp:= byteFor1bpp shl (7 - insertedBits);
              f.Write(byteFor1bpp, 1);
            end;
        end;
       8:
       begin
          for j := 0 to fnt_container.header.char_info[i].Width - 1 do
          begin
             byte_line[j]:=Find_Color(0,pSrc^[j * 4+2],pSrc^[j * 4+1],pSrc^[j * 4]);
          end;
          f.Write(byte_line, fnt_container.header.char_info[i].Width );

       end;
       16:
       begin
          for j := 0 to fnt_container.header.char_info[i].width - 1 do begin
            set_BGR16(byte_line[j*2 + 1], byte_line[j*2],pSrc^[j * 4 ],pSrc^[j * 4 + 1],pSrc^[j * 4 +2] );
          end;
          f.Write(byte_line, fnt_container.header.char_info[i].Width * 2 );
       end;
       24:
       begin
          for j := 0 to fnt_container.header.char_info[i].width - 1 do begin
            byte_line[j*3 ]:=pSrc^[j*4 ];
            byte_line[j*3 + 1]:=pSrc^[j*4 + 1];
            byte_line[j*3 + 2]:=pSrc^[j*4 + 2];
          end;
           f.Write(byte_line, fnt_container.header.char_info[i].Width * 3 );
       end;
       32:
       begin
           f.Write(pSrc^, fnt_container.header.char_info[i].Width * 4 );
       end;
     end; //case
    end;
    lazBMP.Free;

   end;
  end;

  fileclose(f.Handle);
  result := true;
 end;

 procedure unload_fnt;
 var
  i : longint;
 begin

  for i := 0 to 255 do
  begin
   fnt_container.char_data[i].ischar := false;
   FreeAndNil (fnt_container.char_data[i].Bitmap);
   fnt_container.header.char_info[i].width := 0;
   fnt_container.header.char_info[i].height := 0;
   fnt_container.header.char_info[i].width_offset := 0;
   fnt_container.header.char_info[i].height_offset := 0;
   fnt_container.header.char_info[i].horizontal_offset := 0;
   fnt_container.header.char_info[i].vertical_offset := 0;
   fnt_container.header.char_info[i].file_offset := 0;
  end;

  fnt_container.header.file_type[0]:='f';
  fnt_container.header.file_type[1]:='n';
  fnt_container.header.file_type[2]:='x';

  fnt_container.header.code[0]:=26;
  fnt_container.header.code[1]:=13;
  fnt_container.header.code[2]:=10;
  fnt_container.header.code[3]:=0;

  FillByte(fnt_container.HEADER.palette , 768, 0);
  FillByte(fnt_container.HEADER.gamuts , 576, 0);
  fnt_container.HEADER.charset:=0;
  fnt_container.HEADER.version:=32;

  fnt_container.width  := 0;
  fnt_container.height := 0;
  fnt_container.vertical_offset:= 0;
  fnt_container.view_height := 0;
  fnt_container.hpal:=0;
  fnt_container.sizeof:=0;
 end;


 function Find_Color(index, rc, gc, bc: integer): integer;
 var
   dif_colors, temp_dif_colors, i: word;
 begin
   dif_colors := 800;
   Result := 0;

   for i := index to 255 do
   begin
     temp_dif_colors :=
       Abs(rc - fnt_container.HEADER.palette[i * 3]) +
       Abs(gc - fnt_container.HEADER.palette[(i * 3) + 1]) +
       Abs(bc - fnt_container.HEADER.palette[(i * 3) + 2]);

     if temp_dif_colors <= dif_colors then
     begin
       Result := i;
       dif_colors := temp_dif_colors;

       if dif_colors = 0 then
         Exit;
     end;

   end;

 end;


procedure Calculate_BGR16( byte0, byte1 : Byte; var red, green, blue : Byte );
begin
 blue := byte0 and $F8; // me quedo 5 bits 11111000
 green := (byte0 shl 5) or ( (byte1 and $E0) shr 3); // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
 red := byte1 shl 3; // me quedo 5 bits
end;

procedure set_BGR16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 byte0 := (blue and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (red shr 3);
end;

procedure set_RGB16( var byte0, byte1 : Byte; red, green, blue : Byte );
begin
 byte0 := (red and $F8) or (green shr 5);
 byte1 := ( (green and $1C) shl 3)  or (blue shr 3);
end;


function sizeofheader (): longint;
begin
  Result := SizeOf(fnt_container.HEADER.file_type);
  Result := Result + SizeOf(fnt_container.HEADER.code);
  Result := Result + SizeOf(fnt_container.HEADER.version);
  if  fnt_container.HEADER.version = 8 then
  begin
      Result := Result + SizeOf(fnt_container.HEADER.palette);
      Result := Result + SizeOf(fnt_container.HEADER.gamuts);
  end;
  Result := Result + SizeOf(fnt_container.HEADER.charset);
  Result := Result + SizeOf(fnt_container.HEADER.char_info);
end;

procedure SetFNTSetup;
var
 i, min_vertical_offset : LongInt;
begin
  min_vertical_offset := High(LongInt);
  fnt_container.width:=0;
  fnt_container.height:=0;
  fnt_container.vertical_offset:=0;
  fnt_container.view_height:=0;

  for i := 0 to 255 do
    if( fnt_container.char_data[i].ischar ) then
    begin
     if(fnt_container.header.char_info[i].vertical_offset < min_vertical_offset) then
      min_vertical_offset := fnt_container.header.char_info[i].vertical_offset;
    end;

  for i := 0 to 255 do
    if( fnt_container.char_data[i].ischar ) then
    begin
     fnt_container.header.char_info[i].vertical_offset := fnt_container.header.char_info[i].vertical_offset - min_vertical_offset;

     if( fnt_container.header.char_info[i].width   > fnt_container.width  ) then fnt_container.width := fnt_container.header.char_info[i].width;
     if( fnt_container.header.char_info[i].height  > fnt_container.height ) then fnt_container.height := fnt_container.header.char_info[i].height;
     if( fnt_container.header.char_info[i].vertical_offset > fnt_container.vertical_offset) then fnt_container.vertical_offset := fnt_container.header.char_info[i].vertical_offset;
     if( (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > fnt_container.view_height ) then fnt_container.view_height := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
    end;
end;


end.