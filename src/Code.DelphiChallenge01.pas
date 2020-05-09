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

function Challenge01(const aText:string; const aChar:char): string;
var
    lInputStringIndex,
    lOutputStringIndex: Integer;

begin
  if ((aText.IsEmpty) OR (Length(aText) = 1)) then
  begin
    Exit(aText);
  end;

  SetLength(Result, Length(aText));

  Result[1] := aText[1];
  lOutputStringIndex := 1;
  for lInputStringIndex := 2 to Length(aText) do
  begin
    if((aText[lInputStringIndex - 1] = aChar) AND (aText[lInputStringIndex] = aChar)) then
    begin
      Continue;
    end;

    Inc(lOutputStringIndex);
    Result[lOutputStringIndex] := aText[lInputStringIndex];
  end;


  SetLength(Result, lOutputStringIndex);
end;

end.
