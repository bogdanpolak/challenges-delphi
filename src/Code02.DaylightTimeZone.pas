unit Code02.DaylightTimeZone;

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

function IsDaylightSaving(const area: string; year: word): boolean;
function GetDaylightStart(const area: string; year: word): TDateTime;
function GetDaylightEnd(const area: string; year: word): TDateTime;
function MakeValidUrl(const area: string; year: word): string;
function GetPageContent(const area: string; year: word): string;
procedure SaveDataToRecords(const area: string; year: word);
function DataInRecords(const data: string): TJSONObject;
function GetDaylightFromRecord(const area: string; year: word): Boolean;
function GetDaylightStartFromRecord(const area: string; year: word): TDateTime;
function GetDaylightEndFromRecord(const area: string; year: word): TDateTime;
function JsonFromDB: TJSONObject;
function PageStringToDateTime(const date : string; year : Word): TDateTime;


implementation

uses
  System.SysUtils,
  system.ioutils,
  system.dateutils,
  system.strutils,
  Code02.HttpGet;

const
  cUrlStr = 'https://www.timeanddate.com/time/change/%s?year=%d';
  cNotDTSdiv = '<div class="alert warning">';
  cDBfile = 'DBrecords.json';
  cJsonDTS = 'DTS';
  cJsonStart = 'start';
  cJsonEnd = 'end';

function PageStringToDateTime(const date : string; year : Word): TDateTime;
var
  lDateParts : TArray<string>;
  month, day, hour, minute : Integer;
  fs: TFormatSettings;

begin
  fs := TFormatSettings.Create('en-US');
  lDateParts := SplitString(date, ' ');
  month := IndexText(lDateParts[2],fs.LongMonthNames) + 1;
  day := lDateParts[1].ToInteger;
  hour := StrToInt(Copy(ldateparts[3], 1, 2));
  minute := StrToInt(Copy(ldateparts[3], 4, 2));
  Result := EncodeDateTime(year, month, day, hour, minute, 0, 0);
end;

function JsonFromDB: TJSONObject;
begin
  Result := TJSONObject.Create;
  if FileExists(cDBfile) then
    Result := TJSONObject(TJSONObject.ParseJSONValue(TFile.ReadAllText(cDBfile)));
end;

function GetDaylightFromRecord(const area: string; year: word): Boolean;
var
  lJsonObj : TJSONObject;

begin
  Result := False;
  lJsonObj := DataInRecords(area + year.ToString);
  if Assigned(lJsonObj) then
  begin
    lJsonObj := JsonFromDB;
    Result := lJsonObj.GetValue<Boolean>(area + year.ToString + '[0].' + cJsonDTS);
  end;
end;

function GetDaylightStartFromRecord(const area: string; year: word): TDateTime;
var
  lJsonObj : TJSONObject;
  ldateStr : string;

begin
  Result := 0;
  lJsonObj := DataInRecords(area + year.ToString);
  if Assigned(lJsonObj) then
  begin
    lJsonObj := JsonFromDB;
    ldateStr := lJsonObj.GetValue<string>(area + year.ToString + '[0].' + cJsonStart);
    Result := UnixToDateTime(StrToInt(ldateStr));
  end;
end;

function GetDaylightEndFromRecord(const area: string; year: word): TDateTime;
var
  lJsonObj : TJSONObject;
  ldateStr : string;

begin
  Result := 0;
  lJsonObj := DataInRecords(area + year.ToString);
  if Assigned(lJsonObj) then
  begin
    lJsonObj := JsonFromDB;
    ldateStr := lJsonObj.GetValue<string>(area + year.ToString + '[0].' + cJsonEnd);
    Result := UnixToDateTime(StrToInt(ldateStr));
  end;
end;

function DataInRecords(const data: string): TJSONObject;
var
  lJsonObj : TJSONObject;

begin
  lJsonObj := JsonFromDB;

  Result := TJSONObject(lJsonObj.FindValue(data));
  lJsonObj.Free;
end;

procedure SaveDataToRecords(const area: string; year: word);
var
  lJsonObj, lJsonData : TJSONObject;
  lJsonArray : TJSONArray;
  lPageContent : string;
  valDTS : Boolean;
  valStart, valEnd : Integer;

  startstr, endstr : Integer;
  tmpdates : string;
  str1, str2 : string;

begin
  lJsonObj := DataInRecords(area + year.ToString);
  if lJsonObj = nil then
  begin
    lPageContent := GetPageContent(area, year);
    startstr := Pos('</td></tr><tr ><th>'+year.ToString+'</th><td>',lPageContent);
    startstr := startstr + 32;
    endstr := Pos('</td></tr>', lPageContent, startstr);
    if (startstr < endstr) and (endstr > 1) then
    begin
      tmpdates := Copy(lPageContent, startstr, endstr - startstr);
      if (tmpdates[1] <> '<') then
      begin
        tmpdates := StringReplace(tmpdates, ',', '', [rfReplaceAll]);
        startstr := Pos('</td><td>', tmpdates);
        startstr := startstr + 9;
        endstr := Pos('>', tmpdates, startstr);
        str1 := Copy(tmpdates, 1, startstr - 10);
        if endstr = 0 then
          Delete(tmpdates, 1, Pos('>', tmpdates))
        else
          Delete(tmpdates, 1, endstr);
        str2 := tmpdates;
      end
      else
      begin
        startstr := Pos('>', tmpdates);
        startstr := startstr;
        endstr := Pos('</', tmpdates, startstr);
        if (startstr < endstr) then
          Delete(tmpdates, 1, startstr);

        tmpdates := StringReplace(tmpdates, ',', '', [rfReplaceAll]);
        startstr := Pos('</', tmpdates);
        endstr := Pos('<td>', tmpdates, startstr);
        str1 := Copy(tmpdates, 1, startstr - 1);
        Delete(tmpdates, 1, endstr + 3);
        str2 := tmpdates;
      end;
    end;


    valDTS := Pos(cNotDTSdiv, lPageContent) = 0;
    if str1.IsEmpty then
      valStart := 0
    else
      valStart := DateTimeToUnix(PageStringToDateTime(str1, year));

    if str2.IsEmpty then
      valEnd := 0
    else
      valEnd := DateTimeToUnix(PageStringToDateTime(str2, year));

    lJsonData := TJSONObject.Create;
    lJsonData.AddPair(cJsonStart, valStart.ToString);
    lJsonData.AddPair(cJsonEnd, valEnd.ToString);
    lJsonData.AddPair(cJsonDTS, valDTS.ToString);

    lJsonArray := TJSONArray.Create;
    lJsonArray.Add(lJsonData);

    lJsonObj := JsonFromDB;
    lJsonObj.AddPair(area + year.ToString, lJsonArray);

    TFile.WriteAllText(cDBfile, lJsonObj.ToString);
    lJsonObj.Free;
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
  SaveDataToRecords(area, year);

  Result := GetDaylightFromRecord(area, year);
end;

function GetDaylightStart(const area: string; year: word): TDateTime;
begin
  SaveDataToRecords(area, year);

  Result := GetDaylightStartFromRecord(area, year);
end;

function GetDaylightEnd(const area: string; year: word): TDateTime;
begin
  SaveDataToRecords(area, year);

  Result := GetDaylightEndFromRecord(area, year);
end;

initialization
begin
  DeleteFile(cDBfile);
end;

end.
