unit Czas_Zmiana;

interface

uses
  System.SysUtils;

type
  THistoria_Zapyta�_r_wsk = ^THistoria_Zapyta�_r;

  THistoria_Zapyta�_r = record
    rok : word;

    czas__zmiana,
    czas__zmiana__koniec__ustawione,
    czas__zmiana__pocz�tek__ustawione,
    czas__zmiana__ustawione
      : boolean;

    czas__zmiana__koniec,
    czas__zmiana__pocz�tek
      : TDateTime;

    miejsce : string;
  end;
  //---//THistoria_Zapyta�_r

  TCzas_Zmiana = class
  private
    zapytania_ilo��_g : integer;
    czas_blok_g : string;
    historia_zapyta�_r_t_g : array of THistoria_Zapyta�_r;
    function Czas_Blok_Zmiany_Znajd�( napis_f : string; const czy_blok_pocz�tku_f : boolean ) : TDateTime;
  public
    procedure Inicjuj();
    procedure Zako�cz();

    function IsDaylightSaving( const area : string; year : word ) : boolean;
    function GetDaylightStart( const area : string; year : word ) : TDateTime;
    function GetDaylightEnd( const area : string; year : word ) : TDateTime;

    function Historia_Zapyta�_Zarz�dzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapyta�_r_wsk;
    function Zapytania_Ilo��_Odczytaj() : integer;
  end;
  //---//TCzas_Zmiana

const
  strona_adres_c : string = 'https://www.timeanddate.com/time/change/';
  strona_adres__rok_c : string = '?year=';

  znacznik_zmiana__brak_c : string = 'Daylight Saving Time (DST) Not Observed';
  znacznik_zmiana__pocz�tek_c : string = 'Daylight Saving Time Start';
  znacznik_zmiana__koniec_c : string = 'Daylight Saving Time End';


implementation

uses
  Code02.HttpGet;


//Funkcja Inicjuj().
procedure TCzas_Zmiana.Inicjuj();
begin

  Self.zapytania_ilo��_g := 0;
  Self.czas_blok_g := '';
  SetLength( Self.historia_zapyta�_r_t_g, 0 );

end;//---//Funkcja Inicjuj().

//Funkcja Zako�cz().
procedure TCzas_Zmiana.Zako�cz();
begin

  Self.Inicjuj();

end;//---//Funkcja Zako�cz().

//Funkcja Czas_Blok_Zmiany_Znajd�().
function TCzas_Zmiana.Czas_Blok_Zmiany_Znajd�( napis_f : string; const czy_blok_pocz�tku_f : boolean ) : TDateTime;

  //Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_Znajd�().
  function Data_Dekoduj_Z_Napisu( data_s_f : string ) : TDate;
  var
    zts_l,
    dzie�_s_l,
    miesi�c_s_l
      : string;
    zti_l,
    dzie�_l,
    miesi�c_l,
    rok_l
      : integer;
  begin

    //
    // Funkcja zamieni� napis na dat�.
    //
    // Zwraca dat� i czas.
    //
    // Parametry:
    //   napis_f - w postaci dd mmmmm rrrr
    //

    Result := 0;

    zti_l := Pos( ' ', data_s_f ) - 1;
    dzie�_s_l := Copy( data_s_f, 1, zti_l );
    Delete( data_s_f, 1, zti_l + 1 );

    zti_l := Pos( ' ', data_s_f ) - 1;
    miesi�c_s_l := AnsiLowerCase(  Copy( data_s_f, 1, zti_l )  );
    Delete( data_s_f, 1, zti_l + 1 );

    try
      dzie�_l := StrToInt( dzie�_s_l );
    except
      dzie�_l := -1;
    end;
    //---//try

    try
      rok_l := StrToInt( data_s_f );
    except
      rok_l := -1;
    end;
    //---//try

    {$region 'Dekoduje miesi�c.'}
    if   ( miesi�c_s_l = 'stycze�' )
      or ( miesi�c_s_l = 'stycze�' )
      or ( miesi�c_s_l = '1' )
      or ( miesi�c_s_l = '01' )
      or ( miesi�c_s_l = 'january' ) then
      miesi�c_l := 1
    else
    if   ( miesi�c_s_l = 'luty' )
      or ( miesi�c_s_l = '2' )
      or ( miesi�c_s_l = '02' )
      or ( miesi�c_s_l = 'february' ) then
      miesi�c_l := 2
    else
    if   ( miesi�c_s_l = 'marzec' )
      or ( miesi�c_s_l = '3' )
      or ( miesi�c_s_l = '03' )
      or ( miesi�c_s_l = 'march' ) then
      miesi�c_l := 3
    else
    if   ( miesi�c_s_l = 'kwiecie�' )
      or ( miesi�c_s_l = 'kwiecien' )
      or ( miesi�c_s_l = '4' )
      or ( miesi�c_s_l = '04' )
      or ( miesi�c_s_l = 'april' ) then
      miesi�c_l := 4
    else
    if   ( miesi�c_s_l = 'maj' )
      or ( miesi�c_s_l = '5' )
      or ( miesi�c_s_l = '05' )
      or ( miesi�c_s_l = 'may' ) then
      miesi�c_l := 5
    else
    if   ( miesi�c_s_l = 'czerwiec' )
      or ( miesi�c_s_l = '6' )
      or ( miesi�c_s_l = '06' )
      or ( miesi�c_s_l = 'june' ) then
      miesi�c_l := 6
    else
    if   ( miesi�c_s_l = 'lipiec' )
      or ( miesi�c_s_l = '7' )
      or ( miesi�c_s_l = '07' )
      or ( miesi�c_s_l = 'july' ) then
      miesi�c_l := 7
    else
    if   ( miesi�c_s_l = 'sierpie�' )
      or ( miesi�c_s_l = 'sierpien' )
      or ( miesi�c_s_l = '8' )
      or ( miesi�c_s_l = '08' )
      or ( miesi�c_s_l = 'august' ) then
      miesi�c_l := 8
    else
    if   ( miesi�c_s_l = 'wrzesie�' )
      or ( miesi�c_s_l = 'wrzesien' )
      or ( miesi�c_s_l = '9' )
      or ( miesi�c_s_l = '09' )
      or ( miesi�c_s_l = 'september' ) then
      miesi�c_l := 9
    else
    if   ( miesi�c_s_l = 'pa�dziernik' )
      or ( miesi�c_s_l = 'pazdziernik' )
      or ( miesi�c_s_l = '10' )
      or ( miesi�c_s_l = 'october' ) then
      miesi�c_l := 10
    else
    if   ( miesi�c_s_l = 'listopad' )
      or ( miesi�c_s_l = '11' )
      or ( miesi�c_s_l = 'november' ) then
      miesi�c_l := 11
    else
    if   ( miesi�c_s_l = 'grudzie�' )
      or ( miesi�c_s_l = 'grudzien' )
      or ( miesi�c_s_l = '12' )
      or ( miesi�c_s_l = 'december' ) then
      miesi�c_l := 12
    else
      miesi�c_l := -1;
    {$endregion 'Dekoduje miesi�c.'}

    if   ( dzie�_l <= 0 )
      or ( miesi�c_l <= 0 )
      or ( rok_l <= 0 ) then
      Exit;

    Result := EncodeDate( rok_l, miesi�c_l, dzie�_l );

  end;//---//Funkcja Data_Dekoduj_Z_Napisu() w Czas_Blok_Zmiany_Znajd�().

var
  zti : integer;
  zts,
  data_l,
  czas_l
    : string;
  ztt : TTime;
  ztd : TDate;
begin//Funkcja Czas_Blok_Zmiany_Znajd�().

  //
  // Funkcja wyszukuje blok danych z informacjami o dacie zmiany czasu.
  //
  // Zwraca blok danych z informacjami o dacie zmiany czasu.
  //
  // Parametry:
  //   napis_f
  //   czy_blok_pocz�tku_f:
  //     false - szuka dat� pocz�tku zmiany czasu.
  //     true - szuka dat� ko�ca zmiany czasu.
  //

  Result := 0;

  if czy_blok_pocz�tku_f then
    zti := Pos( znacznik_zmiana__pocz�tek_c, napis_f )
  else//if czy_blok_pocz�tku_f then
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

end;//---//Funkcja Czas_Blok_Zmiany_Znajd�().

//Funkcja IsDaylightSaving().
function TCzas_Zmiana.IsDaylightSaving( const area : string; year : word ) : boolean;
var
  zt_historia_zapyta�_r_wsk_l : THistoria_Zapyta�_r_wsk;
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



  zt_historia_zapyta�_r_wsk_l := Self.Historia_Zapyta�_Zarz�dzaj( area, year );

  if zt_historia_zapyta�_r_wsk_l.czas__zmiana__ustawione then
    begin

      Result := zt_historia_zapyta�_r_wsk_l.czas__zmiana;
      Exit;

    end;
  //---//if zt_historia_zapyta�_r_wsk_l.czas__zmiana__ustawione then


  inc( Self.zapytania_ilo��_g );

  czas_blok_g := Code02.HttpGet.TMyHttpGet.GetWebsiteContent(  strona_adres_c + area + strona_adres__rok_c + IntToStr( year )  );


  if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then
    begin

      zt_historia_zapyta�_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapyta�_r_wsk_l.czas__zmiana__ustawione := true;

      zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione := true;

      Exit;

    end;
  //---//if Pos( znacznik_zmiana__brak_c, czas_blok_g ) > 0 then


  if    (  Pos( znacznik_zmiana__pocz�tek_c, czas_blok_g ) > 0  )
    and (  Pos( znacznik_zmiana__koniec_c, czas_blok_g ) > 0  ) then
    begin

      Result := true;

      zt_historia_zapyta�_r_wsk_l.czas__zmiana := Result;
      zt_historia_zapyta�_r_wsk_l.czas__zmiana__ustawione := true;


      // Od razu przeliczy pozosta�e warto�ci (opcjonalnie). //???
      if not zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione then
        begin

          zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec := Self.Czas_Blok_Zmiany_Znajd�( Self.czas_blok_g, false );
          zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione := true;

        end;
      //---//if not zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione then


      if not zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione then
        begin

          zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek := Self.Czas_Blok_Zmiany_Znajd�( Self.czas_blok_g, true );
          zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione := true;

        end;
      //---//if not zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione then
      //---// Od razu przeliczy pozosta�e warto�ci (opcjonalnie). //???.

      Exit;

    end;
  //---//if    (  Pos( znacznik_zmiana__pocz�tek_c, czas_blok_g ) > 0  ) (...)
  //else
  //  B��d. //???

end;//---//Funkcja IsDaylightSaving().

//Funkcja GetDaylightStart().
function TCzas_Zmiana.GetDaylightStart( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapyta�_r_wsk_l : THistoria_Zapyta�_r_wsk;
begin

  Result := 0;


  zt_historia_zapyta�_r_wsk_l := Self.Historia_Zapyta�_Zarz�dzaj( area, year );

  if zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione then
    begin

      Result := zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek;
      Exit;

    end;
  //---//if zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_Znajd�( Self.czas_blok_g, true );

  zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek := Result;
  zt_historia_zapyta�_r_wsk_l.czas__zmiana__pocz�tek__ustawione := true;

end;//---//Funkcja GetDaylightStart().

//Funkcja GetDaylightEnd().
function TCzas_Zmiana.GetDaylightEnd( const area : string; year : word ) : TDateTime;
var
  zts : string;
  zt_historia_zapyta�_r_wsk_l : THistoria_Zapyta�_r_wsk;
begin

  Result := 0;


  zt_historia_zapyta�_r_wsk_l := Self.Historia_Zapyta�_Zarz�dzaj( area, year );

  if zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione then
    begin

      Result := zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec;
      Exit;

    end;
  //---//if zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione then


  if not IsDaylightSaving( area, year ) then
    begin

      zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione := true;
      Exit;

    end;
  //---//if not IsDaylightSaving( area, year ) then


  if Trim( Self.czas_blok_g ) = '' then
    Exit;


  Result := Self.Czas_Blok_Zmiany_Znajd�( Self.czas_blok_g, false );

  zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec := Result;
  zt_historia_zapyta�_r_wsk_l.czas__zmiana__koniec__ustawione := true;

end;//---//Funkcja GetDaylightEnd().

//Funkcja Historia_Zapyta�_Zarz�dzaj().
function TCzas_Zmiana.Historia_Zapyta�_Zarz�dzaj( const miejsce_f : string; rok_f : word ) : THistoria_Zapyta�_r_wsk;
var
  i : integer;
  zts : string;
begin

  //
  // Funkcja sprawdza czy jest zapami�tane zapytanie o podane miejsce i rok.
  //
  // Zwraca rekord historii zapyta�
  //   gdy nie ma w historii zapytania warto�� Result.historia_brak r�wna si� false.
  //
  // Parametry:
  //   miejsce_f
  //   rok_f:
  //

  for i := 0 to Length( Self.historia_zapyta�_r_t_g ) - 1 do
    if    ( Self.historia_zapyta�_r_t_g[ i ].miejsce = miejsce_f )
      and ( Self.historia_zapyta�_r_t_g[ i ].rok = rok_f ) then
      begin

        Result := @Self.historia_zapyta�_r_t_g[ i ];
        Exit;

      end;
    //---//if    ( Self.historia_zapyta�_r_t_g[ i ].miejsce = miejsce_f ) (...)


  // Dodaje nowy wpis historii zapyta� i zeruje warto�ci.
  i := Length( Self.historia_zapyta�_r_t_g );
  SetLength( Self.historia_zapyta�_r_t_g, i + 1 );

  Self.historia_zapyta�_r_t_g[ i ].rok := rok_f;
  Self.historia_zapyta�_r_t_g[ i ].miejsce := miejsce_f;

  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana__koniec__ustawione := false;
  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana__pocz�tek__ustawione := false;
  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana__ustawione := false;

  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana := false;
  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana__koniec := 0;
  Self.historia_zapyta�_r_t_g[ i ].czas__zmiana__pocz�tek := 0;
  //---// Dodaje nowy wpis historii zapyta� i zeruje warto�ci.


  Result := @Self.historia_zapyta�_r_t_g[ i ];

end;//---//Funkcja Historia_Zapyta�_Zarz�dzaj().

//Funkcja Historia_Zapyta�_Zarz�dzaj().
function TCzas_Zmiana.Zapytania_Ilo��_Odczytaj() : integer;
begin

  Result := Self.zapytania_ilo��_g;

end;//---//Funkcja Historia_Zapyta�_Zarz�dzaj().

end.
