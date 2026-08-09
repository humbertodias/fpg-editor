unit umainmap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ExtCtrls, ExtDlgs, Spin, StdCtrls, Buttons, ColorBox,
  IntfGraphics, FPimage, lazcanvas, ComCtrls, FPCanvas, typinfo ,math, uLanguage
  , types, uMAPGraphic, uselectcolor;

type

  { TfrmMapEditor }
  TfrmMapEditor = class(TForm)
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Action5: TAction;
    Action6: TAction;
    Action7: TAction;
    Action8: TAction;
    ActionList1: TActionList;
    BrushStyleCombo: TComboBox;
    cbPen: TColorButton;
    cbBrush: TColorButton;
    cbBackground: TColorButton;
    cbPen1: TColorButton;
    cbBrush1: TColorButton;
    ColorDialog1: TColorDialog;
    FigureCombo: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    gbPalette: TGroupBox;
    gbGamuts: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    lblGamutReference: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    PColorReference: TPanel;
    pPalettes: TPanel;
    PGamutColorReference: TPanel;
    pnlStatus: TPanel;
    pnlProperties: TPanel;
    pClient: TPanel;
    PenStyleCombo: TComboBox;
    PenModeCombo: TComboBox;
    SavePictureDialog1: TSavePictureDialog;
    scrlbxImage: TScrollBox;
    scrlbxPalette: TScrollBox;
    scrlbxGamuts: TScrollBox;
    sePenAlpha: TSpinEdit;
    seBrushAlpha: TSpinEdit;
    seZoom: TSpinEdit;
    sePen: TSpinEdit;
    Splitter1: TSplitter;
    SplitterProperties: TSplitter;
    splitterPalette: TSplitter;
    pGamutReference: TPanel;
    PPaletteReference: TPanel;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure Action8Execute(Sender: TObject);
    procedure BrushStyleComboChange(Sender: TObject);
    procedure cbBrush1ColorChanged(Sender: TObject);
    procedure cbBrushColorChanged(Sender: TObject);
    procedure cbBackgroundColorChanged(Sender: TObject);
    procedure cbPen1ColorChanged(Sender: TObject);
    procedure cbPenColorChanged(Sender: TObject);
    procedure FigureComboChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure lblGamutReferenceClick(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PColorReferenceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PenModeComboChange(Sender: TObject);
    procedure PenStyleComboChange(Sender: TObject);
    procedure PGamutColorReferenceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure scrlbxImageMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure seBrushAlphaChange(Sender: TObject);
    procedure sePenAlphaChange(Sender: TObject);
    procedure sePenChange(Sender: TObject);
    procedure SpeedButton1DblClick(Sender: TObject);
    procedure SpeedButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure seZoomChange(Sender: TObject);
    procedure pencil(X,Y: integer; pen: boolean);
    procedure fill(X,Y: integer; pen: boolean);
    procedure fill(X,Y: integer; pen: boolean; var lazBMP : TLazIntfImage);
    procedure copyColor(X,Y: integer; pen: boolean);
    procedure line(X,Y: integer; X2,Y2:Integer; pen: boolean);
    procedure triangle(X,Y: integer; X2,Y2:Integer);
    procedure rectangle(X,Y: integer; X2,Y2:Integer);
    procedure circle(X,Y: integer; X2,Y2:Integer);
//    procedure paintPenImage;
//    procedure paintBrushImage;
    procedure updatePen;
    procedure updateBrush;
    procedure fillPalette;
    procedure fillGamuts;
    procedure replaceColor(index : Integer; inColor: TFPColor  );
    procedure RefreshForm;
    procedure copyPalettes;
  private
    PColor: array[0..255] of TPanel;
    PGamutColor: array[0..15] of array [0..31] of TPanel;
    lastShift : TShiftState;
    x1,y1 : Integer;
    FPen : TFPCustomPen;
    FBrush : TFPCustomBrush;
    undoImage : TPicture;
    primeraVez : Boolean;
    { private declarations }
  public
    { public declarations }
    imageSource : TMAPGraphic;
  end;

var
  frmMapEditor: TfrmMapEditor;

resourcestring
  LNG_MAPEDIT_HELP = 'Con control pulsado y haciendo clic, puedes cambiar los colores de la paleta.';
  LNG_PEN = 'Lápiz';
  LNG_LINE = 'Linea';
  LNG_TRIANGLE = 'Triangulo';
  LNG_RECTANGLE = 'Rectangulo';
  LNG_ELLIPSE = 'Elipse';
  LNG_COPYCOLOR = 'Copiar Color';
  LNG_FILL = 'Rellenar';


implementation

{$R *.lfm}

{ TfrmMapEditor }

procedure TfrmMapEditor.Action4Execute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMapEditor.Action8Execute(Sender: TObject);
begin
  image1.Picture.Assign(undoImage);
end;

procedure TfrmMapEditor.BrushStyleComboChange(Sender: TObject);
begin
    updateBrush;

end;

procedure TfrmMapEditor.cbBrush1ColorChanged(Sender: TObject);
begin
  cbBrush.ButtonColor:=cbBrush1.ButtonColor;
  updateBrush;
end;

procedure TfrmMapEditor.cbBrushColorChanged(Sender: TObject);
begin
  cbBrush1.ButtonColor:=cbBrush.ButtonColor;
  updateBrush;
end;

procedure TfrmMapEditor.cbBackgroundColorChanged(Sender: TObject);
begin
  scrlbxImage.Color:=cbBackground.ButtonColor;
end;

procedure TfrmMapEditor.cbPen1ColorChanged(Sender: TObject);
begin
  cbPen.ButtonColor:=cbPen1.ButtonColor;
  updatePen;
end;

procedure TfrmMapEditor.cbPenColorChanged(Sender: TObject);
begin
  cbPen1.ButtonColor:=cbPen.ButtonColor;
  updatePen;
end;

procedure TfrmMapEditor.FigureComboChange(Sender: TObject);
begin
  case FigureCombo.ItemIndex of
  0: MenuItem7.Checked := true;
  1: MenuItem8.Checked := true;
  2: MenuItem12.Checked := true;
  3: MenuItem13.Checked := true;
  4: MenuItem9.Checked := true;
  5: MenuItem14.Checked := true;
  end;
end;


procedure TfrmMapEditor.copyPalettes;
var
  i,j,z: integer;
  tmpColor : TColor;
begin
   for i:=0 to 15 do
     for j:=0 to 31 do
     begin
       imageSource.Gamuts[i].editable:=1;
       imageSource.Gamuts[i].mode:=1;
       imageSource.Gamuts[i].colors[j] :=PGamutColor[i][j].Tag;
     end;

   for i:=0 to 7 do
      for j:=31 downto 0 do
      begin
          z:=i*32+j;
          tmpColor:=PColor[z].Color;
          imageSource.bPalette[z*3]:=Red(tmpColor);
          imageSource.bPalette[z*3+1]:=green(tmpColor);
          imageSource.bPalette[z*3+2]:=blue(tmpColor);
      end;

end;

procedure TfrmMapEditor.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if MessageDlg(LNG_WARNING,LNG_SAVE_CHANGES,mtWarning,mbYesNo,0) = mrYes  then
  begin
     imageSource.Assign(Image1.Picture);
     copyPalettes;
  end;
end;

(*
procedure TfrmMapEditor.paintPenImage;
var
  bmp : TBitmap;
  lazBMP : TLazIntfImage;
  imgCanvas : TFPImageCanvas;
begin
  bmp:= TBitmap.Create;
  bmp.SetSize(16,16);
  lazBMP := bmp.CreateIntfImage;

  imgCanvas := TFPImageCanvas.create(lazBMP);
  imgCanvas.Brush.FPColor:=FPen.FPColor;
  imgCanvas.Brush.Style:=bsSolid;
  imgCanvas.FillRect(0,0,16,16);

  bmp.LoadFromIntfImage(lazBMP);
  SpeedButton1.Glyph.Assign(bmp);
  FreeAndNil(lazBMP);
  freeandnil(bmp);
end;
*)
(*
procedure TfrmMapEditor.paintBrushImage;
var
  bmp : TBitmap;
  lazBMP : TLazIntfImage;
  imgCanvas : TFPImageCanvas;
begin
  bmp:= TBitmap.Create;
  bmp.SetSize(16,16);
  lazBMP := bmp.CreateIntfImage;

  imgCanvas := TFPImageCanvas.create(lazBMP);
  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.FillRect(0,0,16,16);

  bmp.LoadFromIntfImage(lazBMP);
  SpeedButton2.Glyph.Assign(bmp);
  FreeAndNil(lazBMP);
  freeandnil(bmp);
end;
*)

procedure TfrmMapEditor.updatePen;
var
  tmpColor : TFPColor;
begin
  FPen.Style:=TFPPenStyle(PenStyleCombo.ItemIndex);
  FPen.Width:=sePen.Value;
  tmpColor:=TColorToFPColor(cbPen.ButtonColor);
  tmpColor.alpha:=High(word) * (sePenAlpha.value div 100);
  FPen.FPColor:=tmpColor;
  FPen.Mode:=TFPPenMode(PenModeCombo.ItemIndex);

end;

procedure TfrmMapEditor.updateBrush;
var
  tmpColor : TFPColor;
begin
  FBrush.Style:=TFPBrushStyle(BrushStyleCombo.ItemIndex);
  tmpColor:=TColorToFPColor(cbBrush.ButtonColor);
  tmpColor.alpha:=High(word)* (seBrushAlpha.value div 100);
  FBrush.FPColor:=tmpColor;

end;

procedure TfrmMapEditor.FormCreate(Sender: TObject);
var
  ps: TFPPenStyle;
  bs: TFPBrushStyle;
  pm: TFPPenMode;
begin

  FigureCombo.Items.Clear;
  FigureCombo.Items.Add(LNG_PEN);
  FigureCombo.Items.Add(LNG_LINE);
  FigureCombo.Items.Add(LNG_TRIANGLE);
  FigureCombo.Items.Add(LNG_RECTANGLE);
  FigureCombo.Items.Add(LNG_ELLIPSE);
  FigureCombo.Items.Add(LNG_COPYCOLOR);
  FigureCombo.Items.Add(LNG_FILL);

  FPen := TFPCustomPen.Create;
  FBrush := TFPCustomBrush.Create;

  undoImage:= TPicture.Create;

  PenStyleCombo.Items.BeginUpdate;
  for ps := Low(ps) to High(ps) do
    PenStyleCombo.Items.Add(GetEnumName(TypeInfo(TFPPenStyle), Ord(ps)));
  PenStyleCombo.Items.EndUpdate;
  PenStyleCombo.ItemIndex := 0;

  PenModeCombo.Items.BeginUpdate;
  for pm := Low(pm) to High(pm) do
    PenModeCombo.Items.Add(GetEnumName(TypeInfo(TFPPenMode), Ord(pm)));
  PenModeCombo.Items.EndUpdate;
  PenModeCombo.ItemIndex := 0;


  BrushStyleCombo.Items.BeginUpdate;
  for bs := Low(bs) to High(bs) do
    BrushStyleCombo.Items.Add(GetEnumName(TypeInfo(TFPBrushStyle), Ord(bs)));
  BrushStyleCombo.Items.EndUpdate;
  BrushStyleCombo.ItemIndex := 1;

  updatePen;
  updateBrush;

  cbBackground.ButtonColor:=scrlbxImage.Color;
  primeraVez:=true;
  imageSource := nil;
end;

procedure TfrmMapEditor.RefreshForm;
begin
  if imageSource <> nil then
  begin
    if imageSource.bitsPerPixel = 8 then
    begin
      fillPalette;
      fillGamuts;
    end;
    Image1.Picture.Assign(imageSource);
    Image1.Width:=imageSource.Width;
    Image1.Height:=imageSource.Height;
  end;
end;

procedure TfrmMapEditor.FormShow(Sender: TObject);
var
  i,j : Integer;
  tmpPanel : TPanel;
  parentPanel : TPanel;
  tmplabel : TLabel;
begin
  BeginFormUpdate;

  if primeraVez then
  begin
    for i:=0 to 7 do
    begin
      parentPanel:= TPanel.Create(Owner);
      parentPanel.Parent:=scrlbxPalette;
      parentPanel.height:=PPaletteReference.height;
      parentPanel.Align:=PPaletteReference.Align;
      for j:=31 downto 0 do
      begin
        tmpPanel:= TPanel.Create(Owner);
        tmpPanel.OnMouseDown:= @PColorReferenceMouseDown;
        tmpPanel.Parent:=parentPanel;
        tmpPanel.Width:=PColorReference.Width;
        tmpPanel.Align:=PColorReference.Align;
        tmpPanel.Tag:=i*32+j;
        PColor[i*32+j]:=tmpPanel;
      end;
    end;

    for i:=0 to 15 do
    begin
        parentPanel:= TPanel.Create(Owner);
        parentPanel.Parent:=scrlbxGamuts;
        parentPanel.height:=pGamutReference.height;
        parentPanel.Align:=pGamutReference.Align;

      for j:=31 downto 0 do
      begin
        tmpPanel:= TPanel.Create(Owner);
        tmpPanel.OnMouseDown:= @PGamutColorReferenceMouseDown;
        tmpPanel.Parent:=parentPanel;
        tmpPanel.Width:=PGamutColorReference.Width;
        tmpPanel.Align:=PGamutColorReference.Align;
        PGamutColor[i,j]:=tmpPanel;
      end;
      tmplabel:= TLabel.Create(Owner);
      tmplabel.AutoSize:=lblGamutReference.AutoSize;
      tmplabel.Width:=lblGamutReference.Width;
      tmplabel.Parent:=parentPanel;
      tmplabel.Caption:=inttostr(i+1)+':';
      tmplabel.Align:=lblGamutReference.Align;
    end;

    primeraVez:=false;
  end;

  EndFormUpdate;

  RefreshForm;

end;


procedure TfrmMapEditor.fillPalette;
var
  i : Integer;
begin
   for i:=0 to 255 do
   begin
      PColor[i].color:=RGBToColor (imageSource.bpalette[i*3],imageSource.bpalette[i*3+1],imageSource.bpalette[i*3+2]);
   end;
end;

procedure TfrmMapEditor.fillGamuts;
var
  i,j : Integer;
  index : Integer;
begin
   for i:=0 to 15 do
    for j:=0 to 31 do
    begin
      index := imageSource.Gamuts[i].colors[j];
      PGamutColor[i][j].color:=RGBToColor (imageSource.bpalette[index*3],imageSource.bpalette[index*3+1],imageSource.bpalette[index*3+2]);
      PGamutColor[i][j].tag:=index;
    end;
end;


procedure TfrmMapEditor.pencil(X,Y: integer; pen: boolean);
begin
  line(x,y,x,y,pen);
end;

procedure TfrmMapEditor.fill(X,Y: integer; pen: boolean; var lazBMP : TLazIntfImage);
var
  currColor : TFPColor;
  newColor : TFPColor;
begin
   if (x < 0) or (x>Image1.Picture.width -1) then
    exit;
   if (y < 0) or (y>Image1.Picture.height -1) then
    exit;

   currColor:=lazBMP.Colors[x,y];
   if pen then
     newColor:=FPen.FPColor
   else
    newColor:=FBrush.FPColor;

   if newColor = currColor then
      exit;

   lazBMP.Colors[x,y]:=newColor;

   if x <Image1.Picture.Width-1 then
     if (lazBMP.Colors[x+1,y]= currColor) then
      fill(x+1,y,pen,lazbmp);
   if (x>1) then
     if(lazBMP.Colors[x-1,y]= currColor) then
      fill(x-1,y,pen,lazbmp);
   if (y <Image1.Picture.height-1) then
     if(lazBMP.Colors[x,y+1]= currColor) then
      fill(x,y+1,pen,lazbmp);
   if (y>1) then
     if(lazBMP.Colors[x,y-1]= currColor) then
      fill(x,y-1,pen,lazbmp);

end;

procedure TfrmMapEditor.fill(X,Y: integer; pen: boolean);
var
  lazBMP : TLazIntfImage;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  fill(x,y,pen,lazBMP);

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;


procedure TfrmMapEditor.copyColor(X,Y: integer; pen: boolean);
var
  lazBMP : TLazIntfImage;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;
  if pen then
  begin
    FPen.FPColor:=lazBMP.Colors[x,y];
    cbPen.ButtonColor:=FPColorToTColor(FPen.FPColor);
    cbPen1.ButtonColor:=cbPen.ButtonColor;
    sePenAlpha.Value:= (FPen.FPColor.alpha * 100) div high(Word) ;
  end else begin
    FBrush.FPColor:=lazBMP.Colors[x,y];
    cbBrush.ButtonColor:=FPColorToTColor(FBrush.FPColor);
    cbBrush1.ButtonColor:=cbBrush.ButtonColor;
    seBrushAlpha.Value:= (FBrush.FPColor.alpha * 100) div high(Word) ;
  end;
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.line(X,Y: integer; X2,Y2:Integer; pen: boolean);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);

  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;
  if pen then
     imgCanvas.Pen.FPColor:=FPen.FPColor
  else
   imgCanvas.Pen.FPColor:=FBrush.FPColor;

  imgCanvas.Line(x,y,x2,y2);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;


procedure TfrmMapEditor.circle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.EllipseC(x,y,abs(x-x2),abs(y-y2));

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.triangle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
  Points: array of TPoint;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;

  SetLength(Points, 4);
  Points[0] := Point(x, y2);
  Points[3] := Points[0];
  Points[1] := Point((x + x2) div 2, y);
  Points[2] := point(x2,y2);

  imgCanvas.Polygon(points);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.rectangle(X,Y: integer; X2,Y2:Integer);
var
  lazBMP : TLazIntfImage;
  imgCanvas : TLazCanvas;
begin
  lazBMP := image1.Picture.Bitmap.CreateIntfImage;

  imgCanvas := TLazCanvas.create(lazBMP);


  imgCanvas.Pen.Width:=FPen.Width;
  imgCanvas.Pen.FPColor:=FPen.FPColor;
  imgCanvas.Pen.Style:=FPen.Style;
  imgCanvas.Pen.Mode:=FPen.Mode;

  imgCanvas.Brush.FPColor:=FBrush.FPColor;
  imgCanvas.Brush.Style:=FBrush.Style;
  imgCanvas.Rectangle(x,y,x2,y2);

  //lazBMP imgCanvas.Image;

  image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);
end;

procedure TfrmMapEditor.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  lastShift :=Shift;
  X1 := (X * 100 )div seZoom.Value;
  Y1 := (Y * 100 )div seZoom.Value;
  if FigureCombo.ItemIndex = 5 then
  begin
    if ssLeft in Shift then
     copyColor(x1,y1,true);
    if ssRight in Shift then
     copyColor(x1,y1,false);
  end else
    undoImage.Assign(Image1.Picture);

end;

procedure TfrmMapEditor.Image1MouseLeave(Sender: TObject);
begin
(*
  if MenuItem6.Checked then
  begin
     undoImage.Assign(Image1.Picture);
     pencil(X1,Y1);
 end;*)
end;

procedure TfrmMapEditor.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  X2,Y2: integer;
begin
  if   ssRight in  Shift then
  begin
    if FigureCombo.ItemIndex = 0 then
    begin
       X1 := (X * 100 )div seZoom.Value;
       Y1 := (Y * 100 )div seZoom.Value;
       pencil(x1,y1,false);
    end;
    if FigureCombo.ItemIndex = 1 then
    begin
       X2 := (X * 100 )div seZoom.Value;
       Y2 := (Y * 100 )div seZoom.Value;
       image1.Picture.assign(undoImage);
       line(x1,y1,x2,y2,false);
    end;

  end;

  if   ssLeft in  Shift then
  begin
    if FigureCombo.ItemIndex = 0 then
    begin
       X1 := (X * 100 )div seZoom.Value;
       Y1 := (Y * 100 )div seZoom.Value;
       pencil(x1,y1,true);
    end;
    if FigureCombo.ItemIndex = 1 then
    begin
       X2 := (X * 100 )div seZoom.Value;
       Y2 := (Y * 100 )div seZoom.Value;
       image1.Picture.assign(undoImage);
       line(x1,y1,x2,y2,true);
    end;
    if FigureCombo.ItemIndex = 2 then
    begin
       X2 := (X * 100 )div seZoom.Value;
       Y2 := (Y * 100 )div seZoom.Value;
       image1.Picture.assign(undoImage);
       triangle(x1,y1,x2,y2);
    end;
    if FigureCombo.ItemIndex = 3 then
    begin
       X2 := (X * 100 )div seZoom.Value;
       Y2 := (Y * 100 )div seZoom.Value;
       image1.Picture.assign(undoImage);
       rectangle(x1,y1,x2,y2);
    end;
    if FigureCombo.ItemIndex = 4 then
    begin
       X2 := (X * 100 )div seZoom.Value;
       Y2 := (Y * 100 )div seZoom.Value;
       image1.Picture.assign(undoImage);
       circle(x1,y1,x2,y2);
    end;

  end;
end;

procedure TfrmMapEditor.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if FigureCombo.ItemIndex = 0 then
   begin
      X1 := (X * 100 )div seZoom.Value;
      Y1 := (Y * 100 )div seZoom.Value;
      if  ssLeft in  lastShift then
       pencil(x1,y1,true);
      if  ssRight in  lastShift then
       pencil(x1,y1,false);
   end;
   if FigureCombo.ItemIndex = 6 then
   begin
    X1 := (X * 100 )div seZoom.Value;
    Y1 := (Y * 100 )div seZoom.Value;
    if  ssLeft in  lastShift then
     fill(x1,y1,true);
    if  ssRight in  lastShift then
     fill(x1,y1,false);

   end;
end;

procedure TfrmMapEditor.Image1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
     seZoom.Value:=seZoom.Value+seZoom.Increment
  else
      seZoom.Value:=seZoom.Value-seZoom.Increment;
end;

procedure TfrmMapEditor.lblGamutReferenceClick(Sender: TObject);
begin

end;

procedure TfrmMapEditor.MenuItem12Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 2;
end;

procedure TfrmMapEditor.MenuItem13Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 3;
end;

procedure TfrmMapEditor.MenuItem14Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 5;
end;

procedure TfrmMapEditor.MenuItem16Click(Sender: TObject);
begin
  pnlProperties.Visible:= not pnlProperties.Visible;
end;

procedure TfrmMapEditor.MenuItem17Click(Sender: TObject);
begin
  gbPalette.Visible:= not gbPalette.Visible;

  if gbPalette.Visible then
  begin
     gbGamuts.Align:=alNone;
     Splitter1.Align:=alNone;
     gbGamuts.Align:=alBottom;
     Splitter1.Align:=alBottom;
  end
  else
    gbGamuts.Align:=alClient;

  pPalettes.Visible:= (gbPalette.Visible OR gbGamuts.Visible);
end;

procedure TfrmMapEditor.MenuItem18Click(Sender: TObject);
begin
  ShowMessage(LNG_MAPEDIT_HELP);
end;

procedure TfrmMapEditor.MenuItem19Click(Sender: TObject);
begin
  gbGamuts.Visible:= not gbGamuts.Visible;
  if gbPalette.Visible then
  begin
   gbGamuts.Align:=alNone;
   Splitter1.Align:=alNone;
   gbGamuts.Align:=alBottom;
   Splitter1.Align:=alBottom;
  end
  else
    gbGamuts.Align:=alClient;
  pPalettes.Visible:= (gbPalette.Visible OR gbGamuts.Visible);
end;

procedure TfrmMapEditor.MenuItem20Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 6;
end;

procedure TfrmMapEditor.MenuItem5Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMapEditor.MenuItem7Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 0;
end;

procedure TfrmMapEditor.MenuItem8Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 1;
end;

procedure TfrmMapEditor.MenuItem9Click(Sender: TObject);
begin
  FigureCombo.ItemIndex := 4;
end;

procedure TfrmMapEditor.replaceColor(index : Integer; inColor: TFPColor  );
var
  mapGraphic : TMAPGraphic;
  lazBMP : TLazIntfImage;
  i,j : Integer;
begin
  if Image1.Picture.Graphic.ClassType <> TMAPGraphic.ClassType then
    exit;
    mapGraphic:= TMAPGraphic(Image1.Picture);
  lazBMP:= Image1.Picture.Bitmap.CreateIntfImage;
  if mapGraphic.bitsPerPixel = 8  then
  begin
   for j:=0 to lazBMP.Height-1 do
     for i:=0 to lazBMP.Width-1 do
     begin
        if mapGraphic.data8bits[i*Height+j] = index then
           lazBMP.Colors[i,j]:= inColor;
     end;

  end;
  Image1.Picture.Bitmap.LoadFromIntfImage(lazBMP);
  FreeAndNil(lazBMP);

end;

procedure TfrmMapEditor.PColorReferenceMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssCtrl in Shift then
  begin
    ColorDialog1.Color:=TPanel(Sender).Color;
    if ColorDialog1.Execute then
    begin
      TPanel(Sender).Color:=ColorDialog1.Color;
      //if usePalette then
      //   replaceColor(TPanel(Sender).Tag,TColorToFPColor(TPanel(Sender).Color));
    end;
    exit;
  end;
  if ssLeft in Shift then
  begin
    cbPen.ButtonColor:= TPanel(Sender).Color;
    cbPen1.ButtonColor:= cbPen.ButtonColor;
    updatePen;
  end;
  if ssRight in Shift then
  begin
    cbBrush.ButtonColor:= TPanel(Sender).Color;
    cbBrush1.ButtonColor:= cbBrush.ButtonColor;
    updateBrush;
  end;

end;



procedure TfrmMapEditor.PenModeComboChange(Sender: TObject);
begin
    updatePen;
end;

procedure TfrmMapEditor.PenStyleComboChange(Sender: TObject);
begin
    updatePen;
end;


procedure TfrmMapEditor.PGamutColorReferenceMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssCtrl in Shift then
  begin
    if imageSource.bitsPerPixel = 8 then
    begin
      frmselectcolor.palette:=imageSource.bPalette;
      frmselectcolor.fillPalette;
      frmselectcolor.setSelected(TPanel(Sender).tag);
      if frmSelectColor.ShowModal = mrOK then
      begin
        if frmSelectColor.selectedIndex > -1 then
        begin
         TPanel(Sender).Color:=frmSelectColor.selectedColor;
         TPanel(Sender).Tag:=frmSelectColor.selectedIndex;
        end;
      end;
    end else begin
      ColorDialog1.Color:=TPanel(Sender).Color;
      if ColorDialog1.Execute then
      begin
        TPanel(Sender).Color:=ColorDialog1.Color;
      end;
    end;
    exit;
  end;
  if ssLeft in Shift then
  begin
    cbPen.ButtonColor:= TPanel(Sender).Color;
    cbPen1.ButtonColor:= cbPen.ButtonColor;
    updatePen;
  end;
  if ssRight in Shift then
  begin
    cbBrush.ButtonColor:= TPanel(Sender).Color;
    cbBrush1.ButtonColor:= cbBrush.ButtonColor;
    updateBrush;
  end;
end;


procedure TfrmMapEditor.scrlbxImageMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  if WheelDelta > 0 then
     seZoom.Value:=seZoom.Value+seZoom.Increment
  else
      seZoom.Value:=seZoom.Value-seZoom.Increment;
end;

procedure TfrmMapEditor.seBrushAlphaChange(Sender: TObject);
begin
  updateBrush;
end;

procedure TfrmMapEditor.sePenAlphaChange(Sender: TObject);
begin
    updatePen;
end;

procedure TfrmMapEditor.sePenChange(Sender: TObject);
begin
  updatePen;
end;

procedure TfrmMapEditor.SpeedButton1DblClick(Sender: TObject);
begin
end;

procedure TfrmMapEditor.SpeedButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;


procedure TfrmMapEditor.seZoomChange(Sender: TObject);
begin
  Image1.Width:= Image1.Picture.Width * seZoom.Value div 100;;
  Image1.Height:= Image1.Picture.Height * seZoom.Value div 100;;
  image1.Refresh;
end;

procedure TfrmMapEditor.Action3Execute(Sender: TObject);
begin
    if SavePictureDialog1.Execute then
     Image1.Picture.SaveToFile(SavePictureDialog1.FileName);

end;

procedure TfrmMapEditor.Action1Execute(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
   Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
   Image1.Width:= Image1.Picture.Width * seZoom.Value div 100;;
   Image1.Height:= Image1.Picture.Height * seZoom.Value div 100;;
  end;
end;

procedure TfrmMapEditor.Action2Execute(Sender: TObject);
begin
  if OpenPictureDialog1.FileName = '' then
     Action3.Execute
  else
   Image1.Picture.SaveToFile(OpenPictureDialog1.FileName);
end;

end.
