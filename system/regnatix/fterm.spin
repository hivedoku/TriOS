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
Name            : Terminal
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : Terminalprogramm, ursprünglich für Experimente mit PropForth gedacht - deshalb fterm.

Komponenten     : -
COG's           : -
Logbuch         :
Kommandoliste   :
Notizen         :

}}

OBJ
  ios   : "reg-ios"
  ser   : "glob-fds"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

PUB main | key

  ios.start
'  ios.startram                                          'code für test im ram, sollte bei bin-datei auskommentiert werden
  ser.start(31, 30, 0, 9600)
  ios.print(string("FTerm - Quit = [ESC]",ios#CHAR_NL))
  term
  ios.stop

PRI term | rxchar,keychar

  repeat

    rxchar := ser.rxcheck                              'zeichen empfangen
    if rxchar <> -1
      case rxchar
        $08:                                           'backspace empfangen
          ios.printctrl(ios#CHAR_TER_BS)
        other:
          if rxchar > $05
            ios.printchar(rxchar)                      'textzeichen empfangen

    if ios.keystat
      keychar := ios.key
      case keychar
        ios#CHAR_BS:                                    'backspace senden
          ser.tx($08)
        ios#CHAR_ESC:                                   'esc - programm beenden
          return
        other:                                          'textzeichen senden
          ser.tx(keychar)


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
