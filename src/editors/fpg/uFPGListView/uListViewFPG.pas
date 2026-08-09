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

unit uListViewFPG;


interface

uses LCLIntf, LCLType,  ComCtrls, Graphics, Controls, SysUtils, Classes,
     ClipBrd, Forms, Dialogs,
     uLanguage, uFPG, uTools, uIniFile,
      uLoadImage, uColor16bits, uFrmMessageBox ,IntfGraphics;

type
  TFPGListView = class( TListView)
  private
    { Private declarations }
    Ffpg: TFpg;
  public
    { Public declarations }
    procedure Load_Images( progressBar : TProgressBar);

    procedure Insert_Images(lImages : TStringList; dir : string;  var progressBar : TProgressBar);

    procedure Insert_Imagescb(  var progressBar : TProgressBar);

    procedure add_items( index : Word);
    procedure replace_item( index : Word);
    procedure freeFPG;
   published
    property Fpg : TFpg read Ffpg write Ffpg ;
    property Align;
    property AllocBy;
    property Anchors;
    property AutoSort;
    property AutoWidthLastColumn;
    property BorderSpacing;
    property BorderStyle;
    property BorderWidth;
    property Checkboxes;
    property Color;
    property Columns;
    property ColumnClick;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
//    property DefaultItemHeight;
//    property DropTarget;
    property Enabled;
//    property FlatScrollBars;
    property Font;
//    property FullDrag;
    property GridLines;
    property HideSelection;
//    property HotTrack;
//    property HotTrackStyles;
//    property HoverTime;
    property IconOptions;
//    property ItemIndex; shouldn't be published, see bug 16367
    property Items;
    property LargeImages;
    property MultiSelect;
    property OwnerData;
//    property OwnerDraw;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RowSelect;
    property ScrollBars;
    property ShowColumnHeaders;
    property ShowHint;
//    property ShowWorkAreas;
    property SmallImages;
    property SortColumn;
    property SortDirection;
    property SortType;
    property StateImages;
    property TabStop;
    property TabOrder;
    property ToolTips;
    property Visible;
    property ViewStyle;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnChange;
    property OnClick;
    property OnColumnClick;
    property OnCompare;
    property OnContextPopup;
    property OnCreateItemClass;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnItemChecked;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
    property OnUTF8KeyPress;

  end;

procedure Register;

implementation


procedure TFPGListView.Load_Images( progressBar : TProgressBar);
var
 count   : Integer;
begin
 //Limpiamos la lista de imagenes
 LargeImages.Clear;
 Items.Clear;

 LargeImages.Width  := inifile_sizeof_icon;
 LargeImages.Height := inifile_sizeof_icon;

 progressBar.Position := 0;
 progressBar.Show;
 progressBar.Repaint;
 for count:= 1 to Fpg.Count do
 begin
  with Fpg.images[count] do
  begin
   add_items(count);
   if (count mod inifile_repaint_number) = 0 then
   begin
    progressBar.Position:= (count * 100) div Fpg.Count;
    progressBar.Repaint;
   end;
  end;
 end;

 progressBar.Hide;
end;


procedure TFPGListView.Insert_Images(lImages : TStringList; dir : string;
                              var progressBar : TProgressBar);
var
 i : Integer;
 bmp_src  : TBitmap;
 file_source, filename : string;
 index : word;
begin
 // Creamos el bitmap fuente y destino
 bmp_src := TBitmap.Create;
 // Se inializa la barra de progresión
 progressBar.Position := 0;
 progressBar.Show;
 progressBar.Repaint;


 for i := 0 to lImages.Count - 1 do
 begin

  index:=Fpg.indexOfCode( Fpg.lastcode);
  if index<>0 then
  begin
   if MessageDlg('El código: '+intToStr(Fpg.lastcode)+' ya existe. ¿Desea sobrescribirlo?',mtConfirmation,[mbYes,mbNo],0) = mrNo then
         continue;
  end;

  filename := lImages.Strings[i];

  // Se prepara la ruta del fichero
  file_source := prepare_file_source(Dir, filename);

  // Se carga la imagen
  loadImageFile(bmp_src, file_source);

  (*
  // Se incrementa el código de la imagen
  Fpg.last_code := Fpg.last_code + 1;

  // Busca hasta que encuentre un código libre
  while CodeExists(Fpg.last_code) do
    Fpg.last_code := Fpg.last_code + 1;
  *)

  // ver como meter fpgedit2009
  if index<>0 then
  begin
   fpg.replace_bitmap( index, ChangeFileExt(filename,''), ChangeFileExt(filename,''), bmp_src );
   replace_item( index);
  end else begin
      Fpg.Count := Fpg.Count + 1;
      fpg.add_bitmap( Fpg.Count, ChangeFileExt(filename,''), ChangeFileExt(filename,''), bmp_src );
      add_items( Fpg.Count);
  end;
  Fpg.lastcode := Fpg.lastcode + 1;

  //bmp_src.FreeImage;
  progressBar.Position:= ((i+1) * 100) div lImages.Count;
  progressBar.Repaint;

 end;
 Fpg.lastcode := Fpg.lastcode - 1;
 bmp_src.Free;
 Fpg.update := true;
 Repaint;
 progressBar.Hide;
end;

procedure TFPGListView.Insert_Imagescb(   var progressBar : TProgressBar);
var
 bmp_src : TBitmap;
begin
 // Se inializa la barra de progresión
 progressBar.Position := 50;
 progressBar.Show;
 progressBar.Repaint;

 bmp_src := TBitmap.Create;
 bmp_src.PixelFormat := pf32bit;

 try
   bmp_src.LoadFromClipBoardFormat( cf_BitMap);
 except
   bmp_src.Destroy;
   progressBar.Hide;
   feMessageBox(LNG_STRINGS[LNG_ERROR], LNG_STRINGS[LNG_NOT_CLIPBOARD_IMAGE], 0, 0);
   Exit;
 end;

 LargeImages.Width  := inifile_sizeof_icon;
 LargeImages.Height := inifile_sizeof_icon;

 // Se incrementa el código de la imagen
  Fpg.lastcode := Fpg.lastcode + 1;

  // Busca hasta que encuentre un código libre
  while Fpg.CodeExists(Fpg.lastcode) do
   Fpg.lastcode := Fpg.lastcode + 1;

  // ver como meter fpgedit2009
 Fpg.Count := Fpg.Count + 1;
 fpg.add_bitmap( Fpg.Count, 'ClipBoard', 'ClipBoard', bmp_src );
 add_items( Fpg.Count);


 progressBar.Hide;

 bmp_src.Destroy;

 Fpg.update := true;
end;

procedure TFPGListView.add_items( index : Word);
var
 list_bmp : TListItem;
 bmp_dst: TBitMap;
begin

 // Pintamos el icono
 DrawProportional(Fpg.images[index].bmp, bmp_dst, color);

 list_bmp := Items.Add;

 list_bmp.ImageIndex := LargeImages.add(bmp_dst, nil);

 // Se establece el código del FPG
 list_bmp.Caption := NumberTo3Char( Fpg.images[index].graph_code );

 // Se añaden los datos de la imagen a la lista
 list_bmp.SubItems.Add(Fpg.images[index].fpname);
 list_bmp.SubItems.Add(Fpg.images[index].name);

 list_bmp.SubItems.Add(IntToStr(Fpg.images[index].width));
 list_bmp.SubItems.Add(IntToStr(Fpg.images[index].height));
 list_bmp.SubItems.Add(IntToStr(Fpg.images[index].points));

end;

procedure TFPGListView.replace_item( index : Word);
var
 list_bmp : TListItem;
 bmp_dst: TBitMap;
begin

 // Pintamos el icono
 DrawProportional(Fpg.images[index].bmp, bmp_dst, color);

 list_bmp := Items.Item[index -1];

 LargeImages.Replace(index-1, bmp_dst, Nil);
 //list_bmp.ImageIndex :=

 // Se añaden los datos de la imagen a la lista
 list_bmp.SubItems.Strings[0]:=Fpg.images[index].fpname;
 list_bmp.SubItems.Strings[1]:=Fpg.images[index].name;

 list_bmp.SubItems.Strings[2]:=IntToStr(Fpg.images[index].width);
 list_bmp.SubItems.Strings[3]:=IntToStr(Fpg.images[index].height);
// list_bmp.SubItems.Strings[4]:=IntToStr(Fpg.images[index].points);

end;

procedure TFPGListView.FreeFPG;
begin
    FreeAndNil(ffpg);
end;

procedure Register;
begin
 RegisterComponents('Common Controls',[TFPGListView]);
end;


end.
