unit LConvEncoding;

{$mode objfpc}

interface

function CP850ToUTF8(const S: string): string;
function ISO_8859_1ToUTF8(const S: string): string;

implementation

function CP850ToUTF8(const S: string): string;
begin
  Result := S;
end;

function ISO_8859_1ToUTF8(const S: string): string;
begin
  Result := S;
end;

end.
