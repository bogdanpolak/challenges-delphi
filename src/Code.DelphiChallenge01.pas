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

function Challenge01(const aText: string; const aChar: char): string;

implementation

function Challenge01(const aText: string; const aChar: char): string;
var
  CurrChar, PrevChar: char;
begin
  Result := '';
  PrevChar := #0;
  for CurrChar in aText do begin
    if CurrChar <> PrevChar then
      Result := Result + CurrChar;
    PrevChar := CurrChar;
  end;
end;

end.
