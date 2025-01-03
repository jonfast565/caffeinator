program caffeinator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  AutoCloseNotifier,
  SettingsUi,
  AboutUi;

  {$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
