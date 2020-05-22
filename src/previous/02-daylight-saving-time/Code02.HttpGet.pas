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
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdSSLOpenSSL,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP;

class function TMyHttpGet.GetWebsiteContent(aUrl: string): string;
var
  IdHTTP: TIdHTTP;
  aSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  IdHTTP := TIdHTTP.Create(nil);
  aSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
  aSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvTLSv1_2;
  aSSLIOHandlerSocketOpenSSL.SSLOptions.Mode := sslmUnassigned;
  IdHTTP.IOHandler := aSSLIOHandlerSocketOpenSSL;
  IdHTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
  IdHTTP.Request.CharSet := 'utf-8';
  IdHTTP.Request.ContentEncoding := 'utf-8';
  IdHTTP.Request.ContentType := 'application/x-www-form-urlencoded';
  IdHTTP.Request.AcceptLanguage := 'en-US';
  try
    Result := IdHTTP.Get(aUrl);
    CounterHttpCalls := CounterHttpCalls + 1;
  finally
    IdHTTP.Free;
  end;
end;

end.
