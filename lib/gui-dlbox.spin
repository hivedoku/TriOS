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

CON


VAR

  byte  box_win,box_x0,box_y0,box_x1,box_y1
  long  box_ladr,box_fadr
  byte  box_view,box_maxpos,box_pos
  byte  box_cols
  byte  box_stat

PUB define(win,x0,y0,x1,y1,ladr,fadr,view,maxpos)

  box_win    := win             'fensternummer
  box_x0     := x0              'koordinaten
  box_x1     := x1
  box_y0     := y0
  box_y1     := y1
  box_view   := view            'position in der liste
  box_pos    := 0               'position im fenster
  box_maxpos := maxpos          'max. anzahl in liste
  box_ladr   := ladr            'adresse dateinamenliste
  box_fadr   := fadr            'adresse dateiflags
  box_cols   := (box_x1-box_x0)/(fm#MAX_LEN+2)
  box_stat   := 0
  ios.windefine(box_win,box_x0,box_y0,box_x1,box_y1)
  ios.winset(box_win)
  ios.printcls

PUB draw

  ios.winset(box_win)
  ios.printcls
  redraw

PUB redraw | i

  ios.winset(box_win)
  if box_stat & fm#FL_FOCUS
    ios.setcolor(fm#COL_FOCUS)
  ios.winoframe
  ios.curhome
  ios.curoff
  ios.setcolor(fm#COL_DEFAULT)
  i := 0
  repeat fm#WROWS
    repeat box_cols
      print_file(box_view+i,i)
      i++
    ios.printnl

PUB setpos(pos)

  box_pos := pos
  redraw

PUB setview(view)

  box_view := view
  redraw

PUB getcols: cols

  return box_cols

PUB focus

  ios.winset(box_win)
  box_stat := box_stat | fm#FL_FOCUS
  redraw

PUB defocus

  ios.winset(box_win)
  box_stat := box_stat & !fm#FL_FOCUS
  redraw

PRI print_file(fnr,posnr) | i,c

  i := 0
  c := fm#COL_DEFAULT

  if byte[box_fadr+fnr] & fm#FL_SEL                     'eintrag selektiert?
    c := fm#COL_SELECT

  if (posnr == box_pos) & (box_stat & fm#FL_FOCUS)      'eintrag an cursorpos?
    ios.setcolor(c+8)
  else
    ios.setcolor(c)

  if byte[box_fadr+fnr] & fm#FL_DIR                     'eintrag verzeichnis?
    ios.printq(string(" ▶"))
  else
    ios.print(string("  "))

  repeat fm#MAX_LEN
    ios.bus_putchar2(byte[box_ladr][fnr*fm#MAX_LEN+i])
    i++
  ios.setcolor(fm#COL_DEFAULT)

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
