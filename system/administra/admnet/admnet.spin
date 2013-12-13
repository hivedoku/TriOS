{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Ingo Kripahle & Jörg Deckert                                                                                │
│ Copyright (c) 2010 Ingo Kripahle, 2013 Jörg Deckert                                                                     │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : drohne235@googlemail.com
System          : TriOS
Name            : Administra-Flash (LAN)
Chip            : Administra
Typ             : Flash
Version         : 00
Subversion      : 01

Funktion        : Diese Codeversion basiert auf admflash.spin und wird um einen LAN-Treiber erweitert.
                  Die Soundfunktionen wurden aus Platzgründen entfernt.

                  Dieser Code wird von  Administra nach einem Reset aus dem EEProm in den hRAM kopiert
                  und gestartet. Im Gegensatz zu Bellatrix und Regnatix, die einen Loader aus dem EEProm
                  laden und entsprechende Systemdateien vom SD-Cardlaufwerk booten, also im
                  wesentlichen vor dem Bootvorgang keine weiter Funktionalität als die Ladeprozedur
                  besitzen, muß das EEProm-Bios von Administra mindestens die Funktionalität des
                  SD-Cardlaufwerkes zur Verfügung stellen können. Es erscheint deshalb sinnvoll, dieses
                  BIOS gleich mit einem ausgewogenen Funktionsumfang auszustatten, welcher alle Funktionen
                  für das System bietet. Durch eine Bootoption kann dieses BIOS aber zur Laufzeit
                  ausgetauscht werden, um das Funktionssetup an konkrete Anforderungen anzupassen.

                  Chip-Managment-Funktionen
                  - Bootfunktion für Administra
                  - Abfrage und Verwaltung des aktiven Soundsystems
                  - Abfrage Version und Spezifikation

                  SD-Funktionen:
                  - FAT32 oder FAT16
                  - Partitionen bis 1TB und Dateien bis 2GB
                  - Verzeichnisse
                  - Verwaltung aller Dateiattribute
                  - DIR-Marker System
                  - Verwaltung eines Systemordners
                  - Achtung: Keine Verwaltung von mehreren geöffneten Dateien!

                  RTC-Funktionen:
                  - Datum, Uhrzeit auslesen
                  - Datum, Uhrzeit schreiben
                  - NVRAM auslesen
                  - NVRAM schreiben
                  - Wartefunktionen

                  LAN-Funktionen:
                  -

Komponenten     : FATEngine      01/18/2009 Kwabena W. Agyeman MIT Lizenz
                  RTCEngine      11/22/2009 Kwabena W. Agyeman MIT Lizenz
                  PropTCP        12/08/2009 Harrison Pham      MIT Lizenz

COG's           : MANAGMENT     1 COG
                  FAT/RTC       1 COG
                  NET           2 COGs
                  -------------------
                                4 COGs

Logbuch         :

14-11-2008-dr235  - erste version erstellt
13-03-2009-dr235  - sd_eof eingefügt
25-01-2009-dr235  - komfortableres interface für hss-player eingefügt
19-03-2009-dr235  - seek, ftime, fattrib und fsize eingefügt
22-08-2009-dr235  - getcogs eingefügt
09-01-2010-dr235  - fehler in sfx_fire korrigiert
10-01-2010-dr235  - fehler in sdw_stop - hss wurde nicht wieder gestartet
15-03-2010-dr235  - start trios
21-03-2010-dr235  - screeninterface entfernt
24-03-2010-dr235  - start einbindung fatengine
                  - per flashcli laufen schon die ersten kommandos
25-03-2010-dr235  - umstellung fatengine auf fehlernummern
27-03-2010-dr235  - ich hab geburtstag :)
                  - test mount ok (fat16 + 32, div. sd-cards, fehlermeldungen)
                  - sd_volname eingefügt + test
                  - sd_checkmounted/sd_checkused/sd_checkfree eingefügt + test
                  - sd_checkopen eingefügt (test später)
28-03-2010-dr235  - fehler in der anbindung sd_open --> openFile: der modus
                    wurde als 0-term-string übergeben! änderung in einen normalen
                    1-zeichen-parameter
02-04-2010-dr235  - sd_putblk/sd_getblk eingefügt und getestet
03-04-2010-dr235  - sd_opendit, sd_nextfile, sd_fattrib umgearbeitet und getestet
04-04-2010-dr235  - sd_newdir, sd_del, sd_rename eingefügt und getestet
                  - test sd_seek ok
                  - sd_chattrib, sd_chdir eingefügt und getestet
                  - mgr_getver, mgr_getspec, mgr_getcogs eingefügt + getestet
                  - mgr_aload eingefügt und getestet
                  - administra hat jetzt einen bootloader! :)
08-04-2010-dr235  - erster test dir-marker-system
12-04-2010-dr235  - neues soundsystem für wav eingebunden
16-04-2010-dr235  - komplexfehler im wav-system aufgelöst
21-04-2010-dr235  - pausen-modus  positionsabfrage im wav-player eingefügt & getestet
29-04-2010-dr235  - wav-player: verwendung der dateigröße statt dem headerwert, da einige
                    programme definitiv den headerwert falsch setzen!
09-06-2010-dr085  - frida hat den fehler gefunden, welcher eine korrekte funktion der fatengine
                    nach einem bootvorgang von administra verhinderte :)
13-06-2010-dr235  - fehler in sd_volname korrigiert
                  - free/used auf fast umgestellt
18-06-2010-dr085  - fehler bei der businitialisierung: beim systemstart wurde ein kurzer impuls
                    auf der hs-leitung erzeugt, wodurch ein buszyklus verloren ging (symptom:
                    flashte man admin, so lief das system erst nach einem reset an)
                  - fatengine: endgültige beseitigung der feherhaften volname-abfrage
27-06-2010-dr085  - automount nach boot
19-07-2010-dr235  - booten eines alternativen administra-codes: befindet sich auf der karte
                    in der root eine datei "adm.sys", so wird diese datei automatisch in
                    administra geladen
18-09-2010-dr235  - funktion zur abfrage von eof eingefügt
29-10-2010-dr235  - grundlegende routinen für den plexbus eingefügt
03-12-2010-stepha - RTC Datums- und Zeit Funktionen
04-12-2010-stepha - NVRAM Funktionen
17-04-2013-dr235  - konstanten für administra-funktionen komplett ausgelagert

Kommandoliste   :

Notizen         :


}}


CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000


'             +----------
'             |  +------- system
'             |  |  +---- version    (änderungen)
'             |  |  |  +- subversion (hinzufügungen)
CHIP_VER  = $00_01_01_02

CHIP_SPEC = gc#A_FAT|gc#A_LDR|gc#A_COM|gc#A_LAN

'
'          hbeat   --------+
'          clk     -------+|
'          /wr     ------+||
'          /hs     -----+||| +------------------------- /cs
'                       |||| |+------------------------ adm-p22
'                       |||| ||+----------------------- adm-p21 (io)
'                       |||| |||+---------------------- adm-p20 (rx)
'                       |||| ||||+--------------------- adm-p19 (tx)
'                       |||| |||||             +------+ d0..d7
'                       |||| |||||             |      |
DB_IN            = %00001001_00100000_00000000_00000000 'dira-wert für datenbuseingabe
DB_OUT           = %00001001_00100000_00000000_11111111 'dira-wert für datenbusausgabe

M1               = %00000010_00000000_00000000_00000000 'busclk=1? & /prop1=0?
M2               = %00000010_10000000_00000000_00000000 'maske: busclk & /cs (/prop1)

M3               = %00000000_00000000_00000000_00000000 'busclk=0?
M4               = %00000010_00000000_00000000_00000000 'maske: busclk

LED_OPEN     = gc#HBEAT                                 'led-pin für anzeige "dateioperation"
SD_BASE      = gc#A_SDD0                                'baspin cardreader
CNT_HBEAT    = 5_000_0000                               'blinkgeschw. front-led

MPLEN        = 12000                                    'größe des hss-musikpuffers

'Netzwerk-Puffergrößen (müssen Vielfaches von 2 sein!)
rxlen        = 2048
txlen        = 128

'index für dmarker
#0,     RMARKER                 'root
        SMARKER                 'system
        UMARKER                 'programmverzeichnis
        AMARKER
        BMARKER
        CMARKER

CON 'Signaldefinitionen --------------------------------------------------------------------------

'signaldefinitionen administra (todo: nach glob-con.spin auslagern!!!)

#14,     A_NETCS,A_NETSCK,A_NETSI,A_NETSO              'Pins zum ENC28J60

CON 'NVRAM Konstanten --------------------------------------------------------------------------

' todo: nach glob-con.spin auslagern!!!

#4,     NVRAM_IPADDR
#8,     NVRAM_IPMASK
#12,    NVRAM_IPGW
#16,    NVRAM_IPDNS
#20,    NVRAM_IPBOOT
#24,    NVRAM_HIVE       ' 4 Bytes

OBJ
  sdfat           : "adm-fat"        'fatengine
  rtc             : "adm-rtc"        'RTC-Engine
  com             : "adm-com"        'serielle schnittstelle
  sock            : "driver_socket"  'LAN
  gc              : "glob-con"       'globale konstanten
  num             : "glob-numbers"   'Number Engine

VAR

  long  dmarker[6]                                      'speicher für dir-marker
  byte  tbuf[20]                                        'stringpuffer
  byte  tbuf2[20]
  long  com_baud
  byte  lan_started                                     'LAN gestartet?
  byte  bufrxconn[rxlen]                                'LAN Empfangspuffer ausgehende Verbindung
  byte  buftxconn[txlen]                                'LAN Sendepuffer ausgehende Verbindung
  byte  bufrxlist[rxlen]                                'LAN Empfangspuffer eingehende Verbindung
  byte  buftxlist[txlen]                                'LAN Sendepuffer eingehende Verbindung

CON ''------------------------------------------------- ADMINISTRA

PUB main | cmd,err                                      'chip: kommandointerpreter
''funktionsgruppe               : chip
''funktion                      : kommandointerpreter
''eingabe                       : -
''ausgabe                       : -

  init_chip                                             'bus/vga/keyboard/maus initialisieren
  repeat
    cmd := bus_getchar                                  'kommandocode empfangen
    err := 0
    case cmd
        0:  !outa[LED_OPEN]                             'led blinken

'       ----------------------------------------------  SD-FUNKTIONEN
        gc#a_sdMount: sd_mount("M")                     'sd-card mounten                                              '
        gc#a_sdOpenDir: sd_opendir                      'direktory öffnen
        gc#a_sdNextFile: sd_nextfile                    'verzeichniseintrag lesen
        gc#a_sdOpen: sd_open                            'datei öffnen
        gc#a_sdClose: sd_close                          'datei schließen
        gc#a_sdGetC: sd_getc                            'zeichen lesen
        gc#a_sdPutC: sd_putc                            'zeichen schreiben
        gc#a_sdGetBlk: sd_getblk                        'block lesen
        gc#a_sdPutBlk: sd_putblk                        'block schreiben
        gc#a_sdSeek: sd_seek                            'zeiger in datei positionieren
        gc#a_sdFAttrib: sd_fattrib                      'dateiattribute übergeben
        gc#a_sdVolname: sd_volname                      'volumelabel abfragen
        gc#a_sdCheckMounted: sd_checkmounted            'test ob volume gemounted ist
        gc#a_sdCheckOpen: sd_checkopen                  'test ob eine datei geöffnet ist
        gc#a_sdCheckUsed: sd_checkused                  'test wie viele sektoren benutzt sind
        gc#a_sdCheckFree: sd_checkfree                  'test wie viele sektoren frei sind
        gc#a_sdNewFile: sd_newfile                      'neue datei erzeugen
        gc#a_sdNewDir: sd_newdir                        'neues verzeichnis wird erzeugt
        gc#a_sdDel: sd_del                              'verzeichnis oder datei löschen
        gc#a_sdRename: sd_rename                        'verzeichnis oder datei umbenennen
        gc#a_sdChAttrib: sd_chattrib                    'attribute ändern
        gc#a_sdChDir: sd_chdir                          'verzeichnis wechseln
        gc#a_sdFormat: sd_format                        'medium formatieren
        gc#a_sdUnmount: sd_unmount                      'medium abmelden
        gc#a_sdDmAct: sd_dmact                          'dir-marker aktivieren
        gc#a_sdDmSet: sd_dmset                          'dir-marker setzen
        gc#a_sdDmGet: sd_dmget                          'dir-marker status abfragen
        gc#a_sdDmClr: sd_dmclr                          'dir-marker löschen
        gc#a_sdDmPut: sd_dmput                          'dir-marker status setzen
        gc#a_sdEOF: sd_eof                              'eof abfragen

'       ----------------------------------------------  COM-FUNKTIONEN
        gc#a_comInit: com_init
        gc#a_comTx: com_tx
        gc#a_comRx: com_rx

'       ----------------------------------------------  RTC-FUNKTIONEN
        gc#a_rtcGetSeconds: rtc_getSeconds              'Returns the current second (0 - 59) from the real time clock.
        gc#a_rtcGetMinutes: rtc_getMinutes              'Returns the current minute (0 - 59) from the real time clock.
        gc#a_rtcGetHours: rtc_getHours                  'Returns the current hour (0 - 23) from the real time clock.
        gc#a_rtcGetDay: rtc_getDay                      'Returns the current day (1 - 7) from the real time clock.
        gc#a_rtcGetDate: rtc_getDate                    'Returns the current date (1 - 31) from the real time clock.
        gc#a_rtcGetMonth: rtc_getMonth                  'Returns the current month (1 - 12) from the real time clock.
        gc#a_rtcGetYear: rtc_getYear                    'Returns the current year (2000 - 2099) from the real time clock.
        gc#a_rtcSetSeconds: rtc_setSeconds              'Sets the current real time clock seconds. Seconds - Number to set the seconds to between 0 - 59.
        gc#a_rtcSetMinutes: rtc_setMinutes              'Sets the current real time clock minutes. Minutes - Number to set the minutes to between 0 - 59.
        gc#a_rtcSetHours: rtc_setHours                  'Sets the current real time clock hours. Hours - Number to set the hours to between 0 - 23.
        gc#a_rtcSetDay: rtc_setDay                      'Sets the current real time clock day. Day - Number to set the day to between 1 - 7.
        gc#a_rtcSetDate: rtc_setDate                    'Sets the current real time clock date. Date - Number to set the date to between 1 - 31.
        gc#a_rtcSetMonth: rtc_setMonth                  'Sets the current real time clock month. Month - Number to set the month to between 1 - 12.
        gc#a_rtcSetYear: rtc_setYear                    'Sets the current real time clock year. Year - Number to set the year to between 2000 - 2099.
        gc#a_rtcSetNVSRAM: rtc_setNVSRAM                'Sets the NVSRAM to the selected value (0 - 255) at the index (0 - 55).
        gc#a_rtcGetNVSRAM: rtc_getNVSRAM                'Gets the selected NVSRAM value at the index (0 - 55).
        gc#a_rtcPauseForSec: rtc_pauseForSeconds        'Pauses execution for a number of seconds. Returns a puesdo random value derived from the current clock frequency and the time when called. Number - Number of seconds to pause for between 0 and 2,147,483,647.
        gc#a_rtcPauseForMSec: rtc_pauseForMilliseconds  'Pauses execution for a number of milliseconds. Returns a puesdo random value derived from the current clock frequency and the time when called. Number - Number of milliseconds to pause for between 0 and 2,147,483,647.

'       ----------------------------------------------  LAN-FUNKTIONEN
        gc#a_lanStart: lan_start                        'Start Network
        gc#a_lanStop:lan_stop                           'Stop Network
        gc#a_lanConnect: lan_connect                    'ausgehende TCP-Verbindung öffnen
        gc#a_lanListen: lan_listen                      'auf eingehende TCP-Verbindung lauschen
        gc#a_lanReListen: lan_relisten                  'wieder auf eingehende TCP-Verbindung lauschen
        gc#a_lanIsConnected: lan_isconnected            'Prüfen, ob verbunden
        gc#a_lanRXCount: lan_rxcount                    'Anzahl Zeichen im Empfangspuffer
        gc#a_lanResetBuffers: lan_resetbuffers          'Puffer zurücksetzen
        gc#a_lanWaitConnTimeout: lan_waitconntimeout    'bestimmte Zeit auf Verbindung warten
        gc#a_lanClose: lan_close                        'TCP-Verbindung schließen
        gc#a_lanRXFlush: lan_rxflush                    'Empfangspuffer leeren
        gc#a_lanRXCheck: lan_rxcheck                    'warten auf Byte aus Empfangspuffer
        gc#a_lanRXTime: lan_rxtime                      'bestimmte Zeit warten auf Byte aus Empfangspuffer
        gc#a_lanRXByte: lan_rxbyte                      'Byte aus Empfangspuffer lesen
        gc#a_lanRXDataTime: lan_rxdatatime              'bestimmte Zeit auf daten aus Empfangspuffer warten
        gc#a_lanRXData: lan_rxdata                      'Daten aus Empfangspuffer lesen
        gc#a_lanTXFlush: lan_txflush                    'Sendepuffer leeren
        gc#a_lanTXCheck: lan_txcheck                    'Verbindung prüfen und Byte senden
        gc#a_lanTX: lan_tx                              'Byte senden
        gc#a_lanTXData: lan_txdata                      'Daten senden

'       ----------------------------------------------  CHIP-MANAGMENT
        gc#a_mgrGetSpec: mgr_getspec                    'spezifikation abfragen
        gc#a_mgrALoad: mgr_aload                        'neuen code booten
        gc#a_mgrGetCogs: mgr_getcogs                    'freie cogs abfragen
        gc#a_mgrGetVer: mgr_getver                      'codeversion abfragen
        gc#a_mgrReboot: reboot                          'neu starten

'       ----------------------------------------------  DEBUG-FUNKTIONEN
        255: mgr_debug                                  'debugfunktion

PRI init_chip | err,i,j                                 'chip: initialisierung des administra-chips
''funktionsgruppe               : chip
''funktion                      : - initialisierung des businterface
''eingabe                       : -
''ausgabe                       : -

  'businterface initialisieren
  outa[gc#bus_hs] := 1                                  'handshake inaktiv             ,frida
  dira := db_in                                         'datenbus auf eingabe schalten ,frida

  'sd-card starten
  clr_dmarker                                           'dir-marker löschen
  sdfat.FATEngine
  repeat
    waitcnt(cnt + clkfreq/10)
  until sd_mount("B") == 0
  'err := sd_mount("B")
  'siglow(err)

 'RTC initialisieren
  rtc.setSQWOUTFrequency(3)                             'RTC Uhrenquarzt Frequenz wählen
  rtc.setSQWOUTState(0)                                 'RT Zähler ein

  'adm-code booten?
   ifnot \sdfat.openFile(string("adm.sys"), "R")        'test ob adm.sys vorhanden ist
      \sdfat.bootPartition(string("adm.sys"), ".")      'neuen code booten

  'serielle schnittstelle starten
  com_baud := 115200
  com.start(gc#SER_RX,gc#SER_TX,0,com_baud)             'start the default serial interface

  'LAN
  lan_started := false                                  'LAN noch nicht gestartet

PRI bus_putchar(zeichen)                                'chip: ein byte über bus ausgeben
''funktionsgruppe               : chip
''funktion                      : senderoutine für ein byte zu regnatix über den systembus
''eingabe                       : byte zeichen
''ausgabe                       : -

  waitpeq(M1,M2,0)                                      'busclk=1? & /prop1=0?
  dira := db_out                                        'datenbus auf ausgabe stellen
  outa[7..0] := zeichen                                 'daten ausgeben
  outa[gc#bus_hs] := 0                                  'daten gültig
  waitpeq(M3,M4,0)                                      'busclk=0?
  outa[gc#bus_hs] := 1                                  'daten ungültig
  dira := db_in                                         'bus freigeben

PRI bus_getchar : zeichen                               'chip: ein byte über bus empfangen
''funktionsgruppe               : chip
''funktion                      : emfangsroutine für ein byte von regnatix über den systembus
''eingabe                       : -
''ausgabe                       : byte zeichen

  waitpeq(M1,M2,0)                                      'busclk=1? & /prop1=0?
  zeichen := ina[7..0]                                  'daten einlesen
  outa[gc#bus_hs] := 0                                  'daten quittieren
  outa[gc#bus_hs] := 1
  waitpeq(M3,M4,0)                                      'busclk=0?

PRI clr_dmarker| i                                      'chip: dmarker-tabelle löschen
''funktionsgruppe               : chip
''funktion                      : dmarker-tabelle löschen
''eingabe                       : -
''ausgabe                       : -

    i := 0
    repeat 6                                            'alle dir-marker löschen
      dmarker[i++] := TRUE

CON ''------------------------------------------------- SUBPROTOKOLL-FUNKTIONEN

PRI sub_getstr | i,len                                  'sub: string einlesen
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen string von regnatix zu empfangen und im
''                              : textpuffer (tbuf) zu speichern
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [get.len][get.byte(1)]..[get.byte(len)]
''                              : len - länge des dateinamens

  repeat i from 0 to 19                                 'puffer löschen und kopieren
    tbuf2[i] := tbuf[i]
    tbuf[i] := 0
  len := bus_getchar                                    'längenbyte name empfangen
  repeat i from 0 to len - 1                            'dateiname einlesen
    tbuf[i] := bus_getchar

PRI sub_putstr(strptr)|len,i                            'sub: string senden
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen string an regnatix zu senden
''eingabe                       : strptr - zeiger auf einen string (0-term)
''ausgabe                       : -
''busprotokoll                  : [put.len][put.byte(1)]..[put.byte(len)]
''                              : len - länge des dateinamens

  len := strsize(strptr)
  bus_putchar(len)
  repeat i from 0 to len - 1                            'string übertragen
    bus_putchar(byte[strptr][i])

PRI sub_putword(wert)                                   'sub: long senden
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen 16bit-wert an regnatix zu senden
''eingabe                       : 16bit wert der gesendet werden soll
''ausgabe                       : -
''busprotokoll                  : [put.byte1][put.byte2]
''                              : [  hsb    ][   lsb   ]

   bus_putchar(wert >> 8)
   bus_putchar(wert)

PRI sub_getword:wert                                    'sub: long empfangen
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen 16bit-wert von regnatix zu empfangen
''eingabe                       : -
''ausgabe                       : 16bit-wert der empfangen wurde
''busprotokoll                  : [get.byte1][get.byte2]
''                              : [  hsb    ][   lsb   ]

  wert := wert + bus_getchar << 8
  wert := wert + bus_getchar

PRI sub_putlong(wert)                                   'sub: long senden
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen long-wert an regnatix zu senden
''eingabe                       : 32bit wert der gesendet werden soll
''ausgabe                       : -
''busprotokoll                  : [put.byte1][put.byte2][put.byte3][put.byte4]
''                              : [  hsb    ][         ][         ][   lsb   ]

   bus_putchar(wert >> 24)                              '32bit wert senden hsb/lsb
   bus_putchar(wert >> 16)
   bus_putchar(wert >> 8)
   bus_putchar(wert)

PRI sub_getlong:wert                                    'sub: long empfangen
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen long-wert von regnatix zu empfangen
''eingabe                       : -
''ausgabe                       : 32bit-wert der empfangen wurde
''busprotokoll                  : [get.byte1][get.byte2][get.byte3][get.byte4]
''                              : [  hsb    ][         ][         ][   lsb   ]

  wert :=        bus_getchar << 24                      '32 bit empfangen hsb/lsb
  wert := wert + bus_getchar << 16
  wert := wert + bus_getchar << 8
  wert := wert + bus_getchar


CON ''------------------------------------------------- CHIP-MANAGMENT-FUNKTIONEN

PRI mgr_aload | err                                     'cmgr: neuen administra-code booten
''funktionsgruppe               : cmgr
''funktion                      : administra mit neuem code booten
''eingabe                       :
''ausgabe                       :
''busprotokoll                  : [096][sub_getstr.fn]
''                              : fn  - dateiname des neuen administra-codes
  sub_getstr
  err := \sdfat.bootPartition(@tbuf, ".")

PRI mgr_getcogs: cogs |i,c,cog[8]                       'cmgr: abfragen wie viele cogs in benutzung sind
''funktionsgruppe               : cmgr
''funktion                      : abfrage wie viele cogs in benutzung sind
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [097][put.cogs]
''                              : cogs - anzahl der belegten cogs

  cogs := i := 0
  repeat 'loads as many cogs as possible and stores their cog numbers
    c := cog[i] := cognew(@entry, 0)
    if c=>0
      i++
  while c => 0
  cogs := i
  repeat 'unloads the cogs and updates the string
    i--
    if i=>0
      cogstop(cog[i])
  while i=>0
  bus_putchar(cogs)

PRI mgr_getver                                          'cmgr: abfrage der version
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [098][sub_putlong.ver]
''                              : ver - version
''                  +----------
''                  |  +------- system
''                  |  |  +---- version    (änderungen)
''                  |  |  |  +- subversion (hinzufügungen)
''version :       $00_00_00_00
''

  sub_putlong(CHIP_VER)

PRI mgr_getspec                                         'cmgr: abfrage der spezifikation des chips
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [089][sub_putlong.spec]
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

  sub_putlong(CHIP_SPEC)

PRI mgr_debug                                           'cmgr: debug
' adresse der ersten variable senden

  sub_putlong(@dmarker)                                 'adresse erste variable als marker

CON ''------------------------------------------------- SD-LAUFWERKS-FUNKTIONEN

PRI sd_mount(mode) | err                                'sdcard: sd-card mounten frida
''funktionsgruppe               : sdcard
''funktion                      : eingelegtes volume mounten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [001][put.error]
''                              : error - fehlernummer entspr. list

  ifnot sdfat.checkPartitionMounted                      'frida
    err := \sdfat.mountPartition(0,0)                     'karte mounten
    'bus_putchar(err)                                      'fehlerstatus senden
    if mode == "M"                                         'frida
      bus_putchar(err)                                      'fehlerstatus senden

    ifnot err
      dmarker[RMARKER] := sdfat.getDirCluster             'root-marker setzen

      err := \sdfat.changeDirectory(string("system"))
      ifnot err
        dmarker[SMARKER] := sdfat.getDirCluster           'system-marker setzen

      sdfat.setDirCluster(dmarker[RMARKER])               'root-marker wieder aktivieren
  else                                                    'frida
    bus_putchar(0)                                        'frida

PRI sd_opendir | err                                    'sdcard: verzeichnis öffnen
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis öffnen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [002]

  err := \sdfat.listReset

PRI sd_nextfile | strpt                                 'sdcard: nächsten eintrag aus verzeichnis holen
''funktionsgruppe               : sdcard
''funktion                      : nächsten eintrag aus verzeichnis holen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [003][put.status=0]
''                              : [003][put.status=1][sub_putstr.fn]
''                              : status - 1 = gültiger eintrag
''                              :          0 = es folgt kein eintrag mehr
''                              : fn - verzeichniseintrag string

  strpt := \sdfat.listName                              'nächsten eintrag holen
  if strpt                                              'status senden
    bus_putchar(1)                                      'kein eintrag mehr
    sub_putstr(strpt)
  else
    bus_putchar(0)                                      'gültiger eintrag folgt

PRI sd_open  | err,modus                                'sdcard: datei öffnen
''funktionsgruppe               : sdcard
''funktion                      : eine bestehende datei öffnen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [004][get.modus][sub_getstr.fn][put.error]
''                              : modus - "A" Append, "W" Write, "R" Read
''                              : fn - name der datei
''                              : error - fehlernummer entspr. list

   modus := bus_getchar                                 'modus empfangen
   sub_getstr
   err := \sdfat.openFile(@tbuf, modus)
   bus_putchar(err)                                     'ergebnis der operation senden
''   outa[LED_OPEN] := 1

PRI sd_close | err                                      'sdcard: datei schließen
''funktionsgruppe               : sdcard
''funktion                      : die aktuell geöffnete datei schließen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [005][put.error]
''                              : error - fehlernummer entspr. list

  err  := \sdfat.closeFile
  bus_putchar(err)                                      'ergebnis der operation senden
''  outa[LED_OPEN] := 0

PRI sd_getc | n                                         'sdcard: zeichen aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus datei lesen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [006][put.char]
''                              : char - gelesenes zeichen

  n := \sdfat.readCharacter
  bus_putchar(n)

PRI sd_putc                                             'sdcard: zeichen in datei schreiben
''funktionsgruppe               : sdcard
''funktion                      : zeichen in datei schreiben
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [007][get.char]
''                              : char - zu schreibendes zeichen

  \sdfat.writeCharacter(bus_getchar)


PRI sd_eof                                              'sdcard: eof abfragen
''funktionsgruppe               : sdcard
''funktion                      : eof abfragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [030][put.eof]
''                              : eof - eof-flag

  bus_putchar(sdfat.getEOF)

PRI sd_getblk                                           'sdcard: block aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [008][sub_getlong.count][put.char(1)]..[put.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen

  repeat sub_getlong
    bus_putchar(\sdfat.readCharacter)


PRI sd_putblk                                           'sdcard: block in datei schreiben
''funktionsgruppe               : sdcard
''funktion                      : block in datei schreiben
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [009][sub_getlong.count][put.char(1)]..[put.char(count)]
''                              : count - anzahl der zu schreibenden zeichen
''                              : char - zu schreibende zeichen

  repeat sub_getlong
    \sdfat.writeCharacter(bus_getchar)

PRI sd_seek | wert                                      'sdcard: zeiger in datei positionieren
''funktionsgruppe               : sdcard
''funktion                      : zeiger in datei positionieren
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [010][sub_getlong.pos]
''                              : pos - neue zeichenposition in der datei

  wert := sub_getlong
  \sdfat.setCharacterPosition(wert)

PRI sd_fattrib | anr,wert                               'sdcard: dateiattribute übergeben
''funktionsgruppe               : sdcard
''funktion                      : dateiattribute abfragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [011][get.anr][sub_putlong.wert]
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

   anr := bus_getchar
   case anr
     0:  wert := \sdfat.listSize
     1:  wert := \sdfat.listCreationDay
     2:  wert := \sdfat.listCreationMonth
     3:  wert := \sdfat.listCreationYear
     4:  wert := \sdfat.listCreationSeconds
     5:  wert := \sdfat.listCreationMinutes
     6:  wert := \sdfat.listCreationHours
     7:  wert := \sdfat.listAccessDay
     8:  wert := \sdfat.listAccessMonth
     9:  wert := \sdfat.listAccessYear
     10: wert := \sdfat.listModificationDay
     11: wert := \sdfat.listModificationMonth
     12: wert := \sdfat.listModificationYear
     13: wert := \sdfat.listModificationSeconds
     14: wert := \sdfat.listModificationMinutes
     15: wert := \sdfat.listModificationHours
     16: wert := \sdfat.listIsReadOnly
     17: wert := \sdfat.listIsHidden
     18: wert := \sdfat.listIsSystem
     19: wert := \sdfat.listIsDirectory
     20: wert := \sdfat.listIsArchive
   sub_putlong(wert)

PRI sd_volname                                          'sdcard: volumenlabel abfragen
''funktionsgruppe               : sdcard
''funktion                      : name des volumes überragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [012][sub_putstr.volname]
''                              : volname - name des volumes
''                              : len   - länge des folgenden strings

  sub_putstr(\sdfat.listVolumeLabel)                    'label holen und senden

PRI sd_checkmounted                                     'sdcard: test ob volume gemounted ist
''funktionsgruppe               : sdcard
''funktion                      : test ob volume gemounted ist
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [013][put.flag]
''                              : flag  - 0 = unmounted, 1 mounted

  bus_putchar(\sdfat.checkPartitionMounted)

PRI sd_checkopen                                        'sdcard: test ob eine datei geöffnet ist
''funktionsgruppe               : sdcard
''funktion                      : test ob eine datei geöffnet ist
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [014][put.flag]
''                              : flag  - 0 = not open, 1 open

  bus_putchar(\sdfat.checkFileOpen)

PRI sd_checkused                                        'sdcard: anzahl der benutzten sektoren senden
''funktionsgruppe               : sdcard
''funktion                      : anzahl der benutzten sektoren senden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [015][sub_putlong.used]
''                              : used - anzahl der benutzten sektoren

  sub_putlong(\sdfat.checkUsedSectorCount("F"))

PRI sd_checkfree                                        'sdcard: anzahl der freien sektoren senden
''funktionsgruppe               : sdcard
''funktion                      : anzahl der freien sektoren senden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [016][sub_putlong.free]
''                              : free - anzahl der freien sektoren

  sub_putlong(\sdfat.checkFreeSectorCount("F"))

PRI sd_newfile | err                                    'sdcard: eine neue datei erzeugen
''funktionsgruppe               : sdcard
''funktion                      : eine neue datei erzeugen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [017][sub_getstr.fn][put.error]
''                              : fn - name der datei
''                              : error - fehlernummer entspr. liste

   sub_getstr
   err := \sdfat.newFile(@tbuf)
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sd_newdir | err                                     'sdcard: ein neues verzeichnis erzeugen
''funktionsgruppe               : sdcard
''funktion                      : ein neues verzeichnis erzeugen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [018][sub_getstr.fn][put.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. liste

   sub_getstr
   err := \sdfat.newDirectory(@tbuf)
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sd_del | err                                        'sdcard: eine datei oder ein verzeichnis löschen
''funktionsgruppe               : sdcard
''funktion                      : eine datei oder ein verzeichnis löschen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [019][sub_getstr.fn][put.error]
''                              : fn - name des verzeichnisses oder der datei
''                              : error - fehlernummer entspr. liste

   sub_getstr
   err := \sdfat.deleteEntry(@tbuf)
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sd_rename | err                                     'sdcard: datei oder verzeichnis umbenennen
''funktionsgruppe               : sdcard
''funktion                      : datei oder verzeichnis umbenennen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [020][sub_getstr.fn1][sub_getstr.fn2][put.error]
''                              : fn1 - alter name
''                              : fn2 - neuer name
''                              : error - fehlernummer entspr. liste

   sub_getstr                                           'fn1
   sub_getstr                                           'fn2
   err := \sdfat.renameEntry(@tbuf2,@tbuf)
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sd_chattrib | err                                   'sdcard: attribute ändern
''funktionsgruppe               : sdcard
''funktion                      : attribute einer datei oder eines verzeichnisses ändern
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [021][sub_getstr.fn][sub_getstr.attrib][put.error]
''                              : fn - dateiname
''                              : attrib - string mit attributen
''                              : error - fehlernummer entspr. liste

  sub_getstr
  sub_getstr
  err := \sdfat.changeAttributes(@tbuf2,@tbuf)
  bus_putchar(err)                                      'ergebnis der operation senden

PRI sd_chdir | err                                      'sdcard: verzeichnis wechseln
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis wechseln
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [022][sub_getstr.fn][put.error]
''                              : fn - name des verzeichnisses
''                              : error - fehlernummer entspr. list
  sub_getstr
  err := \sdfat.changeDirectory(@tbuf)
  bus_putchar(err)                                      'ergebnis der operation senden

PRI sd_format | err                                     'sdcard: medium formatieren
''funktionsgruppe               : sdcard
''funktion                      : medium formatieren
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [023][sub_getstr.vlabel][put.error]
''                              : vlabel - volumelabel
''                              : error - fehlernummer entspr. list

  sub_getstr
  err := \sdfat.formatPartition(0,@tbuf,0)
  bus_putchar(err)                                      'ergebnis der operation senden

PRI sd_unmount | err                                    'sdcard: medium abmelden
''funktionsgruppe               : sdcard
''funktion                      : medium abmelden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [024][put.error]
''                              : error - fehlernummer entspr. list

  err := \sdfat.unmountPartition
  bus_putchar(err)                                      'ergebnis der operation senden
  ifnot err
    clr_dmarker

PRI sd_dmact|markernr                                   'sdcard: einen dir-marker aktivieren
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker wird aktiviert
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [025][get.dmarker][put.error]
''                              : dmarker - dir-marker
''                              : error   - fehlernummer entspr. list
  markernr := bus_getchar
  ifnot dmarker[markernr] == TRUE
    sdfat.setDirCluster(dmarker[markernr])
    bus_putchar(sdfat#err_noError)
  else
    bus_putchar(sdfat#err_noError)


PRI sd_dmset|markernr                                   'sdcard: einen dir-marker setzen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker mit dem aktuellen verzeichnis setzen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [026][get.dmarker]
''                              : dmarker - dir-marker

  markernr := bus_getchar
  dmarker[markernr] := sdfat.getDirCluster

PRI sd_dmget|markernr                                   'sdcard: einen dir-marker abfragen
''funktionsgruppe               : sdcard
''funktion                      : den status eines ausgewählter dir-marker abfragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [027][get.dmarker][sub_putlong.dmstatus]
''                              : dmarker  - dir-marker
''                              : dmstatus - status des markers

  markernr := bus_getchar
  sub_putlong(dmarker[markernr])

PRI sd_dmput|markernr                                   'sdcard: einen dir-marker übertragen
''funktionsgruppe               : sdcard
''funktion                      : den status eines ausgewählter dir-marker übertragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [029][get.dmarker][sub_getlong.dmstatus]
''                              : dmarker  - dir-marker
''                              : dmstatus - status des markers

  markernr := bus_getchar
  dmarker[markernr] := sub_getlong

PRI sd_dmclr|markernr                                   'sdcard: einen dir-marker löschen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker löschen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [028][get.dmarker]
''                              : dmarker - dir-marker

  markernr := bus_getchar
  dmarker[markernr] := TRUE

CON ''------------------------------------------------- COM-FUNKTIONEN

PRI com_init                                            'com: serielle schnittstelle initialisieren
''funktionsgruppe               : com
''funktion                      : serielle schnittstelle initialisieren
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [031][sub_getlong.baudrate]


  com_baud := sub_getlong
  com.start(gc#SER_RX,gc#SER_TX,0,com_baud)             ' start the default serial interface

PRI com_tx                                              'com: zeichen senden
''funktionsgruppe               : com
''funktion                      : zeichen senden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [032][get.char]

  com.tx(bus_getchar)

PRI com_rx                                              'com: zeichen empfangen
''funktionsgruppe               : com
''funktion                      : zeichen empfangen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [033][put.char]

  bus_putchar(com.rx)

CON ''------------------------------------------------- RTC-FUNKTIONEN

PRI rtc_getSeconds                                      'rtc: Returns the current second (0 - 59) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [041][sub_putlong.seconds]
''                              : seconds - current second (0 - 59)
  sub_putlong(rtc.getSeconds)

PRI rtc_getMinutes                                      'rtc: Returns the current minute (0 - 59) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [042][sub_putlong.minutes]
''                              : minutes - current minute (0 - 59)
  sub_putlong(rtc.getMinutes)

PRI rtc_getHours                                        'rtc: Returns the current hour (0 - 23) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [043][sub_putlong.hours]
''                              : hours -  current hour (0 - 23)
  sub_putlong(rtc.getHours)

PRI rtc_getDay                                          'rtc: Returns the current day of the week (1 - 7) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [044][sub_putlong.day]
''                              : day - current day (1 - 7) of the week
  sub_putlong(rtc.getDay)

PRI rtc_getDate                                         'rtc: Returns the current date (1 - 31) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [045][sub_putlong.date]
''                              : date - current date (1 - 31) of the month
  sub_putlong(rtc.getDate)

PRI rtc_getMonth                                        'rtc: Returns the current month (1 - 12) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [046][sub_putlong.month]
''                              : month - current month (1 - 12)
  sub_putlong(rtc.getMonth)

PRI rtc_getYear                                         'rtc: Returns the current year (2000 - 2099) from the real time clock.
''funktionsgruppe               : rtc
''busprotokoll                  : [047][sub_putlong.year]
''                              : year -  current year (2000 - 2099)
  sub_putlong(rtc.getYear)

PRI rtc_setSeconds : seconds                            'rtc: Sets the current real time clock seconds.
''funktionsgruppe               : rtc
''busprotokoll                  : [048][sub_getlong.seconds]
''                              : seconds - Number to set the seconds to between 0 - 59.
  rtc.setSeconds(sub_getlong)

PRI rtc_setMinutes : minutes                            'rtc: Sets the current real time clock minutes.
''funktionsgruppe               : rtc
''busprotokoll                  : [049][sub_getlong.minutes]
''                              : minutes - Number to set the minutes to between 0 - 59.
  rtc.setMinutes(sub_getlong)

PRI rtc_setHours                                        'rtc: Sets the current real time clock hours.
''funktionsgruppe               : rtc
''busprotokoll                  : [050][sub_getlong.hours]
''                              : hours - Number to set the hours to between 0 - 23.51:
  rtc.setHours(sub_getlong)

PRI rtc_setDay                                          'rtc: Sets the current real time clock day.
''funktionsgruppe               : rtc
''busprotokoll                  : [051][sub_getlong.day]
''                              : day - Number to set the day to between 1 - 7.
  rtc.setDay(sub_getlong)

PRI rtc_setDate                                         'rtc: Sets the current real time clock date.
''funktionsgruppe               : rtc
''busprotokoll                  : [052][sub_getlong.date]
''                              : date - Number to set the date to between 1 - 31.
  rtc.setDate(sub_getlong)

PRI rtc_setMonth                                        'rtc: Sets the current real time clock month.
''funktionsgruppe               : rtc
''busprotokoll                  : [053][sub_getlong.month]
''                              : month - Number to set the month to between 1 - 12.
  rtc.setMonth(sub_getlong)

PRI rtc_setYear                                         'rtc: Sets the current real time clock year.
''funktionsgruppe               : rtc
''busprotokoll                  : [054][sub_getlong.year]
''                              : year - Number to set the year to between 2000 - 2099.
  rtc.setYear(sub_getlong)

PRI rtc_setNVSRAM | index, value                        'rtc: Sets the NVSRAM to the selected value (0 - 255) at the index (0 - 55).
''funktionsgruppe               : rtc
''busprotokoll                  : [055][sub_getlong.index][sub_getlong.value]
''                              : index - The location in NVRAM to set (0 - 55).                                                                           │
''                              : value - The value (0 - 255) to change the location to.                                                                   │
  index := sub_getlong
  value := sub_getlong
  rtc.setNVSRAM(index, value)

PRI rtc_getNVSRAM                                       'rtc: Gets the selected NVSRAM value at the index (0 - 55).
''funktionsgruppe               : rtc
''busprotokoll                  : [056][sub_getlong.index][sub_getlong.value]
''                              : index - The location in NVRAM to get (0 - 55).                                                                           │
  sub_putlong(rtc.getNVSRAM(sub_getlong))

PRI rtc_pauseForSeconds                                 'rtc: Pauses execution for a number of seconds.
''funktionsgruppe               : rtc
''busprotokoll                  : [057][sub_getlong.number][sub_putlong.number]
''                              : Number - Number of seconds to pause for between 0 and 2,147,483,647.
''                              : Returns a puesdo random value derived from the current clock frequency and the time when called.

  sub_putlong(rtc.pauseForSeconds(sub_getlong))

PRI rtc_pauseForMilliseconds                            'rtc: Pauses execution for a number of milliseconds.
''funktionsgruppe               : rtc
''busprotokoll                  : [058][sub_getlong.number][sub_putlong.number]
''                              : Number - Number of milliseconds to pause for between 0 and 2,147,483,647.
''                              : Returns a puesdo random value derived from the current clock frequency and the time when called.
  sub_putlong(rtc.pauseForMilliseconds(sub_getlong))

CON ''------------------------------------------------- LAN-FUNKTIONEN

PRI lan_start | hiveid, hivestr, strpos, macpos
''funktionsgruppe               : lan
''funktion                      : Netzwerk starten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [071]

  if (not lan_started)
    ip_addr := rtc.getNVSRAM(NVRAM_IPADDR)
    ip_addr[1] := rtc.getNVSRAM(NVRAM_IPADDR+1)
    ip_addr[2] := rtc.getNVSRAM(NVRAM_IPADDR+2)
    ip_addr[3] := rtc.getNVSRAM(NVRAM_IPADDR+3)

    ip_subnet := rtc.getNVSRAM(NVRAM_IPMASK)
    ip_subnet[1] := rtc.getNVSRAM(NVRAM_IPMASK+1)
    ip_subnet[2] := rtc.getNVSRAM(NVRAM_IPMASK+2)
    ip_subnet[3] := rtc.getNVSRAM(NVRAM_IPMASK+3)

    ip_gateway := rtc.getNVSRAM(NVRAM_IPGW)
    ip_gateway[1] := rtc.getNVSRAM(NVRAM_IPGW+1)
    ip_gateway[2] := rtc.getNVSRAM(NVRAM_IPGW+2)
    ip_gateway[3] := rtc.getNVSRAM(NVRAM_IPGW+3)

    ip_dns := rtc.getNVSRAM(NVRAM_IPDNS)
    ip_dns[1] := rtc.getNVSRAM(NVRAM_IPDNS+1)
    ip_dns[2] := rtc.getNVSRAM(NVRAM_IPDNS+2)
    ip_dns[3] := rtc.getNVSRAM(NVRAM_IPDNS+3)

    hiveid :=          rtc.getNVSRAM(NVRAM_HIVE)
    hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+1) << 8
    hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+2) << 16
    hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+3) << 24
    hivestr := num.ToStr(hiveid, num#DEC)
    strpos := strsize(hivestr)
    macpos := 5
    repeat while (strpos AND macpos)
      strpos--
      if(strpos)
        strpos--
      mac_addr[macpos] := num.FromStr(hivestr+strpos, num#HEX)
      byte[hivestr+strpos] := 0
      macpos--

    sock.start(A_NETCS,A_NETSCK,A_NETSI,A_NETSO, -1, @mac_addr, @ip_addr)
    lan_started := true


PRI lan_stop
''funktionsgruppe               : lan
''funktion                      : Netzwerk anhalten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [072]

  if lan_started
    sock.stop
    lan_started := false

PRI lan_connect | ipaddr, remoteport, handle
''funktionsgruppe               : lan
''funktion                      : ausgehende TCP-Verbindung öffnen (mit Server verbinden)
''                              : Da hier feste Puffer (bufrxconn,buftxconn) verwendet werden,
''                              : darf diese Funktion nur einmal aufgerufen werden
''                              : (driver_socket.spin handelt per default bis 4 Sockets)
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [073][sub_getlong.ipaddr][sub_getword.remoteport][put.handle]
''                              : ipaddr     - ipv4 address packed into a long (ie: 1.2.3.4 => $01_02_03_04)
''                              : remoteport - port number to connect to
''                              : handle     - lfd. Nr. der Verbindung

  ipaddr := sub_getlong
  remoteport := sub_getword

  handle := sock.connect(ipaddr, remoteport, @bufrxconn, rxlen, @buftxconn, txlen)

  bus_putchar(handle)                                      'handle senden


PRI lan_listen
PRI lan_relisten
PRI lan_isconnected | handle
''funktionsgruppe               : lan
''funktion                      : Abfrage, ob Socket verbunden
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [076][get.handle][put.connected]
''                              : handle     - lfd. Nr. der zu testenden Verbindung
''                              : connected  - True, if connected

  handle := bus_getchar

  bus_putchar(sock.isConnected(handle))

PRI lan_rxcount
PRI lan_resetbuffers | handle
''funktionsgruppe               : lan
''funktion                      : Sende- und Empfangspuffer zurücksetzen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [078][get.handle]
''                              : handle - lfd. Nr. der Verbindung

  handle := bus_getchar

  sock.resetBuffers(handle)

PRI lan_waitconntimeout | handle, timeout, t, connected
''funktionsgruppe               : lan
''funktion                      : bestimmte Zeit auf Verbindung warten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [079][get.handle][sub_getword.timeout][put.connected]
''                              : handle     - lfd. Nr. der zu testenden Verbindung
''                              : timeout    - Timeout in Millisekunden
''                              : connected  - True, if connected

  handle := bus_getchar
  timeout := sub_getword

  t := cnt
  repeat until (connected := sock.isConnected(handle)) or (((cnt - t) / (clkfreq / 1000)) > timeout)

  bus_putchar(connected)

PRI lan_close | handle
''funktionsgruppe               : lan
''funktion                      : TCP-Verbindung (ein- oder ausgehend) schließen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [080][get.handle]
''                              : handle - lfd. Nr. der zu schließenden Verbindung

  handle := bus_getchar

  sock.close(handle)

PRI lan_rxflush
PRI lan_rxcheck | handle, rxbyte
''funktionsgruppe               : lan
''funktion                      : ASCII-Zeichen lesen, wenn vorhanden
''                              : nicht verwenden, wenn anderes als ASCII (0 - 127) empfangen wird
''                              : (vor allem nicht, wenn -1 und -3 enthalten sein können)
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [082][get.handle][put.rxbyte]
''                              : handle  - lfd. Nr. der Verbindung
''                              : rxbyte  - empfangenes Zeichen (0 - 127) oder
''                              :           sock#RETBUFFEREMPTY (-1) wenn Puffer leer
''                              :           sock#ERRSOCKETCLOSED (-3) wenn keine Verbindung mehr

  handle := bus_getchar

  rxbyte := sock.readByteNonBlocking(handle)
  if (not sock.isConnected(handle)) and (rxbyte == -1)
    rxbyte := sock#ERRSOCKETCLOSED

  bus_putchar(rxbyte)

PRI lan_rxtime | handle, timeout, t, rxbyte
''funktionsgruppe               : lan
''funktion                      : angegebene Zeit auf ASCII-Zeichen warten
''                              : nicht verwenden, wenn anderes als ASCII (0 - 127) empfangen wird
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [083][get.handle][sub_getword.timeout][put.rxbyte]
''                              : handle  - lfd. Nr. der Verbindung
''                              : timeout - Timeout in Millisekunden
''                              : rxbyte  - empfangenes Zeichen (0 - 127) oder
''                              :           sock#RETBUFFEREMPTY (-1) wenn Timeout oder keine Verbindung mehr

  handle := bus_getchar
  timeout := sub_getword

  t := cnt
  repeat until (rxbyte := sock.readByteNonBlocking(handle)) => 0 or (not sock.isConnected(handle)) or (cnt - t) / (clkfreq / 1000) > timeout

  bus_putchar(rxbyte)

PRI lan_rxbyte
PRI lan_rxdatatime
PRI lan_rxdata
PRI lan_txflush
PRI lan_txcheck | handle, txbyte
''funktionsgruppe               : lan
''funktion                      : bei bestehender Verbindung ein ASCII-Zeichen zu senden
''                              : nicht verwenden, wenn anderes als ASCII (0 - 127) gesendet wird
''                              : (vor allem nicht, wenn -1 enthalten sein kann)
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [088][get.handle][get.tybyte][put.error]
''                              : handle - lfd. Nr. der Verbindung
''                              : txbyte - zu sendendes Zeichen
''                              : error  - ungleich Null bei Fehler

  handle := bus_getchar
  txbyte := bus_getchar

  ifnot sock.isConnected(handle)
    bus_putchar(sock#ERRSOCKETCLOSED)

  if (sock.writeByteNonBlocking(handle, txbyte) == txbyte)
    bus_putchar(0)
  else
    bus_putchar(sock#RETBUFFERFULL)


PRI lan_tx
PRI lan_txdata

DAT
                long                                    ' long alignment for addresses
  ip_addr       byte    10,  1, 1, 1                    'ip
  ip_subnet     byte    255, 255, 255, 0                'subnet-maske
  ip_gateway    byte    10,  1, 1, 254                  'gateway
  ip_dns        byte    10,  1, 1, 254                  'dns
  ip_boot       long    0                               'boot-server (IP address in long)
  mac_addr      byte    $c0, $de, $ba, $be, $00, $00    'mac-adresse

DAT                                                     'dummyroutine für getcogs
                        org
'
' Entry: dummy-assemblercode fuer cogtest
'
entry                   jmp     entry                   'just loops



{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, PRIlish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
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

