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

unit uFrmExport;


interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, 
   uIniFile, ShellCtrls;

type

  { TfrmExport }

  TfrmExport = class(TForm)
    bbExport: TBitBtn;
    gbImages: TGroupBox;
    DirectoryListBox1: TShellTreeView ;
    Panel1: TPanel;
    rgResType: TRadioGroup;
    rgFilename: TRadioGroup;
    procedure bbExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    _lng_str : string;

    procedure _set_lng;
  public
    last_itemindex: integer;
    { Public declarations }
  end;

var
  frmExport: TfrmExport;

implementation

{$R *.lfm}

procedure TfrmExport._set_lng;
begin
 if _lng_str = inifile_language then
  Exit;

 _lng_str := inifile_language;
end;

procedure TfrmExport.FormCreate(Sender: TObject);
begin
 last_itemindex := 0;
end;

procedure TfrmExport.bbExportClick(Sender: TObject);
begin

end;

procedure TfrmExport.FormDeactivate(Sender: TObject);
begin
 last_itemindex := rgResType.ItemIndex;
end;

procedure TfrmExport.FormActivate(Sender: TObject);
begin
 _set_lng;
end;

end.