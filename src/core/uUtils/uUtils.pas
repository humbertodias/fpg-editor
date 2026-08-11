unit uUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function ExtractFileNameWithoutExt(const FileName: string): string;
{ Writable per-user config dir (macOS Application Support, Linux ~/.config, etc.). }
function GetUserConfigDir: string;
{ App resources: Contents/Resources inside a macOS .app, else directory of the exe. }
function GetAppResourceDir: string;

implementation

function ExtractFileNameWithoutExt(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

function GetUserConfigDir: string;
begin
  Result := ExcludeTrailingPathDelimiter(GetAppConfigDir(False));
end;

function GetAppResourceDir: string;
var
  exeDir, resources: string;
begin
  exeDir := ExcludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
  {$IFDEF DARWIN}
  { .../My.app/Contents/MacOS -> .../My.app/Contents/Resources }
  if SameText(ExtractFileName(exeDir), 'MacOS') then
  begin
    resources := ExpandFileName(exeDir + PathDelim + '..' + PathDelim + 'Resources');
    if DirectoryExists(resources) then
      Exit(ExcludeTrailingPathDelimiter(resources));
  end;
  {$ENDIF}
  Result := exeDir;
end;

end.
