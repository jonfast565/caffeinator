unit AutoCloseNotifier;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, SysUtils, PopupNotifier, ExtCtrls;

type
  TAutoCloseNotifier = class(TPopupNotifier)
  private
    FCloseTimer: TTimer;
    FAutoCloseTime: integer;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowNotification(const ATitle, AText: string);
    property AutoCloseTime: integer read FAutoCloseTime write FAutoCloseTime;
  end;

var
  DefaultCloseTime: integer = 3000;

implementation

constructor TAutoCloseNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCloseTimer := TTimer.Create(nil);
  FCloseTimer.Enabled := False;
  FCloseTimer.Interval := DefaultCloseTime;
  FCloseTimer.OnTimer := @OnTimer;
  FAutoCloseTime := DefaultCloseTime;
end;

destructor TAutoCloseNotifier.Destroy;
begin
  FCloseTimer.Free;
  inherited Destroy;
end;

procedure TAutoCloseNotifier.ShowNotification(const ATitle, AText: string);
var
  ScreenWidth, ScreenHeight: integer;
  Margin: integer = 10;
  Left: integer = 0;
  Top: integer = 0;
begin
  Title := ATitle;
  Text := AText;

  // Get the screen dimensions
  ScreenWidth := Screen.Width;
  ScreenHeight := Screen.Height;

  // Position the popup in the bottom-right corner
  Left := ScreenWidth - vNotifierForm.Width - Margin;
  Top := ScreenHeight - vNotifierForm.Height - Margin;

  // Set the timer interval to the auto-close time
  FCloseTimer.Interval := FAutoCloseTime;
  FCloseTimer.Enabled := True;

  // show at the right position
  inherited ShowAtPos(Left, Top);
end;

procedure TAutoCloseNotifier.OnTimer(Sender: TObject);
begin
  FCloseTimer.Enabled := False;
  Self.Visible := False;
end;

end.
