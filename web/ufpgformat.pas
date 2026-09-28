unit ufpgformat;

{$mode objfpc}

{ FPG, FNT and MAP reader for the pas2js browser project.
  Pixel layout matches src/formats/uFPG/uFPG.pas and
  src/editors/map/uMap/umapgraphic.pas. }

interface

uses
  JS, SysUtils;

type
  TCtrlPoint = record
    X, Y: Word;
  end;

  TFenixImage = class
    Code: LongWord;
    Name: string;
    FPName: string;
    Width, Height: Longint;
    FileOffset: Longint;
    Points: array of TCtrlPoint;
    RGBA: TJSUint8ClampedArray;
  end;

  TFenixDoc = class
    Magic: string;
    LabelText: string;
    Bpp: Integer;
    Palette: TJSUint8Array;
    CreatorName: string;
    CreatorVersion: string;
    Images: array of TFenixImage;
  end;

function ParseFenix(Data: TJSUint8Array; const FileName: string): TFenixDoc;
function BuildDemo: TJSUint8Array;
procedure CheckDemo;

implementation

const
  MaxEdge = 8192;
  MaxPoints = 1024;

type
  TReader = class
    Data: TJSUint8Array;
    Pos: NativeInt;
    procedure Need(N: NativeInt);
    procedure Seek(APos: NativeInt);
    function Remaining: NativeInt;
    function U8: Byte;
    function U16: Word;
    function U32: LongWord;
    function I32: Longint;
    procedure Skip(N: NativeInt);
    function FixedString(N: NativeInt): string;
  end;

  TByteSink = class
    Items: TJSArray;
    constructor Create;
    procedure B(V: Integer);
    procedure W16(V: Integer);
    procedure W32(V: LongWord);
    procedure Zeros(N: Integer);
    procedure Text(const S: string; Len: Integer);
    function Finish: TJSUint8Array;
  end;

procedure TReader.Need(N: NativeInt);
begin
  if Pos + N > Data.length then
    raise Exception.Create('Arquivo terminou antes do esperado.');
end;

procedure TReader.Seek(APos: NativeInt);
begin
  if (APos < 0) or (APos > Data.length) then
    raise Exception.Create('Deslocamento inválido no arquivo.');
  Pos := APos;
end;

function TReader.Remaining: NativeInt;
begin
  Result := Data.length - Pos;
end;

function TReader.U8: Byte;
begin
  Need(1);
  Result := Data[Pos];
  Inc(Pos);
end;

function TReader.U16: Word;
begin
  Need(2);
  Result := Data[Pos] + Data[Pos + 1] * 256;
  Inc(Pos, 2);
end;

function TReader.U32: LongWord;
begin
  Need(4);
  Result := Data[Pos] + Data[Pos + 1] * 256 + Data[Pos + 2] * 65536 +
    Data[Pos + 3] * 16777216;
  Inc(Pos, 4);
end;

function TReader.I32: Longint;
begin
  Result := Longint(U32);
end;

procedure TReader.Skip(N: NativeInt);
begin
  Need(N);
  Inc(Pos, N);
end;

function TReader.FixedString(N: NativeInt): string;
var
  I, Last: NativeInt;
begin
  Need(N);
  Result := '';
  Last := Pos + N;
  I := Pos;
  while I < Last do
  begin
    if Data[I] = 0 then
      Break;
    Result := Result + Chr(Data[I]);
    Inc(I);
  end;
  Pos := Last;
  while (Result <> '') and (Result[Length(Result)] = ' ') do
    Delete(Result, Length(Result), 1);
end;

constructor TByteSink.Create;
begin
  Items := TJSArray.new;
end;

procedure TByteSink.B(V: Integer);
begin
  Items.push(V and 255);
end;

procedure TByteSink.W16(V: Integer);
begin
  B(V);
  B(V shr 8);
end;

procedure TByteSink.W32(V: LongWord);
begin
  B(V);
  B(V shr 8);
  B(V shr 16);
  B(V shr 24);
end;

procedure TByteSink.Zeros(N: Integer);
var
  I: Integer;
begin
  for I := 1 to N do
    B(0);
end;

procedure TByteSink.Text(const S: string; Len: Integer);
var
  I: Integer;
begin
  for I := 1 to Len do
    if I <= Length(S) then
      B(Ord(S[I]))
    else
      B(0);
end;

function TByteSink.Finish: TJSUint8Array;
begin
  Result := TJSUint8Array.from(Items);
end;

function ExtOf(const FileName: string): string;
var
  I: Integer;
  Base: string;
begin
  Base := FileName;
  I := Length(Base);
  while (I > 0) and (Base[I] <> '.') and (Base[I] <> '/') and (Base[I] <> '\') do
    Dec(I);
  if (I > 0) and (Base[I] = '.') then
    Result := LowerCase(Copy(Base, I + 1, MaxInt))
  else
    Result := '';
end;

function MagicIs(R: TReader; const S: string): Boolean;
begin
  Result := (R.Data[0] = Ord(S[1])) and (R.Data[1] = Ord(S[2])) and (R.Data[2] = Ord(S[3]));
end;

procedure AssertSize(W, H: Longint);
begin
  if (W < 0) or (H < 0) or (W > MaxEdge) or (H > MaxEdge) then
    raise Exception.Create('Tamanho de imagem inválido: ' + IntToStr(W) + '×' + IntToStr(H) + '.');
end;

function ExpandPalette(R: TReader): TJSUint8Array;
var
  I: Integer;
begin
  Result := TJSUint8Array.new(768);
  for I := 0 to 767 do
    Result[I] := (R.U8 shl 2) and 255;
  R.Skip(576);
end;

procedure Rgb565(Lo, Hi: Byte; out High5, Green, Low5: Integer);
begin
  High5 := Hi and $F8;
  Green := ((Hi shl 5) or ((Lo and $E0) shr 3)) and $FF;
  Low5 := (Lo shl 3) and $FF;
end;

function ReadPoints(R: TReader; Wide: Boolean): TCtrlPointArray;
var
  N, I: Integer;
begin
  if Wide then
    N := Integer(R.U32)
  else
    N := R.U16;
  if N > MaxPoints then
    raise Exception.Create('Pontos de controle demais.');
  SetLength(Result, N);
  for I := 0 to N - 1 do
  begin
    Result[I].X := R.U16;
    Result[I].Y := R.U16;
  end;
end;

procedure DecodePixels(R: TReader; W, H, Bpp: Integer; Cdiv: Boolean;
  Palette: TJSUint8Array; RGBA: TJSUint8ClampedArray);
var
  X, Y, J, I, Z, LenLine, Index, O: Integer;
  Lo, Hi, LineBit, B, G, Red: Byte;
  High5, Green, Low5: Integer;
begin
  if (W = 0) or (H = 0) then
    Exit;
  if Bpp = 1 then
  begin
    LenLine := (W + 7) div 8;
    for Y := 0 to H - 1 do
      for J := 0 to LenLine - 1 do
      begin
        LineBit := R.U8;
        for I := 0 to 7 do
        begin
          Z := J * 8 + I;
          if Z >= W then
            Break;
          O := (Y * W + Z) * 4;
          if (LineBit and 128) = 128 then
          begin
            RGBA[O] := 255;
            RGBA[O + 1] := 255;
            RGBA[O + 2] := 255;
            RGBA[O + 3] := 255;
          end;
          LineBit := (LineBit shl 1) and 255;
        end;
      end;
    Exit;
  end;

  for Y := 0 to H - 1 do
    for X := 0 to W - 1 do
    begin
      O := (Y * W + X) * 4;
      if Bpp = 8 then
      begin
        Index := R.U8;
        RGBA[O] := Palette[Index * 3];
        RGBA[O + 1] := Palette[Index * 3 + 1];
        RGBA[O + 2] := Palette[Index * 3 + 2];
        if Index = 0 then
          RGBA[O + 3] := 0
        else
          RGBA[O + 3] := 255;
      end
      else if Bpp = 16 then
      begin
        Lo := R.U8;
        Hi := R.U8;
        Rgb565(Lo, Hi, High5, Green, Low5);
        if Cdiv then
        begin
          RGBA[O] := Low5;
          RGBA[O + 1] := Green;
          RGBA[O + 2] := High5;
          if (High5 = $F8) and (Green = 0) and (Low5 = $F8) then
            RGBA[O + 3] := 0
          else
            RGBA[O + 3] := 255;
        end
        else
        begin
          RGBA[O] := High5;
          RGBA[O + 1] := Green;
          RGBA[O + 2] := Low5;
          if Lo + Hi = 0 then
            RGBA[O + 3] := 0
          else
            RGBA[O + 3] := 255;
        end;
      end
      else if Bpp = 24 then
      begin
        B := R.U8;
        G := R.U8;
        Red := R.U8;
        RGBA[O] := Red;
        RGBA[O + 1] := G;
        RGBA[O + 2] := B;
        if Red + G + B = 0 then
          RGBA[O + 3] := 0
        else
          RGBA[O + 3] := 255;
      end
      else if Bpp = 32 then
      begin
        B := R.U8;
        G := R.U8;
        Red := R.U8;
        RGBA[O] := Red;
        RGBA[O + 1] := G;
        RGBA[O + 2] := B;
        RGBA[O + 3] := R.U8;
      end
      else
        raise Exception.Create('Profundidade não suportada: ' + IntToStr(Bpp) + ' bits.');
    end;
end;

function NewImage(W, H: Longint): TFenixImage;
begin
  AssertSize(W, H);
  Result := TFenixImage.Create;
  Result.Width := W;
  Result.Height := H;
  Result.RGBA := TJSUint8ClampedArray.new(W * H * 4);
end;

procedure AddImage(Doc: TFenixDoc; Img: TFenixImage);
begin
  SetLength(Doc.Images, Length(Doc.Images) + 1);
  Doc.Images[High(Doc.Images)] := Img;
end;

function Describe(const Magic: string; out Bpp: Integer; out Cdiv: Boolean;
  out BitLabel: string): Boolean;
begin
  Cdiv := False;
  Result := True;
  if (Magic = 'f01') or (Magic = 'm01') then
  begin
    Bpp := 1;
    BitLabel := '1 bit';
  end
  else if (Magic = 'fpg') or (Magic = 'map') or (Magic = 'fnt') then
  begin
    Bpp := 8;
    BitLabel := '8 bits';
  end
  else if (Magic = 'f16') or (Magic = 'm16') then
  begin
    Bpp := 16;
    BitLabel := '16 bits (Fenix/BennuGD)';
  end
  else if Magic = 'c16' then
  begin
    Bpp := 16;
    Cdiv := True;
    BitLabel := '16 bits (CDIV)';
  end
  else if (Magic = 'f24') or (Magic = 'm24') then
  begin
    Bpp := 24;
    BitLabel := '24 bits';
  end
  else if (Magic = 'f32') or (Magic = 'm32') then
  begin
    Bpp := 32;
    BitLabel := '32 bits';
  end
  else
    Result := False;
end;

procedure ParseFont(R: TReader; Doc: TFenixDoc; const Magic: string; Version: Byte);
var
  Bpp, I, W, H, FileOffset: Integer;
  Cdiv: Boolean;
  BitLabel: string;
  Glyphs: array of TFenixImage;
  Img: TFenixImage;
  WidthOff, HeightOff, HorizOff, VertOff: Longint;
begin
  if Magic = 'fnt' then
  begin
    Bpp := 8;
    BitLabel := 'FNT 8 bits';
  end
  else if Magic = 'fnx' then
  begin
    if (Version <> 1) and (Version <> 8) and (Version <> 16) and
      (Version <> 24) and (Version <> 32) then
      raise Exception.Create('FNT Fenix com profundidade desconhecida: ' + IntToStr(Version) + '.');
    Bpp := Version;
    BitLabel := 'FNT ' + IntToStr(Version) + ' bits';
  end
  else
    raise Exception.Create('Fonte não reconhecida.');
  Cdiv := False;
  Doc.Bpp := Bpp;
  Doc.LabelText := BitLabel;
  if Bpp = 8 then
    Doc.Palette := ExpandPalette(R);
  R.Skip(4);
  SetLength(Glyphs, 0);
  for I := 0 to 255 do
  begin
    W := R.I32;
    if W = 0 then
    begin
      R.I32;
      if Magic = 'fnx' then
      begin
        R.I32;
        R.I32;
        R.I32;
      end;
      R.I32;
      R.I32;
      Continue;
    end;
    H := R.I32;
    WidthOff := 0;
    HeightOff := 0;
    HorizOff := 0;
    if Magic = 'fnx' then
    begin
      WidthOff := R.I32;
      HeightOff := R.I32;
      HorizOff := R.I32;
    end;
    VertOff := R.I32;
    FileOffset := R.I32;
    Img := NewImage(W, H);
    Img.Code := I + 1;
    if I >= 32 then
      Img.Name := Chr(I);
    Img.FPName := IntToStr(I);
    Img.FileOffset := FileOffset;
    if (WidthOff <> 0) or (HeightOff <> 0) then
    begin
      SetLength(Img.Points, Length(Img.Points) + 1);
      Img.Points[High(Img.Points)].X := Word(WidthOff);
      Img.Points[High(Img.Points)].Y := Word(HeightOff);
    end;
    if (HorizOff <> 0) or (VertOff <> 0) then
    begin
      SetLength(Img.Points, Length(Img.Points) + 1);
      Img.Points[High(Img.Points)].X := Word(HorizOff);
      Img.Points[High(Img.Points)].Y := Word(VertOff);
    end;
    SetLength(Glyphs, Length(Glyphs) + 1);
    Glyphs[High(Glyphs)] := Img;
  end;
  for I := 0 to High(Glyphs) do
  begin
    Img := Glyphs[I];
    FileOffset := Img.FileOffset;
    if (FileOffset = 0) or (Img.Width = 0) or (Img.Height = 0) then
      Continue;
    R.Seek(FileOffset);
    DecodePixels(R, Img.Width, Img.Height, Bpp, Cdiv, Doc.Palette, Img.RGBA);
    AddImage(Doc, Img);
  end;
end;

procedure ParseMap(R: TReader; Doc: TFenixDoc; const Magic: string);
var
  Bpp: Integer;
  Cdiv: Boolean;
  BitLabel: string;
  Img: TFenixImage;
begin
  if not Describe(Magic, Bpp, Cdiv, BitLabel) then
    raise Exception.Create('MAP não reconhecido (' + Magic + ').');
  if (Copy(Magic, 1, 1) <> 'm') and (Magic <> 'c16') then
    raise Exception.Create('MAP não reconhecido (' + Magic + ').');
  Doc.Bpp := Bpp;
  Doc.LabelText := 'MAP ' + BitLabel;
  Img := NewImage(R.U16, R.U16);
  Img.Code := R.U32;
  Img.Name := R.FixedString(32);
  if Bpp = 8 then
    Doc.Palette := ExpandPalette(R);
  Img.Points := ReadPoints(R, False);
  DecodePixels(R, Img.Width, Img.Height, Bpp, Cdiv, Doc.Palette, Img.RGBA);
  AddImage(Doc, Img);
end;

procedure ParseFpg(R: TReader; Doc: TFenixDoc; const Magic: string);
var
  Bpp: Integer;
  Cdiv: Boolean;
  BitLabel: string;
  Img: TFenixImage;
  Code: LongWord;
begin
  if not Describe(Magic, Bpp, Cdiv, BitLabel) then
    raise Exception.Create('FPG não reconhecido (' + Magic + ').');
  Doc.Bpp := Bpp;
  Doc.LabelText := 'FPG ' + BitLabel;
  if Bpp = 8 then
    Doc.Palette := ExpandPalette(R);
  while R.Pos < R.Data.length do
  begin
    if R.Remaining < 64 then
      raise Exception.Create('Registro de imagem incompleto.');
    Code := R.U32;
    R.U32;
    Img := TFenixImage.Create;
    Img.Name := R.FixedString(32);
    Img.FPName := R.FixedString(12);
    Img.Width := R.I32;
    Img.Height := R.I32;
    AssertSize(Img.Width, Img.Height);
    Img.Points := ReadPoints(R, True);
    Img.RGBA := TJSUint8ClampedArray.new(Img.Width * Img.Height * 4);
    DecodePixels(R, Img.Width, Img.Height, Bpp, Cdiv, Doc.Palette, Img.RGBA);
    if Code = 1001 then
    begin
      Doc.CreatorName := Img.FPName;
      Doc.CreatorVersion := Img.Name;
      Img.Free;
    end
    else
    begin
      Img.Code := Code;
      AddImage(Doc, Img);
      if Length(Doc.Images) > 999 then
        raise Exception.Create('FPG com imagens demais.');
    end;
  end;
end;

function ParseFenix(Data: TJSUint8Array; const FileName: string): TFenixDoc;
var
  R: TReader;
  Magic, Ext: string;
  Version: Byte;
begin
  if Data.length < 8 then
    raise Exception.Create('Arquivo curto demais.');
  R := TReader.Create;
  try
    R.Data := Data;
    R.Pos := 0;
    Magic := Chr(R.U8) + Chr(R.U8) + Chr(R.U8);
    if (R.U8 <> 26) or (R.U8 <> 13) or (R.U8 <> 10) or (R.U8 <> 0) then
      raise Exception.Create('Este arquivo não é um FPG, FNT ou MAP.');
    Version := R.U8;
    Ext := ExtOf(FileName);
    Result := TFenixDoc.Create;
    Result.Magic := Magic;
    if (Magic = 'fnt') or (Magic = 'fnx') then
      ParseFont(R, Result, Magic, Version)
    else if (Copy(Magic, 1, 1) = 'm') or ((Magic = 'c16') and (Ext = 'map')) then
      ParseMap(R, Result, Magic)
    else if (Magic = 'f01') or (Magic = 'fpg') or (Magic = 'f16') or (Magic = 'c16') or
      (Magic = 'f24') or (Magic = 'f32') then
      ParseFpg(R, Result, Magic)
    else
      raise Exception.Create('Formato não reconhecido (' + Magic + ').');
  finally
    R.Free;
  end;
end;

procedure Header(Sink: TByteSink; const Magic: string);
begin
  Sink.B(Ord(Magic[1]));
  Sink.B(Ord(Magic[2]));
  Sink.B(Ord(Magic[3]));
  Sink.B(26);
  Sink.B(13);
  Sink.B(10);
  Sink.B(0);
  Sink.B(0);
end;

procedure Palette6(Sink: TByteSink; const Colors: array of Byte);
var
  I: Integer;
begin
  for I := 0 to 767 do
    if I < Length(Colors) then
      Sink.B(Colors[I])
    else
      Sink.B(0);
  Sink.Zeros(576);
end;

procedure FpgGraphic(Sink: TByteSink; Code: LongWord; const Name, FPName: string;
  W, H: Integer; const Points: array of Word; const Pixels: array of Byte);
var
  I, PointCount: Integer;
begin
  PointCount := Length(Points) div 2;
  Sink.W32(Code);
  Sink.W32(64 + PointCount * 4 + Length(Pixels));
  Sink.Text(Name, 32);
  Sink.Text(FPName, 12);
  Sink.W32(W);
  Sink.W32(H);
  Sink.W32(PointCount);
  for I := 0 to High(Points) do
    Sink.W16(Points[I]);
  for I := 0 to High(Pixels) do
    Sink.B(Pixels[I]);
end;

function BuildDemo: TJSUint8Array;
const
  Face =
    '00222200' +
    '02011020' +
    '02111120' +
    '02111120' +
    '02011020' +
    '00222200' +
    '03000030' +
    '33000033';
var
  Sink: TByteSink;
  FacePx, CoinPx, MarkPx: array of Byte;
  Center, NoPoints: array of Word;
  I: Integer;
begin
  Sink := TByteSink.Create;
  try
    Header(Sink, 'fpg');
    Palette6(Sink, [0, 0, 0, 50, 8, 8, 0, 50, 10, 50, 40, 8]);
    SetLength(FacePx, 64);
    for I := 1 to 64 do
      FacePx[I - 1] := Ord(Face[I]) - Ord('0');
    SetLength(Center, 2);
    Center[0] := 4;
    Center[1] := 4;
    FpgGraphic(Sink, 1, 'hero', 'hero', 8, 8, Center, FacePx);
    SetLength(CoinPx, 16);
    for I := 0 to 15 do
      CoinPx[I] := 3;
    FpgGraphic(Sink, 10, 'coin', 'coin', 4, 4, NoPoints, CoinPx);
    SetLength(MarkPx, 1);
    MarkPx[0] := 0;
    FpgGraphic(Sink, 1001, 'web', 'fpg-editor', 1, 1, NoPoints, MarkPx);
    Result := Sink.Finish;
  finally
    Sink.Free;
  end;
end;

function Pix(Img: TFenixImage; X, Y: Integer): string;
var
  O: Integer;
begin
  O := (Y * Img.Width + X) * 4;
  Result := IntToStr(Img.RGBA[O]) + ',' + IntToStr(Img.RGBA[O + 1]) + ',' +
    IntToStr(Img.RGBA[O + 2]) + ',' + IntToStr(Img.RGBA[O + 3]);
end;

procedure Expect(const Got, Want, What: string);
begin
  if Got <> Want then
    raise Exception.Create(What + ': esperado ' + Want + ', obteve ' + Got);
end;

procedure CheckDemo;
var
  Doc: TFenixDoc;
  Sink: TByteSink;
  Img: TFenixImage;
  NoPoints: array of Word;
  RedPx, Px32, BitPx: array of Byte;
begin
  Doc := ParseFenix(BuildDemo, 'demo.fpg');
  if Length(Doc.Images) <> 2 then
    raise Exception.Create('demo deveria ter 2 imagens');
  if Doc.CreatorName <> 'fpg-editor' then
    raise Exception.Create('registro 1001 não foi separado');
  Expect(Pix(Doc.Images[0], 1, 1), '0,200,40,255', 'hero verde');
  Expect(Pix(Doc.Images[0], 2, 1), '0,0,0,0', 'hero transparente');
  Expect(Pix(Doc.Images[0], 3, 1), '200,32,32,255', 'hero vermelho');
  if Doc.Images[0].Points[0].X <> 4 then
    raise Exception.Create('ponto de controle');

  Sink := TByteSink.Create;
  try
    Header(Sink, 'f16');
    SetLength(RedPx, 2);
    RedPx[0] := 0;
    RedPx[1] := $F8;
    FpgGraphic(Sink, 7, 'red', '', 1, 1, NoPoints, RedPx);
    Img := ParseFenix(Sink.Finish, 'red.fpg').Images[0];
    Expect(Pix(Img, 0, 0), '248,0,0,255', 'f16 vermelho');
  finally
    Sink.Free;
  end;

  Sink := TByteSink.Create;
  try
    Header(Sink, 'f32');
    SetLength(Px32, 4);
    Px32[0] := 10;
    Px32[1] := 20;
    Px32[2] := 30;
    Px32[3] := 128;
    FpgGraphic(Sink, 2, 'px', '', 1, 1, NoPoints, Px32);
    Img := ParseFenix(Sink.Finish, 'px.fpg').Images[0];
    Expect(Pix(Img, 0, 0), '30,20,10,128', 'f32');
  finally
    Sink.Free;
  end;

  Sink := TByteSink.Create;
  try
    Header(Sink, 'f01');
    SetLength(BitPx, 1);
    BitPx[0] := $80;
    FpgGraphic(Sink, 1, 'bit', '', 8, 1, NoPoints, BitPx);
    Img := ParseFenix(Sink.Finish, 'bit.fpg').Images[0];
    Expect(Pix(Img, 0, 0), '255,255,255,255', '1 bit ligado');
    Expect(Pix(Img, 1, 0), '0,0,0,0', '1 bit desligado');
  finally
    Sink.Free;
  end;
end;

end.
