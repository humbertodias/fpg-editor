(*
 *  FPG EDIT : Edit FPG file from DIV2, FENIX and CDIV 
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 *)
 
unit uSort;


interface
 type
  Table_Sort = record
   nSort, nLink : LongWord;
  end;

 function SortCompare( item1, item2 : Pointer ): integer;

implementation
 function SortCompare( item1, item2 : Pointer ): integer;
 begin
  if Table_Sort(item1^).nSort < Table_Sort(item2^).nSort then
   result := -1
  else if Table_Sort(item1^).nSort > Table_Sort(item2^).nSort then
   result := 1
  else
   result := 0;
 end;

(*procedure Sort(var A: array of Table_Sort);
var
  I, J : LongWord;
  T    : Table_Sort;
begin
  for I := Low(A) to High(A) - 1 do
    for J := High(A) downto I + 1 do
      if A[I].nSort > A[J].nSort then
      begin
        T    := A[I];
        A[I] := A[J];
        A[J] := T;
      end;
end;*)


end.
