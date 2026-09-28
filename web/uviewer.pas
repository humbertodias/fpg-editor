unit uviewer;

{$mode objfpc}

interface

uses
  JS, SysUtils, Web, ComCtrls, Dialogs, uStreamIO, uFPG, uMAPGraphic, ufpgformat;

type
  TViewer = class
  private
    FDoc: TFpg;
    FName: string;
    FIndex: Integer;
    FZoom: Integer;
    FStatus, FError, FDetail, FHint: TJSHTMLElement;
    FList, FPalette, FPaletteWrap, FStage: TJSHTMLElement;
    FView: TJSHTMLCanvasElement;
    FZoomLabel: TJSHTMLElement;
    FPoints: TJSHTMLInputElement;
    FExportPng, FExportSheet: TJSHTMLElement;
    function OnFile(Event: TEventListenerEvent): Boolean;
    function OnSample(Event: TEventListenerEvent): Boolean;
    function OnLoaded(Event: TEventListenerEvent): Boolean;
    procedure OnDragOver(Event: TJSEvent);
    procedure OnDrop(Event: TJSEvent);
    function OnZoomOut(Event: TEventListenerEvent): Boolean;
    function OnZoomIn(Event: TEventListenerEvent): Boolean;
    function OnPoints(Event: TEventListenerEvent): Boolean;
    function OnExportPng(Event: TEventListenerEvent): Boolean;
    function OnExportSheet(Event: TEventListenerEvent): Boolean;
    function OnListClick(Event: TEventListenerEvent): Boolean;
    procedure OnKey(Event: TJSEvent);
    procedure ReadFile(AFile: TJSHTMLFile);
    procedure OpenBuffer(Buf: TJSArrayBuffer; const AName: string);
    procedure ShowError(const Msg: string);
    procedure ClearError;
    procedure Render;
    procedure Paint;
    function Current: TMAPGraphic;
    procedure Download(Canvas: TJSHTMLCanvasElement; const AName: string);
    function El(const Tag, ClassName: string): TJSHTMLElement;
    function Btn(const Caption, ClassName: string; Handler: TJSEventHandler): TJSHTMLElement;
  public
    procedure Start;
  end;

implementation

uses
  uimagedata;

function BitmapPixels(Img: TMAPGraphic): TJSUint8ClampedArray;
var
  N, I, O: Integer;
begin
  N := Img.Width * Img.Height;
  Result := TJSUint8ClampedArray.new(N * 4);
  if (N <= 0) or (Length(Img.PasPixels) < N * 4) then
    Exit;
  for I := 0 to N - 1 do
  begin
    O := I * 4;
    Result[O] := Img.PasPixels[O + 2];
    Result[O + 1] := Img.PasPixels[O + 1];
    Result[O + 2] := Img.PasPixels[O];
    Result[O + 3] := Img.PasPixels[O + 3];
  end;
end;

function DocLabel(Doc: TFpg): string;
begin
  Result := Doc.Magic[0];
  Result := Result + Doc.Magic[1];
  Result := Result + Doc.Magic[2];
  Result := Result + ' ' + IntToStr(Doc.getBPP) + ' bits';
end;

const
  Zooms: array[0..7] of Integer = (1, 2, 3, 4, 6, 8, 12, 16);

procedure Click(Target: TJSElement);
begin
  asm
    Target.click();
  end;
end;

function Pad3(N: LongWord): string;
begin
  Result := IntToStr(N);
  while Length(Result) < 3 do
    Result := '0' + Result;
end;

function TViewer.El(const Tag, ClassName: string): TJSHTMLElement;
begin
  Result := TJSHTMLElement(document.createElement(Tag));
  if ClassName <> '' then
    Result.className := ClassName;
end;

function TViewer.Btn(const Caption, ClassName: string; Handler: TJSEventHandler): TJSHTMLElement;
begin
  Result := El('button', ClassName);
  Result.setAttribute('type', 'button');
  Result.textContent := Caption;
  Result.addEventListener('click', Handler);
end;

procedure TViewer.Start;
var
  Top, Brand, Actions, Workspace, Aside, Bar, ZoomBox, LabelFile, Check: TJSHTMLElement;
  Title, Note, Link: TJSHTMLElement;
  Input: TJSHTMLInputElement;
  H2, Scroll, Viewer: TJSHTMLElement;
begin
  FZoom := 8;
  Top := El('header', 'top');
  Brand := El('div', 'brand');
  Title := El('h1', '');
  Title.textContent := 'FPG Editor';
  Note := El('p', '');
  Note.textContent := 'Visualizador gerado pelo Lazarus (pas2js). O arquivo fica no navegador.';
  Brand.appendChild(Title);
  Brand.appendChild(Note);

  Actions := El('div', 'actions');
  LabelFile := El('label', 'button primary');
  LabelFile.textContent := 'Abrir';
  Input := TJSHTMLInputElement(document.createElement('input'));
  Input._type := 'file';
  Input.accept := '.fpg,.fnt,.fnx,.map';
  Input.className := 'file';
  Input.addEventListener('change', @OnFile);
  LabelFile.appendChild(Input);
  Actions.appendChild(LabelFile);
  Actions.appendChild(Btn('Exemplo', '', @OnSample));
  Link := El('a', 'button ghost');
  Link.setAttribute('href', 'https://github.com/humbertodias/fpg-editor');
  Link.textContent := 'Código';
  Actions.appendChild(Link);
  Top.appendChild(Brand);
  Top.appendChild(Actions);

  FStatus := El('p', 'status');
  FStatus.textContent := 'Nenhum arquivo aberto.';
  FError := El('p', 'error');
  FError.hidden := True;

  Workspace := El('div', 'workspace');
  Aside := El('aside', '');
  FList := El('div', 'list');
  FPaletteWrap := El('section', 'palette-wrap');
  FPaletteWrap.hidden := True;
  H2 := El('h2', '');
  H2.textContent := 'Paleta';
  FPalette := El('div', 'palette');
  FPaletteWrap.appendChild(H2);
  FPaletteWrap.appendChild(FPalette);
  Aside.appendChild(FList);
  Aside.appendChild(FPaletteWrap);

  Bar := El('div', 'viewer-bar');
  ZoomBox := El('div', 'zoom');
  ZoomBox.appendChild(Btn('−', '', @OnZoomOut));
  FZoomLabel := El('span', '');
  FZoomLabel.textContent := '8×';
  ZoomBox.appendChild(FZoomLabel);
  ZoomBox.appendChild(Btn('+', '', @OnZoomIn));
  Check := El('label', 'check');
  FPoints := TJSHTMLInputElement(document.createElement('input'));
  FPoints._type := 'checkbox';
  FPoints.checked := True;
  FPoints.addEventListener('change', @OnPoints);
  Check.appendChild(FPoints);
  Check.appendChild(document.createTextNode(' Pontos de controle'));
  FExportPng := Btn('PNG', '', @OnExportPng);
  FExportSheet := Btn('Folha', '', @OnExportSheet);
  FExportPng.setAttribute('disabled', 'disabled');
  FExportSheet.setAttribute('disabled', 'disabled');
  Bar.appendChild(ZoomBox);
  Bar.appendChild(Check);
  Bar.appendChild(FExportPng);
  Bar.appendChild(FExportSheet);

  Scroll := El('div', 'stage-scroll');
  FStage := El('div', 'stage');
  FHint := El('p', 'hint');
  FHint.textContent := 'Abra um arquivo ou solte-o nesta página.';
  FView := TJSHTMLCanvasElement(document.createElement('canvas'));
  FView.hidden := True;
  FStage.appendChild(FHint);
  FStage.appendChild(FView);
  Scroll.appendChild(FStage);
  FDetail := El('p', 'detail');

  Viewer := El('section', 'viewer');
  Viewer.appendChild(Bar);
  Viewer.appendChild(Scroll);
  Viewer.appendChild(FDetail);
  Workspace.appendChild(Aside);
  Workspace.appendChild(Viewer);

  document.body.appendChild(Top);
  document.body.appendChild(FStatus);
  document.body.appendChild(FError);
  document.body.appendChild(Workspace);

  document.addEventListener('dragenter', @OnDragOver);
  document.addEventListener('dragover', @OnDragOver);
  document.addEventListener('drop', @OnDrop);
  window.addEventListener('keydown', @OnKey);
  FList.addEventListener('click', @OnListClick);
end;

function TViewer.OnFile(Event: TEventListenerEvent): Boolean;
var
  Input: TJSHTMLInputElement;
begin
  Input := TJSHTMLInputElement(Event.target);
  if (Input.files <> nil) and (Input.files.length > 0) then
    ReadFile(Input.files[0]);
  Result := True;
end;

function TViewer.OnSample(Event: TEventListenerEvent): Boolean;
var
  Demo: TJSUint8Array;
begin
  if Event <> nil then
    ClearError;
  try
    Demo := BuildDemo;
    OpenBuffer(Demo.buffer, 'demo.fpg');
  except
    on E: Exception do
      ShowError(E.Message);
  end;
  Result := True;
end;

procedure TViewer.ReadFile(AFile: TJSHTMLFile);
var
  Reader: TJSFileReader;
begin
  FName := AFile.name;
  Reader := TJSFileReader.new;
  Reader.onload := @OnLoaded;
  Reader.readAsArrayBuffer(AFile);
end;

function TViewer.OnLoaded(Event: TEventListenerEvent): Boolean;
var
  Reader: TJSFileReader;
begin
  Reader := TJSFileReader(Event.target);
  OpenBuffer(TJSArrayBuffer(Reader.Result), FName);
  Result := True;
end;

procedure TViewer.OnDragOver(Event: TJSEvent);
begin
  Event.preventDefault;
  document.body.classList.add('drag');
end;

procedure TViewer.OnDrop(Event: TJSEvent);
var
  Drag: TJSDragEvent;
begin
  Event.preventDefault;
  document.body.classList.remove('drag');
  Drag := TJSDragEvent(Event);
  if (Drag.dataTransfer <> nil) and (Drag.dataTransfer.files.length > 0) then
    ReadFile(Drag.dataTransfer.files[0]);
end;

procedure TViewer.OpenBuffer(Buf: TJSArrayBuffer; const AName: string);
var
  Bytes: TJSUint8Array;
  Raw: array of Byte;
  I: Integer;
  Bar: TProgressBar;
  Loaded: TFpg;
begin
  ClearError;
  Bytes := TJSUint8Array.new(Buf);
  SetLength(Raw, Bytes.length);
  for I := 0 to Bytes.length - 1 do
    Raw[I] := Bytes[I];
  RegisterBrowserFile(AName, Raw);
  FreeAndNil(FDoc);
  Bar := TProgressBar.Create;
  Loaded := TFpg.Create;
  try
    try
      if not Loaded.LoadFromFile(AName, Bar) then
      begin
        if LastDialogMessage <> '' then
          ShowError(LastDialogMessage)
        else
          ShowError('Não foi possível abrir o arquivo.');
        FreeAndNil(Loaded);
      end
      else
      begin
        FDoc := Loaded;
        Loaded := nil;
        FName := AName;
        FIndex := 0;
        if (FDoc.Count > 0) and (FDoc.images[1].Width > 96) then
          FZoom := 2
        else if (FDoc.Count > 0) and (FDoc.images[1].Width > 32) then
          FZoom := 4
        else
          FZoom := 8;
      end;
      Render;
    except
      on E: Exception do
      begin
        FreeAndNil(Loaded);
        FreeAndNil(FDoc);
        ShowError(E.Message);
        Render;
      end;
    end;
  finally
    Bar.Free;
  end;
end;

procedure TViewer.ShowError(const Msg: string);
begin
  FError.hidden := False;
  FError.textContent := Msg;
end;

procedure TViewer.ClearError;
begin
  FError.hidden := True;
  FError.textContent := '';
end;

function TViewer.Current: TMAPGraphic;
begin
  if (FDoc = nil) or (FIndex < 0) or (FIndex >= FDoc.Count) then
    Result := nil
  else
    Result := FDoc.images[FIndex + 1];
end;

procedure TViewer.Render;
var
  Count, I, P: Integer;
  Creator, Name: string;
  Button, Code, Title, Swatch: TJSHTMLElement;
  Img: TMAPGraphic;
begin
  FList.textContent := '';
  FPalette.textContent := '';
  Count := 0;
  if FDoc <> nil then
    Count := FDoc.Count;
  if Count = 0 then
  begin
    FExportPng.setAttribute('disabled', 'disabled');
    FExportSheet.setAttribute('disabled', 'disabled');
  end
  else
  begin
    FExportPng.removeAttribute('disabled');
    FExportSheet.removeAttribute('disabled');
  end;
  if FDoc = nil then
  begin
    FStatus.textContent := 'Nenhum arquivo aberto.';
    FPaletteWrap.hidden := True;
    FDetail.textContent := '';
    FHint.hidden := False;
    FView.hidden := True;
    Exit;
  end;

  Creator := '';
  if FDoc.appName <> '' then
    Creator := ' · ' + FDoc.appName + ' ' + FDoc.appVersion;
  if Count = 1 then
    FStatus.textContent := FName + ' · ' + DocLabel(FDoc) + ' · 1 imagem' + Creator
  else
    FStatus.textContent := FName + ' · ' + DocLabel(FDoc) + ' · ' + IntToStr(Count) + ' imagens' + Creator;

  if Count = 0 then
    FList.textContent := 'Nenhuma imagem neste arquivo.'
  else
    for I := 0 to FDoc.Count - 1 do
    begin
      Img := FDoc.images[I + 1];
      Button := El('button', 'sprite');
      Button.setAttribute('type', 'button');
      Button.setAttribute('data-index', IntToStr(I));
      Code := El('strong', '');
      Code.textContent := Pad3(Img.Code);
      Title := El('span', '');
      Name := Img.Name;
      if Name = '' then
        Name := Img.FPName;
      if Name = '' then
        Name := IntToStr(Img.Width) + '×' + IntToStr(Img.Height);
      Title.textContent := Name;
      Button.appendChild(Code);
      Button.appendChild(Title);
      FList.appendChild(Button);
    end;

  FPaletteWrap.hidden := not FDoc.loadPalette;
  if FDoc.loadPalette then
    for I := 0 to 255 do
    begin
      Swatch := El('i', 'swatch');
      P := I * 3;
      Swatch.setAttribute('style', 'background:rgb(' + IntToStr(FDoc.Palette[P]) + ' ' +
        IntToStr(FDoc.Palette[P + 1]) + ' ' + IntToStr(FDoc.Palette[P + 2]) + ')');
      FPalette.appendChild(Swatch);
    end;
  Paint;
end;

procedure TViewer.Paint;
var
  Img: TMAPGraphic;
  Ctx: TJSCanvasRenderingContext2D;
  Data: TFenixImageData;
  I: Integer;
  Text, Points: string;
  Button: TJSHTMLElement;
begin
  FZoomLabel.textContent := IntToStr(FZoom) + '×';
  Img := Current;
  for I := 0 to FList.childNodes.length - 1 do
  begin
    if FList.childNodes[I].nodeType <> TJSNode.ELEMENT_NODE then
      Continue;
    Button := TJSHTMLElement(FList.childNodes[I]);
    if Button.getAttribute('data-index') = IntToStr(FIndex) then
      Button.setAttribute('aria-selected', 'true')
    else
      Button.removeAttribute('aria-selected');
  end;
  if (Img = nil) or (Img.Width = 0) or (Img.Height = 0) then
  begin
    FHint.hidden := False;
    if Img = nil then
      FHint.textContent := 'Abra um arquivo ou solte-o nesta página.'
    else
      FHint.textContent := 'Esta imagem está vazia.';
    FView.hidden := True;
    if Img <> nil then
      FDetail.textContent := 'Código ' + IntToStr(Img.Code);
    Exit;
  end;
  FHint.hidden := True;
  FView.hidden := False;
  FView.width := Img.Width;
  FView.height := Img.Height;
  FView.setAttribute('style', 'width:' + IntToStr(Img.Width * FZoom) + 'px;height:' +
    IntToStr(Img.Height * FZoom) + 'px');
  Ctx := FView.getContextAs2DContext('2d');
  Data := NewImageData(BitmapPixels(Img), Img.Width, Img.Height);
  Ctx.putImageData(Data, 0, 0);
  if FPoints.checked then
  begin
    Ctx.strokeStyleAsColor := '#ff4d6d';
    Ctx.lineWidth := 1;
    for I := 0 to Img.NCPoints - 1 do
    begin
      Ctx.beginPath;
      Ctx.moveTo(Img.CPoints[I * 2] - 2, Img.CPoints[I * 2 + 1] + 0.5);
      Ctx.lineTo(Img.CPoints[I * 2] + 3, Img.CPoints[I * 2 + 1] + 0.5);
      Ctx.moveTo(Img.CPoints[I * 2] + 0.5, Img.CPoints[I * 2 + 1] - 2);
      Ctx.lineTo(Img.CPoints[I * 2] + 0.5, Img.CPoints[I * 2 + 1] + 3);
      Ctx.stroke;
    end;
  end;
  Points := '';
  for I := 0 to Img.NCPoints - 1 do
    Points := Points + ' (' + IntToStr(Img.CPoints[I * 2]) + ', ' + IntToStr(Img.CPoints[I * 2 + 1]) + ')';
  Text := 'Código ' + IntToStr(Img.Code);
  if Img.Name <> '' then
    Text := Text + ' · ' + Img.Name;
  Text := Text + ' · ' + IntToStr(Img.Width) + '×' + IntToStr(Img.Height);
  if Points <> '' then
    Text := Text + ' · pontos' + Points;
  FDetail.textContent := Text;
end;

function ZoomPos(Value: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(Zooms) do
    if Zooms[I] = Value then
    begin
      Result := I;
      Exit;
    end;
end;

function TViewer.OnZoomOut(Event: TEventListenerEvent): Boolean;
var
  P: Integer;
begin
  P := ZoomPos(FZoom);
  if P > 0 then
  begin
    FZoom := Zooms[P - 1];
    Paint;
  end;
  Result := True;
end;

function TViewer.OnZoomIn(Event: TEventListenerEvent): Boolean;
var
  P: Integer;
begin
  P := ZoomPos(FZoom);
  if P < High(Zooms) then
  begin
    FZoom := Zooms[P + 1];
    Paint;
  end;
  Result := True;
end;

function TViewer.OnPoints(Event: TEventListenerEvent): Boolean;
begin
  Paint;
  Result := True;
end;

function TViewer.OnListClick(Event: TEventListenerEvent): Boolean;
var
  Node: TJSNode;
  Index: string;
begin
  Node := TJSNode(Event.target);
  while (Node <> nil) and ((Node.nodeType <> TJSNode.ELEMENT_NODE) or
    not TJSElement(Node).hasAttribute('data-index')) do
    Node := Node.parentElement;
  if Node = nil then
    Exit(True);
  Index := TJSElement(Node).getAttribute('data-index');
  if Index <> '' then
  begin
    FIndex := StrToInt(Index);
    Paint;
  end;
  Result := True;
end;

procedure TViewer.OnKey(Event: TJSEvent);
var
  Key: string;
begin
  if (FDoc = nil) or (FDoc.Count = 0) then
    Exit;
  Key := TJSKeyboardEvent(Event).Key;
  if (Key = 'ArrowRight') or (Key = 'ArrowDown') then
  begin
    if FIndex < FDoc.Count - 1 then
      Inc(FIndex);
    Paint;
  end
  else if (Key = 'ArrowLeft') or (Key = 'ArrowUp') then
  begin
    if FIndex > 0 then
      Dec(FIndex);
    Paint;
  end;
end;

procedure TViewer.Download(Canvas: TJSHTMLCanvasElement; const AName: string);
var
  Link: TJSHTMLElement;
begin
  Link := El('a', '');
  Link.setAttribute('href', Canvas.toDataURL('image/png'));
  Link.setAttribute('download', AName);
  Click(Link);
end;

function TViewer.OnExportPng(Event: TEventListenerEvent): Boolean;
var
  Img: TMAPGraphic;
  Canvas: TJSHTMLCanvasElement;
  Ctx: TJSCanvasRenderingContext2D;
  Stem: string;
begin
  Img := Current;
  if Img = nil then
    Exit(True);
  Canvas := TJSHTMLCanvasElement(document.createElement('canvas'));
  Canvas.width := Img.Width;
  Canvas.height := Img.Height;
  Ctx := Canvas.getContextAs2DContext('2d');
  Ctx.putImageData(NewImageData(BitmapPixels(Img), Img.Width, Img.Height), 0, 0);
  Stem := FName;
  if Pos('.', Stem) > 0 then
    Stem := Copy(Stem, 1, Pos('.', Stem) - 1);
  Download(Canvas, Stem + '-' + IntToStr(Img.Code) + '.png');
  Result := True;
end;

function TViewer.OnExportSheet(Event: TEventListenerEvent): Boolean;
var
  Images: array of TMAPGraphic;
  I, Cols, Rows, Gap, CellW, CellH, Col, Row, X, Y: Integer;
  Canvas: TJSHTMLCanvasElement;
  Ctx: TJSCanvasRenderingContext2D;
  Img: TMAPGraphic;
  Stem: string;
begin
  SetLength(Images, 0);
  CellW := 1;
  CellH := 1;
  if FDoc <> nil then
    for I := 1 to FDoc.Count do
    begin
      Img := FDoc.images[I];
      if (Img.Width = 0) or (Img.Height = 0) then
        Continue;
      SetLength(Images, Length(Images) + 1);
      Images[High(Images)] := Img;
      if Img.Width > CellW then
        CellW := Img.Width;
      if Img.Height > CellH then
        CellH := Img.Height;
    end;
  if Length(Images) = 0 then
    Exit(True);
  Cols := 1;
  while Cols * Cols < Length(Images) do
    Inc(Cols);
  Rows := (Length(Images) + Cols - 1) div Cols;
  Gap := 8;
  Canvas := TJSHTMLCanvasElement(document.createElement('canvas'));
  Canvas.width := Cols * CellW + (Cols + 1) * Gap;
  Canvas.height := Rows * (CellH + 16) + (Rows + 1) * Gap;
  Ctx := Canvas.getContextAs2DContext('2d');
  Ctx.fillStyleAsColor := '#14110e';
  Ctx.fillRect(0, 0, Canvas.width, Canvas.height);
  Ctx.font := '12px monospace';
  Ctx.textBaseline := 'top';
  Ctx.fillStyleAsColor := '#f3eadc';
  for I := 0 to High(Images) do
  begin
    Col := I mod Cols;
    Row := I div Cols;
    X := Gap + Col * (CellW + Gap);
    Y := Gap + Row * (CellH + 16 + Gap);
    Ctx.putImageData(NewImageData(BitmapPixels(Images[I]), Images[I].Width, Images[I].Height), X, Y);
    Ctx.fillText(IntToStr(Images[I].Code), X, Y + CellH + 2);
  end;
  Stem := FName;
  if Pos('.', Stem) > 0 then
    Stem := Copy(Stem, 1, Pos('.', Stem) - 1);
  Download(Canvas, Stem + '-folha.png');
  Result := True;
end;

end.
