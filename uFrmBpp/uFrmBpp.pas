unit ufrmbpp;


interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type

  { TfBPP }

  TfBPP = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    cbBpp: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fBPP: TfBPP;

implementation

{$R *.lfm}

{ TfBPP }



end.
