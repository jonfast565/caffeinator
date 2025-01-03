unit SettingsUi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  PopupNotifier, ExtCtrls, Spin, AboutUi,
  {$ifdef WINDOWS} Windows, {$endif} BackgroundWorker, AutoCloseNotifier;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    KeyboardKey: TEdit;
    AboutItem: TMenuItem;
    StartMenuItem: TMenuItem;
    StopMenuItem: TMenuItem;
    MoveMouseCheckbox: TCheckBox;
    KeyboardKeyCheckbox: TCheckBox;
    MoveMouseMsLabel: TLabel;
    KeyboardKeyPressMsLabel: TLabel;
    ShowMenuItem: TMenuItem;
    MouseMoveFrequency: TSpinEdit;
    KeyboardKeyPressFrequency: TSpinEdit;
    MouseMovePixels: TSpinEdit;
    TrayMenu: TPopupMenu;
    StartButton: TButton;
    StopButton: TButton;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitItem: TMenuItem;
    TrayIcon: TTrayIcon;
    PopupNotifier: TAutoCloseNotifier;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure InitForms;
    procedure InitPopupNotifier;
    procedure InitControls;
    procedure InitBackgroundWorker;
    procedure InitTrayIcon;
    procedure AboutItemClick(Sender: TObject);
    procedure StartCaffeination;
    procedure StopCaffeination;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure KeyboardKeyChange(Sender: TObject);
    procedure StartMenuItemClick(Sender: TObject);
    procedure StopMenuItemClick(Sender: TObject);
    procedure MouseMovePixelsChange(Sender: TObject);
    procedure MoveMouseCheckboxChange(Sender: TObject);
    procedure MoveMouseMsChange(Sender: TObject);
    procedure KeyboardKeyCheckboxChange(Sender: TObject);
    procedure ShowMenuItemClick(Sender: TObject);
    procedure KeyboardKeyPressFrequencyChange(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private
    Worker: TBackgroundWorker;
  public

  end;

var
  SettingsForm: TSettingsForm;
  AboutForm: TAboutForm;

implementation

{$R *.lfm}

{ TSettingsForm }

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  InitForms;
  InitPopupNotifier;
  InitControls;
  InitBackgroundWorker;
  StartCaffeination;
  {$ifdef WINDOWS}
  InitTrayIcon;
  {$endif}
end;

procedure TSettingsForm.InitForms;
begin
  AboutForm := TAboutForm.Create(Self);
end;

procedure TSettingsForm.InitControls;
begin
  MoveMouseCheckbox.Enabled := True;
  MoveMouseCheckbox.Checked := True;
  KeyboardKeyCheckbox.Enabled := True;
  KeyboardKeyCheckbox.Checked := False;
  MouseMoveFrequency.Value := 1000;
  KeyboardKeyPressFrequency.Value := 1000;
  KeyboardKey.Text := '~';
  MouseMovePixels.Value := 1;
end;

procedure TSettingsForm.InitPopupNotifier;
begin
  PopupNotifier := TAutoCloseNotifier.Create(Self);
  PopupNotifier.AutoCloseTime := 3000;
  PopupNotifier.Title := 'Caffeinator';
end;

procedure TSettingsForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if MessageDlg('Confirm',
    'Do you want to close the app? (Click no to keep running in tray).',
    mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  begin
    CanClose := False;
    SettingsForm.Hide;
  end
  else
    CanClose := True;
end;

procedure TSettingsForm.InitBackgroundWorker;
begin
  Worker := TBackgroundWorker.Create;
  Worker.KeyChar := KeyboardKey.Text[1];
  Worker.PressKey := KeyboardKeyCheckbox.Checked;
  Worker.MoveMouse := MoveMouseCheckbox.Checked;
  Worker.MouseDistance := MouseMovePixels.Value;
  Worker.KeyPressFrequency := KeyboardKeyPressFrequency.Value;
  Worker.MouseMoveFrequency := MouseMoveFrequency.Value;
  Worker.OnOffSwitch := False;
  Worker.Start;
end;

{$ifdef WINDOWS}
procedure TSettingsForm.InitTrayIcon;
var
  tmpIcon: TIcon;
  tmpSize: TSize;
begin
  tmpIcon := TIcon.Create;
  tmpIcon.LoadFromResourceName(HINSTANCE, 'MAINICON');
  tmpSize.cx := TrayIcon.Canvas.Width;
  tmpSize.cy := TrayIcon.Canvas.Height;
  tmpIcon.Current := tmpIcon.GetBestIndexForSize(tmpsize);
  TrayIcon.Icon.Transparent := True;
  TrayIcon.Icon.Assign(tmpIcon);
  tmpIcon.Free;
  TrayIcon.Show;
end;

procedure TSettingsForm.AboutItemClick(Sender: TObject);
begin
     AboutForm.ShowModal;
end;

{$endif}

procedure TSettingsForm.StartCaffeination;
begin
  if not Assigned(Worker) then
    Exit;

  Worker.OnOffSwitch := True;
  PopupNotifier.ShowNotification('Caffeinator', 'Caffeination started.');

  StartButton.Enabled := False;
  StopButton.Enabled := True;

  StartMenuItem.Enabled := False;
  StopMenuItem.Enabled := True;
end;

procedure TSettingsForm.StopCaffeination;
begin
  if Assigned(Worker) then
    Worker.Terminate;

  Worker.OnOffSwitch := False;
  PopupNotifier.ShowNotification('Caffeinator', 'Caffeination stopped.');

  StartButton.Enabled := True;
  StopButton.Enabled := False;

  StartMenuItem.Enabled := True;
  StopMenuItem.Enabled := False;
end;

procedure TSettingsForm.StartButtonClick(Sender: TObject);
begin
  StartCaffeination;
end;


procedure TSettingsForm.StopButtonClick(Sender: TObject);
begin
  StopCaffeination;
end;


procedure TSettingsForm.KeyboardKeyPressFrequencyChange(Sender: TObject);
begin
  if Assigned(Worker) then
    Worker.KeyPressFrequency := KeyboardKeyPressFrequency.Value;
end;


procedure TSettingsForm.MoveMouseCheckboxChange(Sender: TObject);
begin
  if Assigned(Worker) then
    Worker.MoveMouse := MoveMouseCheckbox.Checked;
end;

procedure TSettingsForm.MoveMouseMsChange(Sender: TObject);
begin
  if Assigned(Worker) then
    Worker.MouseMoveFrequency := MouseMoveFrequency.Value;
end;

procedure TSettingsForm.MouseMovePixelsChange(Sender: TObject);
begin
  if Assigned(Worker) then
    Worker.MouseDistance := MouseMovePixels.Value;
end;

procedure TSettingsForm.KeyboardKeyChange(Sender: TObject);
begin
  if Assigned(Worker) and (KeyboardKey.Text <> '') then
    Worker.KeyChar := KeyboardKey.Text[1];
end;

procedure TSettingsForm.StartMenuItemClick(Sender: TObject);
begin
  StartCaffeination;
end;

procedure TSettingsForm.StopMenuItemClick(Sender: TObject);
begin
  StopCaffeination;
end;

procedure TSettingsForm.KeyboardKeyCheckboxChange(Sender: TObject);
begin
  if Assigned(Worker) then
    Worker.PressKey := KeyboardKeyCheckbox.Checked;
end;

procedure TSettingsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(Worker) then
  begin
    Worker.Terminate;
    Worker.WaitFor;
    FreeAndNil(Worker);
  end;
end;

procedure TSettingsForm.ExitItemClick(Sender: TObject);
begin
  SettingsForm.Close;
end;

procedure TSettingsForm.ShowMenuItemClick(Sender: TObject);
begin
  SettingsForm.Show;
end;

procedure TSettingsForm.TrayIconClick(Sender: TObject);
begin
  TrayMenu.PopUp;
end;

end.
