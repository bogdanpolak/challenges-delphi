program DelphiChallenges;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Code01.RemoveRepetitions in 'previous\01-remove-repetitons\Code01.RemoveRepetitions.pas',
  Test01.RemoveRepetitions in 'previous\01-remove-repetitons\Test01.RemoveRepetitions.pas',
  Test02.DaylightTimeZone in 'previous\02-daylight-saving-time\Test02.DaylightTimeZone.pas',
  Code02.HttpGet in 'previous\02-daylight-saving-time\Code02.HttpGet.pas',
  Code02.Clarc1984.DaylightTimeZone in 'previous\02-daylight-saving-time\Code02.Clarc1984.DaylightTimeZone.pas',
  Code02.Jacek.DaylightTimeZone in 'previous\02-daylight-saving-time\Code02.Jacek.DaylightTimeZone.pas',
  Code02.Ongakw.DaylightTimeZone in 'previous\02-daylight-saving-time\Code02.Ongakw.DaylightTimeZone.pas',
  Code02.pslomski.DaylightTimeZone in 'previous\02-daylight-saving-time\Code02.pslomski.DaylightTimeZone.pas',
  HtmlDoc in 'previous\02-daylight-saving-time\pslomski_TimeAndDate\HtmlDoc.pas',
  HttpCache in 'previous\02-daylight-saving-time\pslomski_TimeAndDate\HttpCache.pas',
  TimeAndDate in 'previous\02-daylight-saving-time\pslomski_TimeAndDate\TimeAndDate.pas',
  Utils in 'previous\02-daylight-saving-time\pslomski_TimeAndDate\Utils.pas',
  WebSite in 'previous\02-daylight-saving-time\pslomski_TimeAndDate\WebSite.pas',
  Code02.Ongakw.Czas_Zmiana in 'previous\02-daylight-saving-time\Code02.Ongakw.Czas_Zmiana.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
