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

unit uFrmInputBox;



interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmInputBox = class(TForm)
    lbText: TLabel;
    edText: TEdit;
    Bevel1: TBevel;
    bbAcept: TBitBtn;
    bbCancel: TBitBtn;
    procedure edTextKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   InputType : LongInt;
  end;

var
  frmInputBox: TfrmInputBox;

 function feInputBox( title, prompt : string; var input : string; itype : Integer ) : Integer;

implementation

 function feInputBox( title, prompt : string; var input : string; itype : Integer ) : Integer;
 begin
  frmInputBox.InputType      := itype;
  frmInputBox.lbText.Caption := prompt;
  frmInputBox.edText.Text    := input;
  frmInputBox.Caption        := title;

  frmInputBox.ShowModal;

  input  := frmInputBox.edText.Text;
  result := frmInputBox.ModalResult;
 end;


{$R *.lfm}

procedure TfrmInputBox.edTextKeyPress(Sender: TObject; var Key: Char);
begin
 case InputType of
  1 :
   case key of
    '0' .. '9', chr(8): begin end;
   else
    key := chr(13);
   end;
 end;
end;

procedure TfrmInputBox.FormCreate(Sender: TObject);
begin
 InputType := 0;
end;

end.