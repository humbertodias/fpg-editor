program pfpgeditor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Dialogs, ufrmfpgeditor, ufrmView, ufrmFPGImages, ufrmNewFPG,
  ufrmAnimate, ufrmConfig, uFrmExport, ufrmPalette, uinifile, uFrmBpp, uFrmCFG,
  uFrmMainFNT, uFrmAbout, uFrmInputBox, uFrmMessageBox, uFrmFNTView,
  uMAPGraphic, ufrmZipFenix, uLanguage, DefaultTranslator, ulngConverter,
  ulngTranslator, umainmap, uselectcolor, uFPGcompare, usynprghl, ufrmprgeditor,
  ufrmprgoptions, uFrmMain;

{$R *.res}
resourcestring
  LNG_NO_ENOUGH_MEMORY = 'Error, no se encuentran suficientes recursos para iniciar el programa.'
             + ' Salga de uno o más programas si desea ejecutar este programa.';

begin
  Application.Title:='FPG Editor';
  RequireDerivedFormResource := True;
  Application.Initialize;
  try
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmFPGEditor, frmFPGEditor);
  Application.CreateForm(TfrmAnimate, frmAnimate);
  Application.CreateForm(TfrmConfig, frmConfig);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmFPGImages, frmFPGImages);
  Application.CreateForm(TfrmInputBox, frmInputBox);
  Application.CreateForm(TfrmMessageBox, frmMessageBox);
  Application.CreateForm(TfrmNewFPG, frmNewFPG);
  Application.CreateForm(TfrmPalette, frmPalette);
  Application.CreateForm(TfrmView, frmView);
  Application.CreateForm(TfrmMainFNT, frmMainFNT);
  Application.CreateForm(TFrmCFG, FrmCFG);
  Application.CreateForm(TfBPP, fBPP);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.CreateForm(TfrmFNTView, frmFNTView);
  Application.CreateForm(TfrmZipFenix, frmZipFenix);
  Application.CreateForm(TfrmLanguageConverter, frmLanguageConverter);
  Application.CreateForm(TfrmLangTranslator, frmLangTranslator);
  Application.CreateForm(TfrmMapEditor, frmMapEditor);
  Application.CreateForm(TfrmSelectColor, frmSelectColor);
  Application.CreateForm(TfrmFPGCompare, frmFPGCompare);
  Application.CreateForm(TfrmPRGEditor, frmPRGEditor);
  Application.CreateForm(Tfrmprgoptions, frmprgoptions);
    //Application.CreateForm(TfrmSplash, frmSplash);

  except
   showmessage(LNG_NO_ENOUGH_MEMORY);
   Exit;
  end;
  Application.Run;
end.
