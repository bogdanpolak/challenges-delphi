unit Code02.HttpGet;

interface

type
  TMyHttpGet = class
  class var
    CounterHttpCalls: integer;
    class function GetWebsiteContent(aUrl: string): string;
  end;

implementation

uses
  IdAuthentication,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;

class function TMyHttpGet.GetWebsiteContent(aUrl: string): string;
var
  IdHTTP: TIdHTTP;
begin
  IdHTTP := TIdHTTP.Create(nil);
  try
    Result := IdHTTP.Get(aUrl);
    CounterHttpCalls := CounterHttpCalls + 1;
  finally
    IdHTTP.Free;
  end;
end;

end.
