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
Name            : blexbus-tool
Chip            : Regnatix
Typ             : Programm
Version         :
Subversion      :

Logbuch         :

31-10-2013-dr235  - erste version

Kommandoliste:

Notizen:



}}

OBJ
        ios: "reg-ios"
        num: "glob-numbers"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OS_TIBLEN       = 64                                    'gr??e des inputbuffers


VAR
'systemvariablen
  byte  tib[OS_TIBLEN]          'tastatur-input-buffer
  byte  cmdstr[OS_TIBLEN]       'kommandostring f?r interpreter
  byte  token1[OS_TIBLEN]       'parameterstring 1 für interpreter
  byte  token2[OS_TIBLEN]       'parameterstring 2 für interpreter
  byte  tibpos                  'aktuelle position im tib
  long  ppos                    'puffer für adresse
  long  pcnt                    'puffer für zeilenzahl

  byte  device                  'adresse des geöffneten devices
  byte  polling                 'status polling
  byte  open                    'status device

PUB main | wflag

  ios.start                                             'ios initialisieren
  polling := 1
  ios.plxRun
  ios.printnl

'  ios.print(string("Perplex - PlexBus-Tool - DR235",$0d,$0d))

  repeat
    os_cmdinput                                         'kommandoeingabe
    os_cmdint                                           'kommandozeileninterpreter
  
PUB os_cmdinput | charc                                 'sys: stringeingabe eine zeile
''funktionsgruppe               : sys
''funktion                      : stringeingabe eine zeile
''eingabe                       : -
''ausgabe                       : -
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

  ios.print(@prompt2)
  tibpos := 0                                           'tibposition auf anfang setzen
  repeat until (charc := ios.keywait) == $0D            'tasten einlesen bis return
    if (tibpos + 1) < OS_TIBLEN                         'zeile noch nicht zu lang?
      case charc
        ios#CHAR_BS:                                    'backspace
          if tibpos > 0                                 'noch nicht anfang der zeile erreeicht?
            tib[tibpos--] := 0                          'ein zeichen aus puffer entfernen
            ios.printbs                                 'backspace an terminal senden
        other:                                          'zeicheneingabe
          tib[tibpos++] := charc                        'zeichen speichern
          ios.printchar(charc)                          'zeichen ausgeben
  ios.printnl
  tib[tibpos] := 0                                      'string abschließen
  tibpos := charc := 0                                  'werte rücksetzen

PUB os_nxtoken1: stradr                                 'sys: token 1 von tib einlesen
''funktionsgruppe               : sys
''funktion                      : nächsten token im eingabestring suchen und stringzeiger übergeben
''eingabe                       : -
''ausgabe                       : stradr  - adresse auf einen string mit dem gefundenen token
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib
''                              : token   - tokenstring

  stradr := os_tokenize(@token1)

PUB os_nxtoken2: stradr                                 'sys: token 2 von tib einlesen
''funktionsgruppe               : sys
''funktion                      : nächsten token im eingabestring suchen und stringzeiger übergeben
''eingabe                       : -
''ausgabe                       : stradr  - adresse auf einen string mit dem gefundenen token
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib
''                              : token   - tokenstring

  stradr := os_tokenize(@token2)

PUB os_tokenize(token):stradr | i                       'sys: liest nächsten token aus tib

  i := 0
  if tib[tibpos] <> 0                                   'abbruch bei leerem string
    repeat until tib[tibpos] > ios#CHAR_SPACE           'führende leerzeichen ausbenden
      tibpos++
    repeat until (tib[tibpos] == ios#CHAR_SPACE) or (tib[tibpos] == 0) 'wiederholen bis leerzeichen oder stringende
      byte[token][i] := tib[tibpos]
      tibpos++
      i++
  else
    token := 0
  byte[token][i] := 0
  stradr := token

PUB os_nextpos: tibpos2                                 'sys: setzt zeiger auf nächste position
''funktionsgruppe               : sys
''funktion                      : tibpos auf nächstes token setzen
''eingabe                       : -
''ausgabe                       : tibpos2 - position des nächsten tokens in tib
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

  if tib[tibpos] <> 0
    repeat until tib[tibpos] > ios#CHAR_SPACE               'führende leerzeichen ausbenden
      tibpos++
  return tibpos

PUB os_cmdint                                           'sys: kommandointerpreter
''funktionsgruppe               : sys
''funktion                      : kommandointerpreter; zeichenkette ab tibpos wird als kommando interpretiert
''                              : tibpos wird auf position hinter token gesetzt
''eingabe                       : -
''ausgabe                       : -
''variablen                     : tib     - eingabepuffer zur string
''                              : tibpos  - aktuelle position im tib

  repeat                                                'kommandostring kopieren
    cmdstr[tibpos] := tib[tibpos]
    tibpos++
  until (tib[tibpos] == ios#CHAR_SPACE) or (tib[tibpos] == 0) 'wiederholen bis leerzeichen oder stringende
  cmdstr[tibpos] := 0                                   'kommandostring abschließen
  os_cmdexec(@cmdstr)                                   'interpreter aufrufen
  tibpos := 0                                           'tastaturpuffer zurücksetzen
  tib[0] := 0

PUB os_cmdexec(stradr)                                  'sys: kommando im ?bergebenen string wird als kommando interpretiert
{{os_smdexec - das kommando im ?bergebenen string wird als kommando interpretiert
  stradr: adresse einer stringvariable die ein kommando enth?lt}}
  if strcomp(stradr,string("help"))                     'help
    ios.print(@help1)
  elseif strcomp(stradr,string("open"))
    plx_open
  elseif strcomp(stradr,string("close"))
    plx_close
  elseif strcomp(stradr,string("put"))
    plx_put
  elseif strcomp(stradr,string("get"))
    plx_get
  elseif strcomp(stradr,string("map"))
    plx_map
  elseif strcomp(stradr,string("scan"))
    plx_scan
  elseif strcomp(stradr,string("test"))
    plx_test
  elseif strcomp(stradr,string("test#"))
    plx_testnr
  elseif strcomp(stradr,string("game"))
    plx_game
  elseif strcomp(stradr,string("setgame"))
    plx_setgame
  elseif strcomp(stradr,string("polloff"))
    plx_polloff
  elseif strcomp(stradr,string("pollon"))
    plx_pollon
  elseif strcomp(stradr,string("debug"))
    plx_debug
  elseif strcomp(stradr,string("status"))
    plx_status
  elseif strcomp(stradr,string("plexuswr"))
    plx_plexuswr
  elseif strcomp(stradr,string("bye"))
    ios.stop
  else                                                  'kommando nicht gefunden
      ios.print(stradr)
      ios.print(@prompt3)
      ios.printnl

PRI plx_debug|wert,i

'  ios.plxOut($22,cnt)

' irgendwie funktionieren die direkten i2c-operationen noch nicht
' von administra aus funktioniert das gleiche konstrukt
' ???

  ios.plxHalt
  repeat
    ios.plxStart
    ios.plxWrite($22 << 1)
    ios.plxWrite(i++)
    ios.plxStop
    waitcnt(cnt+clkfreq/3)
    ios.printhex(i,2)
    ios.printchar(" ")

PRI plx_plexuswr|regadr,regval

  device  := num.FromStr(os_nxtoken1,num#HEX)
  regadr  := num.FromStr(os_nxtoken1,num#HEX)
  regval  := num.FromStr(os_nxtoken1,num#HEX)

  ios.plxHalt
  waitcnt(cnt+clkfreq)

  ios.plxStart
  ios.plxWrite(device << 1)
  ios.plxWrite(regadr)
  ios.plxWrite(regval)
  ios.plxStop

  waitcnt(cnt+clkfreq)
  ios.plxRun

PRI plx_status

  ios.printnl
  ios.print(string("Device  : "))
  ios.printhex(device,2)
  if open
    ios.print(string(" open"))
  else
    ios.print(string(" close"))
  ios.printnl
  ios.print(string("Polling : "))
  if polling
    ios.print(string("ON"))
  else
    ios.print(string("OFF"))
  ios.printnl
  ios.printnl


PRI plx_polloff

  ios.plxHalt
  ios.print(string("Poller wurde angehalten!",$0d))
  polling := 0

PRI plx_pollon

  ios.plxRun
  ios.print(string("Poller wurde gestartet!",$0d))
  polling := 1
  open := 0

PRI plx_game|dev,i

  i := 0
  ios.curoff
  ios.printcls
  repeat
    dev := ios.pad
    ios.curhome
    ios.printnl
    ios.print(string("Scan  : "))
    ios.printdec(i++)
    ios.printnl
    ios.print(string("Input : ["))
    ios.printbin(dev,24)
    ios.printchar("]")
    ios.printnl
    ios.printnl
    print_joystick(dev >> 16 & $FF)
    ios.printnl
    print_paddle(0,dev >> 8 & $FF)
    print_paddle(1,dev & $FF)
  until ios.key
  ios.printnl
  ios.curon

PRI plx_setgame|adradda,adrport

  adradda := num.FromStr(os_nxtoken1,num#HEX)
  adrport := num.FromStr(os_nxtoken1,num#HEX)
  ios.plxsetadr(adradda,adrport)

PRI plx_test

  testsepia($48,$20)

PRI plx_testnr|adradda,adrport

  adradda := num.FromStr(os_nxtoken1,num#HEX)
  adrport := num.FromStr(os_nxtoken1,num#HEX)
  testsepia(adradda,adrport)

PRI plx_map|ack,adr,n,i

  ios.plxHalt
  n := 0
  i := 0
  ios.curoff
  ios.printcls
  repeat
    ios.curhome
    ios.printnl
    ios.print(string("   0123456789ABCDEF"))
    ios.printnl
    repeat adr from 0 to 127

      ack := ios.plxping(adr)
      if n == 0
        ios.printhex(adr,2)
        ios.printchar(" ")
      if ack
        ios.printqchar("┼")
      else
        ios.printqchar("•")
      if n++ == 15
        ios.printnl
        n := 0
    ios.printnl
    ios.print(string("Scan : "))
    ios.printdec(i++)
  until ios.key
  ios.printnl
  ios.curon
  ios.plxRun

PRI plx_scan|ack,adr

  ios.plxHalt
  ios.printnl
  repeat adr from 0 to 127
    ack := ios.plxping(adr)
    ifnot ack
      ios.print(string("Ping : $"))
      ios.printhex(adr,2)
      ios.print(string(" : "))
      ios.printdec(adr)
      ios.printnl
  ios.printnl
  ios.plxRun

PRI plx_open|ack

  device  := num.FromStr(os_nxtoken1,num#HEX)
  ios.plxHalt
  ios.plxStart
  ifnot ios.plxWrite(device << 1)
    ios.print(string("Device geöffnet, Polling aus!"))
    polling := 0
    open := 1
  else
    ios.print(string("Device nicht vorhanden!"))
    ios.plxRun
    polling := 1
    open := 0
  ios.printnl

PRI plx_close

  ios.plxRun
  ios.print(string("Device geschlossen, Polling an!"))
  ios.printnl
  polling := 1
  open := 0

PRI plx_put|wert

  if open
    wert := num.FromStr(os_nxtoken1,num#HEX)
    ios.plxOut(device,wert)
  else
    ios.print(string("Kein Device geöffnet!"))
    ios.printnl

PRI plx_get

  if open
    ios.print(string("Get : "))
    ios.printhex(ios.plxIn(device),2)
    ios.printnl
  else
    ios.print(string("Kein Device geöffnet!"))
    ios.printnl

PRI print_chan(cnr,wert)

  ios.print(string("A/D "))
  ios.printdec(cnr)
  ios.printchar(" ")
  ios.printhex(wert,2)
  ios.printchar(" ")
  ios.printchar("[")
  repeat wert>>3
    ios.printqchar("‣")
  repeat (255-wert)>>3
    ios.printqchar(" ")
  ios.printchar("]")
  ios.printnl

PRI print_port(pnr,wert)

  ios.print(string("Port "))
  ios.printdec(pnr)
  ios.print(string("   ["))

  repeat 8
    if wert & 1
      ios.printqchar("‣")
    else
      ios.printqchar(" ")
    wert := wert >> 1
  ios.printchar("]")
  ios.printnl

PRI print_paddle(cnr,wert)

  ios.print(string("Paddle "))
  ios.printdec(cnr)
  ios.printchar(" ")
  ios.printhex(wert,2)
  ios.printchar(" ")
  ios.printchar("[")
  repeat wert>>3
    ios.printqchar("‣")
  repeat (255-wert)>>3
    ios.printqchar(" ")
  ios.printchar("]")
  ios.printnl

PRI print_joystick(wert)

  ios.print(string("Joystick "))
  ios.print(string("   ["))

  repeat 8
    if wert & 1
      ios.printqchar("‣")
    else
      ios.printqchar(" ")
    wert := wert >> 1
  ios.printchar("]")
  ios.printnl

PRI testsepia(adda,port)

  ios.plxHalt
  ios.curoff
  ios.printcls
  repeat
    ios.curhome
    ios.printnl
    print_port(1,ios.plxIn(port  ))
    print_port(2,ios.plxIn(port+1))
    print_port(3,ios.plxIn(port+2))
    ios.printnl
    print_chan(0,ios.plxch(adda,0))
    print_chan(1,ios.plxch(adda,1))
    print_chan(2,ios.plxch(adda,2))
    print_chan(3,ios.plxch(adda,3))
    ios.plxout(port+2,!(cnt>>23))
  until ios.key
  ios.printnl
  ios.curon
  ios.plxRun


DAT
prompt1       byte  "ok ", $0d, 0
prompt2       byte  "plx: ", 0
prompt3       byte  "? ",0
wait1         byte  "<WEITER? */q:>",0

help1         file  "perplex.txt"
              byte   $0d,0



