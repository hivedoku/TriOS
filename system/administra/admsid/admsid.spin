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
Name            : Administra-Flash (SD,SID)
Chip            : Administra
Typ             : Flash
Version         : 00
Subversion      : 01

Funktion        : Diese Codeversion basiert auf admini.spin und wird durch eine SID-Chip-Emulation als
                  Soundfunktion erweitert. Geladen werden zwei SIDCogs, wodurch insgesamt sechs unabhängige
                  Soundkanäle nutzbar sind, oder eine Kombination von einer SIDCog für SFX und einer SIDCog
                  für die Wiedergabe einer DMP-Datei direkt UND gleichzeitig von SD-Card möglich wird.
                  Zusätzlich zu den DMP-Files wird später noch ein einfacher Tracker integriert, welcher
                  die Musi nicht von SD-Card, sondern aus einem Puffer im hRam abspielt. Dadurch werden
                  auch während der Musikwiedergabe wieder Dateioperationen möglich, was ja so bei der
                  DMP-Playerroutine nicht geht.

                  Infos zur SIDCog: http://forums.parallax.com/forums/default.aspx?f=25&p=1&m=409209
                  
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

                  SIDCog-Funktionen:

                  
                  

Komponenten     : SIDCog         Ver. 080   Johannes Ahlebrand MIT Lizenz
                  FATEngine      01/18/2009 Kwabena W. Agyeman MIT Lizenz
                  RTCEngine      11/22/2009 Kwabena W. Agyeman MIT Lizenz
                  
COG's           : MANAGMENT     1 COG
                  FAT/RTC       1 COG
                  SIDCog's      2 COG's
                  DMP/Tracker   1 COG   (dynamisch)
                  -------------------
                                5 Cogs
                  
Logbuch         :

19-06-2010-dr235  - erste version aus admini.spin extrahiert
06-04-2012-dr235  - sid_dmpreg eingefügt

Kommandoliste   :

Notizen         :

Bekannte Fehler :


}}


CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000


'                   +----------
'                   |  +------- system     
'                   |  |  +---- version    (änderungen)
'                   |  |  |  +- subversion (hinzufügungen)
CHIP_VER        = $00_01_01_01

CHIP_SPEC = gc#A_FAT|gc#A_LDR|gc#A_SID

'
'          hbeat   --------+                            
'          clk     -------+|                            
'          /wr     ------+||                            
'          /hs     -----+||| +------------------------- /cs
'                       |||| |                 +------+ d0..d7
'                       |||| |                 |      |
DB_IN            = %00001001_00000000_00000000_00000000 'dira-wert für datenbuseingabe
DB_OUT           = %00001001_00000000_00000000_11111111 'dira-wert für datenbusausgabe

M1               = %00000010_00000000_00000000_00000000 'busclk=1? & /prop1=0?
M2               = %00000010_10000000_00000000_00000000 'maske: busclk & /cs (/prop1)

M3               = %00000000_00000000_00000000_00000000 'busclk=0?
M4               = %00000010_00000000_00000000_00000000 'maske: busclk

LED_OPEN     = gc#HBEAT                                 'led-pin für anzeige "dateioperation"
SD_BASE      = gc#A_SDD0                                'baspin cardreader


'index für dmarker
#0,     RMARKER                 'root
        SMARKER                 'system
        UMARKER                 'programmverzeichnis
        AMARKER
        BMARKER
        CMARKER

'sidcog

playRate        = 50            'Hz
detune          = 1.006

OBJ
  sdfat           : "adm-fat"        'fatengine
  sid1            : "adm-sid"        'SIDCog
  sid2            : "adm-sid"        'SIDCog
  gc              : "glob-con"       'globale konstanten

VAR

  long  dmarker[6]                                      'speicher für dir-marker
  byte  tbuf[20]                                        'stringpuffer
  byte  tbuf2[20]

  long  sidreg1                                         'adresse register der sidcog 1
  long  sidreg2                                         'adresse register der sidcog 2
  long  dmpcog                                          'id der dmp-player-cog
  long  dmpstack[50]                                    'stack für dmpcog
  byte  sidbuffer[25]                                   'puffer für dmpcog
  byte  dmpstatus                                       '0 = inaktiv; 1 = play; 2 = pause
  long  dmppos                                          'position des players im dump
  long  dmplen                                          'länge des dmp-files (anzahl regsitersätze)
  byte  dmppause                                        'pauseflag
  byte  s1buffer[25]                                    'registerpuffer sid1
  byte  s2buffer[25]                                    'registerpuffer sid2

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

'       ----------------------------------------------  CHIP-MANAGMENT
        gc#a_mgrGetSpec: mgr_getspec                    'spezifikation abfragen
        gc#a_mgrALoad: mgr_aload                        'neuen code booten
        gc#a_mgrGetCogs: mgr_getcogs                    'freie cogs abfragen
        gc#a_mgrGetVer: mgr_getver                      'codeversion abfragen
        gc#a_mgrReboot: reboot                          'neu starten

'       ----------------------------------------------  SIDCog: DMP-Player-Funktionen (SIDCog2)
        gc#a_s_mdmpplay: sid_mdmpplay                     'dmp-file mono auf sid2 abspielen
        gc#a_s_sdmpplay: sid_sdmpplay                     'dmp-file stereo auf beiden sids abspielen
        gc#a_s_dmpstop: sid_dmpstop                       'dmp-player beenden
        gc#a_s_dmppause: sid_dmppause                     'dmp-player pausenmodus
        gc#a_s_dmpstatus: sid_dmpstatus                   'dmp-player statusabfrage
        gc#a_s_dmppos: sid_dmppos                         'player-position im dumpfile
        gc#a_s_mute: sid_mute                             'alle register löschen

'       ----------------------------------------------  SIDCog1-Funktionen
        gc#a_s1_setRegister: sid1.setRegister(bus_getchar,bus_getchar)
        gc#a_s1_updateRegisters: sid1.updateRegisters(sub_getdat(25,@s1buffer))
        gc#a_s1_setVolume: sid1.setVolume(bus_getchar)
        gc#a_s1_play: sid1.play(bus_getchar,sub_getlong,bus_getchar,bus_getchar,bus_getchar,bus_getchar,bus_getchar)
        gc#a_s1_noteOn: sid1.noteOn(bus_getchar, sub_getlong)
        gc#a_s1_noteOff: sid1.noteOff(bus_getchar)
        gc#a_s1_setFreq: sid1.setFreq(bus_getchar,sub_getlong)
        gc#a_s1_setWaveform: sid1.setWaveform(bus_getchar,bus_getchar)
        gc#a_s1_setPWM: sid1.setPWM(bus_getchar,sub_getlong)
        gc#a_s1_setADSR: sid1.setADSR(bus_getchar,bus_getchar,bus_getchar,bus_getchar,bus_getchar)
        gc#a_s1_setResonance: sid1.setResonance(bus_getchar)
        gc#a_s1_setCutoff: sid1.setCutoff(sub_getlong)
        gc#a_s1_setFilterMask: sid1.setFilterMask(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s1_setFilterType: sid1.setFilterType(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s1_enableRingmod: sid1.enableRingmod(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s1_enableSynchronization: sid1.enableSynchronization(bus_getchar,bus_getchar,bus_getchar)

'       ----------------------------------------------  SIDCog2-Funktionen
        gc#a_s2_setRegister: sid2.setRegister(bus_getchar,bus_getchar)
        gc#a_s2_updateRegisters: sid2.updateRegisters(sub_getdat(25,@s1buffer))
        gc#a_s2_setVolume: sid2.setVolume(bus_getchar)
        gc#a_s2_play: sid2.play(bus_getchar,sub_getlong,bus_getchar,bus_getchar,bus_getchar,bus_getchar,bus_getchar)
        gc#a_s2_noteOn: sid2.noteOn(bus_getchar, sub_getlong)
        gc#a_s2_noteOff: sid2.noteOff(bus_getchar)
        gc#a_s2_setFreq: sid2.setFreq(bus_getchar,sub_getlong)
        gc#a_s2_setWaveform: sid2.setWaveform(bus_getchar,bus_getchar)
        gc#a_s2_setPWM: sid2.setPWM(bus_getchar,sub_getlong)
        gc#a_s2_setADSR: sid2.setADSR(bus_getchar,bus_getchar,bus_getchar,bus_getchar,bus_getchar)
        gc#a_s2_setResonance: sid2.setResonance(bus_getchar)
        gc#a_s2_setCutoff: sid2.setCutoff(sub_getlong)
        gc#a_s2_setFilterMask: sid2.setFilterMask(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s2_setFilterType: sid2.setFilterType(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s2_enableRingmod: sid2.enableRingmod(bus_getchar,bus_getchar,bus_getchar)
        gc#a_s2_enableSynchronization: sid2.enableSynchronization(bus_getchar,bus_getchar,bus_getchar)

'       ----------------------------------------------  Zusatzfunktionen
        gc#a_s_dmpreg: sid_dmpreg                                 'soundinformationen senden


PUB init_chip|i                                         'chip: initialisierung des administra-chips
''funktionsgruppe               : chip
''funktion                      : - initialisierung des businterface
''                                - grundzustand definieren (hss aktiv, systemklänge an)
''eingabe                       : -
''ausgabe                       : -


    repeat i from 0 to 7                                'evtl. noch laufende cogs stoppen
      ifnot i == cogid
        cogstop(i)

  'debugverbindung
  'debugx.start(9600)                                 ' Start des Debug-Terminals

  'businterface initialisieren
  outa[gc#bus_hs] := 1                                     'handshake inaktiv             ,frida
  dira := db_in                                         'datenbus auf eingabe schalten ,frida

  'sd-card starten
  clr_dmarker                                           'dir-marker löschen
  sdfat.FATEngine
  sd_mount("B")

  'soundsystem initialisieren
  sidreg1 := sid1.start(gc#A_SOUNDL,0)                      'erste sidcog starten, adresse der register speichern
  waitcnt(cnt+(clkfreq>>8))                             '
  sidreg2 := sid2.start(gc#A_SOUNDR,0)                      'zweite sidcog starten


PUB bus_putchar(zeichen)                                'chip: ein byte über bus ausgeben
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

PUB bus_getchar : zeichen                               'chip: ein byte über bus empfangen
''funktionsgruppe               : chip
''funktion                      : emfangsroutine für ein byte von regnatix über den systembus
''eingabe                       : -
''ausgabe                       : byte zeichen

  waitpeq(M1,M2,0)                                      'busclk=1? & /prop1=0?
  zeichen := ina[7..0]                                  'daten einlesen
  outa[gc#bus_hs] := 0                                  'daten quittieren
  outa[gc#bus_hs] := 1
  waitpeq(M3,M4,0)                                      'busclk=0?

PUB clr_dmarker| i                                      'chip: dmarker-tabelle löschen
''funktionsgruppe               : chip
''funktion                      : dmarker-tabelle löschen
''eingabe                       : -
''ausgabe                       : -

    i := 0
    repeat 6                                            'alle dir-marker löschen
      dmarker[i++] := TRUE

CON ''------------------------------------------------- SIDCog: DMP-Player-Funktionen (SIDCog2)

PRI sid_mdmpplay | err                                  'sid: dmp-datei mono auf sid2 abspielen
''funktionsgruppe               : sid
''funktion                      : dmp-datei mono auf sid2 abspielen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [157][sub_getstr.fn][put.error]
''                              : fn - name der dmp-datei
''                              : error - fehlernummer entspr. list
   sub_getstr
   err := \sdfat.openFile(@tbuf, "r")
   if err == 0
      dmppause := 0
      dmpcog := cognew(sid_dmpmcog,@dmpstack) + 1       'player-cog starten
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sid_sdmpplay | err                                  'sid: dmp-datei stereo auf beiden sid's abspielen

   sub_getstr
   err := \sdfat.openFile(@tbuf, "r")
   if err == 0
      dmppause := 0
      dmpcog := cognew(sid_dmpscog,@dmpstack) + 1       'player-cog starten
   bus_putchar(err)                                     'ergebnis der operation senden

PRI sid_dmpstop                                         'sid: dmp-player stoppen
  if dmpcog
    cogstop(dmpcog-1)
    dmpstatus := 0

PRI sid_dmppause|i                                      'sid: dmp-player pause
  case dmppause
    0: dmppause := 1
       repeat until dmpstatus == 2
       sid1.setVolume(0)
       sid2.setVolume(0)
    1: dmppause := 0

PRI sid_dmpstatus                                       'sid: status des dmp-players abfragen
  bus_putchar(dmpstatus)

PRI sid_dmppos                                          'sid: position/länge des dmp-players abfragen
  sub_putlong(dmppos)
  sub_putlong(dmplen)

PRI sid_mute|sidnr,i                                    'sid: ruhe!

  repeat i from 0 to 25
    sidbuffer[i] := 0
  sidnr := bus_getchar
  case sidnr
    1: sid1.updateRegisters(@sidbuffer)
    2: sid2.updateRegisters(@sidbuffer)
    3: sid1.updateRegisters(@sidbuffer)
       sid2.updateRegisters(@sidbuffer)

PRI sid_dmpmcog | i                                     'sid: dmpcog - mono, sid2

  dmpstatus := 1                                        'player läuft
  dmplen := \sdfat.listSize / 25
  dmppos := 0
  repeat dmplen
    waitcnt(cnt+(clkfreq/playRate))                     'warten auf den c64-vbl :)

   \sdfat.readData(@sidbuffer,25)                      '25 byte in den puffer einlesen

'    repeat i from 0 to 24                               'da blocktransfer nicht sicher funktioniert
'      sidbuffer[i] := sdfat.readCharacter               'füllen wir den puffer "manuell"

    sid2.updateRegisters(@sidbuffer)                    'puffer in die sid-register schreiben
    dmppos++
    if dmppause == 1
      dmpstatus := 2
    else
      dmpstatus := 1
    repeat while dmppause == 1                          'warten solange pause
  dmpstatus := 0                                        'player beendet

PRI sid_dmpscog | i                                     'sid: dmpcog - mono, sid2

  dmpstatus := 1                                        'player läuft
  dmplen := \sdfat.listSize / 25
  dmppos := 0
  repeat dmplen
    waitcnt(cnt+(clkfreq/playRate))                     'warten auf den c64-vbl :)

   \sdfat.readData(@sidbuffer,25)                      '25 byte in den puffer einlesen

'    repeat i from 0 to 24                               'da blocktransfer nicht sicher funktioniert
'      sidbuffer[i] := sdfat.readCharacter               'füllen wir den puffer "manuell"

    sid1.updateRegisters(@sidbuffer)                    'puffer in die sid-register schreiben
    sid2.updateRegisters(@sidbuffer)                    'puffer in die sid-register schreiben
    'eine sidcog etwas verstimmen
    word[sidreg2+0 ] := (word[sidreg2+0 ]<<16)/trunc(65536.0/detune)
    word[sidreg2+8 ] := (word[sidreg2+8 ]<<16)/trunc(65536.0/detune)
    word[sidreg2+16] := (word[sidreg2+16]<<16)/trunc(65536.0/detune)
    dmppos := dmppos + 1
    if dmppause == 1
      dmpstatus := 2
    else
      dmpstatus := 1
    repeat while dmppause == 1                          'warten solange pause
  dmpstatus := 0                                        'player beendet
PRI sid_dmpreg                                          'sid: dmpregister senden

  bus_putchar(byte[@sidbuffer+1])                       'kanal 1
  bus_putchar(byte[@sidbuffer+0])
  bus_putchar(byte[@sidbuffer+8])                       'kanal 2
  bus_putchar(byte[@sidbuffer+7])
  bus_putchar(byte[@sidbuffer+15])                      'kanal 3
  bus_putchar(byte[@sidbuffer+14])

  bus_putchar(byte[@sidbuffer+24])                      'volume



CON ''------------------------------------------------- SUBPROTOKOLL-FUNKTIONEN

PUB sub_getstr | i,len                                  'sub: string einlesen
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

PUB sub_getdat(len,datadr1):datadr2 | i                 'sub: daten einlesen
''funktionsgruppe               : sub
''funktion                      : subprotokoll um eine bestimmte anzahl bytes zu empfangen
''eingabe                       : len     - anzahl der bytes
''                              : datadr1 - adresse des datenspeichers
''ausgabe                       : datadr2 - adresse des datenspeichers
''busprotokoll                  : [get.byte(1)]..[get.byte(len)]

  repeat i from 0 to len - 1                            'dateiname einlesen
    tbuf[datadr1 + i] := bus_getchar
  datadr2 := datadr1

PUB sub_putstr(strptr)|len,i                            'sub: string senden
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

PUB sub_putlong(wert)                                   'sub: long senden       
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

PUB sub_getlong:wert                                    'sub: long empfangen    
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


PUB mgr_aload | err                                     'cmgr: neuen administra-code booten
''funktionsgruppe               : cmgr
''funktion                      : administra mit neuem code booten
''eingabe                       :
''ausgabe                       :
''busprotokoll                  : [096][sub_getstr.fn]
''                              : fn  - dateiname des neuen administra-codes
  sub_getstr
  err := \sdfat.bootPartition(@tbuf, "C")

PUB mgr_getcogs: cogs |i,c,cog[8]                       'cmgr: abfragen wie viele cogs in benutzung sind
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

PUB getcogs: cogs |i,c,cog[8]                           'cmgr: abfragen wie viele cogs in benutzung sind

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

PUB mgr_getver                                          'cmgr: abfrage der version 
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

PUB mgr_getspec                                         'cmgr: abfrage der spezifikation des chips
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

CON ''------------------------------------------------- SD-LAUFWERKS-FUNKTIONEN

PUB sd_mount(mode) | err                                'sdcard: sd-card mounten frida
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

PUB sd_opendir | err                                    'sdcard: verzeichnis öffnen
''funktionsgruppe               : sdcard
''funktion                      : verzeichnis öffnen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [002]

  err := \sdfat.listReset

PUB sd_nextfile | strpt                                 'sdcard: nächsten eintrag aus verzeichnis holen
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

PUB sd_open  | err,modus                                'sdcard: datei öffnen
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
   outa[LED_OPEN] := 1

PUB sd_close | err                                      'sdcard: datei schließen
''funktionsgruppe               : sdcard
''funktion                      : die aktuell geöffnete datei schließen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [005][put.error]
''                              : error - fehlernummer entspr. list

  err  := \sdfat.closeFile
  bus_putchar(err)                                      'ergebnis der operation senden
  outa[LED_OPEN] := 0
 
PUB sd_getc | n                                         'sdcard: zeichen aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus datei lesen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [006][put.char]
''                              : char - gelesenes zeichen

  n := \sdfat.readCharacter
  bus_putchar(n)

PUB sd_putc                                             'sdcard: zeichen in datei schreiben
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

PUB sd_getblk                                           'sdcard: block aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : block aus datei lesen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [008][sub_getlong.count][put.char(1)]..[put.char(count)]
''                              : count - anzahl der zu lesenden zeichen
''                              : char - gelesenes zeichen

  repeat sub_getlong
    bus_putchar(\sdfat.readCharacter)


PUB sd_putblk                                           'sdcard: block in datei schreiben
''funktionsgruppe               : sdcard
''funktion                      : block in datei schreiben
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [009][sub_getlong.count][put.char(1)]..[put.char(count)]
''                              : count - anzahl der zu schreibenden zeichen
''                              : char - zu schreibende zeichen

  repeat sub_getlong
    \sdfat.writeCharacter(bus_getchar)

PUB sd_seek | wert                                      'sdcard: zeiger in datei positionieren
''funktionsgruppe               : sdcard
''funktion                      : zeiger in datei positionieren
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [010][sub_getlong.pos]
''                              : pos - neue zeichenposition in der datei

  wert := sub_getlong
  \sdfat.setCharacterPosition(wert)

PUB sd_fattrib | anr,wert                               'sdcard: dateiattribute übergeben
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

PUB sd_volname                                          'sdcard: volumenlabel abfragen
''funktionsgruppe               : sdcard
''funktion                      : name des volumes überragen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [012][sub_putstr.volname]
''                              : volname - name des volumes
''                              : len   - länge des folgenden strings

  sub_putstr(\sdfat.listVolumeLabel)                    'label holen und senden

PUB sd_checkmounted                                     'sdcard: test ob volume gemounted ist
''funktionsgruppe               : sdcard
''funktion                      : test ob volume gemounted ist
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [013][put.flag]
''                              : flag  - 0 = unmounted, 1 mounted

  bus_putchar(\sdfat.checkPartitionMounted)

PUB sd_checkopen                                        'sdcard: test ob eine datei geöffnet ist
''funktionsgruppe               : sdcard
''funktion                      : test ob eine datei geöffnet ist
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [014][put.flag]
''                              : flag  - 0 = not open, 1 open

  bus_putchar(\sdfat.checkFileOpen)
  
PUB sd_checkused                                        'sdcard: anzahl der benutzten sektoren senden
''funktionsgruppe               : sdcard
''funktion                      : anzahl der benutzten sektoren senden 
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [015][sub_putlong.used]
''                              : used - anzahl der benutzten sektoren

  sub_putlong(\sdfat.checkUsedSectorCount("F"))

PUB sd_checkfree                                        'sdcard: anzahl der freien sektoren senden
''funktionsgruppe               : sdcard
''funktion                      : anzahl der freien sektoren senden 
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [016][sub_putlong.free]
''                              : free - anzahl der freien sektoren

  sub_putlong(\sdfat.checkFreeSectorCount("F"))

PUB sd_newfile | err                                    'sdcard: eine neue datei erzeugen
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

PUB sd_newdir | err                                     'sdcard: ein neues verzeichnis erzeugen
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

PUB sd_del | err                                        'sdcard: eine datei oder ein verzeichnis löschen
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

PUB sd_rename | err                                     'sdcard: datei oder verzeichnis umbenennen
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
   
PUB sd_chattrib | err                                   'sdcard: attribute ändern
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

PUB sd_chdir | err                                      'sdcard: verzeichnis wechseln
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

PUB sd_format | err                                     'sdcard: medium formatieren
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

PUB sd_unmount | err                                    'sdcard: medium abmelden
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
    
PUB sd_dmact|markernr                                   'sdcard: einen dir-marker aktivieren
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


PUB sd_dmset|markernr                                   'sdcard: einen dir-marker setzen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker mit dem aktuellen verzeichnis setzen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [026][get.dmarker]
''                              : dmarker - dir-marker      

  markernr := bus_getchar
  dmarker[markernr] := sdfat.getDirCluster

PUB sd_dmget|markernr                                   'sdcard: einen dir-marker abfragen
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

PUB sd_dmclr|markernr                                   'sdcard: einen dir-marker löschen
''funktionsgruppe               : sdcard
''funktion                      : ein ausgewählter dir-marker löschen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [028][get.dmarker]
''                              : dmarker - dir-marker      

  markernr := bus_getchar
  dmarker[markernr] := TRUE
    



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
                      
