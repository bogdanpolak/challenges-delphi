unit TimeAndDate;

interface

uses
  System.SysUtils,
  WebSite,
  HtmlDoc;

type

  ETimeAndDateWebSite = class(Exception);

  ITimeAndDateWebSite = interface
    ['{F32284C8-1B95-40D8-AEA0-76057587E0CD}']
    function IsDaylightSaving(const Area: string; Year: Word): Boolean;
    function GetDaylightStart(const Area: string; Year: Word): TDateTime;
    function GetDaylightEnd(const Area: string; Year: Word): TDateTime;
  end;

  TTimeAndDate = class(TInterfacedObject, ITimeAndDateWebSite)
  private
    fs: TFormatSettings;
    WebSite: IWebSite; // CtorDI
    function GetUrl(Area: string; Year: Word): string;
    function HasDaylightSaving(const Text: string): Boolean;
    function ExtractDateTime(const Text, FindText: string): TDateTime;
    procedure RaiseInvalidStructure;
    function MonthToInt(const MonthStr: string): Integer;
  public
    constructor Create(AWebSite: IWebSite);
    function IsDaylightSaving(const Area: string; Year: Word): Boolean;
    function GetDaylightStart(const Area: string; Year: Word): TDateTime;
    function GetDaylightEnd(const Area: string; Year: Word): TDateTime;
  end;

function BuildTimeAndDateWebSite: ITimeAndDateWebSite;

implementation

uses
  System.Types, System.StrUtils,
  Utils;

constructor TTimeAndDate.Create(AWebSite: IWebSite);
begin
  inherited Create;
  fs := TFormatSettings.Create('en');
  WebSite := AWebSite;
end;

function TTimeAndDate.IsDaylightSaving(const Area: string; Year: Word): Boolean;
const
  SDateAndTimeElemID = 'qfacts';
var
  Doc: IHTMLDoc;
  Elem: IHTMLElem;
begin
  Result := False;
  Doc := BuildHTMLDoc(WebSite.GetContent(GetUrl(Area, Year)));
  Elem := Doc.getElemById(SDateAndTimeElemID);
  if Assigned(Elem) then
    Result := HasDaylightSaving(Elem.InnerText)
  else
    RaiseInvalidStructure;
end;

function TTimeAndDate.GetDaylightStart(const Area: string; Year: Word): TDateTime;
var
  Doc: IHTMLDoc;
begin
  Doc := BuildHTMLDoc(WebSite.GetContent(GetUrl(Area, Year)));
  Result := ExtractDateTime(Doc.Body.InnerText, 'Daylight Saving Time Start')
end;

function TTimeAndDate.GetDaylightEnd(const Area: string; Year: Word): TDateTime;
var
  Doc: IHTMLDoc;
begin
  Doc := BuildHTMLDoc(WebSite.GetContent(GetUrl(Area, Year)));
  Result := ExtractDateTime(Doc.Body.InnerText, 'Daylight Saving Time End')
end;

function TTimeAndDate.GetUrl(Area: string; Year: Word): string;
const
  SHost = 'https://www.timeanddate.com';
  SDoc = 'time/change';
begin
  Result := Format('%s/%s/%s?year=%d', [SHost, SDoc, Area, Year]);
end;

function TTimeAndDate.HasDaylightSaving(const Text: string): Boolean;
begin
  Result := ContainsText(Text, 'Start DST:');
end;

function TTimeAndDate.ExtractDateTime(const Text, FindText: string): TDateTime;

  function Convert(const Text: string): TDateTime;
  var
    Tok: TStringDynArray;
    Day, Month, Year: Integer;
    Time: string;
  begin
    Tok := SplitString(ReplaceStr(Text, ',', ''), ' ');
    if Length(Tok) < 5 then
      RaiseInvalidStructure;

    Day := StrToInt(Tok[1]);
    Month := MonthToInt(Tok[2]);
    Year := StrToInt(Tok[3]);
    Time := Tok[4];
    Result := EncodeDate(Year, Month, Day);
    Result := StrToDateTime(DateToStr(Result) + ' ' + Time);
  end;

var
  ArrIter: IStrArrayIterator;
  Line: string;
begin
  Result := 0;
  ArrIter := BuildStrArrayIteratorNonEmptyLines(SplitString(Text, sLineBreak));
  while ArrIter.Next(Line) do begin
    if ContainsText(Line, FindText) then begin
      ArrIter.Next(Line); // skip 'When local standard/daylight  time was about to reach'
      ArrIter.Next(Line); // fetch line with date time
      Exit(Convert(Line));
    end;
  end;
end;

function TTimeAndDate.MonthToInt(const MonthStr: string): Integer;
var
  Month: Integer;
begin
  Result := -1;
  for Month := low(fs.LongMonthNames) to high(fs.LongMonthNames) do begin
    if SameText(fs.LongMonthNames[Month], MonthStr) then
      Exit(Month);
  end;
  RaiseInvalidStructure;
end;

procedure TTimeAndDate.RaiseInvalidStructure;
begin
  raise ETimeAndDateWebSite.Create('Invalid HTML Page structure');
end;

function BuildTimeAndDateWebSite: ITimeAndDateWebSite;
begin
  Result := TTimeAndDate.Create(BuildWebSiteWithCache);
end;

end.
