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
Name            : mental-Loader für TriOS
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
        ios: "reg-ios"
        mgc: "m-glob-con"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

  long  plen                                            'länge datenblock loader
  byte  proghdr[16]                                     'puffer für objektkopf
  byte  debug

pub main | err,sys

  debug := 0
  err   := 0
  sys   := 0
  ios.start
  ios.sddmact(ios#DM_ROOT)
  ios.print(string(13,"Wir sind Borg. Widerstand ist zwecklos.",13))
  ios.print(string("Assimilation wird gestartet...",13,13))
  err |= need_file(string("Check ADM-Code : "),string("adm"))
  err |= need_file(string("Check BEL-Code : "),string("bel"))
  err |= need_file(string("Check REG-Code : "),string("reg"))
  sys := need_file(string("Check USR-Tape : "),string("usr"))
  sys := need_file(string("Check SYS-Tape : "),string("sys"))
  pause(3)
  ifnot err
    if sys
      ios.print(string(13,"SYS-Tape nicht vorhanden, mental wird dennoch gestartet!",13))
      timer(10)
    mload
  else
    ios.print(string(13,"Abbruch: System nicht korrekt installiert!",13))
  ios.stop

pri timer(sec)

  ios.curoff
  ios.printnl
  repeat sec
    ios.curpos1
    ios.print(string("Weiter in "))
    ios.printdec(sec--)
    ios.print(string(" Sekunden "))
    waitcnt(cnt+clkfreq)
  ios.curon

pri pause(sec)

  if debug
    waitcnt(cnt+clkfreq*sec)

pri mload | i

  '---------------------------------------------------------- slavecode starten
  ios.print(string(13,"System wird nun gestartet...",13))
  pause(2)

  ios.belload(string("bel"))
  ios.print(string(" BEL-Code wurde gestartet:  ok",13))
  ios.sdclose
  pause(2)

  ios.print(string(" ADM-Code wird  gestartet: "))
  ios.admload(string("adm"))
  ios.print(string(" ok"))

  pause(2)
  ios.printnl
  ios.print(string(" REG-Code wird  gestartet: "))

  '---------------------------------------------------------- m-core starten
  m_sdopen("r",string("reg"))                           'datei öffnen
  repeat i from 0 to 15                                 '16 bytes header --> bellatrix
    byte[@proghdr][i] := m_sdgetc
  m_sdclose

  plen := 0
  plen :=        byte[@proghdr + $0B] << 8
  plen := plen + byte[@proghdr + $0A]
  plen := plen - 8                                      'korrekte dateilänge berechnen

  m_sdopen("r",string("reg"))                           'datei öffnen
  ios.bus_putchar1(mgc#adm_sd_getblk)                   'adm:sd_getblk
  ios.bus_putlong1(plen)                                'blocklänge senden

  dira := 0                                             'diese cog vom bus trennen
  repeat i from 0 to 7                                  'alle anderen cogs stoppen
    if i <> cogid
      cogstop(i)
  cognew(@loader, plen)                                 'pasm-loader übernimmt
  cogstop(cogid)                                        'spin-loader beenden


dat                        org     0

loader
                        mov     outa,    _S1               'bus inaktiv
                        mov     dira,    DINP              'bus auf eingabe schalten
                        mov     reg_cnt, PAR               'parameter = plen
                        mov     reg_adr, #0                'adresse ab 0

                        ' datenblock empfangen
loop
                        call    #m_aget                    'wert einlesen
                        wrbyte  reg_a,   reg_adr           'wert --> hubram

                        add     reg_adr, #1                'adresse + 1
                        djnz    reg_cnt, #loop

                        mov     dira, #0

                        ' neuen code starten

                        rdword  reg_a,   #$A               ' Setup the stack markers.
                        sub     reg_a,   #4                '
                        wrlong  SMARK,   reg_a             '
                        sub     reg_a,   #4                '
                        wrlong  SMARK,   reg_a             '

                        rdbyte  reg_a,   #$4               ' Switch to new clock mode.
                        clkset  reg_a                                             '

                        coginit SINT                       ' Restart running new code.


                        cogid   reg_a
                        cogstop reg_a                      'cog hält sich selbst an

' ---------------------------------------------------------------------
' businterface
' ---------------------------------------------------------------------

' reg_a       io-zeichen
' reg_b       temp
' reg_c       temp

m_aput                  ' zeichen zu administra senden
                        waitpeq _hs,_hs           ' warte auf hs=1 (slave bereit)
                        and     reg_a,#$ff        ' wert maskieren
                        or      reg_a,_a1         ' + bel=0 wr=0 clk=0
                        mov     outa,reg_a        ' daten + signale ausgeben
                        mov     dira,dout         ' bus auf ausgabe schalten
                        or      outa,_a2          ' clk=0 --> clk=1
                        waitpeq _zero,_hs         ' warte auf hs=0
                        mov     dira,dinp         ' bus auf eingabe schalten
                        mov     outa,_s1          ' bussignale inaktiv
m_aput_ret              ret

m_bput                  ' zeichen zu bellatrix senden
                        waitpeq _hs,_hs           ' warte auf hs=1 (slave bereit)
                        and     reg_a,#$ff        ' wert maskieren
                        or      reg_a,_b1         ' + bel=0 wr=0 clk=0
                        mov     outa,reg_a        ' daten + signale ausgeben
                        mov     dira,dout         ' bus auf ausgabe schalten
                        or      outa,_b2          ' clk=0 --> clk=1
                        waitpeq _zero,_hs         ' warte auf hs=0
                        mov     dira,dinp         ' bus auf eingabe schalten
                        mov     outa,_s1          ' bussignale inaktiv
m_bput_ret              ret

m_aget                  ' zeichen von administra empfangen
                        waitpeq _hs,_hs           ' warte auf hs=1 (slave bereit)
                        mov     outa,_a3          ' bel=0 wr=1 clk=1
                        waitpeq _zero,_hs         ' warte auf hs=0
                        mov     reg_a,ina         ' daten einlesen
                        and     reg_a,#$ff        ' wert maskieren
                        mov     outa,_s1          ' bussignale inaktiv
m_aget_ret              ret

m_bget                  ' zeichen von belatrix empfangen
                        waitpeq _hs,_hs           ' warte auf hs=1 (slave bereit)
                        mov     outa,_b3          ' bel=0 wr=1 clk=1
                        waitpeq _zero,_hs         ' warte auf hs=0
                        mov     reg_a,ina         ' daten einlesen
                        and     reg_a,#$ff        ' wert maskieren
                        mov     outa,_s1          ' bussignale inaktiv
m_bget_ret              ret




'                  +------------------------------- /hs
'                  |+------------------------------ /wr
'                  ||+----------------------------- busclk
'                  |||+---------------------------- hbeat
'                  |||| +-------------------------- al
'                  |||| |+------------------------- /bel
'                  |||| ||+------------------------ /adm
'                  |||| |||+----------------------- /ram2
'                  |||| ||||+---------------------- /ram1
'                  |||| |||||           +---------- a0..10
'                  |||| |||||           |
'                  |||| |||||           |        +- d0..7
'                  |||| |||||+----------+ +------+
_al     long  %00000000_10000000_00000000_00000000  ' /al bitmaske
_bwr    long  %00000100_00000000_00000000_00000000  ' /wr bitmaske
_ram1   long  %00000000_00001000_00000000_00000000  ' /ram1 bitmaske
_latch  long  %00000000_00000000_11111111_00000000  ' latch bitmaske
_adr    long  %00000000_00000111_11111111_00000000  ' adrbus bistmaske

dinp    long  %00000111_11111111_11111111_00000000  ' bus input
dout    long  %00000111_11111111_11111111_11111111  ' bus output
_s1     long  %00000100_01111000_00000000_00000000  ' bus inaktiv
_b1     long  %00000000_00111000_00000000_00000000  ' adm=1, bel=0, wr=0, busclk=0
_b2     long  %00000010_00111000_00000000_00000000  ' adm=1, bel=0, wr=0, busclk=1
_b3     long  %00000110_00111000_00000000_00000000  ' adm=1, bel=0, wr=1, busclk=1
_a1     long  %00000000_01011000_00000000_00000000  ' adm=0, bel=1, wr=0, busclk=0
_a2     long  %00000010_01011000_00000000_00000000  ' adm=0, bel=1, wr=0, busclk=1
_a3     long  %00000110_01011000_00000000_00000000  ' adm=0, bel=1, wr=1, busclk=1
_hs     long  %00001000_00000000_00000000_00000000  ' hs=1?
_zero   long  %00000000_00000000_00000000_00000000  '

SINT    long    ($0001 << 18) | ($3C01 << 4)                       ' Spin interpreter boot information.
SMARK   long    $FFF9FFFF                                          ' Stack mark used for spin code.

reg_adr res   1
reg_cnt res   1
reg_a   res   1
reg_b   res   1
reg_c   res   1

pri need_file(strptr1,strptr2): err

  ios.print(strptr1)
  ios.printtab
  ios.printtab
  err := ios.sdopen("R",strptr2)
  ios.sdclose
  ifnot err
    ios.print(string("ok"))
  else
    ios.setcolor(1)
    ios.print(string("fail"))
    ios.setcolor(0)
  ios.printnl

pri m_sdopen(modus,stradr):err | len,i                  'sd-card: datei öffnen
''funktionsgruppe               : sdcard
''funktion                      : eine bestehende datei öffnen
''busprotokoll                  : [004][put.modus][sub_putstr.fn][get.error]
''                              : modus - "A" Append, "W" Write, "R" Read (Großbuchstaben!)
''                              : fn - name der datei
''                              : error - fehlernummer entspr. list

  ios.bus_putchar1(mgc#adm_sd_open)
  ios.bus_putchar1(modus)
  len := strsize(stradr)
  ios.bus_putchar1(len)
  repeat i from 0 to len - 1
    ios.bus_putchar1(byte[stradr++])
  err := ios.bus_getchar1

pri m_sdclose:err                                       'sd-card: datei schließen
''funktionsgruppe               : sdcard
''funktion                      : die aktuell geöffnete datei schließen
''busprotokoll                  : [005][get.error]
''                              : error - fehlernummer entspr. list

  ios.bus_putchar1(mgc#adm_sd_close)
  err := ios.bus_getchar1

pri m_sdgetc: char                                      'sd-card: zeichen aus datei lesen
''funktionsgruppe               : sdcard
''funktion                      : zeichen aus datei lesen
''busprotokoll                  : [006][get.char]
''                              : char - gelesenes zeichen

  ios.bus_putchar1(mgc#adm_sd_getc)
  char := ios.bus_getchar1

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
