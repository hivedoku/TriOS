{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Jörg Deckert                                                                                 │
│ Copyright (c) 2013 Jörg Deckert                                                                     │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : joergd@bitquell.de
System          : TriOS
Name            : flash
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : IP-Konfiguration in NVRAM ablegen
Komponenten     : -
COG's           : -
Logbuch         :

11.12.2013-joergd - erste Version


Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        str: "glob-string"
        num: "glob-numbers"        'Number Engine

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

long    ip_addr
byte    parastr[64]
byte    addrset
byte    handle_control             'Handle FTP Control Verbindung
byte    handle_data                'Handle FTP Data Verbindung

PUB main

  ip_addr := 0

  ios.start                                             'ios initialisieren
  ios.printnl
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(@help)
        "s": if ios.paranext(@parastr)
               setaddr(@parastr)
        other: ios.print(@help)

  if (ip_addr)  ' Adresse nicht 0.0.0.0
    ios.lanstart
    handle_control := ios.lan_connect(ip_addr, 21)
    ios.printnl
    ios.print(string("Handle Connect: "))
    ios.print(num.ToStr(handle_control, num#DEC))
    ios.printnl
    ios.lan_close(handle_control)

 ios.stop

PRI setaddr (ipaddr) | pos, count                       'IP-Adresse in Variable schreiben

  count := 3
  repeat while ipaddr
    pos := str.findCharacter(ipaddr, ".")
    if(pos)
      byte[pos++] := 0
    ip_addr += num.FromStr(ipaddr, num#DEC) << (8*count--)
    ipaddr := pos
    if(count == -1)
      quit

DAT                                                     'sys: helptext


help          byte  "/?  :          Hilfe",13
              byte  "/s <a.b.c.d> : Server-Adresse",13
              byte  0

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
