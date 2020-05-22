unit Test01.RemoveRepetitions;

interface

uses
  DUnitX.TestFramework,
  Code01.RemoveRepetitions;

{$M+}
type

  [TestFixture]
  TDelphiChallenge01 = class(TObject)
  private
    procedure RunTest(aParticipants: TChallengeParticipants);
  published
    procedure Challenge01_LukaszHamera;
    procedure Challenge01_JacekLaskowski;
    procedure Challenge01_LukaszKotynski;
    procedure Challenge01_Ongakw;
    procedure Challenge01_PiotrSlomski;
    procedure Challenge01_WaldekGorajek;
  end;

implementation


procedure TDelphiChallenge01.RunTest(aParticipants: TChallengeParticipants);
begin
  aChallengeParticipants := aParticipants;
  Assert.AreEqual (
    'Wlazł kotek na płotek i mruga',
    Challenge01('Wlazł koooootek na płoooooootek i mruga', 'o'));
end;

procedure TDelphiChallenge01.Challenge01_LukaszHamera;
begin
  RunTest(cpLukaszHamera);
end;

procedure TDelphiChallenge01.Challenge01_JacekLaskowski;
begin
  RunTest(cpJacekLaskowski);
end;

procedure TDelphiChallenge01.Challenge01_LukaszKotynski;
begin
  RunTest(cpLukaszKotynski);
end;

procedure TDelphiChallenge01.Challenge01_PiotrSlomski;
begin
  RunTest(cpPiotrSlomski);
end;

procedure TDelphiChallenge01.Challenge01_WaldekGorajek;
begin
  RunTest(cpWaldekGorajek);
end;

procedure TDelphiChallenge01.Challenge01_Ongakw;
begin
  RunTest(cpOngakw);
end;


initialization
  TDUnitX.RegisterTestFixture(TDelphiChallenge01);
end.
