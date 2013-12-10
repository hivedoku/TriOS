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
Name            : flash
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : Flash-Tool
Komponenten     : -
COG's           : -
Logbuch         :

09-04-2011-dr235  - erste version

Kommandoliste   :

/?         : Hilfe
/fh <fn>   : Datei in HI-ROM flashen
/fl <fn>   : Datei in LO-ROM flashen
/dh        : Dump HI-ROM
/dl        : Dump LO-ROM
/vh <fn>   : Vergleich Datei <--> HI-ROM
/ch        : HI-ROM löschen
/cl        : LO-ROM löschen
/sh <fn>   : HI-ROM speichern
/sl <fn>   : LO-ROM speichern

Notizen         :


}}

OBJ
    ios         : "reg-ios"
    sdspi       : "glob-sdspi"
    num         : "glob-numbers"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

DCOL       = 8               'dump spaltenzahl
DROW       = 16              'dump zeilenzahl

PAGESIZE   = 32
BUFFERSIZE = DCOL * DROW
LO_EEPROM  = $0000           ' based upon 24LC512 (64KB)
HI_EEPROM  = $8000
IMAGESIZE  = $8000           'größe eines rom-images


VAR

byte      buffer[BUFFERSIZE]
byte      parastr[64]
byte      input[64]
long      ioControl[2]

PUB main

  ios.start                                             'ios initialisieren
  ios.parastart                                         'parameterübergabe starten
  sdspi.start(@iocontrol)                               'spi-treiber starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(string("help: man flash"))       '/?
        "f": case byte[@parastr][2]
               "h": flash(HI_EEPROM)                    '/fh - in oberen rom flashen
               "l": flash(LO_EEPROM)                    '/fl - in unteren rom flashen
        "d": case byte[@parastr][2]
               "h": dump(HI_EEPROM)                     '/dh - dump des oberen rom
               "l": dump(LO_EEPROM)                     '/dl - dump des unteren rom
        "v": case byte[@parastr][2]
               "h": verify(HI_EEPROM)                   '/vh - vergleih oberen rom
        "c": case byte[@parastr][2]
               "h": clear(HI_EEPROM)                    '/ch - oberen rom löschen
               "l": clear(LO_EEPROM)                    '/cl - unteren rom löschen
        "s": case byte[@parastr][2]
               "h": save(HI_EEPROM)                     '/sh - oberen rom speichern
               "l": save(LO_EEPROM)                     '/sl - unteren rom speichern
        "t": testsave(HI_EEPROM)

  sdspi.stop
'  ios.ram_wrbyte(ios#sysmod,0,ios#SIFLAG)
'  reboot
  ios.stop

PRI dump(eeAdr)|key,i,j,n                               'flash: azeige rom-inhalt

  eeAdr += sdspi#bootAddr     ' always use boot EEPROM

  repeat
    sdspi.readEEPROM(eeAdr,@buffer,BUFFERSIZE)
    i := j := 0

    repeat DROW                               'zeilen
      ios.printhex(eeAdr+j*DCOL,4)
      ios.printchar(" ")
      repeat DCOL                             'bytes
        n := byte[@buffer][i++]
        ios.printhex(n,2)
        ios.printchar(":")
      ios.printchar(" ")
      i := i - DCOL
      repeat DCOL                             'zeichen
        n := byte[@buffer][i++]
        ios.printqchar(n)
      ios.printnl
      j++

    ios.print(string("CMD? [b]ack[q]uit[a]dr[n]ext : "))
    key := ios.keywait
    case key
      "b": eeAdr := eeAdr - BUFFERSIZE
      "a": eeAdr := inputhex + sdspi#bootAddr
      "n": eeAdr := eeAdr + BUFFERSIZE
    ios.printnl
    ios.printnl
  until key == "q"

PRI flash(eeAdr)|i,len,pos,dif,pcnt                    'flash: datei flashen

  eeAdr += sdspi#bootAddr                               'deviceadresse hinzufügen

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(@msg0)
    ios.print(@msg1)
    ios.print(@parastr)
    ios.printnl
    ifnot ios.sdopen("R",@parastr)

      'programmlänge ermitteln
      repeat i from 0 to PAGESIZE - 1                   'erste page --> puffer
        byte[@buffer][i] := ios.sdgetc
      len := word[@buffer+$A]                           '$a ist stackposition und damit länge der objektdatei
      ios.sdclose

      'datei kpl. einlesen und flashen
      ios.print(@msg8)
      ios.printhex(eeAdr,8)
      ios.printnl
      ios.print(@msg4)
      ios.printdec(len)
      ios.printnl
      ios.print(@msg5)
      ios.printdec(len/PAGESIZE)
      ios.printnl
      ios.print(@msg2)
      pcnt := len / PAGESIZE / 10
      ios.curchar("▶")

      ios.sdopen("R",@parastr)
      repeat pos from 0 to len - 1 step PAGESIZE
        dif := (len - pos) <# PAGESIZE
        repeat i from 0 to dif - 1                       'page --> puffer
          byte[@buffer][i] := ios.sdgetc
        sdspi.writeEEPROM(eeAdr+pos,@buffer,dif)         'puffer --> eeprom
        sdspi.writeWait(eeAdr+pos)                       'warte auf ende des schreibvorgangs
        pcnt--
        if pcnt == 0
          ios.printchar("•")
          pcnt := len / PAGESIZE / 10

      ios.sdclose
      ios.curchar("‣")
      ios.print(@msg3)

    else
      printErr(@err2)
  else
   printErr(@err1)

PRI verify(eeAdr)|a,b,pos,len,i                        'flash: vergleichen

  eeAdr += sdspi#bootAddr                                'deviceadresse hinzufügen
  len := IMAGESIZE

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(@msg0)
    ios.print(@msg1)
    ios.print(@parastr)
    ios.printnl
    ifnot ios.sdopen("R",@parastr)

      ios.print(@msg7)
      ios.print(@msg4)
      ios.printdec(IMAGESIZE)
      ios.printnl
      ios.print(@msg5)
      ios.printdec(len/PAGESIZE)
      ios.printnl

      'vergleich starten
      repeat pos from 0 to IMAGESIZE-1 step PAGESIZE
        sdspi.readEEPROM(eeAdr+pos,@buffer,PAGESIZE)         'page einlesen
        repeat i from 0 to PAGESIZE-1
          a := byte[@buffer][i]
          b := ios.sdgetc
          if a <> b
            ios.printhex(eeAdr+pos+i,4)
            ios.print(string(" : "))
            ios.printhex(a,2)
            ios.print(string(" <> "))
            ios.printhex(b,2)
            ios.print(string(" CMD? [q]uit[*]next : "))
            case ios.keywait
              "q": return
            ios.printnl

      ios.sdclose

    else
      printErr(@err2)
  else
   printErr(@err1)

PRI save(eeAdr)|pos,len,i,j,pcnt,blk                   'flash: speichern

  eeAdr += sdspi#bootAddr                                'deviceadresse hinzufügen
  len := IMAGESIZE
  blk := len/BUFFERSIZE
  pcnt := blk/10

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(@msg9)
    ios.print(@msg1)
    ios.print(@parastr)
    ios.printnl
    ifnot ios.sdnewfile(@parastr)
      ios.sdopen("W",@parastr)
      ios.print(@msg8)
      ios.printhex(eeAdr,8)
      ios.printnl
      ios.print(@msg4)
      ios.printdec(IMAGESIZE)
      ios.printnl
      ios.print(@msg5)
      ios.printdec(blk)
      ios.printnl
      ios.print(@msgA)
      ios.curchar("▶")

      j := 0
      repeat blk+1
        sdspi.readEEPROM(eeAdr,@buffer,BUFFERSIZE)       'puffer einlesen
        ios.sdputblk(BUFFERSIZE,@buffer)
        eeAdr := eeAdr + BUFFERSIZE

        pcnt--
        if pcnt == 0
          ios.printchar("•")
          pcnt := len / BUFFERSIZE / 10

      ios.sdputc(0)                                     'provisorischer patch für fatengine:
                                                        'bei 32kb-grenze gibt es einen fehler!
      ios.sdclose
      ios.curchar("‣")
      ios.print(@msg3)

    else
      printErr(@err2)
  else
    printErr(@err1)

PRI testsave(eeAdr)|pos,len,i,j,pcnt,blk               'flash: speichern

  eeAdr += sdspi#bootAddr                                'deviceadresse hinzufügen
  len := IMAGESIZE
  blk := len/BUFFERSIZE
  pcnt := blk/10

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(@msg0)
    ios.print(@msg1)
    ios.print(@parastr)
    ios.printnl
    ifnot ios.sdnewfile(@parastr)
      ios.sdopen("W",@parastr)
      ios.print(@msg9)
      ios.print(@msg8)
      ios.printhex(eeAdr,8)
      ios.printnl
      ios.print(@msg4)
      ios.printdec(IMAGESIZE)
      ios.printnl
      ios.print(@msg5)
      ios.printdec(blk)
      ios.printnl
      ios.print(@msgA)
      ios.curchar("▶")

      j := 0
      repeat blk+1
        repeat i from 0 to BUFFERSIZE-1
          ios.sdputc(j)

        ios.printdec(j++)
        ios.printchar(" ")

      ios.sdclose
      ios.curchar("‣")
      ios.print(@msg3)

    else
      printErr(@err2)
  else
    printErr(@err1)

PRI printbuf(eeAdr)|i,j,n

    i := j := 0

    repeat DROW                               'zeilen
      ios.printhex(eeAdr+j*DCOL,4)
      ios.printchar(" ")
      repeat DCOL                             'bytes
        n := byte[@buffer][i++]
        ios.printhex(n,2)
        ios.printchar(":")
      ios.printchar(" ")
      i := i - DCOL
      repeat DCOL                             'zeichen
        n := byte[@buffer][i++]
        ios.printqchar(n)
      ios.printnl
      j++

DAT                                                     'sys: strings

msg0      byte "Funktion : Datei --> ROM",13,0
msg1      byte "Datei    : ",0
msg2      byte "Flash    : ",0
msg3      byte " ok",13,0
msg4      byte "Länge    : ",0
msg5      byte "Blöcke   : ",0
msg6      byte "Funktion : ROM löschen",13,0
msg7      byte "Funktion : Datei <--> ROM vergleichen",13,0
msg8      byte "Adresse  : $",0
msg9      byte "Funktion : ROM --> Datei",13,0
msgA      byte "Image    : ",0

PRI clear(eeAdr)|len,pcnt,i,pos                         'flash: löschen

  eeAdr += sdspi#bootAddr                                'deviceadresse hinzufügen
  len := IMAGESIZE
  pcnt := len / PAGESIZE / 10

  ios.printnl
  ios.print(@msg6)
  ios.print(@msg4)
  ios.printdec(IMAGESIZE)
  ios.printnl
  ios.print(@msg5)
  ios.printdec(len/PAGESIZE)
  ios.printnl
  ios.print(@msg2)
  ios.curchar("▶")

  'puffer löschen
  repeat i from 0 to BUFFERSIZE-1
    byte[@buffer][i] := 0

  'rom löschen
  repeat pos from 0 to IMAGESIZE-1 step PAGESIZE
    sdspi.writeEEPROM(eeAdr+pos,@buffer,PAGESIZE)
    sdspi.writeWait(eeAdr+pos)
    pcnt--
    if pcnt == 0
      ios.printchar("•")
      pcnt := len / PAGESIZE / 10

  ios.curchar("‣")
  ios.print(@msg3)
  return

DAT                                                     'sys: fehermeldungen

err0          byte  13,"Fehler : "
err1          byte  "Zu wenig Parameter!",13,0
err2          byte  "Datei nicht gefunden!",13,0

PRI printErr(stradr)                                    'sys: feherbehandlung

  ios.print(@err0)
  ios.print(stradr)
  ios.print(string("help: man flash"))

PRI inputhex:hexnum                                     'sys: eingabe hexwert

  ios.curchar("_")
  ios.print(string("Adresse : $"))
  ios.input(@input,8)                                   'nummer eingeben
  ios.curchar("‣")
  hexnum := num.FromStr(@input,num#HEX)                 'string in hexwert wandeln
  return


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
