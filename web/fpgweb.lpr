program fpgweb;

{$mode objfpc}

{ Lazarus Web Browser Application (pas2js).
  Compile this project in Lazarus, or run: make web }

uses
  JS, SysUtils, Web, ufpgformat, uviewer;

var
  Viewer: TViewer;

begin
  Viewer := TViewer.Create;
  Viewer.Start;
end.
