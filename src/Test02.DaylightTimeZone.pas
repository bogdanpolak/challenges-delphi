unit Test02.DaylightTimeZone;

interface

uses
  DUnitX.TestFramework;

{$M+}

type

  [TestFixture]
  Test02DaylightTimeZone = class(TObject)
  private const
    StrUseMyHttpGet = 'Użyj TMyHttpGet.GetWebsiteContent do pobrania' +
      ' zawartości strony Web';
  published
    [Test]
    procedure CheckWebSiteStructure_TimeAndDate;
    [Test]
    [TestCase(' - USA Atlanta - 2021', 'usa/atlanta,2021,true')]
    [TestCase(' - India Bangalore - 1998', 'india/bangalore,1998,false')]
    procedure IsDaylightSavingTime(const aArea: string; const aYear: word;
      const aIsDST: boolean);
    [Test]
    [TestCase(' - USA Atlanta - 1999', 'usa/atlanta,1999,1999-04-04 02:00')]
    [TestCase(' - Poland Warsaw - 2015', 'poland/warsaw,2015,2015-03-29 02:00')]
    [TestCase(' - USA Atlanta - 2021', 'usa/atlanta,2021,2021-03-14 02:00')]
    procedure Test_GetDaylightStartDate(const aArea: string; const aYear: word;
      const aExpectedTime: string);
    [Test]
    [TestCase(' - USA Atlanta - 1999', 'usa/atlanta,1999,1999-10-31 02:00')]
    [TestCase(' - Poland Warsaw - 2015', 'poland/warsaw,2015,2015-10-25 03:00')]
    [TestCase(' - USA Atlanta - 2021', 'usa/atlanta,2021,2021-11-17 02:00')]
    procedure Test_GetDaylightEndDate(const aArea: string; const aYear: word;
      const aExpectedTime: string);
    [Test]
    procedure Test_Performance();
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  Code02.DaylightTimeZone,
  Code02.HttpGet;

procedure Test02DaylightTimeZone.CheckWebSiteStructure_TimeAndDate;
var
  aHtmlPageContent: string;
  isContains: Boolean;
begin
  aHtmlPageContent := TMyHttpGet.GetWebsiteContent
    ('https://www.timeanddate.com/time/change/poland/warsaw?year=1998');
  isContains := aHtmlPageContent.Contains('<p>25 Oct 2020, 03:00</p>');
  Assert.IsTrue(isContains,
    'Usupported new page format. Required update');
end;

procedure Test02DaylightTimeZone.IsDaylightSavingTime(const aArea: string;
  const aYear: word; const aIsDST: boolean);
begin
  Assert.AreEqual(aIsDST, IsDaylightSaving(aArea, aYear));
end;

procedure Test02DaylightTimeZone.Test_GetDaylightStartDate(const aArea: string;
  const aYear: word; const aExpectedTime: string);
var
  dt: TDateTime;
  actual: string;
begin
  TMyHttpGet.CounterHttpCalls := 0;

  dt := GetDaylightStart(aArea, aYear);

  actual := FormatDateTime('yyyy-mm-dd hh:mm', dt);
  Assert.IsTrue(TMyHttpGet.CounterHttpCalls >= 1, StrUseMyHttpGet);
  Assert.AreEqual(aExpectedTime, actual);
end;

procedure Test02DaylightTimeZone.Test_GetDaylightEndDate(const aArea: string;
  const aYear: word; const aExpectedTime: string);
var
  dt: TDateTime;
  actual: string;
begin
  TMyHttpGet.CounterHttpCalls := 0;

  dt := GetDaylightEnd(aArea, aYear);

  actual := FormatDateTime('yyyy-mm-dd hh:mm', dt);
  Assert.IsTrue(TMyHttpGet.CounterHttpCalls >= 1, StrUseMyHttpGet);
  Assert.AreEqual(aExpectedTime, actual);
end;

procedure Test02DaylightTimeZone.Test_Performance;
var
  area: string;
  year: Integer;
begin
  TMyHttpGet.CounterHttpCalls := 0;
  area := 'usa/atlanta';
  year := 1995;
  IsDaylightSaving(area, year);
  GetDaylightStart(area, year);
  GetDaylightEnd(area, year);
  GetDaylightStart(area, year);
  Assert.AreEqual(1, TMyHttpGet.CounterHttpCalls);
end;

initialization

TDUnitX.RegisterTestFixture(Test02DaylightTimeZone);

end.
