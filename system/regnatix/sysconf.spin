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
Name            : sysconf
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : Kommandozeilentool für TriOS-Systemeinstellungen
Komponenten     : -
COG's           : -
Logbuch         :

16-04-2010-dr235  - erste version
24-10-2010-dr235  - port input/output

Kommandoliste   :

/?        : Hilfe
/l        : list konf
/ap       : Konfiguration anzeigen
/ah 0|1   : hss ab-/anschalten
/aw 0|1   : wav ab-/anschalten
/as 0|1   : systemklänge ab-/anschalten
/al 0..100: wav-lautstärke links
/ar 0..100: wav-lautstärke rechts
/ah 0..15 : hss-lautstärke
/ci       : farbtabelle anzeigen
/cs datei : farbtabelle speichern
/cl datei : farbtabelle laden
/po p a   : port ausgabe portnummer anzahl impulse
/pi       : port eingabe portnummer


Notizen         :

}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

byte    parastr[64]
byte    vidmod                    'videomodus: 0 - vga, 1 -  tv
long    cols,rows

PUB main

  ios.start                                             'ios initialisieren
  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(string("help: man sysconf"))     '/?
        "l": printConf
        "a": case byte[@parastr][2]                     'administra
               "h": setHSS                              '/ah - hss
               "w": setWAV                              '/aw - wav
               "s": setSYS                              '/as - systemklänge
               "l": set_lvol                            '/al - wav-lautstärke links
               "r": set_rvol                            '/ar - wav-lautstärke rechts
               "v": set_hvol                            '/av - hss-lautstärke
               "f": ios.admreset                        '/ab - administra reset, flash wird neu gebootet
               "t": busTransfer                         '/at - transfergeschwindigkeit messen
        "c": case byte[@parastr][2]                     'color
               "i": col_info                            '/ci - farbregister anzeigen
               "l": col_load                            '/cl - farbregister laden
               "s": col_save                            '/cs - farbregister speichern
        "p": case byte[@parastr][2]                     'portfunktionen
               "o": port_out                            '/po - impulse am port ausgeben
               "i": port_in                             '/pi - portstatus einlesen
  ios.stop

DAT 'PORT

PRI port_out|pnr,anz,time,fak,i

  if ios.paranext(@parastr)
    pnr := str2dec(@parastr)
    if ios.paranext(@parastr)
      anz := str2dec(@parastr)
      if ios.paranext(@parastr)
        fak := str2dec(@parastr)
      else
        printErr(@err1)
        return
    else
      printErr(@err1)
      return
  else
    printErr(@err1)
    return

  ios.print(string("Port Nr(0..31): "))
  ios.printdec(pnr)
  ios.printnl
  ios.print(string("Impulse       : "))
  ios.printdec(anz)
  ios.printnl
  ios.print(string("Faktor        : "))
  ios.printdec(fak)
  ios.printnl
' ------------------------
  dira[pnr]~~
  time := cnt
  i := 0
  repeat anz
    outa[pnr] := 1
    waitcnt(time += clkfreq/fak)
    outa[pnr] := 0
    waitcnt(time += clkfreq/fak)
  ios.bus_init
' ------------------------

PRI port_in|pnr,wert

    ios.printnl
'     ------------------------
    dira := 0
    wert := ina[0..31]
    ios.bus_init
'     ------------------------
    ios.print(string("Status : "))
    ios.printbin(wert,32)


DAT 'COLOR

PRI col_info|i,n

  if vidmod == ios#TV
    n := 7
  else
    n := 15
  repeat i from 0 to n
    ios.printhex(ios.belgetcolor(i*2),8)
    ios.printchar(" ")
    ios.printhex(ios.belgetcolor(i*2+1),8)
    ios.setcolor(i)
    ios.print(string(" Farbe : "))
    ios.setcolor(0)
    ios.printdec(i)
    ios.printnl

PRI col_save|i,color

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(string("Farbtabelle speichern : "))
    ios.print(@parastr)
    ios.sdnewfile(@parastr)
    ifnot ios.sdopen("W",@parastr)
      repeat i from 0 to 15
        color := ios.belgetcolor(i)
        ios.sdputc(color >> 24)
        ios.sdputc(color >> 16)
        ios.sdputc(color >>  8)
        ios.sdputc(color      )
      ios.sdclose
  else
   printErr(@err1)
   
PRI col_load|i,color

  if ios.paranext(@parastr)
    ios.printnl
    ios.print(string("Farbtabelle laden : "))
    ios.print(@parastr)
    ifnot ios.sdopen("R",@parastr)
      repeat i from 0 to 15
        color := ios.sdgetc << 24
        color += ios.sdgetc << 16
        color += ios.sdgetc << 8
        color += ios.sdgetc
        ios.belsetcolor(i,color)
      ios.sdclose
  else
   printErr(@err1)

DAT 'VOLUME

PRI set_lvol

  if ios.paranext(@parastr)                             'parameter?
    ios.wav_lvol(str2dec(@parastr))
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PRI set_rvol

  if ios.paranext(@parastr)                             'parameter?
    ios.wav_rvol(str2dec(@parastr))
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

PRI set_hvol

  if ios.paranext(@parastr)                             'parameter?
    ios.hss_vol(str2dec(@parastr))
  else                                                  'kein parameter: fehlermeldung
    printErr(@err1)

DAT 'SOUNDSYSTEM

PRI setHSS

  if ios.paranext(@parastr)                             'parameter?
    case byte[@parastr][0]
      "0": ios.admsetsound(0)
        ios.print(@msg4)
        ios.print(@msg2)
      "1": ios.admsetsound(1)
        ios.print(@msg4)
        ios.print(@msg1)
  else
    printErr(@err1)

PRI setWAV

  if ios.paranext(@parastr)                             'parameter?
    case byte[@parastr][0]
      "0": ios.admsetsound(2)
        ios.print(@msg5)
        ios.print(@msg2)
      "1": ios.admsetsound(3)
        ios.print(@msg5)
        ios.print(@msg1)
  else
    printErr(@err1)

PRI setSYS  

  if ios.paranext(@parastr)                             'parameter?
    case byte[@parastr][0]
      "0": ios.admsetsyssnd(0)
        ios.print(@msg7)
        ios.print(@msg2)
      "1": ios.admsetsyssnd(1)
        ios.print(@msg7)
        ios.print(@msg1)
  else
    printErr(@err1)

VAR

long    tcnt1,tcnt2                                     'transferzähler
byte    tflag                                           'transferflag

CON

  tbytes = 32768

PRI busTransfer|sec

  ios.print(@msg8)

  'zeit für reinen schleifendurchlauf berechnen
  tcnt1 := cnt
  repeat tbytes
    busTransferDummy1
  tcnt1 := cnt - tcnt1

  'messvorgang
  tcnt2 := cnt
  repeat tbytes
    ios.admgetsndsys
  tcnt2 := cnt - tcnt2

  ios.print(@msg10)
  ios.print(@msg9)
  sec := (tcnt2 - tcnt1) / clkfreq      'zeit der übertragung in sekunden
  ios.printdec((tbytes*2)/sec)
  ios.print(@msg11)

PRI busTransferDummy1

    busTransferDummy2
    return busTransferDummy2

PRI busTransferDummy2

    return 1

PRI printConf

  ios.printnl
  ios.print(@msg3)              'soundsystem
  case ios.admgetsndsys
    0: ios.print(@msg6)
    1: ios.print(@msg4)
    2: ios.print(@msg5)
  ios.printnl

  ios.print(@msg12)             'ramdisk
  if ios.rd_getinit
    ios.print(@msg14)
  else
    ios.print(@msg15)
  ios.printnl

  ios.print(@msg13)             'usermem
  ios.printdec(ios.ram_getend - ios.ram_getbas)
  ios.printnl

  ios.print(@msg16)
  ios.printbin(ios.belgetspec,16)
  ios.printnl

  ios.print(@msg17)
  ios.printbin(ios.admgetspec,16)
  ios.printnl

PRI printErr(stradr)

  ios.print(@err0)
  ios.print(stradr)
  ios.print(string("help: man sysconf"))

PRI str2dec(stradr)|buffer,counter

  buffer := byte[stradr]
  counter := (strsize(stradr) <# 11)
  repeat while(counter--)
    result *= 10
    result += lookdownz(byte[stradr++]: "0".."9")
  if(buffer == "-")
    -result   

DAT

msg1          byte  "EIN ", 0
msg2          byte  "AUS ", 0
msg3          byte  "Soundsystem : ",0
msg12         byte  "Ramdisk     : ",0
msg13         byte  "Usermem     : ",0
msg16         byte  "Bellatrix   : ",0
msg17         byte  "Administra  : ",0
msg14         byte  "aktiviert",0
msg15         byte  "deaktiviert",0
msg4          byte  "HSS-Engine ",0
msg5          byte  "WAV-Engine ",0
msg6          byte  "Soundsystem deaktiviert ",0
msg7          byte  "Systemklänge ",0
msg8          byte  "Transfergeschwindigkeit Regnatix <--> Administra messen... ",0
msg9          byte  "Geschwindigkeit : ",0
msg10         byte  "ok",13,0
msg11         byte  " Bytes/Sekunde",13,0

err0          byte  13,"Fehler : "
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
