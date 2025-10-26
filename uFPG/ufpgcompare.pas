unit uFPGcompare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls,
  // Mias
  uFPG

  ;

type

  { TfrmFPGCompare }

  TfrmFPGCompare = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    fpg : array[1..2] of TFPG;
  end;

var
  frmFPGCompare: TfrmFPGCompare;

implementation

{$R *.lfm}

{ TfrmFPGCompare }

procedure TfrmFPGCompare.Button1Click(Sender: TObject);
begin
  If OpenDialog1.Execute then
  begin
   Edit1.Text:=OpenDialog1.FileName;
   fpg[1]:= TFpg.Create;
   fpg[1].LoadFromFile(OpenDialog1.FileName,ProgressBar1);
  end;
end;

procedure TfrmFPGCompare.Button2Click(Sender: TObject);
begin
   If OpenDialog1.Execute then
   begin
    Edit2.Text:=OpenDialog1.FileName;
    fpg[2]:= TFpg.Create;
    fpg[2].LoadFromFile(OpenDialog1.FileName,ProgressBar1);
   end;

end;

procedure TfrmFPGCompare.Button3Click(Sender: TObject);
var
  i,j,z : Integer;
  str : String;
begin
   str:='MAGIC';
   Memo1.Lines.Add(str);

   str:=' 1:';
   for i:=0 to 2 do
   begin
      str:=str+IntToHex(integer(fpg[1].Magic[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:=' 2:';
   for i:=0 to 2 do
   begin
      str:=str+IntToHex(integer(fpg[2].Magic[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:='MSDOSend';
   Memo1.Lines.Add(str);

   str:=' 1:';
   for i:=0 to 3 do
   begin
      str:=str+IntToHex(integer(fpg[1].MSDOSEnd[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:=' 2:';
   for i:=0 to 3 do
   begin
      str:=str+IntToHex(integer(fpg[2].MSDOSEnd[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:='Version';
   Memo1.Lines.Add(str);

   str:=' 1:';
   str:=str+IntToHex(integer(fpg[1].Version),2);
   Memo1.Lines.Add(str);

   str:=' 2:';
   str:=str+IntToHex(integer(fpg[2].Version),2);
   Memo1.Lines.Add(str);

   str:='Palette';
   Memo1.Lines.Add(str);

   str:=' 1:';
   for i:=0 to 767 do
   begin
      str:=str+IntToHex(integer(fpg[1].Palette[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:=' 2:';
   for i:=0 to 767 do
   begin
      str:=str+IntToHex(integer(fpg[2].Palette[i]),2);
   end;
   Memo1.Lines.Add(str);

   str:='Gamuts';
   Memo1.Lines.Add(str);

   for i:=0 to 15 do
   begin
      for z:=1 to 2 do
      begin
        str:=' '+IntToStr(z)+','+IntToStr(i)+ ':';
        Memo1.Lines.Add(str);
        memo1.lines.add('   numcolors:'+ IntToHex(integer(fpg[z].Gamuts[i].numcolors),2));
        memo1.lines.add('   mode:'+ IntToHex(integer(fpg[z].Gamuts[i].mode),2));
        memo1.lines.add('   editable:'+ IntToHex(integer(fpg[z].Gamuts[i].editable),2));
        memo1.lines.add('   unused:'+ IntToHex(integer(fpg[z].Gamuts[i].unused),2));

        str:='   colors:';
        for j:=0 to 31 do
        begin
              str:=str+IntToHex(integer(fpg[z].Gamuts[i].colors[j]),2);
              if j<>31 then
                str:=str+',';
        end;
        Memo1.Lines.Add(str);
      end;
   end;



   str:='CODE';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     str:=str+IntToHex(integer(fpg[z].images[1].Code),8);
     Memo1.Lines.Add(str);
   end;

   str:='GRAPHSIZE';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     str:=str+IntToHex(integer(fpg[z].images[1].GraphSize),8);
     Memo1.Lines.Add(str);
   end;

   str:='FNAME';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     for i:=0 to 31 do
     begin
          str:=str+IntToHex(integer(fpg[z].images[1].fname[i]),2);
     end;
     Memo1.Lines.Add(str);
   end;

   str:='FPNAME';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     for i:=0 to 11 do
     begin
          str:=str+IntToHex(integer(fpg[z].images[1].ffpname[i]),2);
     end;
     Memo1.Lines.Add(str);
   end;

   str:='WIDTH';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     str:=str+IntToHex(integer(fpg[z].images[1].WIDTH),8);
     Memo1.Lines.Add(str);
   end;

   str:='HEIGHT';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     str:=str+IntToHex(integer(fpg[z].images[1].HEIGHT),8);
     Memo1.Lines.Add(str);
   end;

   str:='NCPOINTS';
   Memo1.Lines.Add(str);
   for z:=1 to 2 do
   begin
     str:=' '+inttostr(z)+':';
     str:=str+IntToHex(integer(fpg[z].images[1].NCPOINTS),8);
     Memo1.Lines.Add(str);
   end;

end;
(*

Magic: array [0 .. 2] of char; {fpg, f16, c16}
MSDOSEnd: array [0 .. 3] of byte;
Version: byte;
Palette: array [0 .. 767] of byte;
Gamuts: array [0 .. 15] of MAPGamut;

*)

end.

