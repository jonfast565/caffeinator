unit AboutUi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    CloseButton: TButton;
    AppNameLabel: TLabel;
    AuthorLabel: TLabel;
    YearLabel: TLabel;
    LicenseLabel: TLabel;
    Logo: TImage;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.FormCreate(Sender: TObject);
var
  pic: TPicture;
  resizedBitmap: TBitmap;
  targetWidth, targetHeight: Integer;
begin
  pic := TPicture.Create;
  resizedBitmap := TBitmap.Create;
  try
    pic.LoadFromResourceName(HINSTANCE, 'CAFFEINATOR_ICON');

    targetWidth := 400;
    targetHeight := 400;
    resizedBitmap.Width := targetWidth;
    resizedBitmap.Height := targetHeight;

    resizedBitmap.Canvas.StretchDraw(Rect(0, 0, targetWidth, targetHeight), pic.Graphic);
    Logo.Picture.Bitmap.Assign(resizedBitmap);
  finally
    pic.Free;
    resizedBitmap.Free;
  end;
end;

procedure TAboutForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

end.
