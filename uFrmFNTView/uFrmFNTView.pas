unit uFrmFNTView;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls, Grids, ufnt, LConvEncoding;

type

  { TfrmFNTView }

  TfrmFNTView = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    DrawGrid1: TDrawGrid;
    GroupBox4: TGroupBox;
    Memo1: TMemo;
    Label4: TLabel;
    cbCharset: TComboBox;
    GroupBox5: TGroupBox;
    ListView1: TListView;
    GroupBox6: TGroupBox;
    Image1: TImage;
    Label5: TLabel;
    procedure DrawGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    BGColor : TColor;
    { private declarations }
  public
    { Public declarations }
    procedure RefreshData;
    procedure setImageBGColor(color1: TColor);
  end;

var
  frmFNTView: TfrmFNTView;

implementation

{$R *.lfm}

{ TfrmFNTView }

procedure TfrmFNTView.FormShow(Sender: TObject);
begin
  RefreshData;
end;

procedure TfrmFNTView.Image1Click(Sender: TObject);
begin
  Image1.Stretch:= not image1.Stretch;
end;

procedure TfrmFNTView.DrawGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  index : integer;
begin
  index := (Arow *16+Acol)*3;
  DrawGrid1.Canvas.Brush.color := RGBToColor(fnt_container.header.palette[index] shl 2,fnt_container.header.palette[index+1] shl 2,fnt_container.header.palette[index+2] shl 2);
  DrawGrid1.Canvas.FillRect(aRect);
end;

procedure TfrmFNTView.setImageBGColor(color1: TColor);
begin
  //GroupBox6.Color:=color1;
  BGColor:=color1;
end;

procedure TfrmFNTView.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  tmp : TBitmap;
begin
   if not Selected then
      exit;
   if fnt_container.char_data[Item.Index].Bitmap = nil then
     Image1.Picture.Clear
   else
   begin
      tmp:= TBitmap.Create;
      tmp.PixelFormat:=pf24bit;
      tmp.SetSize(fnt_container.char_data[Item.Index].Bitmap.Width+2,fnt_container.char_data[Item.Index].Bitmap.Height+2);
      tmp.canvas.Brush.Color:=BGColor;
      tmp.canvas.FillRect(0,0,tmp.Width,tmp.Height);
      tmp.canvas.Draw(1,1,fnt_container.char_data[Item.Index].Bitmap);
      Image1.Picture.Assign(tmp);
      FreeAndNil(tmp);
   end;
end;

procedure TFrmFNTView.RefreshData;
var
//  stringmemo: String;
  i : integer;
  listItem : TListItem;
begin
  if (Byte(fnt_container.header.file_type[1])+Byte(fnt_container.header.file_type[2])+Byte(fnt_container.header.file_type[3])) = 0 then
    exit;

  edit1.Text := fnt_container.header.file_type;
  edit2.Text := IntToHex(fnt_container.header.code[0], 2) + IntToHex(fnt_container.header.code[1], 2) +
    IntToHex(fnt_container.header.code[2], 2) + IntToHex(fnt_container.header.code[3], 2);
  edit3.Text := IntToStr(fnt_container.header.version);
  cbCharset.ItemIndex := fnt_container.header.charset;
  label5.Caption := IntToStr(fnt_container.header.charset);

  (*
  stringmemo := '';
  if (fnt_container.header.file_type[2] = 't') or (fnt_container.header.version = 8) then
    for i := 0 to 575 do
    begin
      stringmemo := stringmemo + inttohex(fnt_container.header.gamuts[i], 2);
      if i <> 575 then
        stringmemo := stringmemo + ' ';
    end;
  memo1.Text := stringmemo;
  *)


  listview1.Items.Clear;
  for i := 0 to 255 do
  begin
    listItem := ListView1.Items.add();
    listItem.Caption := IntToStr(i);
    if fnt_container.header.charset = 0 then
        listItem.SubItems.Add(ISO_8859_1ToUTF8(chr(i)))
    else
        listItem.SubItems.Add(CP850ToUTF8(chr(i)));

    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].Width));
    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].Height));
    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].width_offset));
    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].height_offset));
    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].horizontal_offset));
    listItem.SubItems.Add(IntToStr(fnt_container.header.char_info[i].vertical_offset));
    listItem.SubItems.Add(inttohex(fnt_container.header.char_info[i].file_offset, 8));
  end;
end;

end.