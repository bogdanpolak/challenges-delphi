unit Code02.Ongakw.Czas_Zmiana;

interface

uses
  System.SysUtils;

type
  THistoria_Zapytan_r_wsk = ^THistoria_Zapytan_r;

  THistoria_Zapytan_r = record
    rok : word;

    czas__zmiana,
    czas__zmiana__koniec__ustawione,
    czas__zmiana__poczatek__ustawione,
    czas__zmiana__ustawione
      : boolean;

    czas__zmiana__koniec,
    czas__zmiana__poczatek
      : TDateTime;

    miejsce : string;
  end;
  //---//THistoria_Zapytan_r

  TCzas_Zmiana = class
  private
    zapytania_ilosc_g : integer;
    czas_blok_g : string;
    historia_zapytan_r_t_g : array of THistoria_Zapytan_r;
    function Czas_Blok_Zmiany_Znajdz( napis_f : string; const czy_blok_poczatku_f : boolean ) : TDateTime;
  public
    procedure Inicjuj();
    procedure Zakoncz();

    function IsDaylightSaving( const area : string; year : word ) : boolean;
    function GetDaylightStart( const area : string; year : word ) : TDateTime;
    function GetDaylightEnd( const area : string; year : word ) : TDateTime;

    function Historia_Zapytan_Zarzadzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapytan_r_wsk;
    function Zapytania_Ilosc_Odczytaj() : integer;
  end;
  //---//TCzas_Zmiana

const
  strona_adres_c : string = 'https://www.timeanddate.com/time/change/';
  strona_adres__rok_c : string = '?year=';

  znacznik_zmiana__brak_c : string = 'Daylight Saving Time (DST) Not Observed';
  znacznik_zmiana__poczatek_c : string = 'Daylight Saving Time Start';
  znacznik_zmiana__koniec_c : string = 'Daylight Saving Time End';


implementation

uses
  Code02.HttpGet;


//Funkcja Inicjuj().
procedure TCzas_Zmiana.Inicjuj();
begin

  Self.zapytania_ilosc_g := 0;
  Self.czas_blok_g := '';
  SetLength( Self.historia_zapytan_r_t_g, 0 );

end;//---//Funkcja Inicjuj().

//Funkcja Zakoncz().
procedure TCzas_Zmiana.Zakoncz();
begin

  Self.Inicjuj();

end;//---//Funkcja Zako�cz().

//Funkcja Czas_Blok_Zmiany_Znajdn().
function TCzas_Zmiana.Czas_Blok_Zmiany_Znajdz( napis_f : string; const czy_blok_poczatku_f : boolean ) : TDateTime;

  //Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_Znajd�().
  function Data_Dekoduj_Z_Napisu( data_s_f : string ) : TDate;
  var
    zts_l,
    dzien_s_l,
    miesiac_s_l
      : string;
    zti_l,
    dzien_l,
    miesiac_l,
    rok_l
      : integer;
  begin

    //
    // Funkcja zamienia napis na datę.
    //
    // Zwraca datę i czas.
    //
    // Parametry:
    //   napis_f - w postaci dd mmmmm rrrr
    //

    Result := 0;

    zti_l := Pos( ' ', data_s_f ) - 1;
    dzien_s_l := Copy( data_s_f, 1, zti_l );
    Delete( data_s_f, 1, zti_l + 1 );

    zti_l := Pos( ' ', data_s_f ) - 1;
    miesiac_s_l := AnsiLowerCase(  Copy( data_s_f, 1, zti_l )  );
    Delete( data_s_f, 1, zti_l + 1 );

    try
      dzien_l := StrToInt( dzien_s_l );
    except
      dzien_l := -1;
    end;
    //---//try

    try
      rok_l := StrToInt( data_s_f );
    except
      rok_l := -1;
    end;
    //---//try

    {$region 'Dekoduje miesiąc.'}
    if   ( miesiac_s_l = 'styczeń' )
      or ( miesiac_s_l = 'styczen' )
      or ( miesiac_s_l = '1' )
      or ( miesiac_s_l = '01' )
      or ( miesiac_s_l = 'january' ) then
      miesiac_l := 1
    else
    if   ( miesiac_s_l = 'luty' )
      or ( miesiac_s_l = '2' )
      or ( miesiac_s_l = '02' )
      or ( miesiac_s_l = 'february' ) then
      miesiac_l := 2
    else
    if   ( miesiac_s_l = 'marzec' )
      or ( miesiac_s_l = '3' )
      or ( miesiac_s_l = '03' )
      or ( miesiac_s_l = 'march' ) then
      miesiac_l := 3
    else
    if   ( miesiac_s_l = 'kwiecień' )
      or ( miesiac_s_l = 'kwiecien' )
      or ( miesiac_s_l = '4' )
      or ( miesiac_s_l = '04' )
      or ( miesiac_s_l = 'april' ) then
      miesiac_l := 4
    else
    if   ( miesiac_s_l = 'maj' )
      or ( miesiac_s_l = '5' )
      or ( miesiac_s_l = '05' )
      or ( miesiac_s_l = 'may' ) then
      miesiac_l := 5
    else
    if   ( miesiac_s_l = 'czerwiec' )
      or ( miesiac_s_l = '6' )
      or ( miesiac_s_l = '06' )
      or ( miesiac_s_l = 'june' ) then
      miesiac_l := 6
    else
    if   ( miesiac_s_l = 'lipiec' )
      or ( miesiac_s_l = '7' )
      or ( miesiac_s_l = '07' )
      or ( miesiac_s_l = 'july' ) then
      miesiac_l := 7
    else
    if   ( miesiac_s_l = 'sierpień' )
      or ( miesiac_s_l = 'sierpien' )
      or ( miesiac_s_l = '8' )
      or ( miesiac_s_l = '08' )
      or ( miesiac_s_l = 'august' ) then
      miesiac_l := 8
    else
    if   ( miesiac_s_l = 'wrzesień' )
      or ( miesiac_s_l = 'wrzesien' )
      or ( miesiac_s_l = '9' )
      or ( miesiac_s_l = '09' )
      or ( miesiac_s_l = 'september' ) then
      miesiac_l := 9
    else
    if   ( miesiac_s_l = 'październik' )
      or ( miesiac_s_l = 'pazdziernik' )
      or ( miesiac_s_l = '10' )
      or ( miesiac_s_l = 'october' ) then
      miesiac_l := 10
    else
    if   ( miesiac_s_l = 'listopad' )
      or ( miesiac_s_l = '11' )
      or ( miesiac_s_l = 'november' ) then
      miesiac_l := 11
    else
    if   ( miesiac_s_l = 'grudzień' )
      or ( miesiac_s_l = 'grudzien' )
      or ( miesiac_s_l = '12' )
      or ( miesiac_s_l = 'december' ) then
      miesiac_l := 12
    else
      miesiac_l := -1;
    {$endregion 'Dekoduje miesi�c.'}

    if   ( dzien_l <= 0 )
      or ( miesiac_l <= 0 )
      or ( rok_l <= 0 ) then
      Exit;

    Result := EncodeDate( rok_l, miesiac_l, dzien_l );

  end;//---//Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_Znajd�().

var
  zti : integer;
  zts,
  data_l,
  czas_l
    : string;
  ztt : TTime;
  ztd : TDate;
begin//Funkcja Czas_Blok_Zmiany_Znajdn().

  //
  // Funkcja wyszukuje blok danych z informacjami o dacie zmiany czasu.
  //
  // Zwraca blok danych z informacjami o dacie zmiany czasu.
  //
  // Parametry:
  //   napis_f
  //   czy_blok_poczatku_f:
  //     false - szuka daty początku zmiany czasu.
  //     true - szuka daty końca zmiany czasu.
  //

  Result := 0;

  if czy_blok_poczatku_f then
    zti := Pos( znacznik_zmiana__poczatek_c, napis_f )
  else//if czy_blok_początku_f then
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
        //Application.MessageBox(   PChar(  E.Message + ' ' + IntToStr( E.HelpContext )  ), 'B��d', MB_OK + MB_ICONEXCLAMATION   );

      end;
    //---//on E: Exception do
  end;
  //---//try

  Result := ztd + ztt;

end;//---//Funkcja Czas_Blok_Zmiany_Znajdn().

//Funkcja IsDaylightSaving().
function TCzas_Zmiana.IsDaylightSaving( const area : string; year : word ) : boolean;
var
  zt_historia_zapytan_r_wsk_l : THistoria_Zapytan_r_wsk;
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



  zt_historia_zapytan_r_wsk_l := Self.Historia_Zapytan_Zarzadzaj( area, year );

  if zt_historia_zapytan_r_wsk_l.czas__zmiana__ustawione then
    begin

      Result := zt_historia_zapytan_r_wsk_l.czas__zmiana;
      Exit;

    end;
  //---//if zt_historia_zapytan_r_wsk_l.czas__zmiana__ustawione then


  inc( Self.zapytania_ilosc_g );

  czas_blok_g := Code02.HttpGet.TMyHttpGet.GetWebsiteContent(  strona_adres_c + area + strona_adres__rok_c + IntToStr( year )  );


  if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then
    begin

      zt_historia_zapytan_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapytan_r_wsk_l.czas__zmiana__ustawione := true;

      zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione := true;

      Exit;

    end;
  //---//if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then


  if    (  Pos( znacznik_zmiana__poczatek_c, czas_blok_g ) > 0  )
    and (  Pos( znacznik_zmiana__koniec_c, czas_blok_g ) > 0  ) then
    begin

      Result := true;

      zt_historia_zapytan_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapytan_r_wsk_l.czas__zmiana__ustawione := true;


      // Od razu przeliczy pozostałe wartości (opcjonalnie). //???
      if not zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione then
        begin

          zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec := Self.Czas_Blok_Zmiany_Znajdz( Self.czas_blok_g, false );
          zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione := true;

        end;
      //---//if not zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione then


      if not zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione then
        begin

          zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek := Self.Czas_Blok_Zmiany_Znajdz( Self.czas_blok_g, true );
          zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione := true;

        end;
      //---//if not zt_historia_zapytan_r_wsk_l.czas__zmiana__pocz�tek__ustawione then
      //---// Od razu przeliczy pozostałe wartości (opcjonalnie). //???.

      Exit;

    end;
  //---//if    (  Pos( znacznik_zmiana__pocz�tek_c, czas_blok_g ) > 0  ) (...)
  //else
  //  Błąd. //???

end;//---//Funkcja IsDaylightSaving().

//Funkcja GetDaylightStart().
function TCzas_Zmiana.GetDaylightStart( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapytan_r_wsk_l : THistoria_Zapytan_r_wsk;
begin

  Result := 0;


  zt_historia_zapytan_r_wsk_l := Self.Historia_Zapytan_Zarzadzaj( area, year );

  if zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione then
    begin

      Result := zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek;
      Exit;

    end;
  //---//if zt_historia_zapytan_r_wsk_l.czas__zmiana__pocz�tek__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_Znajdz( Self.czas_blok_g, true );

  zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek := Result;
  zt_historia_zapytan_r_wsk_l.czas__zmiana__poczatek__ustawione := true;

end;//---//Funkcja GetDaylightStart().

//Funkcja GetDaylightEnd().
function TCzas_Zmiana.GetDaylightEnd( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapytan_r_wsk_l : THistoria_Zapytan_r_wsk;
begin

  Result := 0;


  zt_historia_zapytan_r_wsk_l := Self.Historia_Zapytan_Zarzadzaj( area, year );

  if zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione then
    begin

      Result := zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec;
      Exit;

    end;
  //---//if zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_Znajdz( Self.czas_blok_g, false );

  zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec := Result;
  zt_historia_zapytan_r_wsk_l.czas__zmiana__koniec__ustawione := true;

end;//---//Funkcja GetDaylightEnd().

//Funkcja Historia_Zapytan_Zarzadzaj().
function TCzas_Zmiana.Historia_Zapytan_Zarzadzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapytan_r_wsk;
var
  i : integer;
  zts : string;
begin

  //
  // Funkcja sprawdza czy jest zapamiętane zapytanie o podane miejsce i rok.
  //
  // Zwraca rekord historii zapytań
  //   gdy nie ma w historii zapytania wartość Result.historia_brak równa się false.
  //
  // Parametry:
  //   miejsce_f
  //   rok_f:
  //

  for i := 0 to Length( Self.historia_zapytan_r_t_g ) - 1 do
    if    ( Self.historia_zapytan_r_t_g[ i ].miejsce = miejsce_f )
      and ( Self.historia_zapytan_r_t_g[ i ].rok = rok_f ) then
      begin

        Result := @Self.historia_zapytan_r_t_g[ i ];
        Exit;

      end;
    //---//if    ( Self.historia_zapyta�_r_t_g[ i ].miejsce = miejsce_f ) (...)


  // Dodaje nowy wpis historii zapytan i zeruje wartości.
  i := Length( Self.historia_zapytan_r_t_g );
  SetLength( Self.historia_zapytan_r_t_g, i + 1 );

  Self.historia_zapytan_r_t_g[ i ].rok := rok_f;
  Self.historia_zapytan_r_t_g[ i ].miejsce := miejsce_f;

  Self.historia_zapytan_r_t_g[ i ].czas__zmiana__koniec__ustawione := false;
  Self.historia_zapytan_r_t_g[ i ].czas__zmiana__poczatek__ustawione := false;
  Self.historia_zapytan_r_t_g[ i ].czas__zmiana__ustawione := false;

  Self.historia_zapytan_r_t_g[ i ].czas__zmiana := false;
  Self.historia_zapytan_r_t_g[ i ].czas__zmiana__koniec := 0;
  Self.historia_zapytan_r_t_g[ i ].czas__zmiana__poczatek := 0;
  //---// Dodaje nowy wpis historii zapyta� i zeruje warto�ci.


  Result := @Self.historia_zapytan_r_t_g[ i ];

end;//---//Funkcja Historia_Zapyta�_Zarz�dzaj().

//Funkcja Historia_Zapyta�_Zarz�dzaj().
function TCzas_Zmiana.Zapytania_Ilosc_Odczytaj() : integer;
begin

  Result := Self.zapytania_ilosc_g;

end;//---//Funkcja Historia_Zapyta�_Zarz�dzaj().

end.
