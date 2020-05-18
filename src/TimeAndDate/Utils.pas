unit Utils;

interface

uses
  System.Types;

type

  IStrArrayIterator = interface
    ['{BDDEE013-5FD0-4049-8F96-23F3FAA2F175}']
    function Next(var Line: string): Boolean;
  end;

function BuildStrArrayIteratorNonEmptyLines(Arr: TStringDynArray): IStrArrayIterator;
procedure SaveStrToFile(const FilePath, Content: string);

implementation

uses
  System.SysUtils, System.Classes;

procedure SaveStrToFile(const FilePath, Content: string);
var
  ss: TStringStream;
begin
  ss := TStringStream.Create;
  try
    ss.WriteString(Content);
    ss.SaveToFile(FilePath);
  finally
    ss.Free;
  end;
end;

{ TStrArrayIterator }

type

  TStrArrayIteratorNonEmptyLines = class(TInterfacedObject, IStrArrayIterator)
  private
    FArr: TStringDynArray;
    Idx: Integer;
  public
    constructor Create(Arr: TStringDynArray);
    function Next(var Line: string): Boolean;
  end;

constructor TStrArrayIteratorNonEmptyLines.Create(Arr: TStringDynArray);
begin
  inherited Create;
  FArr := Arr;
  Idx := 0;
end;

function TStrArrayIteratorNonEmptyLines.Next(var Line: string): Boolean;
begin
  while Idx < Length(FArr) do begin
    Line := Trim(FArr[Idx]);
    Inc(Idx);
    if Line.Length > 0 then
      Exit(True);
  end;
  Result := Idx < Length(FArr);
end;

function BuildStrArrayIteratorNonEmptyLines(Arr: TStringDynArray): IStrArrayIterator;
begin
  Result := TStrArrayIteratorNonEmptyLines.Create(Arr);
end;

end.
