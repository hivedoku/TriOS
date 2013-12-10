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
Name            : splay
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : sid-player für kommandozeile
Komponenten     : -
COG's           : -
Logbuch         :

19-04-2010-dr235  - sid-time: start des projektes :)

Kommandoliste   :

/?          : Hilfetext
/m name.dmp : DMP-Datei mono auf SID2 abspielen
/s name.dmp : DMP-Datei stereo auf SID2 abspielen
/d          : Alle DMP-Dateien im Verzeichnis wiedergeben
                q - quit
                n - next
                p - pause

Notizen         :

}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE        = XTAL1 + PLL16X
_XINFREQ        = 5_000_000

SIDMASK         = %00000000_00000000_00000000_00010000


VAR

  byte  fl_bye                  'flag player beenden
  byte  parastr[64]             'parameterstring
  byte  fn[12]                  'puffer für dateinamen
  long  datcnt                  'zeiger für dateiliste
  

DAT 'PARAMETER

PUB main

  ios.start                                             'ios initialisieren
  ios.parastart                                         'parameterübergabe starten
  if (ios.admgetspec & SIDMASK)
    repeat while ios.paranext(@parastr)                   'parameter einlesen
      if byte[@parastr][0] == "/"                         'option?
        case byte[@parastr][1]
          "?": ios.print(string("help: man splay"))       '/?
          "m": playm_dmp                                  '/p
          "s": plays_dmp                                  '/s
          "d": play_dir                                   '/d
  else
    printErr(@err2)
  ios.stop

DAT 'PLAY_DIR

PUB play_dir|stradr,len,fcnt,i                          'hss: alle songs auf der sd-card abspielen

  ios.sddir                                             'kommando: verzeichnis öffnen
  datcnt := 0                                           'zum listenanfang
  fcnt := 0                                             'zähler für dateianzahl
  fl_bye := 0
  repeat while (stradr := ios.sdnext)                   'dateiliste einlesen
    if str_find(stradr,@ext1)
        fcnt++
        play_dir_wrlst(stradr)
  ios.print(string("Anzahl Dateien : "))
  ios.printdec(fcnt)
  ios.printnl
  datcnt := 0                                           'zum listenanfang
  repeat i from 0 to fcnt-1                             'dateiliste abspielen
    ios.printdec(i+1)
    ios.printchar("/")
    ios.printdec(fcnt)
    ios.printtab
    play_dir_rdlst(@fn)
    play_dir_file(@fn)
    if fl_bye                                           'player beenden
      quit
  ios.printnl

PRI play_dir_file(stradr)|err

    ios.print(stradr)
    ios.printchar(" ")
    if err := ios.sid_sdmpplay(stradr)                      'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_status                                       'warten, solange wav gespielt wird (sd belegt)
    ios.printnl

PUB play_dir_wrlst(stradr)|len,i                        'kopiert dateinamen in liste
  len := strsize(stradr)
  repeat i from 0 to len-1
    ios.ram_wrbyte(ios#usrmod,byte[stradr][i],datcnt++)
  ios.ram_wrbyte(ios#usrmod,0,datcnt++)

PUB play_dir_rdlst(stradr)|i,n                          'liest dateinamen aus list
  i := 0
  repeat
    n := ios.ram_rdbyte(ios#usrmod,datcnt++)
    byte[stradr][i++] := n
  while n <> 0

DAT 'PLAY_DMP

PRI playm_dmp|err                                       'dmp-datei mono auf einem sid abspielen

  if ios.paranext(@parastr)                             'parameter?
    if err := ios.sid_mdmpplay(@parastr)                'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_status                                       'warten, solange wav gespielt wird (sd belegt)
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PRI plays_dmp|err                                       'dmp-datei quasi-stereo auf zwei sidcogs abspielen

  if ios.paranext(@parastr)                             'parameter?
    if err := ios.sid_sdmpplay(@parastr)                'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_status                                       'warten, solange wav gespielt wird (sd belegt)
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PUB play_status|status,curpos,key,l,p                   'warten bis player fertig, oder abbruch

  ios.print(string(" <q/n/p> : "))
  ios.curoff
  curpos := ios.curgetx
  repeat
     status := ios.sid_dmpstatus
     ios.cursetx(curpos)
     ios.printdec(ios.sid_dmplen)
     ios.printchar("/")
     ios.printdec(ios.sid_dmppos)
     if key := ios.key                                  'bei taste stopsignal an player senden
       case key
         "n": ios.sid_dmpstop                              'next wav
         "p": ios.sid_dmppause                             'pause
         "q": fl_bye := 1
              ios.sid_dmpstop
  while status                                          'schleife solange player aktiv
  ios.sid_mute(3)
  ios.curon

DAT 'TOOLS

PRI printErr(stradr)

  ios.print(@err0)
  ios.print(stradr)
  ios.print(string("help: man splay"))

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

PUB str2dec(stradr)|buffer,counter

  buffer := byte[stradr]
  counter := (strsize(stradr) <# 11)
  repeat while(counter--)
    result *= 10
    result += lookdownz(byte[stradr++]: "0".."9")
  if(buffer == "-")
    -result   

DAT

ext1          byte  ".DMP",0

err0          byte  13,"Fehler : ",0
err1          byte  "Zu wenig Parameter!",13,0
err2          byte  "Administra-Code unterstützt keine SID-Emulation!",13,0


DAT
     
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
