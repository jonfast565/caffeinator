unit Utilities;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms, ExtCtrls;

procedure LoadImageFromResource(ImageControl: TImage; const ResourceName: string);

implementation

procedure LoadImageFromResource(ImageControl: TImage; const ResourceName: string);
var
  ResourceStream: TResourceStream;
begin
  if FindResource(HInstance, PChar(ResourceName), 'RT_RCDATA') = 0 then
  begin
    raise Exception.CreateFmt('Resource "%s" not found.', [ResourceName]);
  end;

  ResourceStream := TResourceStream.Create(HInstance, ResourceName, 'RCDATA');
  try
    ImageControl.Picture.LoadFromStream(ResourceStream);
  finally
    ResourceStream.Free;
  end;
end;
end.

