unit uFPGListView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ClipBrd, IntfGraphics,
  uFPG, uLoadImage, uMAPGraphic, utools;

type
  TFPGListView = class(TListView)
  private
    { Private declarations }
    FrepaintNumber : Integer ;
    ffpg: TFPG;
    fnotClipboardImage : String;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(TheOwner: TComponent); override;
    procedure Load_Images(progressBar: TProgressBar);
    procedure Insert_Images(lImages: TStrings; progressBar: TProgressBar);
    procedure Insert_Imagescb(var progressBar: TProgressBar);
    procedure add_items(index: word);
    procedure replace_item(index: word);
    procedure DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap );
  published
    { Published declarations }
    property Fpg: TFpg read Ffpg write Ffpg;
    property repaintNumber: Integer read FrepaintNumber write FrepaintNumber;
    property notClipboardImage: String read fnotClipboardImage write fnotClipboardImage;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I uFPGListView_icon.lrs}
  RegisterComponents('FPG Editor', [TFPGListView]);
end;

constructor TFPGListView.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ffpg:=TFpg.Create;
  with ffpg do
    SetSubComponent(True);
end;

procedure TFPGListView.Load_Images(progressBar: TProgressBar);
var
  Count: integer;
begin
  //Limpiamos la lista de imagenes
  LargeImages.Clear;
  Items.Clear;

  progressBar.Position := 0;
  progressBar.Show;
  progressBar.Repaint;
  for Count := 1 to Fpg.Count do
  begin
    with Fpg.images[Count] do
    begin
      add_items(Count);
      if (Count mod FrepaintNumber) = 0 then
      begin
        progressBar.Position := (Count * 100) div Fpg.Count;
        progressBar.Repaint;
      end;
    end;
  end;

  progressBar.Hide;
end;


procedure TFPGListView.Insert_Images(lImages: TStrings; progressBar: TProgressBar);
var
  i       : Integer;
  code    : Word;
  bmp_src : TMAPGraphic;
  filename: String;
begin
  // Creamos el bitmap tipografía y destino
  bmp_src := TMAPGraphic.Create;
  // Se inializa la barra de progresión
  progressBar.Position := 0;
  progressBar.Show;
  progressBar.Repaint;

  for i := 0 to lImages.Count - 1 do
  begin

    code := Fpg.indexOfCode(Fpg.lastcode);
    if code <> 0 then
    begin
      if MessageDlg('El código: ' + IntToStr(Fpg.lastcode) +
        ' ya existe. ¿Desea sobrescribirlo?', mtConfirmation,
        [mbYes, mbNo], 0) = mrNo then
        continue;
    end;

    filename :=  ExtractFileName(lImages.Strings[i]);;

    // Se carga la imagen
    loadImageFile(bmp_src,  lImages.Strings[i] );

    // ver como meter fpgeditor3.1
    if code <> 0 then
    begin
      fpg.replace_bitmap(code, ChangeFileExt(filename, ''),
        ChangeFileExt(filename, ''), bmp_src);
      replace_item(code);
    end
    else
    begin
      Fpg.Count := Fpg.Count + 1;
      fpg.add_bitmap(Fpg.Count, ChangeFileExt(filename, ''),
        ChangeFileExt(filename, ''), bmp_src);
      add_items(Fpg.Count);
    end;
    Fpg.lastcode := Fpg.lastcode + 1;

    //bmp_src.FreeImage;
    progressBar.Position := ((i + 1) * 100) div lImages.Count;
    progressBar.Repaint;

  end;
  Fpg.lastcode := Fpg.lastcode - 1;
  bmp_src.Free;
  Fpg.update := True;
  Repaint;
  progressBar.Hide;
end;

procedure TFPGListView.Insert_Imagescb(var progressBar: TProgressBar);
var
  bmp_src: TMAPGraphic;

begin
  // Se inializa la barra de progresión
  progressBar.Position := 50;
  progressBar.Show;
  progressBar.Repaint;

  bmp_src := TMAPGraphic.Create;
  bmp_src.PixelFormat := pf32bit;

  try
    bmp_src.LoadFromClipBoardFormat(cf_BitMap);
  except
    bmp_src.Destroy;
    progressBar.Hide;
    MessageDlg(notClipboardImage, mtError, [mbOK], 0);
    Exit;
  end;

  // Se incrementa el código de la imagen
  Fpg.lastcode := Fpg.lastcode + 1;

  // Busca hasta que encuentre un código libre
  while Fpg.CodeExists(Fpg.lastcode) do
    Fpg.lastcode := Fpg.lastcode + 1;

  // ver como meter fpgeditor3.1
  Fpg.Count := Fpg.Count + 1;
  fpg.add_bitmap(Fpg.Count, 'ClipBoard', 'ClipBoard', bmp_src);
  add_items(Fpg.Count);


  progressBar.Hide;

  bmp_src.Destroy;

  Fpg.update := True;
end;

procedure TFPGListView.add_items(index: word);
var
  list_bmp: TListItem;
  bmp_dst: TBitMap;
begin

  // Pintamos el icono
  DrawProportional(TBitmap(Fpg.images[index]), bmp_dst);

  list_bmp := Items.Add;

  list_bmp.ImageIndex := LargeImages.add(bmp_dst, nil);

  // Se establece el código del FPG
  list_bmp.Caption := Format('%.3d',[Fpg.images[index].code]);
  //NumberTo3Char(Fpg.images[index].graph_code);

  // Se añaden los datos de la imagen a la lista
  list_bmp.SubItems.Add(Fpg.images[index].fpname);
  list_bmp.SubItems.Add(Fpg.images[index].Name);

  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].Width));
  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].Height));
  list_bmp.SubItems.Add(IntToStr(Fpg.images[index].CPointsCount));

end;

procedure TFPGListView.replace_item(index: word);
var
  list_bmp: TListItem;
  bmp_dst: TBitMap;
begin

  // Pintamos el icono
  DrawProportional(TBitmap(Fpg.images[index]), bmp_dst);

  list_bmp := Items.Item[index - 1];

  LargeImages.Replace(index - 1, bmp_dst, nil);
  //list_bmp.ImageIndex :=

  // Se añaden los datos de la imagen a la lista
  list_bmp.Caption := Format('%.3d',[Fpg.images[index].code]);
  list_bmp.SubItems.Strings[0] := Fpg.images[index].fpname;
  list_bmp.SubItems.Strings[1] := Fpg.images[index].Name;

  list_bmp.SubItems.Strings[2] := IntToStr(Fpg.images[index].Width);
  list_bmp.SubItems.Strings[3] := IntToStr(Fpg.images[index].Height);
  // list_bmp.SubItems.Strings[4]:=IntToStr(Fpg.images[index].ncpoints);

end;

procedure TFPGListView.DrawProportional( var bmp_src : TBitMap; var bmp_dst: TBitMap );
var
 x, y, finalWidth, finalHeight : integer;
 bitmap1 : TBitmap;
begin
 bmp_dst := TBitmap.Create;
 bmp_dst.PixelFormat:= pf32bit;
 bitmap1 := TBitmap.Create;
 bitmap1.PixelFormat:= pf32bit;

 bmp_dst.SetSize(LargeImages.Width,LargeImages.Height);
 setAlpha(bmp_dst,0,Rect(0, 0, LargeImages.Width , LargeImages.Height));

 x := 0;
 y := 0;
 finalWidth  := bmp_dst.Width;
 finalHeight := bmp_dst.Height;

 if bmp_src <> nil then begin
   if bmp_src.Width > bmp_src.Height then
   begin
    finalHeight := (bmp_src.Height * LargeImages.Width) div bmp_src.Width;
    y := (LargeImages.Height - finalHeight) div 2;
   end
   else
   begin
    finalWidth  := (bmp_src.Width * LargeImages.Height) div bmp_src.Height;
    x := (LargeImages.Width - finalWidth) div 2;
   end;

   bitmap1.SetSize(finalWidth,finalHeight);
   bitmap1.Canvas.StretchDraw( Rect(0, 0, finalWidth , finalHeight ), bmp_src );

   copyPixels(bmp_dst,bitmap1,x,y);

   if countAlphas(bitmap1,0) >= finalWidth*finalHeight then
    setAlpha(bmp_dst,255,Rect(x, y, x+finalWidth , y+finalHeight));

   bitmap1.Free;

 end;

end;

end.