unit uColorTable;

{$mode objfpc}{$H+}

interface

 uses
  uFNT;

 var
  Color_Table : array [0 .. 31, 0 .. 63, 0 .. 31] of LongWord;
  Color_Table_16_to_8 : array [0 .. 31, 0 .. 63, 0 .. 31] of Byte;

 procedure Init_Color_Table;
 procedure Init_Color_Table_16_to_8;
 procedure Init_Color_Table_With_Palette;

implementation

 procedure Init_Color_Table;
 var
  r, g, b : byte;
 begin
  for r := 0 to 31 do
   for g := 0 to 63 do
    for b := 0 to 31 do
     Color_Table[r, g, b] := 0;
 end;

 procedure Init_Color_Table_16_to_8;
 var
  r, g, b : byte;
 begin
  for r := 0 to 31 do
   for g := 0 to 63 do
    for b := 0 to 31 do
     Color_Table_16_to_8[r, g, b] := 0;
 end;

 procedure Init_Color_Table_With_Palette;
 var
  i : LongInt;
 begin
  for i := 0 to 255 do
   Color_Table_16_to_8[ fnt_container.header.palette[  i * 3      ] shr 3,
                        fnt_container.header.palette[ (i * 3) + 1 ] shr 2,
                        fnt_container.header.palette[ (i * 3) + 2 ] shr 3] := i;
 end;

end.
