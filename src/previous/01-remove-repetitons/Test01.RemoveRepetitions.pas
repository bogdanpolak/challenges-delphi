unit Test01.RemoveRepetitions;

interface
uses
  DUnitX.TestFramework;

{$M+}
type

  [TestFixture]
  TDelphiChallenge01 = class(TObject) 
  published
    procedure Test1;
  end;

implementation

uses Code01.RemoveRepetitions;

procedure TDelphiChallenge01.Test1;
begin
  Assert.AreEqual (
    'Wlazł kotek na płotek i mruga',
    Challenge01('Wlazł koooootek na płoooooootek i mruga', 'o'));
end;

initialization
  TDUnitX.RegisterTestFixture(TDelphiChallenge01);
end.
