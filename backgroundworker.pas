unit BackgroundWorker;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, MouseKeyboardEvents;

type
  TBackgroundWorker = class(TThread)
  private
    FOnOffSwitch: boolean;
    FKeyChar: char;
    FPressKey: boolean;
    FMoveMouse: boolean;
    FMouseDistance: integer;
    FKeyPressFrequency: integer;
    FMouseMoveFrequency: integer;
    FLock: TRTLCriticalSection;
    procedure SetOnOffSwitch(Value: boolean);
    procedure SetKeyChar(Value: char);
    procedure SetPressKey(Value: boolean);
    procedure SetMoveMouse(Value: boolean);
    procedure SetMouseDistance(Value: integer);
    procedure SetKeyPressFrequency(Value: integer);
    procedure SetMouseMoveFrequency(Value: integer);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdateConfig(KeyChar: char; PressKey, MoveMouse: boolean;
      MouseDistance, KeyPressFrequency, MouseMoveFrequency: integer);
    property OnOffSwitch: boolean read FOnOffSwitch write SetOnOffSwitch;
    property KeyChar: char read FKeyChar write SetKeyChar;
    property PressKey: boolean read FPressKey write SetPressKey;
    property MoveMouse: boolean read FMoveMouse write SetMoveMouse;
    property MouseDistance: integer read FMouseDistance write SetMouseDistance;
    property KeyPressFrequency: integer read FKeyPressFrequency
      write SetKeyPressFrequency;
    property MouseMoveFrequency: integer read FMouseMoveFrequency
      write SetMouseMoveFrequency;
  end;

implementation

constructor TBackgroundWorker.Create;
begin
  inherited Create(True); // Create suspended
  FKeyChar := 'A';
  FPressKey := False;
  FMoveMouse := False;
  FMouseDistance := 10;
  FKeyPressFrequency := 1000;
  FMouseMoveFrequency := 1000;
  InitCriticalSection(FLock);
  FreeOnTerminate := False; // Do not automatically free thread when done
end;

destructor TBackgroundWorker.Destroy;
begin
  DoneCriticalSection(FLock);
  inherited Destroy;
end;

procedure TBackgroundWorker.SetOnOffSwitch(Value: boolean);
begin
  EnterCriticalSection(FLock);
  try
    FOnOffSwitch := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetKeyChar(Value: char);
begin
  EnterCriticalSection(FLock);
  try
    FKeyChar := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetPressKey(Value: boolean);
begin
  EnterCriticalSection(FLock);
  try
    FPressKey := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetMoveMouse(Value: boolean);
begin
  EnterCriticalSection(FLock);
  try
    FMoveMouse := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetMouseDistance(Value: integer);
begin
  EnterCriticalSection(FLock);
  try
    FMouseDistance := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetKeyPressFrequency(Value: integer);
begin
  EnterCriticalSection(FLock);
  try
    FKeyPressFrequency := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.SetMouseMoveFrequency(Value: integer);
begin
  EnterCriticalSection(FLock);
  try
    FMouseMoveFrequency := Value;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TBackgroundWorker.UpdateConfig(KeyChar: char; PressKey, MoveMouse: boolean;
  MouseDistance, KeyPressFrequency, MouseMoveFrequency: integer);
begin
  EnterCriticalSection(FLock);
  try
    FKeyChar := KeyChar;
    FPressKey := PressKey;
    FMoveMouse := MoveMouse;
    FMouseDistance := MouseDistance;
    FKeyPressFrequency := KeyPressFrequency;
    FMouseMoveFrequency := MouseMoveFrequency;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

function MilliSecondsBetweenDates(ATime1, ATime2: TDateTime): int64;
begin
  Result := Round((ATime2 - ATime1) * 24 * 60 * 60 * 1000);
end;

procedure TBackgroundWorker.Execute;
var
  LocalKeyChar: char;
  LocalPressKey, LocalMoveMouse: boolean;
  LocalMouseDistance, LocalKeyPressFrequency, LocalMouseMoveFrequency: integer;
  DateNow, LastKeyPressTime, LastMouseMoveTime: TDateTime;
  LastKeyPressTimeDiff, LastMouseMoveTimeDiff: integer;
begin
  LastKeyPressTime := Now;
  LastMouseMoveTime := Now;

  while not Terminated do
  begin
    if FOnOffSwitch then
    begin
      EnterCriticalSection(FLock);
      try
        LocalKeyChar := FKeyChar;
        LocalPressKey := FPressKey;
        LocalMoveMouse := FMoveMouse;
        LocalMouseDistance := FMouseDistance;
        LocalKeyPressFrequency := FKeyPressFrequency;
        LocalMouseMoveFrequency := FMouseMoveFrequency;
      finally
        LeaveCriticalSection(FLock);
      end;

      DateNow := Now;
      LastKeyPressTimeDiff := MilliSecondsBetweenDates(LastKeyPressTime, DateNow);
      if LocalPressKey and (LastKeyPressTimeDiff >= LocalKeyPressFrequency) then
      begin
        MkEvents.PressKeyboardKey(LocalKeyChar);
        LastKeyPressTime := DateNow;
      end;

      LastMouseMoveTimeDiff := MilliSecondsBetweenDates(LastMouseMoveTime, DateNow);
      if LocalMoveMouse and (LastMouseMoveTimeDiff >= LocalMouseMoveFrequency) then
      begin
        MkEvents.MoveMouse(LocalMouseDistance);
        LastMouseMoveTime := DateNow;
      end;

      // Wait a short time to prevent high CPU usage
      Sleep(10);
    end
    else
      Sleep(10);
  end;
end;

end.
