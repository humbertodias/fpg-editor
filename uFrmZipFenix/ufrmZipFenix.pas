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

unit ufrmZipFenix;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls,
  StdCtrls, Buttons, FileCtrl, ExtCtrls, FileUtil, ShellCtrls, uFPG, ulanguage, uTools,
  uFrmMessageBox, uFNT, uMAPGraphic  ;

type

  { TfrmZipFenix }

  TfrmZipFenix = class(TForm)
    bbCompress: TBitBtn;
    dlb: TShellTreeView;
    flb: TShellListView;
    imgAnimate: TImage;
    lbZipFile: TLabel;
    Panel1: TPanel;
    fcb: TFilterComboBox;
    Panel2: TPanel;
    Panel3: TPanel;
    pZip: TPanel;
    Splitter1: TSplitter;
    statusbar: TStatusBar;
    procedure dlbChange(Sender: TObject; Node: TTreeNode);
    procedure flbChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure flbClick(Sender: TObject);
    procedure bbCompressClick(Sender: TObject);
    procedure flbSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
   old_file_size : Longint;
  end;

var
  frmZipFenix: TfrmZipFenix;

implementation

{$R *.lfm}

function FileExists(FileName: string): Boolean;

{ Boolean function that returns True if the file exists; otherwise,
  it returns False. Closes the file if it exists. }
var
  F: file;
begin
  {$I-}
  AssignFile(F, FileName);
  FileMode := 0;  { Set file access to read only }
  Reset(F);
  CloseFile(F);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

procedure TfrmZipFenix.flbClick(Sender: TObject);
var
 f : File of byte;
 filename : String;
begin
  if flb.Selected <> nil then
  begin
   filename:= flb.Root + DirectorySeparator+ flb.Selected.Caption;
   statusbar.Panels.Items[0].Text := filename;

   AssignFile(f, FileName);
   Reset(f);
   old_file_size := FileSize(FileName);
   CloseFile(f);

   statusbar.Panels.Items[1].Text := IntToStr(old_file_size) + ' Bytes';
   bbCompress.Enabled:=true;
  end else begin
   bbCompress.Enabled:=false;
  end;
end;

procedure TfrmZipFenix.flbChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  bbCompress.Enabled:=(flb.Selected <> nil);
end;

procedure TfrmZipFenix.dlbChange(Sender: TObject; Node: TTreeNode);
begin
   bbCompress.Enabled:=(flb.Selected <> nil);
end;


procedure TfrmZipFenix.bbCompressClick(Sender: TObject);
var
 f : File of Byte;
 f1: TFileStream;
 uncompressed : Boolean;
 filename : String;

begin
 uncompressed := false;

 if flb.ItemIndex = -1 then
   Exit;

 filename := flb.Root + DirectorySeparator+ flb.selected.caption;

 if not FileExists(filename) then
  Exit;

 uncompressed:=TFPG.Test(filename);
 if not uncompressed then
   uncompressed:=TMAPGraphic.test(filename);
 if not uncompressed then
   uncompressed:=FNT_Test(filename);

 if not uncompressed then
 begin
  feMessageBox(LNG_ERROR, LNG_NOTFPG, 0, 0);
  Exit;
 end;

 pZip.Visible := true;

 {$IFDEF WINDOWS}
   RunExe(ExtractFileDir(Application.ExeName) + DirectorySeparator+'zlib'+DirectorySeparator+'zlib.exe -6 "'+ FileName + '"', GetTempDir(False)  );
 {$ENDIF}

 {$IFDEF Linux}
   RunExe('/bin/gzip -nc "'+ FileName + '"', GetTempDir(False),FileName +'.gz' );
 {$ENDIF}


 f1 := TFileStream.Create(FileName + '.gz', fmOpenRead);

 old_file_size := f1.Size;
 f1.free;

 AssignFile(f, FileName);
 Erase(f);

 RenameFileUTF8(FileName + '.gz',FileName); { *Converted from RenameFile*  }

 statusbar.Panels.Items[1].Text := IntToStr(old_file_size) + ' Bytes';

 pZip.Visible := False;
 flb.Refresh;
end;

procedure TfrmZipFenix.flbSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
    if not Selected then
      exit;
    bbCompress.Enabled:=(flb.Selected <> nil);
end;


end.
