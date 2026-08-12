unit ubennugdwords;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, usynprghl;

procedure FillBennuCompletionList(OutList: TStrings; const Prefix: string);
function BennuCompletionInsertValue(const DisplayValue: string): string;

implementation

type
  TBennuDocEntry = record
    Name: string;
    Doc: string;
  end;

const
  BENNU_DOC_SEPARATOR = ' | ';

  BENNU_LOCALS: array[0..23] of string =
  (
    'x',
    'y',
    'z',
    'graph',
    'file',
    'angle',
    'size',
    'size_x',
    'size_y',
    'flags',
    'alpha',
    'blendop',
    'ctype',
    'cnumber',
    'region',
    'resolution',
    'priority',
    'father',
    'son',
    'bigbro',
    'smallbro',
    'id',
    'reserved',
    'frame_percent'
  );

  BENNU_CONSTANTS: array[0..103] of string =
  (
    'true',
    'false',
    'c_screen',
    'c_scroll',
    'c_m7',
    'all_text',
    'all_sound',
    'all_processes',
    's_kill',
    's_wakeup',
    's_sleep',
    's_freeze',
    's_kill_tree',
    's_wakeup_tree',
    's_sleep_tree',
    's_freeze_tree',
    's_kill_next',
    's_wakeup_next',
    's_sleep_next',
    's_freeze_next',
    'b_clear',
    'b_alpha',
    'b_opaque',
    '_esc',
    '_enter',
    '_space',
    '_tab',
    '_backspace',
    '_left',
    '_right',
    '_up',
    '_down',
    '_l_shift',
    '_r_shift',
    '_l_control',
    '_r_control',
    '_l_alt',
    '_r_alt',
    '_f1',
    '_f2',
    '_f3',
    '_f4',
    '_f5',
    '_f6',
    '_f7',
    '_f8',
    '_f9',
    '_f10',
    '_f11',
    '_f12',
    '_a',
    '_b',
    '_c',
    '_d',
    '_e',
    '_f',
    '_g',
    '_h',
    '_i',
    '_j',
    '_k',
    '_l',
    '_m',
    '_n',
    '_o',
    '_p',
    '_q',
    '_r',
    '_s',
    '_t',
    '_u',
    '_v',
    '_w',
    '_x',
    '_y',
    '_z',
    '_0',
    '_1',
    '_2',
    '_3',
    '_4',
    '_5',
    '_6',
    '_7',
    '_8',
    '_9',
    '_c_left',
    '_c_right',
    '_c_up',
    '_c_down',
    'mouse',
    'timer',
    'fps',
    'frame_time',
    'scale_mode',
    'full_screen',
    'focus_status',
    'os_id',
    'argv',
    'argc',
    'text_z',
    'scroll',
    'm7',
    'joy_state'
  );

{$I ubennugddocs.inc}

function BennuCompletionInsertValue(const DisplayValue: string): string;
var
  p: Integer;
begin
  p := Pos(BENNU_DOC_SEPARATOR, DisplayValue);
  if p > 0 then
    Result := Copy(DisplayValue, 1, p - 1)
  else
    Result := DisplayValue;
end;

function ListHasCompletionName(List: TStrings; const AName: string): Boolean;
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
    if SameText(BennuCompletionInsertValue(List[i]), AName) then
      Exit(True);
  Result := False;
end;

procedure AddCompletionItem(OutList: TStrings; const AName, ADoc, Prefix: string);
var
  display: string;
begin
  if (Prefix <> '') and not AnsiStartsText(Prefix, AName) then
    Exit;
  if ListHasCompletionName(OutList, AName) then
    Exit;
  if ADoc <> '' then
    display := AName + BENNU_DOC_SEPARATOR + ADoc
  else
    display := AName;
  OutList.Add(display);
end;

procedure AddMatchingWithDoc(OutList: TStrings; const Words: array of string;
  const FixedDoc, Prefix: string);
var
  i: Integer;
begin
  for i := Low(Words) to High(Words) do
    AddCompletionItem(OutList, Words[i], FixedDoc, Prefix);
end;

procedure FillBennuCompletionList(OutList: TStrings; const Prefix: string);
var
  i: Integer;
begin
  if OutList = nil then
    Exit;
  OutList.BeginUpdate;
  try
    OutList.Clear;
    AddMatchingWithDoc(OutList, PRG_RESERVED_WORDS, 'language keyword', Prefix);
    AddMatchingWithDoc(OutList, BENNU_LOCALS, 'process local', Prefix);
    AddMatchingWithDoc(OutList, BENNU_CONSTANTS, 'constant', Prefix);
    for i := Low(BENNU_FUNCTION_DOCS) to High(BENNU_FUNCTION_DOCS) do
      AddCompletionItem(OutList, BENNU_FUNCTION_DOCS[i].Name,
        BENNU_FUNCTION_DOCS[i].Doc, Prefix);
  finally
    OutList.EndUpdate;
  end;
end;

end.
