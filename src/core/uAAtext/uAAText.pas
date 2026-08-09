unit uAAText;

interface

 uses
  Graphics, sysutils, classes, IntfGraphics;

 const
  MAX_NUM_SUPERSAMPLING = 2;

 procedure DrawAAText(Dest: TBitmap; DX, DY: Integer; Text: String);

implementation

type
  TRGBTriple = record
   rgbtRed, rgbtGreen, rgbtBlue : Byte;
  end;

  pRGBLine = ^TRGBLine;
  TRGBLine = Array[Word] of TRGBTriple;

{Separate R, G and B values from the color}
  procedure SeparateColor(Color: TColor; var r: Byte; var g: byte; var b: byte);
  begin
    R := Color and $FF0000 shr 16;
    G := Color and $00FF00 shr 8;
    B := Color and $0000FF;
  end;


procedure DrawAAText(Dest: TBitmap; DX, DY: Integer; Text: String);

var
  TempBitmap: TBitmap;
  x, y      : Integer;
  totr,
  totg,
  totb      : Integer;
  j, i, l   : Integer;
  Line      : pRGBLine;
  TempLine  : Array[0..MAX_NUM_SUPERSAMPLING - 1] of pRGBLine;
  lazDest,lazTempBitmap : TLazIntfImage;
begin
  {Creates a temporary bitmap do work with supersampling}
  TempBitmap := TBitmap.Create;

  with TempBitmap do
  begin
    PixelFormat := pf24bit;

    {Copy attributes from previous bitmap}
    Canvas.Font.Assign(Dest.Canvas.Font);
    Canvas.Brush.Assign(Dest.Canvas.Brush);
    Canvas.Pen.Assign(Dest.Canvas.Pen);

    Canvas.Font.Size := Canvas.Font.Size * MAX_NUM_SUPERSAMPLING;

    {Make it twice larger to apply supersampling later}
    Width  := Canvas.TextWidth(Text);
    Height := Canvas.TextHeight(Text);

    {To prevent unexpected junk}
    if (Width div MAX_NUM_SUPERSAMPLING) + DX > Dest.Width then
      Width := (Dest.Width - DX) * MAX_NUM_SUPERSAMPLING;
    if (Height div MAX_NUM_SUPERSAMPLING) + DY > Dest.Height then
      Height := (Dest.Height - DY) * MAX_NUM_SUPERSAMPLING;


    {If the brush style is clear, then copy the image from the}
    {previous image to create the propher effect}
    if Canvas.Brush.Style = bsClear then
    begin
      Canvas.Draw(-DX, -DY, Dest);
      Canvas.Stretchdraw(Rect(0, 0, Width * MAX_NUM_SUPERSAMPLING, Height * MAX_NUM_SUPERSAMPLING), TempBitmap);
    end;

    {Draws the text using double size}
    Canvas.TextOut(0, 0, Text);
  end;

  {Draws the antialiased image}
  lazDest:=dest.CreateIntfImage;
  lazTempBitmap:=TempBitmap.CreateIntfImage;
  for y := 0 to ((TempBitmap.Height) div MAX_NUM_SUPERSAMPLING) - 1 do begin
    {If the y pixel is outside the clipping region, do the proper action}
    if dy + y < 0 then
      Continue
    else if Dy + y > Dest.Height - 1 then
      Break;

    {Scanline for faster access}
    Line := lazDest.GetDataLineStart(DY + y);

    for l := 0 to MAX_NUM_SUPERSAMPLING - 1 do
     TempLine[l] := lazTempBitmap.GetDataLineStart((MAX_NUM_SUPERSAMPLING*y) + l);

    for x := 0 to ((TempBitmap.Width) div MAX_NUM_SUPERSAMPLING) - 1 do begin

      {If the x pixel is outside the clipping region, do the proper
action}
      if dx + x < 0 then
        Continue
      else if Dx + x > Dest.Width - 1 then
        Break;

      {Compute the value of the output pixel (x, y) }
      TotR := 0;
      TotG := 0;
      TotB := 0;

      for j := 0 to MAX_NUM_SUPERSAMPLING - 1 do begin
        for i := 0 to MAX_NUM_SUPERSAMPLING - 1 do
          begin
            (*
            inc(TotR, TempLine[j][MAX_NUM_SUPERSAMPLING*x+i] .rgbtRed);
            inc(TotG, TempLine[j][MAX_NUM_SUPERSAMPLING*x+i].rgbtGreen);
            inc(TotB, TempLine[j][MAX_NUM_SUPERSAMPLING*x+i].rgbtBlue);
            *)
          end;
      end;

      {Set the pixel values thru scanline}
      with Line^[DX + x] do
      begin
        rgbtRed := TotR div (MAX_NUM_SUPERSAMPLING*MAX_NUM_SUPERSAMPLING);
        rgbtGreen := TotG div (MAX_NUM_SUPERSAMPLING*MAX_NUM_SUPERSAMPLING);
        rgbtBlue := TotB div (MAX_NUM_SUPERSAMPLING*MAX_NUM_SUPERSAMPLING);
      end;
    end;
  end;

  dest.LoadFromIntfImage(lazDest);
  {Free the temporary bitmap}
  lazdest.free;
  lazTempBitmap.free;
  TempBitmap.Free;
end;

end.
