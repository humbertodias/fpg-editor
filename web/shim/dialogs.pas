unit Dialogs;

{$mode objfpc}

interface

type
  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  TMsgDlgBtn = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore, mbAll,
    mbNoToAll, mbYesToAll, mbHelp, mbClose);
  TMsgDlgButtons = set of TMsgDlgBtn;

function MessageDlg(const aCaption, aMsg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
function LastDialogMessage: string;

implementation

var
  DialogMessage: string;

function MessageDlg(const aCaption, aMsg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
begin
  DialogMessage := aMsg;
  if DialogMessage = '' then
    DialogMessage := aCaption;
  Result := 0;
end;

function LastDialogMessage: string;
begin
  Result := DialogMessage;
end;

end.
