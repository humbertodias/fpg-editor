program fpgcheck;

{$mode objfpc}

uses
  JS, SysUtils, ComCtrls, ufpgformat, uStreamIO, uMAPGraphic, uFPG;

procedure Expect(const Got, Want, What: string);
begin
  if Got <> Want then
    raise Exception.Create(What + ': esperado ' + Want + ', obteve ' + Got);
end;

procedure LoadDemo;
var
  Demo: TJSUint8Array;
  Raw: array of Byte;
  I, O: Integer;
  Doc: TFpg;
  Bar: TProgressBar;
  Img: TMAPGraphic;
begin
  Demo := BuildDemo;
  SetLength(Raw, Demo.length);
  for I := 0 to Demo.length - 1 do
    Raw[I] := Demo[I];
  RegisterBrowserFile('demo.fpg', Raw);
  Bar := TProgressBar.Create;
  Doc := TFpg.Create;
  try
    if not Doc.LoadFromFile('demo.fpg', Bar) then
      raise Exception.Create('TFpg.LoadFromFile falhou');
    if Doc.Count <> 2 then
      raise Exception.Create('demo deveria ter 2 imagens');
    if Doc.appName <> 'fpg-editor' then
      raise Exception.Create('registro 1001 não foi separado');
    Img := Doc.images[1];
    O := (1 * Img.Width + 1) * 4;
    Expect(IntToStr(Img.PasPixels[O]) + ',' + IntToStr(Img.PasPixels[O + 1]) + ',' +
      IntToStr(Img.PasPixels[O + 2]) + ',' + IntToStr(Img.PasPixels[O + 3]),
      '40,200,0,255', 'hero verde');
    if Img.CPoints[0] <> 4 then
      raise Exception.Create('ponto de controle');
  finally
    Bar.Free;
    Doc.Free;
  end;
end;

begin
  LoadDemo;
  writeln('ok');
end.
