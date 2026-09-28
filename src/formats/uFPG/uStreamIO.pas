unit uStreamIO;

{$mode objfpc}{$H+}

{ Byte-level stream helpers shared by the Qt editor and the pas2js viewer.
  FPC reads with the untyped TStream.Read. pas2js only has typed byte reads. }

interface

uses
  Classes, SysUtils;

procedure ReadBytesN(S: TStream; var Buf: array of Byte; Count: Integer);
procedure ReadChars(S: TStream; var Buf: array of Char);
procedure ReadWordBytes(S: TStream; var Buf: array of Word; ByteCount: Integer);
function ReadU8(S: TStream): Byte;
function ReadU16(S: TStream): Word;
function ReadI32(S: TStream): LongInt;
function ReadU32(S: TStream): LongWord;
function OpenRead(const FileName: string): TStream;
function BrowserFileExists(const FileName: string): Boolean;
procedure RegisterBrowserFile(const FileName: string; const Data: array of Byte);

implementation

function ReadU8(S: TStream): Byte;
var
  B: array[0..0] of Byte;
begin
{$ifdef pas2js}
  ReadBytesN(S, B, 1);
  Result := B[0];
{$else}
  S.Read(Result, 1);
{$endif}
end;

function ReadU16(S: TStream): Word;
var
  B: array[0..1] of Byte;
begin
{$ifdef pas2js}
  ReadBytesN(S, B, 2);
  Result := B[0] + B[1] * 256;
{$else}
  S.Read(Result, 2);
{$endif}
end;

function ReadU32(S: TStream): LongWord;
var
  B: array[0..3] of Byte;
begin
{$ifdef pas2js}
  ReadBytesN(S, B, 4);
  Result := B[0] + B[1] * 256 + B[2] * 65536 + B[3] * 16777216;
{$else}
  S.Read(Result, 4);
{$endif}
end;

function ReadI32(S: TStream): LongInt;
var
  U: LongWord;
begin
{$ifdef pas2js}
  U := ReadU32(S);
  if U >= 2147483648 then
    Result := LongInt(U - 4294967296)
  else
    Result := LongInt(U);
{$else}
  S.Read(Result, 4);
{$endif}
end;

procedure ReadBytesN(S: TStream; var Buf: array of Byte; Count: Integer);
{$ifdef pas2js}
var
  B: TBytes;
  I: Integer;
{$endif}
begin
  if Count <= 0 then
    Exit;
{$ifdef pas2js}
  SetLength(B, Count);
  S.Read(B, Count);
  for I := 0 to Count - 1 do
    Buf[I] := B[I];
{$else}
  S.Read(Buf[0], Count);
{$endif}
end;

procedure ReadChars(S: TStream; var Buf: array of Char);
{$ifdef pas2js}
var
  B: TBytes;
  I, N: Integer;
{$endif}
begin
{$ifdef pas2js}
  N := Length(Buf);
  if N <= 0 then
    Exit;
  SetLength(B, N);
  S.Read(B, N);
  for I := 0 to N - 1 do
    Buf[I] := Chr(B[I]);
{$else}
  if Length(Buf) > 0 then
    S.Read(Buf[0], Length(Buf));
{$endif}
end;

procedure ReadWordBytes(S: TStream; var Buf: array of Word; ByteCount: Integer);
{$ifdef pas2js}
var
  B: TBytes;
  I, N: Integer;
{$endif}
begin
  if ByteCount <= 0 then
    Exit;
{$ifdef pas2js}
  SetLength(B, ByteCount);
  S.Read(B, ByteCount);
  N := ByteCount div 2;
  for I := 0 to N - 1 do
    Buf[I] := B[I * 2] + B[I * 2 + 1] * 256;
{$else}
  S.Read(Buf[0], ByteCount);
{$endif}
end;

type
  TBrowserFile = record
    Name: string;
    Data: TBytes;
  end;

var
  BrowserFiles: array of TBrowserFile;

function FindBrowserFile(const FileName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(BrowserFiles) do
    if BrowserFiles[I].Name = FileName then
      Exit(I);
end;

function BrowserFileExists(const FileName: string): Boolean;
begin
  Result := FindBrowserFile(FileName) >= 0;
end;

procedure RegisterBrowserFile(const FileName: string; const Data: array of Byte);
var
  I, At: Integer;
  Bytes: TBytes;
begin
  SetLength(Bytes, Length(Data));
  for I := 0 to High(Data) do
    Bytes[I] := Data[I];
  At := FindBrowserFile(FileName);
  if At < 0 then
  begin
    At := Length(BrowserFiles);
    SetLength(BrowserFiles, At + 1);
    BrowserFiles[At].Name := FileName;
  end;
  BrowserFiles[At].Data := Bytes;
end;

function OpenRead(const FileName: string): TStream;
{$ifdef pas2js}
var
  At: Integer;
{$endif}
begin
{$ifdef pas2js}
  At := FindBrowserFile(FileName);
  if At < 0 then
    raise EStreamError.Create('Arquivo não encontrado.');
  Result := TBytesStream.Create(BrowserFiles[At].Data);
  Result.Position := 0;
{$else}
  Result := TFileStream.Create(FileName, fmOpenRead);
{$endif}
end;

end.
