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
Name            : sfxtool
Chip            : Regnatix
Typ             : Programm
Version         : 00
Subversion      : 01

Funktion        : Einfaches Tool um interaktiv HSS-Soundeffekte zu erstellen und als Spin-Quelltext
                  zu exportieren.

Logbuch         :

19-04-2010-dr235  - erste version

Kommandoliste   :

sfx-struktur:

wav len freq vol      grundschwingung 
lfo lfw fma ama       modulation
att dec sus rel       hüllkurve
seq                   (optional)

wav                   wellenform
 0   sinus (0..500hz)
 1   schneller sinus (0..1khz)
 2   dreieck (0..500hz)
 3   rechteck (0..1khz)
 4   schnelles rechteck (0..4khz)
 5   impulse (0..1,333hz)
 6   rauschen
len                   tonlänge $0..$fe, $ff endlos
freq                  frequenz $00..$ff
vol                   lautstärke $00..$0f

lfo                   low frequency oscillator $ff..$01
lfw                   low frequency waveform
 $00   sinus (0..8hz)
 $01   fast sine (0..16hz)
 $02   ramp up (0..8hz)
 $03   ramp down (0..8hz)
 $04   square (0..32hz)
 $05   random
 $ff   sequencer data
fma                    frequency modulation amount
 $00   no modulation
 $01..$ff
ama                    amplitude modulation amount
 $00   no modulation
 $01..$ff
att                    attack $00..$ff
dec                    decay $00..$ff
sus                    sustain $00..$ff
rel                    release $00..$ff


     
}}

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OBJ
        ios: "reg-ios"
        num: "glob-numbers"
        str: "glob-string"

CON

TIBLEN  = 32
FNLEN   = 12

VAR

  byte tib[TIBLEN]           'tastatur-input-buffer
  byte rows                     'aktuelle anzahl der nutzbaren zeilen
  byte cols                     'aktuelle Anzahl der nutzbaren spalten
  byte vidmod

PUB main | a,b,c,key,n

  ios.start
  rows := 23                                            'zeilenzahl temp. setzen
  cols := 64
  screeninit(@prompt1,4)
  repeat
    ios.sfx_setslot(@fx_puffer,15)
    ios.sfx_fire(15,1)
    printfx(@fx_puffer)
    key := ios.keywait
    case key
      "1":
            ios.printchar($0d)
            ios.print(string("Basisschwingung Waveform (0..6): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer] := n
      "2":
            ios.printchar($0d)
            ios.print(string("Basisschwingung Länge (0..FE, FF endlos):"))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+1] := n
      "3":
            ios.printchar($0d)
            ios.print(string("Basisschwingung Frequenz (0..FF): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+2] := n
      "4":
            ios.printchar($0d)
            ios.print(string("Basisschwingung Volume (0..F): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+3] := n
      "5":
            ios.printchar($0d)
            ios.print(string("Modulation LFO (Speed 01..FF): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+4] := n
      "6":
            ios.printchar($0d)
            ios.print(string("Modulation LFW (Waveform 0..5): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+5] := n
      "7":
            ios.printchar($0d)
            ios.print(string("Modulation FMa (Stärke der FM 0 - off, 01..FF, 01 - MAX): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+6] := n
      "8":
            ios.printchar($0d)
            ios.print(string("Modulation AMa (Stärke der AM 0 - off, 01..FF, 01 - MAX): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+7] := n
      "9":
            ios.printchar($0d)
            ios.print(string("Hüllkurve Attack - Anstieg (0 - off, 1..FF, 1 - lansamster Anstieg): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+8] := n
      "a":
            ios.printchar($0d)
            ios.print(string("Hüllkurve Decay - Abfall (0 - off, 1..FF, 1 - lansamster Abfall): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+9] := n
      "b":
            ios.printchar($0d)
            ios.print(string("Hüllkurve Sustain - Halten Volume (0 - Mute, 1..FF, 1 - Leise): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+10] := n
      "c":
            ios.printchar($0d)
            ios.print(string("Hüllkurve Release - Freigabe (0 - off, 1..FF, 1 - Langsamste Freigabe): "))
            ios.input(@tib,TIBLEN)
            n := num.FromStr(@tib,num#HEX)
            byte[@fx_puffer+11] := n
      "m":
            menu2
            screeninit(@prompt1,4)
   
pri screeninit(stradr,n)

  os_testvideo
  ios.windefine(1,0,0,cols,n)
  ios.winset(1)
  ios.printcls
  ios.print(stradr)
  ios.windefine(2,0,n+1,cols,rows)
  ios.winset(2)
  ios.printcls

pri os_testvideo                                        'sys: passt div. variablen an videomodus an

  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen

pub menu2 | key,a
  screeninit(@prompt2,4)
  key := ios.keywait
  case key
    "s": save
    "l": load
    "e": export
    "r": menu3
    "q": ios.winset(0)
         ios.screeninit
         ios.stop

pub save|i

  ios.printnl
  ios.print(string("Effekt speichern - Dateiname : "))
  ios.input(@tib,FNLEN)
  printerr(ios.sdnewfile(@tib))
  ifnot printerr(ios.sdopen("W",@tib))
    i := 0
    repeat 32
      ios.sdputc(byte[@fx_puffer + i++])
    ios.sdclose
  
pub load|i

  cmd_dir
  ios.printnl
  ios.print(string("Effekt laden - Dateiname : "))
  ios.input(@tib,FNLEN)
  ifnot printerr(ios.sdopen("R",@tib))
    i := 0
    repeat 32
      byte[@fx_puffer + i++] := ios.sdgetc
    ios.sdclose

pub export | i

  ios.printnl
  ios.print(string("Effekt exportieren - Dateiname : "))
  ios.input(@tib,FNLEN)
  printerr(ios.sdnewfile(@tib))
  ifnot printerr(ios.sdopen("W",@tib))
    ios.print(string(" Name : "))
    ios.input(@tib,FNLEN)
    sd_print(@tib)
    sd_printchar($0d)
    i := 0
    sd_print(string("'    Wav Len Fre Vol LFO LFW FMa AMa Att Dec Sus Rel"))          
    sd_printchar($0d)
    sd_print(string("byte "))
    sd_printchar("$")
    sd_printhex(byte[@fx_puffer + i++],2)
    repeat 11
      sd_printchar(",")
      sd_printchar("$")
      sd_printhex(byte[@fx_puffer + i++],2)
    sd_printchar($0d)
    sd_print(string("byte "))
    sd_printchar("$")
    sd_printhex(byte[@fx_puffer + i++],2)
    repeat 20
      sd_printchar(",")
      sd_printchar("$")
      sd_printhex(byte[@fx_puffer + i++],2)
    ios.sdclose
    
pub menu3 | key,a,n,c,w
    
  screeninit(@prompt3,4)
  w := 0
  c := 32
  repeat
    key := ios.keywait
    case key
      "r":
         repeat c
           a?
           a := a & $FF
           byte[@fx_puffer+2] := a
           ios.sfx_setslot(@fx_puffer,15)
           ios.sfx_fire(15,1)
           printfx(@fx_puffer)
           if w > 0
             waitcnt(clkfreq / w + cnt)
      "c":
            ios.printchar($0d)
            ios.print(string("Anzahl = "))
            ios.printdec(c)
            ios.print(string(" : "))
            ios.input(@tib,TIBLEN)
            c := num.FromStr(@tib,num#DEC)
            ios.print(string(" ok",$0d))
      "w":
            ios.printchar($0d)
            ios.print(string("Wait = "))
            ios.printdec(w)
            ios.print(string(" : "))
            ios.input(@tib,TIBLEN)
            w := num.FromStr(@tib,num#DEC)
            ios.print(string(" ok",$0d))
      "b": quit
    
pub printfx(adr)| i,a
  ios.printchar(ios#char_nl)
  repeat i from 0 to 11
    a := byte[adr+i]
    ios.print(string("$"))
    ios.printhex(a,2)
    ios.print(string("  "))
    
PUB printerr(err):error                                 'sys: fehlerausgabe

  if err
    ios.printnl
    ios.print(@err_s1)
    ios.printdec(err)
    ios.print(string(" : $"))
    ios.printhex(err,2)
    ios.printnl
    ios.print(@err_s2)
    case err
      0: ios.print(@err0)
      1: ios.print(@err1)
      2: ios.print(@err2)
      3: ios.print(@err3)
      4: ios.print(@err4)
      5: ios.print(@err5)
      6: ios.print(@err6)
      7: ios.print(@err7)
      8: ios.print(@err8)
      9: ios.print(@err9)
      10: ios.print(@err10)
      11: ios.print(@err11)
      12: ios.print(@err12)
      13: ios.print(@err13)
      14: ios.print(@err14)
      15: ios.print(@err15)
      16: ios.print(@err16)
      17: ios.print(@err17)
      18: ios.print(@err18)
      19: ios.print(@err19)
      20: ios.print(@err20)
      OTHER: ios.print(@errx)
    ios.printnl
    ios.print(string("<Taste>"))
    ios.keywait
  error := err
  
PUB cmd_dir|fcnt,stradr,hflag                           'cmd: verzeichnis anzeigen
{{sddir - anzeige verzeichnis}}

    ifnot printerr(ios.sddir)                           'verzeichnis öffnen
        fcnt := cmd_dir_w(hflag)

PRI cmd_dir_w(hflag):fcnt|stradr,lcnt,wcnt

    fcnt := 0
    wcnt := (cols / 14) - 1 '3
    lcnt := (rows - 2) * (cols / 15)
    ios.printnl
    repeat while (stradr := ios.sdnext)
       ifnot ios.sdfattrib(ios#F_HIDDEN) & hflag                                'versteckte dateien anzeigen?
         if ios.sdfattrib(ios#F_DIR)                                            'verzeichnisname
           ios.setcolor(1)
           ios.printqchar("▶")
           ios.printchar(" ")
           ios.print(stradr)
           ios.setcolor(0)
         elseif ios.sdfattrib(ios#F_HIDDEN)
           ios.setcolor(3)
           ios.print(string("  "))
           str.charactersToLowerCase(stradr)
           ios.print(stradr)
           ios.setcolor(0)
         else                                                                   'dateiname
           ios.print(string("  "))
           str.charactersToLowerCase(stradr)
           ios.print(stradr)
         ifnot wcnt--
           wcnt := (cols / 15) - 1 '3
           ios.printnl
         else
           'ios.printtab
         fcnt++
         ifnot --lcnt
           lcnt := (rows - 2) * (cols / 15)
           if ios.keywait == "q"
             return

PRI str_lowercase(characters)

  repeat strsize(characters--)
    result := byte[++characters]
    if((result => "A") and (result =< "Z"))
      byte[characters] := (result + 32)

PUB sd_print(stringptr)                                 'screen: bildschirmausgabe einer zeichenkette (0-terminiert)
{{print(stringptr) - screen: bildschirmausgabe einer zeichenkette (0-terminiert)}}
  repeat strsize(stringptr)
    ios.sdputc(byte[stringptr++])

PUB sd_printdec(value) | i                              'screen: dezimalen zahlenwert auf bildschirm ausgeben
{{printdec(value) - screen: dezimale bildschirmausgabe zahlenwertes}}
  if value < 0                                          'negativer zahlenwert
    -value
    ios.sdputc("-")
  i := 1_000_000_000
  repeat 10                                             'zahl zerlegen
    if value => i
      ios.sdputc(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      ios.sdputc("0")
    i /= 10                                             'nächste stelle

PUB sd_printhex(value, digits)                          'screen: hexadezimalen zahlenwert auf bildschirm ausgeben
{{hex(value,digits) - screen: hexadezimale bildschirmausgabe eines zahlenwertes}}
  value <<= (8 - digits) << 2
  repeat digits
    ios.sdputc(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB sd_printchar(c):c2                                  'screen: einzelnes zeichen auf bildschirm ausgeben
{{printchar(c) - screen: bildschirmausgabe eines zeichens}}
  ios.sdputc(c)
  c2 := c

DAT

prompt1 byte      "▶Hive: SFX-Tool"
        byte  $0d,"Basisschwingung     Modulation          Hüllkurve         "
        byte  $0d,"Wav  Len  Fre  Vol  LFO  LFW  FMa  AMa  Att  Dec  Sus  Rel"
        byte  $0d,"[01] [02] [03] [04] [05] [06] [07] [08] [09] [0A] [0B] [0C] [M] ",$0

prompt2 byte      "▶SFX-Tool - Menü"
        byte  $0d," "
        byte  $0d," "
        byte  $0d,"[S]ave [L]oad [E]xport [R]and [Q]uit",$0

prompt3 byte      "▶SFX-Tool - Random Freq"
        byte  $0d," "
        byte  $0d," "
        byte  $0d,"[R]un [C]ount [W]ait [B]ack",$0

mod1    byte "bd1.hss ",0
mod2    byte "bd2.hss ",0

err_s1  byte "Fehlernummer : ",0
err_s2  byte "Fehler       : ",0

err0    byte "no error",0
err1    byte "fsys unmounted",0
err2    byte "fsys corrupted",0
err3    byte "fsys unsupported",0
err4    byte "not found",0
err5    byte "file not found",0
err6    byte "dir not found",0
err7    byte "file read only",0
err8    byte "end of file",0
err9    byte "end of directory",0
err10   byte "end of root",0
err11   byte "dir is full",0
err12   byte "dir is not empty",0
err13   byte "checksum error",0
err14   byte "reboot error",0
err15   byte "bpb corrupt",0
err16   byte "fsi corrupt",0
err17   byte "dir already exist",0
err18   byte "file already exist",0
err19   byte "out of disk free space",0
err20   byte "disk io error",0
err21   byte "command not found",0
errx    byte "undefined",0


                               'basisschwingung     modulation          hüllkurve
                               'Wav  Len  Fre  Vol  LFO  LFW  FMa  AMa  Att  Dec  Sus  Rel
fx_puffer               byte    $01, $01, $80, $0F, $00, $00, $00, $00, $FF, $00, $00, $80              
                        byte    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

                                


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
