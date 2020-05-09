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
  System.SysUtils;

function Challenge01(const aText:string; const aChar:char): string;
var
  i: Integer;
  lSB : TStringBuilder;
  iStart : Integer;
  iEnd : Integer;
  iCopyStart : Integer;
begin
  if Length(aText) < 2 then
  begin
    Exit(aText);
  end;
  lSB := TStringBuilder.Create(Length(aText));
  try
    i := 1;
    iStart := 1;
    iEnd := 1;
    iCopyStart := 1;
    while i < Length(aText) do
    begin
      if aText[i] = aChar then
      begin
        Inc(iEnd);
      end else
      begin
        if iStart <> iEnd then
        begin
          lSB.Append(Copy(aText, iCopyStart, iStart - iCopyStart + 1));
          iCopyStart := iEnd;
          Inc(iEnd);
          iStart := iEnd;
        end else
        begin
          Inc(iStart);
          Inc(iEnd);
        end;
      end;
      Inc(i);
    end;
    if iCopyStart < iStart then
    begin
      lSB.Append(Copy(aText, iCopyStart, iStart - iCopyStart + 1));
    end;
    Result := lSB.ToString;
  finally
    lSB.Free;
  end;
end;

end.
