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
Name            : wplay
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : wav-player für kommandozeile
Komponenten     : -
COG's           : -
Logbuch         :

16-04-2010-dr235  - erste trios-version
21-04-2010-dr235  - pausenmodus & anzeige wav-position
29-04-2010-dr235  - /i eingefügt, da offensichtlich einige konwerter den len-parameter im header falsch setzen!

Kommandoliste   :

/?          : Hilfetext
/p name.wav : WAV-Datei abspielen
/d          : Verzeichnis wiedergeben
            : q - quit
            : n - next
            : p - pause
/l 0..100   : Lautstärke links
/r 0..100   : Lautstärke rechts
/i name.wav : Info zur Datei anzeigen


Notizen         :

}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

  byte  fl_bye                  'flag player beenden
  byte  parastr[64]             'parameterstring
  byte  fn[12]                  'puffer für dateinamen
  long  datcnt                  'zeiger für dateiliste
  

DAT 'PARAMETER

PUB main

  ios.start                                             'ios initialisieren
  ios.parastart                                         'parameterübergabe starten
  ios.admsetsound(ios#SND_HSSOFF)                       'hss ausschalten
  ios.admsetsound(ios#SND_WAVON)                        'wav einschalten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(string("help: man wplay"))       '/?
        "p": play_wav                                   '/p
        "d": play_dir                                   '/r
        "l": set_lvol                                   '/l
        "r": set_rvol                                   '/r
        "i": print_info
  ios.admsetsound(ios#SND_WAVOFF)                       'wav ausschalten
  ios.admsetsound(ios#SND_HSSON)                        'hss anschalten
  ios.stop

DAT 'VOLUME

PUB set_lvol

  if ios.paranext(@parastr)                             'parameter?
    ios.wav_lvol(str2dec(@parastr))
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PUB set_rvol

  if ios.paranext(@parastr)                             'parameter?
    ios.wav_rvol(str2dec(@parastr))
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PUB print_info|err

  if ios.paranext(@parastr)                             'parameter?
    if err := ios.sdopen("R",@parastr)                  'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      ios.sdseek(22)
      ios.print(string(13,"Anzahl der Kanäle : "))
      ios.printdec(ios.sdgetc | (ios.sdgetc << 8))
      ios.sdseek(34)
      ios.print(string(13,"Bits per Sample   : "))
      ios.printdec(ios.sdgetc | (ios.sdgetc << 8))
      ios.sdseek(40)
      ios.print(string(13,"Länge             : "))
      ios.printdec(ios.sdgetc | (ios.sdgetc << 8) | (ios.sdgetc << 16) | (ios.sdgetc << 24))
      ios.printnl
      ios.sdclose
      
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)


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
    if err := ios.wav_play(stradr)                      'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_wav_status                                   'warten, solange wav gespielt wird (sd belegt)
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

DAT 'PLAY_WAV

PRI play_wav|err                                        'wav abspielen

  if ios.paranext(@parastr)                             'parameter?
    if err := ios.wav_play(@parastr)                    'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_wav_status                                   'warten, solange wav gespielt wird (sd belegt)
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PUB play_wav_status|status,curpos,key,l,p               'warten bis player fertig, oder abbruch

  ios.print(string(" <q/n/p> : "))
  ios.curoff
  curpos := ios.curgetx
  repeat
     status := ios.wav_status
     ios.cursetx(curpos)
     ios.printdec(ios.wav_len)
     ios.printchar("/")
     ios.printdec(ios.wav_pos)
     ios.print(string("     "))
     if key := ios.key                                  'bei taste stopsignal an player senden
       case key
         "n": ios.wav_stop                              'next wav
         "p": ios.wav_pause                             'pause
         "q": fl_bye := 1
              ios.wav_stop
  while status                                          'schleife solange player aktiv
  ios.curon 

DAT 'TOOLS

PRI printErr(stradr)

  ios.print(@err0)
  ios.print(stradr)
  ios.print(string("help: man wplay"))

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

ext1          byte  ".WAV",0

err0          byte  13,"Fehler : ",0
err1          byte  "Zu wenig Parameter!",13,0

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
