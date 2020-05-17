unit Code01.RemoveRepetitions;

interface

{
@theme: Delphi Challenge
@subject: #01 Remove Character Repetitions
@author: Jacek Laskowski
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

type
  TChallengeParticipants = (cpLukaszHamera, cpJacekLaskowski, cpClarc1984,
    cpPiotrSlomski, cpWldekGorajek, cpOngakw);

var
  aChallengeParticipants: TChallengeParticipants;

function Challenge01(const aText: string; const aChar: char): string;

implementation

uses
  System.SysUtils,
  System.RegularExpressions;


// ----------------------------------------------------------------
// Łukasz Hamera - solution
// ----------------------------------------------------------------

function Challenge01_LukaszHamera(const aText: string;
  const aChar: char): string;
var
  lInputStringIndex, lOutputStringSize: Integer;
  lInputStringPointer, lOutputStringPointer: PChar;
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
    if (((lInputStringPointer - 1)^ = aChar) AND (lInputStringPointer^ = aChar))
    then
    begin
      Inc(lInputStringPointer);
      Continue;
    end;

    lOutputStringPointer^ := lInputStringPointer^;

    Inc(lInputStringPointer);
    Inc(lOutputStringPointer);
  end;

  lOutputStringSize := (Integer(lOutputStringPointer) - Integer(PChar(Result)))
    div SizeOf(char);
  SetLength(Result, lOutputStringSize);
end;


// ----------------------------------------------------------------
// Jacek Laskowski - solution
// ----------------------------------------------------------------

function Challenge01_JacekLaskowski(const aText: string;
  const aChar: char): string;
var
  i: Integer;
  lSB: TStringBuilder;
  iStart: Integer;
  iEnd: Integer;
  iCopyStart: Integer;
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
      end
      else
      begin
        if iStart <> iEnd then
        begin
          lSB.Append(Copy(aText, iCopyStart, iStart - iCopyStart + 1));
          iCopyStart := iEnd;
          Inc(iEnd);
          iStart := iEnd;
        end
        else
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


// ----------------------------------------------------------------
// Clarc1984 - solution
// ----------------------------------------------------------------

function Challenge01_Clarc1984(const aText: string; const aChar: char): string;
begin
  Result := '';
  for var i := 1 to High(aText) do
    if (aText[i] = aChar) then
    begin
      if (aText[i - 1] <> aChar) then
        Result := Result + aText[i];
    end
    else
      Result := Result + aText[i];
end;


// ----------------------------------------------------------------
// Piotr Slomski - solution
// ----------------------------------------------------------------

function Challenge01_PiotrSlomski(const aText: string;
  const aChar: char): string;
var
  CurrChar, PrevChar: char;
begin
  Result := '';
  PrevChar := #0;
  for CurrChar in aText do
  begin
    if CurrChar <> PrevChar then
      Result := Result + CurrChar;
    PrevChar := CurrChar;
  end;
end;


// ----------------------------------------------------------------
// Waldek Gorajek - solution
// ----------------------------------------------------------------

function Challenge01_WaldekGorajek(const aText: string;
  const aChar: char): string;
begin
  Result := System.RegularExpressions.TRegEx.Replace(aText, aChar + '+', aChar);
end;


// ----------------------------------------------------------------
// ongakw - solution
// ----------------------------------------------------------------

function Challenge01_ongakw(const aText: string; const aChar: char): string;
var
  znak_numer: Integer;
begin
  Result := aText;

  if Trim(Result) = '' then
    Exit;

  znak_numer := 1;

  while znak_numer <= Length(Result) - 1 do
  begin
    if Result[znak_numer] = aChar then
      while Result[znak_numer] = Result[znak_numer + 1] do
        Delete(Result, znak_numer + 1, 1);
    Inc(znak_numer);
  end;
end;

// ----------------------------------------------------------------
// ----------------------------------------------------------------

function Challenge01(const aText: string; const aChar: char): string;
begin
  case aChallengeParticipants of
    cpLukaszHamera:
      Result := Challenge01_LukaszHamera(aText, aChar);
    cpJacekLaskowski:
      Result := Challenge01_JacekLaskowski(aText, aChar);
    cpClarc1984:
      Result := Challenge01_Clarc1984(aText, aChar);
    cpPiotrSlomski:
      Result := Challenge01_PiotrSlomski(aText, aChar);
    cpWldekGorajek:
      Result := Challenge01_WaldekGorajek(aText, aChar);
    cpOngakw:
      Result := Challenge01_ongakw(aText, aChar);
  end;

end;

end.
