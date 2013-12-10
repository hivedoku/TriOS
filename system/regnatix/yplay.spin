{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Volker Pohlers
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : 
System          : TriOS
Name            : yplay
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : ay-ym-player für kommandozeile
Komponenten     : -
COG's           : -
Logbuch         :

17-08-2010-dr040  - start des projektes :)
22.08.2010-dr040  - Timing geändert     

Notizen         : based on splay.bin by Ingo Kripahle
                  ,YM6player.spin by Juergen Buchmueller

}}

OBJ
  ios   : "reg-ios"
  gc    : "glob-con"       'globale konstanten

CON

_CLKMODE        = XTAL1 + PLL16X
_XINFREQ        = 5_000_000


VAR

  byte  fl_bye                  'flag player beenden
  byte  parastr[64]             'parameterstring
  byte  fn[12]                  'puffer für dateinamen
  long  datcnt                  'zeiger für dateiliste

VAR
  byte  buffer[128]
  long  nvbl
  long  attr
  long  ndrums
  long  clock
  long  rate
  long  loop
  long  extra
  long  bytes
  long  fileNumber
  long  nextsong
  long  wait
 

DAT 'PARAMETER

PUB main

  ios.start                                             'ios initialisieren

{  ios.startram                                          'ios initialisieren (f. Start aus Propeller Tool heraus)
  ios.admload(@admsys)
  ios.bus_putchar1(200)             ' ay_start
  play_dir
}

  ios.parastart                                         'parameterübergabe starten
  if (ios.admgetspec & gc#A_AYS)
    ios.bus_putchar1(200)             ' ay_start

    repeat while ios.paranext(@parastr)                   'parameter einlesen
      if byte[@parastr][0] == "/"                         'option?
        case byte[@parastr][1]
          "?": ios.print(string("help: man yplay"))       '/?
          "p": play_file                                  '/p
          "d": play_dir                                   '/d
  else
    printErr(@err2)

  ios.bus_putchar1(201)             ' ay_stop
  ios.stop

DAT 'PLAY_DIR

PUB play_dir|stradr,len,fcnt,i                          'alle songs auf der sd-card abspielen

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

PRI play_file|err                                       'datei abspielen

  if ios.paranext(@parastr)                             'parameter?
    play_dir_file(@parastr)
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)


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

PRI play_dir_file(stradr)|err, k,curpos,key,vblframe,timecnt

    ios.print(stradr)
    ios.printchar(" ")
    ios.printnl
    
    openFile(stradr)
{    if err := ios.sid_sdmpplay(stradr)                  'fehler bei start des players?
      ios.print(@err0)                                  'fehlernummer ausgeben
      ios.printdec(err)
    else
      play_status                                       'warten, solange wav gespielt wird (sd belegt)
}

  ios.print(string("Status <n/q> : "))
  ios.curoff
  curpos := ios.curgetx

  timecnt := cnt

  repeat
    timecnt += clkFreq / rate 
    ios.sdeof             ' eof?
    ifnot ios.bus_getchar1  

      ios.sdgetblk(16, @buffer)

      ios.bus_putchar1(202)         ' ay_updateRegisters
      repeat k from 0 to 13
        ios.bus_putchar1(buffer[k])

      waitcnt(timecnt)

    else
      quit

    ios.cursetx(curpos)
    ios.printdec(++vblframe)
    ios.printchar("/")
    ios.printdec(nvbl)
    if key := ios.key                                  'bei taste stopsignal an player senden
      case key
        "n": quit
        "q": fl_bye := 1
             quit

  ios.curon
  ios.sdclose
  ios.printnl

DAT 'PLAY_AY


PRI get_word | buff
  ios.sdgetblk(2, @buff)
  return byte[@buff][0] << 8 + byte[@buff][1]

PRI get_dword | buff
  ios.sdgetblk(4, @buff)
  return byte[@buff][0] << 24 + byte[@buff][1] << 16 + byte[@buff][2] << 8 + byte[@buff][3]

PRI get_string | n
  repeat n from 0 to 127
    if (buffer[n] := ios.sdgetc) =< 0
      buffer[n] := 0
      return

      
PUB openFile(filename) | i, j, m

  ios.sdopen( "R", filename )
  
  ios.sdgetblk(4, @buffer)         ' 00 - read "YM6!" header
  ios.sdgetblk(8, @buffer)         ' 04 - read "LeOnArD!" identifier
  nvbl := get_dword            ' 0c - number of VBL frames
'  ios.print(string("VBL frames : "))
'  ios.printdec(nvbl)
'  ios.printnl
  attr := get_dword            ' 10 - attributes
'  ios.print(string("Attributes : "))
'  ios.printhex(attr,8)
'  ios.printnl
  ndrums := get_word           ' 14 - number of digi drum samples
'  ios.print(string("Digi-Drums : "))
'  ios.printdec(ndrums)
'  ios.printnl
  clock := get_dword           ' 16 - YM2149 external frequency in Hz
'  ios.print(string("Clock      : "))
'  ios.printdec(clock)
'  ios.printnl
  rate := get_word             ' 1a - player frequency in Hz
'  ios.print(string("Play rate  : "))
'  ios.printdec(rate)
'  ios.printnl
  loop := get_dword            ' 1c - frame where looping starts
'  ios.print(string("Loop       : "))
'  ios.printdec(loop)
'  ios.printnl
  extra := get_word            ' 20 - extra bytes following (should be 0)
'  ios.print(string("Extra      : "))
'  ios.printdec(extra)
'  ios.printnl

  ' skip over extra data
  repeat while extra > 0
    m := extra <# 128
    ios.sdgetblk(m, @buffer)
    extra -= m
  if ndrums > 0
    ' read digi drum samples
    repeat ndrums
      bytes := get_dword
      repeat while bytes > 0
        m := bytes <# 128
        ios.sdgetblk(m, @buffer)
        bytes -= m

  get_string                  ' read song name
  ios.print(string("Song name  : "))
  ios.print(@buffer)
  ios.printnl
  get_string                  ' read author name
  ios.print(string("Author     : "))
  ios.print(@buffer)
  ios.printnl
  get_string                  ' read comments / software
  ios.print(string("Comments   : "))
  ios.print(@buffer)
  ios.printnl

  
PUB play_status|status,curpos,key,l,p                   'warten bis player fertig, oder abbruch

  ios.print(string("Status <q/n/p> : "))
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
  ios.print(string("help: man yplay"))

PUB str_find(string1, string2) : buf | counter       'sys: string suchen

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
          buf~~

      ifnot(buf~)
        return string1

PUB str2dec(stradr)|buf,counter

  buf := byte[stradr]
  counter := (strsize(stradr) <# 11)
  repeat while(counter--)
    result *= 10
    result += lookdownz(byte[stradr++]: "0".."9")
  if(buf == "-")
    -result   

DAT

admsys        byte  "admym.adm",0

ext1          byte  ".YM",0

err0          byte  13,"Fehler : ",0
err1          byte  "Zu wenig Parameter!",13,0
err2          byte  "Administra-Code unterstützt keine AY/YM-Emulation!",13,0

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
