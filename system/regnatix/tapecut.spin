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
Name            : tapecut - erzeugt leere tapedateien
Chip            : Regnatix
Typ             : Programm
Version         :
Subversion      :
Funktion        :
Komponenten     : -
COG's           : -
Logbuch         :
Kommandoliste   :
Notizen         :


Notizen:
- parameter     c               - create, erzeugt neue tape-datei
                a               - append, hängt screens an
                n               - screens nummerieren
                

 --------------------------------------------------------------------------------------------------------- }}

OBJ
        ios: "reg-ios"
        num: "glob-numbers"
        gc : "m-glob-con"


CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

SCREENSIZE   = 1024

VAR

byte    parastr1[32]            'dateiname
byte    parastr2[32]            'größe
long    screens                 'anzahl der screens

PUB main2 | i,n

  ios.start
  ios.parastart
  parastr1[0] := 0
  parastr2[0] := 0
  ios.printnl
  ifnot rd_parameter                                    'parameter einlesen
    ios.print(@msg1)
    if ios.keywait <> "j"                               'abbruch?
       ios.print(string("nein"))
       ios.printnl
    else                                                'container erzeugen
       ios.print(string("ja"))
       ios.printnl
       create
  ios.stop

PRI rd_parameter
  if ios.paranext(@parastr1)                            'parameter dateiname einlesen
    ios.print(@msg5)
    ios.print(@parastr1)
    ios.printnl
    if ios.paranext(@parastr2)                          'parameter screenzahl einlesen
       screens := num.FromStr(@parastr2,num#DEC)
       ios.print(@msg8)
       ios.printdec(screens)
       ios.printnl
       ios.print(@msg4)
       ios.printnl
       ios.print(@msg6)
       ios.printdec(screens * SCREENSIZE)
       ios.print(@msg7)
    else
      ios.print(@err2)
      ios.print(@msg3)
      return -1

  else 
    ios.print(@err1)
    ios.print(@msg3)
    return -1
  return

PRI create | i,status,curpos,numstr,len                 'erzeugt containerdatei

  status := ios.sdopen("R",@parastr1)                   'test ob datei vorhanden
  ios.sdclose                                           'datei gleich wieder schlie?en
  if status == 0                                        'datei ist schon vorhanden
    ios.print(@msg12)
    if ios.keywait <> "j"
       ios.print(string("nein"))                        'nicht ?berschreiben
       ios.printnl
       return
  ios.printnl                                           
  ios.print(@msg10)
  ios.sdnewfile(@parastr1)
  ios.sdopen("W",@parastr1)                             'datei erzeugen
  ios.print(@msg11)
  ios.print(@msg13)
  curpos := ios.curgetx                                 'cursorposition x merken
  repeat i from 1 to screens                            'screens schreiben
    numstr := num.ToStr(i-1,num#dec)
    len := strsize(numstr)
    fprint(string(gc#m_c_remark,"screen nr : "))
    fprint(numstr)                                      'screennummer in erste zeile
    repeat SCREENSIZE - len - 13                        'screen auffüllen
      ios.sdputc(gc#m_c_remark)
    ios.cursetx(curpos)                                 'position setzen
    ios.printdec(i)
  ios.sdclose
  ios.print(@msg11)

PUB fprint(stringptr)                                     'dateiausgabe einer zeichenkette (0-terminiert)
  repeat strsize(stringptr)
    ios.sdputc(byte[stringptr++])


DAT

msg1          byte  13,"Parameter korrekt? <j/n> : ", 0
msg2          byte  " : ", 0
msg3          byte  "Format          : tapecut <datei> <screens>",13,0
msg4          byte  "Screengröße     : 1024 Byte",0
msg5          byte  "Containerdatei  : ",0
msg6          byte  "Größe           : ",0
msg7          byte  " Bytes ",13,0
msg8          byte  "Screens         : ",0
msg10         byte  "Datei wird geöffnet... ",0
msg11         byte  " ok ",13,0
msg12         byte  13,"Vorhandene Datei überschreiben? <j/n> : ", 0
msg13         byte  "Schreibe Screen : ",0

err1          byte  "Fehler          : Keine Parameter.",13,0
err2          byte  "Fehler          : Keine Größe definiert.",13,0


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
