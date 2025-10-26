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
 
unit uPCX;


interface

uses SysUtils, FileUtil, classes;

type
 uPCX_header = record
  manufacturer,
  version,
  encoding,
  bits_per_pixel : byte;
  xmin, ymin,
  xmax, ymax,
  hres,
  vres : word;
  palette16    : Array [0 .. 47] of byte;
  reserved,
  color_planes : byte; // (1) 8bits (3) 24 bits
  bytes_per_line,
  palette_type,
  Hresol,
  Vresol : word;
  filler : Array [0 .. 53] of byte;
 end;

var
 PCX_header : uPCX_header;
 //PCX_palette: Array [0 .. 767] of byte;

 function load_PCX_header(str : string): Boolean;

 function is_PCX : Boolean;

implementation

 function load_PCX_header(str : string): boolean;
 var
  f : TFileStream;
 begin
  result := false;

  if not FileExistsUTF8(str) { *Converted from FileExists*  } then
   Exit;

  f := TFileStream.Create(str, fmOpenRead);

  f.Read(PCX_header, SizeOf(uPCX_header));

  f.free;

  result := true;
 end;

 function is_PCX : Boolean;
 begin
  is_PCX := false;

  if (PCX_header.manufacturer = 10) and (PCX_header.version = 5) and
     (PCX_header.encoding = 1) and (PCX_header.bits_per_pixel = 8) and
     (PCX_header.color_planes = 1) then
   is_PCX := true;
 end;



end.