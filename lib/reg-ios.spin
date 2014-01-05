{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Ingo Kripahle                                                                                 │
│ Copyright (c) 2010 Ingo Kripahle                                                                     │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : drohne235@googlemail.com
System          : TriOS
Name            : [I]nput-[O]utput-[S]ystem - System-API
Chip            : Regnatix
Typ             : Objekt
Version         : 01
Subversion      : 2
Funktion        : System-API - Schnittstelle der Anwendungen zu allen Systemfunktionen

Regnatix
                  system        : Systemübergreifende Routinen
                  loader        : Routinen um BIN-Dateien zu laden
                  ramdisk       : Strukturierte Speicherverwaltung/Ramdisk
                  eram          : Einfache Speicherverwaltung: Usermem
                  bus           : Kommunikation zu Administra und Bellatrix

Administra
                  sd-card       : FAT16 Dateisystem auf SD-Card
                  scr           : Screeninterface
                  hss           : Hydra-Soundsystem
                  sfx           : Sound-FX

Bellatrix
                  key           : Keyboardroutinen
                  screen        : Bildschirmsteuerung
                  g0            : grafikmodus 0,TV-Modus 256 x 192 Pixel, Vektorengine

Komponenten     : -
COG's           : -
Logbuch         :

19-11-2008-dr235  - erste version aus dem ispin-projekt extrahiert
13-03-2009-dr235  - string für parameterübergabe zwischen programmen im eram eingerichtet
26-03-2010-dr235  - errormeldungen entfernt (mount)
05-08-2010-dr235  - speicherverwaltung für eram eingefügt
18-09-2010-dr235  - fehler in bus_init behoben: erste eram-zelle wurde gelöscht durch falsche initialisierung
25-11-2011-dr235  - funktionsset für grafikmodus 0 eingefügt
28-11-2011-dr235  - sfx_keyoff, sfx_stop eingefügt
01-12-2011-dr235  - printq zugefügt: ausgabe einer zeichenkette ohne steuerzeichen
25-01-2012-dr235  - korrektur char_ter_bs
06-04-2012-dr235  - fehler in g0_printdec behoben
14-11-2012-uheld  - window-funktionen eingefügt, ansatzweise globale konstanten ausgelagert
15-04-2013-dr235  - konstanten für bellatrix-funktionen komplett ausgelagert

Notizen         :

 --------------------------------------------------------------------------------------------------------- }}

OBJ

        gc:   "glob-con"

CON 'Signaldefinitionen
'signaldefinition regnatix
#0,     D0,D1,D2,D3,D4,D5,D6,D7                         'datenbus
#8,     A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10               'adressbus
#19,    REG_RAM1,REG_RAM2                               'selektionssignale rambank 1 und 2
#21,    REG_PROP1,REG_PROP2                             'selektionssignale für administra und bellatrix
#23,    REG_AL                                          'strobesignal für adresslatch
#24,    HBEAT                                           'front-led
        BUSCLK                                          'bustakt
        BUS_WR                                          '/wr - schreibsignal
        BUS_HS '                                        '/hs - quittungssignal

CON 'Zeichencodes
'zeichencodes
CHAR_RETURN     = $0D                                   'eingabezeichen
CHAR_NL         = $0D                                   'newline
CHAR_SPACE      = $20                                   'leerzeichen
CHAR_BS         = $08                                   'tastaturcode backspace
CHAR_TER_BS     = $08                                   'terminalcode backspace
CHAR_ESC        = $1B

KEY_CTRL        = $02
KEY_ALT         = $04
KEY_OS          = $08

KEY_CURUP       = 04
KEY_CURDOWN     = 05
KEY_CURLEFT     = 02
KEY_CURRIGHT    = 03

CON 'Systemvariablen
'systemvariablen

LOADERPTR       = $0FFFFF   - 4                         'Zeiger auf Loader-Register im hRAM
MAGIC           = LOADERPTR - 1                         'Warmstartflag
SIFLAG          = MAGIC     - 1                         'Screeninit-Flag
BELDRIVE        = SIFLAG    - 12                        'Dateiname aktueller Grafiktreiber
PARAM           = BELDRIVE  - 65                        'Parameterstring
TIB2            = PARAM     - 65
RAMDRV          = TIB2      - 1                         'Ramdrive-Flag
RAMEND          = RAMDRV    - 4                         'Zeiger auf oberstes freies Byte (einfache Speicherverwaltung)
RAMBAS          = RAMEND    - 4                         'Zeiger auf unterstes freies Byte (einfache Speicherverwaltung)

SYSVAR          = RAMBAS    - 1                         'Adresse des obersten freien Bytes, darüber folgen Systemvariablen

{
LOADERPTR       = $0FFFFB       '4 Byte                 'Zeiger auf Loader-Register im hRAM
MAGIC           = $0FFFFA       '1 Byte                 'Warmstartflag
SIFLAG          = $0FFFF9       '1 byte                 'Screeninit-Flag
BELDRIVE        = $0FFFED       '12 Byte                'Dateiname aktueller Grafiktreiber
PARAM           = $0FFFAD       '64 Byte                'Parameterstring
RAMDRV          = $0FFFAC       '1 Byte                 'Ramdrive-Flag
RAMEND          = $0FFFA8       '4 Byte                 'Zeiger auf oberstes freies Byte (einfache Speicherverwaltung)
RAMBAS          = $0FFFA4       '4 Byte                 'Zeiger auf unterstes freies Byte (einfache Speicherverwaltung)

SYSVAR          = $0FFFA3                               'Adresse des obersten freien Bytes, darüber folgen Systemvariablen
}
CON 'Sonstiges
CNT_HBEAT       = 5_000_0000                            'blinkgeschw. front-led
DB_IN           = %00000111_11111111_11111111_00000000  'maske: dbus-eingabe
DB_OUT          = %00000111_11111111_11111111_11111111  'maske: dbus-ausgabe

OS_TIBLEN       = 64                                    'größe des inputbuffers
ERAM            = 1024 * 512 * 2                        'größe eram
HRAM            = 1024 * 32                             'größe hram

RMON_ZEILEN     = 16                                    'speichermonitor - angezeigte zeilen
RMON_BYTES      = 8                                     'speichermonitor - zeichen pro byte

STRCOUNT        = 64                                    'größe des stringpuffers

VGA             = 0
TV              = 1

CON 'ADMINISTRA-FUNKTIONEN --------------------------------------------------------------------------

'soundeinstellungen
#0,     SND_HSSOFF
        SND_HSSON
        SND_WAVOFF
        SND_WAVON


#0,     NVRAM_LANG
#0,       LANG_DE
          LANG_EN

#1,     NVRAM_DATEFORMAT
#0,       DATEFORMAT_DE         'DD.MM.YYY    (DE DIN 1355-1)
          DATEFORMAT_CANONICAL  'YYYY-MM-DD   (ISO 8601)
          DATEFORMAT_UK         'DD/MM/YYYY
          DATEFORMAT_US         'MM/DD/YYYY

#2,     NVRAM_TIMEFORMAT
#0,       TIMEFORMAT_24         'HH:MM:SS
          TIMEFORMAT_12         'HH:MM:SS[PM|AM]
          TIMEFORMAT_12UK       'HH.MM.SS[PM|AM]

'dateiattribute
#0,     F_SIZE
        F_CRDAY
        F_CRMONTH
        F_CRYEAR
        F_CRSEC
        F_CRMIN
        F_CRHOUR
        F_ADAY
        F_AMONTH
        F_AYEAR
        F_CDAY
        F_CMONTH
        F_CYEAR
        F_CSEC
        F_CMIN
        F_CHOUR
        F_READONLY
        F_HIDDEN
        F_SYSTEM
        F_DIR
        F_ARCHIV

'dir-marker
#0,     DM_ROOT
        DM_SYSTEM
        DM_USER
        DM_A
        DM_B
        DM_C

'interface zum hss-player
#0,     iEndFlag                                        'Repeat oder Ende wurde erreicht
        iRowFlag                                        'Flag das Songzeile fertig ist
        iEngineC                                        'Patternzähler
        iBeatC                                          'Beatzähler
        iRepeat                                         'zähler für loops
#5,     iChannel
#5,     iChannel1
#10,    iChannel2
#15,    iChannel3
#20,    iChannel4
#0,     iNote
        iOktave
        iVolume
        iEffekt
        iInstrument


CON 'BELLATRIX-FUNKTIONEN --------------------------------------------------------------------------

'                   +----------
'                   |  +------- system     
'                   |  |  +---- version    (änderungen)
'                   |  |  |  +- subversion (hinzufügungen)
CHIP_VER        = $00_01_01_02
'
'                                           +---------- 
'                                           | +-------- 
'                                           | |+------- 
'                                           | ||+------ 
'                                           | |||+----- 
'                                           | ||||+---- 
'                                           | |||||+--- 
'                                           | ||||||+-- multi
'                                           | |||||||+- loader
CHIP_SPEC       = %00000000_00000000_00000000_00000001

LIGHTBLUE       = 0
YELLOW          = 1
RED             = 2
GREEN           = 3
BLUE_REVERSE    = 4
WHITE           = 5
RED_INVERSE     = 6
MAGENTA         = 7

' konstante parameter für die sidcog's

scog_pal        = 985248.0
scog_ntsc       = 1022727.0
scog_maxf       = 1031000.0
scog_triangle   = 16
scog_saw        = 32
scog_square     = 64
scog_noise      = 128


VAR
        long lflagadr                                   'adresse des loaderflag
        long rbas                                       'einfaches speichermodell: virtuelle startadresse
        long rend                                       'einfaches speichermodell: speicherende
        byte dname[16]                                  'puffer für dateiname
        byte strpuffer[STRCOUNT]                        'stringpuffer
        byte parapos                                    'position im parameterstring

PUB start: wflag | i                                    'system: ios initialisieren
''funktionsgruppe               : system
''funktion                      : ios initialisieren
''eingabe                       : -
''ausgabe                       : wflag - 0: kaltstart
''                              :         1: warmstart
''busprotokoll                  : -

  bus_init                                              'bus initialisieren

  sddmact(DM_USER)                                      'wieder in userverzeichnis wechseln
  lflagadr := ram_rdlong(sysmod,LOADERPTR)              'adresse der loader-register setzen
  
  if ram_rdbyte(sysmod,MAGIC) == 235
    'warmstart
    wflag := 1

  else
    'kaltstart
    ram_wrbyte(sysmod,235,MAGIC)
    ram_wrlong(sysmod,SYSVAR,RAMEND)                    'Zeiger auf letzte freie Speicherzelle setzen
    ram_wrlong(sysmod,0,RAMBAS)                         'Zeiger auf erste freie Speicherzelle setzen
    wflag := 0
    ram_wrbyte(sysmod,0,RAMDRV)                         'Ramdrive ist abgeschaltet
    ram_wrbyte(sysmod,0,TIB2)                           'tib-puffer mit leerstrin belegen

  rbas := ram_rdlong(sysmod,RAMBAS)
  rend := ram_rdlong(sysmod,RAMEND)
  rd_init

PUB stop                                                'loader: beendet anwendung und startet os
''funktionsgruppe               : system
''funktion                      : beendet die laufende  anwendung und kehrt zum os (reg.sys) zurück
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : -

  sddmact(DM_ROOT)
  ldbin(@regsys)
  repeat

PUB startram                                            'system: initialisierung des systems bei ram-upload
''funktionsgruppe               : system
''funktion                      : ios initialisieren - wenn man zu testzwecken das programm direkt in den ram
''                              : überträgt und startet, bekommen alle props ein reset, wodurch bellatrix auf
''                              : einen treiber wartet. für testzwecke erledigt diese routine den upload des
''                              : standard-vga-treibers.
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : -

  sdmount                                               'sd-karte mounten
  bload(@belsys)                                        'vga-treiber zu bellatrix übertragen

PUB paraset(stradr) | i,c                               'system: parameter --> eram
''funktionsgruppe               : system
''funktion                      : parameter --> eram - werden programme mit dem systemloader gestartet, so kann
''                              : mit dieser funktion ein parameterstring im eram übergeben werden. das gestartete
''                              : programm kann diesen dann mit "parastart" & "paranext" auslesen und verwenden
''eingabe                       : -
''ausgabe                       : stradr - adresse des parameterstrings
''busprotokoll                  : -

  paradel                                               'parameterbereich löschen
  repeat i from 0 to 63                                 'puffer ist mx. 64 zeichen lang
    c := byte[stradr+i]                                 
    ram_wrbyte(0,c,PARAM+i)
    if c == 0                                           'bei stringende vorzeitig beenden
      return

PUB paradel | i                                         'system: parameterbereich löschen
''funktionsgruppe               : system
''funktion                      : parameterbereich im eram löschen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : -

  repeat i from 0 to 63
    ram_wrbyte(0,0,PARAM+i)

PUB parastart                                           'system: setzt den zeiger auf parameteranfangsposition
''funktionsgruppe               : system
''funktion                      : setzt den index auf die parameteranfangsposition
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : -

  parapos := 0

PUB paranext(stradr): err | i,c                         'system: überträgt den nächsten parameter in stringdatei
''funktionsgruppe               : system
''funktion                      : überträgt den nächsten parameter in stringdatei
''eingabe                       : stradr - adresse einer stringvariable für den nächsten parameter
''ausgabe                       : err - 0: kein weiterer parameter
''                              :       1: parameter gültig
''busprotokoll                  : -

  if ram_rdbyte(0,PARAM+parapos) <> 0                   'stringende?
    repeat until ram_rdbyte(0,PARAM+parapos) > CHAR_SPACE 'führende leerzeichen ausblenden
      parapos++
    i := 0
    repeat                                              'parameter kopieren
      c := ram_rdbyte(0,PARAM + parapos++)
      if c <> CHAR_SPACE                                'space nicht kopieren
        byte[stradr++] := c
    until (c == CHAR_SPACE) or (c == 0)
    byte[stradr] := 0                                   'string abschließen
    return 1
  else
    return 0

PUB reggetcogs:regcogs |i,c,cog[8]                      'system: fragt freie cogs von regnatix ab
''funktionsgruppe               : system
''funktion                      : fragt freie cogs von regnatix ab
''eingabe                       : -
''ausgabe                       : regcogs - anzahl der belegten cogs
''busprotokoll                  : -

  regcogs := i := 0
  repeat 'loads as many cogs as possible and stores their cog numbers
    c := cog[i] := cognew(@entry, 0)
    if c=>0
      i++
  while c => 0
  regcogs := i
  repeat 'unloads the cogs and updates the string
    i--
    if i=>0
      cogstop(cog[i])
  while i=>0  

PUB ldbin(stradr) | len,i,stradr1,stradr2               'loader: startet bin-datei über loader
''funktionsgruppe               : system
''funktion                      : startet bin-datei über den systemloader
''eingabe                       : stradr - adresse eines strings mit dem dateinamen der bin-datei
''ausgabe                       : -
''busprotokoll                  : -

  len := strsize(stradr)
  stradr2 := lflagadr + 1                               'adr = flag, adr + 1 = string
  repeat i from 0 to len - 1                            'string in loadervariable kopieren
    byte[stradr2][i] := byte[stradr][i]
  byte[stradr2][++i] := 0                               'string abschließen
  byte[lflagadr][0] := 1                                'loader starten

PUB os_error(err):error                                 'sys: fehlerausgabe

  if err
    printnl
    print(string("Fehlernummer : "))
    printdec(err)
    print(string(" : $"))
    printhex(err,2)
    printnl
    print(string("Fehler       : "))
    case err
      0:  print(string("no error"))
      1:  print(string("fsys unmounted"))
      2:  print(string("fsys corrupted"))
      3:  print(string("fsys unsupported"))
      4:  print(string("not found"))
      5:  print(string("file not found"))
      6:  print(string("dir not found"))
      7:  print(string("file read only"))
      8:  print(string("end of file"))
      9:  print(string("end of directory"))
      10: print(string("end of root"))
      11: print(string("dir is full"))
      12: print(string("dir is not empty"))
      13: print(string("checksum error"))
      14: print(string("reboot error"))
      15: print(string("bpb corrupt"))
      16: print(string("fsi corrupt"))
      17: print(string("dir already exist"))
      18: print(string("file already exist"))
      19: print(string("out of disk free space"))
      20: print(string("disk io error"))
      21: print(string("command not found"))
      22: print(string("timeout"))
      23: print(string("out of memory"))
      OTHER: print(string("undefined"))
    printnl
  error := err

OBJ '' A D M I N I S T R A

CON ''------------------------------------------------- CHIP-MANAGMENT

PUB admsetsound(sndfunktion):sndstat                    'chip-mgr: soundsubsysteme verwalten
''funktionsgruppe               : cmgr
''funktion                      : soundsubsysteme an- bzw. abschalten
''busprotokoll                  : [150][put.funktion][get.sndstat]
''                              : funktion - 0: hss-engine abschalten    SND_HSSOFF
''                              :            1: hss-engine anschalten    SND_HSSON
''                              :            2: dac-engine abschalten    SND_WAVOFF
''                              :            3: dac-engine anschalten    SND_WAVON
''                              : sndstat  - status/cognr startvorgang
        
  bus_putchar1(gc#a_mgrSetSound)
  bus_putchar1(sndfunktion)
  sndstat := bus_getchar1

PUB admsetsyssnd(status)                                'chip-mgr: systemklänge ein/ausschalten
''funktionsgruppe               : cmgr
''funktion                      : systemklänge steuern
''busprotokoll                  : [094][put.fl_syssnd]
''                              : fl_syssnd - flag zur steuerung der systemsounds
''                              :             0 - systemtöne aus
''                              :             1 - systemtöne an

  bus_putchar1(gc#a_mgrSetSysSound)
  bus_putchar1(status)
  
PUB admgetsndsys: status                                'chip-mgr: status des soundsystems abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage welches soundsystem aktiv ist
''busprotokoll                  : [095][get.status]
''                              : status   - status des soundsystems
''                              :            0 - sound aus
''                              :            1 - hss
''                              :            2 - wav

  bus_putchar1(gc#a_mgrGetSoundSys)
  status := bus_getchar1
  
PUB admload(stradr)|dmu                                 'chip-mgr: neuen administra-code booten
''funktionsgruppe               : cmgr
''funktion                      : administra mit neuem code booten
''busprotokoll                  : [096][sub_putstr.fn]
''                              : fn - dateiname des neuen administra-codes

  bus_putchar1(gc#a_mgrALoad)   'aktuelles userdir retten
  bus_putstr1(stradr)
  waitcnt(cnt + clkfreq*3)      'warte bis administra fertig ist

PUB admgetver:ver                                       'chip-mgr: version abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''busprotokoll                  : [098][sub_getlong.ver]
''                              : ver - version
''                  +----------
''                  |  +------- system     
''                  |  |  +---- version    (änderungen)
''                  |  |  |  +- subversion (hinzufügungen)
''version :       $00_00_00_00
''

  bus_putchar1(gc#a_mgrGetVer)
  ver := bus_getlong1

PUB admgetspec:spec                                     'chip-mgr: spezifikation abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''busprotokoll                  : [089][sub_getlong.spec]
''                              : spec - spezifikation
''
''                                          +---------- com
''                                          | +-------- i2c
''                                          | |+------- rtc
''                                          | ||+------ lan
''                                          | |||+----- sid
''                                          | ||||+---- wav
''                                          | |||||+--- hss
''                                          | ||||||+-- bootfähig
''                                          | |||||||+- dateisystem
''spezifikation : %00000000_00000000_00000000_01001111

  bus_putchar1(gc#a_mgrGetSpec)
  spec := bus_getlong1

PUB admgetcogs:cogs                                     'chip-mgr: verwendete cogs abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage wie viele cogs in benutzung sind
''busprotokoll                  : [097][get.cogs]
''                              : cogs - anzahl der belegten cogs

  bus_putchar1(gc#a_mgrGetCogs)
  cogs := bus_getchar1

PUB admreset                                            'chip-mgr: administra reset
''funktionsgruppe               : cmgr
''funktion                      : reset im administra-chip auslösen - loader aus dem eeprom wird neu geladen
''busprotokoll                  : -

  bus_putchar1(gc#a_mgrReboot)

CON ''------------------------------------------------- SD_LAUFWERKSFUNKTIONEN

PUB sdmount: err                                        'sd-card: mounten
''funktionsgruppe               : sdcard
''funktion                      : eingelegtes volume mounten
''busprotokoll                  : [001][get.err]
''                              : err - fehlernummer entspr. list

  bus_putchar1(gc#a_sdMount)
  err := bus_getchar1
  
PUB sddir                                               'sd-card: verzeichnis wird geöffnet
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis öffnen
''busprotokoll                  : [002]

  bus_putchar1(gc#a_sdOpenDir)

PUB sdnext: stradr | flag                               'sd-card: nächster dateiname aus verzeichnis
''funktionsgruppe               : sdcard
''funktion                      : nächsten eintrag aus verzeichnis holen
''busprotokoll                  : [003][get.status=0]
''                              : [003][get.status=1][sub_getstr.fn]
''                              : status - 1 = gültiger eintrag
''                              :          0 = es folgt kein eintrag mehr
''                              : fn - verzeichniseintrag string

    bus_putchar1(gc#a_sdNextFile)                       'kommando: nächsten eintrag holen
    flag := bus_getchar1                                'flag empfangen
    if flag 
      return bus_getstr1
    else
      return 0

PUB sdopen(modus,stradr):err | len,i                    'sd-card: datei öffnen
''funktionsgruppe               : sdcard
''funktion                      : eine bestehende datei öffnen
''busprotokoll                  : [004][put.modus][sub_putstr.fn][get.error]
''                              : modus - "A" Append, "W" Write, "R" Read (Großbuchstaben!)
''                              : fn - name der datei
''                              : error - fehlernummer entspr. list

  bus_putchar1(gc#a_sdOpen)
  bus_putchar1(modus)
  len := strsize(stradr)
  bus_putchar1(len)
  repeat i from 0 to len - 1
    bus_putchar1(byte[stradr++])
  err := bus_getchar1

PUB sdclose:err                                         'sd-card: datei schließen
''funktionsgruppe               : sdcard
''funktion                      : die aktuell geöffnete datei schließen
''busprotokoll                  : [005][get.error]
''                              : error - fehlernummer entspr. list

  bus_putchar1(gc#a_sdClose)
  err := bus_getchar1

PUB sdgetc: char                                        'sd-card: zeichen aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus datei lesen
''busprotokoll                  : [006][get.char]
''                              : char - gelesenes zeichen

  bus_putchar1(gc#a_sdGetC)
  char := bus_getchar1

PUB sdputc(char)                                        'sd-card: zeichen in datei schreiben
{{sdputc(char) - sd-card: zeichen in datei schreiben}}
  bus_putchar1(gc#a_sdPutC)
  bus_putchar1(char)

PUB sdgetstr(stringptr,len)                             'sd-card: eingabe einer zeichenkette
  repeat len
    byte[stringptr++] := bus_getchar1

PUB sdputstr(stringptr)                                 'sd-card: ausgabe einer zeichenkette (0-terminiert)
{{sdstr(stringptr) - sd-card: ausgabe einer zeichenkette (0-terminiert)}}
  repeat strsize(stringptr)
    sdputc(byte[stringptr++])

PUB sddec(value) | i                                    'sd-card: dezimalen zahlenwert auf bildschirm ausgeben
{{sddec(value) - sd-card: dezimale bildschirmausgabe zahlenwertes}}
  if value < 0                                          'negativer zahlenwert
    -value
    sdputc("-")
  i := 1_000_000_000
  repeat 10                                             'zahl zerlegen
    if value => i
      sdputc(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      sdputc("0")
    i /= 10                                             'n?chste stelle

PUB sdeof: eof                                          'sd-card: eof abfragen
''funktionsgruppe               : sdcard
''funktion                      : eof abfragen
''busprotokoll                  : [030][get.eof]
''                              : eof - eof-flag

  bus_putchar1(gc#a_sdEOF)
  eof := bus_getchar1

PUB sdgetblk(count,bufadr) | i                          'sd-card: block lesen
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen
''busprotokoll                  : [008][sub_putlong.count][get.char(1)]..[get.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen

  i := 0
  bus_putchar1(gc#a_sdGetBlk)
  bus_putlong1(count)
  repeat count
    byte[bufadr][i++] := bus_getchar1
    
PUB sdputblk(count,bufadr) | i                          'sd-card: block schreiben
''funktionsgruppe               : sdcard
''funktion                      : zeichen in datei schreiben
''busprotokoll                  : [007][put.char]
''                              : char - zu schreibendes zeichen

  i := 0
  bus_putchar1(gc#a_sdPutBlk)
  bus_putlong1(count)
  repeat count
    bus_putchar1(byte[bufadr][i++])

PUB sdxgetblk(fnr,count)|i                              'sd-card: block lesen --> eRAM
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen und in ramdisk speichern
''busprotokoll                  : [008][sub_putlong.count][get.char(1)]..[get.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen

  i := 0
  bus_putchar1(gc#a_sdGetBlk)
  bus_putlong1(count)
  repeat count
    rd_put(fnr,bus_getchar1)

PUB sdxputblk(fnr,count)|i                              'sd-card: block schreiben <-- eRAM
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus ramdisk in datei schreiben
''busprotokoll                  : [007][put.char]
''                              : char - zu schreibendes zeichen

  i := 0
  bus_putchar1(gc#a_sdPutBlk)
  bus_putlong1(count)
  repeat count
    bus_putchar1(rd_get(fnr))

PUB sdseek(wert)                                        'sd-card: zeiger auf byteposition setzen
''funktionsgruppe               : sdcard
''funktion                      : zeiger in datei positionieren
''busprotokoll                  : [010][sub_putlong.pos]
''                              : pos - neue zeichenposition in der datei

  bus_putchar1(gc#a_sdSeek)
  bus_putlong1(wert)

PUB sdfattrib(anr): attrib                              'sd-card: dateiattribute abfragen
''funktionsgruppe               : sdcard
''funktion                      : dateiattribute abfragen
''busprotokoll                  : [011][put.anr][sub_getlong.wert]
''                              : anr - 0  = Dateigröße
''                              :       1  = Erstellungsdatum - Tag
''                              :       2  = Erstellungsdatum - Monat
''                              :       3  = Erstellungsdatum - Jahr
''                              :       4  = Erstellungsdatum - Sekunden
''                              :       5  = Erstellungsdatum - Minuten
''                              :       6  = Erstellungsdatum - Stunden
''                              :       7  = Zugriffsdatum - Tag
''                              :       8  = Zugriffsdatum - Monat
''                              :       9  = Zugriffsdatum - Jahr
''                              :       10 = Änderungsdatum - Tag
''                              :       11 = Änderungsdatum - Monat
''                              :       12 = Änderungsdatum - Jahr
''                              :       13 = Änderungsdatum - Sekunden
''                              :       14 = Änderungsdatum - Minuten
''                              :       15 = Änderungsdatum - Stunden
''                              :       16 = Read-Only-Bit
''                              :       17 = Hidden-Bit
''                              :       18 = System-Bit
''                              :       19 = Direktory
''                              :       20 = Archiv-Bit
''                              : wert - wert des abgefragten attributes


  bus_putchar1(gc#a_sdFAttrib)
  bus_putchar1(anr)
  attrib := bus_getlong1                               
  
  
PUB sdvolname: stradr | len,i                           'sd-card: volumelabel abfragen
''funktionsgruppe               : sdcard
''funktion                      : name des volumes überragen
''busprotokoll                  : [012][sub_getstr.volname]
''                              : volname - name des volumes
''                              : len   - länge des folgenden strings

  bus_putchar1(gc#a_sdVolname)                              'kommando: volumelabel abfragen
  return bus_getstr1
  
PUB sdcheckmounted: flag                                'sd-card: test ob volume gemounted ist
''funktionsgruppe               : sdcard
''funktion                      : test ob volume gemounted ist
''busprotokoll                  : [013][get.flag]
''                              : flag  - 0: unmounted
''                              :         1: mounted

  bus_putchar1(gc#a_sdCheckMounted)
  return bus_getchar1
  
PUB sdcheckopen: flag                                   'sd-card: test ob datei geöffnet ist
''funktionsgruppe               : sdcard
''funktion                      : test ob eine datei geöffnet ist
''busprotokoll                  : [014][get.flag]
''                              : flag  - 0: not open
''                              :         1: open

  bus_putchar1(gc#a_sdCheckOpen)
  return bus_getchar1

PUB sdcheckused                                         'sd-card: abfrage der benutzten sektoren
''funktionsgruppe               : sdcard
''funktion                      : anzahl der benutzten sektoren senden 
''busprotokoll                  : [015][sub_getlong.used]
''                              : used - anzahl der benutzten sektoren

  bus_putchar1(gc#a_sdCheckUsed)
  return bus_getlong1

PUB sdcheckfree                                         'sd_card: abfrage der freien sektoren
''funktionsgruppe               : sdcard
''funktion                      : anzahl der freien sektoren senden 
''busprotokoll                  : [016][sub_getlong.free]
''                              : free - anzahl der freien sektoren

  bus_putchar1(gc#a_sdCheckFree)
  return bus_getlong1

PUB sdnewfile(stradr):err                               'sd_card: neue datei erzeugen
''funktionsgruppe               : sdcard
''funktion                      : eine neue datei erzeugen 
''busprotokoll                  : [017][sub_putstr.fn][get.error]
''                              : fn - name der datei
''                              : error - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdNewFile)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sdnewdir(stradr):err                                'sd_card: neues verzeichnis erzeugen
''funktionsgruppe               : sdcard
''funktion                      : ein neues verzeichnis erzeugen
''busprotokoll                  : [018][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdNewDir)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sddel(stradr):err                                   'sd_card: datei/verzeichnis löschen
''funktionsgruppe               : sdcard
''funktion                      : eine datei oder ein verzeichnis löschen
''busprotokoll                  : [019][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses oder der datei
''                              : error - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdDel)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sdrename(stradr1,stradr2):err                       'sd_card: datei/verzeichnis umbenennen
''funktionsgruppe               : sdcard
''funktion                      : datei oder verzeichnis umbenennen
''busprotokoll                  : [020][sub_putstr.fn1][sub_putstr.fn2][get.error]
''                              : fn1 - alter name 
''                              : fn2 - neuer name 
''                              : error - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdRename)
  bus_putstr1(stradr1)
  bus_putstr1(stradr2)
  err := bus_getchar1

PUB sdchattrib(stradr1,stradr2):err                     'sd-card: attribute ändern
''funktionsgruppe               : sdcard
''funktion                      : attribute einer datei oder eines verzeichnisses ändern
''busprotokoll                  : [021][sub_putstr.fn][sub_putstr.attrib][get.error]
''                              : fn - dateiname
''                              : attrib - string mit attributen (AHSR)
''                              : error - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdChAttrib)
  bus_putstr1(stradr1)
  bus_putstr1(stradr2)
  err := bus_getchar1

PUB sdchdir(stradr):err                                 'sd-card: verzeichnis wechseln
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis wechseln
''busprotokoll                  : [022][sub_putstr.fn][get.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. list

  bus_putchar1(gc#a_sdChDir)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sdformat(stradr):err                                'sd-card: medium formatieren
''funktionsgruppe               : sdcard
''funktion                      : medium formatieren
''busprotokoll                  : [023][sub_putstr.vlabel][get.error]
''                              : vlabel - volumelabel
''                              : error - fehlernummer entspr. list

  bus_putchar1(gc#a_sdFormat)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sdunmount:err                                       'sd-card: medium abmelden
''funktionsgruppe               : sdcard
''funktion                      : medium abmelden
''busprotokoll                  : [024][get.error]
''                              : error - fehlernummer entspr. list

  bus_putchar1(gc#a_sdUnmount)
  err := bus_getchar1

PUB sddmact(marker):err                                 'sd-card: dir-marker aktivieren
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker wird aktiviert
''busprotokoll                  : [025][put.dmarker][get.error]
''                              : dmarker - dir-marker      
''                              : error   - fehlernummer entspr. list

  bus_putchar1(gc#a_sdDmAct)
  bus_putchar1(marker)
  err := bus_getchar1

PUB sddmset(marker)                                     'sd-card: dir-marker setzen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker mit dem aktuellen verzeichnis setzen
''busprotokoll                  : [026][put.dmarker]
''                              : dmarker - dir-marker      

  bus_putchar1(gc#a_sdDmSet)
  bus_putchar1(marker)

PUB sddmget(marker):status                              'sd-card: dir-marker abfragen
''funktionsgruppe               : sdcard
''funktion                      : den status eines ausgewählter dir-marker abfragen
''busprotokoll                  : [027][put.dmarker][sub_getlong.dmstatus]
''                              : dmarker  - dir-marker     
''                              : dmstatus - status des markers

  bus_putchar1(gc#a_sdDmGet)
  bus_putchar1(marker)
  status := bus_getlong1
  
PUB sddmclr(marker)                                     'sd-card: dir-marker löschen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker löschen
''busprotokoll                  : [028][put.dmarker]
''                              : dmarker - dir-marker      

  bus_putchar1(gc#a_sdDmClr)
  bus_putchar1(marker)

PUB sddmput(marker,status)                              'sd-card: dir-marker status setzen
''funktionsgruppe               : sdcard
''funktion                      : dir-marker status setzen
''busprotokoll                  : [027][put.dmarker][sub_putlong.dmstatus]
''                              : dmarker  - dir-marker
''                              : dmstatus - status des markers

  bus_putchar1(gc#a_sdDmPut)
  bus_putchar1(marker)
  bus_putlong1(status)

CON ''------------------------------------------------- DATE TIME FUNKTIONEN

PUB getSeconds                                          'Returns the current second (0 - 59) from the real time clock.
  bus_putchar1(gc#a_rtcGetSeconds)
  return bus_getlong1

PUB getMinutes                                          'Returns the current minute (0 - 59) from the real time clock.
  bus_putchar1(gc#a_rtcGetMinutes)
  return bus_getlong1

PUB getHours                                            'Returns the current hour (0 - 23) from the real time clock.
  bus_putchar1(gc#a_rtcGetHours)
  return bus_getlong1

PUB getDay                                              'Returns the current day (1 - 7) from the real time clock.
  bus_putchar1(gc#a_rtcGetDay)
  return bus_getlong1

PUB getDate                                             'Returns the current date (1 - 31) from the real time clock.
  bus_putchar1(gc#a_rtcGetDate)
  return bus_getlong1

PUB getMonth                                            'Returns the current month (1 - 12) from the real time clock.
  bus_putchar1(gc#a_rtcGetMonth)
  return bus_getlong1

PUB getYear                                             'Returns the current year (2000 - 2099) from the real time clock.
  bus_putchar1(gc#a_rtcGetYear)
  return bus_getlong1

PUB setSeconds(seconds)                                 'Sets the current real time clock seconds.
                                                        'seconds - Number to set the seconds to between 0 - 59.
  if seconds => 0 and seconds =< 59
    bus_putchar1(gc#a_rtcSetSeconds)
    bus_putlong1(seconds)

PUB setMinutes(minutes)                                 'Sets the current real time clock minutes.
                                                        'minutes - Number to set the minutes to between 0 - 59.
  if minutes => 0 and minutes =< 59
    bus_putchar1(gc#a_rtcSetMinutes)
    bus_putlong1(minutes)

PUB setHours(hours)                                     'Sets the current real time clock hours.
                                                        'hours - Number to set the hours to between 0 - 23.

  if hours => 0 and hours =< 23
    bus_putchar1(gc#a_rtcSetHours)
    bus_putlong1(hours)

PUB setDay(day)                                         'Sets the current real time clock day.
                                                        'day - Number to set the day to between 1 - 7.
  if day => 1 and day =< 7
    bus_putchar1(gc#a_rtcSetDay)
    bus_putlong1(day)

PUB setDate(date)                                       'Sets the current real time clock date.
                                                        'date - Number to set the date to between 1 - 31.
  if date => 1 and date =< 31
    bus_putchar1(gc#a_rtcSetDate)
    bus_putlong1(date)

PUB setMonth(month)                                     'Sets the current real time clock month.
                                                        'month - Number to set the month to between 1 - 12.
  if month => 1 and month =< 12
    bus_putchar1(gc#a_rtcSetMonth)
    bus_putlong1(month)

PUB setYear(year)                                       'Sets the current real time clock year.
                                                        'year - Number to set the year to between 2000 - 2099.
  if year => 2000 and year =< 2099
    bus_putchar1(gc#a_rtcSetYear)
    bus_putlong1(year)

PUB setNVSRAM(index, value)                             'Sets the NVSRAM to the selected value (0 - 255) at the index (0 - 55).
                                                        'index - The location in NVRAM to set (0 - 55).
                                                        'value - The value (0 - 255) to change the location to.
  if index => 0 AND index =< 55 AND value => 0 AND value =< 255
    bus_putchar1(gc#a_rtcSetNVSRAM)
    bus_putlong1(index)
    bus_putlong1(value)

PUB getNVSRAM(index)                                    'Gets the selected NVSRAM value at the index (0 - 55).
                                                        'Returns the selected location's value (0 - 255).
                                                        'index - The location in NVRAM to get (0 - 55).
  bus_putchar1(gc#a_rtcGetNVSRAM)
  bus_putlong1(index)
  return bus_getlong1

PUB pauseForSeconds(number)                             'Pauses execution for a number of seconds.
                                                        'number - Number of seconds to pause for between 0 and 2,147,483,647.
  bus_putchar1(gc#a_rtcPauseForSec)
  return bus_getlong1

PUB pauseForMilliseconds(number)                        'Pauses execution for a number of milliseconds.
                                                        'Returns a puesdo random value derived from the current clock frequency and the time when called.
                                                        'number - Number of milliseconds to pause for between 0 and 2,147,483,647.
  bus_putchar1(gc#a_rtcPauseForMSec)
  return bus_getlong1


CON ''------------------------------------------------- LAN_FUNKTIONEN

PUB lanstart                                            'LAN starten
''funktionsgruppe               : lan
''funktion                      : Netzwerk starten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [071]

  bus_putchar1(gc#a_lanStart)
  waitcnt(cnt + clkfreq)        '1sek warten (nach ios.lanstart dauert es, bis der Stack funktioniert)


PUB lanstop                                             'LAN beenden
''funktionsgruppe               : lan
''funktion                      : Netzwerk anhalten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [072]

  bus_putchar1(gc#a_lanStop)
  waitcnt(cnt + clkfreq)        '1sek warten, bis in Administra wirklich beendet

PUB lan_connect(ipaddr, remoteport): handleidx
''funktionsgruppe               : lan
''funktion                      : ausgehende TCP-Verbindung öffnen (mit Server verbinden)
''                              : Da hier feste Puffer (bufrxconn,buftxconn) verwendet werden,
''                              : darf diese Funktion nur einmal aufgerufen werden
''                              : (driver_socket.spin handelt per default bis 4 Sockets)
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [073][sub_putlong.ipaddr][sub_putword.remoteport][get.handleidx]
''                              : ipaddr     - ipv4 address packed into a long (ie: 1.2.3.4 => $01_02_03_04)
''                              : remoteport - port number to connect to
''                              : handleidx  - lfd. Nr. der Verbindung

  bus_putchar1(gc#a_lanConnect)
  bus_putlong1(ipaddr)
  bus_putword1(remoteport)
  handleidx := bus_getchar1

PUB lan_listen(port): handleidx
''funktionsgruppe               : lan
''funktion                      : Port für eingehende TCP-Verbindung öffnen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [074][sub_putword.port][get.handleidx]
''                              : port       - zu öffnende Portnummer
''                              : handleidx  - lfd. Nr. der Verbindung (index des kompletten handle)

  bus_putchar1(gc#a_lanListen)
  bus_putword1(port)
  handleidx := bus_getchar1

PUB lan_waitconntimeout(handleidx, timeout): connected
''funktionsgruppe               : lan
''funktion                      : bestimmte Zeit auf Verbindung warten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [075][put.handleidx][sub_putword.timeout][get.connected]
''                              : handleidx  - lfd. Nr. der zu testenden Verbindung
''                              : timeout    - Timeout in Millisekunden
''                              : connected  - True, if connected

  bus_putchar1(gc#a_lanWaitConnTimeout)
  bus_putchar1(handleidx)
  bus_putword1(timeout)
  connected := bus_getchar1

PUB lan_close(handleidx)
''funktionsgruppe               : lan
''funktion                      : TCP-Verbindung (ein- oder ausgehend) schließen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [076][put.handleidx]
''                              : handleidx     - lfd. Nr. der zu schließenden Verbindung

  bus_putchar1(gc#a_lanClose)
  bus_putchar1(handleidx)

PUB lan_rxtime(handleidx, timeout): rxbyte
''funktionsgruppe               : lan
''funktion                      : angegebene Zeit auf ASCII-Zeichen warten
''                              : nicht verwenden, wenn anderes als ASCII (0 - 127) empfangen wird
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [077][sub_putlong.handleidx][sub_putword.timeout][get.rxbyte]
''                              : handleidx - lfd. Nr. der Verbindung
''                              : timeout   - Timeout in Millisekunden
''                              : rxbyte    - empfangenes Zeichen (0 - 127) oder
''                              :             sock#RETBUFFEREMPTY (-1) wenn Timeout oder keine Verbindung mehr

  bus_putchar1(gc#a_lanRXTime)
  bus_putchar1(handleidx)
  bus_putword1(timeout)
  rxbyte := bus_getchar1
  rxbyte := ~rxbyte

PUB lan_rxdata(handleidx, filename, len): error | fnr
''funktionsgruppe               : lan
''funktion                      : bei bestehender Verbindung die angegebene Datenmenge in File der RAM-Disk schreiben
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [078][put.handleidx][sub_putlong.len][get.byte1][get.byte<len>][get.error]
''                              : handleidx           - lfd. Nr. der Verbindung
''                              : byte1 ... byte<len> - zu empfangende Bytes
''                              : len                 - Anzahl zu empfangende Bytes
''                              : error               - ungleich Null bei Fehler

  rd_del(filename)              'File aus RAM-Disk löschen (falls vorhanden)
  rd_newfile(filename,len)
  fnr := rd_open(filename)
  ifnot fnr == -1
    bus_putchar1(gc#a_lanRXData)
    bus_putchar1(handleidx)
    bus_putlong1(len)
    repeat len
      rd_put(fnr,bus_getchar1)
    rd_close(fnr)

  error := bus_getchar1
  error := ~error

PUB lan_txdata(handleidx, ptr, len): error
''funktionsgruppe               : lan
''funktion                      : bei bestehender Verbindung die angegebene Datenmenge senden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [079][put.handleidx][sub_putlong.len][put.byte1][put.byte<len>][get.error]
''                              : handleidx           - lfd. Nr. der Verbindung
''                              : byte1 ... byte<len> - zu sendende Bytes
''                              : len                 - Anzahl zu sendender Bytes
''                              : error               - ungleich Null bei Fehler

  bus_putchar1(gc#a_lanTXData)
  bus_putchar1(handleidx)
  bus_putlong1(len)

  repeat len
    bus_putchar1(byte[ptr++])

  error := bus_getchar1
  error := ~error

PUB lan_rxbyte(handleidx): rxbyte
''funktionsgruppe               : lan
''funktion                      : wenn vorhanden, ein empfangenes Byte lesen
''                              : nicht verwenden, wenn auch $FF empfangen werden kann
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [080][sub_putlong.handleidx]][get.rxbyte]
''                              : handleidx - lfd. Nr. der Verbindung
''                              : rxbyte    - empfangenes Zeichen oder
''                              :             sock#RETBUFFEREMPTY (-1) wenn Empfangspuffer leer

  bus_putchar1(gc#a_lanRXByte)
  bus_putchar1(handleidx)
  rxbyte := bus_getchar1
  rxbyte := ~rxbyte

PUB lan_isconnected(handleidx): connected
''funktionsgruppe               : lan
''funktion                      : TRUE, wenn Socket verbunden, sonst FALSE
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [081][sub_putlong.handleidx]][get.connected]
''                              : handleidx - lfd. Nr. der Verbindung
''                              : connected - TRUE, wenn Socket verbunden, sonst FALSE

  bus_putchar1(gc#a_lanIsConnected)
  bus_putchar1(handleidx)
  connected := bus_getchar1
  connected := ~connected

CON ''------------------------------------------------- Hydra Sound System

PUB hss_playfile(stradr) | status                       'hss: spielt übergebene hss-datei von sd-card
''funktionsgruppe               : hss
''funktion                      : hss-datei wird in den puffer in administra geladen und der player gestartet
''                              : stradr - stringadresse zu dateinamen

  status := hss_load(stradr)
  hss_play

PUB hss_stop                                            'hss: stopt aktuellen song
''funktionsgruppe               : hss
''funktion                      : hss-player stoppen; datei bleibt im puffer

  bus_putchar1(gc#a_hssStop)

PUB hss_pause                                           'hss: pausiert aktuellen song
''funktionsgruppe               : hss
''funktion                      : hss-player pause (funktion noch unklar)

  bus_putchar1(gc#a_hssPause)

PUB hss_load(stradr): status | len,i                    'hss: lädt hss-datei von sd-card in songpuffer
''funktionsgruppe               : hss
''funktion                      : hss-datei wird in den modulpuffer geladen
''busprotokoll                  : [100][sub_putstr.fn][get.err]
''                              : fn  - dateiname
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_hssLoad)
  bus_putstr1(stradr)
  status := bus_getchar1

PUB hss_play                                            'hss: spielt song im puffer ab
''funktionsgruppe               : hss
''funktion                      : hss-player starten und modul im puffer wiedergeben

  bus_putchar1(gc#a_hssPlay)

PUB hss_vol(vol)                                        'hss: volume einstellen 0..15
''funktionsgruppe               : hss
''funktion                      : lautstärke des hss-players wird eingestellt
''busprotokoll                  : [106][put.vol]
''                              : vol - 0..15 gesamtlautstärke des hss-players

  bus_putchar1(gc#a_hssVol)
  bus_putchar1(vol)

PUB hss_peek(n): wert                                   'hss: registerwert auslesen
''funktionsgruppe               : hss
''funktion                      : zugriff auf die internen playerregister; leider sind die register
''                              : nicht dokumentiert; 48 long-register
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [104][put.regnr][sub_getlong.regwert]
''                              : regnr   - registernummer
''                              : regwert - long

  bus_putchar1(gc#a_hssPeek)                               'kommando peek senden
  bus_putchar1(n)                                       'kommando peek senden
  wert := bus_getlong1                                  '32-bit-wert lesen

PUB hss_intreg(n): wert                                 'hss: interfaceregister auslesen
''funktionsgruppe               : hss
''funktion                      : abfrage eines hss-playerregisters (16bit) durch regnatix
''busprotokoll                  : [105][put.regnr][get.reghwt][get.regnwt]
''                              : regnr - 0..24 (5 x 5 register)
''                              : reghwt - höherwertiger teil des 16bit-registerwertes
''                              : regnwt - niederwertiger teil des 16bit-registerwertes
''
''0     iEndFlag        iRowFlag        iEngineC        iBeatC  iRepeat         globale Playerwerte
''5     iNote           iOktave         iVolume         iEffekt iInstrument     Soundkanal 1
''10    iNote           iOktave         iVolume         iEffekt iInstrument     Soundkanal 2
''15    iNote           iOktave         iVolume         iEffekt iInstrument     Soundkanal 3
''20    iNote           iOktave         iVolume         iEffekt iInstrument     Soundkanal 4
''
''iEndFlag      Repeat oder Ende wurde erreicht
''iRowFlag      Trackerzeile (Row) ist fertig
''iEngineC      Patternzähler
''iBeatC        Beatzähler (Anzahl der Rows)
''iRepeat       Zähler für Loops

  bus_putchar1(gc#a_hssIntReg)                             'kommando peek senden
  bus_putchar1(n)                                       'kommando peek senden
  wert := bus_getchar1                                  '16-bit-wert lesen, hsb/lsb
  wert := (wert<<8) + bus_getchar1

PUB sfx_setslot(adr,slot) | i,n                         'sfx: sendet sfx-daten in sfx-slot
''funktionsgruppe               : sfx
''funktion                      : die daten für ein sfx-slot werden werden von regnatix gesetzt
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [108][put.slot][put.daten(0)]..[put.daten(31)]
''                              : slot  - $00..$0f nummer der freien effektpuffer
''                              : daten - 32 byte effektdaten
''
''struktur der effektdaten:
''
''[wav ][len ][freq][vol ]      grundschwingung
''[lfo ][lfw ][fma ][ama ]      modulation
''[att ][dec ][sus ][rel ]      hüllkurve
''[seq ]                        (optional)
''
''[wav]                         wellenform
''  0 sinus (0..500hz)
''  1 schneller sinus (0..1khz)
''  2 dreieck (0..500hz)
''  3 rechteck (0..1khz)
''  4 schnelles rechteck (0..4khz)
''  5 impulse (0..1,333hz)
''  6 rauschen
''[len]                         tonlänge $0..$fe, $ff endlos
''[freq]                        frequenz $00..$ff
''[vol]                         lautstärke $00..$0f
''
''[lfo]                         low frequency oscillator $ff..$01
''[lfw]                         low frequency waveform
''  $00 sinus (0..8hz)
''  $01 fast sine (0..16hz)
''  $02 ramp up (0..8hz)
''  $03 ramp down (0..8hz)
''  $04 square (0..32hz)
''  $05 random
''  $ff sequencer data          (es folgt eine sequenzfolge [seq])
''[fma]                         frequency modulation amount
''  $00 no modulation
''  $01..$ff
''[ama]                         amplitude modulation amount
''  $00 no modulation
''  $01..$ff
''[att]                         attack $00..$ff
''[dec]                         decay $00..$ff
''[sus]                         sustain $00..$ff
''[rel]                         release $00..$ff

  bus_putchar1(gc#a_sfxSetSlot)
  bus_putchar1(slot)                                    'slotnummer senden
  repeat i from 0 to 31                                 '32 byte sfx-daten senden
    n := byte[adr + i]
    bus_putchar1(n)

PUB sfx_fire(slot,chan)                                 'sfx: triggert einen bestimmten soundeffekt
''funktionsgruppe               : sfx
''funktion                      : effekt aus einem effektpuffer abspielen
''busprotokoll                  : [107][put.slot][put.chan]
''                              : slot - $00..$0f nummer der freien effektpuffer
''                              : slot - $f0..ff vordefinierte effektslots
''                              : chan - 0/1 stereokanal auf dem der effekt abgespielt werden soll
''vordefinierte effekte         : &f0 - warnton
''                              : $f1 - signalton
''                              : $f2 - herzschlag schnell
''                              : $f3 - herzschlag langsam
''                              : $f4 - telefon
''                              : $f5 - phaser :)
''                              : $f6 - pling
''                              : $f7 - on
''                              : $f8 - off

  bus_putchar1(gc#a_sfxFire)
  bus_putchar1(slot)                                    'slotnummer senden
  bus_putchar1(chan)                                    'channel senden

PUB sfx_keyoff(chan)                                    'sfx: release-phase wird eingeleitet
''funktionsgruppe               : sfx
''funktion                      : release-phase wird eingeleitet
''busprotokoll                  : [108][put.chan]
''                              : chan - 0/1 stereokanal auf dem der effekt abgespielt werden soll

  bus_putchar1(gc#a_sfxKeyOff)
  bus_putchar1(chan)                                    'slotnummer senden

PUB sfx_stop(chan)                                      'sfx: effekt wird augenblicklich beendet
''funktionsgruppe               : sfx
''funktion                      : effekt wird augenblicklich beendet
''busprotokoll                  : [108][put.chan]
''                              : chan - 0/1 stereokanal auf dem der effekt abgespielt werden soll

  bus_putchar1(gc#a_sfxStop)
  bus_putchar1(chan)                                    'slotnummer senden


CON ''------------------------------------------------- Wave

PUB wav_play(stradr): status | len,i                    'sdw: spielt wav-datei direkt von sd-card
''funktionsgruppe               : sdw
''funktion                      : wav-datei von sd-card abspielen
''busprotokoll                  : [150][sub.putstr][get.err]
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdwStart)
  bus_putstr1(stradr)
  status := bus_getchar1
  
PUB wav_stop:status                                     'sdw: wave-wiedergabe beenden
''funktionsgruppe               : sdw
''funktion                      : wav-player signal zum stoppen senden
''                              : wartet bis player endet und quitiert erst dann
''busprotokoll                  : [151][get.err]
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdwStop)
  status := bus_getchar1

PUB wav_status: status                                  'sdw: status des players abfragen
''funktionsgruppe               : sdw
''funktion                      : status des wav-players abfragen
''busprotokoll                  : [152][get.status]
''                              : status - status des wav-players
''                              :          0: wav fertig (player beendet)
''                              :          1: wav wird abgespielt

  bus_putchar1(gc#a_sdwStatus)
  status := bus_getchar1

PUB wav_lvol(vol)                                       'sdw: linke lautstärke einstellen
''funktionsgruppe               : sdw
''funktion                      : lautstärke links einstellen
''busprotokoll                  : [153][get.vol]
''                              : vol - lautstärke 0..100

  bus_putchar1(gc#a_sdwLeftVol)
  bus_putchar1(vol)

PUB wav_rvol(vol)                                       'sdw: rechte lautstärke einstellen
''funktionsgruppe               : sdw
''funktion                      : lautstärke rechts einstellen
''busprotokoll                  : [154][get.vol]
''                              : vol - lautstärke 0..100

  bus_putchar1(gc#a_sdwRightVol)
  bus_putchar1(vol)

PUB wav_pause:status                                    'sdw: wave-pause
''funktionsgruppe               : sdw
''funktion                      : wav-player signal für pause/weiter senden
''                              : wartet bis player endet und quitiert erst dann
''busprotokoll                  : [151][get.err]
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_sdwPause)
  status := bus_getchar1

PUB wav_len:len                                         'sdw: wav-länge abfragen
''funktionsgruppe               : sdw
''funktion                      : wav-länge abfragen
''busprotokoll                  : [154][sub_getlong.pos][sub_getlong.len]
''                              : len - länge wav-datei
''                              : pos - position in der wav-datei

  bus_putchar1(gc#a_sdwPosition)
         bus_getlong1
  len := bus_getlong1
         
PUB wav_pos:pos                                         'sdw: wav-position abfragen
''funktionsgruppe               : sdw
''funktion                      : wav-länge abfragen
''busprotokoll                  : [154][sub_getlong.pos][sub_getlong.len]
''                              : len - länge wav-datei
''                              : pos - position in der wav-datei

  bus_putchar1(gc#a_sdwPosition)
  pos := bus_getlong1
         bus_getlong1

CON ''------------------------------------------------- SIDCog DMP-Player

PUB sid_mdmpplay(stradr): err                           'sid: dmp-datei mono auf sid2 abspielen
''funktionsgruppe               : sid
''funktion                      : dmp-datei auf sid2 von sd-card abspielen
''busprotokoll                  : [157][sub.putstr][get.err]
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_s_mdmpplay)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sid_sdmpplay(stradr): err                           'sid: dmp-datei stereo auf beiden sid's abspielen
''funktionsgruppe               : sid
''funktion                      : sid: dmp-datei stereo auf beiden sid's abspielen
''busprotokoll                  : [158][sub.putstr][get.err]
''                              : err - fehlernummer entspr. liste

  bus_putchar1(gc#a_s_sdmpplay)
  bus_putstr1(stradr)
  err := bus_getchar1

PUB sid_dmpstop
  bus_putchar1(gc#a_s_dmpstop)

PUB sid_dmppause
  bus_putchar1(gc#a_s_dmppause)

PUB sid_dmpstatus: status
  bus_putchar1(gc#a_s_dmpstatus)
  status := bus_getchar1

PUB sid_dmppos: wert
  bus_putchar1(gc#a_s_dmppos)
  wert := bus_getlong1
          bus_getlong1

PUB sid_dmplen: wert
  bus_putchar1(gc#a_s_dmppos)
          bus_getlong1
  wert := bus_getlong1

PUB sid_mute(sidnr)                                     'sid: chips stummschalten
  bus_putchar1(gc#a_s_mute)
  bus_putchar1(sidnr)

PUB sid_dmpreg: stradr | i                              'sid: dmp-register empfangen
' daten im puffer
' word  frequenz kanal 1
' word  frequenz kanal 2
' word  frequenz kanal 3
' byte  volume

  i := 0
  bus_putchar1(gc#a_s_dmpreg)
  repeat 7
    byte[@strpuffer + i++] := bus_getchar1
  return @strpuffer

CON ''------------------------------------------------- SIDCog1-Funktionen

PUB sid1_setRegister(reg,val)
  bus_putchar1(gc#a_s1_setRegister)
  bus_putchar1(reg)
  bus_putchar1(val)

PUB sid1_updateRegisters(regadr)|i
  bus_putchar1(gc#a_s1_updateRegisters)
  repeat 25
    bus_putchar1(byte[regadr++])

PUB sid1_setVolume(vol)
  bus_putchar1(gc#a_s1_setVolume)
  bus_putchar1(vol)

PUB sid1_play(channel, freq, waveform, attack, decay, sustain, release)
  bus_putchar1(gc#a_s1_play)
  bus_putchar1(channel)
  bus_putlong1(freq)
  bus_putchar1(waveform)
  bus_putchar1(attack)
  bus_putchar1(decay)
  bus_putchar1(sustain)
  bus_putchar1(release)

PUB sid1_noteOn(channel, freq)
  bus_putchar1(gc#a_s1_noteOn)
  bus_putchar1(channel)
  bus_putlong1(freq)

PUB sid1_noteOff(channel)
  bus_putchar1(gc#a_s1_noteOff)
  bus_putchar1(channel)

PUB sid1_setFreq(channel,freq)
  bus_putchar1(gc#a_s1_setFreq)
  bus_putchar1(channel)
  bus_putlong1(freq)

PUB sid1_setWaveform(channel,waveform)
  bus_putchar1(gc#a_s1_setWaveform)
  bus_putchar1(channel)
  bus_putchar1(waveform)

PUB sid1_setPWM(channel, val)
  bus_putchar1(gc#a_s1_setPWM)
  bus_putchar1(channel)
  bus_putlong1(val)

PUB sid1_setADSR(channel, attack, decay, sustain, release )
  bus_putchar1(gc#a_s1_setADSR)
  bus_putchar1(channel)
  bus_putchar1(attack)
  bus_putchar1(decay)
  bus_putchar1(sustain)
  bus_putchar1(release)

PUB sid1_setResonance(val)
  bus_putchar1(gc#a_s1_setResonance)
  bus_putchar1(val)

PUB sid1_setCutoff(freq)
  bus_putchar1(gc#a_s1_setCutoff)
  bus_putlong1(freq)

PUB sid1_setFilterMask(ch1,ch2,ch3)
  bus_putchar1(gc#a_s1_setFilterMask)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)

PUB sid1_setFilterType(lp,bp,hp)
  bus_putchar1(gc#a_s1_setFilterType)
  bus_putchar1(lp)
  bus_putchar1(bp)
  bus_putchar1(hp)

PUB sid1_enableRingmod(ch1,ch2,ch3)
  bus_putchar1(gc#a_s1_enableRingmod)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)

PUB sid1_enableSynchronization(ch1,ch2,ch3)
  bus_putchar1(gc#a_s1_enableSynchronization)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)
CON ''------------------------------------------------- SIDCog2-Funktionen

PUB sid2_setRegister(reg,val)
  bus_putchar1(gc#a_s2_setRegister)
  bus_putchar1(reg)
  bus_putchar1(val)

PUB sid2_updateRegisters(regadr)|i
  bus_putchar1(gc#a_s2_updateRegisters)
  repeat 25
    bus_putchar1(byte[regadr++])

PUB sid2_setVolume(vol)
  bus_putchar1(gc#a_s2_setVolume)
  bus_putchar1(vol)

PUB sid2_play(channel, freq, waveform, attack, decay, sustain, release)
  bus_putchar1(gc#a_s2_play)
  bus_putchar1(channel)
  bus_putlong1(freq)
  bus_putchar1(waveform)
  bus_putchar1(attack)
  bus_putchar1(decay)
  bus_putchar1(sustain)
  bus_putchar1(release)

PUB sid2_noteOn(channel, freq)
  bus_putchar1(gc#a_s2_noteOn)
  bus_putchar1(channel)
  bus_putlong1(freq)

PUB sid2_noteOff(channel)
  bus_putchar1(gc#a_s2_noteOff)
  bus_putchar1(channel)

PUB sid2_setFreq(channel,freq)
  bus_putchar1(gc#a_s2_setFreq)
  bus_putchar1(channel)
  bus_putlong1(freq)

PUB sid2_setWaveform(channel,waveform)
  bus_putchar1(gc#a_s2_setWaveform)
  bus_putchar1(channel)
  bus_putchar1(waveform)

PUB sid2_setPWM(channel, val)
  bus_putchar1(gc#a_s2_setPWM)
  bus_putchar1(channel)
  bus_putlong1(val)

PUB sid2_setADSR(channel, attack, decay, sustain, release )
  bus_putchar1(gc#a_s2_setADSR)
  bus_putchar1(channel)
  bus_putchar1(attack)
  bus_putchar1(decay)
  bus_putchar1(sustain)
  bus_putchar1(release)

PUB sid2_setResonance(val)
  bus_putchar1(gc#a_s2_setResonance)
  bus_putchar1(val)

PUB sid2_setCutoff(freq)
  bus_putchar1(gc#a_s2_setCutoff)
  bus_putlong1(freq)

PUB sid2_setFilterMask(ch1,ch2,ch3)
  bus_putchar1(gc#a_s2_setFilterMask)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)

PUB sid2_setFilterType(lp,bp,hp)
  bus_putchar1(gc#a_s2_setFilterType)
  bus_putchar1(lp)
  bus_putchar1(bp)
  bus_putchar1(hp)

PUB sid2_enableRingmod(ch1,ch2,ch3)
  bus_putchar1(gc#a_s2_enableRingmod)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)

PUB sid2_enableSynchronization(ch1,ch2,ch3)
  bus_putchar1(gc#a_s2_enableSynchronization)
  bus_putchar1(ch1)
  bus_putchar1(ch2)
  bus_putchar1(ch3)

CON ''------------------------------------------------- COM-Funktionen

PUB com_init(baud)                                      'com: serielle schnittstele neu initialisieren

  bus_putchar1(gc#a_comInit)
  bus_putlong1(baud)

PUB com_tx(char)                                        'com: zeichen senden

  bus_putchar1(gc#a_comTx)
  bus_putchar1(char)

PUB com_rx:char                                         'com: zeichen empfangen

  bus_putchar1(gc#a_comRx)
  char := bus_getchar1

OBJ '' B E L L A T R I X

CON ''------------------------------------------------- CHIP-MANAGMENT

PUB belsetcolor(cnr,color)                              'chip-mgr: farbregister setzen
''funktionsgruppe               : cmgr
''funktion                      : farbregister setzen
''busprotokoll                  : [cmd][put.cnr][sub_putlong.color]
''                              : cnr   - nummer des farbregisters 0..15
''                              : color - erster wert

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrsetcol)
  bus_putchar2(cnr)
  bus_putlong2(color)

PUB belgetcolor(cnr):color                              'chip-mgr: farbregister abfragen
''funktionsgruppe               : cmgr
''funktion                      : farbregister abfragen
''busprotokoll                  : [cmd][put.cnr][sub_getong.color]
''                              : cnr   - nummer des farbregisters 0..15
''                              : color - erster wert

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetcol)
  bus_putchar2(cnr)
  color := bus_getlong2


PUB belgetresx:resx                                     'chip-mgr: x-auflösung abfragen
''funktionsgruppe               : cmgr
''funktion                      : x-auflösung abfragen
''busprotokoll                  : [cmd][sub_getlong.resx]
''                              : resx - x-auflösung

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetresx)
  resx := bus_getlong2

PUB belgetresy:resy                                     'chip-mgr: y-auflösung abfragen
''funktionsgruppe               : cmgr
''funktion                      : y-auflösung abfragen
''busprotokoll                  : [cmd][sub_getlong.resy]
''                              : resy - y-auflösung

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetresy)
  resy := bus_getlong2

PUB belgetcols:cols                                     'chip-mgr: anzahl der textspalten abfragen
''funktionsgruppe               : cmgr
''funktion                      : anzahl der textspalten abfragen
''busprotokoll                  : [cmd][get.cols]
''                              : rows - anzahl der textspalten

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetcols)
  cols := bus_getchar2

PUB belgetrows:rows                                     'chip-mgr: anzahl der textzeilen abfragen
''funktionsgruppe               : cmgr
''funktion                      : anzahl der textzeilen abfragen
''busprotokoll                  : [cmd][get.rows]
''                              : rows - anzahl der textzeilen

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetrows)
  rows := bus_getchar2

PUB belgetver:ver                                       'chip-mgr: version abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''busprotokoll                  : [cmd][sub_getlong.ver]
''                              : ver - version
''
''                  +----------
''                  |  +------- system     
''                  |  |  +---- version    (änderungen)
''                  |  |  |  +- subversion (hinzufügungen)
''version       = $00_01_01_01

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetver)
  ver := bus_getlong2

PUB belgetspec:spec                                     'chip-mgr: spezifikationen abfragen
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''busprotokoll                  : [089][sub_getlong.spec]
''                              : spec - spezifikation
''
''
''                                          +---------- 
''                                          | +-------- 
''                                          | |+------- vektor
''                                          | ||+------ grafik
''                                          | |||+----- text
''                                          | ||||+---- maus
''                                          | |||||+--- tastatur
''                                          | ||||||+-- vga
''                                          | |||||||+- tv
''spezifikation = %00000000_00000000_00000000_00010110

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetspec)
  spec := bus_getlong2

PUB belgetcogs:belcogs                                  'chip-mgr: verwendete cogs abfragen

  bus_putchar2(gc#b_cmd)                                'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrgetcogs)                         'code 5 = freie cogs
  belcogs := bus_getchar2                               'statuswert empfangen

PUB belreset                                            'chip-mgr: bellatrix reset
{{breset - bellatrix neu starten}}

  bus_putchar2(gc#b_cmd)                                'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrreboot)                          'code 99 = reboot

PUB belload(stradr)| n,rc,ii,plen                       'chip-mgr: neuen bellatrix-code booten

  bus_putchar2(gc#b_cmd)                                'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrload)                            'code 87 = code laden
  waitcnt(cnt + 2_000_000)                              'warte bis bel fertig ist
  bload(stradr)
  waitcnt(cnt + 2_000_000)                              'warte bis bel fertig ist

PUB bload(stradr) | n,rc,ii,plen                        'system: bellatrix mit grafiktreiber initialisieren
{{bload(stradr) - bellatrix mit grafiktreiber initialisieren
  wird zusätzlich zu belload gebraucht, da situationen auftreten, in denen bella ohne reset (kaltstart) mit
  einem treiber versorgt werden muß. ist der bella-loader aktiv, reagiert er nicht auf das reset-kommando.
  stradr  - adresse eines 0-term-strings mit dem dateinamen des bellatrixtreibers
}}

' kopf der bin-datei einlesen                           ------------------------------------------------------
  rc := sdopen("r",stradr)                              'datei öffnen
  repeat ii from 0 to 15                                '16 bytes header --> bellatrix
    n := sdgetc
    bus_putchar2(n)
  sdclose                                               'bin-datei schießen

' objektgröße empfangen
  plen := bus_getchar2 << 8                             'hsb empfangen
  plen := plen + bus_getchar2                           'lsb empfangen

' bin-datei einlesen                                    ------------------------------------------------------
  sdopen("r",stradr)                                    'bin-datei öffnen
  repeat ii from 0 to plen-1                            'datei --> bellatrix
    n := sdgetc
    bus_putchar2(n)
  sdclose

CON ''------------------------------------------------- KEYBOARD

PUB key:wert                                            'key: holt tastaturcode
{{key:wert - key: übergibt tastaturwert}}
  bus_putchar2(gc#b_cmd)        'kommandosequenz einleiten
  bus_putchar2(gc#b_keycode)    'code 2 = tastenwert holen
  wert := bus_getchar2          'tastenwert empfangen

PUB keyspec:wert                                        'key: statustasten zum letzten tastencode
  bus_putchar2(gc#b_cmd)        'kommandosequenz einleiten
  bus_putchar2(gc#b_keyspec)    'code 2 = tastenwert holen
  wert := bus_getchar2          'wert empfangen


PUB keystat:status                                      'key: übergibt tastaturstatus
{{keystat:status - key: übergibt tastaturstatus}}
  bus_putchar2(gc#b_cmd)        'kommandosequenz einleiten
  bus_putchar2(gc#b_keystat)    'code 1 = tastaturstatus
  status := bus_getchar2        'statuswert empfangen

PUB keywait:n                                           'key: wartet bis taste gedrückt wird
{{keywait: n - key: wartet bis eine taste gedrückt wurde}}
  repeat
  until keystat > 0
  return key

PUB input(stradr,anz) | curpos,i,n                      'key: stringeingabe
{{input(stradr,anz) - key: stringeingabe}}

  curpos := curgetx                                     'cursorposition merken
  i := 0
  repeat
    n := keywait                                        'auf taste warten
    if n == $0d
       quit
    if (n == CHAR_BS)&(i>0)                             'backspace
       printbs
       i--
       byte[stradr][i] := 0
    elseif i < anz                                      'normales zeichen
       printchar(n)
       byte[stradr][i] := n
       i++
       byte[stradr][i] := 0

CON ''------------------------------------------------- SCREEN

PUB debug_belval(q)
  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(255)
  bus_putchar2(q)
  return bus_getlong2

PUB print(stringptr)                                    'screen: bildschirmausgabe einer zeichenkette (0-terminiert)
{{print(stringptr) - screen: bildschirmausgabe einer zeichenkette (0-terminiert)}}
  repeat strsize(stringptr)
    bus_putchar2(byte[stringptr++])

PUB printq(stringptr)                                   'screen: zeichenkette ohne steuerzeichen (0-terminiert)
{{print(stringptr) - screen: bildschirmausgabe einer zeichenkette (0-terminiert)}}
  repeat strsize(stringptr)
    bus_putchar2(gc#b_cmd)
    bus_putchar2(gc#b_printqchar)
    bus_putchar2(byte[stringptr++])

PUB printcstr(eadr) | i,len                             'screen: bildschirmausgabe einer zeichenkette im eram! (mit längenbyte)
{{printcstr(eadr) - screen: bildschirmausgabe einer zeichenkette im eram (mit längenbyte)}}
  len := ram_rdbyte(1,eadr)
  repeat i from 1 to len
    eadr++
    bus_putchar2(ram_rdbyte(1,eadr))
    

PUB printdec(value) | i                                 'screen: dezimalen zahlenwert auf bildschirm ausgeben
{{printdec(value) - screen: dezimale bildschirmausgabe zahlenwertes}}
  if value < 0                                          'negativer zahlenwert
    -value
    printchar("-")
  i := 1_000_000_000
  repeat 10                                             'zahl zerlegen
    if value => i
      printchar(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      bus_putchar2("0")
    i /= 10                                             'nächste stelle

PUB printhex(value, digits)                             'screen: hexadezimalen zahlenwert auf bildschirm ausgeben
{{hex(value,digits) - screen: hexadezimale bildschirmausgabe eines zahlenwertes}}
  value <<= (8 - digits) << 2
  repeat digits
    printchar(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB printbin(value, digits)                             'screen: binären zahlenwert auf bildschirm ausgeben

  value <<= 32 - digits
  repeat digits
    printchar((value <-= 1) & 1 + "0")
    
PUB printchar(c):c2                                     'screen: einzelnes zeichen auf bildschirm ausgeben
{{printchar(c) - screen: bildschirmausgabe eines zeichens}}
  bus_putchar2(c)
  c2 := c

PUB printqchar(c):c2                                    'screen: zeichen ohne steuerzeichen ausgeben
{{printqchar(c) - screen: bildschirmausgabe eines zeichens}}
  bus_putchar2(gc#b_cmd)
  bus_putchar2(gc#b_printqchar)
  bus_putchar2(c)
  c2 := c

PUB printctrl(c)                                        'screen: präfix für steuersequenzen
{{printctrl(c) - screen: steuerzeichen von $100 bis $1FF wird an terminal gesendet}}
  bus_putchar2(gc#b_cmd)        'kommandosequenz einleiten
  bus_putchar2(gc#b_printctrl)  'code 3 = sonderzeichen senden
  bus_putchar2(c & $0FF)        'unteres byte senden               '

PUB printnl                                             'screen: $0D - CR ausgeben
{{printnl - screen: $0D - CR ausgeben}}
  bus_putchar2(gc#b_crlf)
  
PUB printcls                                            'screen: screen löschen
{{printcls - screen: screen löschen}}
  printchar(gc#b_cls)

PUB curhome                                             'screen: cursorposition auf erste position setzen
{{curhome - screen: cursorposition auf erste position setzen}}
  printchar(gc#b_home)

PUB curpos1                                             'screen: setzt cursor auf spalte 1 in zeile
{{curpos1 - screen: setzt cursor auf spalte 1 in zeile}}
  printchar(gc#b_pos1)

PUB curon                                               'screen: schaltet cursor an
{{curon - screen: schaltet cursor an}}
  printchar(gc#b_curon)

PUB curoff                                              'screen: schaltet cursor aus
{{curon - screen: schaltet cursor aus}}
  printchar(gc#b_curoff)

PUB scrollup                                            'screen: scrollt screen eine zeile hoch
{{scrollup - screen: scrollt screen eine zeile hoch}}
  printchar(gc#b_scrollup)

PUB scrolldown                                          'screen: scrollt screen eine zeile runter
{{scrolldown - screen: scrollt screen eine zeile runter}}
  printchar(gc#b_scrolldown)

PUB printbs                                             'screen: backspace
{{curon - screen: backspace senden}}
  printchar(gc#b_backspace)

PUB printtab                                            'screen: zur nächsten tabulatorposition
{{printtab - screen: zur nächsten tabulatorposition}}
  printchar(gc#b_tab)

PUB printlogo(x,y)                                      'screen: logo ausgeben

  bus_putchar2(gc#b_cmd)         'kommandosequenz einleiten
  bus_putchar2(gc#b_printlogo)   'logo ausgeben
  bus_putchar2(x)
  bus_putchar2(y)
  
PUB curchar(char)                                       'screen: setzt cursorzeichen
{{curchar - screen: setzt cursorzeichen}}
  printctrl(gc#b_setcur)
  bus_putchar2(char)

PUB cursetx(x)                                          'screen: setzt cursorposition auf x
{{cursetx - screen: setzt cursorposition auf x}}
  printctrl(gc#b_setx)
  bus_putchar2(x)

PUB cursety(y)                                          'screen: setzt cursorposition auf y
{{cursety - screen: setzt cursorposition auf y}}
  printctrl(gc#b_sety)
  bus_putchar2(y)

PUB curgetx: x                                          'screen: abfrage x-position cursor
{{curgetx: x - 'screen: abfrage x-position cursor}}
  printctrl(gc#b_getx)
  return bus_getchar2

PUB curgety: y                                          'screen: abfrage y-position cursor
{{curgetx: y - 'screen: abfrage y-position cursor}}
  printctrl(gc#b_gety)
  return bus_getchar2

PUB setcolor(color)                                     'screen: farbe setzen
{{setcolor(color) - screen: setzt farbwert}}
  printctrl(gc#b_setcol)
  bus_putchar2(color)

PUB settabs(tnr,tpos)                                   'screen: setzt eine tabulatorposition
  printctrl(gc#b_tabset)
  bus_putchar2(tnr)
  bus_putchar2(tpos)

PUB set_wscr(scrnr)                                     'setzt screen, in welchen geschrieben wird
''funktion                      : schaltet die ausgabe auf einen bestimmten screen
''eingabe                       : scrnr - nummer des screens 1..SCREENS
''ausgabe                       : -
''busprotokoll                  : [0][088][put.scrnr]

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrwscr)
  bus_putchar2(scrnr)

PUB set_dscr(scrnr)                                     'setzt screen, welcher angezeigt wird
''funktion                      : schaltet die anzeige auf einen bestimmten screen
''eingabe                       : scrnr - nummer des screens 1..SCREENS
''ausgabe                       : -
''busprotokoll                  : [0][088][put.scrnr]

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_mgrdscr)
  bus_putchar2(scrnr)

PUB windefine(w, x0, y0, xn, yn)                        'window: fenster definieren
''funktionsgruppe               : window
''funktion                      : Window (=Scroll-Region) festlegen
''busprotokoll                  : [cmd][put.winnum][put.x0][put.y0][put.xn][put.yn]

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_wdef)
  bus_putchar2(w)
  bus_putchar2(x0)
  bus_putchar2(y0)
  bus_putchar2(xn)
  bus_putchar2(yn)

PUB winset(w)                                           'window: aktives fenster wählen
''funktionsgruppe               : window
''funktion                      : vordefiniertes Window (=Scroll-Region) auswählen
''busprotokoll                  : [cmd][put.winnum]

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_wset)
  bus_putchar2(w)

PUB wingetcols:cols                                     'window: anzahl der textspalten abfragen
''funktionsgruppe               : window
''funktion                      : anzahl der textspalten abfragen
''busprotokoll                  : [cmd][get.wincols]
''                              : cols - anzahl der textspalten

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_wgetcols)
  cols := bus_getchar2

PUB wingetrows:rows                                     'window: anzahl der textzeilen abfragen
''funktionsgruppe               : window
''funktion                      : anzahl der textzeilen abfragen
''busprotokoll                  : [cmd][get.winrows]
''                              : rows - anzahl der textzeilen

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_wgetrows)
  rows := bus_getchar2

PUB winoframe                                           'window: rahmen zeichnen
''funktionsgruppe               : window
''funktion                      : Rahmen ausserhalb des aktuellen Window zeichnen
''busprotokoll                  : [cmd]

  bus_putchar2(gc#b_cmd)                                 'kommandosequenz einleiten
  bus_putchar2(gc#b_woframe)

PUB wincursetx(x)                                       'screen: setzt cursorposition auf x
{{cursetx - screen: setzt cursorposition auf x}}
  printctrl(gc#b_wsetx)
  bus_putchar2(x)

PUB wincursety(y)                                       'screen: setzt cursorposition auf y
{{cursety - screen: setzt cursorposition auf y}}
  printctrl(gc#b_wsety)
  bus_putchar2(y)

PUB wincurgetx: x                                       'screen: abfrage x-position cursor
{{curgetx: x - 'screen: abfrage x-position cursor}}
  printctrl(gc#b_wgetx)
  return bus_getchar2

PUB wincurgety: y                                       'screen: abfrage y-position cursor
{{curgetx: y - 'screen: abfrage y-position cursor}}
  printctrl(gc#b_wgety)
  return bus_getchar2


PUB screeninit                                          'screen: löschen, kopfzeile ausgeben und setzen
{{screeninit(stradr,n) - screen löschen, kopfzeile ausgeben und setzen}}
  curoff
  printctrl(gc#b_sinit)
  ifnot (belgetspec & 1)        'wenn kein tv-modus
    printnl
    printlogo(0,0)
  curhome
  curon
  ram_wrbyte(0,0,SIFLAG)


OBJ '' R E G N A T I X

CON ''------------------------------------------------- BUS
'prop 1  - administra   (bus_putchar1, bus_getchar1)
'prop 2  - bellatrix    (bus_putchar2, bus_getchar2)

PUB bus_init                                            'bus: initialisiert bussystem
{{bus_init - bus: initialisierung aller bussignale }}
  outa[bus_wr]    := 1          ' schreiben inaktiv
  outa[reg_ram1]  := 1          ' ram1 inaktiv
  outa[reg_ram2]  := 1          ' ram2 inaktiv
  outa[reg_prop1] := 1          ' prop1 inaktiv
  outa[reg_prop2] := 1          ' prop2 inaktiv
  outa[busclk]    := 0          ' busclk startwert
  outa[reg_al]    := 0          ' strobe aus
  dira := db_in                 ' datenbus auf eingabe schalten
  outa[18..8]     := 0          ' adresse a0..a10 auf 0 setzen
  outa[23]        := 1          ' obere adresse in adresslatch übernehmen
  outa[23]        := 0

PUB bus_putchar1(c)                                     'bus: byte an administra senden
{{bus_putchar1(c) - bus: byte senden an prop1 (administra)}}
  outa := %00001000_01011000_00000000_00000000          'prop1=0, wr=0
  dira := db_out                                        'datenbus auf ausgabe stellen
  outa[7..0] := c                                       'daten --> dbus
  outa[busclk] := 1                                     'busclk=1
  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
  dira := db_in                                         'bus freigeben
  outa := %00001100_01111000_00000000_00000000           'wr=1, prop1=1, busclk=0

PUB bus_getchar1: wert                                  'bus: byte vom administra empfangen
{{bus_getchar1:wert - bus: byte empfangen von prop1 (administra)}}
  outa := %00000110_01011000_00000000_00000000          'prop1=0, wr=1, busclk=1
  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
  wert := ina[7..0]                                     'daten einlesen
  outa := %00000100_01111000_00000000_00000000          'prop1=1, busclk=0

PUB bus_getword1: wert                                  'bus: 16 bit von administra empfangen hsb/lsb

  wert := bus_getchar1 << 8
  wert := wert + bus_getchar1

PUB bus_putword1(wert)                                  'bus: 16 bit an administra senden hsb/lsb

   bus_putchar1(wert >> 8)
   bus_putchar1(wert)

PUB bus_getlong1: wert                                  'bus: long von administra empfangen hsb/lsb

  wert :=        bus_getchar1 << 24                     '32 bit empfangen hsb/lsb
  wert := wert + bus_getchar1 << 16
  wert := wert + bus_getchar1 << 8
  wert := wert + bus_getchar1

PUB bus_putlong1(wert)                                  'bus: long zu administra senden hsb/lsb

   bus_putchar1(wert >> 24)                             '32bit wert senden hsb/lsb
   bus_putchar1(wert >> 16)
   bus_putchar1(wert >> 8)
   bus_putchar1(wert)

PUB bus_getstr1: stradr | len,i                         'bus: string von administra empfangen

    len  := bus_getchar1                                'längenbyte empfangen
    repeat i from 0 to len - 1                          '20 zeichen dateinamen empfangen
      strpuffer[i] := bus_getchar1
    strpuffer[i] := 0
    return @strpuffer

PUB bus_putstr1(stradr) | len,i                         'bus: string zu administra senden

  len := strsize(stradr)
  bus_putchar1(len)
  repeat i from 0 to len - 1
    bus_putchar1(byte[stradr++])

PUB bus_putchar2(c)                                     'bus: byte an prop1 (bellatrix) senden
{{bus_putchar2(c) - bus: byte senden an prop2 (bellatrix)}}
  outa := %00001000_00111000_00000000_00000000          'prop2=0, wr=0
  dira := db_out                                        'datenbus auf ausgabe stellen
  outa[7..0] := c                                       'daten --> dbus
  outa[busclk] := 1                                     'busclk=1
  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
  dira := db_in                                         'bus freigeben
  outa := %00001100_01111000_00000000_00000000           'wr=1, prop2=1, busclk=0

PUB bus_getchar2: wert                                  'bus: byte vom prop1 (bellatrix) empfangen
{{bus_getchar2:wert - bus: byte empfangen von prop2 (bellatrix)}}
  outa := %00000110_00111000_00000000_00000000          'prop2=0, wr=1, busclk=1
  waitpeq(%00000000_00000000_00000000_00000000,%00001000_00000000_00000000_00000000,0) 'hs=0?
  wert := ina[7..0]                                     'daten einlesen
  outa := %00000100_01111000_00000000_00000000          'prop2=1, busclk=0

PUB bus_getword2: wert                                  'bus: 16 bit von bellatrix empfangen hsb/lsb

  wert := bus_getchar2 << 8
  wert := wert + bus_getchar2

PUB bus_putword2(wert)                                  'bus: 16 bit an bellatrix senden hsb/lsb

   bus_putchar2(wert >> 8)
   bus_putchar2(wert)

PUB bus_getlong2: wert                                  'bus: long von bellatrix empfangen hsb/lsb

  wert :=        bus_getchar2 << 24                     '32 bit empfangen hsb/lsb
  wert := wert + bus_getchar2 << 16
  wert := wert + bus_getchar2 << 8
  wert := wert + bus_getchar2

PUB bus_putlong2(wert)                                  'bus: long an bellatrix senden hsb/lsb

   bus_putchar2(wert >> 24)                             '32bit wert senden hsb/lsb
   bus_putchar2(wert >> 16)
   bus_putchar2(wert >> 8)
   bus_putchar2(wert)

CON ''------------------------------------------------- eRAM/SPEICHERVERWALTUNG
{

Und so funktioniert es: Der Speicher (hier geht es nur um den eRAM!) ist in drei Teile gesplittet:

    1. Ramdisk
    2. Heap
    3. Systemvariablen

Wofür ist das jetzt gut?

Das unkomlizierte Speichermodell: Wenn man in seinem Programm unkompliziert Speicher braucht, der nicht resident
gehalten werden muss, nutzt man einfach die Routinen ram_* um auf diesen zuzugreifen. Nach dem Beenden
des Programms ist dieser Speicher (Heap) aber dann vogelfrei. Für die Adressierung mit diesen Routinen gibt es
zwei Modis:

     1. sysmod - Hier entspricht die Adresse 0 auch der wirklichen physischen Adresse 0.
     2. usrmod - Hier entspricht die Adresse 0 dem Wert von "rbas" - ist also virtuell.

In einem normalen Programm wird man den usrmod verwenden und nur auf den freien Speicher (Heap) zwischen rbas
und rend zugreifen. Das klingt im ersten Moment kompliziert, ist aber ganz einfach: wenn es einfach sein soll,
arbeite ich im usrmod und bekomme von Adresse 0000..nnnn den Bereich zwischen Ramdisk und den Systemvariablen
(rbas..rend) zu "sehen". Möchte aber ein Systemprogramm zum Beispiel auf die Systemvariablen oder die Internas
der Ramdisk zugreifen, so ist der sysmod gefragt. In diesem Modus wird der eRAM direkt adressiert.

Die Ramdisk: Braucht die Anwendung aber residenten Speicher, so kann man sich einen Speicherblock als
Datei in der Ramdisk erzeugen und auf den Inhalt auch per direkter Adressierung mit rd_rdbyte/rd_wrbyte
zugreifen. In der Kommandozeile Regime ist es dann möglich, per xdir/xload und xsave auf diesen Speicher
bzw. Dateien zuzugreifen.

Ach ja: Mit der Ramdisk ist es auch möglich mehrere Dateien zu öffnen und zu verwenden - rd_open liefert dafür
eine Filenummer fnr, die man bei allen Operationen benutzen muss! :)

Wichtig ist es nur zu verstehen, dass der freie Speicher bei Verwendung der Ramdisk vogelfrei ist,
wenn die Anwendung beendet wird: Speichert ein Programm dort Daten und kehrt zur Kommandozeile zurück,
wird zum Beispiel durch laden oder speichern einer Datei in der Ramdisk die Variable "rbas" und
damit der freie Bereich in seiner Größe verändert ---> unsere Daten im freien Bereich befinden sich also nun
im usrmod an einer anderen Stelle oder sind überschrieben.


  memory-map:

  0000   -->    datei 1                                 'ab adresse 0 liegen die dateien der ramdisk als
                datei 2                                 'verkettete liste. das erste freie byte hinter der
                ...                                     'wird mit der variable "rbas" definiert.
                datei n

  rbas   -->    usermem start                           'zwischen rbas und rend liegt der freie ram.
                ...
  rend   -->    usermen ende

  sysvar -->    systemvariablen                         'ab dieser adresse befinden sich die systemvariablem im eram


  aufbau datei ramdisk:

  1  long       zeiger auf nächste datei                (oder 0 bei letzter datei)
  1  long       datenlänge
  12 byte       dateiname                               8+3-string
  nn byte       daten

  aufbau ftab:

  fnr                           dateinummer

  fnr 0         usermem
  fnr 1..7      dateien

  fix := fnr * FCNT             index in ftab

  ftab[fix+0]   startadresse daten
  ftab[fix+1]   endadresse daten
  ftab[fix+2]   position in datei
}

CON

  STARTRD       = 0             'startadresse der ramdisk
  FILES         = 8             'maximale anzahl von RAMDisk-Dateien, die gleichzeitig geöffnet werden können
  FTCNT         = 3             'anzahl longs pro eintrag

  sysmod        = 0
  usrmod        = 1

  RDHLEN        = 20            ' 4+4+12 - headerlänge

VAR

  long  ftab[(files)*FTCNT]     'filedeskriptortabelle
                                '1. long = startadresse daten
                                '2. long = endadresse daten
                                '3. long = position in der datei
  long  dpos                    'position im dir (dir/next)
  byte  dstr[13]                'string für dateinamen

DAT

'rdinit  byte  "ramdisk1.ram",0
rdinit  byte  "[RAMDRIVE]  ",0

PUB rd_open(stradr):fnr | adr,eadr,fix                  'ramdisk: datei öffnen
'fnr = 0  - fehler
'fnr > 0  - nummer der geöffneten datei

  'datei suchen, adresse ermitteln
  ifnot adr := rd_searchadr(stradr)
    return 0

  'freien eintrag in ftab suchen
  fix := 0
  repeat FILES
    if ftab[fix] == -1
      quit
    fix += 3

  if fix > FILES * FTCNT
    return -1

  'eintrag setzen
  if (eadr := ram_rdlong(sysmod,adr))
    eadr--                                              'nicht letzte datei
  else
    eadr := rbas -1                                     'letzte datei (zeiger = 0), es folgt usermem

  ftab[fix+0] := adr + RDHLEN                           'startadresse daten
  ftab[fix+1] := eadr                                   'endadresse daten
  ftab[fix+2] := 0                                      'position rücksetzen

  fnr := fix/3

PUB rd_close(fnr) | fix                                 'ramdisk: datei schliessen

  if (fnr > 0) AND (fnr =< FILES)
    fix := fnr * FTCNT
    ftab[fix+0] := -1                                   'startadresse daten
    ftab[fix+1] := -1                                   'endadresse daten
    ftab[fix+2] := -1                                   'position

PUB rd_getftab(fix): wert                               'ramdisk: ftab auslesen

  wert := ftab[fix]

PUB rd_getinit: flag                                    'ramdisk: abfrage ob rd initialisiert ist

  return ram_rdbyte(sysmod,RAMDRV)

PUB rd_newfile(stradr,len) | adr1,adr2,i,char,nx        'ramdisk: neue datei erzeugen
'
' dpos --> 4   byte - (zeiger auf next eintrag)
'          4   byte - dateilänge
'          12  byte - name 8+3
'          len byte - daten

  if ram_rdbyte(sysmod,RAMDRV)

    'zeiger auf header der letzten datei setzen
    adr1 := 0
    repeat
      nx := ram_rdlong(sysmod,adr1)
      if nx
        adr1 := nx
    until nx == 0                                       'letzter zeiger ist 0

    'header der neuen datei setzen
    adr2 := adr1 + ram_rdlong(sysmod,adr1+4) + RDHLEN   'startadresse der neuen datei
    ram_wrlong(sysmod,0,adr2)                           'neuer zeiger wird nun 0 (letzte datei)
    ram_wrlong(sysmod,len,adr2+4)                       'länge der datei

    'dateinamen setzen
    i := adr2 + 8
    repeat 12                                           'alle zeichen löschen
      ram_wrbyte(sysmod," ",i++)
    i := 0
    repeat 12                                           'string mit namen übertragen
      char := byte[stradr+i]
      ifnot char
        quit
      ram_wrbyte(sysmod,char,adr2+8+i++)

    'rbas hinter neue datei setzen
    ram_setbas(adr2 + RDHLEN + len)

    'pointer in vorigem header setzen
    ram_wrlong(sysmod,adr2,adr1)

PUB rd_init|i,j                                         'ramdisk: system initialisieren

  ifnot ram_rdbyte(sysmod,RAMDRV)

    i := STARTRD
    ram_wrlong(sysmod,0,i)                                'zeiger schreiben (letzter zeiger ist 0)
    i += 4
    ram_wrlong(sysmod,1,i)                                'dateilänge schreiben
    i += 4
    repeat j from 0 to 11                                 'namen schreiben
      ram_wrbyte(sysmod,byte[@rdinit+j],i++)
    ram_wrbyte(sysmod,0,i++)                              '1 datenbyte
    ram_setbas(i)                                         'neue basis für userbereich setzen
    ram_wrbyte(sysmod,1,RAMDRV)                           'globales Flag setzen

    'ftab löschen
    i := 0
    repeat files * FTCNT
      ftab[i++] := -1

  ftab[0] := ram_getbas                                   'erster eintrag ist userram
  ftab[1] := ram_getend
  ftab[2] := 0

PUB rd_del(stradr):err | adr,d,s,nx,len,blk             'ramdisk: datei löschen

  'grösse berechnen
  if (adr := rd_searchadr(stradr)) > 0
    err := 0
    len := ram_rdlong(sysmod, adr+4) + RDHLEN
    nx  := ram_rdlong(sysmod,adr)
    blk := ram_getbas - nx

    'block verschieben/löschen
    if nx
      d   := adr
      s   := adr + len
      repeat blk
        ram_wrbyte(sysmod,ram_rdbyte(sysmod,s++),d++)

    'fbas neu setzen
    ram_setbas(ram_getbas - len)

    'verlinkung in der liste aktualisieren
    ifnot nx
      'neu letzte datei markieren, wenn gelöschte datei die letzte war
      adr := 0
      repeat until ram_rdlong(sysmod,adr) == ram_getbas
        adr := ram_rdlong(sysmod,adr)
      ram_wrlong(sysmod,0,adr)
    else
      'header der nachfolgenden dateien neu setzen
      repeat while ram_rdlong(sysmod,adr)
        nx := ram_rdlong(sysmod,adr)
        nx := nx - len
        ram_wrlong(sysmod,nx,adr)
        adr := nx
  else
    err := 5
  return err

PUB rd_rename(stradr1,stradr2): err | i,adr,char        'ramdisk: datei umbenennen

    err := 0
    'datei suchen, adresse ermitteln
    ifnot adr := rd_searchadr(stradr1)
      return 5

    'neuen namen setzen
    i := adr + 8
    repeat 12                                           'alle zeichen löschen
      ram_wrbyte(sysmod," ",i++)
    i := 0
    repeat 12                                           'string mit namen übertragen
      char := byte[stradr2+i]
      ifnot char
        quit
      ram_wrbyte(sysmod,char,adr+8+i++)


PUB rd_searchdat(stradr):adr                            'ramdisk: name --> adresse daten

  if (adr := rd_searchadr(stradr))
    return adr + RDHLEN

PUB rd_searchadr(stradr):adr | hp,nx,i,j,c              'ramdisk: name --> adresse header
' adr = 0    name nicht gefunden
' adr > 0    adresse des headers

  hp  := STARTRD
  adr := STARTRD
  repeat
    nx := ram_rdlong(sysmod,hp)

    'string kopieren
    i := 0
    j := hp + 8
    repeat
      c := ram_rdbyte(sysmod,j+i)
      if c == " "
        c := 0
      dstr[i++] := c
    until (i == 12) OR (c == " ")
    dstr[i] := 0

    'string vergleichen
    if strcomp(stradr,@dstr)
      adr := hp

    hp := nx

  until (nx == 0) OR (adr > 0)
  dpos := adr
  return adr

PUB rd_get(fnr): wert | adr,fix                         'ramdisk: nächstes byte aus datei lesen

  fix := fnr * FTCNT
  adr := ftab[fix+0] + ftab[fix+2]
  wert := ram_rdbyte(sysmod,adr)
  rd_seek(fnr,ftab[fix+2]+1)

PUB rd_getback(fnr): wert | adr,fix                     'ramdisk: voriges byte aus datei lesen

  fix := fnr * FTCNT
  adr := ftab[fix+0] + ftab[fix+2]
  wert := ram_rdbyte(sysmod,adr-1)
  rd_seek(fnr,ftab[fix+2]-1)

PUB rd_put(fnr,wert) | adr,fix                          'ramdisk: nächstes byte in datei schreiben

  fix := fnr * FTCNT
  adr := ftab[fix+0] + ftab[fix+2]
  ram_wrbyte(sysmod,wert,adr)
  rd_seek(fnr,ftab[fix+2]+1)

PUB rd_seek(fnr,fpos) | len,fix                         'ramdisk: position in datei setzen

  fix := fnr * FTCNT
  len := ftab[fix+1] - ftab[fix]
  if (fpos => 0) AND (fpos =< len)
    ftab[fix+2] := fpos                                 'ramdisk: position in datei setzen

PUB rd_rdbyte(fnr,adr):wert | fix                       'ramdisk: byte aus datei lesen

  fix := fnr * FTCNT
  adr := ftab[fix]+adr
  if (adr =< ftab[fix+1])
    wert := ram_rdbyte(sysmod,adr)

PUB rd_wrbyte(fnr,wert,adr) | fix                       'ramdisk: byte in datei schreiben
  fix := fnr * FTCNT
  adr := ftab[fix]+adr
  if (adr =< ftab[fix+1])
    ram_wrbyte(sysmod,wert,adr)

PUB rd_len(fnr): len | fix                              'ramdisk: dateilänge einer geöffgneten datei abfragen

  fix := fnr * FTCNT
  len := ftab[fix+1] - ftab[fix+0] + 1

PUB rd_dlen: len                                        'ramdisk: verzeichnis dateilänge abfragen

  len := ram_rdlong(sysmod,dpos+4)

PUB rd_dir                                              'ramdisk: verzeichnis öffnen

  dpos := STARTRD

PUB rd_next:stradr | i,j                                'ramdisk: verzeichniseintrag lesen

  'ende erreicht?
  if dpos == TRUE
    return 0

  'namen kopieren
  i := 0
  j := dpos + 8
  repeat 12
    dstr[i] := ram_rdbyte(sysmod,j+i)
    i++
  byte[@dstr+i] := 0

  'zeiger auf nächste datei setzen
  dpos := ram_rdlong(sysmod,dpos)
  if dpos == 0
    dpos := TRUE                                        'nächster eintrag ungültig
  return @dstr                                          'gültiger name

PUB absadr(usradr): sysadr                              'ramdisk: wandelt usermode-adr --> absolutadr

  sysadr := usradr - rbas

PUB ram_getbas: adr                                     'ramdisk: virtuelle basisadresse abfragen
  'return rbas
  return ram_rdlong(sysmod,RAMBAS)

PUB ram_getend: adr                                     'ramdisk: endadresse abfragen
  'return rend
  return ram_rdlong(sysmod,RAMEND)

PUB ram_getfree: free                                   'ramdisk: freien speicher ermitteln

  return ram_rdlong(sysmod,RAMEND) - ram_rdlong(sysmod,RAMBAS)

PUB ram_setbas(adr)                                     'ramdisk: virtuelle basisadresse setzen
  ram_wrlong(sysmod,adr,RAMBAS)
  rbas := adr
  ftab[0] := adr                                        'erster eintrag ist userram
  ftab[1] := SYSVAR - adr

PUB ram_rdbyte(sys,adresse):wert                        'eram: liest ein byte vom eram
{{ram_rdbyte(adresse):wert - eram: ein byte aus externem ram lesen}}
'rambank 1                      000000 - 07FFFF
'rambank 2                      080000 - 0FFFFF
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse
'sysmodus: der gesamte speicher (2 x 512 KB) werden durchgängig adressiert
'usermodus: adresse 0   = rambas
'           adresse max = ramend

  if sys                                  'usermodus?
    adresse += rbas                       'adresse virtualisieren
    if adresse > rend                     'adressbereich überschritten?
      return 0

  outa[15..8] := adresse >> 11            'höherwertige adresse setzen
  outa[23] := 1                           'obere adresse in adresslatch übernehmen
  outa[23] := 0
  outa[18..8] := adresse                  'niederwertige adresse setzen
  if adresse < $080000                    'rambank 1?
    outa[reg_ram1] := 0                   'ram1 selektieren (wert wird geschrieben)
    wert := ina[7..0]                     'speicherzelle einlesen
    outa[reg_ram1] := 1                   'ram1 deselektieren
  else
    outa[reg_ram2] := 0                   'ram2 selektieren (wert wird geschrieben)
    wert := ina[7..0]                     'speicherzelle einlesen
    outa[reg_ram2] := 1                   'ram2 deselektieren
     
PUB ram_wrbyte(sys,wert,adresse)                        'eram: schreibt ein byte in eram
{{ram_wrbyte(wert,adresse) - eram: ein byte in externen ram schreiben}}
'rambank 1                      000000 - 07FFFF
'rambank 2                      080000 - 08FFFF
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse
'sysmodus: der gesamte speicher (2 x 512 KB) werden durchgängig adressiert
'usermodus: adresse 0   = rambas
'           adresse max = ramend
'

  if sys                                  'usermodus?
    adresse += rbas                       'adresse virtualisieren
    if adresse > rend                     'adressbereich überschritten?
      return

  outa[bus_wr] := 0                       'schreiben aktivieren
  dira := db_out                          'datenbus --> ausgang
  outa[7..0] := wert                      'wert --> datenbus
  outa[15..8] := adresse >> 11            'höherwertige adresse setzen
  outa[23] := 1                           'obere adresse in adresslatch übernehmen
  outa[23] := 0
  outa[18..8] := adresse                  'niederwertige adresse setzen
  if adresse < $080000                    'rambank 1?
    outa[reg_ram1] := 0                   'ram1 selektieren (wert wird geschrieben)
    outa[reg_ram1] := 1                   'ram1 deselektieren
  else
    outa[reg_ram2] := 0                   'ram2 selektieren (wert wird geschrieben)
    outa[reg_ram2] := 1                   'ram2 deselektieren
  dira := db_in                           'datenbus --> eingang
  outa[bus_wr] := 1                       'schreiben deaktivieren

PUB ram_rdlong(sys,eadr): wert                          'eram: liest long ab eadr
{{ram_rdlong - eram: liest long ab eadr}}
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse

  wert := ram_rdbyte(sys,eadr)
  wert += ram_rdbyte(sys,eadr + 1) << 8
  wert += ram_rdbyte(sys,eadr + 2) << 16
  wert += ram_rdbyte(sys,eadr + 3) << 24

PUB ram_rdword(sys,eadr): wert                          'eram: liest word ab eadr
{{ram_rdlong(eadr):wert - eram: liest word ab eadr}}
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse

  wert := ram_rdbyte(sys,eadr)
  wert += ram_rdbyte(sys,eadr + 1) << 8

PUB ram_wrlong(sys,wert,eadr) | n                       'eram: schreibt long ab eadr
{{ram_wrlong(wert,eadr) - eram: schreibt long ab eadr}}
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse

  n := wert & $FF
  ram_wrbyte(sys,n,eadr)
  n := (wert >> 8) & $FF
  ram_wrbyte(sys,n,eadr + 1)
  n := (wert >> 16) & $FF
  ram_wrbyte(sys,n,eadr + 2)
  n := (wert >> 24) & $FF
  ram_wrbyte(sys,n,eadr + 3)

PUB ram_wrword(sys,wert,eadr) | n                       'eram: schreibt word ab eadr
{{wr_word(wert,eadr) - eram: schreibt word ab eadr}}
'sys = 0 - systemmodus, keine virtualisierung
'sys = 1 - usermodus, virtualisierte adresse

  n := wert & $FF
  ram_wrbyte(sys,n,eadr)
  n := (wert >> 8) & $FF
  ram_wrbyte(sys,n,eadr + 1)
 
CON ''------------------------------------------------- TOOLS

PUB hram_print(adr,rows)

  repeat rows
    printnl
    printhex(adr,4)
    printchar(":")
    printchar(" ")
    repeat 8
      printhex(byte[adr++],2)
      printchar(" ")
    adr := adr - 8
    repeat 8
      printqchar(byte[adr++])

CON ''------------------------------------------------- G0-FUNKTIONEN

CON 'G0-Konstanen

g0_xtiles       = 16
g0_ytiles       = 12

PUB g0_keystat:wert                                     'g0: tastaturstatus abfragen
  bus_putchar2(gc#g0_keystat)
  return bus_getchar2

PUB g0_keycode:wert                                     'g0: tastaturcode abfragen
  bus_putchar2(gc#g0_keycode)
  return bus_getchar2

PUB g0_keyspec:wert                                     'g0: sondertasten abfragen
  bus_putchar2(gc#g0_keyspec)
  return bus_getchar2

PUB g0_keywait:wert                                     'g0: warten auf taste
  repeat until keystat > 0
  return g0_keycode

PUB g0_clear                                            'g0: aktiven screenpuffer löschen
  bus_putchar2(gc#g0_clear)

PUB g0_copy                                             'g0: zeichenpuffer --> anzeigepuffer
  bus_putchar2(gc#g0_copy)

PUB g0_color(n)                                         'g0: zeichenfarbe wählen

'' Set pixel color to two-bit pattern
''
''   c              - color code in bits[1..0]

  bus_putchar2(gc#g0_color)
  bus_putchar2(n)

PUB g0_width(n)                                         'g0: stiftbreite setzen

'' Set pixel width
'' actual width is w[3..0] + 1
''
''   w              - 0..15 for round pixels, 16..31 for square pixels

  bus_putchar2(gc#g0_width)
  bus_putchar2(n)

PUB g0_colorwidth(n,m)                                  'g0: zeichenfarbe/stiftbreite setzen
  bus_putchar2(gc#g0_colorwidth)
  bus_putchar2(n)
  bus_putchar2(m)

PUB g0_plot(x,y)                                        'g0: punkt zeichen
  bus_putchar2(gc#g0_plot)
  bus_putchar2(x)
  bus_putchar2(y)

PUB g0_line(x,y)                                        'g0: linie zu punkt zeichnen

'' Draw a line to point
''
''   x,y            - endpoint

  bus_putchar2(gc#g0_line)
  bus_putchar2(x)
  bus_putchar2(y)

PUB g0_arc(x,y,xr,yr,angle,anglestep,steps,arcmode)     'g0: kreis zeichnen
'17: gr.arc(gc,gc,gc,gc,gw,gw,gc,gc)

'' Draw an arc
''
''   x,y            - center of arc
''   xr,yr          - radii of arc
''   angle          - initial angle in bits[12..0] (0..$1FFF = 0°..359.956°)
''   anglestep      - angle step in bits[12..0]
''   steps          - number of steps (0 just leaves (x,y) at initial arc position)
''   arcmode        - 0: plot point(s)
''                    1: line to point(s)
''                    2: line between points
''                    3: line from point(s) to center

  bus_putchar2(gc#g0_arc)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(xr)
  bus_putchar2(yr)
  bus_putword2(angle)
  bus_putword2(anglestep)
  bus_putchar2(steps)
  bus_putchar2(arcmode)

PUB g0_vec(x,y,vecscale,vecangle,heap_index)            'g0: vektorsprite zeichnen

'' Draw a vector sprite
''
''   x,y            - center of vector sprite
''   vecscale       - scale of vector sprite ($100 = 1x)
''   vecangle       - rotation angle of vector sprite in bits[12..0]
''   heap_index     - heapindex to sprite definition
''
''
'' Vector sprite definition:
''
''    word    $8000|$4000+angle       'vector mode + 13-bit angle (mode: $4000=plot, $8000=line)
''    word    length                  'vector length
''    ...                             'more vectors
''    ...
''    word    0                       'end of definition

  bus_putchar2(gc#g0_vec)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(vecscale)
  bus_putword2(vecangle)
  bus_putword2(heap_index)

PUB g0_vecarc(x,y,xr,yr,angle,vscale,vangle,heap_index) 'g0: vektorsprite an kreisposition zeichnen

'' Draw a vector sprite at an arc position
''
''   x,y            - center of arc
''   xr,yr          - radii of arc
''   angle          - angle in bits[12..0] (0..$1FFF = 0°..359.956°)
''   vscale         - scale of vector sprite ($100 = 1x)
''   vangle         - rotation angle of vector sprite in bits[12..0]
''   heap_index     - heapindex to sprite definition

  bus_putchar2(gc#g0_vecarc)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(xr)
  bus_putchar2(yr)
  bus_putword2(angle)
  bus_putchar2(vscale)
  bus_putword2(vangle)
  bus_putword2(heap_index)

PUB g0_pix(x,y,pixrot,heap_index)                       'g0: pixelsprite zeichnen

'' Draw a pixel sprite
''
''   x,y            - center of vector sprite
''   pixrot         - 0: 0°, 1: 90°, 2: 180°, 3: 270°, +4: mirror
''   heap_index     - heapindex to sprite definition
''
''
'' Pixel sprite definition:
''
''    word                            'word align, express dimensions and center, define pixels
''    byte    xwords, ywords, xorigin, yorigin
''    word    %%xxxxxxxx,%%xxxxxxxx
''    word    %%xxxxxxxx,%%xxxxxxxx
''    word    %%xxxxxxxx,%%xxxxxxxx
''    ...

  bus_putchar2(gc#g0_pix)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(pixrot)
  bus_putword2(heap_index)

PUB g0_pixarc(x,y,xr,yr,angle,pixrot,heap_index)        'g0: pixelsprite an kreisposition zeichnen

'' Draw a pixel sprite at an arc position
''
''   x,y            - center of arc
''   xr,yr          - radii of arc
''   angle          - angle in bits[12..0] (0..$1FFF = 0°..359.956°)
''   pixrot         - 0: 0°, 1: 90°, 2: 180°, 3: 270°, +4: mirror
''   heap_index     - heapindex to sprite definition

  bus_putchar2(gc#g0_pixarc)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(xr)
  bus_putchar2(yr)
  bus_putword2(angle)
  bus_putchar2(pixrot)
  bus_putword2(heap_index)

PUB g0_text(x,y,heap_index)                             'g0: text zeichnen

'' Draw text
''
''   x,y            - text position (see textmode for sizing and justification)
''   heap_index     - heapindex to 0term-sting

  bus_putchar2(gc#g0_text)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putword2(heap_index)

PUB g0_textarc(x,y,xr,yr,angle,heap_index)              'g0: text an kreisposition zeichnen

'' Draw text at an arc position
''
''   x,y            - center of arc
''   xr,yr          - radii of arc
''   angle          - angle in bits[12..0] (0..$1FFF = 0°..359.956°)
''   heap_index     - heapindex to 0term-sting


  bus_putchar2(gc#g0_textarc)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(xr)
  bus_putchar2(yr)
  bus_putword2(angle)
  bus_putword2(heap_index)

PUB g0_textmode(x_scale,y_scale,spacing,justification)  'g0: textparameter setzen

'' Set text size and justification
''
''   x_scale        - x character scale, should be 1+
''   y_scale        - y character scale, should be 1+
''   spacing        - character spacing, 6 is normal
''   justification  - bits[1..0]: 0..3 = left, center, right, left
''                    bits[3..2]: 0..3 = bottom, center, top, bottom

  bus_putchar2(gc#g0_textmode)
  bus_putchar2(x_scale)
  bus_putchar2(y_scale)
  bus_putchar2(spacing)
  bus_putchar2(justification)

PUB g0_box(x, y, box_width, box_height)                 'g0: rechteck zeichnen

'' Draw a box with round/square corners, according to pixel width
''
''   x,y            - box left, box bottom

  bus_putchar2(gc#g0_box)
  bus_putchar2(x)
  bus_putchar2(y)
  bus_putchar2(box_width)
  bus_putchar2(box_height)

PUB g0_quad(x1, y1, x2, y2, x3, y3, x4, y4)             'g0: viereck zeichnen

'' Draw a solid quadrilateral
'' vertices must be ordered clockwise or counter-clockwise

  bus_putchar2(gc#g0_quad)
  bus_putchar2(x1)
  bus_putchar2(y1)
  bus_putchar2(x2)
  bus_putchar2(y2)
  bus_putchar2(x3)
  bus_putchar2(y3)
  bus_putchar2(x4)
  bus_putchar2(y4)

PUB g0_tri(x1, y1, x2, y2, x3, y3)                      'g0: dreieck zeichnen

'' Draw a solid triangle

  bus_putchar2(gc#g0_tri)
  bus_putchar2(x1)
  bus_putchar2(y1)
  bus_putchar2(x2)
  bus_putchar2(y2)
  bus_putchar2(x3)
  bus_putchar2(y3)

PUB g0_printdec(x,y,n,digit,string_ptr,heap_index)|i,j,m'g0: dezimalzahl ausgeben

  j := n
  repeat i from digit-1 to 0
    m := j//10
    ifnot m < 0
      byte[string_ptr + heap_index][i] := m + "0"
    j := j / 10
  byte[string_ptr + heap_index][digit] := 0
  g0_datblk(string_ptr,heap_index,digit+1)
  g0_text(x,y,heap_index)

PUB g0_colortab(ptr)|i                                  'g0: farbtabelle senden

  bus_putchar2(gc#g0_colortab)
  i := 0
  repeat 64
    bus_putlong2(long[ptr][i++])


PUB g0_screen(ptr)|i                                    'g0: tilescreen senden

  bus_putchar2(gc#g0_screen)
  i := 0
  repeat g0_xtiles * g0_ytiles
    bus_putword2(word[ptr][i++])

PUB g0_datblk(heapadr,index,len)|i                      'g0: heapdaten senden

  bus_putchar2(gc#g0_datblk)
  bus_putword2(index)
  bus_putword2(len)
  i := 0
  repeat len
    bus_putchar2(byte[heapadr + index + i++])



PUB g0_datlen:len                                       'g0: heapgröße in bellatrix ermitteln
  bus_putchar2(gc#g0_datlen)
  len := bus_getword2

PUB g0_dynamic                                          'g0: dynamischen modus aktivieren (double buffer)
  bus_putchar2(gc#g0_dynamic)

PUB g0_static                                           'g0: statischen modus aktivieren
  bus_putchar2(gc#g0_static)

PUB g0_reboot                                           'g0: reboot chipcode
  bus_putchar2(gc#g0_reboot)

PUB g0_load                                             'g0: g0-code laden

  sddmset(DM_USER)                                      'u-marker setzen
  sddmact(DM_SYSTEM)                                    's-marker aktivieren
  belload(string("g0key.bel"))
  sddmact(DM_USER)                                      'u-marker aktivieren

DAT
                        org 0
'
' Entry
'
entry                   jmp     entry                   'just loops


regsys        byte  "reg.sys",0
belsys        byte  "bel.sys",0
admsys        byte  "adm.sys",0


{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

                                                                                                                                            
