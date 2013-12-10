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
Name            :
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

}}

OBJ

  ios      : "reg-ios"
  fm       : "fm-con"
  gc       : "glob-con"

CON


VAR

  byte  box_win,box_x0,box_y0,box_x1,box_y1
  byte  input_len
  byte  input_str[64]

PUB define(win,x0,y0,x1,y1,len)

  box_win    := win             'fensternummer
  box_x0     := x0              'koordinaten
  box_x1     := x1
  box_y0     := y0
  box_y1     := y1
  input_len := len
  ios.windefine(box_win,box_x0,box_y0,box_x1,box_y1)
  ios.winset(box_win)
  ios.printcls

PUB draw(stradr1):stradr2 | key,bnr

  input_str[0] := 0
  ios.winset(box_win)
  ios.printcls
  ios.winoframe
  ios.curhome
  ios.curoff
  ios.setcolor(fm#COL_DEFAULT)
  ios.printchar(" ")
  ios.print(stradr1)
  ios.printnl
  ios.printnl
  ios.printchar(" ")
  repeat input_len
    ios.printchar("_")
  ios.curpos1
  ios.printchar(" ")
  ios.curon
  ios.input(@input_str,input_len)
  ios.curoff
  return @input_str


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
