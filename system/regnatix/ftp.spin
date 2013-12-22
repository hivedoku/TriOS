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

VAR

  long    ip_addr
  byte    parastr[64]
  byte    remdir[64]
  byte    filename[64]
  byte    strTemp[128]
  byte    addrset
  byte    handleidx_control          'Handle FTP Control Verbindung
  byte    handleidx_data             'Handle FTP Data Verbindung

PUB main

  ip_addr := 0
  remdir[0] := 0
  filename[0] := 0

  ios.start                                             'ios initialisieren
  ios.printnl
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(@help)
        "s": if ios.paranext(@parastr)
               setaddr(@parastr)
        "v": ios.paranext(@remdir)
        "d": ios.paranext(@filename)
        other: ios.print(@help)

  ifnot ftpconnect
    ifnot ftplogin(string("anonymous"),string("password"))
      ifnot byte[@remdir][0] == 0
        ftpcwd
      ifnot byte[@filename][0] == 0
        if ftppasv
          ftpretr


  ftpclose
  ios.stop

PRI ftpconnect

  ifnot (ip_addr)  ' Adresse 0.0.0.0
    ios.print(string("FTP-Server nicht angegeben (Parameter /s)"))
    ios.printnl
    return(-1)
  ios.print(string("Starte LAN..."))
  ios.printnl
  ios.lanstart
  delay_ms(800) 'nach ios.lanstart dauert es, bis der Stack funktioniert
  ios.print(string("Verbinde mit FTP-Server..."))
  ios.printnl
  if (handleidx_control := ios.lan_connect(ip_addr, 21)) == $FF
    ios.print(string("Kein Socket frei..."))
    ios.printnl
    return(-1)
  ifnot (ios.lan_waitconntimeout(handleidx_control, 2000))
    ios.print(string("Verbindung mit FTP-Server konnte nicht aufgebaut werden."))
    ios.printnl
    return(-1)
  ios.print(string("Verbindung mit FTP-Server hergestellt, warte auf Antwort..."))
  ios.printnl
  ifnot getResponse(string("220 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)
  return(0)

PRI ftpclose

  if handleidx_control
    ios.lan_close(handleidx_control)
    handleidx_control := 0
  if handleidx_data
    ios.lan_close(handleidx_data)
    handleidx_data := 0

PRI ftplogin(username, password) | pwreq, respOK

  pwreq := FALSE
  respOK := FALSE

  ifnot strsize(username)
    username := string("anonymous")
  if sendStr(string("USER ")) || sendStr(username) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des Usernamens"))
    ios.printnl
    return(-1)

  repeat until readLine == -1
    ios.print(string(" < "))
    ios.print(@strTemp)
    ios.printnl
    strTemp[4] := 0
    if strcomp(@strTemp, string("230 "))
      respOk := TRUE
      ios.print(string("Antwort korrekt."))
      ios.printnl
    elseif strcomp(@strTemp, string("331 "))
      pwreq := TRUE
      respOk := TRUE
      ios.print(string("Antwort korrekt."))
      ios.printnl
  ifnot respOK
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)

  ifnot pwreq
    return(0)

  if sendStr(string("PASS ")) || sendStr(password) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des Passworts"))
    ios.printnl
    return(-1)
  ifnot getResponse(string("230 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)

  return(0)

PRI ftpcwd

  if sendStr(string("CWD ")) || sendStr(@remdir) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des Verzeichnisses"))
    ios.printnl
    return(-1)
  ifnot getResponse(string("250 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
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

  if (port == 0)
    ios.print(string("FTP-Server-Fehler beim Öffnen des Passiv-Ports"))
    ios.printnl
    return(0)
  ios.print(string("Öffne Verbindung zu Passiv-Port "))
  ios.print(num.ToStr(port, num#DEC))
  ios.printnl
  if (handleidx_data := ios.lan_connect(ip_addr, port)) == $FF
    ios.print(string("Kein Socket frei..."))
    ios.printnl
    return(0)
  ifnot (ios.lan_waitconntimeout(handleidx_data, 2000))
    ios.print(string("Verbindung mit FTP-Server konnte nicht aufgebaut werden."))
    ios.printnl
    return(0)

PRI ftpretr | len

  if sendStr(string("SIZE ")) || sendStr(@filename) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des SIZE-Kommandos"))
    ios.printnl
    return(-1)
  ifnot getResponse(string("213"))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)
  ifnot(len := num.FromStr(@strTemp+4, num#DEC))
    return(-1)

  if sendStr(string("TYPE I",13,10))
    ios.print(string("Fehler beim Senden des Types"))
    ios.printnl
    return(-1)
  ifnot getResponse(string("200 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)

  if sendStr(string("RETR ")) || sendStr(@filename) || sendStr(string(13,10))
    ios.print(string("Fehler beim Senden des Filenamens"))
    return -1
  ifnot getResponse(string("150 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)

  if ios.lan_rxdata(handleidx_data, @filename, len)
    ios.print(string("Fehler beim Empfang der Datei."))
    ios.printnl
    return(-1)

  ifnot getResponse(string("226 "))
    ios.print(string("Keine oder falsche Antwort vom FTP-Server erhalten."))
    ios.printnl
    return(-1)

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
      ios.print(string("Antwort korrekt."))
      ios.printnl

  return respOk

PRI readLine | i, ch

  repeat i from 0 to 126
    ch := ios.lan_rxtime(handleidx_control, 500)
    if ch == 13
      ch := ios.lan_rxtime(handleidx_control, 500)
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

PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)

DAT                                                     'sys: helptext


help          byte  "/?              : Hilfe",13
              byte  "/s <a.b.c.d>    : Server-Adresse",13
              byte  "/v <verzeichnis>: in entferntes Verzeichnis wechseln",13
              byte  "/d <filename>   : Download <filename>",13
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
