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
 
unit ufrmFPGImages;

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms,
  Buttons, ComCtrls, StdCtrls, uFPG, ExtCtrls, uinifile, Dialogs,
  uFrmMessageBox, uLanguage,umainmap, uMAPGraphic, uFrmPalette;

type

  { TfrmFPGImages }

  TfrmFPGImages = class(TForm)
    bbAceptChanges: TBitBtn;
    bbCancelChanges: TBitBtn;
    bmodify: TButton;
    tAddControlPoints: TTimer;
    ColorDialog: TColorDialog;
    OpenDialog: TOpenDialog;
    PageControl1: TPageControl;
    tsProperties: TTabSheet;
    Panel2: TPanel;
    lb_heigth: TLabel;
    lb_width: TLabel;
    lbWidth: TLabel;
    lbHeight: TLabel;
    lb_ctrl_points: TLabel;
    lbNumCP: TLabel;
    Panel1: TPanel;
    imIcon: TImage;
    gbCode: TGroupBox;
    edCode: TEdit;
    gbFName: TGroupBox;
    edFName: TEdit;
    gbName: TGroupBox;
    edName: TEdit;
    tsControlPoints: TTabSheet;
    lvControlPoints: TListView;
    GroupBox5: TGroupBox;
    edCoordX: TEdit;
    GroupBox6: TGroupBox;
    edCoordY: TEdit;
    sbDelete: TSpeedButton;
    sbEdit: TSpeedButton;
    sbAdd: TSpeedButton;
    sbSetCenter: TSpeedButton;
    sbImageSelect: TSpeedButton;
    sbViewControlPoints: TSpeedButton;
    sbChangeColor: TSpeedButton;
    sbRemoveAll: TSpeedButton;
    sbLoadCP: TSpeedButton;
    pHook: TPanel;
    rbTL: TRadioButton;
    rbTM: TRadioButton;
    rbTR: TRadioButton;
    rbML: TRadioButton;
    rbMM: TRadioButton;
    rbMR: TRadioButton;
    rbDL: TRadioButton;
    rbDM: TRadioButton;
    rbDR: TRadioButton;
    sbSetControlPoint: TSpeedButton;
    sbAddPoint: TSpeedButton;
    sbPutCenter: TSpeedButton;
    procedure bmodifyClick(Sender: TObject);
    procedure edCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edCodeExit(Sender: TObject);
    procedure bbAceptChangesClick(Sender: TObject);
    procedure edCoordXExit(Sender: TObject);
    procedure edCoordYExit(Sender: TObject);
    procedure sbAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvControlPointsDblClick(Sender: TObject);
    procedure sbEditClick(Sender: TObject);
    procedure sbDeleteClick(Sender: TObject);
    procedure sbImageSelectClick(Sender: TObject);
    procedure tAddControlPointsTimer(Sender: TObject);
    procedure sbViewControlPointsClick(Sender: TObject);
    procedure sbRemoveAllClick(Sender: TObject);
    procedure sbChangeColorClick(Sender: TObject);
    procedure sbSetCenterClick(Sender: TObject);
    procedure sbLoadCPClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure sbAddPointClick(Sender: TObject);
    procedure sbPutCenterClick(Sender: TObject);
    procedure edCodeEnter(Sender: TObject);
    procedure edFNameEnter(Sender: TObject);
    procedure edFNameExit(Sender: TObject);
    procedure edNameEnter(Sender: TObject);
    procedure edNameExit(Sender: TObject);
    procedure edCoordXEnter(Sender: TObject);
    procedure edCoordYEnter(Sender: TObject);
  private
    { Private declarations }
    _lng_str : string;

    procedure _set_lng;
  public
    { Public declarations }
    fpg_index : word;

    myUpdate : boolean;
    fpg: TFpg;

    procedure getRBPoint(bmp: TBitmap; var x, y: Longint);
  end;

var
  frmFPGImages: TfrmFPGImages;

implementation

uses ufrmView;

{$R *.lfm}

procedure TfrmFPGImages._set_lng;
begin
 if _lng_str = inifile_language then Exit;

 _lng_str := inifile_language;

 (*
 lvControlPoints.Columns[0].Caption := LNG_PROPERTIES_;
 sbDelete.Hint := LNG_NUMBER;
 sbEdit.Hint := LNG_ADD_CONTROL_POINT;
 sbAdd.Hint := LNG_DELETE_CONTROL_POINT;
 *)

end;

procedure TfrmFPGImages.edCodeKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
 else
  key := chr(13);
 end;
end;

procedure TfrmFPGImages.bmodifyClick(Sender: TObject);
begin
 frmMapEditor.MenuItem2.Visible:=false;
 frmMapEditor.MenuItem3.Visible:=false;
 frmMapEditor.MenuItem4.Caption:= LNG_EXPORT;
 fpg.images[fpg_index].bPalette:=fpg.Palette;
 fpg.images[fpg_index].Gamuts:=fpg.Gamuts;
 frmMapEditor.imageSource:=fpg.images[fpg_index];
 frmMapEditor.scrlbxImage.Color:=panel1.Color;
 frmMapEditor.cbBackground.ButtonColor:=panel1.Color;
 frmMapEditor.ShowModal;
 imIcon.Picture.Assign(fpg.images[fpg_index]);
 fpg.Palette:=fpg.images[fpg_index].bPalette;
 fpg.Gamuts:=fpg.images[fpg_index].Gamuts;
end;

procedure TfrmFPGImages.edCodeExit(Sender: TObject);
begin
 edCode.Color := clMedGray;

 if StrToInt(edCode.Text) <> Fpg.images[fpg_index].code then
  if Fpg.CodeExists(StrToInt(edCode.Text)) then
  begin
   feMessageBox(LNG_ERROR, LNG_EXIST_CODE, 0, 0);
   edCode.SetFocus;
   Exit;
  end;
end;

procedure TfrmFPGImages.bbAceptChangesClick(Sender: TObject);
var
 j : word;
begin
// Fpg.images[fpg_index].Assign(imIcon.Picture.Bitmap);
 if StrToInt(edCode.Text) <> Fpg.images[fpg_index].code then
  if Fpg.CodeExists(StrToInt(edCode.Text)) then
  begin
   feMessageBox(LNG_ERROR, LNG_EXIST_CODE, 0, 0);
   edCode.SetFocus;
   Exit;
  end;

 Fpg.update := true;

 if StrToInt(edCode.Text) < 10 then
  edCode.Text := '00' + edCode.Text
 else if StrToInt(edCode.Text) < 100 then
  edCode.Text := '0'  + edCode.Text;

 Fpg.images[fpg_index].code  := StrToInt(edCode.Text);

 Fpg.images[fpg_index].fpname:=edFName.Text;
 Fpg.images[fpg_index].name:=edName.Text;

 Fpg.images[fpg_index].CPointsCount := lvControlPoints.Items.Count;

 if lvControlPoints.Items.Count > 0 then
  for j := 0 to lvControlPoints.Items.Count - 1 do
  begin
   Fpg.images[fpg_index].cpoints[j * 2] :=
    StrToInt(lvControlPoints.Items.Item[j].SubItems.Strings[0]);
   Fpg.images[fpg_index].cpoints[(j * 2) + 1] :=
    StrToInt(lvControlPoints.Items.Item[j].SubItems.Strings[1]);
  end;

 frmFPGImages.ModalResult := mrYes;
end;

procedure TfrmFPGImages.edCoordXExit(Sender: TObject);
begin
 edCoordX.Color := clMedGray;

 if Length(edCoordX.Text) = 0 then
  Exit;
end;

procedure TfrmFPGImages.edCoordYExit(Sender: TObject);
begin
 edCoordY.Color := clMedGray;

 if Length(edCoordY.Text) = 0 then
  Exit;
end;


procedure TfrmFPGImages.sbAddClick(Sender: TObject);
var
 list_add : TListItem;
begin
 if Length(edCoordX.Text) = 0 then
 begin
  feMessageBox( LNG_WARNING, LNG_INSERT_COORD + ' X.', 0, 0);
  edCoordX.SetFocus;
  Exit;
 end;
 
 if Length(edCoordY.Text) = 0 then
 begin
  feMessageBox( LNG_WARNING, LNG_INSERT_COORD + ' Y.', 0, 0);
  edCoordY.SetFocus;
  Exit;
 end;

 if myUpdate then
 begin
  list_add := lvControlPoints.Selected;
  myUpdate := false;

  list_add.SubItems.Strings[0] := edCoordX.Text;
  list_add.SubItems.Strings[1] := edCoordY.Text;

  edCoordX.Color := clMedGray;
  edCoordY.Color := clMedGray;
  sbDelete.Enabled := true;
 end
 else
 begin
  list_add := lvControlPoints.Items.Add;

  if (lvControlPoints.Items.Count - 1)  < 10 then
   list_add.Caption := '00' + IntToStr(lvControlPoints.Items.Count - 1)
  else if (lvControlPoints.Items.Count - 1) < 100 then
   list_add.Caption := '0'  + IntToStr(lvControlPoints.Items.Count - 1)
  else
   list_add.Caption := IntToStr(lvControlPoints.Items.Count - 1);

  list_add.SubItems.Add( edCoordX.Text );
  list_add.SubItems.Add( edCoordY.Text );
 end;


end;

procedure TfrmFPGImages.FormShow(Sender: TObject);
var
 i, j :word;
 list_add : TListItem;
begin
 lbWidth.Caption  := IntToStr(Fpg.images[fpg_index].width);
 lbHeight.Caption := IntToStr(Fpg.images[fpg_index].height);
 lbNumCP.Caption  := IntToStr(Fpg.images[fpg_index].CPointsCount);
 imIcon.Picture.Assign( Fpg.images[fpg_index]);;
 edCode.Text := IntToStr(Fpg.images[fpg_index].code);
 edFName.Text := Fpg.images[fpg_index].fpname;
 edName.Text := Fpg.images[fpg_index].name;

 lvControlPoints.Items.Clear;

 if Fpg.images[fpg_index].CPointsCount >= 1 then
  for j := 0 to Fpg.images[fpg_index].CPointsCount - 1 do
  begin
     list_add := frmFPGImages.lvControlPoints.Items.Add;

     if j < 10 then
      list_add.Caption := '00' + IntToStr(j)
     else if j < 100 then
      list_add.Caption := '0'  + IntToStr(j)
     else
      list_add.Caption := IntToStr(j);

     list_add.SubItems.Add( IntToStr(Fpg.images[fpg_index].cpoints[j * 2]));
     list_add.SubItems.Add( IntToStr(Fpg.images[fpg_index].cpoints[(j * 2) + 1]));
  end;


 myUpdate := false;
 edCoordX.Color := clMedGray;
 edCoordY.Color := clMedGray;
 sbDelete.Enabled := true;



 for i := 2 to 17 do
   for j := 2 to 17 do
    sbChangecolor.Glyph.Canvas.Pixels[i,j] :=  inifile_color_points;


end;

procedure TfrmFPGImages.lvControlPointsDblClick(Sender: TObject);
begin
 if lvControlPoints.SelCount <> 1 then
  Exit;

 if not myUpdate then
 begin
  edCoordX.Text := lvControlPoints.Selected.SubItems.Strings[0];
  edCoordY.Text := lvControlPoints.Selected.SubItems.Strings[1];
  edCoordX.Color := clTeal;
  edCoordY.Color := clTeal;
  sbDelete.Enabled := false;
 end
 else
 begin
  edCoordX.Color := clMedGray;
  edCoordY.Color := clMedGray;
  sbDelete.Enabled := true;
 end;

 myUpdate := not myUpdate;
end;

procedure TfrmFPGImages.sbEditClick(Sender: TObject);
begin
 if lvControlPoints.SelCount <> 1 then
  Exit;

 lvControlPointsDblClick(Sender);
end;

procedure TfrmFPGImages.sbDeleteClick(Sender: TObject);
var
 i : word;
begin
 if lvControlPoints.SelCount <> 1 then
  Exit;

 lvControlPoints.Items.Delete(lvControlPoints.Selected.Index);

 if lvControlPoints.Items.Count <= 0 then
  Exit;

 for i := 0 to lvControlPoints.Items.Count - 1 do
  if i < 10 then
   lvControlPoints.Items.Item[i].Caption := '00' + IntToStr(i)
  else if i < 100 then
   lvControlPoints.Items.Item[i].Caption := '0'  + IntToStr(i)
  else
   lvControlPoints.Items.Item[i].Caption := IntToStr(i);
end;




procedure TfrmFPGImages.sbImageSelectClick(Sender: TObject);
var
 i : integer;
 pointX, pointY : integer;
begin
 frmView.control_points := true;

 frmView.FPG := true;
 frmView.Image.Picture.Assign(Fpg.images[fpg_index]);;

 for i := 0 to lvControlPoints.Items.Count - 1 do
 begin
  pointX := StrToInt(lvControlPoints.Items.Item[i].SubItems[0]);
  pointY := StrToInt(lvControlPoints.Items.Item[i].SubItems[1]);

  if( (pointX >= 0) and (pointX < frmView.Image.Picture.Bitmap.width) and
      (pointY >= 0) and (pointY < frmView.Image.Picture.Bitmap.height) ) then
  begin
   frmView.paintCross(frmView.Image.Picture.Bitmap,pointX,pointY,inifile_color_points);
  end;
 end;

 frmView.Show;

 tAddControlPoints.Enabled := true;
end;

procedure TfrmFPGImages.tAddControlPointsTimer(Sender: TObject);
begin
 tAddControlPoints.Enabled := frmView.control_points;

 if( frmView.point_active ) then
 begin
  edCoordX.Text := IntToStr( frmView.pointX );
  edCoordY.Text := IntToStr( frmView.pointY );
  sbAddClick( Sender );
  frmView.point_active := false;
 end;
end;


procedure TfrmFPGImages.sbViewControlPointsClick(Sender: TObject);
var
 i : integer;
 pointX, pointY : integer;
begin
 frmView.FPG := true;

 //frmView.Image1.Picture.Bitmap.Width := graph_width;
 //frmView.Image1.Picture.Bitmap.Height:= graph_height;

 frmView.Image.Picture.assign (Fpg.images[fpg_index]);


 for i := 0 to lvControlPoints.Items.Count - 1 do
 begin
  pointX := StrToInt(lvControlPoints.Items.Item[i].SubItems[0]);
  pointY := StrToInt(lvControlPoints.Items.Item[i].SubItems[1]);

  if( (pointX >= 0) and (pointX < frmView.Image.Picture.Bitmap.width) and
      (pointY >= 0) and (pointY < frmView.Image.Picture.Bitmap.height) ) then
   begin
     frmView.paintCross(frmView.Image.Picture.Bitmap,pointX,pointY,inifile_color_points);
   end;
 end;

 frmView.Show;
end;


procedure TfrmFPGImages.sbRemoveAllClick(Sender: TObject);
begin
 if lvControlPoints.Items.Count > 0 then
 begin
  if( feMessageBox(LNG_WARNING, LNG_SURE_DELETE_ALLPOINTS, 4, 2) = mrYes )then
   lvControlPoints.Items.Clear;
 end;
end;

procedure TfrmFPGImages.sbChangeColorClick(Sender: TObject);
var
 i, j: word;
begin
 if ColorDialog.Execute then
 begin
  inifile_color_points := ColorDialog.Color;

  for i := 2 to 17 do
   for j := 2 to 17 do
    sbChangecolor.Glyph.Canvas.Pixels[i,j] :=  inifile_color_points;
    
  write_inifile;
 end;
end;

procedure TfrmFPGImages.sbSetCenterClick(Sender: TObject);
var
 list_add : TListItem;
 x, y     : LongInt;
begin
 x := (Fpg.images[fpg_index].Width  div 2) - 1;
 y := (Fpg.images[fpg_index].Height div 2) - 1;

 if lvControlPoints.Items.Count > 0 then
 begin
  list_add := lvControlPoints.Items.Item[0];

  list_add.SubItems.Strings[0] := IntToStr( x );
  list_add.SubItems.Strings[1] := IntToStr( y );
 end
 else
 begin
  list_add := lvControlPoints.Items.Add;
  
  lvControlPoints.Items.Item[0].Caption := '000';
  list_add.SubItems.Add( IntToStr( x ) );
  list_add.SubItems.Add( IntToStr( y ) );
 end;
end;

procedure TfrmFPGImages.sbLoadCPClick(Sender: TObject);
var
 f : TextFile;
 strin : string;
 n_points, x, y, i : integer;
 list_add : TListItem;
begin
 if OpenDialog.Execute then
 begin
   try
    AssignFile(f, OpenDialog.FileName);
    Reset(f);
   except
    feMessageBox( LNG_ERROR, LNG_NOT_OPEN_FILE, 0, 0 );
    Exit;
   end;

   ReadLn(f, strin);

   if AnsiPos('CTRL-PTS',strin) <= 0 then
   begin
    CloseFile(f);
    Exit;
   end;

   ReadLn(f, n_points);

   for i := 0 to n_points - 1 do
   begin
    Read(f, x); ReadLn(f, y);

    list_add := lvControlPoints.Items.Add;

    if i < 10 then
     list_add.Caption := '00' + IntToStr(i)
    else if i < 100 then
     list_add.Caption := '0'  + IntToStr(i)
    else
     list_add.Caption := IntToStr(i);

    list_add.SubItems.Add( IntToStr(x) );
    list_add.SubItems.Add( IntToStr(y) );
   end;

   CloseFile(f);
 end;
end;

procedure TfrmFPGImages.FormActivate(Sender: TObject);
begin
 _set_lng;

 rbMM.Checked := true
end;

procedure TfrmFPGImages.getRBPoint(bmp: TBitmap; var x, y: Longint);
begin
 x := 0;
 y := 0;

 if rbTM.Checked or rbMM.Checked or rbDM.Checked then
  x := (bmp.Width div 2) - 1;

 if rbTR.Checked or rbMR.Checked or rbDR.Checked then
  x := bmp.Width - 1;

 if rbML.Checked or rbMM.Checked or rbMR.Checked then
  y := (bmp.Height div 2) - 1;

 if rbDL.Checked or rbDM.Checked or rbDR.Checked then
  y := bmp.Height - 1;
end;

procedure TfrmFPGImages.sbAddPointClick(Sender: TObject);
var
 x, y     : LongInt;
begin
 getRBPoint(TBitmap(Fpg.images[fpg_index]), x, y);

 edCoordX.Text := IntToStr( x );
 edCoordY.Text := IntToStr( y );

 sbAddClick( Sender );
end;

procedure TfrmFPGImages.sbPutCenterClick(Sender: TObject);
var
 list_add : TListItem;
 x, y     : LongInt;
begin
 getRBPoint(TBitmap(Fpg.images[fpg_index]), x, y);

 if lvControlPoints.Items.Count > 0 then
 begin
  list_add := lvControlPoints.Items.Item[0];

  list_add.SubItems.Strings[0] := IntToStr( x );
  list_add.SubItems.Strings[1] := IntToStr( y );
 end
 else
 begin
  list_add := lvControlPoints.Items.Add;

  lvControlPoints.Items.Item[0].Caption := '000';
  list_add.SubItems.Add( IntToStr( x ) );
  list_add.SubItems.Add( IntToStr( y ) );
 end;
end;

procedure TfrmFPGImages.edCodeEnter(Sender: TObject);
begin
 edCode.Color := clWhite;
end;

procedure TfrmFPGImages.edFNameEnter(Sender: TObject);
begin
 edFName.Color := clWhite;
end;

procedure TfrmFPGImages.edFNameExit(Sender: TObject);
begin
 edFName.Color := clMedGray;
end;

procedure TfrmFPGImages.edNameEnter(Sender: TObject);
begin
 edName.Color := clWhite;
end;

procedure TfrmFPGImages.edNameExit(Sender: TObject);
begin
 edName.Color := clMedGray;
end;

procedure TfrmFPGImages.edCoordXEnter(Sender: TObject);
begin
 edCoordX.Color := clWhite;
end;

procedure TfrmFPGImages.edCoordYEnter(Sender: TObject);
begin
 edCoordY.Color := clWhite;
end;

end.