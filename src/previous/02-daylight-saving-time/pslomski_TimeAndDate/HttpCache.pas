unit HttpCache;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type

  EHttpCache = class(Exception);

  // Simple in-memory cache
  THttpCache = class
  private type
    TCache = TDictionary<string, string>;
  private
    Cache: TCache;
  public
    constructor Create;
    destructor Destroy; override;
    function Contains(const Url: string): Boolean;
    function GetContent(const Url: string): string;
    procedure SetContent(const Url, Content: string);
  end;

implementation

constructor THttpCache.Create;
begin
  inherited Create;
  Cache := TCache.Create;
end;

destructor THttpCache.Destroy;
begin
  Cache.Free;
  inherited;
end;

function THttpCache.Contains(const Url: string): Boolean;
begin
  Result := Cache.ContainsKey(Url);
end;

function THttpCache.GetContent(const Url: string): string;
begin
  if not Cache.TryGetValue(Url, Result) then
    raise EHttpCache.Create('THttpCache.GetContent: Url not found');
end;

procedure THttpCache.SetContent(const Url, Content: string);
begin
  Cache.AddOrSetValue(Url, Content);
end;

end.
