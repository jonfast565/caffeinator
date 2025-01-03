unit MouseKeyboardEvents;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  {$IFDEF WINDOWS}
  Windows, LCLIntf,
  {$ELSE}
  LCLIntf, KeyInput,
  {$ENDIF}
  LCLType;

type
  MkEvents = class(TObject)
  private
  public
    class procedure MoveMouse(Distance: integer); static;
    class procedure PressKeyboardKey(KeyChar: char); static;
  end;

type
  TKeyMapping = record
    VKey: word;
    RequiresShift: boolean;
  end;

implementation

function RequiresShift(ch: char): boolean;
begin
  case ch of
    'A'..'Z', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
    '_', '+', '{', '}', '|', ':', '"', '<', '>', '?': Result := True;
    else
      Result := False;
  end;
end;

function CharToVirtualKey(ch: char): TKeyMapping;
begin
  case ch of
    '!': begin
      Result.VKey := Ord('1');
      Result.RequiresShift := True; // Shift + '1' for '!'
    end;
    '@': begin
      Result.VKey := Ord('2');
      Result.RequiresShift := True; // Shift + '2' for '@'
    end;
    '#': begin
      Result.VKey := Ord('3');
      Result.RequiresShift := True; // Shift + '3' for '#'
    end;
    '$': begin
      Result.VKey := Ord('4');
      Result.RequiresShift := True; // Shift + '4' for '$'
    end;
    '%': begin
      Result.VKey := Ord('5');
      Result.RequiresShift := True; // Shift + '5' for '%'
    end;
    '^': begin
      Result.VKey := Ord('6');
      Result.RequiresShift := True; // Shift + '6' for '^'
    end;
    '&': begin
      Result.VKey := Ord('7');
      Result.RequiresShift := True; // Shift + '7' for '&'
    end;
    '*': begin
      Result.VKey := Ord('8');
      Result.RequiresShift := True; // Shift + '8' for '*'
    end;
    '(': begin
      Result.VKey := Ord('9');
      Result.RequiresShift := True; // Shift + '9' for '('
    end;
    ')': begin
      Result.VKey := Ord('0');
      Result.RequiresShift := True; // Shift + '0' for ')'
    end;
    '-': begin
      Result.VKey := VK_OEM_MINUS;
      Result.RequiresShift := False; // Minus key
    end;
    '_': begin
      Result.VKey := VK_OEM_MINUS;
      Result.RequiresShift := True; // Shift + Minus for '_'
    end;
    '=': begin
      Result.VKey := VK_OEM_PLUS;
      Result.RequiresShift := False; // Equals key
    end;
    '+': begin
      Result.VKey := VK_OEM_PLUS;
      Result.RequiresShift := True; // Shift + Equals for '+'
    end;
    '`': begin
      Result.VKey := VK_OEM_3;
      Result.RequiresShift := False; // Grave accent
    end;
    '~': begin
      Result.VKey := VK_OEM_3;
      Result.RequiresShift := True; // Shift + Grave accent for '~'
    end;
    '[': begin
      Result.VKey := VK_OEM_4;
      Result.RequiresShift := False; // Open bracket
    end;
    '{': begin
      Result.VKey := VK_OEM_4;
      Result.RequiresShift := True; // Shift + Open bracket for '{'
    end;
    ']': begin
      Result.VKey := VK_OEM_6;
      Result.RequiresShift := False; // Close bracket
    end;
    '}': begin
      Result.VKey := VK_OEM_6;
      Result.RequiresShift := True; // Shift + Close bracket for '}'
    end;
    '\': begin
      Result.VKey := VK_OEM_5;
      Result.RequiresShift := False; // Backslash
    end;
    '|': begin
      Result.VKey := VK_OEM_5;
      Result.RequiresShift := True; // Shift + Backslash for '|'
    end;
    ';': begin
      Result.VKey := VK_OEM_1;
      Result.RequiresShift := False; // Semicolon
    end;
    ':': begin
      Result.VKey := VK_OEM_1;
      Result.RequiresShift := True; // Shift + Semicolon for ':'
    end;
    '''': begin
      Result.VKey := VK_OEM_7;
      Result.RequiresShift := False; // Single quote
    end;
    '"': begin
      Result.VKey := VK_OEM_7;
      Result.RequiresShift := True; // Shift + Single quote for '"'
    end;
    ',': begin
      Result.VKey := VK_OEM_COMMA;
      Result.RequiresShift := False; // Comma
    end;
    '<': begin
      Result.VKey := VK_OEM_COMMA;
      Result.RequiresShift := True; // Shift + Comma for '<'
    end;
    '.': begin
      Result.VKey := VK_OEM_PERIOD;
      Result.RequiresShift := False; // Period
    end;
    '>': begin
      Result.VKey := VK_OEM_PERIOD;
      Result.RequiresShift := True; // Shift + Period for '>'
    end;
    '/': begin
      Result.VKey := VK_OEM_2;
      Result.RequiresShift := False; // Slash
    end;
    '?': begin
      Result.VKey := VK_OEM_2;
      Result.RequiresShift := True; // Shift + Slash for '?'
    end;
    else
    begin
      Result.VKey := 0;
      Result.RequiresShift := False; // Unsupported character
    end;
  end;
end;

{$IFDEF WINDOWS}
procedure PlatformSendKey(VKey: word; KeyDown, Shift: boolean);
var
  Input: TInput;
begin
  if Shift and KeyDown then
  begin
    ZeroMemory(@Input, SizeOf(Input));
    Input._Type := INPUT_KEYBOARD;
    Input.ki.wVk := VK_SHIFT;
    SendInput(1, @Input, SizeOf(TInput));
  end;

  ZeroMemory(@Input, SizeOf(Input));
  Input._Type := INPUT_KEYBOARD;
  Input.ki.wVk := VKey;
  if not KeyDown then
    Input.ki.dwFlags := KEYEVENTF_KEYUP;
  SendInput(1, @Input, SizeOf(TInput));

  if Shift and not KeyDown then
  begin
    ZeroMemory(@Input, SizeOf(Input));
    Input._Type := INPUT_KEYBOARD;
    Input.ki.wVk := VK_SHIFT;
    Input.ki.dwFlags := KEYEVENTF_KEYUP;
    SendInput(1, @Input, SizeOf(TInput));
  end;
end;

procedure PlatformMoveMouse(Distance: integer);
var
  Mouse: TPoint;
begin
  Mouse := TPoint.Create(0, 0);
  GetCursorPos(Mouse);
  SetCursorPos(Mouse.X - Distance, Mouse.Y);
  Sleep(50);
  SetCursorPos(Mouse.X + Distance, Mouse.Y);
end;
{$ELSE}

procedure PlatformSendKey(VKey: word; KeyDown, Shift: boolean);
begin
  if Shift and KeyDown then
    KeyInput.PressKey(VK_SHIFT);

  if KeyDown then
    KeyInput.PressKey(VKey)
  else
    KeyInput.ReleaseKey(VKey);

  if Shift and not KeyDown then
    KeyInput.ReleaseKey(VK_SHIFT);
end;

procedure PlatformMoveMouse(Distance: integer);
var
  Mouse: TPoint;
begin
  Mouse := Mouse.CursorPos;
  Mouse.CursorPos := Point(Mouse.X - Distance, Mouse.Y);
  Sleep(50);
  Mouse.CursorPos := Point(Mouse.X + Distance, Mouse.Y);
end;
{$ENDIF}

class procedure MkEvents.MoveMouse(Distance: integer);
begin
  PlatformMoveMouse(Distance);
end;

class procedure MkEvents.PressKeyboardKey(KeyChar: char);
var
  KeyCode: TKeyMapping;
begin
  KeyCode := CharToVirtualKey(KeyChar);
  if KeyCode.VKey = 0 then
  begin
    Sleep(50);
  end
  else
  begin
    PlatformSendKey(KeyCode.VKey, True, KeyCode.RequiresShift);
    Sleep(10);
    PlatformSendKey(KeyCode.VKey, False, KeyCode.RequiresShift);
  end;
end;

end.
