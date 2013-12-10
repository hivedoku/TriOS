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
Name            : Regime
Chip            : Regnatix
Typ             : Programm
Version         : 00
Subversion      : 02

Funktion        : "Regime" ist ein einfacher Kommandozeileninterpreter für das Betriebssystem TriOS.

help                     - diese hilfe
<sd:dateiname>           - bin/adm/bel-datei wird gestartet
mount                    - sd-card mounten
unmount                  - sd-card abmelden
dir <wh>                 - verzeichnis anzeigen
type <sd:fn>             - anzeige einer textdatei
aload <sd:fn>            - administra-code laden
bload <sd:fn>            - bellatrix-treiber laden
rload <sd:fn>            - regnatix-code laden
del <sd:fn>              - datei löschen
cls                      - bildschirm löschen
free                     - freier speicher auf sd-card
attrib <sd:fn> <ashr>    - attribute ändern
cd <sd:dir>              - verzeichnis wechseln
mkdir <sd:dir>           - verzeichnis erstellen
rename <sd:fn1> <sd:fn2> - datei/verzeichnis umbenennen
format <volname>         - sd-card formatieren
reboot                   - hive neu starten
sysinfo                  - systeminformationen
color <0..7>             - farbe wählen
cogs                     - belegung der cogs anzeigen
dmlist                   - anzeige der verzeichnis-marker
dm <r/s/u/a/b/c>         - in das entsprechende marker-
                           verzeichnis wechseln
dmset <r/s/u/a/b/c>      - setzt den entsprechenden marker
                           auf das aktuelle verzeichnis
dmclr <r/s/u/a/b/c>      - marker löschen
forth                    - forth starten

marker:
r       - root-verzeichnis
s       - system-verzeichnis
u       - user-verzeichnis
a/b/c   - benutzerdefinierte verzeichnismarker
r, s, u-marker werden vom system automatisch gesetzt und
intern verwendet.

RAMDISK:

xload <sd:fn>           - datei in ram laden
xsave <x:fn>            - datei aus ram speichern
xdir                    - verzeichnis im ram anzeigen
xrename <x:fn1> <x:fn2> - datei im ram umbenennen
xdel <x:fn>             - datei im ram löschen
xtype <x:fn>            - text im ram anzeigen

Logbuch         :

22-03-2010-dr235  - anpassung trios
10-04-2010-dr235  - alternatives dir-marker-system eingefügt
17-04-2010-dr235  - dm-user wird jetzt auch beim start aus dem aktuellen dir gesetzt
30-04-2010-dr235  - mount robuster gestaltet
19-09-2010-dr235  - integration ramdisk
                  - kommandos: xdir, xdel, xrename, xload, xsave, xtype
20-09-2010-dr235  - blocktransfer für xload/xsave (wesentlich bessere geschwindigkeit!!!)
07.04.2013-dr235  - div. anpassungen für alternative videomodis (tv)


}}

OBJ
        ios: "reg-ios"
        str: "glob-string"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OS_TIBLEN       = 64                                    'größe des inputbuffers
OS_MLEN         = 8
ERAM            = 1024 * 512 * 2                        'größe eram
HRAM            = 1024 * 32                             'größe hram

RMON_ZEILEN     = 16                                    'speichermonitor - angezeigte zeilen
RMON_BYTES      = 8                                     'speichermonitor - zeichen pro byte

VGA             = 0
TV              = 1

VAR
'systemvariablen
  byte tib[OS_TIBLEN]           'tastatur-input-buffer
  byte cmdstr[OS_TIBLEN]        'kommandostring für interpreter
  byte token1[OS_TIBLEN]        'parameterstring 1 für interpreter
  byte token2[OS_TIBLEN]        'parameterstring 2 für interpreter
  byte tibpos                   'aktuelle position im tib
  byte rows                     'aktuelle anzahl der nutzbaren zeilen
  byte cols                     'aktuelle Anzahl der nutzbaren spalten
  byte cog[8]                   'array for free-cog counter
  byte act_color                'Speicher für gewählte zeichenfarbe
  byte vidmod                   'videomodus: 0 - vga, 1 -  tv

PUB main | flag                                         

  flag := ios.start                                     'ios initialisieren

  if flag == 0                                          'kaltstart?
     ios.screeninit                                     'systemmeldung
     ios.ram_wrbyte(0,1,ios#SIFLAG)                     'screeninit-flag setzen
     ios.os_error(ios.sdmount)                          'sd-card mounten

  if 0 == ios.ram_rdbyte(0,ios#SIFLAG)                  'screen neu initialisieren?
     ios.screeninit                                     'systemmeldung
     ios.ram_wrbyte(0,1,ios#SIFLAG)

  ios.sddmact(ios#DM_USER)                              'wieder in userverzeichnis wechseln

  ios.printnl
  ios.print(@prompt1)
  repeat
    os_testvideo                                        'neuer videomodus?
    os_cmdinput                                         'kommandoeingabe
    os_cmdint                                           'kommandozeileninterpreter


CON ''------------------------------------------------- INTERPRETER

PRI os_cmdinput | charc                                 'sys: stringeingabe eine zeile
''funktionsgruppe               : sys
''funktion                      : stringeingabe eine zeile
''eingabe                       : -
''ausgabe                       : -
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

  ios.print(@prompt3)
  tibpos := 0                                           'tibposition auf anfang setzen
  repeat until (charc := ios.keywait) == $0D            'tasten einlesen bis return
    if (tibpos + 1) < OS_TIBLEN                         'zeile noch nicht zu lang?
      case charc
        ios#CHAR_BS:                                    'backspace
          if tibpos > 0                                 'noch nicht anfang der zeile erreeicht?
            tib[tibpos--] := 0                          'ein zeichen aus puffer entfernen
            ios.printbs                                 'backspace an terminal senden
        ios#KEY_CURUP: os_tibpop
        ios#KEY_CURDOWN: os_tibclear
        other:                                          'zeicheneingabe
          tib[tibpos++] := charc                        'zeichen speichern
          ios.printchar(charc)                          'zeichen ausgeben
  ios.printnl
  tib[tibpos] := 0                                      'string abschließen
  tibpos := charc := 0                                  'werte rücksetzen
  if tib[tibpos]
    os_tibpush

PRI os_tibpush | i

  i := 0
  repeat OS_TIBLEN
    'tib2[i] := tib[i]
    ios.ram_wrbyte(0,tib[i],ios#TIB2+i)
    i++

PRI os_tibpop | i

  i := 0
  os_tibclear
  repeat OS_TIBLEN
    tib[i] := ios.ram_rdbyte(0,ios#TIB2+i)
    i++
  ios.curpos1
  ios.print(@prompt3)
  ios.print(@tib)
  tibpos := strsize(@tib)

PRI os_tibclear | i

  i := 0
  ios.curoff
  repeat OS_TIBLEN
    tib[i] := 0
    i++
  ios.curpos1
  repeat 63
    ios.printchar(" ")
  ios.curpos1
  ios.print(@prompt3)
  ios.print(@tib)
  tibpos := strsize(@tib)
  ios.curon

PRI os_nxtoken1: stradr                                 'sys: token 1 von tib einlesen
''funktionsgruppe               : sys
''funktion                      : nächsten token im eingabestring suchen und stringzeiger übergeben
''eingabe                       : -
''ausgabe                       : stradr  - adresse auf einen string mit dem gefundenen token
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib
''                              : token   - tokenstring

  stradr := os_tokenize(@token1)

PRI os_nxtoken2: stradr                                 'sys: token 2 von tib einlesen
''funktionsgruppe               : sys
''funktion                      : nächsten token im eingabestring suchen und stringzeiger übergeben
''eingabe                       : -
''ausgabe                       : stradr  - adresse auf einen string mit dem gefundenen token
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib
''                              : token   - tokenstring

  stradr := os_tokenize(@token2)

PRI os_tokenize(token):stradr | i                       'sys: liest nächsten token aus tib
                     
  i := 0  
  if tib[tibpos] <> 0                                   'abbruch bei leerem string
    repeat until tib[tibpos] > ios#CHAR_SPACE           'führende leerzeichen ausbenden
      tibpos++
    repeat until (tib[tibpos] == ios#CHAR_SPACE) or (tib[tibpos] == 0) 'wiederholen bis leerzeichen oder stringende
      byte[token][i] := tib[tibpos]
      tibpos++
      i++
  byte[token][i] := 0
  stradr := token

PRI os_nextpos: tibpos2                                 'sys: setzt zeiger auf nächste position
''funktionsgruppe               : sys
''funktion                      : tibpos auf nächstes token setzen
''eingabe                       : -
''ausgabe                       : tibpos2 - position des nächsten tokens in tib
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

  if tib[tibpos] <> 0
    repeat until tib[tibpos] > ios#CHAR_SPACE               'führende leerzeichen ausbenden
      tibpos++
  return tibpos

PRI os_cmdint                                           'sys: kommandointerpreter
''funktionsgruppe               : sys
''funktion                      : kommandointerpreter; zeichenkette ab tibpos wird als kommando interpretiert
''                              : tibpos wird auf position hinter token gesetzt
''eingabe                       : -
''ausgabe                       : -
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

if tib[tibpos]
  repeat                                                'kommandostring kopieren
    cmdstr[tibpos] := tib[tibpos]                       
    tibpos++
  until (tib[tibpos] == ios#CHAR_SPACE) or (tib[tibpos] == 0) 'wiederholen bis leerzeichen oder stringende
  cmdstr[tibpos] := 0                                   'kommandostring abschließen
  os_cmdexec(@cmdstr)                                   'interpreter aufrufen
  tibpos := 0                                           'tastaturpuffer zurücksetzen
  tib[0] := 0

DAT ''------------------------------------------------- Kommandostrings

cmd1    byte  "help",0
cmd2    byte  "mount",0
cmd3    byte  "dir",0
cmd4    byte  "type",0
cmd5    byte  "rload",0
cmd6    byte  "cls",0
cmd7    byte  "bload",0
cmd8    byte  "del",0
cmd9    byte  "unmount",0
cmd10   byte  "free",0
cmd11   byte  "attrib",0
cmd12   byte  "cd",0
cmd13   byte  "aload",0
cmd14   byte  "mkdir",0
cmd15   byte  "rename",0
cmd16   byte  "format",0
cmd17   byte  "reboot",0
cmd18   byte  "sysinfo",0
cmd19   byte  "color",0
cmd20   byte  "cogs",0
cmd21   byte  "dm",0
cmd22   byte  "dmset",0
cmd23   byte  "dmclr",0
cmd24   byte  "dmlist",0
cmd25   byte  "debug",0
cmd26   byte  "xload",0
cmd27   byte  "xsave",0
cmd28   byte  "xdir",0
cmd29   byte  "xrename",0
cmd30   byte  "xdel",0
cmd31   byte  "xtype",0
cmd32   byte  "forth",0
cmd33   byte  "vga",0

PRI os_cmdexec(stradr)                                  'sys: kommando ausführen
{{os_smdexec - das kommando im übergebenen string wird als kommando interpretiert
  stradr: adresse einer stringvariable die ein kommando enthält}}


if     strcomp(stradr,@cmd14)                           'mkdir - verzeichnis erstellen
       cmd_mkdir
elseif strcomp(stradr,@cmd15)                           'rename - datei/verzeichnis umbenennen
       cmd_rename
elseif strcomp(stradr,@cmd16)                           'format - sd-card formatieren
       cmd_format
elseif strcomp(stradr,@cmd17)                           'reboot
       cmd_reboot
elseif strcomp(stradr,@cmd18)                           'sysinfo
       cmd_sysinfo
elseif strcomp(stradr,@cmd19)                           'color
       cmd_color
elseif strcomp(stradr,@cmd20)                           'cogs
       cmd_cogs
elseif strcomp(stradr,@cmd21)                           'dm
       cmd_dm
elseif strcomp(stradr,@cmd22)                           'dmset
       cmd_dmset
elseif strcomp(stradr,@cmd23)                           'dmclr
       cmd_dmclr
elseif strcomp(stradr,@cmd24)                           'dmlist
       cmd_dmlist
elseif strcomp(stradr,@cmd25)                           'debug
       cmd_debug
elseif strcomp(stradr,@cmd1)                          'help
       cmd_help
elseif strcomp(stradr,@cmd2)                          'mount - sd-card mounten
       cmd_mount
elseif strcomp(stradr,@cmd3)                          'dir - verzeichnis anzeigen
       cmd_dir
elseif strcomp(stradr,@cmd4)                          'type - textdatei auf bildschirm ausgeben
       cmd_type
elseif strcomp(stradr,@cmd5)                          'rload - lade regnatix-code
       os_load
elseif strcomp(stradr,@cmd6)                          'cls - bildschirm löschen
       ios.printcls
elseif strcomp(stradr,@cmd7)                          'bload - lade bellatrix-code
       cmd_bload
elseif strcomp(stradr,@cmd8)                          'del - datei löschen
       cmd_del
elseif strcomp(stradr,@cmd9)                          'unmount - medium abmelden
       cmd_unmount
elseif strcomp(stradr,@cmd10)                         'free - anzeige datenträgerbelegung
       cmd_free
elseif strcomp(stradr,@cmd11)                         'attrib - attribute ändern
       cmd_attrib
elseif strcomp(stradr,@cmd12)                         'cd - verzeichnis wechseln
       cmd_cd
elseif strcomp(stradr,@cmd13)                         'aload - lade administra-code
       cmd_aload
elseif strcomp(stradr,@cmd26)                         'xload
  rd_load
elseif strcomp(stradr,@cmd27)                         'xsave
  rd_save
elseif strcomp(stradr,@cmd28)                         'xdir
  rd_dir
elseif strcomp(stradr,@cmd29)                         'xrename
  rd_rename
elseif strcomp(stradr,@cmd30)                         'xdel
  rd_del
elseif strcomp(stradr,@cmd31)                         'xtype
  rd_type
elseif strcomp(stradr,@cmd32)                         'forth
  reboot
elseif strcomp(stradr,@cmd33)                         'vga
  ios.belreset
elseif os_testbin(stradr)                             '.bin
elseif os_testadm(stradr)                             '.adm
elseif os_testbel(stradr)                             '.bel
else                                                  'kommando nicht gefunden
    ios.print(stradr)
    ios.print(@msg3)
ios.print(@prompt1)

{
PUB os_error(err):error                                 'sys: fehlerausgabe

  if err
    ios.printnl
    ios.print(@err_s1)
    ios.printdec(err)
    ios.print(string(" : $"))
    ios.printhex(err,2)
    ios.printnl
    ios.print(@err_s2)
    case err
      0: ios.print(@err0)
      1: ios.print(@err1)
      2: ios.print(@err2)
      3: ios.print(@err3)
      4: ios.print(@err4)
      5: ios.print(@err5)
      6: ios.print(@err6)
      7: ios.print(@err7)
      8: ios.print(@err8)
      9: ios.print(@err9)
      10: ios.print(@err10)
      11: ios.print(@err11)
      12: ios.print(@err12)
      13: ios.print(@err13)
      14: ios.print(@err14)
      15: ios.print(@err15)
      16: ios.print(@err16)
      17: ios.print(@err17)
      18: ios.print(@err18)
      19: ios.print(@err19)
      20: ios.print(@err20)
      OTHER: ios.print(@errx)
    ios.printnl
  error := err
}
PRI os_load | len,i,stradr1,stradr2                     'sys: startet bin-datei über loader
{{ldbin - startet bin-datei über loader}}
  ios.paraset(@tib + os_nextpos)                        'parameterstring kopieren
  ios.ldbin(os_nxtoken1)

PRI os_testbin(stradr): flag | status,i,len             'sys: testet ob das kommando als bin-datei vorliegt
{{testbin(stradr): flag - testet ob das kommando als bin-datei vorliegt
                        - string bei stradr wird um .bin erweitert
                        - flag = TRUE - kommando gefunden}}

  flag := FALSE
  len := strsize(stradr)
  repeat i from 0 to 3                                  '.bin anhängen
    byte[stradr][len + i] := byte[@ext1][i]
  byte[stradr][len + i] := 0

' im aktuellen dir suchen
  ios.sddmset(ios#DM_USER)                              'u-marker setzen
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
     flag := TRUE
     ios.paraset(@tib + os_nextpos)                     'parameterstring kopieren
     ios.ldbin(stradr)                                  'anwendung starten
  ios.sdclose

'im system-dir suchen
  ios.sddmset(ios#DM_USER)                              'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                            's-marker aktivieren
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
     flag := TRUE
     ios.paraset(@tib + os_nextpos)                     'parameterstring kopieren
     ios.ldbin(stradr)                                  'anwendung starten
  ios.sdclose
  ios.sddmact(ios#DM_USER)                              'u-marker aktivieren

'vorbereiten für suche nach anderen dateien
  byte[stradr][len] := 0                                'extender wieder abschneiden

PRI os_testadm(stradr): flag | status,i,len,dmu         'sys: test ob kommando als adm-datei vorliegt

  flag := FALSE
  len := strsize(stradr)
  repeat i from 0 to 3                                  '.bel anhängen
    byte[stradr][len + i] := byte[@ext2][i]
  byte[stradr][len + i] := 0

' im aktuellen dir suchen
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
     flag := TRUE
    ios.admload(stradr)                                 'administra-code laden
  else                                                  'datei nicht gefunden
  ios.sdclose

'im system-dir suchen
  ios.sddmset(ios#DM_USER)                              'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                            's-marker aktivieren
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
    flag := TRUE
    dmu := ios.sddmget(ios#DM_USER)                     'usermarker von administra holen
    ios.admload(stradr)                                 'administra-code laden
    ios.sddmput(ios#DM_USER,dmu)                        'usermarker wieder in administra setzen
  else                                                  'datei nicht gefunden
  ios.sdclose
  ios.sddmact(ios#DM_USER)                              'u-marker aktivieren

  byte[stradr][len] := 0                                'extender wieder abschneiden

PRI os_testbel(stradr): flag | status,i,len             'sys: test ob kommando als bel-datei vorliegt

  flag := FALSE
  len := strsize(stradr)
  repeat i from 0 to 3                                  '.bel anhängen
    byte[stradr][len + i] := byte[@ext3][i]
  byte[stradr][len + i] := 0

' im aktuellen dir suchen
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
    flag := TRUE
    ios.belload(stradr)                                 'bellatrix-code laden
    ios.screeninit                                      'systemmeldung
  else                                                  'datei nicht gefunden
  ios.sdclose

'im system-dir suchen
  ios.sddmset(ios#DM_USER)                              'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                            's-marker aktivieren
  status := ios.sdopen("r",stradr)                      'datei vorhanden?
  if status == 0                                        'datei gefunden
    flag := TRUE
    ios.belload(stradr)                                 'bellatrix-code laden
    ios.screeninit                                      'systemmeldung
  else                                                  'datei nicht gefunden
  ios.sdclose
  ios.sddmact(ios#DM_USER)                              'u-marker aktivieren

  byte[stradr][len] := 0                                'extender wieder abschneiden

PRI os_printstr(strptr1,strptr2):strptr3

  ios.print(strptr1)
  ios.print(strptr2)
  ios.printnl
  strptr3 := strptr2

PRI os_printdec(strptr, wert):wert2

  ios.print(strptr)
  ios.printdec(wert)
  ios.printnl
  wert2 := wert

PRI os_testvideo                                        'sys: passt div. variablen an videomodus an

  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen

PRI os_tvwait

  if vidmod == TV
    ios.keywait

CON ''------------------------------------------------- KOMMANDOS

PRI rd_dir | stradr,len                                 'rd: dir anzeigen

if ios.ram_rdbyte(ios#sysmod,ios#RAMDRV)
  ios.rd_dir
  repeat
    len := ios.rd_dlen
    stradr := ios.rd_next
    if stradr
      ios.print(stradr)
      ios.printtab
      ios.printdec(len)
      ios.printnl
  until stradr == 0
else
  ios.os_error(1)

PRI rd_load | stradr,len,fnr,i                          'rd: datei in ramdisk laden

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  ifnot ios.os_error(ios.sdopen("r",stradr))            'datei öffnen
    len := ios.sdfattrib(ios#F_SIZE)
    ios.rd_newfile(stradr,len)                          'datei erzeugen
    fnr := ios.rd_open(stradr)
    ios.rd_seek(fnr,0)
    ios.print(string("Datei laden... "))
    i := 0
    ios.sdxgetblk(fnr,len)                              'daten als block direkt in ext. ram einlesen
    ios.sdclose
    ios.rd_close(fnr)

PRI rd_save | stradr,fnr,len,i                          'rd: datei aus ramdisk speichern

  stradr := os_nxtoken1
  fnr := ios.rd_open(stradr)
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ifnot ios.os_error(ios.sdnewfile(stradr))
      ifnot ios.os_error(ios.sdopen("W",stradr))
        ios.print(string("Datei schreiben... "))
        i := 0
        ios.sdxputblk(fnr,len)                          'daten als block schreiben
        ios.sdclose
        ios.printnl
    ios.rd_close(fnr)

PRI rd_rename                                           'rd: datei in ramdisk umbenennen

  ios.os_error(ios.rd_rename(os_nxtoken1,os_nxtoken2))

PRI rd_del | adr                                        'rd: datei löschen

  ios.os_error(ios.rd_del(os_nxtoken1))

PRI rd_type | stradr,len,fnr,n                          'rd: text ausgeben

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  fnr := ios.rd_open(stradr)                            'datei öffnen
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ios.rd_seek(fnr,0)
    repeat len
      if ios.printchar(ios.rd_get(fnr)) == ios#CHAR_NL       'zeilenzahl zählen und stop
        if ++n == (rows - 2)
          n := 1
          if ios.keywait == "q"
            ios.sdclose
            return
    ios.rd_close(fnr)


PRI cmd_debug|stradr,len,fnr,i,x                        'cmd: temporäre debugfunktion

  ios.print(string("Debug : "))
  ios.printnl
  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  ifnot ios.os_error(ios.sdopen("r",stradr))            'datei öffnen
    len := ios.sdfattrib(ios#F_SIZE)
    ios.rd_newfile(stradr,len)                          'datei erzeugen
    fnr := ios.rd_open(stradr)
    ios.rd_seek(fnr,0)
    ios.print(string("Datei laden... "))
    i := 0
    x := ios.curgetx
    ios.curoff
    ios.sdxgetblk(fnr,len)                              'daten als block direkt in ext. ram einlesen
    ios.print(string("ok"))
    ios.curon
    ios.sdclose
    ios.rd_close(fnr)

PRI cmd_dm|wert                                         'cmd: dir-marker aktivieren

  ios.os_error(ios.sddmact(cmd_dm_nr))

PRI cmd_dmset                                           'cmd: dir-marker setzen

  ios.sddmset(cmd_dm_nr)

PRI cmd_dmclr                                           'cmd: dir-marker löschen

  ios.sddmclr(cmd_dm_nr)

PRI cmd_dmlist                                          'cmd: dir-marker auflisten

  ios.setcolor(ios#YELLOW)
  ios.print(@msg25)
  cmd_dm_status(ios#DM_ROOT)
  ios.print(@msg24)
  cmd_dm_status(ios#DM_SYSTEM)
  ios.print(@msg26)
  cmd_dm_status(ios#DM_USER)
  ios.setcolor(act_color)
  ios.print(@msg27)
  cmd_dm_status(ios#DM_A)
  ios.print(@msg28)
  cmd_dm_status(ios#DM_B)
  ios.print(@msg29)
  cmd_dm_status(ios#DM_C)
  
PRI cmd_dm_status(markernr)

  if ios.sddmget(markernr) == TRUE
    ios.print(@msg31)
  else
    ios.print(@msg30)
    
PRI cmd_dm_nr:wert

  case byte[os_nxtoken1]
    "r": wert := 0              'root
    "s": wert := 1              'system
    "u": wert := 2              'user
    "a": wert := 3              'marker a
    "b": wert := 4              'marker b
    "c": wert := 5              'marker c
    other: wert := 0

PRI cmd_color                                           'cmd: zeichenfarbe wählen

  ios.setcolor(str.decimalToNumber(act_color := os_nxtoken1))
  
PRI cmd_sysinfo                                         'cmd: systeminformationen anzeigen

  ios.printnl
  os_printstr(@msg22,@syst)
  os_printstr(@msg14,@prog)
  os_printstr(@msg23,@copy)
  if ios.sdcheckmounted                                 'test ob medium gemounted ist
    os_printstr(@msg21,ios.sdvolname)
  ios.printnl
  os_tvwait

  os_printstr(@msg15,str.numberToBinary(ios#CHIP_VER,32))
  os_printstr(@msg16,str.numberToBinary(ios#CHIP_SPEC,32))
  os_printstr(@msg17,str.numberToBinary(ios.admgetver,32))
  os_printstr(@msg18,str.numberToBinary(ios.admgetspec,32))
  os_tvwait

  os_printstr(@msg19,str.numberToBinary(ios.belgetver,32))
  os_printstr(@msg20,str.numberToBinary(ios.belgetspec,32))
  os_printstr(@msg32,str.numberToDecimal(ios.belgetcols,4))
  os_printstr(@msg33,str.numberToDecimal(ios.belgetrows,4))
  os_printstr(@msg34,str.numberToDecimal(ios.belgetresx,4))
  os_printstr(@msg35,str.numberToDecimal(ios.belgetresy,4))

  if vidmod == VGA
    os_printstr(@msg36,@msg37)
  else
    os_printstr(@msg36,@msg38)

PRI cmd_mount | err                                     'cmd: mount

    repeat 16
       err := ios.sdmount
       ifnot err
         quit
    ios.os_error(err)
    ifnot err
      ios.setcolor(ios#YELLOW)
      ios.print(@msg4)
      ios.print(ios.sdvolname)
      ios.printnl
      ios.print(@msg25)
      cmd_dm_status(ios#DM_ROOT)
      ios.print(@msg24)
      cmd_dm_status(ios#DM_SYSTEM)
      ios.printnl
      ios.setcolor(act_color)

PRI cmd_unmount                                         'cmd: unmount

  ios.os_error(ios.sdunmount)

PRI cmd_free | wert                                     'cmd: anzeige freier speicher

  os_printstr(@msg5,ios.sdvolname)
  wert := os_printdec(@msg6,ios.sdcheckfree*512/1024)
  wert += os_printdec(@msg7,ios.sdcheckused*512/1024)
          os_printdec(@msg8,wert)

  ios.printnl
  ios.print(string("RBAS   : $"))
  ios.printhex(ios.ram_rdlong(ios#sysmod,ios#RAMBAS),8)
  ios.printnl
  ios.print(string("REND   : $"))
  ios.printhex(ios.ram_rdlong(ios#sysmod,ios#RAMEND),8)
  ios.printnl
  ios.print(string("USER   : $"))
  wert := ios.ram_rdlong(ios#sysmod,ios#RAMEND)
  wert := wert - ios.ram_rdlong(ios#sysmod,ios#RAMBAS)
  ios.printhex(wert,8)
  ios.printnl
  ios.print(string("RAMDRV : $"))
  ios.printhex(ios.ram_rdbyte(ios#sysmod,ios#RAMDRV),2)
  ios.printnl
  ios.print(string("SYSVAR : $"))
  ios.printhex(ios#SYSVAR,8)
  ios.printnl

PRI cmd_attrib                                          'cmd: dateiattribute ändern
' A-Archive, S-System, H-Hidden, R-Read Only.

  ios.os_error(ios.sdchattrib(os_nxtoken1,os_nxtoken2))

PRI cmd_rename                                          'cmd: datei/verzeichnis umbenennen

  ios.os_error(ios.sdrename(os_nxtoken1,os_nxtoken2))

PRI cmd_cd                                              'cmd: verzeichnis wechseln

  ios.os_error(ios.sdchdir(os_nxtoken1))

PRI cmd_mkdir                                           'cmd: verzeichnis erstellen

  ios.os_error(ios.sdnewdir(os_nxtoken1))

PRI cmd_del | stradr,char                               'cmd: datei auf sdcard löschen
{{sddel - datei auf sdcard löschen}}

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  ios.print(@msg2)       
  if ios.keywait == "j"
    ios.os_error(ios.sddel(stradr))

PRI cmd_format | stradr                                 'cmd: sd-card formatieren

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  ios.print(@msg12)
  if ios.keywait == "j"
    ios.os_error(ios.sdformat(stradr))

PRI cmd_reboot | key, stradr                            'cmd: reboot

  ios.print(@msg13)
  key := ios.keywait
  case key
    "c": ios.ram_wrbyte(ios#sysmod,0,ios#MAGIC)
         ios.ram_wrbyte(ios#sysmod,0,ios#RAMDRV)
         ios.admreset
         ios.belreset
         waitcnt(cnt+clkfreq*3)
         reboot
    "w": ios.ram_wrbyte(ios#sysmod,0,ios#SIFLAG)
         reboot

PRI cmd_aload|status,stradr                             'cmd: administra-code laden

  stradr := os_nxtoken1
  status := ios.sdopen("r",stradr)
  if status == 0
    ios.admload(stradr)                                 'administra-code laden
  else
    ios.os_error(status)
  
PRI cmd_bload | stradr,status                           'cmd: bellatrix-code laden
{{bload - treiber für bellatrix laden}}

  stradr := os_nxtoken1
  status := ios.sdopen("r",stradr)
  if status == 0
    ios.belload(stradr)                                 'treiberupload
    ios.screeninit                                      'systemmeldung
    ios.print(@prog)                                    'programmversion
  else
    ios.os_error(status)
    
PRI cmd_type | stradr,char,n                            'cmd: textdatei ausgeben
{{sdtype <name> - textdatei ausgeben}}

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  n := 1
  ifnot ios.os_error(ios.sdopen("r",stradr))            'datei öffnen
    repeat                                              'text ausgeben
      if ios.printchar(ios.sdgetc) == ios#CHAR_NL       'zeilenzahl zählen und stop
        if ++n == (rows - 2)
          n := 1
          if ios.keywait == "q"
            ios.sdclose
            return
    until ios.sdeof                                     'ausgabe bis eof
  ios.sdclose                                           'datei schließen

PRI cmd_help | i,char,n                                 'cmd: textdatei ausgeben

  ios.print(string("help: man regime"))

{
  n := i := 1
  repeat until (char := byte[@help1][i++]) == 0         'text ausgeben
    ios.printchar(char)
    if char == ios#CHAR_NL                              'zeilenzahl zählen und stop
        if ++n == (rows - 2)
          n := 1
          if ios.keywait == "q"
            return
}

PRI cmd_dir|fcnt,stradr,hflag                           'cmd: verzeichnis anzeigen
{{sddir - anzeige verzeichnis}}

  if ios.sdcheckmounted                                 'test ob medium gemounted ist

    hflag := 1
    stradr := os_nxtoken1                               'parameter einlesen
    ios.print(@msg10)                                   
    ios.print(@msg5)
    ios.print(ios.sdvolname)
    ifnot ios.os_error(ios.sddir)                       'verzeichnis öffnen
      if str.findCharacter(stradr,"h")
        hflag := 0
      if str.findCharacter(stradr,"w")
        fcnt := cmd_dir_w(hflag)
      else
        fcnt := cmd_dir_l(hflag)                        'dir l
      ios.printnl
      ios.print(@msg10)
      ios.print(@msg9)
      ios.printdec(fcnt)
  else
    ios.os_error(1)

PRI cmd_dir_w(hflag):fcnt|stradr,lcnt,wcnt

    fcnt := 0
    wcnt := (cols / 14) - 1 '3
    lcnt := (rows - 2) * (cols / 15)
    ios.printnl
    repeat while (stradr := ios.sdnext)
       ifnot ios.sdfattrib(ios#F_HIDDEN) & hflag                                'versteckte dateien anzeigen?
         if ios.sdfattrib(ios#F_DIR)                                            'verzeichnisname
           ios.setcolor(1)
           ios.printqchar("▶")
           ios.printchar(" ")
           ios.print(stradr)
           ios.setcolor(0)
         elseif ios.sdfattrib(ios#F_HIDDEN)
           ios.setcolor(3)
           ios.print(string("  "))
           str.charactersToLowerCase(stradr)
           ios.print(stradr)
           ios.setcolor(0)
         else                                                                   'dateiname
           ios.print(string("  "))
           str.charactersToLowerCase(stradr)
           ios.print(stradr)
         ifnot wcnt--                                                           
           wcnt := (cols / 15) - 1 '3
           ios.printnl
         else
           'ios.printtab
         fcnt++
         ifnot --lcnt
           lcnt := (rows - 2) * (cols / 15)
           if ios.keywait == "q"
             return

PRI cmd_dir_l(hflag):fcnt|stradr,lcnt

  fcnt := 0
  lcnt := rows - 2
  repeat while (stradr := ios.sdnext)
    ifnot ios.sdfattrib(ios#F_HIDDEN) & hflag                                   'versteckte dateien anzeigen?
       ios.printnl
       if ios.sdfattrib(ios#F_DIR)                                              'verzeichnisname
         ios.setcolor(1)
           ios.printqchar("▶")
           ios.printchar(" ")
         ios.print(stradr)
         ios.setcolor(0)
       elseif ios.sdfattrib(ios#F_HIDDEN)
         ios.setcolor(3)
         ios.print(string("  "))
         str.charactersToLowerCase(stradr)
         ios.print(stradr)
         ios.setcolor(0)
       else                                                                     'dateiname
         ios.print(string("  "))
         str.charactersToLowerCase(stradr)
         ios.print(stradr)
       
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_SIZE),10))             'dateigröße

       ios.printchar(" ")                                                       'attribute
       if ios.sdfattrib(ios#F_READONLY)
          ios.printchar("r")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_HIDDEN)
          ios.printchar("h")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_SYSTEM)
          ios.printchar("s")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_ARCHIV)
          ios.printchar("a")
       else
          ios.printchar("-")

       if vidmod == TV
         ios.printnl
         --lcnt

       ios.printchar(" ")                                                       'änderungsdatum
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CDAY),2))
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMONTH),2) + 1)
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CYEAR),4) + 1)
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CHOUR),2))
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMIN),2) + 1)
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CSEC),2) + 1)
       fcnt++
       --lcnt
       if lcnt < 1
         lcnt := rows - 2
         if ios.keywait == "q"
           return

PRI cmd_cogs | i,l                                      'cmd: belegung der cogs anzeigen

  ios.print(@cogs4)
  ios.printnl  

  i := ios.reggetcogs                                   'regnatix
  cmd_cogs_print(8-i,i,@cogs1)

  i := ios.admgetcogs                                   'administra
  cmd_cogs_print(8-i,i,@cogs2)

  i := ios.belgetcogs                                   'bellatrix
  cmd_cogs_print(8-i,i,@cogs3)

  ios.setcolor(act_color)
  ios.print(@cogs4)
  ios.printnl
  ios.print(string(" ("))
  ios.setcolor(ios#RED)
  ios.print(string("•"))
  ios.setcolor(act_color)
  ios.print(@cogs5)
  ios.printnl

PRI cmd_cogs_print(used,free,stradr)
  
  ios.print(stradr)
  if used > 0
    repeat
        ios.setcolor(ios#RED)
        ios.print(string("•"))
        used--
    until used == 0
  if free > 0
    repeat
        ios.setcolor(ios#GREEN)
        ios.print(string("•"))
        free--
    until free == 0
  ios.setcolor(act_color)
  ios.printnl
        
DAT                                                     'strings
system1       byte  "▶Hive: Regime", 0
syst          byte  "TriOS • 07-04-2013",0
prog          byte  "Regime",0
copy          byte  "drohne235 • 06-04-2012",0
prompt1       byte  " ok ", $0d, 0
prompt2       byte  "~ ", 0
prompt3       byte  "∞ ", 0
msg1          byte  "Datei nicht gefunden!",0
msg2          byte  "Datei löschen? <j/*> : ",0
msg3          byte  " ? ",0
msg4          byte  "Volume      : ",0
msg5          byte  "Datenträger : ",0
msg6          byte  "Frei        : ",0
msg7          byte  "Belegt      : ",0
msg8          byte  "Gesamt      : ",0
msg9          byte  "Anzahl der Dateien : ",0
msg10         byte  "• ",0
msg11         byte  " KB",0
msg12         byte  "SD-Card formatieren? <j/*> : ",0
msg13         byte  "Hive neu starten? <[c]old/[w]arm/*> : ",0
msg14         byte  "CLI       : ",0
msg15         byte  "Regnatix   Version       : ",0
msg16         byte  "Regnatix   Spezifikation : ",0
msg17         byte  "Administra Version       : ",0
msg18         byte  "Administra Spezifikation : ",0
msg19         byte  "Bellatrix  Version       : ",0
msg20         byte  "Bellatrix  Spezifikation : ",0
msg21         byte  "Medium    : ",0
msg22         byte  "OS        : ",0
msg23         byte  "Copyright : ",0
msg24         byte  "[S]ystem    : ",0
msg25         byte  "[R]oot      : ",0
msg26         byte  "[U]ser      : ",0
msg27         byte  "Marker [A]  : ",0
msg28         byte  "Marker [B]  : ",0
msg29         byte  "Marker [C]  : ",0
msg30         byte  "gesetzt",13,0
msg31         byte  "frei",13,0
msg32         byte  "Bellatrix  Textspalten   :",0
msg33         byte  "Bellatrix  Textzeilen    :",0
msg34         byte  "Bellatrix  Auflösung X   :",0
msg35         byte  "Bellatrix  Auflösung Y   :",0
msg36         byte  "Bellatrix  Videomodus    : ",0
msg37         byte  "VGA",0
msg38         byte  "TV",0

ext1          byte  ".BIN",0
ext2          byte  ".ADM",0
ext3          byte  ".BEL",0
wait1         byte  "<WEITER? */q:>",0

cstr          byte    "••••••••",0
cogs1         byte  "Regnatix  : ",0
cogs2         byte  "Administra: ",0
cogs3         byte  "Bellatrix : ",0
cogs4         byte  "────────────────────",0
cogs5         byte   " = running cog)",0

gdriver       byte  "bel.sys", 0                         'name des grafiktreibers

{
help1         file  "regime.txt"
              byte  13,0
}
DAT                                                     'systemfehler
err_s1  byte "Fehlernummer : ",0
err_s2  byte "Fehler       : ",0
{
err0    byte "no error",0
err1    byte "fsys unmounted",0
err2    byte "fsys corrupted",0
err3    byte "fsys unsupported",0
err4    byte "not found",0
err5    byte "file not found",0
err6    byte "dir not found",0
err7    byte "file read only",0
err8    byte "end of file",0
err9    byte "end of directory",0
err10   byte "end of root",0
err11   byte "dir is full",0
err12   byte "dir is not empty",0
err13   byte "checksum error",0
err14   byte "reboot error",0
err15   byte "bpb corrupt",0
err16   byte "fsi corrupt",0
err17   byte "dir already exist",0
err18   byte "file already exist",0
err19   byte "out of disk free space",0
err20   byte "disk io error",0
err21   byte "command not found",0
err22   byte "timeout",0
errx    byte "undefined",0
}
DAT                                                     'lizenz
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
              
