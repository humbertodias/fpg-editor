unit uCopyPalette;

interface

uses
 LCLIntf, LCLType, SysUtils, Forms, Classes, dialogs,
     Graphics, FileUtil, IntfGraphics,
     uFrmMessageBox, uLanguage, uColor16bits;

function CopyPalette(Source: hPalette): hPalette;

implementation

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
end.

