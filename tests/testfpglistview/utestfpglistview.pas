unit utestfpglistview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, StdCtrls, uFPGListView, uFPG;

type

  { TForm1 }

  TForm1 = class(TForm)
    FPGListView1: TFPGListView;
    ImageList1: TImageList;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
      if TFpg.test(OpenDialog1.FileName) then
      begin
        FPGListView1.Fpg.LoadFromFile(OpenDialog1.FileName,ProgressBar1);
        FPGListView1.Load_Images(ProgressBar1);
        Label1.Caption:=FPGListView1.Fpg.appName+' '+ FPGListView1.Fpg.appVersion;
      end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FPGListView1.Fpg.appName:='TestFPGListview';
  FPGListView1.Fpg.appVersion:='r00';
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
     FPGListView1.Fpg.source:=SaveDialog1.FileName;
     FPGListView1.Fpg.SaveToFile(ProgressBar1);
  end;

end;

end.

