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

unit uFrmMessageBox;


interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons ,uLanguage;

type
  TfrmMessageBox = class(TForm)
    bbButton1: TBitBtn;
    bbButton2: TBitBtn;
    bbButton0: TBitBtn;
    reText: TMemo;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    btType    : Integer;
    btDefault : Integer;
  end;

var
  frmMessageBox: TfrmMessageBox;

 function feMessageBox( title, msg : string; msgtype, dbutton : Integer ) : Integer;

implementation

{$R *.lfm}

 function feMessageBox( title, msg : string; msgtype, dbutton : Integer ) : Integer;
 begin
  frmMessageBox.btType      := msgtype;
  frmMessageBox.Caption     := title;
  frmMessageBox.reText.Text := msg;
  frmMessageBox.btDefault   := dbutton;

  frmMessageBox.ShowModal;

  result := frmMessageBox.ModalResult;
 end;

procedure TfrmMessageBox.FormCreate(Sender: TObject);
begin
 btType    := 0;
 btDefault := 0;
end;

procedure TfrmMessageBox.FormActivate(Sender: TObject);
begin
 bbButton0.Default := false;
 bbButton1.Default := false;
 bbButton2.Default := false;

 bbButton0.Hide;
 bbButton1.Hide;
 bbButton2.Hide;

 case btType of
  0 : begin
       bbButton2.Show;
       bbButton2.Default := true;
      end;
  2, 3 :
      begin
       bbButton0.Show;
       bbButton1.Show;
       bbButton2.Show;

       case btDefault of
        1 : bbButton0.Default := true;
        2 : bbButton1.Default := true;
        3 : bbButton2.Default := true;
       end;
      end;
  1, 4, 5 :
      begin
       bbButton1.Show;
       bbButton2.Show;
       case btDefault of
        1 : bbButton1.Default := true;
        2 : bbButton2.Default := true;
       end;
      end;
 end;

 case btType of
  0 : begin
       bbButton2.ModalResult := mrOK;
       bbButton2.Caption:=LNG_ACCEPT;
      end;
  1 : begin
       bbButton1.ModalResult := mrOK;
       bbButton2.ModalResult := mrCancel;
       bbButton1.Caption:= LNG_ACCEPT;
       bbButton2.Caption:=LNG_CANCEL;
      end;
  2 : begin
       bbButton0.ModalResult := mrAbort;
       bbButton1.ModalResult := mrRetry;
       bbButton2.ModalResult := mrIgnore;
       bbButton0.Caption:=LNG_ABORT;
       bbButton1.Caption:=LNG_RETRY;
       bbButton2.Caption:=LNG_IGNORE;
      end;
  3 : begin
       bbButton0.ModalResult := mrYes;
       bbButton1.ModalResult := mrNo;
       bbButton2.ModalResult := mrCancel;
       bbButton0.Caption:=LNG_YES;
       bbButton1.Caption:=LNG_NO;
       bbButton2.Caption:=LNG_CANCEL;
      end;
  4 : begin
       bbButton1.ModalResult := mrYes;
       bbButton2.ModalResult := mrNo;
       bbButton1.Caption:=LNG_YES;
       bbButton2.Caption:=LNG_NO;
      end;
  5 : begin
       bbButton1.ModalResult := mrRetry;
       bbButton2.ModalResult := mrCancel;
       bbButton1.Caption:=LNG_RETRY;
       bbButton2.Caption:=LNG_CANCEL;
      end;
 end;
end;

end.