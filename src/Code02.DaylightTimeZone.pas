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
    const cMonthNames : array of string = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'];
    const cReg = 'mgt0.*?reach<br>.*?([0-9]+[^0-9]*?[0-9]+).*?<strong>(.*?)</strong>';
    const cNotDST  = 'Daylight Saving Time (DST) Not Observed in Year ';
    const cURL = 'https://www.timeanddate.com/time/change/%s?year=%d';
    class var cfDLSMatrix : TDictionary<TTimeAreaPoint, TDayligtSavingPeriod>;
    class function ConvertDateTime(const aDate, aTime : string): TDateTime; static;
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
  System.StrUtils,
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
  Result := TDaylightSavingMatrix.GetPeriod(area, year).StartPeriod;
end;

function GetDaylightEnd(const area: string; year: Word): TDateTime;
begin
  Result := TDaylightSavingMatrix.GetPeriod(area, year).EndPeriod;
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

class function TDaylightSavingMatrix.ConvertDateTime(const aDate, aTime : string): TDateTime;
var
  i: Integer;
  lDateItems: TArray<string>;
  lDayNumber: Integer;
  lMonthName: string;
  lMonthNumber: Integer;
  lName: string;
  lYearNumber: Integer;
begin
  // 7 November 2021
  // 03:00:00
  lDateItems := SplitString(aDate.ToLower, ' ');
  lDayNumber := StrToInt(lDateItems[0]);
  lYearNumber := StrToInt(lDateItems[2]);
  lMonthName := lDateItems[1];
  lMonthNumber := 0;
  for i := 0 to 11 do
  begin
    lName :=  cMonthNames[i];
    if SameText(lName, lMonthName) then
    begin
      lMonthNumber := i + 1;
      Break;
    end;
  end;
  if lMonthNumber = 0 then
  begin
    raise Exception.CreateFmt('Bad input data: %s - %s', [aDate, aTime]);
  end;
  Result := EncodeDate(lYearNumber, lMonthNumber, lDayNumber) + StrToTime(aTime);
end;

class function TDaylightSavingMatrix.GetPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod;
var
  lArea: string;
  lPoint : TTimeAreaPoint;
begin
  lArea  := aArea.ToLower;
  lPoint.Area := lArea;
  lPoint.Year := aYear;
  if cfDLSMatrix.TryGetValue(lPoint, Result) then
  begin
    Exit;
  end;
  Result := ImportPeriod(lArea, aYear);
  cfDLSMatrix.Add(lPoint, Result);
end;

class function TDaylightSavingMatrix.ImportPeriod(const aArea: string; aYear: Word): TDayligtSavingPeriod;
var
  i: Integer;
  lBody: string;
  lDate: string;
  lEndDateTime: TDateTime;
  lMatches: TMatchCollection;
  lRegex: TRegEx;
  lStartDateTime: TDateTime;
  lTime: string;
  lURL : string;
  s: string;
begin
  lURL := Format(cURL, [aArea, aYear]);
  lBody := TMyHttpGet.GetWebsiteContent(lURL);
  if Pos(cNotDST, lBody) > 0 then
  begin
    Result.StartPeriod := 0;
    Result.EndPeriod := 0;
  end else
  begin
    lMatches := TRegEx.Matches(lBody, cReg, [roIgnoreCase, roMultiLine]);
    if lMatches.Count = 2 then
    begin
      if lMatches.Item[0].Groups.Count = 3 then
      begin
        lDate := lMatches.Item[0].Groups[1].Value;
        lTime := lMatches.Item[0].Groups[2].Value;
        lStartDateTime := ConvertDateTime(lDate, lTime);
      end else
      begin
        raise Exception.Create('Unknown website content');
      end;
      if lMatches.Item[1].Groups.Count = 3 then
      begin
        lDate := lMatches.Item[1].Groups[1].Value;
        lTime := lMatches.Item[1].Groups[2].Value;
        lEndDateTime := ConvertDateTime(lDate, lTime);
      end else
      begin
        raise Exception.Create('Unknown website content');
      end;
    end else
    begin
      raise Exception.CreateFmt('Bad input data: %s: %d', [aArea, aYear]);
    end;
    Result.StartPeriod := lStartDateTime;
    Result.EndPeriod := lEndDateTime;
  end;
end;

end.
