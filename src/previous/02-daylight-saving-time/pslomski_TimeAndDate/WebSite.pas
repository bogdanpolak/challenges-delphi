unit WebSite;

interface

type

  IWebSite = interface
    ['{D9458634-F21B-4CE2-BB4E-587E95CF4694}']
    function GetContent(const Url: string): string;
  end;

function BuildWebSiteWithCache: IWebSite;

implementation

uses
  Code02.HttpGet,
  HttpCache;

type

  TWebSiteWithCache = class(TInterfacedObject, IWebSite)
    private
    class var Cache: THttpCache;
    class constructor Create;
    class destructor Destroy;
  public
    function GetContent(const Url: string): string;
  end;


class constructor TWebSiteWithCache.Create;
begin
  Cache := THttpCache.Create;
end;

class destructor TWebSiteWithCache.Destroy;
begin
  Cache.Free;
end;

function TWebSiteWithCache.GetContent(const Url: string): string;
begin
  if Cache.Contains(Url) then begin
    Result := Cache.GetContent(Url)
  end
  else begin
    Result := TMyHttpGet.GetWebsiteContent(Url);
    Cache.SetContent(Url, Result);
  end;
end;

function BuildWebSiteWithCache: IWebSite;
begin
  Result := TWebSiteWithCache.Create;
end;

end.
