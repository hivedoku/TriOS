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
Name            : ramtest
Chip            : Regnatix
Typ             : Programm
Version         :
Subversion      :
Funktion        : Testroutinen für die externen RAM-Bänke
Komponenten     :
COG's           :
Logbuch         :
Kommandoliste   :
Notizen         :

}}

OBJ
        ios: "reg-ios"
        
CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000


VAR

word    cnt_err                 'gesamtzähler
word    cnt_test1
word    cnt_test2
word    cnt_test3
word    cnt_testx
word    cnt_loop



PUB main | tast

  ios.start
  'ios.startram                                         'nur für test im ram
  ios.print(string("RAMTest - 10-06-2010-dr235"))
  ios.printnl
  ios.print(string("ACHTUNG: Endlostest - Alle Daten im eRam werden komplett überschrieben!"))
  ios.printnl
  ios.print(string("Eingabe */<a>bbruch : "))
  tast := ios.keywait
  repeat
    if tast <> "a"
      statistik
      ramtest1                                          '1:1 random                                        
      statistik
      ramtestx(0)                                       '1:1, 0                                               
      statistik
      ramtestx($FF)                                     '1:1, 255                                          
      statistik
      ramtestx($55)                                     '1:1, $55                                          
      statistik
      ramtestx($AA)                                     '1:1, $AA                                          
      statistik
      ramtest2                                          'test adresskontinuität
      statistik                                       
      ramtest3                                          '1:1 negierte bänke
      statistik                                       

'  ios.printnl
'  ios.print(string("Fertig. "))
'  ios.stop

PUB statistik                                           'ausgabe der fehlerstatistik

  cnt_err := cnt_err + cnt_test1 + cnt_test2 + cnt_test3 + cnt_testx
  ios.setcolor(0)
  ios.printcls
  ios.printnl
  ios.print(string("Statistik eRAM-Test:", $0d, $0d))
  ios.print(string("Testdurchläufe                  : "))
  ios.printdec(cnt_loop)
  ios.printnl
  ios.printnl
  ios.setcolor(4)
  ios.print(string("Fehler Gesamt                   : "))
  ios.printdec(cnt_err)
  ios.printnl
  ios.print(string("Fehler Test 1:1, Random         : "))
  ios.printdec(cnt_test1)
  ios.printnl
  ios.print(string("Fehler Test Adresskontinuität   : "))
  ios.printdec(cnt_test2)
  ios.printnl
  ios.print(string("Fehler Test 1:1, Negierte Bänke : "))
  ios.printdec(cnt_test3)
  ios.printnl
  ios.print(string("Fehler Test Div. Testmuster     : "))
  ios.printdec(cnt_testx)
  ios.printnl
  ios.printnl
  cnt_test1 := 0
  cnt_test2 := 0
  cnt_test3 := 0
  cnt_testx := 0
  cnt_loop++
  ios.setcolor(0)

PUB ramtest1 | adr,wert1,a
{{ramtest2 - zufallswerte werden gleichzeitig in beide rambänke geschrieben und im zweiten
schritt miteinander verglichen}}
  ios.print(string("RAMTest - 1:1 Random",$0D))
  ios.print(string("Speicher beschreiben...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    wert1?
    ram_write1(wert1,adr)
    ram_write2(wert1,adr)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d,"Speicher vergleichen...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    if ram_read1(adr) <> ram_read2(adr)
      ios.setcolor(3)
      ios.printchar($0d)
      ios.print(string("Ramfehler : "))
      ios.printhex(adr,6)
      ios.printchar(":")
      ios.printhex(ram_read1(adr),2)
      ios.printchar(":")
      ios.printhex(ram_read2(adr),2)
      ios.printchar(" ")
      ios.sfx_fire($f3,0)
      cnt_test1++
      ios.setcolor(0)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d))

PUB ramtest2 | adr,wert1,a
{{ramtest2 - adresswert wird long in den speicher geschrieben und verglichen}}
  ios.print(string("RAMTest - Test Adresskontinuität",$0D))
  ios.print(string("Speicher beschreiben...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat (ios#ERAM)/4
    ios.ram_wrlong(ios#sysmod,adr,adr)
    if a == ios#ERAM/64
      a := 1
      ios.printhex(adr,6)
      ios.printchar("-")
    else
      a++  
    adr := adr + 4
  ios.print(string("ok",$0d,"Speicher vergleichen...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat (ios#ERAM)/4
    if ios.ram_rdlong(ios#sysmod,adr) <> adr
      ios.setcolor(3)
      ios.printchar($0d)
      ios.print(string("Ramfehler : "))
      ios.printhex(adr,8)
      ios.printchar(":")
      ios.printhex(ios.ram_rdlong(ios#sysmod,adr),8)
      ios.printchar(" ")
      ios.sfx_fire($f3,0)
      cnt_test2++
      ios.setcolor(0)
    if a == ios#ERAM/64
      a := 1
      ios.printhex(adr,6)
      ios.printchar("-")
    else
      a++  
    adr := adr + 4
  ios.print(string("ok",$0d))


PUB ramtest3 | adr,wert1,wert2,a
{{ramtest3 - }}
  ios.print(string("RAMTest - Random/Negierte Bänke",$0D))
  ios.print(string("Speicher beschreiben...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    wert1?
    wert2 := !wert1
    ram_write1(wert1,adr)
    ram_write2(wert2,adr)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d,"Speicher vergleichen...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    wert1 := ram_read1(adr)
    wert2 := !ram_read2(adr) & $0ff
    if wert1 <> wert2
      ios.setcolor(3)
      ios.printchar($0d)
      ios.print(string("Ramfehler : "))
      ios.printhex(adr,6)
      ios.printchar(":")
      ios.printhex(wert1,2)
      ios.printchar(":")
      ios.printhex(wert2,2)
      ios.printchar(" ")
      ios.sfx_fire($f3,0)
      cnt_test3++
      ios.setcolor(0)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d))

PUB ramtestx(wert) | adr,a
{{ramtest2 - zufallswerte werden gleichzeitig in beide ramb?nke geschrieben und im zweiten
schritt miteinander verglichen}}
  ios.print(string("RAMTest - 1:1 Testwert: $"))
  ios.printhex(wert,2)
  ios.printnl
  ios.print(string("Speicher beschreiben...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    ram_write1(wert,adr)
    ram_write2(wert,adr)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d,"Speicher vergleichen...",$0D))
  adr := 0
  a := 0
  ios.printhex(adr,6)
  ios.printchar("-")
  repeat ios#ERAM/2-1
    if ram_read1(adr) <> ram_read2(adr)
      ios.setcolor(3)
      ios.printchar($0d)
      ios.print(string("Ramfehler : "))
      ios.printhex(adr,6)
      ios.printchar(":")
      ios.printhex(ram_read1(adr),2)
      ios.printchar(":")
      ios.printhex(ram_read2(adr),2)
      ios.printchar(" ")
      ios.sfx_fire($f3,0)
      cnt_testx++
      ios.setcolor(0)
    if a++ == (ios#ERAM/2-1)/16
      a := 0
      ios.printhex(adr,6)
      ios.printchar("-")
    adr++
  ios.print(string("ok",$0d))

PUB ram_read1(adresse):wert
{{ein byte aus rambank1 lesen}}
      outa[15..8] := adresse >> 11        'höherwertige adresse setzen
      set_latch
      outa[18..8] := adresse              'niederwertige adresse setzen
      outa[ios#reg_ram1] := 0             'ram1 selektieren (wert wird geschrieben)
      wert := ina[7..0]                   'speicherzelle einlesen
      outa[ios#reg_ram1] := 1             'ram1 deselektieren

PUB ram_read2(adresse):wert
{{ein byte aus rambank2 lesen}}
      outa[15..8] := adresse >> 11        'höherwertige adresse setzen
      set_latch
      outa[18..8] := adresse              'niederwertige adresse setzen
      outa[ios#reg_ram2] := 0             'ram2 selektieren (wert wird geschrieben)
      wert := ina[7..0]                   'speicherzelle einlesen
      outa[ios#reg_ram2] := 1             'ram2 deselektieren

PUB ram_write1(wert,adresse)
{{ein byte in rambank1 schreiben}}
    outa[ios#bus_wr] := 0                 'schreiben aktivieren
    dira := ios#db_out                    'datenbus --> ausgang
    outa[7..0] := wert                    'wert --> datenbus
    outa[15..8] := adresse >> 11          'höherwertige adresse setzen
    set_latch
    outa[18..8] := adresse                'niederwertige adresse setzen
    outa[ios#reg_ram1] := 0               'ram1 selektieren (wert wird geschrieben)
    outa[ios#reg_ram1] := 1               'ram1 deselektieren
    dira := ios#db_in                     'datenbus --> eingang
    outa[ios#bus_wr] := 1                 'schreiben deaktivieren

PUB ram_write2(wert,adresse)
{{ein byte in rambank2 schreiben}}
    outa[ios#bus_wr] := 0                 'schreiben aktivieren
    dira := ios#db_out                    'datenbus --> ausgang
    outa[7..0] := wert                    'wert --> datenbus
    outa[15..8] := adresse >> 11          'höherwertige adresse setzen
    set_latch
    outa[18..8] := adresse                'niederwertige adresse setzen
    outa[ios#reg_ram2] := 0               'ram2 selektieren (wert wird geschrieben)
    outa[ios#reg_ram2] := 1               'ram2 deselektieren
    dira := ios#db_in                     'datenbus --> eingang
    outa[ios#bus_wr] := 1                 'schreiben deaktivieren
  
PRI set_latch
{{set_latch - übernimmt a0..a7 in adresslatch (obere adresse a11..18)}}
  outa[23] := 1
  outa[23] := 0

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
