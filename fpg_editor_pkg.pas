{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit fpg_editor_pkg;

interface

uses
  uFPGListView, uFPG, uMAPGraphic, uLoadImage, uTools, usynprghl, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uFPGListView', @uFPGListView.Register);
  RegisterUnit('usynprghl', @usynprghl.Register);
end;

initialization
  RegisterPackage('fpg_editor_pkg', @Register);
end.
