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
Funktion        : FTP-Client
Komponenten     : -
COG's           : -
Logbuch         :

22.12.2013-joergd - erste Version
05.01.2014-joergd - Defaultwerte gesetzt
                  - Speichern auf SD-Card
                  - Parameter für Benutzer und Paßwort

Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        str: "glob-string"
        num: "glob-numbers"        'Number Engine

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

 LANMASK     = %00000000_00000000_00000000_00100000

CON 'NVRAM Konstanten --------------------------------------------------------------------------

#4,     NVRAM_IPADDR
#8,     NVRAM_IPMASK
#12,    NVRAM_IPGW
#16,    NVRAM_IPDNS
#20,    NVRAM_IPBOOT
#24,    NVRAM_HIVE       ' 4 Bytes

VAR

  long    ip_addr
  byte    parastr[64]
  byte    remdir[64]
  byte    filename[64]
  byte    username[64]
  byte    password[64]
  byte    strTemp[128]
  byte    addrset
  byte    save2card
  byte    handleidx_control          'Handle FTP Control Verbindung
  byte    handleidx_data             'Handle FTP Data Verbindung

PUB main

  ip_addr := 0
  save2card := FALSE
  remdir[0] := 0
  filename[0] := 0
  username[0] := 0
  password[0] := 0

  ios.start
  ifnot (ios.admgetspec & LANMASK)
    ios.print(string(10,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",10,"Bitte admnet laden.",10))
    ios.stop
  ios.printnl
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(@help)
        "f": if ios.paranext(@parastr)
               setaddr(@parastr)
        "v": ios.paranext(@remdir)
        "d": ios.paranext(@filename)
        "u": ios.paranext(@username)
        "p": ios.paranext(@password)
        "s": save2card := TRUE
        other: ios.print(@help)

  ifnot byte[@filename][0] == 0
    ifnot ftpconnect
      ifnot ftplogin
        ftpcwd
        if ftppasv
          ftpretr
  else
    ios.print(string("Keine Datei zum Downloaden angegeben, beende...",10))


  ftpclose
  ios.stop

PRI ftpconnect

  ifnot (ip_addr)  ' Adresse 0.0.0.0
    ios.print(string("FTP-Server nicht angegeben (Parameter /s)",10))
    ip_addr := ios.getNVSRAM(NVRAM_IPBOOT) << 24
    ip_addr += ios.getNVSRAM(NVRAM_IPBOOT+1) << 16
    ip_addr += ios.getNVSRAM(NVRAM_IPBOOT+2) << 8
    ip_addr += ios.getNVSRAM(NVRAM_IPBOOT+3)
    if (ip_addr)
      ios.print(string("Verwende Boot-Server (mit ipconfig gesetzt).",10))
    else
      return(-1)
  ios.print(string("Starte LAN...",10))
  ios.lanstart
  ios.print(string("Verbinde mit FTP-Server...",10))
  if (handleidx_control := ios.lan_connect(ip_addr, 21)) == $FF
    ios.print(string("Kein Socket frei...",10))
    return(-1)
  ifnot (ios.lan_waitconntimeout(handleidx_control, 2000))
    ios.print(string("Verbindung mit FTP-Server konnte nicht aufgebaut werden.",10))
    return(-1)
  ios.print(string("Verbindung mit FTP-Server hergestellt, warte auf Antwort...",10))
  ifnot getResponse(string("220 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)
  return(0)

PRI ftpclose

  ifnot handleidx_control == $FF
    ios.lan_close(handleidx_control)
    handleidx_control := $FF
  ifnot handleidx_data == $FF
    ios.lan_close(handleidx_data)
    handleidx_data := $FF

PRI ftplogin | pwreq, respOK, hiveid

  pwreq := FALSE
  respOK := FALSE

  sendStr(string("USER "))
  if strsize(@username)
    sendStr(@username)
    sendStr(string(13,10))
  else
    sendStr(string("anonymous",13,10))

  repeat until readLine == -1
    ios.print(string(" < "))
    ios.print(@strTemp)
    ios.printnl
    strTemp[4] := 0
    if strcomp(@strTemp, string("230 "))
      respOk := TRUE
      quit
    elseif strcomp(@strTemp, string("331 "))
      pwreq := TRUE
      respOk := TRUE
      quit
  ifnot respOK
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)

  ifnot pwreq
    return(0)

  sendStr(string("PASS "))
  if strsize(@password)
    sendStr(@password)
    sendStr(string(13,10))
  else
    hiveid := ios.getNVSRAM(NVRAM_HIVE)
    hiveid += ios.getNVSRAM(NVRAM_HIVE+1) << 8
    hiveid += ios.getNVSRAM(NVRAM_HIVE+2) << 16
    hiveid += ios.getNVSRAM(NVRAM_HIVE+3) << 24
    sendStr(string("anonymous@hive"))
    sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC)))
    sendStr(string(13,10))

  ifnot getResponse(string("230 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)

  return(0)

PRI ftpcwd | i

  if byte[@remdir][0] == 0
    i := sendStr(string("CWD ")) || sendStr(@defdir) || sendStr(string(13,10))
  else
    i := sendStr(string("CWD ")) || sendStr(@remdir) || sendStr(string(13,10))
  if i
    ios.print(string("Fehler beim Senden des Verzeichnisses",10))
    return(-1)
  ifnot getResponse(string("250 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)
  return(0)

PRI ftppasv : port | i, k, port256, port1

  port := 0
  port256 := 0
  port1 := 0
  k := 0

  if sendStr(string("PASV",13,10))
    return(0)

  repeat until readLine == -1
    ios.print(string(" < "))
    ios.print(@strTemp)
    ios.printnl
    strTemp[4] := 0
    if strcomp(@strTemp, string("227 "))
      repeat i from 5 to 126
        if (strTemp[i] == 0) OR (strTemp[i] == 13) OR (strTemp[i] == 10)
          quit
        if strTemp[i] == 44 'Komma
          strTemp[i] := 0
          k++
          if k == 4         '4. Komma, Port Teil 1 folgt
            port256 := i + 1
          if k == 5         '5. Komma, Port Teil 2 folgt
            port1 := i + 1
        if strTemp[i] == 41 'Klammer zu
          strTemp[i] := 0
          if (port256 & port1)
            port := (num.FromStr(@strTemp+port256, num#DEC) * 256) + num.FromStr(@strTemp+port1, num#DEC)
      quit

  if (port == 0)
    ios.print(string("FTP-Server-Fehler beim Öffnen des Passiv-Ports",10))
    return(0)
  ios.print(string("Öffne Verbindung zu Passiv-Port "))
  ios.print(num.ToStr(port, num#DEC))
  ios.printnl
  if (handleidx_data := ios.lan_connect(ip_addr, port)) == $FF
    ios.print(string("Kein Socket frei...",10))
    return(0)
  ifnot (ios.lan_waitconntimeout(handleidx_data, 2000))
    ios.print(string("Verbindung mit FTP-Server konnte nicht aufgebaut werden.",10))
    return(0)

PRI ftpretr | len, respOK

  if sendStr(string("TYPE I",13,10))
    ios.print(string("Fehler beim Senden des Types",10))
    return(-1)
  ifnot getResponse(string("200 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)

  if sendStr(string("SIZE ")) || sendStr(@filename) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des SIZE-Kommandos",10))
    return(-1)
  ifnot getResponse(string("213"))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)
  ifnot(len := num.FromStr(@strTemp+4, num#DEC))
    return(-1)

  if sendStr(string("RETR ")) || sendStr(@filename) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des Filenamens",10))
    return -1
  respOK := FALSE
  repeat until readLine == -1
    ios.print(string(" < "))
    ios.print(@strTemp)
    ios.printnl
    strTemp[4] := 0
    if strcomp(@strTemp, string("150 "))
      respOk := TRUE
      quit
    elseif strcomp(@strTemp, string("125 "))
      respOk := TRUE
      quit
  ifnot respOK
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)

  if ios.lan_rxdata(handleidx_data, @filename, len)
    ios.print(string("Fehler beim Empfang der Datei.",10))
    return(-1)

  ifnot getResponse(string("226 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten.",10))
    return(-1)

  if save2card
    writeToSDCard
    ios.print(string("Speichere auf SD-Card...",10))

PRI writeToSDCard | fnr, len, i

  fnr := ios.rd_open(@filename)
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ios.sddel(@filename)                                   'falls alte Datei auf SD-Card vorhanden, diese löschen
    ifnot ios.sdnewfile(@filename)
      ifnot ios.sdopen("W",@filename)
        i := 0
        ios.sdxputblk(fnr,len)                          'daten als block schreiben
        ios.sdclose
        ios.rd_del(@filename)
    ios.rd_close(fnr)

PRI setaddr (ipaddr) | pos, count                       'IP-Adresse in Variable schreiben

  count := 3
  repeat while ipaddr
    pos := str.findCharacter(ipaddr, ".")
    if(pos)
      byte[pos++] := 0
    ip_addr += num.FromStr(ipaddr, num#DEC) << (8*count--)
    ipaddr := pos
    if(count == -1)
      quit

PRI getResponse (strOk) : respOk | len

  respOk := FALSE

  repeat until readLine == -1
    ios.print(string(" < "))
    ios.print(@strTemp)
    ios.printnl
    strTemp[strsize(strOk)] := 0
    if strcomp(@strTemp, strOk)
      respOk := TRUE
      quit

  return respOk

PRI readLine | i, ch

  repeat i from 0 to 126
    ch := ios.lan_rxtime(handleidx_control, 2000)
    if ch == 13
      ch := ios.lan_rxtime(handleidx_control, 2000)
    if ch == -1 or ch == 10
      quit
    strTemp[i] := ch

  strTemp[i] := 0

  return ch 'letztes Zeichen oder -1, wenn keins mehr empfangen

PRI sendStr (strSend) : error

  ios.print(string(" > "))
  ios.print(strSend)
  ios.printnl
  error := ios.lan_txdata(handleidx_control, strSend, strsize(strSend))

DAT

defdir        byte  "/hive/sdcard/system",0
help          byte  "/?              : Hilfe",10
              byte  "/f <a.b.c.d>    : FTP-Server-Adresse",10
              byte  "                  (default: mit ipconfig gesetzter Boot-Server)",10
              byte  "/v <verzeichnis>: in entferntes Verzeichnis wechseln",10
              byte  "                  (default: /hive/sdcard/system)",10
              byte  "/d <dateiname>  : Download <dateiname>",10
              byte  "/u <username>   : Benutzername am FTP-Server",10
              byte  "                  (default: anonymous)",10
              byte  "/p <password>   : Paßwort am FTP-Server",10
              byte  "                  (default: anonymous@hive<Hive-Id>)",10
              byte  "/s              : Datei auf SD-Card speichern",10
              byte  0

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
