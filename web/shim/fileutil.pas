unit FileUtil;

{$mode objfpc}

interface

uses
  uStreamIO;

function FileExists(const FileName: string): Boolean;

implementation

function FileExists(const FileName: string): Boolean;
begin
  Result := BrowserFileExists(FileName);
end;

end.
