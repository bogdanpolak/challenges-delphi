unit Code02.DaylightTimeZone;

interface

uses
  System.Generics.Collections;
{
@theme: Delphi Challenge
@subject: #02 Daylight Time Zone
@author: Bogdan Polak
@date: 2020-05-16 21:00
}

{
  Zadaniem jest wydobycie z treści strony https://www.timeanddate.com/
  informacji o tym czy w podanej strefie czasowej wykonuje się przesuniecie
  czasu podstawowego (zimowego) na czas letni. Daylight Saving Time

  Funkcja:
    * IsDaylightSaving - powinna sprawdzić to dla podanego roku (year) i dla podanego obszaru (area).
  Jeśli przesuniecie czasu jest aktywne to funkcje:
    * GetDaylightStart
    * GetDaylightEnd
  powinny zwrócić informacje w jakim dniu i o jakiej godzinie następuje przesuniecie czasu.

  Dla przykładu przy danych:
    - area: poland/warsaw
    - year: 2015
  Powinna zostać wywołana strona:
    https://www.timeanddate.com/time/change/poland/warsaw?year=2015
  i na podstawie analizy treści strony WWW należy zwrócić podane wyżej wyniki

  Aby nie powtarzać wielokrotnego pobierania danych dla tych samych stron
  należy przechować poprzednie wyniki, aby nie pobierać wielokrotnie tych
  samych danych.

  Uwaga!

  Wymagane jest użycie `TMyHttpGet.GetWebsiteContent` do pobrania zawartości strony
  Przykład wywołania:
    aHtmlPageContent := TMyHttpGet.GetWebsiteContent(‘http://delphi.pl/’);
}


type
  TTimeAreaPoint = type string;

  TTimeAreaPointHelper = record helper for TTimeAreaPoint
  protected
    function GetYear(): Word;
    procedure SetYear(const aValue: Word);
    function GetArea(): string;
    procedure SetArea(const aValue: string);
  public
    property Area: string read GetArea write SetArea;
    property Year: Word read GetYear write SetYear;
  end;

  TDayligtSavingPeriod = record
    StartPeriod : TDateTime;
    EndPeriod : TDateTime;
  end;

  TDaylightSavingMatrix = record
  private
    const cReg = 'mgt0.*?reach<br>(.*?)[^0-9]*<strong>(.*?)</strong>';
    const cNotDST  = 'Daylight Saving Time (DST) Not Observed in Year ';
    const cURL = 'https://www.timeanddate.com/time/change/%s?year=%d';
    class var cfDLSMatrix : TDictionary<TTimeAreaPoint, TDayligtSavingPeriod>;
    class function ImportPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod; static;
  public
    class function GetPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod; static;
    class constructor Create();
    class destructor Destroy();
  end;

function IsDaylightSaving(const area: string; year: Word): boolean;
function GetDaylightStart(const area: string; year: Word): TDateTime;
function GetDaylightEnd(const area: string; year: Word): TDateTime;

implementation

uses
  Code02.HttpGet,

  System.RegularExpressions,
  System.SysUtils;

function IsDaylightSaving(const area: string; year: Word): boolean;
var
  lPeriod: TDayligtSavingPeriod;
begin
  lPeriod := TDaylightSavingMatrix.GetPeriod(area, year);
  Result := (lPeriod.StartPeriod > 0) and (lPeriod.EndPeriod > 0);
end;

function GetDaylightStart(const area: string; year: Word): TDateTime;
begin
  Result := 0;
end;

function GetDaylightEnd(const area: string; year: Word): TDateTime;
begin
  Result := 0;
end;

function TTimeAreaPointHelper.GetArea(): string;
begin
  if Length(Self) < 1 then
  begin
    Result := '';
  end else
  begin
    Result := Copy(Self, 2);
  end;
end;

function TTimeAreaPointHelper.GetYear(): Word;
begin
  if Length(self) = 0 then
  begin
    Result := 0;
  end else
  begin
    Result := Word(Self[1]);
  end;
end;

procedure TTimeAreaPointHelper.SetArea(const aValue: string);
begin
  if Length(Self) = 0 then
  begin
    Self := #0 + aValue;
  end else
  begin
    Self := Self[1] + aValue;
  end;
end;

procedure TTimeAreaPointHelper.SetYear(const aValue: Word);
begin
  if Length(Self) = 0 then
  begin
    SetLength(Self, 1);
  end;
  Self[1] := Char(aValue);
end;

class constructor TDaylightSavingMatrix.Create();
begin
  cfDLSMatrix := TDictionary<TTimeAreaPoint, TDayligtSavingPeriod>.Create();
end;

class destructor TDaylightSavingMatrix.Destroy();
begin
  cfDLSMatrix.Free;
end;

class function TDaylightSavingMatrix.GetPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod;
var
  lPoint : TTimeAreaPoint;
begin
  lPoint.Area := aArea;
  lPoint.Year := aYear;
  if cfDLSMatrix.TryGetValue(lPoint, Result) then
  begin
    Exit;
  end;
  Result := ImportPeriod(aArea, aYear);
  cfDLSMatrix.Add(lPoint, Result);
end;

class function TDaylightSavingMatrix.ImportPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod;
var
  lArea: string;
  lBody: string;
  lMatches: TMatchCollection;
  lRegex: TRegEx;
  lURL : string;
begin
  lArea := aArea.ToLower;
  lURL := Format(cURL, [lArea, aYear]);
  lBody := TMyHttpGet.GetWebsiteContent(lURL);
  if Pos(cNotDST, lBody) > 0 then
  begin
    Result.StartPeriod := 0;
    Result.EndPeriod := 0;
  end else
  begin
    lMatches := TRegEx.Matches(lBody, cReg, [roIgnoreCase, roMultiLine]);
    Result.StartPeriod := 0;
    Result.EndPeriod := 0;
  end;
end;

end.
