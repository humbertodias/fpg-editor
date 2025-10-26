unit uMap;

interface

uses LCLIntf, LCLType, SysUtils, Forms, Classes, dialogs,
     Graphics, FileUtil, IntfGraphics,
     uFrmMessageBox, uLanguage, uColor16bits;

const
 MAX_NUM_IMAGES = 999;
 FPG_NULL = 255;
 FPG1 = 0;
 FPG8_DIV2   = 1;
 FPG16 = 2;
 FPG16_CDIV  = 3;
 FPG24  = 4;
 FPG32  = 5;

type
 file_str_map = record
  Magic          : array [0 .. 2] of char;
  MSDOSEnd       : array [0 .. 3] of byte;
  Version        : byte;
  width          : word;
  height         : word;
  code           : dword;
  description    : array [0 .. 31] of char;
  palette   : array [0 .. 767] of byte;
  gamma     : array [0 .. 575] of byte;
  ncpoints          : Word;
  cpoints :   array[0..high(Word)*2] of Word;
  //maximun value of a Word 65535, need 1 word for x and other word for y.
  bmp : TBitMap;
 end;


function MAP_Load(filename: string; var ncpoints:word; cpoints:PWord) : TBitmap;
function create_hpal (palette_ar : array of byte) : HPALETTE;
function loadDataBitmap(var f : TStream; palette : PByte ; width , height : longint; bytes_per_pixel : word; is_cdiv: boolean): TBitmap;
function MAP_test(filename :String):Boolean;

implementation
 function create_hpal (palette_ar : array of byte) : HPALETTE;
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
     pal^.palPalEntry[i].peRed   := palette_ar[(i*3)    ];
     pal^.palPalEntry[i].peGreen := palette_ar[(i*3) + 1];
     pal^.palPalEntry[i].peBlue  := palette_ar[(i*3) + 2];
     pal^.palPalEntry[i].peFlags := 0;
    end;

    create_hpal := CreatePalette(pal^);

  finally
    FreeMem(pal);
  end;
 end;

function loadDataBitmap(var f : TStream; palette : PByte ; width , height : longint; bytes_per_pixel : word; is_cdiv: boolean): TBitmap;
var
  lazBMP : TLazIntfImage;
  p_bytearray: PByteArray;
  i, j, k, z: integer;
  byte_line: array [0 .. 16383] of byte;
  lenLineBits: integer;
  lineBit: byte;

begin
        // Se crea la imagen resultante
        result := TBitMap.Create;
        result.PixelFormat := pf32bit;
        result.SetSize(Width, Height);


        // Para usar en caso de un bit
        if bytes_per_pixel = 0 then
        begin
          lenLineBits := Width div 8;
          if (Width mod 8) <> 0 then
            lenLineBits := lenLineBits + 1;
        end;

        lazBMP := result.CreateIntfImage;
        for k := 0 to result.Height - 1 do
        begin
          p_bytearray := lazBMP.GetDataLineStart(k);
          case bytes_per_pixel of
            0:
            begin
                for j := 0 to lenLineBits - 1 do
                begin
                  f.Read(lineBit, 1);
                  for i := 0 to 7 do
                  begin
                    z := (j * 8) + i;
                    if z < result.Width then
                    begin
                      if (lineBit and 128) = 128 then
                      begin
                        p_bytearray^[z * 4] := 255;
                        p_bytearray^[(z * 4) + 1] := 255;
                        p_bytearray^[(z * 4) + 2] := 255;
                        p_bytearray^[(z * 4) + 3] := 255;
                      end
                      else
                      begin
                        p_bytearray^[z * 4] := 0;
                        p_bytearray^[(z * 4) + 1] := 0;
                        p_bytearray^[(z * 4) + 2] := 0;
                        p_bytearray^[(z * 4) + 3] := 0;
                      end;
                      lineBit := lineBit shl 1;
                    end
                    else
                      break;
                  end;
                end;
            end;
            1:
            begin
              f.Read(byte_line, result.Width * bytes_per_pixel);
              for j:=0 to result.Width -1  do
              begin
                 p_bytearray^[j*4] := palette[byte_line[j] * 3 + 2];
                 p_bytearray^[j*4+1] := palette[byte_line[j] * 3 + 1];
                 p_bytearray^[j*4+2] := palette[byte_line[j] * 3];
                 p_bytearray^[j*4+3]:=255;
                 if byte_line[j]=0 then
                   p_bytearray^[j*4+3]:=0;
              end;
            end;
            2:
            begin
              f.Read(byte_line, result.Width * bytes_per_pixel);
              for j:=0 to result.Width -1  do
              begin
                if is_cdiv then
                begin
                  Calculate_RGB(byte_line[j*2+1], byte_line[j*2],
                    p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
                    p_bytearray^[(j * 4) + 2]);
                  p_bytearray^[(j * 4) + 3] := 255;
                  if ( ( p_bytearray^[j * 4] = $F8) and
                         ( p_bytearray^[j * 4 + 1] = 0) and
                         ( p_bytearray^[j * 4 + 2] = $F8)  ) then
                     p_bytearray^[(j * 4) + 3] := 0;
                end
                else
                begin
                  Calculate_BGR(byte_line[j*2+1], byte_line[j*2 ],
                    p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
                    p_bytearray^[(j * 4) + 2]);
                  p_bytearray^[(j * 4) + 3] := 255;
                  if (byte_line[j*2+1] + byte_line[j*2 ]) = 0 then
                     p_bytearray^[(j * 4) + 3] := 0;

                end;

              end;
            end;
            3:
            begin
              f.Read(byte_line, result.Width * bytes_per_pixel);
              for j:=0 to result.Width -1  do
              begin
                p_bytearray^[j*4] := byte_line[j*3];
                p_bytearray^[j*4+1] := byte_line[j*3+1];
                p_bytearray^[j*4+2] := byte_line[j*3+2];
                p_bytearray^[j*4+3]:=255;
                if (byte_line[j*3+2] + byte_line[j*3+1] + byte_line[j*3 ]) = 0 then
                     p_bytearray^[(j * 4) + 3] := 0;
              end;
            end;
            else // 32 bits
                f.Read(p_bytearray^, result.Width * bytes_per_pixel)
          end;
        end;
        result.LoadFromIntfImage(lazBMP);
        lazBMP.Free;

end;

function MAP_test(filename :String):Boolean;
var
 Stream       : TStream;
 header : file_str_map;
begin
  Result := False;
  if not FileExistsUTF8(filename) { *Converted from FileExists*  } then
   Exit;
  try
   Stream := TFileStream.Create(filename, fmOpenRead);
  except
   Exit;
  end;

  try
   Stream.Read(header.Magic, 3);
   Stream.Read(header.MSDOSEnd , 4);
   Stream.Read(header.Version, 1);
  except
   Stream.free;
   Exit;
  end;

  // Ficheros de 1 bit
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '0') and
     (header.Magic[2]         = '1') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = 'a') and
     (header.Magic[2]         = 'p') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  // Ficheros de 16 bits para FENIX
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '1') and
     (header.Magic[2]         = '6') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;

  // Ficheros de 16 bits para CDIV
  if (header.Magic[0]         = 'c') and (header.Magic[1]         = '1') and
     (header.Magic[2]         = '6') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;

  // Ficheros de 24 bits
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '2') and
     (header.Magic[2]         = '4') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;

     // Ficheros de 32 bits
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '3') and
     (header.Magic[2]         = '2') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  FreeAndNil(Stream);
end;

function MAP_Load(filename: string; var ncpoints:word; cpoints:PWord) : TBitmap;
 var
  f       : TStream;
  frames,
  length,
  speed   : word;
  bytes_per_pixel  : word;
  is_cdiv : boolean;
  header : file_str_map;
  map_hpal : HPALETTE;
  i : integer;

 begin

  result   := nil;

  if not FileExistsUTF8(filename) { *Converted from FileExists*  } then
   Exit;

  try
   f := TFileStream.Create(filename, fmOpenRead);
  except
   Exit;
  end;

  try
   f.Read(header.Magic, 3);
   f.Read(header.MSDOSEnd , 4);
   f.Read(header.Version, 1);
  except
   f.free;
   Exit;
  end;

  bytes_per_pixel := 0;
  is_cdiv:=false;
  // Ficheros de 1 bit
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '0') and
     (header.Magic[2]         = '1') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 0;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = 'a') and
     (header.Magic[2]         = 'p') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 1;
  end;
  // Ficheros de 16 bits para FENIX
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '1') and
     (header.Magic[2]         = '6') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 2;
  end;

  // Ficheros de 16 bits para CDIV
  if (header.Magic[0]         = 'c') and (header.Magic[1]         = '1') and
     (header.Magic[2]         = '6') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 2;
   is_cdiv:=true;
  end;

  // Ficheros de 24 bits
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '2') and
     (header.Magic[2]         = '4') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 3;
  end;

     // Ficheros de 32 bits
  if (header.Magic[0]         = 'm') and (header.Magic[1]         = '3') and
     (header.Magic[2]         = '2') and (header.MSDOSEnd [0]     = 26 ) and
     (header.MSDOSEnd [1]     = 13 ) and (header.MSDOSEnd [2] = 10 ) and
     (header.MSDOSEnd [3] = 0) then begin
   bytes_per_pixel := 4;
  end;

  if (bytes_per_pixel > 4) then
  begin
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_WRONG_FPG], 0, 0);
   f.free;
   Exit;
  end;

  try
   f.Read(header.width,2);
   f.Read(header.height,2);
   f.Read(header.code,4);
   f.Read(header.description, 32);

   if (bytes_per_pixel = 1) then
   begin
    f.Read(header.palette, 768);
    f.Read(header.gamma, 576);

    for i := 0 to 767 do
     header.palette[i] := header.palette[i] shl 2;

    map_hpal := create_hpal(header.palette);

   end;

   f.Read(ncpoints, 2);
   //ncpoints:=header.ncpoints;

   // Leemos los puntos de control del bitmap


   if ncpoints > 0 then
   begin
    f.Read(header.cpoints, ncpoints  * 4);
    for i:=0 to (ncpoints*2)-1 do
    begin
        cpoints[i]:=header.cpoints[i];
    end;
   end;
   //else
   // FillChar(cpoints,High(Word)*4,0); //borramos los puntos de control.

   (*  BennuGD no controla que si ncpoints = 4096 haga algo distinto,
       Habría que revistar esta funcionalidad en DIV si se quiere implementar
   if ((header.ncpoints > 0) and (header.ncpoints  <> 4096)) then
   begin
    f.Read(header.cpoints, header.ncpoints  * 4);
   end;

   if (header.ncpoints  = 4096) then
   begin
    f.Read(frames, 2);
    f.Read(length, 2);
    f.Read(speed , 2);
    f.Seek(length * 2, soFromCurrent);
   end;
   *)


   // Se crea la imagen resultante

   result:=loadDataBitmap(f,header.palette, header.width,header.height, bytes_per_pixel, is_cdiv);

  finally
   f.free;
  end;
 end;

end.
 