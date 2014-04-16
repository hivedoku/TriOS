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
Name            : Hallo Hive!
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
        str: "glob-string"

VAR

  byte parastr[64]
  byte rows                     'aktuelle anzahl der nutzbaren zeilen
  byte cols                     'aktuelle Anzahl der nutzbaren spalten
  byte vidmod                   'videomodus: 0 - vga, 1 -  tv

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

PUB main | i,n,len,ch,lch

  n := 1
  lch := 0
  ios.start
  ios.parastart
  ios.paranext(@parastr)
  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen
  len := strsize(@parastr)
  ios.sddmset(ios#DM_USER)                              'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                            's-marker aktivieren
  repeat i from 0 to 3                                  'extender anhängen
    byte[@parastr][len + i] := byte[@ext1][i]
  byte[@parastr][len + i] := 0
  ifnot ios.sdopen("r",@parastr)
    repeat                                              'text ausgeben
      ch := ios.sdgetc
      if ch == ios#CHAR_NL OR ch == $0a                 'CR or NL
        if ch == lch OR (lch <> ios#CHAR_NL AND lch <> $0a)
          ios.printnl
          lch := ch
          if ++n == (rows - 2)
            n := 1
            if ios.keywait == "q"
              ios.sdclose
              ios.sddmact(ios#DM_USER)                  'u-marker aktivieren
              ios.stop
        else
          lch := 0
      else
        ios.printchar(ch)
        lch := ch
    until ios.sdeof                                     'ausgabe bis eof
  else
    'ios.print(string("Hilfetexte : ",$0d))
    cmd_dir_w(1)
  ios.sdclose                                           'datei schließen
  ios.sddmact(ios#DM_USER)                              'u-marker aktivieren
  ios.stop

PRI cmd_dir_w(hflag):fcnt|stradr,lcnt,wcnt,len,i,j

    fcnt := 0
    wcnt := (cols / 9) - 1 '3
    lcnt := (rows - 2) * (cols / 15)
    ios.printnl
    repeat while (stradr := ios.sdnext)
       len := strsize(stradr)

       i := j := 0
       repeat until byte[stradr + i] == "."             'extender finden
         i++
       repeat until byte[stradr + i + j] == " "         'endesuchen/terminieren
         j++
       byte[stradr + i + j] := 0
{
       ios.print(stradr)
       ios.print(stradr+i)
       ios.print(@ext1)
       ios.printdec(i)
       ios.printdec(strcomp(@ext1,(stradr+i)))
       ios.printnl
}
       if strcomp(@ext1,(stradr+i))
         ios.print(string("  "))
         str.charactersToLowerCase(stradr)
         byte[stradr + i] := 0                          'extender abtrennen
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


DAT

ext1          byte  ".MAN",0


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
