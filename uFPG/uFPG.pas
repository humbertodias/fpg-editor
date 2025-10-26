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

unit uFPG;

{$mode objfpc}{$H+}

interface

uses SysUtils, Classes, Graphics, FileUtil, ComCtrls,
     uMAPGraphic, Dialogs, LConvEncoding;

const
  MAX_NUM_IMAGES = 999;
  FPG_NULL = 255;
  FPG1 = 0;
  FPG8_DIV2 = 1;
  FPG16 = 2;
  FPG16_CDIV = 3;
  FPG24 = 4;
  FPG32 = 5;

  FNX1 = 16;
  FNT8 = 17;
  FNX8 = 18;
  FNX16 = 19;
  FNX24 = 20;
  FNX32 = 21;

type

  TFpg = class(TPersistent)
  private
    { Private declarations }
  public
    { Public declarations }
    Magic: array [0 .. 2] of char; {fpg, f16, c16}
    MSDOSEnd: array [0 .. 3] of byte;
    Version: byte;
    Palette: array [0 .. 767] of byte;
    Gamuts: array [0 .. 15] of MAPGamut;
    FileFormat: byte;
    images: array [1 .. MAX_NUM_IMAGES] of TMAPGraphic;
    active, update: boolean;
    source: String;
    needTable: boolean;
    Count: word;
    lastCode: word;
    loadPalette: boolean;
    table_16_to_8: array [0 .. 31, 0 .. 63, 0 .. 31] of byte;
    appName : String;
    appVersion : String;

    (*Strings para mensajes*)
    fmsgInfo    : String;
    fmsgError   : String;
    fmsgCorrect : String;
    fmsgWrong   : String;
    (* Para soporte de Tipografías *)
    charset   : longint; // Tipos

    constructor Create;
    destructor Destroy; override;
    function CodeExists(code: word): boolean;
    function indexOfCode(code: word): word;
    procedure DeleteWithCode(code: word);
    procedure Initialize;
    procedure setMagic;
    procedure SaveToFile(gFPG: TProgressBar);
    procedure SaveToFile(index: integer; filename: string);
    function LoadFromFile(str: string; gFPG: TProgressBar): boolean;
    procedure Create_table_16_to_8;
    procedure Sort_Palette;
    procedure add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TMapGraphic);
    procedure replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TMapGraphic);
    function isKnownFormat: boolean;
    function loadHeaderFromFile(fileName : String): Boolean;
    procedure loadHeaderFromStream( stream : TStream );
    procedure saveHeaderToStream(stream : TStream);
    function getFPGFormat(var byte_size : Word) :Integer;
    function getFontFormat(var byte_size : Word) :Integer;
    function getFormat(var byte_size : Word): Integer ;
    function getBPP : Word;
    function findColor(index, rc, gc, bc: integer): integer;

    class function test(str: string): boolean;static ;
    procedure setDefaultGamut;
    function isFont: boolean;
  published
    property msgInfo: String read fmsgInfo write fmsgInfo;
    property msgError: String read fmsgError write fmsgError;
    property msgCorrect: String read fmsgCorrect write fmsgCorrect;
    property msgWrong: String read fmsgWrong write fmsgWrong;

  end;

resourcestring
  STRFPG1 = 'FPG 1 bit (Fenix/BennuGD)';
  STRFPG8 = 'FPG 8 bits (All)';
  STRFPG16 = 'FPG 16 bits (Fenix/BennuGD)';
  STRFPGCDIV16 = 'FPG 16 bits (CDIV)';
  STRFPG24 = 'FPG 24 bits ';
  STRFPG32 = 'FPG 32 bits (BennuGD)';

  STRFNX1 = 'FNT 1 bit (Fenix/BennuGD)';
  STRFNT = 'FNT 8 bits (All)';
  STRFNX8 = 'FNT 8 bits (Fenix/BennuGD)';
  STRFNX16 = 'FNT 16 bits (Fenix/BennuGD)';
  STRFNX24 = 'FNT 24 bits ';
  STRFNX32 = 'FNT 32 bits (BennuGD)';


procedure stringToArray(var inarray: array of char; str: string; len: integer);

//procedure Register;

implementation

//procedure Register;
//begin
//  {$I uFPG_icon.lrs}
//  RegisterComponents('FPG Editor', [TFpg]);
//end;

function TFpg.getBPP:Word;
begin
  result:=0;
  case FileFormat of
    FPG1, FNX1:
    begin
      result:=1;
    end;
    FPG8_DIV2, FNT8,FNX8:
    begin
      result:=8;
    end;
    FPG16, FPG16_CDIV,FNX16:
    begin
      result:=16;
    end;
    FPG24,FNX24:
    begin
      result:=24;
    end;
    FPG32,FNX32:
    begin
      result:=32;
    end;
  end;
end;

function TFpg.getFontFormat(var byte_size : Word) :Integer;
begin
  Result := FPG_NULL;
  // Ficheros FNT
  if (Magic[0] = 'f') and (Magic[1] = 'n') and
   (Magic[2] = 't') then
  begin
   Result := FNT8;
   byte_size := 8;
   Exit;
  end;
  // Ficheros FNX
  if (Magic[0] = 'f') and (Magic[1] = 'n') and
   (Magic[2] = 'x')  then
  begin
   byte_size := Version;
  end;

  // Ficheros de 1 bit1
  if version = 1  then
  begin
   Result := FNX1;
   Exit;
  end;

  // Ficheros de 8 bits
  if version = 8  then
  begin
   Result := FNX8;
   Exit;
  end;

  // Ficheros de 16 bits
  if version = 16  then
  begin
    Result := FNX16;
    Exit;
  end;

  // Ficheros de 24 bits
  if version = 24  then
  begin
   Result := FNX24;
   Exit;
  end;

  // Ficheros de 32 bits
  if version = 32  then
  begin
    Result := FNX32;
    Exit;
  end;

end;

function TFpg.getFPGFormat(var byte_size : Word) :Integer;
begin
 Result := FPG_NULL;
 // Ficheros de 1 bit
 if (Magic[0] = 'f') and (Magic[1] = '0') and
   (Magic[2] = '1') then
 begin
   Result := FPG1;
   byte_size := 0;
   Exit;
 end;
 // Ficheros de 8 bits para DIV2, FENIX y CDIV
 if (Magic[0] = 'f') and (Magic[1] = 'p') and
   (Magic[2] = 'g')  then
 begin
   Result := FPG8_DIV2;
   byte_size := 1;
   Exit;
 end;
 // Ficheros de 16 bits para FENIX
 if (Magic[0] = 'f') and (Magic[1] = '1') and
   (Magic[2] = '6')  then
 begin
   Result := FPG16;
   byte_size := 2;
   Exit;
 end;

 // Ficheros de 16 bits para CDIV
 if (Magic[0] = 'c') and (Magic[1] = '1') and
   (Magic[2] = '6') then
 begin
   Result := FPG16_CDIV;
   byte_size := 2;
   Exit;
 end;

 // Ficheros de 24 bits
 if (Magic[0] = 'f') and (Magic[1] = '2') and
   (Magic[2] = '4')  then
 begin
   Result := FPG24;
   byte_size := 3;
   Exit;
 end;

 // Ficheros de 32 bits
 if (Magic[0] = 'f') and (Magic[1] = '3') and
   (Magic[2] = '2')  then
 begin
   Result := FPG32;
   byte_size := 4;
   Exit;
 end;

end;

function TFpg.getFormat(var byte_size : Word) :Integer;
begin
 Result := FPG_NULL;

 // Si no es correcta la terminación salimos.
 if not ((MSDOSEnd[0] = 26) and
   (MSDOSEnd[1] = 13) and (MSDOSEnd[2] = 10) and
   (MSDOSEnd[3] = 0)) then
   Exit;

 Result:= getFPGFormat(byte_size);
 if result <> FPG_NULL then
   Exit;

 Result:= getFontFormat(byte_size);

end;

function TFpg.isKnownFormat : Boolean;
var
  byte_size: Word;
begin
  result := getFormat(byte_size) <> FPG_NULL;
end;


function TFpg.loadHeaderFromFile(fileName : String): Boolean;
var
  f : TFileStream;
begin
  Result := False;

  if not FileExistsUTF8(fileName) { *Converted from FileExists*  } then
    Exit;

  try
    f := TFileStream.Create(fileName, fmOpenRead);
  except
    Exit;
  end;

  try
    loadHeaderFromStream(f);
  finally
    f.Free;
  end;

  Result:=True;
end;

procedure TFpg.loadHeaderFromStream(stream : TStream);
begin
  stream.Read(Magic, 3);
  stream.Read(MSDOSEnd, 4);
  stream.Read(Version, 1);
end;

procedure TFpg.saveHeaderToStream(stream : TStream);
begin
  stream.Write(Magic, 3);
  stream.Write(MSDOSEnd, 4);
  stream.Write(Version, 1);
end;


constructor TFpg.Create;
begin
  inherited Create;
  Initialize;
end;


//-----------------------------------------------------------------------------
// CodeExists: Comprueba si existe el código del gráfico en el FPG
//-----------------------------------------------------------------------------

function TFpg.CodeExists(code: word): boolean;
begin
   Result:= (indexOfCode(code) <> 0);
end;

function TFpg.indexOfCode(code: word): word;
var
  i: word;
begin
  indexOfCode := 0;

  if (code < 1) or (code > MAX_NUM_IMAGES) or (Count < 1) then
  begin
    indexOfCode := 0;
    Exit;
  end;

  for i := 1 to Count do
    if images[i].code = code then
    begin
      indexOfCode := i;
      break;
    end;
end;

//-----------------------------------------------------------------------------
// FreeFPG: Libera la memoria reservada e inicializa el FPG
//-----------------------------------------------------------------------------

destructor TFpg.Destroy;
var
  i: word;
begin
  if Count > 0 then
  begin
    for i := 1 to Count do
    begin
        FreeAndNil(images[i]);
    end;
  end;
  inherited Destroy;
end;


//-----------------------------------------------------------------------------
// DeleteWithCode: Elimina un elemento de FPG con el código
//-----------------------------------------------------------------------------

procedure TFpg.DeleteWithCode(code: word);
var
  i,j: word;
begin
  if (Count < 1) then
    Exit;

  for i := 1 to Count  do
  begin
    if Images[i].code = code then
    begin
      FreeAndNil(Images[i]);
      break;
    end;
  end;
  if i < Count then
    for j:=i to Count do
    begin
       Images[j]:=Images[j+1];
    end;
  Count := Count - 1;
end;

function IntToBin ( value: LongInt; digits: integer ): string;
begin
  result := StringOfChar ( '0', digits ) ;
  while value > 0 do begin
    if ( value and 1 ) = 1 then
        result [ digits ] := '1';
    dec ( digits ) ;
    value := value shr 1;
  end;
end;

//-----------------------------------------------------------------------------
// Save: Guarda el FPG actual a disco.
//-----------------------------------------------------------------------------

procedure TFpg.SaveToFile( gFPG: TProgressBar);
var
  f: TFileStream;
  i : Word;
  index : Integer;
  fileOffset : Integer;
  widthForFPG1: integer;
  W,H,WO,HO,HOO,VO,FO : Integer;
  bits_per_pixel: Word;
  comments : TMAPGraphic;
begin

  bits_per_pixel:=getBPP;
  f := TFileStream.Create(source, fmCreate);
  setMagic;
  saveHeaderToStream(f);

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;

  if bits_per_pixel = 8 then
  begin
    for i := 0 to 767 do
      Palette[i] := Palette[i] shr 2;

    f.Write(Palette, 768);
    f.Write(Gamuts, 576);

    for i := 0 to 767 do
      Palette[i] := Palette[i] shl 2;
  end;

  if isFont then
  begin
     f.Write(charset,4);

     fileOffset:=3+4+1+4;
     if bits_per_pixel =8 then
        fileOffset:=fileOffset+768+576;

     if Magic[2] ='x' then
       fileOffset:=fileOffset+ 7*4*256
     else
       fileOffset:=fileOffset+ 4*4*256;

     for i:=1 to 256 do
     begin
       W := 0;
       H := 0;
       WO := 0;
       HO := 0;
       HOO := 0;
       VO := 0;
       FO := 0;
       index := indexOfCode(i);
       if  index > 0 then
       begin
         W := images[index].Width;
         H := images[index].Height;
         if images[index].NCPoints > 1 then
         begin
            WO := images[index].CPoints[0];
            HO := images[index].CPoints[1];
            HOO := images[index].CPoints[2];
            VO := images[index].CPoints[3];
         end else
         begin
            WO:= W;
            HO:= H;
         end;
         FO:=fileOffset;
         if (bits_per_pixel = 1) then begin
           widthForFPG1:= images[index].width div 8;
           if (images[index].width mod 8) <>0 then
              widthForFPG1:= widthForFPG1 +1;
           fileOffset:= fileOffset+ (widthForFPG1 * images[index].height);
         end else begin
           fileOffset:=fileOffset + images[index].width* images[index].height * (bits_per_pixel div 8) ;
         end;
       end;
       f.Write(W,4);
       f.Write(H,4);
       if Magic[2] ='x' then
       begin
         f.Write(WO,4);
         f.Write(HO,4);
         f.Write(HOO,4);
       end;
       f.Write(VO,4);
       f.Write(FO,4);
     end;

     for i := 1 to 256 do
     begin
       index := indexOfCode(i);
       if  index > 0 then
       begin
         images[index].bitsPerPixel:=bits_per_pixel;
         images[index].CDIVFormat:= (FileFormat= FPG16_CDIV);
         images[index].bPalette:=Palette;
         images[index].SaveToStream(f,lmFont);
         gFPG.Position := (index * 100) div Count;
         gFPG.Repaint;
       end;
     end;
  end else begin
    for i := 1 to Count do
    begin
      images[i].bitsPerPixel:=bits_per_pixel;
      images[i].CDIVFormat:= (FileFormat= FPG16_CDIV);
      images[i].bPalette:=Palette;
      images[i].SaveToStream(f,lmFPG);
      gFPG.Position := (i * 100) div Count;
      gFPG.Repaint;
    end;
    comments := TMAPGraphic.Create;
    comments.bitsPerPixel:=bits_per_pixel;
    comments.CDIVFormat:= (FileFormat= FPG16_CDIV);
    comments.code:=1001;
    comments.SetSize(1,1);
    comments.name:=appVersion;
    comments.fpname:=appName;
    comments.SaveToStream(f,lmFPG);
    FreeAndNil(comments);
  end;


  gFPG.Hide;

  f.Free;

  MessageDlg(fmsgInfo,fmsgCorrect,mtInformation,[mbOK],0);

end;

function TFpg.isFont: boolean;
begin
  result:=false;
  if (Magic[2] ='t') Or (Magic[2] ='x') then
     result:= true;
end;

//-----------------------------------------------------------------------------
// LoadFPG: Carga un FPG a memoria.
//-----------------------------------------------------------------------------

function TFpg.LoadFromFile(str: string; gFPG: TProgressBar): boolean;
var
  f: TStream;
  byte_size: Word;
  i : Integer;
  fpgGraphic    :TMAPGraphic;
  tmpInt : integer;
  tmpInt64 : Int64;
  //tmpArr : array [0..575] of byte;
begin
  FileFormat := FPG_NULL;

  Result := False;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
    Exit;

  //if not FPG_Test(str) then
  //begin
  //  zipfile:= TZipFile.Create(frmMain);
  //  zipfile.FileName:=str;
  //  zipfile.Activate;
  //  f:=zipfile.GetFileStream(ExtractFileNameOnly(str),bufflen);
  //  zipfile.Destroy;
  //end else
  begin
    try
      f := TFileStream.Create(str, fmOpenRead);
    except
      Exit;
    end;
  end;

  try
    loadHeaderFromStream(f);
  except
    f.Free;
    Exit;
  end;

  gFPG.Position := 0;
  gFPG.Show;
  gFPG.Repaint;
  byte_size := 0;

  FileFormat := getFormat(byte_size);

  if (FileFormat = FPG_NULL) then
  begin
    MessageDlg(fmsgError,fmsgWrong,mtError,[mbOK],0);
    f.Free;
    Exit;
  end;


  try
    if (FileFormat = FPG8_DIV2) OR  (FileFormat = FNT8)
      OR  (FileFormat = FNX8) then
    begin
      f.Read(palette, 768);
      f.Read(Gamuts, 576);
      //f.Read(tmpArr, 576);

      for i := 0 to 767 do
        palette[i] := palette[i] shl 2;

      loadPalette := True;
      needTable := True;
    end;

    Count := 0;
    appVersion:='';
    appName:='';

    if isFont then
    begin
      f.Read(charset,4);
      for i :=0 to 255 do
      begin
        f.Read(tmpInt,4); //width
        if tmpInt = 0 then
        begin
           f.Read(tmpInt,4); // height
           if Magic[2]='x' then
           begin
             f.Read(tmpInt,4); // widthOffset
             f.Read(tmpInt,4); // hegithOffset
             f.Read(tmpInt,4); // horizontalOffset
           end;
           f.Read(tmpInt,4); // verticalOffset
           f.Read(tmpInt,4); // fileOffset
           continue;
        end;
        fpgGraphic:= TMAPGraphic.Create;
        fpgGraphic.bitsPerPixel:= getBPP;
        fpgGraphic.CDIVFormat:= (FileFormat = FPG16_CDIV);
        fpgGraphic.bpalette:=palette;
        fpgGraphic.Code:=i+1;
        fpgGraphic.fpname:=inttostr(i);
        if charset = 1 then
          fpgGraphic.Name:=''+CP850ToUTF8(chr(i))
        else
          fpgGraphic.Name:=''+ISO_8859_1ToUTF8(chr(i));

        // asignamos primer read.
        fpgGraphic.Width:=tmpInt;
        f.Read(tmpInt,4);
        fpgGraphic.Height:=tmpInt;
        if Magic[2]='x' then
        begin
          f.Read(fpgGraphic.Width_Offset,4);
          f.Read(fpgGraphic.Height_Offset,4);
          f.Read(fpgGraphic.Horizontal_Offset,4);
        end;
        f.Read(fpgGraphic.Vertical_Offset,4);
        f.Read(fpgGraphic.file_Offset,4);
        fpgGraphic.CPoints[0]:=fpgGraphic.Width_Offset;
        fpgGraphic.CPoints[1]:=fpgGraphic.Height_Offset;
        fpgGraphic.CPoints[2]:=fpgGraphic.Horizontal_Offset;
        fpgGraphic.CPoints[3]:=fpgGraphic.Vertical_Offset;
        fpgGraphic.NCPoints:=2;

        Count := Count +1;
        images[Count] := fpgGraphic;


        gFPG.Position := (f.Position * 100) div f.Size;
        gFPG.Repaint;
      end;

      tmpInt64:=f.Position;
      images[Count+1] := nil;

      for i :=1 to 256 do
      begin
        if images[i] = nil then
           break;
        if( (images[i].file_Offset = 0) or
    	(images[i].width  = 0     ) or
    	(images[i].height = 0) ) then continue ;

        f.seek(images[i].file_Offset, soFromBeginning);
        images[i].LoadFromStream(f,lmFont);

        tmpInt64:=tmpInt64+Int64(images[i].width)*images[i].Height * images[i].bitsPerPixel;

        gFPG.Position := (tmpInt64 * 100) div f.Size;
        gFPG.Repaint;
      end;

    end else begin
      while f.Position < f.Size do
      begin
        fpgGraphic:= TMAPGraphic.Create;
        fpgGraphic.bitsPerPixel:= getBPP;
        fpgGraphic.CDIVFormat:= (FileFormat = FPG16_CDIV);
        fpgGraphic.bpalette:=palette;
        fpgGraphic.LoadFromStream(f,lmFPG);

        if fpgGraphic.code=1001 then
        begin
          appVersion:=fpgGraphic.name;
          appName:=fpgGraphic.fpname;
          FreeAndNil(fpgGraphic);
        end else begin
          Count := Count + 1;
          images[Count] := fpgGraphic;
        end;

        gFPG.Position := (f.Position * 100) div f.Size;
        gFPG.Repaint;

      end; // end wile
    end;

    gFPG.Hide;
    Result := True;


  finally
    f.Free;
  end;
end;




procedure TFpg.Sort_Palette;
var
  R, G, B, i, color_index: integer;
begin
  i := 1;

  repeat
    // Buscamos el color que más se parece al anterior
    color_index := findColor(i, palette[(i - 1) * 3],
      palette[((i - 1) * 3) + 1], palette[((i - 1) * 3) + 2]);
    // Intercambio de colores
    R := palette[color_index * 3];
    G := palette[(color_index * 3) + 1];
    B := palette[(color_index * 3) + 2];

    palette[color_index * 3] := palette[i * 3];
    palette[(color_index * 3) + 1] := palette[(i * 3) + 1];
    palette[(color_index * 3) + 2] := palette[(i * 3) + 2];

    palette[i * 3] := R;
    palette[(i * 3) + 1] := G;
    palette[(i * 3) + 2] := B;

    i := i + 1;
  until i >= 255;
end;

procedure TFpg.Create_Table_16_to_8;
var
  i: byte;
  r, g, b: byte;
begin
  for r := 0 to 31 do
    for g := 0 to 63 do
      for b := 0 to 31 do
        table_16_to_8[r, g, b] := 0;

  for i := 0 to 255 do
    table_16_to_8[
      palette[(i * 3)] shr 3,
      palette[(i * 3) + 1] shr 2,
      palette[(i * 3) + 2] shr 3] := i;
end;

procedure TFpg.SaveToFile(index: integer; filename: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(filename, fmCreate);

  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FileFormat = FPG16_CDIV);
  images[index].bPalette:=Palette;
  images[index].SaveToStream(f);

  f.Free;
end;

Procedure TFpg.setMagic;
begin
 version:= 0;
 case FileFormat of
  FPG1:
    Magic := 'f01';
  FPG8_DIV2:
    Magic := 'fpg';
  FPG16:
    Magic := 'f16';
  FPG16_CDIV:
    Magic := 'c16';
  FPG24:
    Magic := 'f24';
  FPG32:
    Magic := 'f32';
  FNX1:
  begin
    Magic := 'fnx';
    version:= 1;
  end;
  FNT8:
  begin
    Magic := 'fnt';
  end;
  FNX8:
  begin
    Magic := 'fnx';
    version:= 8;
  end;
  FNX16:
  begin
    Magic := 'fnx';
    version:= 16;
  end;
  FNX24:
  begin
    Magic := 'fnx';
    version:= 24;
  end;
  FNX32:
  begin
    Magic := 'fnx';
    version:= 32;
  end;
 end;
end;

//-----------------------------------------------------------------------------
// initialize: Inicializa el FPG
//-----------------------------------------------------------------------------

Procedure TFpg.Initialize;
begin
 active   := true;
 Count   := 0;
 lastCode := 0;
 needTable:= false;

 source:='';
 FileFormat:=FPG32;
 Magic:='f32';
 MSDOSEnd[0] := 26;
 MSDOSEnd[1] := 13;
 MSDOSEnd[2] := 10;
 MSDOSEnd[3] := 0;
 Version     := 0;
 appName:='';
 appVersion:='';

end;

//Comprobamos si es un archivo FPG sin comprimir
class function TFPG.test(str: string): boolean;
var
  fpg : TFpg;
begin
  Result := False;
  fpg := TFpg.Create;

  if fpg.loadHeaderFromFile(str) then
     result:= fpg.isKnownFormat;

  FreeAndNil(fpg);
end;


procedure stringToArray(var inarray: array of char; str: string; len: integer);
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

// Añadir index
procedure TFPG.add_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TMapGraphic);
begin
  // Establece el código
  FreeAndNil( images[index]);
  images[index]:= TMAPGraphic.Create;
  images[index].code  := lastcode;

  // Se establecen los datos de la imagen
  images[index].fpname:=FileName;
  images[index].name:=GraphicName;
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;
  images[index].CPointsCount := bmp_src.CPointsCount;
  images[index].cpoints:=bmp_src.CPoints;

  // Se crea la imagen resultante
  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FileFormat= FPG16_CDIV);
  images[index].bPalette:=Palette;
  images[index].CreateBitmap(bmp_src);

end;

// Añadir index
procedure TFPG.replace_bitmap( index : LongInt; FileName, GraphicName : String; var bmp_src: TMapGraphic);
begin
  // Establece el código
  images[index].code  := lastcode;

  // Se establecen los datos de la imagen
  images[index].fpname:=FileName;
  images[index].name:=GraphicName;
  images[index].width  := bmp_src.Width;
  images[index].height := bmp_src.Height;
  if bmp_src.CPointsCount>0 then
  begin
    images[index].CPointsCount:= bmp_src.CPointsCount;
    images[index].cpoints:=bmp_src.CPoints;
  end;

  // Se crea la imagen resultante
  images[index].bitsPerPixel:=getBPP;
  images[index].CDIVFormat:= (FileFormat= FPG16_CDIV);
  images[index].bPalette:=Palette;
  images[index].CreateBitmap(bmp_src);

end;

function TFPG.findColor(index, rc, gc, bc: integer): integer;
var
  dif_colors, temp_dif_colors, i: word;
begin
  dif_colors := 800;
  Result := 0;

  for i := index to 255 do
  begin
    temp_dif_colors :=
      Abs(rc - palette[i * 3]) +
      Abs(gc - palette[(i * 3) + 1]) +
      Abs(bc - palette[(i * 3) + 2]);

    if temp_dif_colors <= dif_colors then
    begin
      Result := i;
      dif_colors := temp_dif_colors;

      if dif_colors = 0 then
        Exit;
    end;

  end;

end;

procedure TFPG.setDefaultGamut;
var
 i,j : Byte;
begin
  FillByte(Gamuts,576,0);
  for i:=0 to 15 do
  begin
      gamuts[i].numcolors:=16;
      //gamuts[i].colors[0]:=(i*16);
      for j:=0 to gamuts[i].numcolors -1 do
      begin
        gamuts[i].colors[j]:=(i*gamuts[i].numcolors)+j;
      end;
  end;
end;

//initialization
//  {$I fpgres.lrs}

end.