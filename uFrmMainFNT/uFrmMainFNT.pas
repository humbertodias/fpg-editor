unit uFrmMainFNT;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Forms, Classes, Graphics, Controls,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, ExtDlgs, Spin,
  IntfGraphics, uFNT, uIniFile,  uFrmBpp, FileUtil, FPimage, uColorTable
  , uSort, uTools, ufrmFNTView, LConvEncoding, uFrmCFG, ufrmPalette;

const
 FONT_COLOR   = 1;
 EDGE_COLOR   = 2;
 SHADOW_COLOR = 3;
 TRANSPARENT_COLOR = 0;
 TOTAL_LAYERS = 3; 

type
  TRGBTriple = record
   R, G, B : Byte;
  end;
  
  TRGBLine = Array[Word] of TRGBTriple;
  pRGBLine = ^TRGBLine;

  { TfrmMainFNT }

  TfrmMainFNT = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    cbCharset: TComboBox;
    dlgFont: TFontDialog;
    EPreview: TEdit;
    gbCharset: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    pTools: TToolBar;
    pTop: TPanel;
    gbLoadFont: TGroupBox;
    bgSize: TGroupBox;
    gbStyle: TGroupBox;
    edSizeFont: TEdit;
    cbStyle: TComboBox;
    gbSymbolType: TGroupBox;
    cbUpper: TCheckBox;
    cbMinus: TCheckBox;
    cbNumbers: TCheckBox;
    cbSymbol: TCheckBox;
    gbSelectColor: TGroupBox;
    imgSelect: TImage;
    sbChangeBGColor: TSpeedButton;
    sbExport: TSpeedButton;
    sbImport: TSpeedButton;
    sbLoadFont: TSpeedButton;
    gbShadow: TGroupBox;
    lbShadow: TLabel;
    gbFont: TGroupBox;
    sbInfo: TStatusBar;
    dlgOpen: TOpenDialog;
    cbExtended: TCheckBox;
    gbEdge: TGroupBox;
    rbsLT: TRadioButton;
    rbsTM: TRadioButton;
    rbsRT: TRadioButton;
    rbsRM: TRadioButton;
    rbsLM: TRadioButton;
    rbsLD: TRadioButton;
    rbsDM: TRadioButton;
    rbsRD: TRadioButton;
    sbOpen: TSpeedButton;
    sbSave: TSpeedButton;
    sbSaveAs: TSpeedButton;
    sbSaveText: TSpeedButton;
    sbSelectImage: TSpeedButton;
    sbSelectColor: TSpeedButton;
    rbSFont: TRadioButton;
    rbSEdge: TRadioButton;
    rbSShadow: TRadioButton;
    lbSizeEdge: TLabel;
    lbNameFontB: TLabel;
    lbNameFont: TLabel;
    sbShowFNT: TSpeedButton;
    sedSizeEdge: TSpinEdit;
    sedSizeShadow: TSpinEdit;
    dlgColor: TColorDialog;
    dlgOpenPicture: TOpenPictureDialog;
    dlgSave: TSaveDialog;
    pImage: TPanel;
    imgPreview: TImage;
    gInfo: TProgressBar;
    pInfo: TPanel;
    sbMakeFont: TSpeedButton;
    sbOptions: TSpeedButton;
    sdSaveText: TSaveDialog;
    odImportFNT: TOpenDialog;
    seReAlfa: TSpinEdit;
    Label1: TLabel;
    seFontAlfa: TSpinEdit;
    seSoAlfa: TSpinEdit;
    Label2: TLabel;
    seCharPreview: TSpinEdit;
    ToolBar1: TToolBar;
    procedure cbCharsetChange(Sender: TObject);
    procedure EPreviewChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure sbOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvFontExit(Sender: TObject);
    procedure sbLoadFontClick(Sender: TObject);
    procedure edSizeEdgeKeyPress(Sender: TObject; var Key: Char);
    procedure edSizeShadowKeyPress(Sender: TObject; var Key: Char);
    procedure edSizeFontKeyPress(Sender: TObject; var Key: Char);
    procedure sbShowFNTClick(Sender: TObject);
    procedure sbShowPaletteClick(Sender: TObject);
    procedure rbSFontClick(Sender: TObject);
    procedure rbSEdgeClick(Sender: TObject);
    procedure rbSShadowClick(Sender: TObject);
    procedure sbSelectColorClick(Sender: TObject);
    procedure sbSelectImageClick(Sender: TObject);
    procedure cbStyleChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action1: TCloseAction);
    procedure cbUpperClick(Sender: TObject);
    procedure cbMinusClick(Sender: TObject);
    procedure cbNumbersClick(Sender: TObject);
    procedure cbSymbolClick(Sender: TObject);
    procedure cbExtendedClick(Sender: TObject);
    procedure rbsRDClick(Sender: TObject);
    procedure rbsDMClick(Sender: TObject);
    procedure rbsLDClick(Sender: TObject);
    procedure rbsRMClick(Sender: TObject);
    procedure rbsLMClick(Sender: TObject);
    procedure rbsRTClick(Sender: TObject);
    procedure rbsTMClick(Sender: TObject);
    procedure rbsLTClick(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure sbSaveAsClick(Sender: TObject);
    procedure sbChangeBGColorClick(Sender: TObject);
    procedure sbWriteTextClick(Sender: TObject);
    procedure sbMakeFontClick(Sender: TObject);
    procedure sbExportClick(Sender: TObject);
    procedure sbImportClick(Sender: TObject);
    procedure sbOptionsClick(Sender: TObject);
    procedure sbSaveTextClick(Sender: TObject);
    procedure seCharPreviewChange(Sender: TObject);
    procedure seFontAlfaChange(Sender: TObject);
    procedure seSoAlfaChange(Sender: TObject);
    procedure seReAlfaChange(Sender: TObject);
  private
    { Private declarations }
    function  GetUpOffset( bmpsrc : TBitMap ) : LongInt;
    function  GetDownOffset( bmpsrc : TBitMap ) : LongInt;
    function  GetNumberOfFNT( ) : LongInt;

    procedure SetPaletteColor( i, color1: LongInt );
    procedure ExtractAllFNT;
    procedure ExtractFNT  ( index : LongInt );
    procedure InsertEdge  ( index : LongInt );
    procedure InsertShadow( index : LongInt );
    procedure RenderFNT   ( index : LongInt );
    procedure CreatePAL;

    procedure MakeFont;
    procedure MakePreview;
    procedure MakeEdge;
    procedure MakeShadow;
    procedure MakeFontDraw;

    procedure CreateBitmaps;
    procedure DestroyBitmaps;
    procedure ClearBitmap(var bmp: TBitmap);
    procedure UpdateBGColor;
    procedure MakeText(str_in: string);
    procedure MakeChar(index: integer);
    procedure ExportFNT(str : string);
    procedure ImportFNT(str : string);

    procedure drawProgress( str : string );
    procedure EnableButtons;
    procedure createSelectedImageBox(color1 :TColor);
    function OpenFNT( sfile: string ) : boolean;
    procedure MakeTextParsingCharset( str : String);
  public
    { Public declarations }
    dpCount, dpTotal : LongInt;
    font_edge  : LongInt;
    font_shadow: LongInt;
    img_font, img_edge, img_shadow : TBitMap;
    nFont : TFont;
    procedure openParamFile;
  end;

var
  frmMainFNT: TfrmMainFNT;
  //text_color, ed_color, sh_color : LongInt;
  //AATable : Array [0 .. 255, 0 .. 255] of real;
  //posadd : Longint;

const
 //  to use with previous lazarus version without iso8859_15
ArrayISO_8859_15ToUTF8: TCharToUTF8Table = (
  #0,                 // #0
  #1,                 // #1
  #2,                 // #2
  #3,                 // #3
  #4,                 // #4
  #5,                 // #5
  #6,                 // #6
  #7,                 // #7
  #8,                 // #8
  #9,                 // #9
  #10,                // #10
  #11,                // #11
  #12,                // #12
  #13,                // #13
  #14,                // #14
  #15,                // #15
  #16,                // #16
  #17,                // #17
  #18,                // #18
  #19,                // #19
  #20,                // #20
  #21,                // #21
  #22,                // #22
  #23,                // #23
  #24,                // #24
  #25,                // #25
  #26,                // #26
  #27,                // #27
  #28,                // #28
  #29,                // #29
  #30,                // #30
  #31,                // #31
  ' ',                // ' '
  '!',                // '!'
  '"',                // '"'
  '#',                // '#'
  '$',                // '$'
  '%',                // '%'
  '&',                // '&'
  '''',               // ''''
  '(',                // '('
  ')',                // ')'
  '*',                // '*'
  '+',                // '+'
  ',',                // ','
  '-',                // '-'
  '.',                // '.'
  '/',                // '/'
  '0',                // '0'
  '1',                // '1'
  '2',                // '2'
  '3',                // '3'
  '4',                // '4'
  '5',                // '5'
  '6',                // '6'
  '7',                // '7'
  '8',                // '8'
  '9',                // '9'
  ':',                // ':'
  ';',                // ';'
  '<',                // '<'
  '=',                // '='
  '>',                // '>'
  '?',                // '?'
  '@',                // '@'
  'A',                // 'A'
  'B',                // 'B'
  'C',                // 'C'
  'D',                // 'D'
  'E',                // 'E'
  'F',                // 'F'
  'G',                // 'G'
  'H',                // 'H'
  'I',                // 'I'
  'J',                // 'J'
  'K',                // 'K'
  'L',                // 'L'
  'M',                // 'M'
  'N',                // 'N'
  'O',                // 'O'
  'P',                // 'P'
  'Q',                // 'Q'
  'R',                // 'R'
  'S',                // 'S'
  'T',                // 'T'
  'U',                // 'U'
  'V',                // 'V'
  'W',                // 'W'
  'X',                // 'X'
  'Y',                // 'Y'
  'Z',                // 'Z'
  '[',                // '['
  '\',                // '\'
  ']',                // ']'
  '^',                // '^'
  '_',                // '_'
  '`',                // '`'
  'a',                // 'a'
  'b',                // 'b'
  'c',                // 'c'
  'd',                // 'd'
  'e',                // 'e'
  'f',                // 'f'
  'g',                // 'g'
  'h',                // 'h'
  'i',                // 'i'
  'j',                // 'j'
  'k',                // 'k'
  'l',                // 'l'
  'm',                // 'm'
  'n',                // 'n'
  'o',                // 'o'
  'p',                // 'p'
  'q',                // 'q'
  'r',                // 'r'
  's',                // 's'
  't',                // 't'
  'u',                // 'u'
  'v',                // 'v'
  'w',                // 'w'
  'x',                // 'x'
  'y',                // 'y'
  'z',                // 'z'
  '{',                // '{'
  '|',                // '|'
  '}',                // '}'
  '~',                // '~'
  #127,               // #127
  #194#128,           // #128
  #194#129,           // #129
  #194#130,           // #130
  #194#131,           // #131
  #194#132,           // #132
  #194#133,           // #133
  #194#134,           // #134
  #194#135,           // #135
  #194#136,           // #136
  #194#137,           // #137
  #194#138,           // #138
  #194#139,           // #139
  #194#140,           // #140
  #194#141,           // #141
  #194#142,           // #142
  #194#143,           // #143
  #194#144,           // #144
  #194#145,           // #145
  #194#146,           // #146
  #194#147,           // #147
  #194#148,           // #148
  #194#149,           // #149
  #194#150,           // #150
  #194#151,           // #151
  #194#152,           // #152
  #194#153,           // #153
  #194#154,           // #154
  #194#155,           // #155
  #194#156,           // #156
  #194#157,           // #157
  #194#158,           // #158
  #194#159,           // #159
  #194#160,           // #160
  #194#161,           // #161
  #194#162,           // #162
  #194#163,           // #163
  #226#130#172,       // #164
  #194#165,           // #165
  #197#160,           // #166
  #194#167,           // #167
  #197#161,           // #168
  #194#169,           // #169
  #194#170,           // #170
  #194#171,           // #171
  #194#172,           // #172
  #194#173,           // #173
  #194#174,           // #174
  #194#175,           // #175
  #194#176,           // #176
  #194#177,           // #177
  #194#178,           // #178
  #194#179,           // #179
  #197#189,           // #180
  #194#181,           // #181
  #194#182,           // #182
  #194#183,           // #183
  #197#190,           // #184
  #194#185,           // #185
  #194#186,           // #186
  #194#187,           // #187
  #197#146,           // #188
  #197#147,           // #189
  #197#184,           // #190
  #194#191,           // #191
  #195#128,           // #192
  #195#129,           // #193
  #195#130,           // #194
  #195#131,           // #195
  #195#132,           // #196
  #195#133,           // #197
  #195#134,           // #198
  #195#135,           // #199
  #195#136,           // #200
  #195#137,           // #201
  #195#138,           // #202
  #195#139,           // #203
  #195#140,           // #204
  #195#141,           // #205
  #195#142,           // #206
  #195#143,           // #207
  #195#144,           // #208
  #195#145,           // #209
  #195#146,           // #210
  #195#147,           // #211
  #195#148,           // #212
  #195#149,           // #213
  #195#150,           // #214
  #195#151,           // #215
  #195#152,           // #216
  #195#153,           // #217
  #195#154,           // #218
  #195#155,           // #219
  #195#156,           // #220
  #195#157,           // #221
  #195#158,           // #222
  #195#159,           // #223
  #195#160,           // #224
  #195#161,           // #225
  #195#162,           // #226
  #195#163,           // #227
  #195#164,           // #228
  #195#165,           // #229
  #195#166,           // #230
  #195#167,           // #231
  #195#168,           // #232
  #195#169,           // #233
  #195#170,           // #234
  #195#171,           // #235
  #195#172,           // #236
  #195#173,           // #237
  #195#174,           // #238
  #195#175,           // #239
  #195#176,           // #240
  #195#177,           // #241
  #195#178,           // #242
  #195#179,           // #243
  #195#180,           // #244
  #195#181,           // #245
  #195#182,           // #246
  #195#183,           // #247
  #195#184,           // #248
  #195#185,           // #249
  #195#186,           // #250
  #195#187,           // #251
  #195#188,           // #252
  #195#189,           // #253
  #195#190,           // #254
  #195#191            // #255
);

resourcestring
  LNG_NORMAL  ='Normal';
  LNG_BOLD ='Negrita';
  LNG_UNDERLINE ='Subrayado';
  LNG_LABELED ='Tachado';

implementation

{$R *.lfm}

function ISO_8859_15ToUTF8(const s: string): string;
begin
  Result:=SingleByteToUTF8(s,ArrayISO_8859_15ToUTF8);
end;

function UnicodeToISO_8859_15(Unicode: cardinal): integer;
begin
  case Unicode of
  0..255: Result:=Unicode;
  8364: Result:=164;
  352: Result:=166;
  353: Result:=168;
  381: Result:=180;
  382: Result:=184;
  338: Result:=188;
  339: Result:=189;
  376: Result:=190;
  else Result:=-1;
  end;
end;

function UTF8ToISO_8859_15(const s: string): string;
begin
  Result:=UTF8ToSingleByte(s,@UnicodeToISO_8859_15);
end;


function  TfrmMainFNT.GetNumberOfFNT( ) : LongInt;
begin
 result := 0;

 if cbUpper.Checked    then result := result + 25;
 if cbMinus.Checked    then result := result + 25;
 if cbNumbers.Checked  then result := result + 10;
 if cbSymbol.Checked   then result := result + 68;
 if cbExtended.Checked then result := result + 128;
end;

procedure TfrmMainFNT.drawProgress( str : string );
begin
 gInfo.Visible := (Length(str) > 0);
 pInfo.Visible := (Length(str) > 0);

 if Length(str) <= 0 then
 begin
  dpCount := 0;
  Exit;
 end;

 pInfo.Caption := str;

 if dpTotal > 0 then
 begin
  gInfo.Position := (dpCount * 100) div dpTotal;
  gInfo.Repaint;
  dpCount := dpCount + 1;
 end;

 Repaint;
end;

procedure TfrmMainFNT.MakeEdge;
var
 i : LongInt;
begin
 dpCount := 0;
 for i := 0 to 255 do
   if( fnt_container.char_data[i].ischar ) then
   begin
    InsertEdge( i );
    drawProgress('Añadiendo reborde...');
   end;
end;

procedure TfrmMainFNT.MakeShadow;
var
 i : LongInt;
begin
  dpCount := 0;

  for i := 0 to 255 do
   if( fnt_container.char_data[i].ischar ) then
   begin
    InsertShadow( i );

    drawProgress('Añadiendo sombra...');
   end;
end;

procedure TfrmMainFNT.MakeFontDraw;
var
 i : Longint;
begin
 // Pintando Tipografía
 dpCount := 0;

 for i := 0 to 255 do
  if( fnt_container.char_data[i].ischar ) then
   begin
    RenderFNT( i );

    drawProgress('Pintando Tipografía...');
   end;
end;


procedure TfrmMainFNT.MakePreview;
var
 x, nNumber, nUpper, nDown, nSymbol, nExtended : LongInt;
 i, MaxWidth, MaxHeight : LongInt;
 bmp_buffer : TBitmap;
begin
 x := 0;
 nNumber := 0;
 nUpper  := 0;
 nDown   := 0;
 nSymbol := 0;
 nExtended := 0;

 if (inifile_symbol_type and 1 ) <> 0 then x := x + 1;
 if (inifile_symbol_type and 2 ) <> 0 then x := x + 1;
 if (inifile_symbol_type and 4 ) <> 0 then x := x + 1;
 if (inifile_symbol_type and 8 ) <> 0 then x := x + 1;
 if (inifile_symbol_type and 16) <> 0 then x := x + 1;

 case x of
  5:begin
     nNumber := 2; nUpper := 2; nDown := 2; nSymbol := 1; nExtended := 1;
    end;
  4,3:begin
     nNumber := 2; nUpper := 2; nDown := 2; nSymbol := 2; nExtended := 2;
    end;
  2:begin
     nNumber := 4; nUpper := 4; nDown := 4; nSymbol := 4; nExtended := 4;
    end;
  1:begin
     nNumber := 8; nUpper := 8; nDown := 8; nSymbol := 8; nExtended := 8;
    end;
 end;

 MaxWidth  := 0;
 MaxHeight := 0;

 if (inifile_symbol_type and 1 ) <> 0 then
  for i := 48 to 47 + nNumber do
  begin
   MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

   if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
  end;

 if (inifile_symbol_type and 2 ) <> 0 then
  for i := 65 to 64 + nUpper do
  begin
   MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

   if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
  end;

 if (inifile_symbol_type and 4 ) <> 0 then
  for i := 97 to 96 + nDown do
  begin
   MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

   if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
  end;

 if (inifile_symbol_type and 8 ) <> 0 then
  for i := 33 to 32 + nSymbol do
  begin
   MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

   if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
  end;

 if (inifile_symbol_type and 16) <> 0 then
  for i := 128 to 127 + nExtended do
  begin
   MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

   if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
  end;


 bmp_buffer := TBitmap.Create;
 bmp_buffer.PixelFormat := pf32bit;
 //bmp_buffer.Palette := CopyPalette(fnt_hpal);
 bmp_buffer.Width  := MaxWidth  + 2;
 bmp_buffer.Height := MaxHeight + 2;

 ClearBitmap(bmp_buffer);

 x := 1;

 if (inifile_symbol_type and 1 ) <> 0 then
  for i := 48 to 47 + nNumber do
  begin
   bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[i].vertical_offset + 1, fnt_container.char_data[i].Bitmap );

   x  := x + fnt_container.header.char_info[i].width;
  end;

 if (inifile_symbol_type and 2 ) <> 0 then
  for i := 65 to 64 + nUpper do
  begin
   bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[i].vertical_offset + 1, fnt_container.char_data[i].Bitmap );

   x  := x + fnt_container.header.char_info[i].width;
  end;

 if (inifile_symbol_type and 4 ) <> 0 then
  for i := 97 to 96 + nDown do
  begin
   bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[i].vertical_offset + 1, fnt_container.char_data[i].Bitmap );

   x  := x + fnt_container.header.char_info[i].width;
  end;

 if (inifile_symbol_type and 8 ) <> 0 then
  for i := 33 to 32 + nSymbol do
  begin
   bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[i].vertical_offset + 1, fnt_container.char_data[i].Bitmap );

   x  := x + fnt_container.header.char_info[i].width;
  end;

 if (inifile_symbol_type and 16) <> 0 then
  for i := 128 to 127 + nExtended do
  begin
   bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[i].vertical_offset + 1, fnt_container.char_data[i].Bitmap );

   x  := x + fnt_container.header.char_info[i].width;
  end;

 imgPreview.Picture.Bitmap.assign(bmp_buffer);
// imgPreview.Picture.Bitmap.Transparent:=true;
// imgPreview.Picture.Bitmap.TransparentColor:=clBlack;

 bmp_buffer.Destroy;
end;

function isSameColor( color1, color2 : TFPColor ) : boolean;
begin
  result:= (color1.red = color2.red) and (color1.green = color2.green) and
           (color1.blue = color2.blue) and (color1.alpha = color2.alpha);
end;

function TfrmMainFNT.GetUpOffset( bmpsrc : TBitMap ) : LongInt;
var
 i, j : LongInt;
 lazBMP : TLazIntfImage;

begin
 result := bmpsrc.Height;

 // Buscamos el desplazamiento vertical
 lazBMP := bmpsrc.CreateIntfImage;
 for j := 0 to (lazBMP.Height - 1) do
 begin
  for i := 0 to (lazBMP.Width - 1) do
   if not isSameColor(lazBmp.Colors[i,j], colTransparent)  then
   begin
    result := j;
    Exit;
   end;
 end;

 lazBMP.Free;

end;

function TfrmMainFNT.GetDownOffset( bmpsrc : TBitMap ) : LongInt;
var
 i, j : LongInt;
 lazBMP : TLazIntfImage;
begin
 result := bmpsrc.Height;

 // Buscamos el desplazamiento vertical bajo
 lazBMP:= bmpsrc.CreateIntfImage;
 for j := (lazBMP.Height - 1) downto 0 do
 begin
  for i := 0 to (lazBMP.Width - 1) do
   if not isSameColor(lazBmp.Colors[i,j], colTransparent)  then
   begin
    result := (lazBMP.Height - 1) - j;
    Exit;
   end;
 end;
end;

procedure TfrmMainFNT.SetPaletteColor( i, color1: LongInt );
begin
 if color1 = TRANSPARENT_COLOR then
 begin
  fnt_container.header.palette[ (i * 3) + 2 ] := 0;
  fnt_container.header.palette[ (i * 3) + 1 ] := 4;
  fnt_container.header.palette[ (i * 3)     ] := 0;
  Exit;
 end;

 fnt_container.header.palette[ (i * 3) + 2 ] :=  color1 shr 19;
 fnt_container.header.palette[ (i * 3) + 1 ] := (color1 and 64512) shr 10;
 fnt_container.header.palette[ (i * 3)     ] := (color1 and 248  ) shr 3;

 fnt_container.header.palette[  i * 3      ] := fnt_container.header.palette[  i * 3      ] shl 3;
 fnt_container.header.palette[ (i * 3) + 1 ] := fnt_container.header.palette[ (i * 3) + 1 ] shl 2;
 fnt_container.header.palette[ (i * 3) + 2 ] := fnt_container.header.palette[ (i * 3) + 2 ] shl 3;
end;

procedure showColors(c1,c2:TFPColor);
begin
 showMessage('c1.red:'+inttostr(c1.red)+' - '+'c1.green:'+inttostr(c1.green)+' - '+'c1.blue:'+inttostr(c1.blue)+' - '+'c1.alpha:'+inttostr(c1.alpha)
 +' - ' +  'c2.red:'+inttostr(c2.red)+' - '+'c2.green:'+inttostr(c2.green)+' - '+'c2.blue:'+inttostr(c2.blue)+' - '+'c2.alpha:'+inttostr(c2.alpha) );
end;

procedure TfrmMainFNT.ExtractFNT( index : LongInt );
var
 x, y : LongInt;
 bmp_src : TBitmap;
 lazBMPsrc : TLazIntfImage;
 lazBMPdst : TLazIntfImage;
 tmpColor : TFPColor;
 tmpVal :integer;
begin
 bmp_src := TBitmap.Create;
 bmp_src.PixelFormat := pf32bit;
 //bmp_src.Palette := CopyPalette(fnt_hpal);
 bmp_src.Canvas.Font.Assign(nFont);

 // Obtenemos el ancho y el alto real de esta imagen
 case cbCharset.ItemIndex of
   0:begin
     bmp_src.Width  := bmp_src.Canvas.TextWidth(ISO_8859_1ToUTF8(chr(index)));
     bmp_src.Height := bmp_src.Canvas.TextHeight(ISO_8859_1ToUTF8(chr(index)));
   end;

   1:begin
    bmp_src.Width  := bmp_src.Canvas.TextWidth(CP850ToUTF8(chr(index)));
    bmp_src.Height := bmp_src.Canvas.TextHeight(CP850ToUTF8(chr(index)));
   end;

   2:begin
     bmp_src.Width  := bmp_src.Canvas.TextWidth(ISO_8859_15ToUTF8(chr(index)));
     bmp_src.Height := bmp_src.Canvas.TextHeight(ISO_8859_15ToUTF8(chr(index)));
   end;

   3:begin
     bmp_src.Width  := bmp_src.Canvas.TextWidth(CP1252ToUTF8(chr(index)));
     bmp_src.Height := bmp_src.Canvas.TextHeight(CP1252ToUTF8(chr(index)));
   end;

   4:begin
     bmp_src.Width  := bmp_src.Canvas.TextWidth(CP437ToUTF8(chr(index)));
     bmp_src.Height := bmp_src.Canvas.TextHeight(CP437ToUTF8(chr(index)));
   end;
 end;


 // Rellenamos la imagen de color transparente
 ClearBitmap(bmp_src);

 if( bmp_src.Width <= 0 ) then
 begin
  fnt_container.header.char_info[index].width   := 0;
  fnt_container.header.char_info[index].Width_Offset:= 0;
  fnt_container.header.char_info[index].height  := 0;
  fnt_container.header.char_info[index].Height_Offset:=0;
  fnt_container.header.char_info[index].vertical_offset := 0;
  fnt_container.header.char_info[index].Horizontal_Offset:=0;
  fnt_container.header.char_info[index].file_Offset:=0;
  FreeAndNil(fnt_container.char_data[index].Bitmap);
  fnt_container.char_data[index].ischar:=false;
  Exit;
 end;

 // Pintamos la Tipografía
 bmp_src.Canvas.Brush.Color := clBlack;
 bmp_src.Canvas.Font.Color  := inifile_fnt_color;

 case cbCharset.ItemIndex of
  0: bmp_src.Canvas.TextOut(0, 0, ISO_8859_1ToUTF8(chr(index)));
  1: bmp_src.Canvas.TextOut(0, 0, CP850ToUTF8(chr(index)));
  2: bmp_src.Canvas.TextOut(0, 0, ISO_8859_15ToUTF8(chr(index)));
  3: bmp_src.Canvas.TextOut(0, 0, CP1252ToUTF8(chr(index)));
  4: bmp_src.Canvas.TextOut(0, 0, CP437ToUTF8(chr(index)));
 end;

 // Obtenemos el desplazamiento vertical, ancho y alto mínimo
 fnt_container.header.char_info[index].vertical_offset:= GetUpOffset(bmp_src);
 fnt_container.header.char_info[index].width  := bmp_src.Width;
 fnt_container.header.char_info[index].height := bmp_src.Height - fnt_container.header.char_info[index].vertical_offset - GetDownOffset(bmp_src);

 if( fnt_container.header.char_info[index].height <= 0 ) then
 begin
  fnt_container.header.char_info[index].width   := 0;
  fnt_container.header.char_info[index].Width_Offset:= 0;
  fnt_container.header.char_info[index].height  := 0;
  fnt_container.header.char_info[index].Height_Offset:=0;
  fnt_container.header.char_info[index].vertical_offset := 0;
  fnt_container.header.char_info[index].Horizontal_Offset:=0;
  fnt_container.header.char_info[index].file_Offset:=0;
  FreeAndNil(fnt_container.char_data[index].Bitmap);
  fnt_container.char_data[index].ischar:=false;
  Exit;
 end;

 FreeAndNil(fnt_container.char_data[index].Bitmap);
 fnt_container.char_data[index].Bitmap := TBitmap.Create;

 fnt_container.char_data[index].Bitmap.PixelFormat := pf32bit;
// fnt_container.char_data[index].Bitmap.Palette := CopyPalette(fnt_hpal);
 fnt_container.char_data[index].Bitmap.Width   := fnt_container.header.char_info[index].width;
 fnt_container.char_data[index].Bitmap.Height  := fnt_container.header.char_info[index].Height;


 //** Copia una imagen en otra con el desplazamiento vertical **//
 tmpVal:= (MulDiv (high(word) , alpha_font , 100) ) and $FF00;
 lazBMPdst:= fnt_container.char_data[index].Bitmap.CreateIntfImage;
 lazBMPsrc:= bmp_src.CreateIntfImage;
 for y := 0 to lazBMPdst.Height - 1 do
  for x := 0 to lazBMPdst.Width - 1 do
  begin
   tmpColor:=lazBMPsrc.Colors[x,y + fnt_container.header.char_info[index].vertical_offset];
   if FPColorToTColor(tmpColor) = inifile_fnt_color then
   begin
      tmpColor.alpha:=tmpVal;
      lazBMPdst.Colors[x,y] := tmpColor;
   end;
  end;

 fnt_container.char_data[index].Bitmap.LoadFromIntfImage(lazBMPdst);
 fnt_container.char_data[index].ischar := true;

 lazBMPsrc.free;
 lazBMPdst.free;

 bmp_src.free;
end;

procedure TfrmMainFNT.InsertEdge( index : LongInt );
var
 x, y, j, k : LongInt;
 bmp_edge   : TBitmap;
 bmp_dst    : TBitmap;
 lazBMPsrc, lazBMPdst  : TLazIntfImage;
 lazBMPedge  : TLazIntfImage;
 edgeColor : TFPColor;
begin
 bmp_edge := TBitmap.Create;
 bmp_edge.PixelFormat := pf32bit;
 //bmp_edge.Palette := CopyPalette(fnt_hpal);
 bmp_edge.Width  := fnt_container.header.char_info[index].width  + (font_edge * 2);
 bmp_edge.Height := fnt_container.header.char_info[index].height + (font_edge * 2);

 bmp_dst := TBitmap.Create;
 bmp_dst.PixelFormat := pf32bit;
 //bmp_dst.Palette := CopyPalette(fnt_hpal);
 bmp_dst.Width  := bmp_edge.Width;
 bmp_dst.Height := bmp_edge.Height;

 // Borramos la imagen
 ClearBitmap(bmp_edge);
 ClearBitmap(bmp_dst);

 fnt_container.header.char_info[index].width  := bmp_edge.Width;
 fnt_container.header.char_info[index].height := bmp_edge.Height;

 // Desplazamiento horizontal y vertical
 lazBMPsrc:= fnt_container.char_data[index].Bitmap.CreateIntfImage ;
 lazBMPdst:= bmp_dst.CreateIntfImage ;

 lazBMPdst.CopyPixels(lazBMPsrc, font_edge,font_edge);

 // Pintamos el reborde
 lazBMPedge:= bmp_edge.CreateIntfImage ;
 edgeColor:=TColorToFPColor(inifile_edge_color);
 edgeColor.alpha:= (MulDiv (high(word) , alpha_edge , 100)) and $FF00;

 for y := 0 to lazBMPdst.Height - 1 do
 begin
  for x := 0 to lazBMPdst.Width - 1 do
   if FPColorToTColor(lazBMPdst.Colors[x,y]) = inifile_fnt_color then
   begin
    for k := y - font_edge to y + font_edge do
    begin
     for j := x - font_edge to x + font_edge do
      lazBMPedge.Colors[j,k]:= edgeColor;
    end;
   end;
 end;


  // Añadimos el reborde
 for y := 0 to lazBMPedge.Height - 1 do
 begin
  for x := 0 to lazBMPedge.Width - 1 do
  begin
   if FPColorToTColor(lazBMPdst.Colors[x,y]) = inifile_fnt_color then
    continue;
   if FPColorToTColor(lazBMPedge.Colors[x,y]) = inifile_edge_color then
    lazBMPdst.Colors[x,y] := edgeCOLOR;
  end;
 end;


// fnt_container.char_data[index].Bitmap.Destroy;
 fnt_container.char_data[index].Bitmap.LoadFromIntfImage(lazBMPdst);

 lazBMPdst.free;
 lazBMPsrc.free;
 lazBMPedge.free;

 bmp_dst.Destroy;
 bmp_edge.Destroy;

end;

// Usage  NewColor:= Blend(Color1, Color2, blending level 0 to 100);
function Blend(Color1, Color2: TColor; A: Byte): TColor;
var
  c1, c2: LongInt;
  r, g, b, v1, v2: byte;
begin
  A:= Round(2.55 * A);
  c1 := ColorToRGB(Color1);
  c2 := ColorToRGB(Color2);
  v1:= Byte(c1);
  v2:= Byte(c2);
  r:= A * (v1 - v2) shr 8 + v2;
  v1:= Byte(c1 shr 8);
  v2:= Byte(c2 shr 8);
  g:= A * (v1 - v2) shr 8 + v2;
  v1:= Byte(c1 shr 16);
  v2:= Byte(c2 shr 16);
  b:= A * (v1 - v2) shr 8 + v2;
  Result := (b shl 16) + (g shl 8) + r;
end;

procedure TfrmMainFNT.InsertShadow( index : LongInt );
var
 j, k, x, y, xs, ys,
 bmp_width, bmp_height : LongInt;
 bmp_dst, bmp_tmp : TBitmap;
 lazBMPsrc, lazBMPdst  : TLazIntfImage;
 lazBMPtmp  : TLazIntfImage;
 fontColor : TFPColor;
 shadowColor : TFPColor;
 edgeColor : TFPColor;
 mixEdgeColor : TFPColor;
 mixFontColor : TFPColor;

begin
 // Desplazamiento de la imagen
 x := 0; y := 0;
 xs:= 0; ys:= 0;

 fontColor := TColorToFPColor(inifile_fnt_color);
 fontColor.alpha:=(muldiv(high(word),alpha_font,100) ) and $FF00;
 edgeColor := TColorToFPColor(inifile_edge_color);
 edgeColor.alpha:=(muldiv(high(word),alpha_edge,100)) and $FF00;
 shadowColor := TColorToFPColor(inifile_shadow_color);
 shadowColor.alpha:=(muldiv(high(word),alpha_shadow,100)) and $FF00;
 // Posición de la Tipografía
 if ( rbsLT.Checked or rbsLM.Checked or rbsLD.Checked ) then
  x := font_shadow;

 if ( rbsLT.Checked or rbsTM.Checked or rbsRT.Checked ) then
  y := font_shadow;

 // Posición de la sombra
 if ( rbsRT.Checked or rbsRM.Checked or rbsRD.Checked ) then
  xs := font_shadow;

 if ( rbsLD.Checked or rbsDM.Checked or rbsRD.Checked ) then
  ys := font_shadow;

 bmp_Width  := fnt_container.header.char_info[index].width;
 bmp_Height := fnt_container.header.char_info[index].height;

 // Calculo del tamaño de la imagen
 if ( rbsLM.Checked or rbsRM.Checked ) then
  bmp_Width  := bmp_Width  +  font_shadow
 else if ( rbsTM.Checked or rbsDM.Checked ) then
  bmp_Height := bmp_Height +  font_shadow
 else
 begin
  bmp_Width  := bmp_Width  +  font_shadow;
  bmp_Height := bmp_Height +  font_shadow;
 end;

 fnt_container.header.char_info[index].width  := bmp_Width;
 fnt_container.header.char_info[index].height := bmp_Height;

 bmp_dst := TBitmap.Create;
 bmp_dst.PixelFormat := pf32bit;
 bmp_dst.Width  := bmp_Width;
 bmp_dst.Height := bmp_Height;

 bmp_tmp := TBitmap.Create;
 bmp_tmp.PixelFormat := pf32bit;
 //bmp_tmp.Palette := CopyPalette(fnt_hpal);
 bmp_tmp.Width  := bmp_Width;
 bmp_tmp.Height := bmp_Height;

 ClearBitmap(bmp_dst);
 ClearBitmap(bmp_tmp);

 // Pintamos la sombra
 lazBMPsrc:= fnt_container.char_data[index].Bitmap.CreateIntfImage;
 lazBMPdst:= bmp_dst.CreateIntfImage;

 for k := 0 to lazBMPsrc.Height - 1 do
 begin
  for j := 0 to lazBMPsrc.Width - 1 do
   if ((FPColorToTColor(lazBMPsrc.Colors[j,k]) = inifile_fnt_color) or
       (FPColorToTColor(lazBMPsrc.Colors[j,k]) = inifile_edge_color)) then
    lazBMPdst.Colors[j + xs,k+ys] := shadowColor;
 end;

 fnt_container.header.char_info[index].width  := lazBMPdst.Width;
 fnt_container.header.char_info[index].height := lazBMPdst.Height;

 lazBMPtmp:=bmp_tmp.CreateIntfImage;
 // Desplazamiento horizontal
  for k := 0 to lazBMPsrc.Height - 1 do
  begin
   for j := lazBMPsrc.Width - 1 downto 0 do
    if ((FPColorToTColor(lazBMPsrc.Colors[j,k]) = inifile_fnt_color) or
        (FPColorToTColor(lazBMPsrc.Colors[j,k]) = inifile_edge_color)) then
     lazBMPtmp[j + x,k+y] := lazBMPsrc.Colors[j,k];
  end;

  mixFontColor:= TColorToFPColor(Blend(inifile_fnt_color,inifile_shadow_color,alpha_font));
  mixFontColor.alpha:= fontColor.alpha;
  mixEdgeColor:= TColorToFPColor(Blend(inifile_edge_color,inifile_shadow_color,alpha_edge));
  mixEdgeColor.alpha:= edgeColor.alpha;
  // Añadimos la sombra
 for k := 0 to lazBMPtmp.Height -1 do
 begin
  for j := 0 to lazBMPtmp.Width - 1 do
  begin
   if (FPColorToTColor(lazBMPdst.Colors[j,k]) = inifile_shadow_color) then
   begin
    if FPColorToTColor(lazBMPtmp.Colors[j,k]) = inifile_fnt_color then
      lazBMPtmp.Colors[j,k]:= mixFontColor
    else
     if FPColorToTColor(lazBMPtmp.Colors[j,k]) = inifile_edge_color then
          lazBMPtmp.Colors[j,k]:= mixEdgeColor
     else
      lazBMPtmp.Colors[j,k]:= shadowColor;
   end;
  end;
 end;
 // fnt_container.char_data[index].Bitmap.Destroy;
  fnt_container.char_data[index].Bitmap.LoadFromIntfImage(lazBMPtmp);

 lazBMPtmp.free;
 lazBMPsrc.free;
 lazBMPdst.free;
 bmp_tmp.Destroy;
 bmp_dst.Destroy;
end;



procedure TfrmMainFNT.RenderFNT( index : LongInt );
var
 j, k : LongInt;
 lazBMP,lazBMPfnt,lazBMPedge,lazBMPshadow : TLazIntfImage;
 ncolor : TColor;
begin

 lazBMP:= fnt_container.char_data[index].Bitmap.CreateIntfImage;
 lazBMPfnt:= img_font.CreateIntfImage;
 lazBMPedge:= img_edge.CreateIntfImage;
 lazBMPshadow:= img_shadow.CreateIntfImage;


 for k := 0 to lazBMP.Height - 1 do
 begin
  for j := 0 to lazBMP.Width - 1 do
  begin
   nColor := FPColorToTColor(lazBMP.Colors[j,k]);

   if  nColor = inifile_fnt_color then
   begin
      if inifile_fnt_image <> '' then
         lazBMP.Colors[j,k] := lazBMPfnt.Colors[j mod img_font.Width, k mod img_font.Height];
      continue;
   end;
   if  nColor = inifile_edge_color then
   begin
      if inifile_edge_image <> '' then
       lazBMP.Colors[j,k] := lazBMPedge.Colors[j mod img_edge.Width, k mod img_edge.Height];
      continue;
   end;
   if  nColor = inifile_shadow_color then
   begin
      if inifile_shadow_image <> '' then
       lazBMP.Colors[j,k] := lazBMPshadow.Colors[j mod img_shadow.Width, k mod img_shadow.Height];
      continue;
   end;
(*
    B16 :=  nColor shr 19;
    G16 := (nColor and 64512) shr 10;
    R16 := (nColor and 248  ) shr 3;

    if( Color_Table_16_to_8[R16, G16, B16] = 0 ) then
        Color_Table_16_to_8[R16, G16, B16] := Find_Color(1, R16 shl 3, G16 shl 2, B16 shl 3);

    pSrc^[j] := Color_Table_16_to_8[R16, G16, B16];
*)
  end;
 end;
 fnt_container.char_data[index].Bitmap.LoadFromIntfImage(lazBMP);
 lazBMP.free;
 lazBMPfnt.free;
 lazBMPedge.free;
 lazBMPshadow.free;
end;


procedure TfrmMainFNT.CreatePAL;
var
 table_pixels : Array [0 .. 65535] of Table_Sort;
 sort_pixels  : TList;
 sort_pixel   : Table_Sort;
 images       : Boolean;
 i, j, k, R16, G16, B16 : LongInt;
begin
 Init_Color_Table;

 // Si tenemos imágenes
 images := (inifile_fnt_image <> '') or (inifile_edge_image <> '') or (inifile_shadow_image <> '');

 if (inifile_fnt_image <> '') then
  for j := 0 to img_font.Width - 1 do
    for k := 0 to img_font.Height - 1 do
     begin
      // Conversión a 16 bits
      B16 :=  img_font.Canvas.Pixels[j, k] shr 19;
      G16 := (img_font.Canvas.Pixels[j, k] and 64512) shr 10;
      R16 := (img_font.Canvas.Pixels[j, k] and 248) shr 3;

      Color_Table[R16, G16, B16] := Color_Table[R16, G16, B16] + 1;
     end;

 if (inifile_edge_image <> '') and (sedSizeEdge.Value > 0) then
  for j := 0 to img_edge.Width - 1 do
    for k := 0 to img_edge.Height - 1 do
     begin
      // Conversión a 16 bits
      B16 :=  img_edge.Canvas.Pixels[j, k] shr 19;
      G16 := (img_edge.Canvas.Pixels[j, k] and 64512) shr 10;
      R16 := (img_edge.Canvas.Pixels[j, k] and 248) shr 3;

      Color_Table[R16, G16, B16] := Color_Table[R16, G16, B16] + 1;
     end;

 if (inifile_shadow_image <> '') and (sedSizeShadow.Value > 0) then
  for j := 0 to img_shadow.Width - 1 do
    for k := 0 to img_shadow.Height - 1 do
     begin
      // Conversión a 16 bits
      B16 :=  img_shadow.Canvas.Pixels[j, k] shr 19;
      G16 := (img_shadow.Canvas.Pixels[j, k] and 64512) shr 10;
      R16 := (img_shadow.Canvas.Pixels[j, k] and 248) shr 3;

      Color_Table[R16, G16, B16] := Color_Table[R16, G16, B16] + 1;
     end;

 sort_pixels := TList.Create;

 // Si tenemos imágenes
 if images then
 begin
  // Ordenamos los resultados del análisis
  for i := 0 to 65535 do
  begin
   // Conversión a 16 bits
   B16 :=  i shr 11;
   G16 := (i and 2016) shr 5;
   R16 := (i and 31);

   table_pixels[i].nSort := Color_Table[R16, G16, B16];
   table_pixels[i].nLink := i;

   sort_pixels.Add(@table_pixels[i]);
  end;

  sort_pixels.Sort(@SortCompare);
 end;

 // Establecemos el color transparente
 fnt_container.header.palette[ 0 ] := 0;
 fnt_container.header.palette[ 1 ] := 0;
 fnt_container.header.palette[ 2 ] := 0;

 j := 0;

 // Establecemos el color de Tipografía
 if inifile_fnt_image = '' then
 begin
  j := j + 1;

  SetPaletteColor(j, inifile_fnt_color);
 end;

 // Establecemos del borde
 if (inifile_edge_image = '') then
 begin
  j := j + 1;
  SetPaletteColor(j, inifile_edge_color);
    if (alpha_edge < 100 ) then
    begin
     j := j + 1;
     SetPaletteColor(j, Blend(inifile_fnt_color,inifile_edge_color,alpha_font));
    end;

 end;

 // Establecemos de la sombra
 if (inifile_shadow_image = '') then
 begin
  j := j + 1;
  SetPaletteColor(j, inifile_shadow_color);
  if (alpha_shadow < 100 ) then
   begin
     j := j + 1;
     SetPaletteColor(j, Blend(inifile_fnt_color,inifile_shadow_color,alpha_font));
   end;
 end;

 // Si tenemos imágenes
 if images then
 begin
  // Establecemos la paleta de colores
  i := 65535;

  while j < 256 do
  begin
   sort_pixel := Table_Sort(sort_pixels.Items[i]^);

   i := i - 1;

   // Si es el color transparente
   if sort_pixel.nLink = 0 then
    continue;

   // Si se establece color de Tipografía
   if ((inifile_fnt_image = '') and (sort_pixel.nLink = inifile_fnt_color)) then
    continue;

   // Si se establece color de borde
   if ((inifile_edge_image = '') and (sort_pixel.nLink = inifile_edge_color)) then
    continue;

   // Si se establece color de sombra
   if ((inifile_shadow_image = '') and (sort_pixel.nLink = inifile_shadow_color)) then
    continue;

   // Conversión a 16 bits
   B16 :=  sort_pixel.nLink shr 11;
   G16 := (sort_pixel.nLink and 2016) shr 5;
   R16 := (sort_pixel.nLink and 31);

   j := j + 1;

   fnt_container.header.palette[  j * 3      ] := R16 shl 3;
   fnt_container.header.palette[ (j * 3) + 1 ] := G16 shl 2;
   fnt_container.header.palette[ (j * 3) + 2 ] := B16 shl 3;
  end;
 end;

 // Establecemos de la sombra
 if not images then
 begin
  j := j + 1;

  SetPaletteColor(j, clRed);
 end;

 sort_pixels.Free;

 Create_HPal;
end;


procedure TfrmMainFNT.ExtractAllFNT;
var
 i : LongInt;
begin
  dpCount := 0;

  if cbNumbers.Checked then
  for i := 48 to 57 do
  begin
   ExtractFNT( i );
   drawProgress('Generando los números...');
  end;

 if cbUpper.Checked then
  for i := 65 to 90 do
  begin
   ExtractFNT( i );
   drawProgress('Generando las mayúsculas...');
  end;

 if cbMinus.Checked then
  for i := 97 to 122 do
  begin
   ExtractFNT( i );
   drawProgress('Generando las minúsculas...');
  end;

 if cbSymbol.Checked then
 begin
  for i := 0 to 47 do
  begin
   ExtractFNT( i );
   drawProgress('Extrayendo los símbolos...');
  end;
  for i := 58 to 64 do
  begin
   ExtractFNT( i );
   drawProgress('Extrayendo los símbolos...');
  end;
  for i := 91 to 96 do
  begin
   ExtractFNT( i );
   drawProgress('Extrayendo los símbolos...');
  end;

  for i := 123 to 127 do
  begin
   ExtractFNT( i );
   drawProgress('Extrayendo los símbolos...');
  end;
 end;

 if cbExtended.Checked then
  for i := 128 to 255 do
  begin
   ExtractFNT( i );
   drawProgress('Extrayendo los carácteres extendidos...');
  end;
end;

procedure TfrmMainFNT.MakeFont;
var
 total : LongInt;
begin

 DrawProgress('');

 // Obtenemos el número de letras
 total := GetNumberOfFNT();

 // Si no hay contenido no hace nada
 if total = 0 then
  Exit;

 dpTotal := total;

 sbInfo.Panels.Items[0].Text := '';

 unload_fnt;

 fnt_container.header.charset   := 1; // no aplicar tabla de transformación
 if cbCharset.ItemIndex = 0 then
  fnt_container.header.charset   :=  0; // Aplicar tabla de transformación CP850 a ISO8859_1

 font_edge  := sedSizeEdge.Value;
 font_shadow:= sedSizeShadow.Value;

 ExtractAllFNT;

 // Si hay Reborde
 if font_edge > 0 then
  MakeEdge;

 // Si hay sombra
 if font_shadow > 0 then
  MakeShadow;

 MakeFontDraw;

 SetFNTSetup;

 sbInfo.Panels.Items[1].Text := 'Tamaño: ' + IntToStr(fnt_container.sizeof div 1024) + 'KB';

 DrawProgress('');

 sbSave.Enabled := true;
 sbSaveAs.Enabled := true;

 MakePreview;
 EnableButtons;

end;

procedure TfrmMainFNT.FormResize(Sender: TObject);
begin
 if width  < 640 then width  := 640;
 if height < 480 then height := 480;
end;

procedure TfrmMainFNT.Label5Click(Sender: TObject);
begin

end;

procedure TfrmMainFNT.MakeTextParsingCharset( str : String);
begin
 if fnt_container.header.charset = 0 then
  case cbCharset.ItemIndex of
    0:MakeText(UTF8ToISO_8859_1(str));
    2:MakeText(UTF8ToISO_8859_15(str));
    4:MakeText(UTF8ToCP437(str));
  end
 else
  case cbCharset.ItemIndex of
   3: MakeText(UTF8ToCP1252(str))
  else
    MakeText(UTF8ToCP850(str));
  end;

end;

procedure TfrmMainFNT.EPreviewChange(Sender: TObject);
begin
    MakeTextParsingCharset(EPreview.Text);
end;

procedure TfrmMainFNT.cbCharsetChange(Sender: TObject);
begin
  inifile_charset_to_gen:=cbCharset.ItemIndex;
end;


function TfrmMainFNT.OpenFNT( sfile: string ) : boolean;
var
 WorkDir: string;
 BinDir: string;
 f : TextFile;
begin
 result:=false;
 // Comprobamos si es un formato sin comprimir
 if not FNT_Test(sfile) then
 begin

 WorkDir := GetTempDir(False) ;
 BinDir := ExtractFilePath(Application.ExeName);

 {$IFDEF WINDOWS}
  RunExe(BinDir + DirectorySeparator+'\zlib\zlib.exe -d "'+ sfile + '"', WorkDir );
 {$ENDIF}

 {$IFDEF Linux}
   RunExe('/bin/gzip -dc "'+ sfile+'"', WorkDir,WorkDir +'________.uz' );
 {$ENDIF}

  result := load_fnt( WorkDir +'________.uz');

  AssignFile(f, WorkDir +'________.uz');
  Erase(f);

 end
 else
  result := load_fnt(sfile);
end;

procedure TfrmMainFNT.sbOpenClick(Sender: TObject);

begin
 if dlgOpen.Execute then
 begin
  if( not FileExistsUTF8(dlgOpen.FileName) { *Converted from FileExists*  } ) then
  begin
   showmessage('No existe el archivo.');
   Exit;
  end;

  pInfo.Caption := 'Cargando Tipografía...';
  pInfo.Show;
  Repaint;

  if OpenFNT( dlgOpen.FileName ) then
  begin
   sbInfo.Panels.Items[0].Text := dlgOpen.FileName;
   sbInfo.Panels.Items[1].Text := 'Tamaño: ' + IntToStr(fnt_container.sizeof div 1024) + 'KB';

   sbSave.Enabled := true;
   sbSaveAs.Enabled := true;

   MakePreview;

   cbNumbers.Checked  := ((inifile_symbol_type and 1 ) = 1);
   cbUpper.Checked    := ((inifile_symbol_type and 2 ) = 2);
   cbMinus.Checked    := ((inifile_symbol_type and 4 ) = 4);
   cbSymbol.Checked   := ((inifile_symbol_type and 8 ) = 8);
   cbExtended.Checked := ((inifile_symbol_type and 16) = 16);

   if fnt_container.header.file_type[2] = 'x' then
   begin
    cbCharset.ItemIndex:= fnt_container.header.charset;
   end;

  end;

  pInfo.Hide;
  EnableButtons;
 end;
end;

procedure TfrmMainFNT.openParamFile;
begin
 // Si hay Tipografía como parámetro
 if ParamCount = 1 then
  if FileExistsUTF8(ParamStr(1) ) { *Converted from FileExists*  } then
   if load_fnt( ParamStr(1) ) then
   begin
    sbInfo.Panels.Items[0].Text := dlgOpen.FileName;
    sbInfo.Panels.Items[1].Text := 'Tamaño: ' + IntToStr(fnt_container.sizeof div 1024) + 'KB';

    sbSave.Enabled := true;
    sbSaveAs.Enabled := true;

    if fnt_container.header.file_type[2]='x' then
        inifile_symbol_type := fnt_container.header.charset;

    MakePreview;
   end;

end;

procedure TfrmMainFNT.FormCreate(Sender: TObject);

begin
 cbStyle.Items.Clear;
 cbStyle.Items.Add(LNG_NORMAL);
 cbStyle.Items.Add(LNG_BOLD);
 cbStyle.Items.Add(LNG_UNDERLINE);
 cbStyle.Items.Add(LNG_LABELED);
 // Carga la configuración de inicio
 load_inifile;
 alpha_edge:= seRealfa.value;
 alpha_shadow:= seSoalfa.value;
 alpha_font:= seFontAlfa.value;

 UpdateBGColor;

 // Crea una Tipografía
 nFont := TFont.Create;
 cbStyle.ItemIndex := 0;

 // Crea los BITMAPS necesarios
 CreateBitmaps;

 // Inicializa la Tipografía
 inifile_load_font( nFont );

 nFont.Size := inifile_fnt_size;
 edSizeFont.Text := IntToStr(nFont.Size);
 lbNameFont.Caption  := nFont.Name;
 lbNameFontB.Caption := nFont.Name;

 sedSizeEdge.Value   := inifile_edge_size;
 sedSizeShadow.Value := inifile_shadow_offset;

 cbStyle.ItemIndex := inifile_fnt_effects;

 if inifile_fnt_effects = 0 then // Normal
  nFont.Style := [];

 if inifile_fnt_effects = 1 then // Negrita
  nFont.Style := [fsBold];

 if inifile_fnt_effects = 2 then // Subrayado
  nFont.Style := [fsUnderline];

 if inifile_fnt_effects = 3 then // Tachado
  nFont.Style := [fsStrikeOut];


 cbNumbers.Checked  := ((inifile_symbol_type and 1 ) = 1);
 cbUpper.Checked    := ((inifile_symbol_type and 2 ) = 2);
 cbMinus.Checked    := ((inifile_symbol_type and 4 ) = 4);
 cbSymbol.Checked   := ((inifile_symbol_type and 8 ) = 8);
 cbExtended.Checked := ((inifile_symbol_type and 16) = 16);

 case inifile_shadow_pos of
  1 : rbsLT.Checked := true;
  2 : rbsTM.Checked := true;
  3 : rbsRT.Checked := true;
  4 : rbsLM.Checked := true;
  5 : rbsRM.Checked := true;
  6 : rbsLD.Checked := true;
  7 : rbsDM.Checked := true;
  8 : rbsRD.Checked := true;
 end;

 // Si tenemos imagen para la Tipografía
 if (inifile_fnt_image <> '') then
  try
   img_font.LoadFromFile(inifile_fnt_image);
  except
   inifile_fnt_image := '';
  end;

 // Si tenemos imagen para el borde
 if (inifile_edge_image <> '') then
  try
   img_edge.LoadFromFile(inifile_edge_image);
  except
   inifile_edge_image := '';
  end;

 // Si tenemos imagen para la sombra
 if (inifile_shadow_image <> '') then
  try
   img_shadow.LoadFromFile(inifile_shadow_image);
  except
   inifile_shadow_image := '';
  end;

 // Establece el RadioButton seleccionado
 rbSFontClick(Sender);
end;

procedure TfrmMainFNT.lvFontExit(Sender: TObject);
begin
 unload_fnt;
end;

procedure TfrmMainFNT.sbLoadFontClick(Sender: TObject);
begin
 dlgFont.Font.Assign(nFont);
 dlgFont.Font.Color := inifile_fnt_color;

 if not dlgFont.Execute then
  Exit;

 nFont.Assign(dlgFont.Font);

 edSizeFont.Text := IntToStr(nFont.Size);
 
 lbNameFont.Caption  := nFont.Name;
 lbNameFontB.Caption := nFont.Name;

 inifile_fnt_color   := nFont.Color;
 inifile_fnt_charset := nFont.Charset;
 inifile_fnt_height  := nFont.Height;
 inifile_fnt_size    := nFont.Size;
 inifile_fnt_name    := nFont.Name;

 if rbSFont.Checked then
  rbSFontClick(Sender);

 //nFont.Style := [];

 if( nFont.Style = [] ) then
  cbStyle.ItemIndex := 0
 else if( nFont.Style = [fsBold] ) then
  cbStyle.ItemIndex := 1
 else if( nFont.Style = [fsUnderline] ) then
  cbStyle.ItemIndex := 2
 else if( nFont.Style = [fsStrikeOut] ) then
  cbStyle.ItemIndex := 3
 else
  begin
   cbStyle.ItemIndex := 0;
   nFont.Style := [];
  end;

 inifile_fnt_effects := cbStyle.ItemIndex;

 write_inifile;
end;

procedure TfrmMainFNT.edSizeEdgeKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
 else
  key := chr(13);
 end;
end;

procedure TfrmMainFNT.edSizeShadowKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
 else
  key := chr(13);
 end;
end;

procedure TfrmMainFNT.edSizeFontKeyPress(Sender: TObject; var Key: Char);
begin
 case key of
  '0' .. '9', chr(8): begin end;
 else
  key := chr(13);
 end;
end;

procedure TfrmMainFNT.sbShowFNTClick(Sender: TObject);
begin
 frmFNTView.setImageBGColor(inifile_bgcolor);
  frmFNTView.Show;
end;

procedure TfrmMainFNT.sbShowPaletteClick(Sender: TObject);
begin
 frmPalette.ShowModal;
end;

procedure TfrmMainFNT.createSelectedImageBox(color1 :TColor);
var
 bmp : TBitmap;
begin
  bmp:= TBitmap.Create;
  bmp.PixelFormat:=pf24bit;
  bmp.SetSize(50,50);
  bmp.Canvas.Brush.Color := clBlack;
  bmp.Canvas.Rectangle(0, 0, 50, 50);
  bmp.Canvas.Brush.Color := color1;
  bmp.Canvas.FillRect(Rect(1,1, 49, 49));
  imgSelect.Picture.Assign(bmp);
  FreeAndNil(bmp);
end;


procedure TfrmMainFNT.rbSFontClick(Sender: TObject);
begin
 sbSelectColor.Font.Style := [];
 sbSelectImage.Font.Style := [];

 if inifile_fnt_image = '' then
 begin

  sbSelectColor.Font.Style := [fsBold];
  createSelectedImageBox(inifile_fnt_color);
 end
 else
 begin
  sbSelectImage.Font.Style := [fsBold];

  imgSelect.Picture.Assign(img_font);
 end;
end;

procedure TfrmMainFNT.rbSEdgeClick(Sender: TObject);
begin
 sbSelectColor.Font.Style := [];
 sbSelectImage.Font.Style := [];

 if inifile_edge_image = '' then
 begin
  sbSelectColor.Font.Style := [fsBold];
  createSelectedImageBox(inifile_edge_color);
 end
 else
 begin
  sbSelectImage.Font.Style := [fsBold];
  imgSelect.Picture.Assign(img_edge);
 end;
end;

procedure TfrmMainFNT.rbSShadowClick(Sender: TObject);
begin
 sbSelectColor.Font.Style := [];
 sbSelectImage.Font.Style := [];

 if inifile_shadow_image = '' then
 begin
  sbSelectColor.Font.Style := [fsBold];
  createSelectedImageBox(inifile_shadow_color);
 end
 else
 begin
  sbSelectImage.Font.Style := [fsBold];

  imgSelect.Picture.Assign(img_shadow);
 end;
end;

procedure TfrmMainFNT.sbSelectColorClick(Sender: TObject);
begin
 if dlgColor.Execute then
 begin

  if rbSFont.Checked then
  begin
   inifile_fnt_color := dlgColor.Color;
   inifile_fnt_image := '';
   alpha_font:= seFontAlfa.value;
   rbSFontClick(Sender);
  end;

  if rbSEdge.Checked then
  begin
   inifile_edge_color := dlgColor.Color;
   inifile_edge_image := '';
   alpha_edge:= seRealfa.value;
   rbSEdgeClick(Sender);
  end;

  if rbSShadow.Checked then
  begin
   inifile_shadow_color := dlgColor.Color;
   inifile_shadow_image := '';
   alpha_shadow:= seSoalfa.value;
   rbSShadowClick(Sender);
  end;

 end;
end;

procedure TfrmMainFNT.sbSelectImageClick(Sender: TObject);
begin
 if not dlgOpenPicture.Execute then
  Exit;

 if rbsFont.Checked then
 begin
  try
   img_font.LoadFromFile(dlgOpenPicture.FileName);
  except
   Exit;
  end;

  imgSelect.Picture.Assign( img_font);

  inifile_fnt_image := dlgOpenPicture.FileName;

  sbSelectColor.Font.Style := [];
  sbSelectImage.Font.Style := [fsBold];
 end;

 if rbsEdge.Checked then
 begin
  try
   img_edge.LoadFromFile(dlgOpenPicture.FileName);
  except
   Exit;
  end;

  imgSelect.Picture.Assign( img_edge);

  inifile_edge_image := dlgOpenPicture.FileName;

  sbSelectColor.Font.Style := [];
  sbSelectImage.Font.Style := [fsBold];
 end;

 if rbsShadow.Checked then
 begin
  try
   img_shadow.LoadFromFile(dlgOpenPicture.FileName);
  except
   Exit;
  end;

  imgSelect.Picture.Assign( img_shadow);

  inifile_shadow_image := dlgOpenPicture.FileName;

  sbSelectColor.Font.Style := [];
  sbSelectImage.Font.Style := [fsBold];
 end;
end;

procedure TfrmMainFNT.cbStyleChange(Sender: TObject);
begin
 inifile_fnt_effects := cbStyle.ItemIndex;
 
 if( cbStyle.ItemIndex = 0 ) then
  nFont.Style := [];

 if( cbStyle.ItemIndex = 1 ) then
  nFont.Style := [fsBold];

 if( cbStyle.ItemIndex = 2 ) then
  nFont.Style := [fsUnderline];

 if( cbStyle.ItemIndex = 3 ) then
  nFont.Style := [fsStrikeOut];
end;

procedure TfrmMainFNT.FormClose(Sender: TObject; var Action1: TCloseAction);
begin
 inifile_fnt_size    := StrToInt(edSizeFont.Text);
 inifile_edge_size   := sedSizeEdge.Value;
 inifile_shadow_offset := sedSizeShadow.Value;

 inifile_fnt_effects := cbStyle.ItemIndex;

end;

procedure TfrmMainFNT.cbUpperClick(Sender: TObject);
begin
 if (cbUpper.Checked and ((inifile_symbol_type and 2) = 0)) then
   inifile_symbol_type := inifile_symbol_type + 2;

 if ((not cbUpper.Checked) and ((inifile_symbol_type and 2) = 2)) then
   inifile_symbol_type := inifile_symbol_type - 2;
end;

procedure TfrmMainFNT.cbMinusClick(Sender: TObject);
begin
 if (cbMinus.Checked and ((inifile_symbol_type and 4) = 0)) then
   inifile_symbol_type := inifile_symbol_type + 4;

 if ((not cbMinus.Checked) and ((inifile_symbol_type and 4) = 4)) then
   inifile_symbol_type := inifile_symbol_type - 4;
end;

procedure TfrmMainFNT.cbNumbersClick(Sender: TObject);
begin
 if (cbNumbers.Checked and ((inifile_symbol_type and 1) = 0)) then
   inifile_symbol_type := inifile_symbol_type + 1;

 if ((not cbNumbers.Checked) and ((inifile_symbol_type and 1) = 1)) then
   inifile_symbol_type := inifile_symbol_type - 1;
end;

procedure TfrmMainFNT.cbSymbolClick(Sender: TObject);
begin
 if (cbSymbol.Checked and ((inifile_symbol_type and 8) = 0)) then
   inifile_symbol_type := inifile_symbol_type + 8;

 if ((not cbSymbol.Checked) and ((inifile_symbol_type and 8) = 8)) then
   inifile_symbol_type := inifile_symbol_type - 8;
end;

procedure TfrmMainFNT.cbExtendedClick(Sender: TObject);
begin
 if (cbExtended.Checked and ((inifile_symbol_type and 16) = 0)) then
   inifile_symbol_type := inifile_symbol_type + 16;

 if ((not cbExtended.Checked) and ((inifile_symbol_type and 16) = 16)) then
   inifile_symbol_type := inifile_symbol_type - 16;
end;

procedure TfrmMainFNT.rbsRDClick(Sender: TObject);
begin
 inifile_shadow_pos := 8;
end;

procedure TfrmMainFNT.rbsDMClick(Sender: TObject);
begin
 inifile_shadow_pos := 7;
end;

procedure TfrmMainFNT.rbsLDClick(Sender: TObject);
begin
 inifile_shadow_pos := 6;
end;

procedure TfrmMainFNT.rbsRMClick(Sender: TObject);
begin
 inifile_shadow_pos := 5;
end;

procedure TfrmMainFNT.rbsLMClick(Sender: TObject);
begin
 inifile_shadow_pos := 4;
end;

procedure TfrmMainFNT.rbsRTClick(Sender: TObject);
begin
 inifile_shadow_pos := 3;
end;

procedure TfrmMainFNT.rbsTMClick(Sender: TObject);
begin
 inifile_shadow_pos := 2;
end;

procedure TfrmMainFNT.rbsLTClick(Sender: TObject);
begin
 inifile_shadow_pos := 1;
end;

procedure TfrmMainFNT.sbSaveClick(Sender: TObject);
begin
 if sbInfo.Panels.Items[0].Text = '' then
    sbSaveAsClick(Sender)
 else
  if FileExistsUTF8(sbInfo.Panels.Items[0].Text) { *Converted from FileExists*  }  then
   if save_fnt(sbInfo.Panels.Items[0].Text, fBPP.cbBPP.itemIndex) then
    showmessage('Tipografía guardada.');
end;

procedure TfrmMainFNT.sbSaveAsClick(Sender: TObject);
var
 QueryResult : LongInt;
 //str : String;
begin
 QueryResult := IDYES;
 if fBpp.ShowModal = mrOk then
   if dlgSave.Execute then
   begin
    (*if( StrPos(StrLower(PChar(dlgSave.FileName)), '.fnt') = nil ) then
     str := dlgSave.FileName + '.fnt'
    else
     str := dlgSave.FileName;*)

    if( FileExistsUTF8(dlgSave.FileName) { *Converted from FileExists*  } ) then
     QueryResult := MessageBox(frmMainFNT.Handle, 'El fichero ya existe ¿Desea sobreescribirlo?', '¡Aviso!', 4);

    //Si se cancela la operación
    if QueryResult = IDNO then
     Exit;

    if fBPP.cbBpp.ItemIndex = 1 then
    begin
     // Creando paleta
     if (not FrmCFG.user_palette) or (FrmCFG.rbFNT2PAL.Checked) then
     begin
      DrawProgress('Calculando paleta...');
      CreatePAL;
     end;
     // Actualizando información
     Init_Color_Table_16_to_8;

     // Inicializa la tabla con la paleta
     Init_Color_Table_With_Palette;

    end;


    if save_fnt( dlgSave.FileName , fBPP.cbBpp.ItemIndex) then
    begin
     sbInfo.Panels.Items[0].Text := dlgSave.FileName;
     showmessage('Fuente guardada.');
     DrawProgress('');
    end;
    EnableButtons;
   end;
end;

procedure TfrmMainFNT.CreateBitmaps;
var
 i : Integer;
begin
 img_font   := TBitMap.Create;
 img_edge   := TBitMap.Create;
 img_shadow := TBitMap.Create;

 img_font.PixelFormat   := pf32bit;
 img_edge.PixelFormat   := pf32bit;
 img_shadow.PixelFormat := pf32bit;

 for i := 0 to 255 do
 begin
   fnt_container.char_data[i].ischar := false;

   //fnt_container.char_data[i].Bitmap        := TBitMap.Create;
   //fnt_container.char_data[i].Bitmap.PixelFormat := pf32bit;
   //fnt_container.char_data[i].Bitmap.Width  := 100;
   //fnt_container.char_data[i].Bitmap.Height := 100;

   fnt_container.header.char_info[i].width   := 0;//fnt_container.char_data[i].Bitmap.Width;
   fnt_container.header.char_info[i].height  := 0;//fnt_container.char_data[i].Bitmap.Height;
   fnt_container.header.char_info[i].vertical_offset := 0;
 end;
end;

procedure TfrmMainFNT.DestroyBitmaps;
begin
 unload_fnt;
 img_font.Destroy;
 img_edge.Destroy;
 img_shadow.Destroy;
end;

procedure TfrmMainFNT.ClearBitmap(var bmp : TBitmap);
var
 x, y   : Integer;
 lazBMP : TLazIntfImage;
begin
 lazBMP:= bmp.CreateIntfImage;
 for y := 0 to bmp.Height - 1 do
   for x := 0 to bmp.Width - 1 do
   lazBMP.Colors[x,y]:=colTransparent;
 bmp.LoadFromIntfImage(lazBMP);
 lazBMP.free;
end;

procedure TfrmMainFNT.sbChangeBGColorClick(Sender: TObject);
begin
 if dlgColor.Execute then
 begin
  inifile_bgcolor := dlgColor.Color;

  UpdateBGColor;

  write_inifile;
 end;
end;

procedure TfrmMainFNT.UpdateBGColor;
var
 i, j : Integer;
begin
 for i := 2 to 17 do
   for j := 2 to 17 do
    sbChangeBGColor.Glyph.Canvas.Pixels[i,j] := inifile_bgcolor;

 pImage.Color := inifile_bgcolor;
end;

procedure TfrmMainFNT.MakeText(str_in: string);
var
 bmp_buffer : TBitmap;
 i, x, nOrd,
 MaxWidth, MaxHeight,
 WSpaces, WSOffset : Integer;
 str : string;
begin
 MaxWidth  := 0;
 MaxHeight := 0;
 str:=trim(str_in);
 if not isFNTLoad then
   exit;
 if str ='' then
 begin
  MakePreview;
  exit;
 end;
 for i := 1 to Length(str) do
 begin
  nOrd := Ord(str[i]);

  if not fnt_container.char_data[nOrd].ischar then
   continue;

  MaxWidth  := MaxWidth  + fnt_container.header.char_info[nOrd].width;

  if (fnt_container.header.char_info[nOrd].height + fnt_container.header.char_info[nOrd].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[nOrd].height + fnt_container.header.char_info[nOrd].vertical_offset;
 end;

 WSpaces := 0;

 // Contamos los espacios en blanco
 for i := 1 to Length(str) do
 begin
  nOrd := Ord(str[i]);

  if nOrd = 32 then
   WSpaces := WSpaces + 1;
 end;

 WSOffset := MaxWidth div (Length(str) - WSpaces);

 MaxWidth := MaxWidth + (WSOffset * WSpaces);

 bmp_buffer := TBitmap.Create;
 bmp_buffer.PixelFormat := pf32bit;
// bmp_buffer.Palette := CopyPalette(fnt_hpal);
 bmp_buffer.Width  := MaxWidth  + 2;
 bmp_buffer.Height := MaxHeight + 2;

// ClearBitmap(bmp_buffer);

 x := 1;

 for i := 1 to Length(str) do
 begin
  nOrd := Ord(str[i]);

  // Si hay un espacio
  if nOrd = 32 then
   x := x + WSOffset;

  if not fnt_container.char_data[nOrd].ischar then
   continue;

  bmp_buffer.Canvas.Draw( x, fnt_container.header.char_info[nOrd].vertical_offset + 1, fnt_container.char_data[nOrd].Bitmap );

  x  := x + fnt_container.header.char_info[nOrd].width;
 end;

 imgPreview.Picture.Bitmap.Assign(bmp_buffer);

// imgPreview.Picture.Bitmap.Transparent:=true;
// imgPreview.Picture.Bitmap.TransparentColor:=clBlack;

 bmp_buffer.Destroy;
end;

procedure TfrmMainFNT.MakeChar(index: integer);
begin
 if not isFNTLoad then
   exit;
 if not fnt_container.char_data[index].ischar then
   exit;
 imgPreview.Picture.Bitmap.Assign(fnt_container.char_data[index].Bitmap);
end;


procedure TfrmMainFNT.sbWriteTextClick(Sender: TObject);
begin
 if not isFNTLoad then
 begin
  showmessage('Aviso, no hay tipografía cargada');
  Exit;
 end;

 if EPreview.Text <> '' then
  MakeText(EPreview.Text);

end;



procedure TfrmMainFNT.sbMakeFontClick(Sender: TObject);
begin
   nFont.Size := StrToInt(edSizeFont.Text);

   inifile_fnt_size      := StrToInt(edSizeFont.Text);
   inifile_edge_size     := sedSizeEdge.Value;
   inifile_shadow_offset := sedSizeShadow.Value;

   inifile_fnt_effects := cbStyle.ItemIndex;

   if inifile_fnt_effects = 0 then // Normal
    nFont.Style := [];

   if inifile_fnt_effects = 1 then // Negrita
    nFont.Style := [fsBold];

   if inifile_fnt_effects = 2 then // Subrayado
    nFont.Style := [fsUnderline];

   if inifile_fnt_effects = 3 then // Tachado
    nFont.Style := [fsStrikeOut];

   write_inifile;

   unload_fnt;

   MakeFont;
   EnableButtons;
end;

procedure TfrmMainFNT.ExportFNT(str : string);
var
 bmp_buffer : TBitmap;
 i, j, x,
 MaxWidth, MaxHeight : Integer;
 lazBMPbuffer, lazBMPfnt : TLazIntfImage;
begin
 MaxWidth  := 0;
 MaxHeight := 0;

 dpCount := 0;
 dpTotal := 256;

 for i := 0 to 255 do
 begin
  MaxWidth  := MaxWidth  + 1;

  if not fnt_container.char_data[i].ischar then
  begin
   MaxWidth  := MaxWidth  + 1;
   continue;
  end;

  MaxWidth  := MaxWidth  + fnt_container.header.char_info[i].width;

  if (fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset) > MaxHeight then
    MaxHeight := fnt_container.header.char_info[i].height + fnt_container.header.char_info[i].vertical_offset;
 end;

 bmp_buffer := TBitmap.Create;
 bmp_buffer.PixelFormat := pf32bit;
 //bmp_buffer.Palette := CopyPalette(fnt_container.hpal);
 bmp_buffer.Width  := MaxWidth +1 ; // +1 to paint the last vertical line
 bmp_buffer.Height := MaxHeight + 2; // +2  to paint the first an last horizontal line

 // Limpiamos la imagen
 lazBMPbuffer:= bmp_buffer.CreateIntfImage;
 for i := 0 to bmp_buffer.Width - 1 do
  for j := 0 to bmp_buffer.Height - 1 do
   lazBMPbuffer.Colors[i,j]:= colBlack;

 x := 1;
 // Copiamos las Tipografías
 for i := 0 to 255 do
 begin
  lazBMPbuffer.Colors[x-1, 0] := colTransparent;

  drawProgress('Exportando caracter:'+inttostr(i)+ '...');


  if not fnt_container.char_data[i].ischar then
  begin
   lazBMPbuffer.Colors[x, 0] := colTransparent;
   x  := x + 2;
   continue;
  end;
  lazBMPfnt :=fnt_container.char_data[i].Bitmap.CreateIntfImage;
  lazBMPbuffer.CopyPixels( lazBMPfnt, x, fnt_container.header.char_info[i].vertical_offset + 1 );
  lazBMPfnt.free;

  lazBMPbuffer.Colors[x + fnt_container.char_data[i].Bitmap.Width, 0] := colTransparent;
  lazBMPbuffer.Colors[x + fnt_container.char_data[i].Bitmap.Width,
     fnt_container.header.char_info[i].vertical_offset + fnt_container.char_data[i].Bitmap.Height + 1] := colTransparent;

  lazBMPbuffer.Colors[x-1, fnt_container.header.char_info[i].vertical_offset + 1] := colTransparent;

  x  := x + fnt_container.header.char_info[i].width + 1;
 end;

 bmp_buffer.LoadFromIntfImage(lazBMPbuffer);
 lazBMPbuffer.Free;

 bmp_buffer.SaveToFile(str);

 bmp_buffer.Destroy;

 drawProgress('');
 showmessage('Tipografía exportada correctamente.');
end;

procedure TfrmMainFNT.ImportFNT( str : string );
var
 bmp_buffer : TBitmap;
 bmp_tmp    : TBitmap;
 bExit      : Boolean;
 i, j, k, x, y : LongInt;
 tWidth, tHeight, tVOffset, tDOffset : Integer;
 lazBMPbuffer,lazBMPtmp : TLazIntfImage;
begin
 if not FileExistsUTF8(str) { *Converted from FileExists*  } then
  Exit;

 bmp_buffer := TBitmap.Create;

 bmp_buffer.LoadFromFile(str);

 lazBMPbuffer:=bmp_buffer.CreateIntfImage;
 // Comprobaciones básicas para ver que pudiese contener Tipografía
 bExit := (bmp_buffer.Width  <= 1) or
          (bmp_buffer.Height <= 1);

 bExit := (lazBMPbuffer.Colors[0,0] <> colTransparent) or bExit;

 //bExit := (lazBMPbuffer.Colors[0,1] <> colBlack) or bExit;

 if bExit then
 begin
  bmp_buffer.Destroy;
  lazBMPbuffer.free;
  showmessage('Esta imagen no contiene una tipografía (FNT)');
  Exit;
 end;

 // Pensamos que contiene una Tipografía e intentamos cargarla
 dpCount := 0;
 dpTotal := 256;

 unload_fnt;


 (*
 // Obtenemos la paleta
 GetPaletteEntries(bmp_buffer.Palette, 0, 256, pal);

 for i := 0 to 255 do
 begin
   fnt_container.header.palette[ i*3     ] := pal[i].peRed;
   fnt_container.header.palette[(i*3) + 1] := pal[i].peGreen;
   fnt_container.header.palette[(i*3) + 2] := pal[i].peBlue;
 end;

 Create_hpal;
 *)

 x := 0;
 y := 0;
 inifile_symbol_type := 0;

 for i := 0 to 255 do
 begin

  drawProgress('Importando caracter: '+inttostr(i)+'...');
  
  // Si no hay caracter
  if lazBMPbuffer.Colors[x + 1, y] = colTransparent then
  begin
   x := x + 2;
   continue;
  end;

  // Obtiene el ancho
  tWidth := 0;

  while lazBMPbuffer.colors[x + tWidth + 1, y] <> colTransparent do
   tWidth := tWidth + 1;

  // Otiene el VOffset
  tVOffset := 0;

  while lazBMPbuffer.colors[x, y + tVOffset + 1] <> colTransparent do
   tVOffset := tVOffset + 1;

  // Otiene el DOffset
  tDOffset := 0 ;

  while lazBMPbuffer.colors[x + tWidth + 1, bmp_buffer.Height - tDOffset - 1] <> colTransparent do
   tDOffset := tDOffset + 1;

  // Obtiene el alto
  tHeight := bmp_buffer.Height - tVOffset - tDOffset - 2;

  bmp_tmp := TBitmap.Create;
  bmp_tmp.PixelFormat := pf32bit;
//  bmp_tmp.Palette := CopyPalette(fnt_hpal);
  bmp_tmp.Width   := tWidth;
  bmp_tmp.Height  := tHeight;

  lazBMPtmp:=bmp_tmp.CreateIntfImage;
  for k := 0 to bmp_tmp.Height - 1 do
   for j := 0 to bmp_tmp.Width - 1 do
    lazBMPtmp.Colors[j,k]:=lazBMPbuffer.colors[x + j + 1,k + tVOffset + 1];

  x := x + bmp_tmp.Width + 1;

  fnt_container.header.char_info[i].vertical_offset:= tVOffset;
  fnt_container.header.char_info[i].width  := tWidth;
  fnt_container.header.char_info[i].height := tHeight;

  fnt_container.char_data[i].Bitmap:= TBitmap.Create;
  fnt_container.char_data[i].Bitmap.LoadFromIntfImage(lazBMPtmp);
  fnt_container.char_data[i].ischar := true;

  // Mayusculas
  if (inifile_symbol_type and 2) = 0 then
   if (i >= 65) and (i <= 90) then
    inifile_symbol_type := inifile_symbol_type + 2;

  // Minusculas
  if (inifile_symbol_type and 4) = 0 then
   if (i >= 97) and (i <= 122) then
    inifile_symbol_type := inifile_symbol_type + 4;

  // Múmeros
  if (inifile_symbol_type and 1) = 0 then
   if (i >= 48) and (i <= 57) then
    inifile_symbol_type := inifile_symbol_type + 1;

  // Simbolos
  if (inifile_symbol_type and 8) = 0 then
   if ( ((i >= 33) and (i <= 47)) or
        ((i >= 58) and (i <= 64)) or
        ((i >= 91) and (i <= 96)) or
        ((i >= 123) and (i <= 127)) ) then
    inifile_symbol_type := inifile_symbol_type + 8;

  // Extendido
  if (inifile_symbol_type and 16) = 0 then
   if (i >= 128) then
    inifile_symbol_type := inifile_symbol_type + 16;
 end;

 lazBMPtmp.free;
 lazBMPbuffer.free;
 bmp_buffer.Destroy;
 bmp_tmp.Destroy;

 SetFNTSetup;
 MakePreview;

 cbNumbers.Checked  := ((inifile_symbol_type and 1 ) = 1);
 cbUpper.Checked    := ((inifile_symbol_type and 2 ) = 2);
 cbMinus.Checked    := ((inifile_symbol_type and 4 ) = 4);
 cbSymbol.Checked   := ((inifile_symbol_type and 8 ) = 8);
 cbExtended.Checked := ((inifile_symbol_type and 16) = 16);

 drawProgress('');
 sbInfo.Panels.Items[1].Text := 'Tamaño: ' + IntToStr(fnt_container.sizeof div 1024) + 'KB';

 showmessage('Tipografía importada correctamente.');
end;

procedure TfrmMainFNT.sbExportClick(Sender: TObject);
 var QueryResult : integer;
begin
 QueryResult := IDYES;

 if not isFNTLoad then
 begin
  showmessage('Aviso, no hay tipografía cargada');
  Exit;
 end
 else
 begin
  sdSaveText.Title := 'Exportar tipografía a BMP';

  if sdSaveText.Execute then
  begin
   if( FileExistsUTF8(sdSaveText.FileName) { *Converted from FileExists*  } ) then
    QueryResult := MessageBox(frmMainFNT.Handle, 'El fichero ya existe ¿Desea sobreescribirlo?', '¡Aviso!', 4);

   //Si se cancela la operación
   if QueryResult = IDNO then
    Exit;

   ExportFNT(sdSaveText.FileName);
  end;
 end;

end;



procedure TfrmMainFNT.sbImportClick(Sender: TObject);
begin

 if odImportFNT.Execute then
 begin
  ImportFNT(odImportFNT.FileName);
  EnableButtons;
 end;
 
end;

procedure TfrmMainFNT.sbOptionsClick(Sender: TObject);
begin
 FrmCFG.palette:=fnt_container.header.palette;
 FrmCFG.ShowModal;
end;

procedure TfrmMainFNT.sbSaveTextClick(Sender: TObject);
var
 QueryResult : integer;
begin
 QueryResult := IDYES;

 if not isFNTLoad then
 begin
  showmessage('Aviso, no hay tipografía cargada');
  Exit;
 end
 else
 begin
  sdSaveText.Title := 'Guardar texto';

  if sdSaveText.Execute then
  begin
   if( FileExistsUTF8(sdSaveText.FileName) { *Converted from FileExists*  } ) then
    QueryResult := MessageBox(frmMainFNT.Handle, 'El fichero ya existe ¿Desea sobreescribirlo?', '¡Aviso!', 4);

   //Si se cancela la operación
   if QueryResult = IDNO then
    Exit;

   imgPreview.Picture.SaveToFile(sdSaveText.FileName);
  end;
 end;
end;

procedure TfrmMainFNT.seCharPreviewChange(Sender: TObject);
begin
 MakeTextParsingCharset(''+chr(seCharPreview.Value));
end;

procedure TfrmMainFNT.seFontAlfaChange(Sender: TObject);
begin
 alpha_font := seFontalfa.value;

end;

procedure TfrmMainFNT.seSoAlfaChange(Sender: TObject);
begin
    alpha_shadow := seSoalfa.value;
end;

procedure TfrmMainFNT.seReAlfaChange(Sender: TObject);
begin
    alpha_edge := seRealfa.value;

end;

procedure TfrmMainFNT.EnableButtons;
begin
   sbShowFNT.Enabled:=((Byte(fnt_container.header.file_type[1])+Byte(fnt_container.header.file_type[2])
   +Byte(fnt_container.header.file_type[3])) <> 0);
end;

end.