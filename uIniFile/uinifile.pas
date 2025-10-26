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
 
unit uinifile;

{$mode objfpc}{$H+}


interface

uses inifiles, SysUtils, graphics, LCLIntf, LCLType, Forms, FileUtil;

const
 sINIFILE         =  DirectorySeparator+'fpg-editor.ini';
 sDEFAULT_LNG     = DirectorySeparator+'lng'+DirectorySeparator+'Spanish.ini';

 sMAIN            = 'FPG';
 sFONT            = 'FNT';
 sSIZE_OF_ICON    = 'Size of icon';
 sAUTOLOAD_IMAGES = 'Autoload images';
 sRELOAD_REMOVE   = 'Reload remove images';
 sVIEW_FLAT       = 'Show flat';
 sVIEW_SPLASH     = 'Show SPLASH screen';
 sCOLOR_POINTS    = 'Color points';
 sIMAGES_PAINT    = 'Number of images to repaint';
 sANIMATE_DELAY   = 'Animate delay';
 sLANGUAGE        = 'Language';
 sEDIT_PROGRAM    = 'External edit program';
 sBG_COLOR        = 'Background Color';
 sBG_COLOR_FPG        = 'FPG Background Color';

var
 inifile_program_edit    : string;
 inifile_language        : string;
 inifile_autoload_images,
 inifile_autoload_remove,
 inifile_show_splash,     
 inifile_show_flat       : boolean;
 inifile_sizeof_icon,
 inifile_repaint_number,
 inifile_color_points,
 inifile_animate_delay : longint;
 inifile_bg_color : TColor;
 inifile_bg_colorFPG : TColor;

 inifile_charset_to_gen,
 inifile_fnt_charset,
 inifile_fnt_height,
 inifile_fnt_size,
 inifile_fnt_effects : longint;
 inifile_fnt_name    : string;
 inifile_symbol_type,
 inifile_edge_size,
 inifile_shadow_pos,
 inifile_shadow_offset,
 inifile_fnt_color,
 inifile_edge_color,
 inifile_shadow_color,
 inifile_bgcolor : longint;
 inifile_fnt_image,
 inifile_edge_image,
 inifile_shadow_image : string;
 inifile_admin_tools: Integer;
 alpha_font, alpha_edge,alpha_shadow :integer;

 procedure load_inifile;
 procedure write_inifile;
 procedure inifile_load_font( var nFnt : TFont );


implementation



procedure inifile_load_font( var nFnt : TFont );
var
  lf: LOGFONT; // Windows native font structure
begin
  FillChar(lf, SizeOf(lf), Byte(0));

  lf.lfHeight := inifile_fnt_height;
  lf.lfCharSet := inifile_fnt_charset;
  
  StrCopy(lf.lfFaceName, PChar(inifile_fnt_name));

  nFnt.Handle := CreateFontIndirect(lf);
end;
 
procedure load_inifile;
var
 inifile : TIniFile;
 strinifile : string;
 
begin

 strinifile := ExtractFileDir( ParamStr(0) ) + sINIFILE;

 if not FileExistsUTF8(strinifile) { *Converted from FileExists*  } then
 begin
  inifile_sizeof_icon     := 50;
  inifile_autoload_images := true;
  inifile_autoload_remove := false;
  inifile_color_points    := clBlack;
  inifile_repaint_number  := 20;
  inifile_animate_delay   := 100;
  inifile_language        := ExtractFileDir(Application.ExeName) + sDEFAULT_LNG;
  inifile_program_edit    := ExtractFileDir( ParamStr(0) ) + DirectorySeparator+'myprogram.exe';
  inifile_show_flat       := true;
  inifile_show_splash     := true;
  inifile_bg_color        := clWhite;
  inifile_bg_colorFPG        := clWhite;

  inifile_fnt_charset := DEFAULT_CHARSET;
  inifile_charset_to_gen := 0;
  inifile_fnt_height  := -11;
  inifile_fnt_effects := 0; // 0-Normal 1-Negrita 2-Subrayado 3-Tachado
  inifile_fnt_size    := 8;
  inifile_fnt_name    := 'Arial';
  inifile_symbol_type := 15; //1+2+4+8
  inifile_edge_size   := 0;
  inifile_shadow_pos  := 8;   //123 4-5 678
  inifile_shadow_offset := 0;
  inifile_fnt_color    := clWhite;
  inifile_edge_color   := clBlue;
  inifile_shadow_color := 8;
  inifile_bgcolor      := clBtnFace;
  inifile_fnt_image    := '';
  inifile_edge_image   := '';
  inifile_shadow_image := '';
  inifile_admin_tools := 0;

  write_inifile;
  
 end
 else
 begin
  inifile := TIniFile.Create(strinifile);

  inifile_sizeof_icon     := inifile.ReadInteger( sMAIN, sSIZE_OF_ICON   , 50);
  inifile_autoload_images := inifile.ReadBool   ( sMAIN, sAUTOLOAD_IMAGES, true);
  inifile_autoload_remove := inifile.ReadBool   ( sMAIN, sRELOAD_REMOVE  , false);
  inifile_show_flat       := inifile.ReadBool   ( sMAIN, sVIEW_FLAT      , false);
  inifile_show_splash     := inifile.ReadBool   ( sMAIN, sVIEW_SPLASH    , false);
  inifile_color_points    := inifile.ReadInteger( sMAIN, sCOLOR_POINTS   , 0);
  inifile_repaint_number  := inifile.ReadInteger( sMAIN, sIMAGES_PAINT   , 20);
  inifile_animate_delay   := inifile.ReadInteger( sMAIN, sANIMATE_DELAY  , 100);
  inifile_language        := inifile.ReadString ( sMAIN, sLANGUAGE       , ExtractFileDir(Application.ExeName) + sDEFAULT_LNG);
  inifile_program_edit    := inifile.ReadString ( sMAIN, sEDIT_PROGRAM   , ExtractFileDir(ParamStr(0)) + DirectorySeparator+'myprogram.exe');
  inifile_bg_color        := inifile.ReadInteger( sMAIN, sBG_COLOR   , clWhite);
  inifile_bg_colorFPG        := inifile.ReadInteger( sMAIN, sBG_COLOR_FPG   , clWhite);
  inifile_admin_tools  := inifile.ReadInteger(sMAIN, 'ADMIN TOOLS', 0);


  inifile_fnt_charset   := inifile.ReadInteger(sFONT, 'CHARSET', DEFAULT_CHARSET);
  inifile_charset_to_gen:= inifile.ReadInteger(sFONT, 'CHARSET TO GEN', 0);
  inifile_fnt_height    := inifile.ReadInteger(sFONT, 'HEIGHT' , -11);
  inifile_fnt_size      := inifile.ReadInteger(sFONT, 'SIZE' , 8);
  inifile_fnt_effects   := inifile.ReadInteger(sFONT, 'EFFECTS', 0);
  inifile_fnt_name      := inifile.ReadString (sFONT, 'NAME', 'Arial');
  inifile_symbol_type   := inifile.ReadInteger(sFONT, 'SYMBOL TYPE', 15);
  inifile_edge_size     := inifile.ReadInteger(sFONT, 'EDGE SIZE', 0);
  inifile_shadow_pos    := inifile.ReadInteger(sFONT, 'SHADOW POSITION', 0);
  inifile_shadow_offset := inifile.ReadInteger(sFONT, 'SHADOW OFFSET', 0);
  inifile_fnt_color     := inifile.ReadInteger(sFONT, 'FONT COLOR', clWhite);
  inifile_edge_color    := inifile.ReadInteger(sFONT, 'EDGE COLOR', clBlue);
  inifile_shadow_color  := inifile.ReadInteger(sFONT, 'SHADOW COLOR', 8);
  inifile_bgcolor       := inifile.ReadInteger(sFONT, 'BACKGROUND COLOR', clBtnFace);
  inifile_fnt_image     := inifile.ReadString (sFONT, 'FONT IMAGE'  , '');
  inifile_edge_image    := inifile.ReadString (sFONT, 'EDGE IMAGE'  , '');
  inifile_shadow_image  := inifile.ReadString (sFONT, 'SHADOW IMAGE', '');

  
  inifile.Destroy;
 end;
end;

procedure write_inifile;
var
 inifile : TIniFile;
 strinifile : String;
begin
 strinifile := ExtractFileDir( ParamStr(0) ) + sINIFILE;

 inifile := TIniFile.Create(strinifile);

 inifile.WriteInteger( sMAIN, sSIZE_OF_ICON   , inifile_sizeof_icon);
 inifile.WriteBool   ( sMAIN, sAUTOLOAD_IMAGES, inifile_autoload_images);
 inifile.WriteBool   ( sMAIN, sRELOAD_REMOVE  , inifile_autoload_remove);
 inifile.WriteBool   ( sMAIN, sVIEW_FLAT      , inifile_show_flat);
 inifile.WriteBool   ( sMAIN, sVIEW_SPLASH    , inifile_show_splash);
 inifile.WriteInteger( sMAIN, sCOLOR_POINTS   , inifile_color_points);
 inifile.WriteInteger( sMAIN, sIMAGES_PAINT   , inifile_repaint_number);
 inifile.WriteInteger( sMAIN, sANIMATE_DELAY  , inifile_animate_delay);
 inifile.WriteString ( sMAIN, sLANGUAGE       , inifile_language);
 inifile.WriteString ( sMAIN, sEDIT_PROGRAM   , inifile_program_edit);
 inifile.WriteInteger( sMAIN, sBG_COLOR   , inifile_bg_color);
 inifile.WriteInteger( sMAIN, sBG_COLOR_FPG   , inifile_bg_colorFPG);
 inifile.WriteInteger (sMAIN, 'ADMIN TOOLS', inifile_admin_tools);

  inifile.WriteInteger(sFONT, 'CHARSET', inifile_fnt_charset);
  inifile.WriteInteger(sFONT, 'CHARSET TO GEN', inifile_charset_to_gen);
  inifile.WriteInteger(sFONT, 'HEIGHT' , inifile_fnt_height);
  inifile.WriteInteger(sFONT, 'SIZE' , inifile_fnt_size);
  inifile.WriteInteger(sFONT, 'EFFECTS', inifile_fnt_effects);
  inifile.WriteString (sFONT, 'NAME'   , inifile_fnt_name);
  inifile.WriteInteger(sFONT, 'SYMBOL TYPE', inifile_symbol_type);
  inifile.WriteInteger(sFONT, 'EDGE SIZE'  , inifile_edge_size);
  inifile.WriteInteger(sFONT, 'SHADOW POSITION', inifile_shadow_pos);
  inifile.WriteInteger(sFONT, 'SHADOW OFFSET'  , inifile_shadow_offset);
  inifile.WriteInteger(sFONT, 'FONT COLOR', inifile_fnt_color);
  inifile.WriteInteger(sFONT, 'EDGE COLOR', inifile_edge_color);
  inifile.WriteInteger(sFONT, 'SHADOW COLOR', inifile_shadow_color);
  inifile.WriteInteger(sFONT, 'BACKGROUND COLOR', inifile_bgcolor);
  inifile.WriteString (sFONT, 'FONT IMAGE'  , inifile_fnt_image);
  inifile.WriteString (sFONT, 'EDGE IMAGE'  , inifile_edge_image);
  inifile.WriteString (sFONT, 'SHADOW IMAGE', inifile_shadow_image);

 
 inifile.Destroy;
end;

end.