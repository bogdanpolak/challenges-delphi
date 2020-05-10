unit Code.DelphiChallenge01;

interface

{
@subject: Delphi Challenge #01
@author: Jacke Laskiwski
@date: 2020-05-09 21:00

Funkcja przyjmująca na wejściu dwa parametry:
  - łańcuch tekstowy oraz
  - znak (char),
celem funkcji jest usunięcie z zadanego łańcucha wszystkich powtórzonych
znaków zgodnych z podanym charem i pozostawienie go tylko pojedynczo.

Przykładowo przekazuję do funkcji łańcuch:
  "Wlazł koooootek na płoooooootek i mruga",
  oraz jako char literę "o",
  a funkcja zwraca: "Wlazł kotek na płotek i mruga".
}

function Challenge01(const aText:string; const aChar:char): string;

implementation

uses
    System.RegularExpressions
  ;

function Challenge01(const aText:string; const aChar:char): string;
begin
  Result := TRegEx.Replace(aText, aChar + '+', aChar);
end;

end.
