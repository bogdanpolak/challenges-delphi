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

uses
  System.SysUtils;

function Challenge01(const aText: string; const aChar: char): string;
var
  lInputStringIndex,
  lOutputStringSize: Integer;

  lInputStringPointer,
  lOutputStringPointer: PChar;

begin
  if (aText.IsEmpty OR (Length(aText) = 1)) then
  begin
    Exit(aText);
  end;

  SetLength(Result, Length(aText));
  lInputStringPointer := PChar(aText);
  lOutputStringPointer := PChar(Result);
  lOutputStringPointer^ := lInputStringPointer^;

  Inc(lInputStringPointer);
  Inc(lOutputStringPointer);

  for lInputStringIndex := 2 to Length(aText) do
  begin
    if(((lInputStringPointer - 1)^ = aChar) AND (lInputStringPointer^ = aChar)) then
    begin
      Inc(lInputStringPointer);
      Continue;
    end;

    lOutputStringPointer^ := lInputStringPointer^;

    Inc(lInputStringPointer);
    Inc(lOutputStringPointer);
  end;

  lOutputStringSize := (Integer(lOutputStringPointer) - Integer(PChar(Result))) div SizeOf(Char);
  SetLength(Result, lOutputStringSize);
end;

end.
