unit uUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function ExtractFileNameWithoutExt(const FileName: string): string;

implementation

function ExtractFileNameWithoutExt(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

end.
