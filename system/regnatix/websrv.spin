{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Jörg Deckert                                                                                  │
│ Copyright (c) 2014 Jörg Deckert                                                                      │
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
Funktion        : Webserver
Komponenten     : -
COG's           : -
Logbuch         :

23.06.2014-joergd - erste Version
                  - Parameter für Benutzer und Paßwort

Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        gc : "glob-con"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR


PUB main

  ios.start
  ifnot (ios.admgetspec & gc#A_LAN)
    ios.sddmset(ios#DM_USER)                            'u-marker setzen
    ios.sddmact(ios#DM_SYSTEM)                          's-marker aktivieren
    ios.admload(string("admnet.adm"))                   'versuche, admnet zu laden
    ios.sddmact(ios#DM_USER)                            'u-marker aktivieren
    ifnot (ios.admgetspec & gc#A_LAN)                   'wenn Laden fehlgeschlagen
      ios.print(@strNoNetwork)
      ios.stop                                          'Ende
  ios.printnl


  ios.stop

DAT ' Locale

#ifdef __LANG_EN
  'locale: english

  strNoNetwork     byte 13,"Administra doesn't provide network functions!",13,"Please load admnet.",13,0

#else
  'default locale: german

  strNoNetwork     byte 13,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",13,"Bitte admnet laden.",13,0

#endif

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
