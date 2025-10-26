{ uMAPGraphic class to manipulate MAP files for DIV like Programs

  Copyright (C) 2013 DCelso <- gmail.com

  Esta código es software libre; usted puede redistribuirlo y/o modificarlo
  bajo los términos de la GNU General Public License publicada por la Free
  Software Foundation; sea versión 2 de la licencia, o (a su opción)
  cualquier posterior versión.

  Este código se distribuye con la esperanza de que sea útil, pero SIN
  NINGUNA GARANTÍA, ni siquiera la garantía implícita de COMERCIABILIDAD o
  IDONEIDAD PARA UN DETERMINADO FIN.  Consulte la GNU General Public License
  para obtener más detalles.

  Una copia de la Licencia Pública General de GNU está disponible en la
  World Wide Web en <http://www.gnu.org/copyleft/gpl.html>. También puede
  obtenerlo por escrito a la Free Software Foundation, Inc., 59 Temple Place -
  Suite 330, Boston, MA 02111-1307, USA.
}

unit uMAPGraphic;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs,
  IntfGraphics, FileUtil,LCLIntf, LCLType;

const
  lmMap = 0;
  lmFPG = 1;
  lmFont = 2;

type
  MAPGamut = record
     numcolors : Byte;
     mode : Byte;
     editable: Byte;
     unused: Byte;
     colors :array[0..31] of Byte;
  end;
  PMAPGamut = ^MAPGamut;

  { TMAPGraphic }
  TMAPGraphic = class(TBitmap)
  private
    Magic: array [0 .. 2] of Char;
    MSDOSEnd: array [0 .. 3] of Byte;
    Version: Byte;
    //      width          : word;  // Not needed, stored in TBitmap
    //      height         : word;  // Not needed, stored in TBitmap
    FCode: DWord;
    FbitsPerPixel: Word;            // to get faster this attribute.
    FCDIVFormat: Boolean;            // to get faster this attribute.
    procedure loadDataBitmap(Stream: TStream);
    procedure writeDataBitmap(Stream: TStream);
    procedure RGB24toBGR16(var byte0, byte1: Byte; red, green, blue: Byte);
    procedure RGB24toRGB16(var byte0, byte1: Byte; red, green, blue: Byte);
    procedure BGR16toRGB24(byte0, byte1: Byte; var red, green, blue: Byte);
    procedure RGB16toRGB24(byte0, byte1: Byte; var red, green, blue: Byte);
    function FindColor(index, rc, gc, bc: Integer): Integer;
    procedure SetFormat(cdiv : Boolean);
    procedure SetBitsPerPixel(bpp: word);
    procedure setMagic;
    function getName : String;
    procedure setName(str:String);
    function getFPName : String;
    procedure setFPName(str:String);
    procedure copyPixels(srcBitmap: TBitmap; x, y : Integer);
    procedure setAlpha( value: Byte; in_rect : TRect );
    procedure stringToArray(var inarray: array of char; str: string; len: integer);
  public
    data8bits: array of Byte;
    bPalette: array [0 .. 767] of Byte;
    Gamuts: array [0 .. 15] of MAPGamut;
    (*Temporalmente publicas*)
    GraphSize: LongInt;               // Needed for FPG Graphics
    FName: array [0 .. 31] of Char;
    FFPName: array [0 .. 11] of Char; // Needed for FPG Graphics
    NCPoints: LongInt;
    (* fin Temporalmente publicas*)
    CPoints :   array[0..high(Word)*2] of Word;
    (*Para soporte de Tipografías*)
    Width_Offset  : longint; // Ancho
    Height_Offset : longint; // Alto
    Horizontal_Offset: longint; // Desplazamiento vertical
    Vertical_Offset: longint; // Desplazamiento vertical
    file_Offset : longint; // Desplazamiento en el archivo

    procedure LoadFromFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream; loadmode: byte );
    procedure SaveToFile(const Filename: string); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream; savemode: byte);
    procedure CreateBitmap(bmp_src : TBitmap);
    procedure simulate1bppIn32bpp;
    procedure simulate8bppIn32bpp;
    procedure colorToTransparent(color1 : tcolor ;  splitTo16b :boolean = false);
    class function GetFileExtensions: string; override;
  published
    property CDIVFormat : Boolean read FCDIVFormat write SetFormat default False;
    property bitsPerPixel : Word read FbitsPerPixel write setBitsPerPixel default 32;
    property CPointsCount : Integer read NCPoints write NCPoints;
    property Name : String read getName write setName;
    property FPName : String read getFPName write setFPName;
    property Code : DWord read FCode write FCode default 1;
    class function test(filename: string): boolean;static ;
  end;

implementation

{ TMAPGraphic }

class function TMAPGraphic.GetFileExtensions: string;
begin
  Result := 'map';
end;

class function TMAPGraphic.test(filename: string): boolean;
var
 Stream       : TStream;
 tmpMagic: array [0 .. 2] of Char;
 tmpMSDOSEnd: array [0 .. 3] of Byte;
 tmpVersion: Byte;

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
   Stream.Read(tmpMagic, 3);
   Stream.Read(tmpMSDOSEnd , 4);
   Stream.Read(tmpVersion, 1);
  except
   Stream.free;
   Exit;
  end;

  // Ficheros de 1 bit
  if (tmpMagic[0]         = 'm') and (tmpMagic[1]         = '0') and
     (tmpMagic[2]         = '1') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  // Ficheros de 8 bits para DIV2, FENIX y CDIV
  if (tmpMagic[0]         = 'm') and (tmpMagic[1]         = 'a') and
     (tmpMagic[2]         = 'p') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  // Ficheros de 16 bits para FENIX
  if (tmpMagic[0]         = 'm') and (tmpMagic[1]         = '1') and
     (tmpMagic[2]         = '6') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;

  // Ficheros de 16 bits para CDIV
  if (tmpMagic[0]         = 'c') and (tmpMagic[1]         = '1') and
     (tmpMagic[2]         = '6') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;

  // Ficheros de 24 bits
  if (tmpMagic[0]         = 'm') and (tmpMagic[1]         = '2') and
     (tmpMagic[2]         = '4') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;

     // Ficheros de 32 bits
  if (tmpMagic[0]         = 'm') and (tmpMagic[1]         = '3') and
     (tmpMagic[2]         = '2') and (tmpMSDOSEnd [0]     = 26 ) and
     (tmpMSDOSEnd [1]     = 13 ) and (tmpMSDOSEnd [2] = 10 ) and
     (tmpMSDOSEnd [3] = 0) then begin
      Result := True;
  end;
  FreeAndNil(Stream);
end;


procedure TMAPGraphic.LoadFromFile(const Filename: string);
var
  f: TFileStream;
begin
  if not FileExistsUTF8(Filename) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(Filename, fmOpenRead);
  except
    Exit;
  end;

  try
    LoadFromStream(f);
  finally
    f.Free;
  end;

end;

procedure TMAPGraphic.LoadFromStream(Stream: TStream);
begin
  LoadFromStream(Stream,lmMap);
end;

procedure TMAPGraphic.LoadFromStream(Stream: TStream; loadmode: byte );
var
  tmpWidth: word;
  tmpHeight: word;
  intWidth: LongInt;
  intHeight: LongInt;
  i: integer;
  tmpNCPoints :word;
begin
  if (loadmode = lmMap) OR (loadmode = lmFPG) then
  begin
    if loadmode = lmMap then
    begin
      Stream.Read(Magic, 3);
      Stream.Read(MSDOSEnd, 4);
      Stream.Read(Version, 1);
      FbitsPerPixel := 0;
      FCDIVFormat := False;
      // Ficheros de 1 bit
      if (Magic[0] = 'm') and (Magic[1] = '0') and (Magic[2] = '1') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 0;
      end;
      // Ficheros de 8 bits para DIV2, FENIX y CDIV
      if (Magic[0] = 'm') and (Magic[1] = 'a') and (Magic[2] = 'p') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 8;
      end;
      // Ficheros de 16 bits para FENIX
      if (Magic[0] = 'm') and (Magic[1] = '1') and (Magic[2] = '6') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 16;
      end;

      // Ficheros de 16 bits para CDIV
      if (Magic[0] = 'c') and (Magic[1] = '1') and (Magic[2] = '6') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 16;
      end;

      // Ficheros de 24 bits
      if (Magic[0] = 'm') and (Magic[1] = '2') and (Magic[2] = '4') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 24;
      end;

      // Ficheros de 32 bits
      if (Magic[0] = 'm') and (Magic[1] = '3') and (Magic[2] = '2') and
        (MSDOSEnd[0] = 26) and (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
        (MSDOSEnd[3] = 0) then
      begin
        FbitsPerPixel := 32;
      end;

      Stream.Read(tmpWidth, 2);
      Stream.Read(tmpHeight, 2);
      Width := tmpWidth;
      Height := tmpHeight;
    end;

    Stream.Read(FCode, 4);

    if loadmode = lmFPG then
    begin
       Stream.Read(GraphSize,4);
    end;

    Stream.Read(FName, 32);

    if loadmode = lmFPG then
    begin
      Stream.Read(FFPName, 12);
      Stream.Read(intWidth, 4);
      Stream.Read(intHeight, 4);
      Width := intWidth;
      Height := intHeight;
    end;

    if (loadmode = lmMap) and (FbitsPerPixel = 8) then
    begin
      Stream.Read(bPalette, 768);
      Stream.Read(Gamuts, 576);

      for i := 0 to 767 do
        bPalette[i] := bPalette[i] shl 2;

    end;

    if loadmode = lmFPG then
        Stream.Read(ncpoints, 4)
    else begin
      Stream.Read(tmpNCPoints, 2);
      ncpoints:= tmpNCPoints;
    end;

    // Leemos los puntos de control del bitmap
    if ncpoints > 0  then
    begin
      Stream.Read(CPoints, ncpoints * 4);
    end;

  end;
  // Se carga la imagen resultante
  loadDataBitmap(Stream);

end;

procedure TMAPGraphic.loadDataBitmap(Stream: TStream);
var
  lazBMP: TLazIntfImage;
  p_bytearray: PByteArray;
  i, j, k, z: integer;
  byte_line: array [0 .. 16383] of byte;
  lenLineBits: integer;
  lineBit: byte;
  bytesPerPixel: Word;

begin
  // Se crea la imagen resultante
  PixelFormat := pf32bit;
  SetSize(Width, Height);
  bytesPerPixel:=FbitsPerPixel div 8;


  // Para usar en caso de un bit
  if FbitsPerPixel = 1 then
  begin
    lenLineBits := Width div 8;
    if (Width mod 8) <> 0 then
      lenLineBits := lenLineBits + 1;
  end;

  if FbitsPerPixel = 8 then
    SetLength(data8bits,Width*Height);

  lazBMP := CreateIntfImage;
  for k := 0 to Height - 1 do
  begin
    p_bytearray := lazBMP.GetDataLineStart(k);
    case FbitsPerPixel of
      1:
      begin
        for j := 0 to lenLineBits - 1 do
        begin
          Stream.Read(lineBit, 1);
          for i := 0 to 7 do
          begin
            z := (j * 8) + i;
            if z < Width then
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
      8:
      begin
        Stream.Read(byte_line, Width * bytesPerPixel);
        for j := 0 to Width - 1 do
        begin
          data8bits[k*Width+j]:=byte_line[j];
          p_bytearray^[j * 4] := bPalette[byte_line[j] * 3 + 2];
          p_bytearray^[j * 4 + 1] := bPalette[byte_line[j] * 3 + 1];
          p_bytearray^[j * 4 + 2] := bPalette[byte_line[j] * 3];
          p_bytearray^[j * 4 + 3] := 255;
          if byte_line[j] = 0 then
            p_bytearray^[j * 4 + 3] := 0;
        end;
      end;
      16:
      begin
        Stream.Read(byte_line, Width * bytesPerPixel);
        for j := 0 to Width - 1 do
        begin
          if FCDIVFormat then
          begin
            RGB16toRGB24(byte_line[j * 2 + 1], byte_line[j * 2],
              p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
              p_bytearray^[(j * 4) + 2]);
            p_bytearray^[(j * 4) + 3] := 255;
            if ((p_bytearray^[j * 4] = $F8) and
              (p_bytearray^[j * 4 + 1] = 0) and
              (p_bytearray^[j * 4 + 2] = $F8)) then
              p_bytearray^[(j * 4) + 3] := 0;
          end
          else
          begin
            BGR16toRGB24(byte_line[j * 2 + 1], byte_line[j * 2],
              p_bytearray^[j * 4], p_bytearray^[(j * 4) + 1],
              p_bytearray^[(j * 4) + 2]);
            p_bytearray^[(j * 4) + 3] := 255;
            if (byte_line[j * 2 + 1] + byte_line[j * 2]) = 0 then
              p_bytearray^[(j * 4) + 3] := 0;

          end;

        end;
      end;
      24:
      begin
        Stream.Read(byte_line, Width * bytesPerPixel);
        for j := 0 to Width - 1 do
        begin
          p_bytearray^[j * 4] := byte_line[j * 3];
          p_bytearray^[j * 4 + 1] := byte_line[j * 3 + 1];
          p_bytearray^[j * 4 + 2] := byte_line[j * 3 + 2];
          p_bytearray^[j * 4 + 3] := 255;
          if (byte_line[j * 3 + 2] + byte_line[j * 3 + 1] + byte_line[j * 3]) = 0 then
            p_bytearray^[(j * 4) + 3] := 0;
        end;
      end;
      else // 32 bits
        Stream.Read(p_bytearray^, Width * bytesPerPixel)
    end;
  end;
  LoadFromIntfImage(lazBMP);
  lazBMP.Free;

end;

procedure TMAPGraphic.SaveToStream(Stream: TStream);
begin
  saveToStream(Stream, lmMap);
end;

procedure TMAPGraphic.SaveToStream(Stream: TStream; savemode: byte);
var
  i: word;
  aWidth, aHeight: word;
  wordNCPoints: Word;
  widthForFPG1: integer;
begin

  if savemode=lmMap then
  begin
    MSDOSEnd[0] := 26;
    MSDOSEnd[1] := 13;
    MSDOSEnd[2] := 10;
    MSDOSEnd[3] := 0;

    Stream.Write(Magic, 3);
    Stream.Write(MSDOSEnd, 4);
    Stream.Write(Version, 1);

    aWidth := Width;
    aHeight := Height;
    Stream.Write(aWidth, 2);
    Stream.Write(aHeight, 2);
  end;

  if (savemode=lmFPG) OR (savemode=lmMap) then
    Stream.Write(FCode, 4);

  if savemode=lmFPG then
  begin
    if FbitsPerPixel = 1 then
    begin
      widthForFPG1 := Width;
      if (Width mod 8) <> 0 then
        widthForFPG1 := widthForFPG1 + 8 - (Width mod 8);
      graphSize := (widthForFPG1 div 8) * Height + 64;
    end
    else
    begin
      graphSize := (Width * Height * (FbitsPerPixel div 8)) + 64;
    end;
    if (ncpoints > 0) then
      graphSize := graphSize + (ncpoints * 4);

    Stream.Write(graphSize, 4);
  end;

  if (savemode=lmFPG) OR (savemode=lmMap) then
    Stream.Write(FName, 32);

  if savemode=lmFPG then
  begin
    Stream.Write(FFPName, 12);
    Stream.Write(Width, 4);
    Stream.Write(Height, 4);
  end;

  if (savemode=lmMap) and (FbitsPerPixel = 8) then
  begin
    for i := 0 to 767 do
      bPalette[i] := bPalette[i] shr 2;

    Stream.Write(bPalette, 768);
    Stream.Write(Gamuts, 576);

    for i := 0 to 767 do
      bPalette[i] := bPalette[i] shl 2;
  end;

  if savemode=lmFPG then
      Stream.Write(ncpoints, 4);

  if savemode=lmMap then
  begin
    wordNCPoints := ncpoints;
    Stream.Write(wordNCPoints, 2);
  end;

  if (savemode=lmFPG) OR (savemode=lmMap) then
    if ncpoints > 0  then
      Stream.Write(CPoints, ncpoints * 4);

  writeDataBitmap(Stream);

end;

procedure TMAPGraphic.writeDataBitmap(Stream: TStream);
var
  lazBMP: TLazIntfImage;
  byte_line: array [0 .. 16383] of byte;
  byteForFPG1: byte;
  insertedBits: integer;
  p_bytearray: PByteArray;
  j, k: word;
  bytes_per_pixel : word;
  index8bit : byte;
begin
  lazBMP := CreateIntfImage;
  bytes_per_pixel:= FbitsPerPixel div 8;
  for k := 0 to Height - 1 do
  begin
    p_bytearray := lazBmp.GetDataLineStart(k);
    case FbitsPerPixel of
      1:
      begin
        insertedBits := 0;
        byteForFPG1 := 0;
        for j := 0 to Width - 1 do
        begin
          if (p_bytearray^[j * 4] shr 7) = 1 then
          begin
            byteForFPG1 := byteForFPG1 or 1; // bit más alto en 8 bits
          end;
          insertedBits := insertedBits + 1;
          if (insertedBits = 8) then
          begin
            Stream.Write(byteForFPG1, 1);
            byteForFPG1 := 0;
            insertedBits := 0;
          end
          else
            byteForFPG1 := byteForFPG1 shl 1;
        end;
        if insertedBits > 0 then
        begin
          byteForFPG1 := byteForFPG1 shl (7 - insertedBits);
          Stream.Write(byteForFPG1, 1);
        end;
      end;
      8:
      begin
        for j := 0 to Width - 1 do
        begin
          if Code = 101 then
          begin
            index8bit:=0;
          end;

          byte_line[j] := 0;
          index8bit:=0;
          if length(data8bits) >0 then
             index8bit:= data8bits[k*Width+j];
          if p_bytearray^[j * 4 + 3] <> 0 then
          begin
            if (p_bytearray^[j * 4] = bPalette[index8bit*3]) and
               (p_bytearray^[j * 4 + 1] = bPalette[index8bit*3 +1]) and
               (p_bytearray^[j * 4 + 2] = bPalette[index8bit*3 +2 ] ) then
               byte_line[j]:= index8bit
            else
              byte_line[j] := FindColor(0, p_bytearray^[j * 4 + 2],
                p_bytearray^[j * 4 + 1], p_bytearray^[j * 4]);
          end;
        end;
        Stream.Write(byte_line, Width);
      end;
      16:
      begin
        for j := 0 to Width - 1 do
        begin
          if FCDIVFormat then
            if p_bytearray^[j * 4 + 3] <> 0 then
              RGB24toRGB16(byte_line[j * 2 + 1],
                byte_line[j * 2], p_bytearray^[j * 4], p_bytearray^[j * 4 + 1],
                p_bytearray^[j * 4 + 2])
            else
              RGB24toRGB16(byte_line[j * 2 + 1], byte_line[j * 2], 248, 0, 248)
          else
          begin
            byte_line[j * 2] := 0;
            byte_line[j * 2 + 1] := 0;
            if p_bytearray^[j * 4 + 3] <> 0 then
              RGB24toBGR16(byte_line[j * 2 + 1],
                byte_line[j * 2], p_bytearray^[j * 4], p_bytearray^[j * 4 + 1],
                p_bytearray^[j * 4 + 2]);

          end;
        end;
        Stream.Write(byte_line, Width * bytes_per_pixel);
      end;
      24:
      begin
        for j := 0 to Width - 1 do
        begin
          byte_line[j * 3] := 0;
          byte_line[j * 3 + 1] := 0;
          byte_line[j * 3 + 2] := 0;
          if p_bytearray^[j * 4 + 3] <> 0 then
          begin
            byte_line[j * 3] := p_bytearray^[j * 4];
            byte_line[j * 3 + 1] := p_bytearray^[j * 4 + 1];
            byte_line[j * 3 + 2] := p_bytearray^[j * 4 + 2];
          end;
        end;
        Stream.Write(byte_line, Width * bytes_per_pixel);
      end;
      else  // 32 bits
      begin
        Stream.Write(p_bytearray^, Width * bytes_per_pixel);
      end;
    end;

  end;
  lazBMP.Free;
end;

function TMAPGraphic.FindColor(index, rc, gc, bc: integer): integer;
var
  dif_colors, temp_dif_colors, i: word;
begin
  dif_colors := 800;
  Result := 0;

  for i := index to 255 do
  begin
    temp_dif_colors :=
      Abs(rc - bPalette[i * 3]) + Abs(gc - bPalette[(i * 3) + 1]) +
      Abs(bc - bPalette[(i * 3) + 2]);

    if temp_dif_colors <= dif_colors then
    begin
      Result := i;
      dif_colors := temp_dif_colors;

      if dif_colors = 0 then
        Exit;
    end;

  end;

end;

procedure TMAPGraphic.SaveToFile(const Filename: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(filename, fmCreate);
  SaveToStream(f);
  f.Free;
end;


// Calcula las componentes RGB almacenadas en 2 bytes como BGR
procedure TMAPGraphic.BGR16toRGB24(byte0, byte1: byte; var red, green, blue: byte);
begin
  blue := byte0 and $F8; // me quedo 5 bits 11111000
  green := (byte0 shl 5) or ((byte1 and $E0) shr 3);
  // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
  red := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes RGB almacenadas en 2 bytes como RGB
procedure TMAPGraphic.RGB16toRGB24(byte0, byte1: byte; var red, green, blue: byte);
begin
  red := byte0 and $F8; // me quedo 5 bits 11111000
  green := (byte0 shl 5) or ((byte1 and $E0) shr 3);
  // me quedo 3 bits de byte0 y 3 bits de byte 1 (11100000)
  blue := byte1 shl 3; // me quedo 5 bits
end;

// Calcula las componentes BGR almacenandolas en 2 bytes como BGR
procedure TMAPGraphic.RGB24toBGR16(var byte0, byte1: byte; red, green, blue: byte);
begin
  // F8 = 11111000
  // 1C = 00011100
  byte0 := (blue and $F8) or (green shr 5);
  byte1 := ((green and $1C) shl 3) or (red shr 3);
end;

// Establece las componentes RGB almacenandolas en 2 bytes como RGB
procedure TMAPGraphic.RGB24toRGB16(var byte0, byte1: byte; red, green, blue: byte);
begin
  // F8 = 11111000
  // 1C = 00011100
  byte0 := (red and $F8) or (green shr 5);
  byte1 := ((green and $1C) shl 3) or (blue shr 3);
end;

procedure  TMAPGraphic.SetFormat(cdiv : Boolean);
begin
  FCDIVFormat:=cdiv;
  if cdiv then
    FbitsPerPixel:=16;
  setMagic;
end;

procedure  TMAPGraphic.setMagic;
var
  strBpp :String;
begin
  if FCDIVFormat then
  begin
    magic[0]:='c';
  end else begin
    magic[0]:='m';
  end;
  if FbitsPerPixel = 8 then
  begin
    magic[1]:='a';
    magic[2]:='p';
  end else begin
    strBpp:= Format('%.2d',[FbitsPerPixel]);
    magic[1]:=strBpp[1];
    magic[2]:=strBpp[2];
  end;

end;

procedure TMAPGraphic.SetBitsPerPixel(bpp: word);
begin
  FbitsPerPixel:=bpp;
  if FCDIVFormat then
    FbitsPerPixel:=16;
  setMagic;
end;

function TMAPGraphic.getName : String;
var
  i : integer;
begin
  result:='';
  i:=0;
  while ( FName[i] <>char(0) ) and (i<32) do
  begin
        result:= result+FName[i];
        i:=i+1;
  end;

end;

function TMAPGraphic.getFPName : String;
var
  i : integer;
begin
  result:='';
  i:=0;
  while ( FFPName[i] <>char(0) ) and (i<12) do
  begin
        result:= result+FFPName[i];
        i:=i+1;
  end;

end;


procedure TMAPGraphic.setName(str:String);
begin
 stringToArray(FName,str,32);
end;

procedure TMAPGraphic.setFPName(str:String);
begin
 stringToArray(FFPName,str,12);
end;

procedure TMAPGraphic.copyPixels(srcBitmap: TBitmap; x, y : Integer);
var
  dstLazBitmap: TLazIntfImage;
  srcLazBitmap: TLazIntfImage;
begin
 dstLazBitmap:=CreateIntfImage;
 srcLazBitmap:=srcBitmap.CreateIntfImage;

 dstLazBitmap.CopyPixels(srcLazBitmap,x,y);

 srcLazBitmap.free;
 LoadFromIntfImage(dstLazBitmap);
 dstLazBitmap.free;
end;


procedure TMAPGraphic.CreateBitmap(bmp_src : TBitmap);
begin
 PixelFormat:=pf32bit;
 SetSize(bmp_src.Width, bmp_src.Height);

 CopyPixels(bmp_src,0,0);

 if bmp_src.PixelFormat<>pf32bit then
    setAlpha(255,Rect(0,0,Width,Height));
 case FbitsPerPixel of
    1:
    begin
          simulate1bppIn32bpp;
    end;
    8:
    begin
         simulate8bppIn32bpp;
    end;
    16:
    begin
         if FCDIVFormat then
                  colorToTransparent(clFuchsia,true )
         else
             colorToTransparent(clBlack,true );
    end;
    24:
    begin
         colorToTransparent(clBlack );
    end;
 end;

end;

procedure TMAPGraphic.setAlpha( value: Byte; in_rect : TRect );
var
  lazBitmap: TLazIntfImage;
  k, j :integer;
  ppixel : PRGBAQuad;
begin
 lazBitmap:= CreateIntfImage;
 for k := in_rect.top to in_rect.Bottom -1 do
 begin
   ppixel := lazBitmap.GetDataLineStart(k);
   for j := in_rect.Left to in_rect.Right - 1 do
     ppixel[j].Alpha := value;
 end;
 LoadFromIntfImage(lazBitmap);
 lazBitmap.free;
end;

procedure TMAPGraphic.simulate1bppIn32bpp;
var
 lazBMP: TLazIntfImage;
 rgbaLine : PRGBAQuad;
 i, j : LongInt;
begin
   lazBMP:=CreateIntfImage;
   for j := 0 to height - 1 do begin
    rgbaLine := lazBMP.GetDataLineStart(j);
    for i := 0 to width - 1 do begin
      if ((rgbaLine[i].Alpha shr 7) =1) and ((rgbaLine[i].Red shr 7) = 1)  then begin
         rgbaLine[i].Red := 255;
         rgbaLine[i].Green := 255;
         rgbaLine[i].Blue := 255;
         rgbaLine[i].Alpha:= 255;
      end else begin
         rgbaLine[i].Red := 0;
         rgbaLine[i].Green := 0;
         rgbaLine[i].Blue := 0;
         rgbaLine[i].Alpha:= 0;
      end;
    end;
   end;
   LoadFromIntfImage(lazBMP);
   lazBMP.free;
end;


procedure TMAPGraphic.simulate8bppIn32bpp;
var
 lazBMP_src: TLazIntfImage;
 p_src : PRGBAQuad;
 i, j : LongInt;
 pal_index : integer;
begin
   lazBMP_src:= CreateIntfImage;
   for j := 0 to height - 1 do
   begin
    p_src := lazbmp_src.GetDataLineStart(j);
    for i := 0 to width - 1 do
     begin
        pal_index := FindColor(0, p_src[i].Red , p_src[i].Green, p_src[i].Blue);
        p_src[i].red := bpalette[pal_index * 3];
        p_src[i].green := bpalette[(pal_index * 3)+1];
        p_src[i].blue := bpalette[(pal_index * 3)+2];
        if ((p_src[i].Alpha shr 7) = 1) and (pal_index<>0) then
           p_src[i].Alpha:=255
        else
           p_src[i].Alpha:=0;
     end;
   end;
   LoadFromIntfImage(lazBMP_src);
   lazBMP_src.free;
end;

procedure TMAPGraphic.colorToTransparent( color1 : tcolor ;  splitTo16b :boolean = false);
var
 lazBMP_src: TLazIntfImage;
 p_src : PRGBAQuad;
 i, j : LongInt;
 curColor: TColor;
begin
   if splitTo16b then
       color1:=RGB(GetRValue(color1) and $F8, GetGValue(color1) and $FC,GetBValue(color1) and $F8);
   lazBMP_src:= CreateIntfImage;
   for j := 0 to height - 1 do
   begin
    p_src := lazbmp_src.GetDataLineStart(j);
    for i := 0 to width - 1 do
     begin
        if splitTo16b then
        begin
          p_src[i].red := (p_src[i].red and $F8);
          p_src[i].green := (p_src[i].green and $FC);
          p_src[i].blue := (p_src[i].blue and $F8);
        end;
        curColor:=RGB(p_src[i].red, p_src[i].green,p_src[i].Blue );
        if ((p_src[i].Alpha shr 7 )= 1 ) and (curColor <> color1) then
          p_src[i].Alpha := 255
        else
          p_src[i].Alpha := 0;
     end;
   end;
   LoadFromIntfImage(lazBMP_src);
   lazBMP_src.free;
end;

procedure TMAPGraphic.stringToArray(var inarray: array of char; str: string; len: integer);
var
  i: integer;
begin
  for i := 0 to len - 1 do
  begin
    if i >= length(str) then
      inarray[i] := char(0)
    else
      inarray[i] := str[i + 1];
  end;
end;
(*
procedure TMAPGraphic.Assign(Source: TPersistent);
var
  bmpIntf : TLazIntfImage;
  bmpIntf2 : TLazIntfImage;
begin
  if Source is TBitmap then
  begin
   bmpIntf:=CreateIntfImage;
   bmpIntf2:=TBitmap(Source).CreateIntfImage;

   bmpIntf.CopyPixels(bmpIntf2,0,0);

   LoadFromIntfImage(bmpIntf);
   FreeAndNil(bmpIntf);
   FreeAndNil(bmpIntf2);
  end else
    inherited Assign(Source);
end;
*)

initialization
  TPicture.RegisterFileFormat('map','DIV MAP Images', TMAPGraphic);

end.