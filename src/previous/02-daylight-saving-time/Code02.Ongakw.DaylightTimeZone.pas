﻿unit Code02.Ongakw.DaylightTimeZone;

interface

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

implementation

uses
  System.SysUtils,
  Code02.HttpGet,
  Code02.Ongakw.Czas_Zmiana;

function IsDaylightSaving(const area: string; year: word): boolean;
var
  aCzasZmiana: TCzas_Zmiana;
begin
  aCzasZmiana := TCzas_Zmiana.Create;
  try
    Result := aCzasZmiana.IsDaylightSaving(area,year);
  finally
    aCzasZmiana.Free;
  end;
end;

function GetDaylightStart(const area: string; year: word): TDateTime;
var
  aCzasZmiana: TCzas_Zmiana;
begin
  aCzasZmiana := TCzas_Zmiana.Create;
  try
    Result := aCzasZmiana.GetDaylightStart(area,year);
  finally
    aCzasZmiana.Free;
  end;
end;

function GetDaylightEnd(const area: string; year: word): TDateTime;
var
  aCzasZmiana: TCzas_Zmiana;
begin
  aCzasZmiana := TCzas_Zmiana.Create;
  try
    Result := aCzasZmiana.GetDaylightEnd(area,year);
  finally
    aCzasZmiana.Free;
  end;
end;

end.
