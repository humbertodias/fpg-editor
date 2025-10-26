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

unit uExportToFiles;

interface

uses LCLIntf, LCLType, ComCtrls, Forms, {Gauges,} Graphics, Controls, SysUtils, Classes,
     ClipBrd, FileUtil,
      uFPG, uPAL, uIniFile,
     uFrmMessageBox, uLanguage,
     //inserted by me
     uFrmExport, uFPGListView;

 procedure export_to_bmp( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
 procedure export_to_png( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
 procedure export_to_map( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );

 procedure export_DIV2_PAL( lvFPG: TFPGListView; path: string );
 procedure export_MS_PAL  ( lvFPG: TFPGListView; path: string );
 procedure export_PSP_PAL ( lvFPG: TFPGListView; path: string );

 procedure export_control_points( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );

implementation

procedure export_control_points( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 f : TextFile;
 i, j, k, icount: integer;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;


 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  for j := 1 to lvFPG.Fpg.Count do
   if lvFPG.Fpg.images[j].code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    if lvFPG.Fpg.images[j].CPointsCount <= 0 then
     continue;

    try
     AssignFile(f, path + lvFPG.Items.Item[i].Caption + '.cpt');
     Rewrite(f);
    except
     feMessageBox(LNG_ERROR, LNG_NOT_OPEN_FILE, 0, 0 );
     Exit;
    end;

    WriteLn(f, 'CTRL-PTS');

    WriteLn(f, lvFPG.Fpg.images[j].CPointsCount);

    for k := 0 to lvFPG.Fpg.images[j].CPointsCount - 1 do
    begin
     Write(f, lvFPG.Fpg.images[j].cpoints[k*2]); Write(f, ' ');
     WriteLn(f, lvFPG.Fpg.images[j].cpoints[(k*2) + 1]);
    end;

    CloseFile(f);

    break;
   end;

   gFPG.Position := (icount * 100) div lvFPG.SelCount;
   gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_to_bmp( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount : integer;
 imageName :String;
 bmp : TBitmap;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
  end;

  for j := 1 to lvFPG.Fpg.Count do
   if lvFPG.Fpg.images[j].code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imagename + '.bmp') { *Converted from FileExists*  } then
    begin

     if feMessageBox(LNG_WARNING, LNG_EXISTS_FILE_OVERWRITE, 4, 2) <> mrYes then
      break;
    end;
    bmp:=TBitmap.Create;
    bmp.Assign(lvFPG.Fpg.images[j]);
    bmp.SaveToFile(path + imagename + '.bmp');
    FreeAndNil(bmp);
    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_to_PNG( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount: integer;
 image :TPortableNetworkGraphic;
 imageName : String;
begin
 image := TPortableNetworkGraphic.Create;
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
   3: imageName:= lvFPG.Items.Item[i].SubItems[1];
   4: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[1] +')';
  end;

  for j := 1 to lvFPG.Fpg.Count do
   if lvFPG.Fpg.images[j].code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imageName + '.png') { *Converted from FileExists*  } then
    begin
     if feMessageBox(LNG_WARNING, LNG_EXISTS_FILE_OVERWRITE, 4, 2) <> mrYes then
      break;
    end;

    image.Assign(lvFPG.Fpg.images[j]);
    image.savetofile(path + imageName + '.png');

    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 image.Destroy;
 gFPG.Hide;
end;


procedure export_to_map( lvFPG: TFPGListView; path: string; var frmMain: TForm; var gFPG: TProgressBar );
var
 i, j, icount : integer;
 imageName :String;
begin
 icount := 1;

 gFPG.Position := 0;
 gFPG.Show;
 gFPG.Repaint;

 for i := 0 to lvFPG.Items.Count - 1 do
 begin
  if not lvFPG.Items.Item[i].Selected then
   continue;

  icount := icount + 1;

  case frmExport.rgFilename.ItemIndex of
   0: imageName:= lvFPG.Items.Item[i].Caption;
   1: imageName:= lvFPG.Items.Item[i].SubItems[0];
   2: imageName:= lvFPG.Items.Item[i].Caption +'(' + lvFPG.Items.Item[i].SubItems[0] +')';
  end;

  for j := 1 to lvFPG.Fpg.Count do
   if lvFPG.Fpg.images[j].code = StrToInt(lvFPG.Items.Item[i].Caption) then
   begin
    //Se comprueba si existe el fichero
    if FileExistsUTF8(path + imagename + '.map') { *Converted from FileExists*  } then
    begin

     if feMessageBox(LNG_WARNING, LNG_EXISTS_FILE_OVERWRITE, 4, 2) <> mrYes then
      break;
    end;

    //lvFPG.Fpg.images[j].bmp.SaveToFile(path + imagename + '.map');
     lvFPG.Fpg.SaveToFile(j,path + imagename + '.map');
    break;
   end;

  gFPG.Position := (icount * 100) div lvFPG.SelCount;
  gFPG.Repaint;
 end;

 gFPG.Hide;
end;

procedure export_DIV2_PAL( lvFPG: TFPGListView; path: string );
begin
 Save_DIV2_PAL(lvFPG.Fpg.palette, path + 'DIV2.pal' );
end;

procedure export_MS_PAL( lvFPG: TFPGListView; path: string );
begin
 Save_MS_PAL(lvFPG.Fpg.palette, path + 'MS.pal' );
end;

procedure export_PSP_PAL( lvFPG: TFPGListView; path: string );
begin
 Save_JASP_pal(lvFPG.Fpg.palette, path + 'PSP4.pal' );
end;

end.