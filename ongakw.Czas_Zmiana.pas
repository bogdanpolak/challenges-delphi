unit Czas_Zmiana;

interface

uses
  System.SysUtils;

type
  THistoria_Zapytañ_r_wsk = ^THistoria_Zapytañ_r;

  THistoria_Zapytañ_r = record
    rok : word;

    czas__zmiana,
    czas__zmiana__koniec__ustawione,
    czas__zmiana__pocz¹tek__ustawione,
    czas__zmiana__ustawione
      : boolean;

    czas__zmiana__koniec,
    czas__zmiana__pocz¹tek
      : TDateTime;

    miejsce : string;
  end;
  //---//THistoria_Zapytañ_r

  TCzas_Zmiana = class
  private
    zapytania_iloœæ_g : integer;
    czas_blok_g : string;
    historia_zapytañ_r_t_g : array of THistoria_Zapytañ_r;
    function Czas_Blok_Zmiany_ZnajdŸ( napis_f : string; const czy_blok_pocz¹tku_f : boolean ) : TDateTime;
  public
    procedure Inicjuj();
    procedure Zakoñcz();

    function IsDaylightSaving( const area : string; year : word ) : boolean;
    function GetDaylightStart( const area : string; year : word ) : TDateTime;
    function GetDaylightEnd( const area : string; year : word ) : TDateTime;

    function Historia_Zapytañ_Zarz¹dzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapytañ_r_wsk;
    function Zapytania_Iloœæ_Odczytaj() : integer;
  end;
  //---//TCzas_Zmiana

const
  strona_adres_c : string = 'https://www.timeanddate.com/time/change/';
  strona_adres__rok_c : string = '?year=';

  znacznik_zmiana__brak_c : string = 'Daylight Saving Time (DST) Not Observed';
  znacznik_zmiana__pocz¹tek_c : string = 'Daylight Saving Time Start';
  znacznik_zmiana__koniec_c : string = 'Daylight Saving Time End';


implementation

uses
  Code02.HttpGet;


//Funkcja Inicjuj().
procedure TCzas_Zmiana.Inicjuj();
begin

  Self.zapytania_iloœæ_g := 0;
  Self.czas_blok_g := '';
  SetLength( Self.historia_zapytañ_r_t_g, 0 );

end;//---//Funkcja Inicjuj().

//Funkcja Zakoñcz().
procedure TCzas_Zmiana.Zakoñcz();
begin

  Self.Inicjuj();

end;//---//Funkcja Zakoñcz().

//Funkcja Czas_Blok_Zmiany_ZnajdŸ().
function TCzas_Zmiana.Czas_Blok_Zmiany_ZnajdŸ( napis_f : string; const czy_blok_pocz¹tku_f : boolean ) : TDateTime;

  //Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_ZnajdŸ().
  function Data_Dekoduj_Z_Napisu( data_s_f : string ) : TDate;
  var
    zts_l,
    dzieñ_s_l,
    miesi¹c_s_l
      : string;
    zti_l,
    dzieñ_l,
    miesi¹c_l,
    rok_l
      : integer;
  begin

    //
    // Funkcja zamieniæ napis na datê.
    //
    // Zwraca datê i czas.
    //
    // Parametry:
    //   napis_f - w postaci dd mmmmm rrrr
    //

    Result := 0;

    zti_l := Pos( ' ', data_s_f ) - 1;
    dzieñ_s_l := Copy( data_s_f, 1, zti_l );
    Delete( data_s_f, 1, zti_l + 1 );

    zti_l := Pos( ' ', data_s_f ) - 1;
    miesi¹c_s_l := AnsiLowerCase(  Copy( data_s_f, 1, zti_l )  );
    Delete( data_s_f, 1, zti_l + 1 );

    try
      dzieñ_l := StrToInt( dzieñ_s_l );
    except
      dzieñ_l := -1;
    end;
    //---//try

    try
      rok_l := StrToInt( data_s_f );
    except
      rok_l := -1;
    end;
    //---//try

    {$region 'Dekoduje miesi¹c.'}
    if   ( miesi¹c_s_l = 'styczeñ' )
      or ( miesi¹c_s_l = 'styczeñ' )
      or ( miesi¹c_s_l = '1' )
      or ( miesi¹c_s_l = '01' )
      or ( miesi¹c_s_l = 'january' ) then
      miesi¹c_l := 1
    else
    if   ( miesi¹c_s_l = 'luty' )
      or ( miesi¹c_s_l = '2' )
      or ( miesi¹c_s_l = '02' )
      or ( miesi¹c_s_l = 'february' ) then
      miesi¹c_l := 2
    else
    if   ( miesi¹c_s_l = 'marzec' )
      or ( miesi¹c_s_l = '3' )
      or ( miesi¹c_s_l = '03' )
      or ( miesi¹c_s_l = 'march' ) then
      miesi¹c_l := 3
    else
    if   ( miesi¹c_s_l = 'kwiecieñ' )
      or ( miesi¹c_s_l = 'kwiecien' )
      or ( miesi¹c_s_l = '4' )
      or ( miesi¹c_s_l = '04' )
      or ( miesi¹c_s_l = 'april' ) then
      miesi¹c_l := 4
    else
    if   ( miesi¹c_s_l = 'maj' )
      or ( miesi¹c_s_l = '5' )
      or ( miesi¹c_s_l = '05' )
      or ( miesi¹c_s_l = 'may' ) then
      miesi¹c_l := 5
    else
    if   ( miesi¹c_s_l = 'czerwiec' )
      or ( miesi¹c_s_l = '6' )
      or ( miesi¹c_s_l = '06' )
      or ( miesi¹c_s_l = 'june' ) then
      miesi¹c_l := 6
    else
    if   ( miesi¹c_s_l = 'lipiec' )
      or ( miesi¹c_s_l = '7' )
      or ( miesi¹c_s_l = '07' )
      or ( miesi¹c_s_l = 'july' ) then
      miesi¹c_l := 7
    else
    if   ( miesi¹c_s_l = 'sierpieñ' )
      or ( miesi¹c_s_l = 'sierpien' )
      or ( miesi¹c_s_l = '8' )
      or ( miesi¹c_s_l = '08' )
      or ( miesi¹c_s_l = 'august' ) then
      miesi¹c_l := 8
    else
    if   ( miesi¹c_s_l = 'wrzesieñ' )
      or ( miesi¹c_s_l = 'wrzesien' )
      or ( miesi¹c_s_l = '9' )
      or ( miesi¹c_s_l = '09' )
      or ( miesi¹c_s_l = 'september' ) then
      miesi¹c_l := 9
    else
    if   ( miesi¹c_s_l = 'paŸdziernik' )
      or ( miesi¹c_s_l = 'pazdziernik' )
      or ( miesi¹c_s_l = '10' )
      or ( miesi¹c_s_l = 'october' ) then
      miesi¹c_l := 10
    else
    if   ( miesi¹c_s_l = 'listopad' )
      or ( miesi¹c_s_l = '11' )
      or ( miesi¹c_s_l = 'november' ) then
      miesi¹c_l := 11
    else
    if   ( miesi¹c_s_l = 'grudzieñ' )
      or ( miesi¹c_s_l = 'grudzien' )
      or ( miesi¹c_s_l = '12' )
      or ( miesi¹c_s_l = 'december' ) then
      miesi¹c_l := 12
    else
      miesi¹c_l := -1;
    {$endregion 'Dekoduje miesi¹c.'}

    if   ( dzieñ_l <= 0 )
      or ( miesi¹c_l <= 0 )
      or ( rok_l <= 0 ) then
      Exit;

    Result := EncodeDate( rok_l, miesi¹c_l, dzieñ_l );

  end;//---//Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_ZnajdŸ().

var
  zti : integer;
  zts,
  data_l,
  czas_l
    : string;
  ztt : TTime;
  ztd : TDate;
begin//Funkcja Czas_Blok_Zmiany_ZnajdŸ().

  //
  // Funkcja wyszukuje blok danych z informacjami o dacie zmiany czasu.
  //
  // Zwraca blok danych z informacjami o dacie zmiany czasu.
  //
  // Parametry:
  //   napis_f
  //   czy_blok_pocz¹tku_f:
  //     false - szuka datê pocz¹tku zmiany czasu.
  //     true - szuka datê koñca zmiany czasu.
  //

  Result := 0;

  if czy_blok_pocz¹tku_f then
    zti := Pos( znacznik_zmiana__pocz¹tek_c, napis_f )
  else//if czy_blok_pocz¹tku_f then
    zti := Pos( znacznik_zmiana__koniec_c, napis_f );

  if zti <= 0 then
    Exit;


  Delete( napis_f, 1, zti );


  zts := '<br>';
  zti := Pos(  zts, AnsiLowerCase( napis_f )  );
  Delete(  napis_f, 1, zti + Length( zts ) - 1  );

  zts := ' ';
  zti := Pos(  zts, AnsiLowerCase( napis_f )  );
  Delete(  napis_f, 1, zti + Length( zts ) - 1  );


  zti := Pos( ',', napis_f ) - 1;

  data_l := Copy( napis_f, 1, zti );


  zts := '<strong>';
  zti := Pos(  zts, AnsiLowerCase( napis_f )  );
  Delete(  napis_f, 1, zti + Length( zts ) - 1  );


  zti := Pos(  AnsiLowerCase( '</strong>' ), napis_f  ) - 1;

  czas_l := Copy( napis_f, 1, zti );


  ztd := Data_Dekoduj_Z_Napisu( data_l );

  try
    ztt := StrToTime( czas_l );
  except
    on E: Exception do
      begin

        ztt := 0;
        //Application.MessageBox(   PChar(  E.Message + ' ' + IntToStr( E.HelpContext )  ), 'B³¹d', MB_OK + MB_ICONEXCLAMATION   );

      end;
    //---//on E: Exception do
  end;
  //---//try

  Result := ztd + ztt;

end;//---//Funkcja Czas_Blok_Zmiany_ZnajdŸ().

//Funkcja IsDaylightSaving().
function TCzas_Zmiana.IsDaylightSaving( const area : string; year : word ) : boolean;
var
  zt_historia_zapytañ_r_wsk_l : THistoria_Zapytañ_r_wsk;
begin

  //https://www.timeanddate.com/time/change/poland/warsaw?year=2015

  // Zmiana czasu.
  //
  //<div class="nine columns"><h2 class='mgt0'>29 mar 2015 - Daylight Saving Time Started</h2><p>When local standard time was about to reach<br>niedziela 29 marzec 2015, <strong>02:00:00</strong> clocks were turned <strong>forward</strong> 1 hour to <br>niedziela 29 marzec 2015, <strong>03:00:00</strong> local daylight time instead.</p>
  //
  //<div class="nine columns">
  //<h2 class='mgt0'>29 mar 2015 - Daylight Saving Time Started</h2>
  //  albo
  //  <h2 class='mgt0'>14 mar 2021 - Daylight Saving Time Starts</h2>
  //<p>When local standard time was about to reach<br>
  //niedziela 29 marzec 2015,
  //<strong>02:00:00</strong>
  // clocks were turned <strong>forward</strong> 1 hour to <br>niedziela 29 marzec 2015, <strong>03:00:00</strong> local daylight time instead.</p>
  //
  //<div class="nine columns"><h2 class='mgt0'>25 paz 2015 - Daylight Saving Time Ended</h2><p>When local daylight time was about to reach<br>niedziela 25 pazdziernik 2015, <strong>03:00:00</strong> clocks were turned <strong>backward</strong> 1 hour to <br>niedziela 25 pazdziernik 2015, <strong>02:00:00</strong> local standard time instead.</p>
  //
  //<div class="nine columns">
  //<h2 class='mgt0'>25 paz 2015 - Daylight Saving Time Ended</h2>
  //  albo
  //  <h2 class='mgt0'>7 lis 2021 - Daylight Saving Time Ends</h2>
  //<p>When local daylight time was about to reach<br>
  //niedziela 25 pazdziernik 2015,
  //<strong>03:00:00</strong>
  // clocks were turned <strong>backward</strong> 1 hour to <br>niedziela 25 pazdziernik 2015, <strong>02:00:00</strong> local standard time instead.</p>


  // Bez zmiany czasu.
  //
  //<h3>Daylight Saving Time (DST) Not Observed in Year 1995</h3>


  Result := false;



  zt_historia_zapytañ_r_wsk_l := Self.Historia_Zapytañ_Zarz¹dzaj( area, year );

  if zt_historia_zapytañ_r_wsk_l.czas__zmiana__ustawione then
    begin

      Result := zt_historia_zapytañ_r_wsk_l.czas__zmiana;
      Exit;

    end;
  //---//if zt_historia_zapytañ_r_wsk_l.czas__zmiana__ustawione then


  inc( Self.zapytania_iloœæ_g );

  czas_blok_g := Code02.HttpGet.TMyHttpGet.GetWebsiteContent(  strona_adres_c + area + strona_adres__rok_c + IntToStr( year )  );


  if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then
    begin

      zt_historia_zapytañ_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapytañ_r_wsk_l.czas__zmiana__ustawione := true;

      zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione := true;

      Exit;

    end;
  //---//if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then


  if    (  Pos( znacznik_zmiana__pocz¹tek_c, czas_blok_g ) > 0  )
    and (  Pos( znacznik_zmiana__koniec_c, czas_blok_g ) > 0  ) then
    begin

      Result := true;

      zt_historia_zapytañ_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapytañ_r_wsk_l.czas__zmiana__ustawione := true;


      // Od razu przeliczy pozosta³e wartoœci (opcjonalnie). //???
      if not zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione then
        begin

          zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec := Self.Czas_Blok_Zmiany_ZnajdŸ( Self.czas_blok_g, false );
          zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione := true;

        end;
      //---//if not zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione then


      if not zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione then
        begin

          zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek := Self.Czas_Blok_Zmiany_ZnajdŸ( Self.czas_blok_g, true );
          zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione := true;

        end;
      //---//if not zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione then
      //---// Od razu przeliczy pozosta³e wartoœci (opcjonalnie). //???.

      Exit;

    end;
  //---//if    (  Pos( znacznik_zmiana__pocz¹tek_c, czas_blok_g ) > 0  ) (...)
  //else
  //  B³¹d. //???

end;//---//Funkcja IsDaylightSaving().

//Funkcja GetDaylightStart().
function TCzas_Zmiana.GetDaylightStart( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapytañ_r_wsk_l : THistoria_Zapytañ_r_wsk;
begin

  Result := 0;


  zt_historia_zapytañ_r_wsk_l := Self.Historia_Zapytañ_Zarz¹dzaj( area, year );

  if zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione then
    begin

      Result := zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek;
      Exit;

    end;
  //---//if zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_ZnajdŸ( Self.czas_blok_g, true );

  zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek := Result;
  zt_historia_zapytañ_r_wsk_l.czas__zmiana__pocz¹tek__ustawione := true;

end;//---//Funkcja GetDaylightStart().

//Funkcja GetDaylightEnd().
function TCzas_Zmiana.GetDaylightEnd( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapytañ_r_wsk_l : THistoria_Zapytañ_r_wsk;
begin

  Result := 0;


  zt_historia_zapytañ_r_wsk_l := Self.Historia_Zapytañ_Zarz¹dzaj( area, year );

  if zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione then
    begin

      Result := zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec;
      Exit;

    end;
  //---//if zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_ZnajdŸ( Self.czas_blok_g, false );

  zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec := Result;
  zt_historia_zapytañ_r_wsk_l.czas__zmiana__koniec__ustawione := true;

end;//---//Funkcja GetDaylightEnd().

//Funkcja Historia_Zapytañ_Zarz¹dzaj().
function TCzas_Zmiana.Historia_Zapytañ_Zarz¹dzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapytañ_r_wsk;
var
  i : integer;
  zts : string;
begin

  //
  // Funkcja sprawdza czy jest zapamiêtane zapytanie o podane miejsce i rok.
  //
  // Zwraca rekord historii zapytañ
  //   gdy nie ma w historii zapytania wartoœæ Result.historia_brak równa siê false.
  //
  // Parametry:
  //   miejsce_f
  //   rok_f:
  //

  for i := 0 to Length( Self.historia_zapytañ_r_t_g ) - 1 do
    if    ( Self.historia_zapytañ_r_t_g[ i ].miejsce = miejsce_f )
      and ( Self.historia_zapytañ_r_t_g[ i ].rok = rok_f ) then
      begin

        Result := @Self.historia_zapytañ_r_t_g[ i ];
        Exit;

      end;
    //---//if    ( Self.historia_zapytañ_r_t_g[ i ].miejsce = miejsce_f ) (...)


  // Dodaje nowy wpis historii zapytañ i zeruje wartoœci.
  i := Length( Self.historia_zapytañ_r_t_g );
  SetLength( Self.historia_zapytañ_r_t_g, i + 1 );

  Self.historia_zapytañ_r_t_g[ i ].rok := rok_f;
  Self.historia_zapytañ_r_t_g[ i ].miejsce := miejsce_f;

  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana__koniec__ustawione := false;
  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana__pocz¹tek__ustawione := false;
  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana__ustawione := false;

  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana := false;
  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana__koniec := 0;
  Self.historia_zapytañ_r_t_g[ i ].czas__zmiana__pocz¹tek := 0;
  //---// Dodaje nowy wpis historii zapytañ i zeruje wartoœci.


  Result := @Self.historia_zapytañ_r_t_g[ i ];

end;//---//Funkcja Historia_Zapytañ_Zarz¹dzaj().

//Funkcja Historia_Zapytañ_Zarz¹dzaj().
function TCzas_Zmiana.Zapytania_Iloœæ_Odczytaj() : integer;
begin

  Result := Self.zapytania_iloœæ_g;

end;//---//Funkcja Historia_Zapytañ_Zarz¹dzaj().

end.
