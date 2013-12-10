{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Ingo Kripahle                                                                                 │
│ Copyright (c) 2010 Ingo Kripahle                                                                     │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei.                                             │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : drohne235@googlemail.com
System          : TriOS
Name            : keycode
Chip            : Regnatix
Typ             : Programm
Version         : 00
Subversion      : 01
Funktion        : Kleines Tool um Tastencodes auszugeben
Komponenten     : -
COG's           : -
Logbuch         :

22-03-2010-dr235  - anpassung trios

Kommandoliste   :

Notizen         :

}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

PUB main | key,spec
  ios.start

' code für test im ram, sollte bei bin-datei auskommentiert werden
' ios.startram

  repeat
    ios.print(string("[q] keycode : "))
    key  := ios.keywait
    spec := ios.keyspec
    ios.printhex(key,2)
    ios.print(@str1)
    ios.printdec(key)
    ios.printtab
    ios.print(@str1)
    ios.printtab
    ios.printqchar(key)
    ios.print(@str1)
    ios.printhex(spec,2)
    ios.printnl
  until key == "q"

  ios.stop

DAT

str1    byte " : ",0

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
