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

11.06.2013-joergd - erste Version, basierend auf time.spin


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

CON 'NVRAM Konstanten --------------------------------------------------------------------------

#4,     NVRAM_IPADDR
#8,     NVRAM_IPMASK
#12,    NVRAM_IPGW
#16,    NVRAM_IPDNS
#20,    NVRAM_IPBOOT
#24,    NVRAM_HIVE       ' 4 Bytes

VAR

byte    parastr[64]

PUB main

  ios.start                                             'ios initialisieren
  ios.printnl
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(@help)
        "l": cmd_listcfg
        "a": if ios.paranext(@parastr)
               cmd_setaddr(NVRAM_IPADDR, @parastr)
        "m": if ios.paranext(@parastr)
               cmd_setaddr(NVRAM_IPMASK, @parastr)
        "g": if ios.paranext(@parastr)
               cmd_setaddr(NVRAM_IPGW, @parastr)
        "d": if ios.paranext(@parastr)
               cmd_setaddr(NVRAM_IPDNS, @parastr)
        "b": if ios.paranext(@parastr)
               cmd_setaddr(NVRAM_IPBOOT, @parastr)
        "i": if ios.paranext(@parastr)
               cmd_sethive(num.FromStr(@parastr, num#DEC))
        other: ios.print(@help)
  ios.stop

PRI cmd_listcfg | hiveid                                       'nvram: IP-Konfiguration anzeigen

  ios.print(string(" IP-Adresse:  "))
  listaddr(NVRAM_IPADDR)
  ios.print(string("/"))
  listaddr(NVRAM_IPMASK)
  ios.printnl

  ios.print(string(" Gateway:     "))
  listaddr(NVRAM_IPGW)
  ios.printnl

  ios.print(string(" DNS-Server:  "))
  listaddr(NVRAM_IPDNS)
  ios.printnl

  ios.print(string(" Boot-Server: "))
  listaddr(NVRAM_IPBOOT)
  ios.printnl

  ios.print(string(" Hive-Id:     "))
  hiveid :=          ios.getNVSRAM(NVRAM_HIVE)
  hiveid := hiveid + ios.getNVSRAM(NVRAM_HIVE+1) << 8
  hiveid := hiveid + ios.getNVSRAM(NVRAM_HIVE+2) << 16
  hiveid := hiveid + ios.getNVSRAM(NVRAM_HIVE+3) << 24
  ios.print(str.trimCharacters(num.ToStr(hiveid, num#DEC)))
  ios.printnl

PRI listaddr (nvidx) | count                                  'nvram: IP-Adresse setzen

  repeat count from 0 to 3
    if(count)
      ios.print(string("."))
    ios.print(str.trimCharacters(num.ToStr(ios.getNVSRAM(nvidx+count), num#DEC)))

PRI cmd_setaddr (nvidx, ipaddr) | pos, count                  'nvram: IP-Adresse setzen

  count := 0
  repeat while ipaddr
    pos := str.findCharacter(ipaddr, ".")
    if(pos)
      byte[pos++] := 0
    ios.setNVSRAM(nvidx+count++, num.FromStr(ipaddr, num#DEC))
    ipaddr := pos
    if(count == 4)
      quit

  ios.lanstart
  cmd_listcfg

PRI cmd_sethive (hiveid)                                       'nvram: IP-Adresse setzen

  ios.setNVSRAM(NVRAM_HIVE, hiveid & $FF)
  ios.setNVSRAM(NVRAM_HIVE+1, (hiveid >> 8) & $FF)
  ios.setNVSRAM(NVRAM_HIVE+2, (hiveid >> 16) & $FF)
  ios.setNVSRAM(NVRAM_HIVE+3, (hiveid >> 24) & $FF)

  ios.lanstart
  cmd_listcfg

DAT                                                     'sys: helptext


help          byte  "/?  :          Hilfe",13
              byte  "/l  :          Konfiguration anzeigen",13
              byte  "/a <a.b.c.d> : IP-Adresse setzen",13
              byte  "/m <x.x.x.x> : Netzwerk-Maske setzen",13
              byte  "/g <e.f.g.h> : Gateway setzen",13
              byte  "/d <i.j.k.l> : DNS-Server setzen",13
              byte  "/b <m.n.o.p> : Boot-Server setzen",13
              byte  "/i <Id> :      Hive-Id setzen",13
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
