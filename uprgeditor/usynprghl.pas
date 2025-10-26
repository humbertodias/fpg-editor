unit usynprghl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEditTypes, SynEditHighlighter, SynEditStrConst;

type

  { TSynPrgHl }


  TSynPrgHl = class(TSynCustomHighlighter)
  private
    FTokenPos, FTokenEnd: Integer;
    FLineText: String;
    fCommentAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
  public
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    constructor Create(AOwner: TComponent); override;

  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri
      write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri
      write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri
      write fKeyAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri
      write fStringAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri
      write fSpaceAttri;

  end;

const
  PRG_RESERVED_WORDS : array[1..55] of string =
    ('array',
    'begin',
    'break',
    'byte' ,
    'call' ,
    'case' ,
    'clone',
    'const',
    'continue',
    'debug' ,
    'declare',
    'default',
    'dup'    ,
    'elif'   ,
    'else'   ,
    'elseif' ,
    'elsif'  ,
    'end'    ,
    'float'   ,
    'for'    ,
    'frame'  ,
    'from'   ,
    'function',
    'global' ,
    'goto'   ,
    'if'     ,
    'import' ,
    'include',
    'int'    ,
    'jmp'    ,
    'local'  ,
    'loop'   ,
    'offset' ,
    'onExit' ,
    'pointer',
    'private',
    'process',
    'program',
    'public' ,
    'repeat' ,
    'return' ,
    'short'  ,
    'sizeof' ,
    'step'   ,
    'string' ,
    'struct' ,
    'switch' ,
    'to'     ,
    'type'   ,
    'until'  ,
    'varspace',
    'void',
    'while',
    'word',
    'yield');


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FPG Editor', [TSynPrgHl]);
end;

constructor TSynPrgHl.Create(AOwner: TComponent);
var
  i :Integer;
begin
  inherited Create(AOwner);


  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment, SYNS_XML_AttrComment);
  fCommentAttri.Style:= [fsItalic];
  fCommentAttri.Foreground:=clGray;
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier, SYNS_XML_AttrIdentifier);
  fIdentifierAttri.Foreground:=clBlack;
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrKey, SYNS_XML_AttrKey);
  fKeyAttri.Foreground:=clRed;
  AddAttribute(fKeyAttri);

  fStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString, SYNS_XML_AttrString);
  fStringAttri.Foreground:=clBlue;
  AddAttribute(fStringAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace, SYNS_XML_AttrSpace);
  fIdentifierAttri.Foreground:=clBlack;
  AddAttribute(fSpaceAttri);

end;


procedure TSynPrgHl.SetLine(const NewValue: String; LineNumber: Integer);
begin
  inherited;
  FLineText := NewValue;
  FTokenEnd := 1;
  Next;
end;

procedure TSynPrgHl.Next;
var
  l: Integer;
begin
  FTokenPos := FTokenEnd;

  l := length(FLineText);

  If FTokenPos > l then
    exit;

  if FLineText[FTokenEnd] in ['/'] then
   if FLineText[FTokenEnd+1] in ['/'] then
    while (FTokenEnd <= l ) do
    begin
          inc (FTokenEnd);
    end;

  if FLineText[FTokenEnd] in [#9,' '] then
    while (FTokenEnd+1 <= l ) do
    begin
          inc (FTokenEnd);
          if not (FLineText[FTokenEnd] in [#9,' ']) then
             exit;
    end;

  If FTokenEnd > l then
    exit;

  if FLineText[FTokenEnd] in ['"'] then
    while (FTokenEnd+1 <= l ) do
    begin
          inc (FTokenEnd);
          if (FLineText[FTokenEnd] in ['"']) then
          begin
             inc (FTokenEnd);
             exit;
          end;
    end;

  If FTokenEnd > l then
     exit;

  while (FTokenEnd+1 <= l ) do
  begin
        inc (FTokenEnd);
        if (FLineText[FTokenEnd] in [#9,' ','"',';']) then
           exit;
  end;
  inc (FTokenEnd);

end;

function TSynPrgHl.GetEol: Boolean;
begin
  Result := FTokenPos > length(FLineText);
end;

procedure TSynPrgHl.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenStart := @FLineText[FTokenPos];
  TokenLength := FTokenEnd - FTokenPos;
end;

function TSynPrgHl.GetTokenAttribute: TSynHighlighterAttributes;
var
  i: Integer;
begin
  // Match the text, specified by FTokenPos and FTokenEnd
  Result := fIdentifierAttri;

  if (GetToken[1] ='/') and (GetToken[2] ='/') then
  begin
    Result := fCommentAttri;
    exit;
  end;

  if GetToken[1] ='"' then
  begin
    Result := fStringAttri;
    exit;
  end;

  if (GetToken[1] in [#9,' ']) then
  begin
    Result := fSpaceAttri;
    exit;
  end;

  for i:=1 to length(PRG_RESERVED_WORDS) do
    if LowerCase(GetToken) = PRG_RESERVED_WORDS[i] then
    begin
      Result := fKeyAttri;
      break;
    end;

end;

function TSynPrgHl.GetToken: String;
begin
  Result := copy(FLineText, FTokenPos, FTokenEnd - FTokenPos);
end;

function TSynPrgHl.GetTokenPos: Integer;
begin
  Result := FTokenPos - 1;
end;

function TSynPrgHl.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    else Result := nil;
  end;
end;

function TSynPrgHl.GetTokenKind: integer;
var
  a: TSynHighlighterAttributes;
begin
  // Map Attribute into a unique number
  a := GetTokenAttribute;
  Result := 0;
  if a = fKeyAttri then Result := 1;
  if a = fSpaceAttri then Result := 2;
end;


end.

