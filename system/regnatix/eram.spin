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
Name            : eram-tool
Chip            : Regnatix
Typ             : Programm
Version         :
Subversion      :

Logbuch         :

Kommandoliste:

Notizen:



}}

OBJ
        num: "glob-numbers"
        ios: "reg-ios"
        
CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

OS_TIBLEN       = 64                                    'gr??e des inputbuffers
ERAM            = 1024 * 512 * 2                        'gr??e eram
HRAM            = 1024 * 32                             'gr??e hram

RMON_ZEILEN     = 16                                    'speichermonitor - angezeigte zeilen
RMON_BYTES      = 8                                     'speichermonitor - zeichen pro byte

VAR
'systemvariablen
  byte  tib[OS_TIBLEN]          'tastatur-input-buffer
  byte  cmdstr[OS_TIBLEN]       'kommandostring f?r interpreter
  byte  token1[OS_TIBLEN]       'parameterstring 1 für interpreter
  byte  token2[OS_TIBLEN]       'parameterstring 2 für interpreter
  byte  tibpos                  'aktuelle position im tib
  long  ppos                    'puffer für adresse
  long  pcnt                    'puffer für zeilenzahl

PUB main | wflag

  ios.start                                             'ios initialisieren
'  ios.startram
  ios.printnl
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
            ios.printbs                                 'steuerzeichen an terminal senden
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
    ios.print(string("help: man eram"))
  elseif strcomp(stradr,string("d"))                    'd display - speicheranzeige
    ram_disp
  elseif strcomp(stradr,string("dl"))                   'd display long - speicheranzeige
    ram_displong
  elseif strcomp(stradr,string("n"))                    'n next - anzeige fortsetzen
    ram_next
  elseif strcomp(stradr,string("m"))                    'm modify - speicher modifizieren
    ram_mod
  elseif strcomp(stradr,string("l"))                    'l modify - long
    ram_lmod
  elseif strcomp(stradr,string("info"))
    ram_info
  elseif strcomp(stradr,string("f"))
    ram_fill
  elseif strcomp(stradr,string("fu"))                   'fill im userbereich
    ram_fillusr
  elseif strcomp(stradr,string("rbas"))
    ram_setrbas
  elseif strcomp(stradr,string("sysvar"))
    ram_sysvar
  elseif strcomp(stradr,string("load"))                 'load -
    ram_load
  elseif strcomp(stradr,string("cls"))                  'cls -
    ios.printcls
  elseif strcomp(stradr,string("bye"))                  'bye
    ios.stop
  elseif strcomp(stradr,string("xinit"))                'rdisk initialisieren
    rd_init
  elseif strcomp(stradr,string("xnew"))                 'neue ram-datei erstellen
    rd_new
  elseif strcomp(stradr,string("xhead"))                'header der dateien anzeigen
    rd_header
  elseif strcomp(stradr,string("xdel"))                 'ram-datei löschen
    rd_del
  elseif strcomp(stradr,string("xren"))                 'ram- datei umbenennen
    rd_rename
  elseif strcomp(stradr,string("xdir"))                 'ram-dateien liste anzeigen
    rd_dir
  elseif strcomp(stradr,string("xftab"))                'tabelle geöffnete dateien anzeigen
    rd_ftab
  elseif strcomp(stradr,string("xopen"))                'ram-datei öffnen
    rd_open
  elseif strcomp(stradr,string("xsave"))                'ram-datei auf sd speichern
    rd_save
  elseif strcomp(stradr,string("xclose"))               'ram-datei schliessen
    rd_close
  elseif strcomp(stradr,string("xseek"))                'dateizeiger setzen
    rd_seek
  elseif strcomp(stradr,string("xput"))                 'wert in geöffnete datei schreiben
    rd_put
  elseif strcomp(stradr,string("xget"))                 'wert aus geöffneter datei lesen
    rd_get
  elseif strcomp(stradr,string("xwrite"))               'wert an def. adresse in datei schreiben
    rd_write
  elseif strcomp(stradr,string("xread"))                'wert von def. adresse aus datei lesen
    rd_read
  elseif strcomp(stradr,string("xload"))                'ram-datei von sd laden
    rd_load
  elseif strcomp(stradr,string("xtype"))                'ram-datei (text) ausgeben
    rd_type
  elseif strcomp(stradr,string("debug"))
    debug
  else                                                  'kommando nicht gefunden
      ios.print(stradr)
      ios.print(@prompt3)
      ios.printnl

PRI debug

  ios.rd_init
  ios.rd_newfile(string("d1"),8)
  ios.rd_newfile(string("d2"),8)
  ios.rd_newfile(string("d3"),8)
  ios.rd_newfile(string("d4"),8)
  ios.rd_newfile(string("d5"),8)
  rd_dir


PRI rd_type | stradr,len,fnr                            'rd: text ausgeben

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  fnr := ios.rd_open(stradr)                            'datei öffnen
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ios.rd_seek(fnr,0)
    repeat len
      ios.printchar(ios.rd_get(fnr))
    ios.rd_close(fnr)


PRI rd_load | stradr,len,fnr                            'rd: datei in ramdisk laden

  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  ifnot os_error(ios.sdopen("r",stradr))                'datei öffnen
    len := ios.sdfattrib(ios#F_SIZE)
    ios.rd_newfile(stradr,len)                          'datei erzeugen
    fnr := ios.rd_open(stradr)
    ios.rd_seek(fnr,0)
    repeat len                                          'datei einlesen
      ios.rd_put(fnr,ios.sdgetc)
    ios.sdclose
    ios.rd_close(fnr)

PRI rd_save | stradr, fnr, len                          'rd: datei aus ramdisk speichern

  stradr := os_nxtoken1
  fnr := ios.rd_open(stradr)
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ifnot os_error(ios.sdnewfile(stradr))
      ifnot os_error(ios.sdopen("W",stradr))
        ios.print(string("Schreibe Datei..."))
        repeat len
          ios.sdputc(ios.rd_get(fnr))
        ios.sdclose
        ios.print(string(" ok"))
        ios.printnl
    ios.rd_close(fnr)

PRI rd_rename

  os_error(ios.rd_rename(os_nxtoken1,os_nxtoken2))


PRI rd_seek | fnr,wert                                  'rd: dateizeiger setzen

  fnr   := num.FromStr(os_nxtoken1,num#HEX)
  wert  := num.FromStr(os_nxtoken1,num#HEX)
  ios.rd_seek(fnr,wert)

PRI rd_put | fnr,wert,chars                             'rd: werte ausgeben

  fnr   := num.FromStr(os_nxtoken1,num#HEX)
  wert  := num.FromStr(os_nxtoken1,num#HEX)
  chars := num.FromStr(os_nxtoken1,num#HEX)

  repeat chars
    ios.rd_put(fnr,wert)

PRI rd_get | fnr,chars,i,j                              'rd: werte einlesen

  fnr   := num.FromStr(os_nxtoken1,num#HEX)
  chars := num.FromStr(os_nxtoken1,num#HEX)

  i := j := 0
  repeat chars
    ifnot i
      ios.printnl
      ios.printhex(j,4)
      ios.printchar(":")
    ios.printhex(ios.rd_get(fnr),2)
    ios.printchar(" ")
    if i++ == 7
      i := 0
    j++
  ios.printnl

PRI rd_write | fnr,adr,wert                             'rd: wert schreiben

  fnr   := num.FromStr(os_nxtoken1,num#HEX)
  adr   := num.FromStr(os_nxtoken1,num#HEX)
  wert  := num.FromStr(os_nxtoken1,num#HEX)

  ios.rd_wrbyte(fnr,wert,adr)

PRI rd_read | fnr,adr                                   'rd: wert lesen

  fnr   := num.FromStr(os_nxtoken1,num#HEX)
  adr   := num.FromStr(os_nxtoken1,num#HEX)

  ios.printhex(ios.rd_rdbyte(fnr,adr),2)
  ios.printnl


PRI rd_close                                            'rd: datei schliessen

  ios.rd_close(num.FromStr(os_nxtoken1,num#HEX))

PRI rd_open                                             'rd: datei öffnen

  ifnot ios.rd_open(os_nxtoken1)
    os_error(5)

PRI rd_ftab | i                                         'rd: anzeige ftab

  i := 0
  repeat ios#FILES
    ios.printnl
    ios.printhex(i,2)
    ios.printchar(":")
    ios.printhex(ios.rd_getftab(i*3+0),6)
    ios.printchar(" ")
    ios.printhex(ios.rd_getftab(i*3+1),6)
    ios.printchar(" ")
    ios.printhex(ios.rd_getftab(i*3+2),6)
    ifnot i
      ios.print(string(" user"))
    i++
  ios.printnl

PRI rd_del | adr                                        'rd: datei löschen

  os_error(ios.rd_del(os_nxtoken1))

PRI rd_dir | stradr,len                                 'rd: dir anzeigen

if ios.ram_rdbyte(ios#sysmod,ios#RAMDRV)
  ios.rd_dir
  repeat
    len := ios.rd_dlen
    stradr := ios.rd_next
    if stradr
      ios.print(stradr)
      ios.printtab
      ios.printdec(len)
      ios.printnl
  until stradr == 0
else
  os_error(1)

PRI rd_header|hp,nx,len,i                               'rd: header

  hp := ios#STARTRD
  repeat
    nx  := ios.ram_rdlong(ios#sysmod,hp)
    len := ios.ram_rdlong(ios#sysmod,hp+4)
    ios.print(string("[adr-header] = $"))
    ios.printhex(hp,8)
    ios.printnl
    ios.print(string("[adr-next  ] = $"))
    ios.printhex(nx,8)
    ios.printnl
    ios.print(string("[len       ] = $"))
    ios.printhex(len,8)
    ios.printchar(" ")
    ios.printdec(len)
    ios.printnl
    ios.print(string("[name      ] = "))
    i := 0
    repeat 12
      ios.printchar(ios.ram_rdbyte(ios#sysmod,hp+8+i++))
    hp := nx
    ios.print(string(" <*/q> : "))
    if ios.keywait == "q"
      quit
    ios.printnl
  until nx == 0
    ios.printnl

PRI rd_new                                              'rd: new file

  ios.rd_newfile(os_nxtoken1,num.FromStr(os_nxtoken2,num#DEC))

PRI rd_init                                             'rd: rdisk initialisieren

  ios.rd_init

PRI ram_sysvar | i                                      'ram: systemvariablen anzeigen

  ios.print(string("LOADERPTR     = "))
  ios.printchar("[")
  ios.printhex(ios#LOADERPTR,6)
  ios.print(string("] : "))
  ios.printhex(ios.ram_rdlong(0,ios#LOADERPTR),6)
  ios.printnl
  ios.print(string("MAGIC         = "))
  ios.printchar("[")
  ios.printhex(ios#MAGIC,6)
  ios.print(string("] : "))
  ios.printhex(ios.ram_rdbyte(0,ios#MAGIC),6)
  ios.printnl
  ios.print(string("SIFLAG        = "))
  ios.printchar("[")
  ios.printhex(ios#SIFLAG,6)
  ios.print(string("] : "))
  ios.printhex(ios.ram_rdbyte(0,ios#SIFLAG),6)
  ios.printnl
  ios.print(string("BELDRIVE      =  "))
  i := ios#BELDRIVE
  repeat 12
    ios.printchar(ios.ram_rdbyte(0,i++))
  ios.printnl
  ios.print(string("PARAM         =  "))
  i := ios#PARAM
  repeat 32
    ios.printchar(ios.ram_rdbyte(0,i++))
  ios.printnl
  ios.print(string("RAMEND        = "))
  ios.printchar("[")
  ios.printhex(ios#RAMEND,6)
  ios.print(string("] : "))
  ios.printhex(ios.ram_getend,6)
  ios.printnl
  ios.print(string("RAMBAS        = "))
  ios.printchar("[")
  ios.printhex(ios#RAMBAS,6)
  ios.print(string("] : "))
  ios.printhex(ios.ram_getbas,6)
  ios.printnl


PRI ram_setrbas                                         'ram: basisadresse setzen

  ios.ram_setbas(num.FromStr(os_nxtoken1,num#HEX))

PRI ram_fill | adr,len,wert                             'ram: speicherbereich füllen

  adr  := ram_symbols
  len  := num.FromStr(os_nxtoken1,num#HEX)
  wert := num.FromStr(os_nxtoken1,num#HEX)

  repeat len
    ios.ram_wrbyte(ios#sysmod,wert,adr++)

PRI ram_fillusr | adr,len,wert                          'ram: speicherbereich füllen

  adr  := ram_symbols
  len  := num.FromStr(os_nxtoken1,num#HEX)
  wert := num.FromStr(os_nxtoken1,num#HEX)

  repeat len
    ios.ram_wrbyte(ios#usrmod,wert,adr++)

PRI ram_info                                            'ram: infos anzeigen
  ios.print(string("RBAS : $"))
  ios.printhex(ios.ram_getbas,6)
  ios.print(string(" REND : $"))
  ios.printhex(ios.ram_getend,6)
  ios.print(string(" RLEN : $"))
  ios.printhex(ios.ram_getend - ios.ram_getbas,6)
  ios.print(string(" RDRV : $"))
  ios.printhex(ios.ram_rdbyte(ios#sysmod,ios#RAMDRV),2)
  ios.printnl

PRI ram_mod | wert,adresse,stradr                       'ram: rambereich beschreiben
{{rmodify <adr b1 b2 b3 ...> - rambereich beschreiben, adresse und werte
  folgen auf kommandozeile}}

  adresse := ram_symbols                                'adresse von kommandozeile holen
  repeat
    if (stradr := os_nxtoken1)
      wert := num.FromStr(stradr,num#HEX)               'nächstes byte von kommandozeile holen
      ios.ram_wrbyte(0,wert,adresse++)                  'wert in eram schreiben
  until stradr == 0                                     'keine parameter mehr?

PRI ram_lmod | wert,adresse,stradr                      'ram: rambereich beschreiben (long)
{{rmodify <adr l1 l2 l3 ...> - rambereich beschreiben, adresse und werte
  folgen auf kommandozeile}}

  adresse := ram_symbols                                'adresse von kommandozeile holen
  repeat
    if (stradr := os_nxtoken1)
      wert := num.FromStr(stradr,num#HEX)               'nächstes byte von kommandozeile holen
      ios.ram_wrlong(0,wert,adresse)                    'long in eram schreiben
      adresse := adresse + 4
  until stradr == 0                                     'keine parameter mehr?

PRI ram_disp | adresse,zeilen,sadr                      'ram: rambereich anzeigen
{{rdisplay <adr anz> - rambereich anzeigen, adresse und zeilenzahl folgt auf kommandozeile}}

  adresse := ram_symbols

  zeilen := num.FromStr(os_nxtoken1,num#HEX)            'zeilenzahl von kommandozeile holen
  if zeilen == 0
    zeilen := RMON_ZEILEN
  ram_print(adresse,zeilen)

PRI ram_symbols:adresse | sadr                          'ram: adresse auflösen

  sadr := os_nxtoken1
  if strcomp(sadr,string("bas"))
    adresse := ios.ram_getbas
  elseif strcomp(sadr,string("end"))
    adresse := ios.ram_getend
  elseif strcomp(sadr,string("sys"))
    adresse := ios.ram_getend + 1
  elseif strcomp(sadr,string("rd:"))
    adresse := ios.rd_searchdat(os_nxtoken1)
  else
    adresse := num.FromStr(sadr,num#HEX)                  'adresse von kommandozeile holen


PRI ram_displong | sadr,adresse,wert                    'ram: rambereich als long anzeigen

  adresse := ram_symbols

  repeat
    ios.printnl
    if (adresse => ios.ram_getbas) & (adresse =< ios.ram_getend)
      ios.setcolor(2)
      ios.printhex(adresse - ios.ram_getbas,6)
      ios.setcolor(0)
    else
      ios.print(string("------"))
    ios.printchar("-")
    ios.printhex(adresse,6)                             'adresse ausgeben
    ios.printchar(" ")

    wert := ios.ram_rdlong(0,adresse)
    ios.printhex(wert,6)
    ios.printchar(":")
    ios.printbin(wert,32)
    ios.print(string(" <*/q> : "))
    adresse += 4
  until ios.keywait == "q"
  ios.printnl

PRI ram_next                                            'ram: anzeige fortsetzen
  ram_print(ppos,pcnt)

PRI ram_print(adresse,zeilen)|wert,pbas,pend            'ram: ausgabe

  pbas := ios.ram_getbas                                'rbas vom system sichern
  pend := ios.ram_getend
  repeat zeilen                                         'zeilen
    if (adresse => pbas) & (adresse =< pend)
      ios.setcolor(2)
      ios.printhex(adresse-pbas,6)
      ios.setcolor(0)
    else
      ios.print(string("------"))
    ios.printchar("-")
    ios.printhex(adresse,6)                             'adresse ausgeben
    ios.printchar(ios#CHAR_SPACE)                        
    repeat RMON_BYTES                                   'hexwerte ausgeben
      wert := ios.ram_rdbyte(0,adresse++)
      ios.printhex(wert,2)                              'byte ausgeben
      ios.printchar(":")
    adresse := adresse - rmon_bytes                      
    ios.printchar(ios#CHAR_SPACE)                        
    repeat RMON_BYTES                                   'zeichen ausgeben
      wert := ios.ram_rdbyte(0,adresse++)
      if wert < $20                                      
        wert := 46                                       
      ios.printchar(wert)                               'byte ausgeben
    ios.printchar($0D)
  ppos := adresse
  pcnt := zeilen

PRI ram_load | adr,len,stradr,status,char,i             'ram: lade datei nach eramadr
{{sdload - adr len dateiname   lade datei nach eram-adr}}

  adr    := num.FromStr(os_nxtoken1,num#HEX)            'adresse von kommandozeile holen
  len    := num.FromStr(os_nxtoken1,num#HEX)            'l?nge von kommandozeile holen
  stradr := os_nxtoken1                                 'dateinamen von kommandozeile holen
  status := ios.sdopen("r",stradr)                      'datei ?ffnen
  if status > 0
    ios.print(string("Status : "))
    ios.printdec(status)
    ios.printnl
  if status == 0
    repeat i from 0 to len
      char := ios.sdgetc
      ios.ram_wrbyte(0,char,adr + i)
    ios.sdclose
      


PUB os_error(err):error                                 'sys: fehlerausgabe

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
  error := err

DAT
prompt1       byte  "ok ", $0d, 0
prompt2       byte  ": ", 0
prompt3       byte  "? ",0
wait1         byte  "<WEITER? */q:>",0

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

