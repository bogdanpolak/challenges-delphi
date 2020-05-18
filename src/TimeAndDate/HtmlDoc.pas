unit HtmlDoc;

interface

type

  IHTMLElemCollection = interface;

  IHTMLElem = interface
    ['{348287FA-A001-49C7-966B-2B07A151D8DA}']
    function TagName: string;
    //function ClassName: string;
    function InnerText: string;
    function Children: IHTMLElemCollection;
  end;

  IHTMLElemCollection = interface
    ['{0344A65F-85BD-4F5B-BCD8-E0A19C852F02}']
    function Count: Integer;
    function Item(Index: Integer): IHTMLElem;
  end;

  IHTMLDoc = interface
    ['{4AB6D434-937D-4FD5-A646-E6B8B58D5C77}']
    function DocumentElem: IHTMLElem;
    function Body: IHTMLElem;
    function GetElemById(const ID: string): IHTMLElem;
  end;

function BuildHTMLDoc(const Content: string): IHTMLDoc;

implementation

uses
  System.Variants, System.VarUtils,
  Winapi.ActiveX,
  MSHTML;

type


  THTMLElem = class(TInterfacedObject, IHTMLElem)
  private
    HTMLElem: IHTMLElement;
    FChildren: IHTMLElemCollection;
  public
    constructor Create(AHTMLElem: IHTMLElement);
    function TagName: string;
    function InnerText: string; inline;
    function Children: IHTMLElemCollection; inline;
  end;

  THTMLElemCollection = class(TInterfacedObject, IHTMLElemCollection)
  private
    Children: IHTMLElementCollection; // CtorDI
  public
    constructor Create(AChildren: IHTMLElementCollection);
    function Count: Integer; inline;
    function Item(Index: Integer): IHTMLElem; inline;
  end;

  THtmlDoc = class(TInterfacedObject, IHTMLDoc)
  private
    Doc2: IHTMLDocument2;
    Doc3: IHTMLDocument3;

    procedure SetHtmlDoc(const HtmlDoc: string);
  public
    constructor Create(const Content: string);
    function DocumentElem: IHTMLElem;
    function Body: IHTMLElem;
    function GetElemById(const ID: string): IHTMLElem; inline;
  end;

{ THTMLElem }

constructor THTMLElem.Create(AHTMLElem: IHTMLElement);
begin
  inherited Create;
  FChildren := nil;
  HTMLElem := AHTMLElem;
end;

function THTMLElem.TagName: string;
begin
  Result := HTMLElem.tagName;
end;

function THTMLElem.InnerText: string;
begin
  Result := HTMLElem.InnerText;
end;

function THTMLElem.Children: IHTMLElemCollection;
begin
  if not Assigned(FChildren) then
    FChildren := THTMLElemCollection.Create(HTMLElem.children as IHTMLElementCollection);
  Result := FChildren;
end;

{ THTMLElemCollection }

constructor THTMLElemCollection.Create(AChildren: IHTMLElementCollection);
begin
  inherited Create;
  Children :=  AChildren;
end;

function THTMLElemCollection.Count: Integer;
begin
  Result := Children.length;
end;

function THTMLElemCollection.Item(Index: Integer): IHTMLElem;
begin
  Result := THTMLElem.Create(Children.item(Index, 0) as IHTMLElement);
end;

{ THTMLDoc }

constructor THtmlDoc.Create(const Content: string);
begin
  inherited Create;
  Doc2 := coHTMLDocument.Create as IHTMLDocument2;
  SetHTMLDoc(Content);
  Doc3 := Doc2 as IHTMLDocument3;
end;

procedure THtmlDoc.SetHtmlDoc(const HtmlDoc: string);
var
  V: OleVariant;
begin
  V := VarArrayCreate([0,0], varVariant);
  V[0] := HtmlDoc;
  Doc2.Write(PSafeArray(TVarData(v).VArray));
end;

function THtmlDoc.DocumentElem: IHTMLElem;
begin
  Result := THTMLElem.Create(Doc3.documentElement);
end;

function THtmlDoc.Body: IHTMLElem;
begin
  Result := THTMLElem.Create(Doc2.body);
end;

function THtmlDoc.getElemById(const ID: string): IHTMLElem;
begin
  Result := THTMLElem.Create(Doc3.getElementById(ID));
end;

function BuildHTMLDoc(const Content: string): IHTMLDoc;
begin
  Result := THTMLDoc.Create(Content);
end;

end.
