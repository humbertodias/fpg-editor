unit uimagedata;

{$mode objfpc}

{ pas2js 3.2 declares ImageData in weborworker, which the Web unit does not re-export. }

interface

uses
  JS, weborworker;

type
  TFenixImageData = TJSImageData;

function NewImageData(Pixels: TJSUint8ClampedArray; W, H: Integer): TFenixImageData;

implementation

function NewImageData(Pixels: TJSUint8ClampedArray; W, H: Integer): TFenixImageData;
begin
  Result := TJSImageData.new(Pixels, W, H);
end;

end.
