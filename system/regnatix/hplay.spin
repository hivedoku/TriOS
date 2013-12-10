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
Name            : HSS-Player
Chip            : Regnatix
Typ             : Programm
Version         : 00
Subversion      : 02

Funktion        : HSS-Player für die Kommandozeile

Logbuch         :

08-04-2010-dr235  - fork aus regime
                  - anpassung an trios
16-04-2010-dr235  - umwandlung in reine kommandozeilenanwendung

Kommandoliste   :

/?             : hilfetext
/p name.wav    : hss-datei abspielen
/d             : verzeichnis abspielen
/s             : wiedergabe stoppen
/t             : anzeige trackerliste
/r             : anzeige engine-register
/i             : anzeige interface-register


}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OS_TIBLEN       = 64                                    'größe des inputbuffers
ERAM            = 1024 * 512 * 2                        'größe eram
HRAM            = 1024 * 32                             'größe hram

RMON_ZEILEN     = 16                                    'speichermonitor - angezeigte zeilen
RMON_BYTES      = 8                                     'speichermonitor - zeichen pro byte

VAR

  long  datcnt                  'zeiger für dateiliste
  byte  fn[12]                  'puffer für dateinamen
  byte  parastr[64]             'parameterstring
  byte  fl_bye
  byte  fl_next

DAT 'PARAMETER

PUB main

  ios.start                                             'ios initialisieren
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(string("help: man hplay"))       '/? - hilfetext
        "p": play_hss                                   '/p - hss-datei wiedergeben
        "d": play_dir                                   '/d - verzeichnis wiedergeben
        "t": disp_tracker                               '/t - anzeige tracker
        "r": disp_reg                                   '/r - anzeige register
        "i": disp_ireg                                  '/i - anzeige interfaceregister
        "s": ios.hss_stop                               '/s - wiedergabe stoppen
  ios.stop


DAT 'PLAY_FILE
    
PUB play_hss                                            'hss: player starten

  if ios.paranext(@parastr)                             'parameter?
    ios.hss_playfile(@parastr)
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

DAT 'PLAY_DIR
    
PUB play_dir | stradr,len,fcnt,i                        'hss: alle songs auf der sd-card abspielen

  ios.sddir                                             'kommando: verzeichnis öffnen
  hss_startlist                                         'zum listenanfang
  fcnt := 0                                             'zähler für dateianzahl
  fl_bye := fl_next := 0
  repeat while (stradr := ios.sdnext)                   'dateiliste einlesen
'   ios.print(stradr)
    if str_find(stradr,@ext1)
'       ios.printchar("◀")
        fcnt++ 
        hss_wrfn(stradr)
'   ios.printnl
  ios.print(string("Anzahl Dateien : "))
  ios.printdec(fcnt)
  ios.printnl
  hss_startlist                                         'zum listenanfang
  if fcnt
    repeat i from 0 to fcnt-1                           'dateiliste abspielen
      ios.printdec(i+1)
      ios.printchar("/")
      ios.printdec(fcnt)
      ios.printchar(" ")
      hss_rdfn(@fn)
      hss_playsong(@fn)
      if fl_bye
        quit
      if fl_next
        fl_next := 0
      else
        hss_fadeout
    ios.hss_stop

PUB hss_playsong(stradr) | n,q,key                      'hss: spielt die musikdatei bis zum ende

  ios.curoff
  ios.print(string("PlaySong <q/n> : "))
  ios.print(stradr)
  ios.printnl
  ios.hss_stop
  ios.hss_playfile(stradr)
  repeat
    n := ios.hss_intreg(ios#iRepeat)                    'anzahl der schleifendurchläufe abfragen
    q := ios.hss_intreg(ios#iEndFlag)
    ios.curpos1
    ios.print(string("iRepeat : "))
    ios.printdec(n)
    ios.print(string(" iEndFlag : "))
    ios.printdec(q)
    if key := ios.key
      case key
        "n": fl_next := 1
             quit
        "q": fl_bye := 1
             quit
  until n == 3 or q == 1
  ios.printnl
  ios.curon

PUB hss_fadeout | i                                     'hss: song langsam ausblenden
  repeat i from 0 to 15
    ios.hss_vol(15 - i)
    waitcnt(cnt + 60_000_000)
  waitcnt(cnt + 30_000_000)
  
PUB hss_wrfn(stradr) | len,i                            'hss: kopiert dateinamen in eram
  len := strsize(stradr)
  repeat i from 0 to len-1
    ios.ram_wrbyte(ios#usrmod,byte[stradr][i],datcnt++)
  ios.ram_wrbyte(ios#usrmod,0,datcnt++)

  
PUB hss_rdfn(stradr) | i,n                              'hss: liest dateinamen aus eram
  i := 0
  repeat
    n := ios.ram_rdbyte(ios#usrmod,datcnt++)
    byte[stradr][i++] := n
  while n <> 0

PUB hss_startlist                                       'hss: zeiger auf listenanfang (dateinamen)
  datcnt := 0
  

DAT 'DISPLAY

PUB disp_tracker | i,n                                  'disp: trackerliste ausgeben
  repeat
    repeat
    until ios.hss_intreg(ios#iRowFlag) == 0
    repeat
    until ios.hss_intreg(ios#iRowFlag) == 1             'synchronisation bis zeile fertig bearbeitet

    ios.printhex(ios.hss_intreg(ios#iBeatC),4)
    ios.printchar("-")
    ios.printhex(ios.hss_intreg(ios#iEngineC),4)
    ios.printchar(":")
    ios.printchar(" ")

    repeat i from 1 to 4

      hss_printnote(ios.hss_intreg(i*5+ios#iNote))      'note

      n := ios.hss_intreg(i*5+ios#iOktave)
      if n
        ios.printhex(n,1)                               'oktave
      else
        ios.printchar("-")
      ios.printchar(" ")
      
      n := ios.hss_intreg(i*5+ios#iVolume)
      if n
        ios.printhex(n,1)                               'volume
      else
        ios.printchar("-")
      ios.printchar(" ")
      
      n := ios.hss_intreg(i*5+ios#iEffekt)
      if n
        ios.printhex(n,1)                               'effekt
      else
        ios.printchar("-")
      ios.printchar(" ")

      n := ios.hss_intreg(i*5+ios#iInstrument)
      if n
        ios.printhex(n,1)                               'instrument
      else
        ios.printchar("-")
      ios.printchar(" ")


    ios.printnl
      
  until ios.keystat > 0                                  'taste gedrückt?
  ios.key
  ios.curon
  ios.printnl

PUB hss_printnote(n)                                    'disp: notenwert ausgeben
'C1,C#1,D1,D#1,E1,F1,F#1,G1,G#1,A1,A#1,H1

  case n
    0:  ios.print(string("  "))
    1:  ios.print(string("C "))
    2:  ios.print(string("C#"))
    3:  ios.print(string("D "))
    4:  ios.print(string("D#"))
    5:  ios.print(string("E "))
    6:  ios.print(string("F "))
    7:  ios.print(string("F#"))
    8:  ios.print(string("G "))
    9:  ios.print(string("G#"))
    10: ios.print(string("A "))
    11: ios.print(string("A#"))
    12: ios.print(string("H "))
    


PUB disp_ireg | i,j,n,wert                              'disp: anzeige interfaceregister
  ios.printcls
  repeat
    ios.curhome
    ios.curoff
    ios.printnl
    repeat i from 0 to 4
      ios.printhex(i*8,2)
      ios.printchar(":")
      repeat j from 0 to 4
        n := (i*5)+j
        wert := ios.hss_intreg(n)
        ios.printhex(wert,4)
        ios.printchar(" ")
      ios.printnl
  until ios.keystat > 0                                  'taste gedrückt?
  ios.key
  ios.curon
  ios.printnl

PUB disp_reg | wert,i,j,n                               'disp: kontinuierliche anzeige der regsiterwerte
{{
 8 x 6 register long

 0      kanal a
 3>>16  f
 4      v

 8      kanal b
 16     kanal c
 24     kanal d
 
}}
  ios.printcls
  repeat
    ios.curhome
    ios.curoff
    repeat j from 0 to 3
      ios.printnl
      ios.printnl
      ios.printhex(j*8,2)
      ios.printchar(":")
      repeat i from 0 to 3
        n := (j*8)+i
        wert := ios.hss_peek(n)
        ios.printhex(wert,8)
        ios.printchar(" ")
      ios.printnl
      ios.printhex(j*8+4,2)
      ios.printchar(":")
      repeat i from 4 to 7
        n := (j*8)+i
        wert := ios.hss_peek(n)
        ios.printhex(wert,8)
        ios.printchar(" ")

    ios.printnl
    ios.printnl
    ios.print(string("Channel A F: "))
    wert := ios.hss_peek(0+3)
    ios.printhex(wert>>16,4)
    ios.print(string(" V: "))
    wert := ios.hss_peek(0+4)
    ios.printhex(wert,2)

    ios.printnl
    ios.print(string("Channel B F: "))
    wert := ios.hss_peek(8+3)
    ios.printhex(wert>>16,4)
    ios.print(string(" V: "))
    wert := ios.hss_peek(8+4)
    ios.printhex(wert,2)

    ios.printnl
    ios.print(string("Channel C F: "))
    wert := ios.hss_peek(16+3)
    ios.printhex(wert>>16,4)
    ios.print(string(" V: "))
    wert := ios.hss_peek(16+4)
    ios.printhex(wert,2)

    ios.printnl
    ios.print(string("Channel D F: "))
    wert := ios.hss_peek(24+3)
    ios.printhex(wert>>16,4)
    ios.print(string(" V: "))
    wert := ios.hss_peek(24+4)
    ios.printhex(wert,2)
 
  until ios.keystat > 0                                  'taste gedrückt?
  ios.key
  ios.curon
  ios.printnl
  
DAT 'TOOLS

PRI printErr(stradr)

  ios.print(@err0)
  ios.print(stradr)
  ios.print(string("help: man hplay"))

PUB str_find(string1, string2) : buffer | counter       'sys: string suchen

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Searches a string of characters for the first occurence of the specified string of characters.                           │
'' │                                                                                                                          │
'' │ Returns the address of that string of characters if found and zero if not found.                                         │
'' │                                                                                                                          │
'' │ string1 - A pointer to the string of characters to search.                                                               │                                                           
'' │ string2            - A pointer to the string of characters to find in the string of characters to search.                │                                                                           
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat strsize(string1--)

    if(byte[++string1] == byte[string2])

      repeat counter from 0 to (strsize(string2) - 1)

        if(byte[string1][counter] <> byte[string2][counter])
          buffer~~

      ifnot(buffer~)
        return string1

PUB str_lower(characters) '' 4 Stack Longs              'sys: in kleine zeichen wandeln

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Demotes all upper case characters in the set of ("A","Z") to their lower case equivalents.                               │
'' │                                                                                                                          │
'' │ Characters - A pointer to a string of characters to convert to lowercase.                                                │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat strsize(characters--)

    result := byte[++characters]

    if((result => "A") and (result =< "Z"))
    
      byte[characters] := (result + 32)

        
DAT                                                     'strings

ext1          byte  ".HSS",0

err0          byte  13,"Fehler : ",0
err1          byte  "Zu wenig Parameter!",13,0

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
              
