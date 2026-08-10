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

unit uFrmSplahs;


interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls
  {$IFDEF WINDOWS}
  , windows
  {$ENDIF}
  ;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    Image1: TImage;
    lblRevision: TLabel;
    tTimer: TTimer;
    procedure tTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Execute;
  end;

{$I revision.inc}
var
  frmSplash: TfrmSplash;

implementation

{$R *.lfm}
{$IFDEF WINDOWS}
function UpdateLayeredWindow(hwnd: HWND; hdcDst: HDC; pptDst: PPoint;
  psize: PSize; hdcSrc: HDC; pptSrc: PPoint; crKey: TColor;
  pblend: PBlendFunction; dwFlags: DWORD): BOOL; stdcall; external 'user32';
{$ENDIF}

procedure TfrmSplash.tTimerTimer(Sender: TObject);
begin
 tTimer.Enabled := false;
 
 frmSplash.ModalResult := mrYes;
 frmSplash.Close;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
begin
 lblRevision.Caption:=RevisionStr;
 execute;
 tTimer.Enabled := true;
end;

procedure TfrmSplash.Execute;
var
   {$IFDEF WINDOWS}
   BlendFunction: TBlendFunction;
   BitmapSize: TSize;
   {$ENDIF}
   BitmapPos: TPoint;
   exStyle: DWORD;
 begin
   {$IFDEF WINDOWS}
   // Enable window layering
   exStyle := GetWindowLongA(Handle, GWL_EXSTYLE);
   if (exStyle and WS_EX_LAYERED = 0) then
     SetWindowLong(Handle, GWL_EXSTYLE, exStyle or WS_EX_LAYERED);
   {$ENDIF}


     // Resize form to fit bitmap
     ClientWidth := image1.picture.Bitmap.Width;
     ClientHeight := image1.picture.Bitmap.Height;

     // Position bitmap on form
     BitmapPos.x:=0;
     BitmapPos.y:=0;

     {$IFDEF WINDOWS}
     BitmapSize.cx := image1.picture.Bitmap.Width;
     BitmapSize.cy := image1.picture.Bitmap.Height;

     // Setup alpha blending parameters
     BlendFunction.BlendOp := AC_SRC_OVER;
     BlendFunction.BlendFlags := 0;
     BlendFunction.SourceConstantAlpha := 255;
     BlendFunction.AlphaFormat := AC_SRC_ALPHA;

     // ... and action!
     UpdateLayeredWindow(Handle, 0, nil, @BitmapSize, image1.picture.Bitmap.Canvas.Handle,
       @BitmapPos, 0, @BlendFunction, ULW_ALPHA);
     {$ENDIF}

end;


end.
