{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Jörg Deckert                                                                                  │
│ Copyright (c) 2013 Jörg Deckert                                                                      │
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
Funktion        : IRC-Client
Komponenten     : -
COG's           : -
Logbuch         :

27.12.2013-joergd - erste Version


Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        str: "glob-string"
        num: "glob-numbers"        'Number Engine
        gc : "glob-con"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

CON

W0X_MENU        = 8
W0Y_MENU        = 0

COL_DEFAULT     = 0
COL_MENU        = 8
COL_FOCUS       = 3

VAR

  long  ip_addr
  word  ip_port
  byte  rows,cols,vidmod
  byte  x0[4],y0[4],xn[4],yn[4],hy[4],focus
  byte  input_str[64]

PUB main | key

  init

  repeat
    key := ios.keywait
    case key
      gc#KEY_TAB:               f_focus
      gc#KEY_F02:               f_setserver
      gc#KEY_F10:               f_quit


PRI init

  focus := 3

  ios.start                                             'ios initialisieren
  setscreen

PRI f_focus

  if ++focus == 4
    focus := 1
  win_redraw

PRI f_setserver

  input(string("IRC-Server angeben (IP:Port):"),21)
  win_redraw
  ios.winset(2)
  ios.print(string("Verbinde mit "))
  ios.print(@input_str)
  ios.print(string("...",10))

  if strToIpPort(@input_str, ip_addr, ip_port)
    ios.print(string("Wandlung erfolgreich",10))
  else
    ios.print(string("Wandlung fehlgeschlagen",10))


PRI f_quit

  ios.winset(0)
  ios.screeninit
  ios.stop

PRI frame_draw

  ios.winset(0)
  ios.curoff
  ios.printcls
  ios.cursetx(W0X_MENU)
  ios.cursety(W0Y_MENU)
  ios.setcolor(COL_MENU)
' ios.print(string("                                                        "))
  ios.print(string(" IRC Client                                             "))
  ios.printlogo(0,0)
  ios.setcolor(COL_DEFAULT)

PRI win_draw | i

  repeat i from 1 to 3
    ios.windefine(i,x0[i],y0[i],xn[i],yn[i])
    ios.winset(i)
    ios.curoff
    ios.printcls
    if i == focus
      ios.setcolor(COL_FOCUS)
    ios.winoframe
    if i == focus
      ios.setcolor(COL_DEFAULT)
    ios.winset(0)
    ios.cursetx(2)
    ios.cursety(hy[i])
    if i == focus
      ios.setcolor(COL_FOCUS)
    case i
      1: ios.print(@strWin1)
      2: ios.print(@strWin2)
      3: ios.print(@strWin3)
    if i == focus
      ios.setcolor(COL_DEFAULT)

PRI win_redraw | i

  repeat i from 1 to 3
    ios.winset(i)
    if i == focus
      ios.setcolor(COL_FOCUS)
    ios.winoframe
    if i == focus
      ios.setcolor(COL_DEFAULT)
    ios.winset(0)
    ios.cursetx(2)
    ios.cursety(hy[i])
    if i == focus
      ios.setcolor(COL_FOCUS)
    case i
      1: ios.print(@strWin1)
      2: ios.print(@strWin2)
      3: ios.print(@strWin3)
    if i == focus
      ios.setcolor(COL_DEFAULT)

PRI setscreen

  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen

  'gesamter Bildschirm (Nr. 0)
  x0[0] := 0
  y0[0] := 0
  xn[0] := cols-1
  yn[0] := rows-1

  'Chat-Fenster (Nr. 1)
  x0[1] := 1
  y0[1] := 2
  xn[1] := cols-2
  yn[1] := rows-9
  hy[1] := 1

  'Status-Fenster (Nr. 2)
  x0[2] := 1
  y0[2] := rows-7
  xn[2] := cols-2
  yn[2] := rows-4
  hy[2] := rows-8

  'Eingabe-Fenster (Nr. 3)
  x0[3] := 1
  y0[3] := rows-2
  xn[3] := cols-2
  yn[3] := rows-2
  hy[3] := rows-3

  frame_draw
  win_draw

  'Eingabe-Fenster (Nr. 4)
  ios.windefine(4,15,10,45,13)

PRI strToIpPort(ipstr, ip, port) | octet
  ' extracts the IP and PORT from a string

  long[ip] := 0
  word[port] := 0
  octet := 3
  repeat while octet => 0
    case byte[ipstr]
      "0".."9":
        byte[ip][octet] := (byte[ip][octet] * 10) + (byte[ipstr] - "0")
      ".":
        octet--
      ":":
        quit
      other:
        return false
    ipstr++
  if octet <> 0
    return false
  if byte[ipstr++] == ":"
    repeat while byte[ipstr] <> 0
      if byte[ipstr] => "0" and byte[ipstr] =< "9"
        word[port] := (word[port] * 10) + (byte[ipstr] - "0")
      else
        return false
      ipstr++

  return true

PUB input(stradr, input_len) | key,bnr

  input_str[0] := 0
  ios.winset(4)
  ios.printcls
  ios.winoframe
  ios.curhome
  ios.curoff
  ios.setcolor(COL_DEFAULT)
  ios.printchar(" ")
  ios.print(stradr)
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

PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)

DAT

strWin1    byte  "Chat",0
strWin2    byte  "Status",0
strWin3    byte  "Eingabe",0

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
