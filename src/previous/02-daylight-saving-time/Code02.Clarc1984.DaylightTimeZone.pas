unit Code02.Clarc1984.DaylightTimeZone;

interface

uses
  System.json;

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
  TJsonParam = (jpDTS, jpStart, jpEnd);

function IsDaylightSaving(const area: string; year: Word): boolean;
function GetDaylightStart(const area: string; year: Word): TDateTime;
function GetDaylightEnd(const area: string; year: Word): TDateTime;
function MakeValidUrl(const area: string; year: Word): string;
function GetPageContent(const area: string; year: Word): string;
procedure SaveDataToRecords(const area: string; year: Word);
function DataInRecords(const data: string): TJSONObject;
function JsonFromDB: TJSONObject;
function PageStringToDateTime(const date: string; year: Word): TDateTime;
function GetDaylightParamFromRecord(const area: string; year: Word; param: TJsonParam): Variant;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.StrUtils,
  Code02.HttpGet;

const
  cUrlStr = 'https://www.timeanddate.com/time/change/%s?year=%d';
  cNotDTSdiv = '<div class="alert warning">';
  cDBfile = 'DBrecords.json';
  cJsonDTS = 'DTS';
  cJsonStart = 'start';
  cJsonEnd = 'end';

function GetDaylightParamFromRecord(const area: string; year: Word; param: TJsonParam): Variant;
var
  lJsonObj: TJSONObject;

begin
  SaveDataToRecords(area, year);

  lJsonObj := DataInRecords(area + year.ToString);
  if Assigned(lJsonObj) then
  begin
    lJsonObj := JsonFromDB;
    case param of
      jpDTS   : Result := lJsonObj.GetValue<Boolean>(area + year.ToString + '[0].' + cJsonDTS);
      jpStart : Result := UnixToDateTime(lJsonObj.GetValue<Integer>(area + year.ToString + '[0].' + cJsonStart));
      jpEnd   : Result := UnixToDateTime(lJsonObj.GetValue<Integer>(area + year.ToString + '[0].' + cJsonEnd));
    end;
  end;
end;

function PageStringToDateTime(const date: string; year: word): TDateTime;
var
  lDateParts: TArray<string>;
  lMonth, lDay, lHour, lMinute: word;
  lFs: TFormatSettings;

begin
  lFs := TFormatSettings.Create('en-US');
  lDateParts := SplitString(date, ' ');
  lMonth := IndexText(lDateParts[2], lFs.LongMonthNames) + 1;
  lDay := lDateParts[1].ToInteger;
  lHour := StrToInt(Copy(lDateParts[3], 1, 2));
  lMinute := StrToInt(Copy(lDateParts[3], 4, 2));
  Result := EncodeDateTime(year, lMonth, lDay, lHour, lMinute, 0, 0);
end;

function JsonFromDB: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FileExists(cDBfile) then
    Result := TJSONObject(TJSONObject.ParseJSONValue(TFile.ReadAllText(cDBfile)));
end;

function DataInRecords(const data: string): TJSONObject;
var
  lJsonObj: TJSONObject;

begin
  lJsonObj := JsonFromDB;
  Result := TJSONObject(lJsonObj.FindValue(data));
  lJsonObj.Free;
end;

procedure SaveDataToRecords(const area: string; year: word);
var
  lJsonObj, lJsonData: TJSONObject;
  lJsonArray: TJSONArray;
  lPageContent: string;
  lvalDTS: boolean;
  lStartDate, lEndDate: Integer;
  lStartPos, lEndPos: Integer;
  lTmpDatesStr: string;
  lStartDateStr, lEndDateStr: string;

begin
  lJsonObj := DataInRecords(area + year.ToString);
  if lJsonObj = nil then
  begin
    lPageContent := GetPageContent(area, year);
    lStartPos := Pos('</td></tr><tr ><th>' + year.ToString + '</th><td>', lPageContent);
    lStartPos := lStartPos + 32;
    lEndPos := Pos('</td></tr>', lPageContent, lStartPos);
    if (lStartPos < lEndPos) and (lEndPos > 1) then
    begin
      lTmpDatesStr := Copy(lPageContent, lStartPos, lEndPos - lStartPos);
      lTmpDatesStr := StringReplace(lTmpDatesStr, ',', '', [rfReplaceAll]);
      if (lTmpDatesStr[1] <> '<') then
      begin
        lStartPos := Pos('</td><td>', lTmpDatesStr);
        lStartPos := lStartPos + 9;
        lEndPos := Pos('>', lTmpDatesStr, lStartPos);
        lStartDateStr := Copy(lTmpDatesStr, 1, lStartPos - 10);
        if lEndPos = 0 then
          Delete(lTmpDatesStr, 1, Pos('>', lTmpDatesStr))
        else
          Delete(lTmpDatesStr, 1, lEndPos);
      end
      else
      begin
        lStartPos := Pos('>', lTmpDatesStr);
        lEndPos := Pos('</', lTmpDatesStr, lStartPos);
        if (lStartPos < lEndPos) then
          Delete(lTmpDatesStr, 1, lStartPos);
        lStartPos := Pos('</', lTmpDatesStr);
        lEndPos := Pos('<td>', lTmpDatesStr, lStartPos);
        lStartDateStr := Copy(lTmpDatesStr, 1, lStartPos - 1);
        Delete(lTmpDatesStr, 1, lEndPos + 3);
      end;
      lEndDateStr := lTmpDatesStr;
    end;

    lvalDTS := Pos(cNotDTSdiv, lPageContent) = 0;
    if lStartDateStr.IsEmpty then
      lStartDate := 0
    else
      lStartDate := DateTimeToUnix(PageStringToDateTime(lStartDateStr, year));

    if lEndDateStr.IsEmpty then
      lEndDate := 0
    else
      lEndDate := DateTimeToUnix(PageStringToDateTime(lEndDateStr, year));

    lJsonData := TJSONObject.Create;
    try
      lJsonData.AddPair(cJsonStart, lStartDate.ToString);
      lJsonData.AddPair(cJsonEnd, lEndDate.ToString);
      lJsonData.AddPair(cJsonDTS, lvalDTS.ToString);

      lJsonArray := TJSONArray.Create;
      lJsonArray.Add(lJsonData);

      lJsonObj := JsonFromDB;
      lJsonObj.AddPair(area + year.ToString, lJsonArray);

      TFile.WriteAllText(cDBfile, lJsonObj.ToString);
    finally
      lJsonObj.Free;
    end;
  end;
end;

function GetPageContent(const area: string; year: word): string;
begin
  Result := TMyHttpGet.GetWebsiteContent(MakeValidUrl(area, year));
end;

function MakeValidUrl(const area: string; year: word): string;
begin
  Result := Format(cUrlStr, [area, year]);
end;

function IsDaylightSaving(const area: string; year: word): Boolean;
begin
  Result := GetDaylightParamFromRecord(area, year, jpDTS);
end;

function GetDaylightStart(const area: string; year: word): TDateTime;
begin
  Result := GetDaylightParamFromRecord(area, year, jpStart);
end;

function GetDaylightEnd(const area: string; year: word): TDateTime;
begin
  Result := GetDaylightParamFromRecord(area, year, jpEnd);
end;

initialization

begin
  DeleteFile(cDBfile);
end;

end.
