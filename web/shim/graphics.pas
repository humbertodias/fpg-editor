unit Graphics;

{$mode objfpc}

interface

uses
  Classes;

type
  TPixelFormat = (pfDevice, pf1bit, pf4bit, pf8bit, pf15bit, pf16bit, pf24bit, pf32bit, pfCustom);
  TColor = LongInt;

  TGraphic = class(TPersistent)
  public
    procedure LoadFromFile(const Filename: string); virtual;
    procedure SaveToFile(const Filename: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    class function GetFileExtensions: string; virtual;
  end;
  TGraphicClass = class of TGraphic;

  TBitmap = class(TGraphic)
  private
    FWidth: Integer;
    FHeight: Integer;
  public
    PixelFormat: TPixelFormat;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    procedure SetSize(AWidth, AHeight: Integer); virtual;
  end;

  TPicture = class
  public
    class procedure RegisterFileFormat(const Ext, Desc: string; AClass: TGraphicClass);
  end;

implementation

procedure TGraphic.LoadFromFile(const Filename: string);
begin
end;

procedure TGraphic.SaveToFile(const Filename: string);
begin
end;

procedure TGraphic.LoadFromStream(Stream: TStream);
begin
end;

procedure TGraphic.SaveToStream(Stream: TStream);
begin
end;

class function TGraphic.GetFileExtensions: string;
begin
  Result := '';
end;

procedure TBitmap.SetSize(AWidth, AHeight: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;
end;

class procedure TPicture.RegisterFileFormat(const Ext, Desc: string; AClass: TGraphicClass);
begin
end;

end.
