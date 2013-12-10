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
Name            : Bellatrix-Test
Chip            : Regnatix
Typ             : Programm
Version         : 00
Subversion      : 01
Funktion        : Test für die grundlegenden Textausgabe- und Tastaturfunktionen.
Komponenten     : -
COG's           : -
Logbuch         :

22-03-2010-dr235  - anpassung trios

Kommandoliste   :

Notizen         :

}}

OBJ
        ios: "reg-ios"
        str: "glob-string"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OS_TIBLEN    = 64                                       'größe des inputbuffers

VAR
'systemvariablen
  byte  tib[OS_TIBLEN]           'tastatur-input-buffer
  byte  tibpos                   'aktuelle position im tib
  byte  tbuf[32]
  long  cols,rows
  byte vidmod                    'videomodus: 0 - vga, 1 -  tv

PUB main|fnr

  ios.start
  os_testvideo

  repeat
    ios.print(string("0  - Alle Tests",13))
    ios.print(string("1  - Zeichensatz",13))
    ios.print(string("2  - Hive-Logo",13))
    ios.print(string("3  - Funktion TAB",13))
    ios.print(string("4  - Funktion CLS",13))
    ios.print(string("5  - Scrolling",13))
    ios.print(string("6  - Funktion SCREENINIT",13))
    ios.print(string("7  - Funktion SETCOLOR",13))
    ios.print(string("8  - Funktion SETX/SETY",13))
    ios.print(string("9  - Windows",13))
    ios.print(string("10 - Funktion INPUT/BACKSPACE",13))
    ios.print(string("11 - Funktion HOME/POS1/CURCHAR",13))
    ios.print(string("99 - Ende  "))
    fnr := str.decimalToNumber(fInput(string(" Funktion : ")))
    case fnr
      0:  test_all
      1:  test_charmap
      2:  test_logo
      3:  test_tab
      4:  test_cls
      5:  test_scroll
      6:  test_screeninit
      7:  test_setcolor
      8:  test_setxy
      9:  test_windows
      10: test_inputbackspace
      11: test_home
          test_pos1
          test_curchar
      99: ios.stop

pri os_testvideo                                        'sys: passt div. variablen an videomodus an

  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen

pri fInput(stradr1): stradr2

  ios.setcolor(1)
  ios.printq(string("▶"))
  ios.print(stradr1)
  ios.input(@tbuf,32)
  ios.setcolor(0)
  ios.printnl
  return @tbuf

pri test_all

  test_charmap
  test_logo
  test_tab
  test_cls
  test_scroll
  test_screeninit
  test_setcolor
  test_setxy
  test_windows
  test_inputbackspace
  test_home
  test_pos1
  test_curchar


pri test_charmap|i,j

  ios.print(string("Zeichensatz:"))
  ios.printnl
  ios.print(string("   0123456789ABCDEF0123456789ABCDEF"))
  ios.printnl
  ios.print(string("  ┌────────────────────────────────┐"))

  repeat i from 0 to 7
    ios.printnl
    ios.printhex(i*j,2)
    ios.printchar("│")
    repeat j from 0 to 31
      ios.printqchar((i*31)+j)
    ios.printchar("│")
  ios.printnl
  ios.print(string("  └────────────────────────────────┘"))
  weiter

pri test_logo
  ios.print(string("Hive-Logo:"))
  ios.printcls
  ios.printlogo(0,0)
  weiter

pri test_tab|a,b,i,j

  ios.print(string("Test TAB:"))
  if cols < 50
    a := 3
    b := 5
  else
    a := 3
    b := 7
  repeat j from a to b
    repeat i from 0 to 7
      ios.settabs(i,j*i)
    ios.printcls
    repeat 8
      ios.print(string("tab"))
      ios.printtab
    ios.printnl
    repeat i from 1 to 5
      repeat 8
        ios.printdec(i)
        ios.printtab
      ios.printnl
    waitcnt(10_000_000+cnt)
  weiter

pri test_cls
  ios.print(string("Test CLS:"))
  ios.printcls
  repeat 10
      charset
  ios.printnl
  ios.printnl
  ios.print(string("Bildschirm wird gleich gelöscht..."))
  waitcnt(cnt + clkfreq*3)
  ios.printcls
  ios.print(string("Bildschirm löschen OK"))
  weiter

pri test_scroll
  ios.print(string("Test ScrollUp:"))
  repeat 10
    charset
  repeat 20
    waitcnt(10_000_000+cnt)
    ios.scrollup
  ios.printnl
  ios.printnl
'------------------------------------------------------------------------------------
  ios.print(string("Test ScrollDown:"))
  weiter
  repeat 10
    charset
  repeat 15 <# rows - 2
    waitcnt(10_000_000+cnt)
    ios.scrolldown
  repeat 16
    repeat 15 <# rows - 2
      waitcnt(1_000_000+cnt)
      ios.scrollup
    repeat 15 <# rows - 2
      waitcnt(1_000_000+cnt)
      ios.scrolldown
  weiter

pri test_screeninit
  ios.print(string("Test SCREENINIT:"))
  ios.screeninit
  ios.print(string("▶Funktionstest Bellatrix-BIOS [SCREENINIT OK]"))
  weiter

pri test_setcolor|i,j,n

  if vidmod == ios#TV
    n := 7
  else
    n := 15
  ios.print(string("Test SETCOLOR:",13))
  repeat i from 0 to n
    repeat j from 0 to 32
      ios.setcolor(i)
      ios.printchar(j + 65)
    ios.printchar(":")
    ios.printdec(i)
    ios.printchar(":")
    ios.printhex(i,2)
    ios.printnl
  ios.setcolor(0)
  weiter

pri test_setxy|i,j,n
  ios.print(string("Test SETX/SETY (CURON/CUROFF):"))
  ios.printcls
  ios.printnl
  ios.curoff
  repeat n from 1 to 50
    repeat j from 1 to 5
      repeat i from 1 to 8 <# cols/5-1
        ios.cursetx(i * 5)
        ios.cursety(j * 2)
        ios.printchar(":")
        ios.printdec(n)

        ios.cursetx(5)
        ios.cursety(12 <# rows)
        ios.printchar(":")
        ios.printdec(j)
        ios.printchar(":")
        ios.printdec(i)
        ios.printchar(":")
        ios.printdec(n)
  ios.curon
  ios.printnl
  weiter

pri test_windows
  ios.print(string("Test Windows:"))
  windows1
  windows2
  ios.printcls
  weiter

pri test_inputbackspace
  ios.print(string("Test Eingabe/Backspace (bis Enter): "))
  input
  ios.printnl
  ios.print(string("Eingabe :"))
  ios.print(@tib)
  weiter

pri test_home|i
  ios.printcls
  ios.print(string("Test Home:"))
  repeat i from 0 to 1000
    ios.curhome
    ios.printdec(i)
  weiter

pri test_pos1|i
  ios.print(string("Test POS1:"))
  ios.printnl
  repeat i from 0 to 1000
    ios.curpos1
    ios.printdec(i)
  weiter

pri test_curchar|i
  ios.print(string("Test CURCHAR: "))
  repeat i from 1 to 100
    ios.curchar(i)
    waitcnt(cnt + clkfreq/20)
  ios.curchar($0E)
  weiter

PRI weiter | tast
  ios.printnl
  ios.print(string("Weiter [q|*] : "))
  tast := ios.keywait
  if tast == "q"  OR tast == "Q"
     ios.stop
  ios.printnl

PUB charset | i,j

  repeat i from 20 to 255
    ios.printchar(i)

PUB input | charc
  repeat 
    if ios.keystat > 0                                      'taste gedrückt?
      charc := ios.key                                      'tastencode holen
        if (tibpos + 1) < OS_TIBLEN                     'tastaturpuffer voll?
          case charc
            ios#CHAR_BS:                                'backspace
                   if tibpos > 0
                     tibpos--
                     tib[tibpos] := $0                  'letztes zeichen im puffer löschen
                     ios.printbs                        'steuerzeichen anterminal senden
            other: ios.bus_putchar2(charc)              'sonstige zeichen
        
      if (charc <> ios#CHAR_NL) & (charc <> ios#CHAR_BS) 'ausser sonderzeichen alles in tib
        if (tibpos + 1) < OS_TIBLEN                     'tastaturpuffer voll?
          tib[tibpos++] := charc
          tib[tibpos] := $0
  until charc == $0D                                    'schleife bis RETURN

VAR
  long h[3], z[3], r[3]

PUB windows1 | gx, gy, i, j, tast
  cols := ios.belgetcols
  rows := ios.belgetrows
  gx := cols / 2
  gy := rows * 2 / 3
  ios.printcls
  ios.print(string("  ### Window-Test ###"))

  ios.windefine(1, 2, 3, gx - 1, gy - 1)
  ios.windefine(2, gx + 2, 3, cols - 2, gy - 1)
  ios.windefine(3, 2, gy + 2, cols - 2, rows - 2)
  repeat i from 1 to 3
    ios.winset(i)
    ios.printcls
    ios.winoframe

  waitcnt(cnt + clkfreq)
  repeat i from 1 to 3
    ios.winset(i)
    repeat 3
      charset
  waitcnt(cnt + clkfreq)

  repeat i from 1 to 3
    ios.winset(i)
    j := ios.wingetrows
    repeat 8
      repeat 15 <# j - 2
        waitcnt(1_000_000+cnt)
        ios.scrollup
      repeat 15 <# j - 2
        waitcnt(1_000_000+cnt)
        ios.scrolldown

  repeat i from 0 to 2
    ios.winset(i+1)
    h[i] := ios.wingetrows - 2
    z[i] := 0
    r[i] := 1
    repeat 3
      charset
  i := 0
  repeat 16*3*4
    i := (i + 1) // 3
    ios.winset(i+1)
    z[i] += r[i]
    if r[i] > 0
      ios.scrollup
    else
      ios.scrolldown
    if z[i] == 0 or z[i] == h[i]
      r[i] *= -1
    waitcnt(1_000_000+cnt)

  ios.winset(3)
  ios.printcls
  ios.print(string("Test Screen 2"))
  weiter
  screen2

  repeat i from 1 to 3
    ios.winset(i)
    ios.printcls
    ios.curoff

  ios.winset(1)
  ios.printcls
  ios.print(string("Test relative Positionierung"))
  weiter

  ios.winset(2)
  repeat j from 2 to 3
    ios.winset(j)
    repeat i from 1 to 3
      setpos(i, i)
      waitcnt(cnt + clkfreq/2)
      setpos(-i, -i)
      waitcnt(cnt + clkfreq/2)

  ios.winset(1)
  ios.curon
  ios.printnl
  ios.printnl
  ios.print(string("Weiter */<Q>uit : "))
  tast := ios.keywait
  ios.screeninit
  if tast == "q"  OR tast == "Q"
    ios.stop

PUB windows2 | gx, gy, i, j, tast
  cols := ios.belgetcols
  rows := ios.belgetrows
  gx := cols / 2
  gy := rows * 2 / 3
  ios.printcls
  ios.print(string("  ### Window-Test - Randkollision ###"))

  ios.windefine(1, 2, 3, gx - 1, gy - 1)
  ios.windefine(2, gx + 2, 3, cols + 4, gy - 1)
  ios.windefine(3, 2, gy + 2, cols + 4, rows + 4)
  repeat i from 1 to 3
    ios.winset(i)
    ios.printcls
    ios.winoframe

  waitcnt(cnt + clkfreq)
  repeat i from 1 to 3
    ios.winset(i)
    repeat 3
      charset
  waitcnt(cnt + clkfreq)

  repeat i from 1 to 3
    ios.winset(i)
    j := ios.wingetrows
    repeat 8
      repeat 15 <# j - 2
        waitcnt(1_000_000+cnt)
        ios.scrollup
      repeat 15 <# j - 2
        waitcnt(1_000_000+cnt)
        ios.scrolldown

  repeat i from 0 to 2
    ios.winset(i+1)
    h[i] := ios.wingetrows - 2
    z[i] := 0
    r[i] := 1
    repeat 3
      charset
  i := 0
  repeat 16*3*4
    i := (i + 1) // 3
    ios.winset(i+1)
    z[i] += r[i]
    if r[i] > 0
      ios.scrollup
    else
      ios.scrolldown
    if z[i] == 0 or z[i] == h[i]
      r[i] *= -1
    waitcnt(1_000_000+cnt)

  ios.winset(3)
  ios.printcls
  ios.print(string("Test Screen 2"))
  weiter
  screen2

  repeat i from 1 to 3
    ios.winset(i)
    ios.printcls
    ios.curoff

  ios.winset(1)
  ios.printcls
  ios.print(string("Test relative Positionierung"))
  weiter

  ios.winset(2)
  repeat j from 2 to 3
    ios.winset(j)
    repeat i from 1 to 3
      setpos(i, i)
      waitcnt(cnt + clkfreq/2)
      setpos(-i, -i)
      waitcnt(cnt + clkfreq/2)

  ios.winset(1)
  ios.curon
  ios.printnl
  ios.printnl
  ios.print(string("Weiter */<Q>uit : "))
  tast := ios.keywait
  ios.screeninit
  if tast == "q"  OR tast == "Q"
    ios.stop

PRI setpos(x, y)
  ios.wincursetx(x)
  ios.wincursety(y)
  printpos(x, y)

PRI printpos(x, y)
  ios.printqchar(15)
  waitcnt(cnt + clkfreq/3)
  if x < 0
    ios.curpos1
  else
    ios.printqchar(2)
  ios.printchar("(")
  ios.printdec(x)
  ios.printchar(",")
  ios.printdec(y)
  ios.printchar(")")
  if x < 0
    ios.printqchar(3)

PRI screen2
  ios.set_wscr(2)
  ios.set_dscr(2)

  ios.print(string("hier ist Screen 2"))
  ios.printnl
' Window anzeigen, Scrolling
  ios.print(string("definiere Window 2 abweichend zu Screen 1: (8, 2)-(30, 8)"))
  ios.printnl
  ios.windefine(2, 8, 2, 30, 8)
  ios.print(string("weiter mit beliebiger Taste..."))
  ios.keywait
  ios.winset(2)
  ios.winoframe
  ios.printcls
  ios.print(string("Ausgabe in Window 2"))
  ios.printnl
  ios.print(string("zurück zu Screen 1 mit beliebiger Taste..."))
  ios.keywait
  ios.set_wscr(1)
  ios.set_dscr(1)

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
