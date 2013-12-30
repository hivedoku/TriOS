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

LANMASK         = %00000000_00000000_00000000_00100000

W0X_MENU        = 8
W0Y_MENU        = 0

COL_DEFAULT     = 0
COL_MENU        = 8
COL_FOCUS       = 3

LEN_PASS        = 32
LEN_NICK        = 32
LEN_USER        = 32
LEN_CHAN        = 32
LEN_IRCLINE     = 512

VAR

  long  t1char                                'Zeit, wann 1. Zeichen einer Zeile empfangen
  long  ip_addr
  word  ip_port
  word  readpos
  byte  handleidx                             'Handle-Nummer IRC Verbindung
  byte  rows,cols,vidmod
  byte  x0[4],y0[4],xn[4],yn[4],hy[4],focus
  byte  password[LEN_PASS+1],nickname[LEN_NICK+1],username[LEN_USER+1],channel[LEN_CHAN+1]
  byte  input_str[64]
  byte  temp_str[64]
  byte  send_str[LEN_IRCLINE]
  byte  receive_str[LEN_IRCLINE]

PUB main | key

  init

  repeat
    if ios.keystat > 0
      key := ios.key
      case key
        gc#KEY_TAB: f_focus
        gc#KEY_F02: f_setconf
        gc#KEY_F03: f_connect
        gc#KEY_F09: f_close
        gc#KEY_F10: f_quit
        other:      f_input(key)
    ifnot handleidx == $FF
      irc_getLine

PRI init

  long[ip_addr]   := 0
  word[ip_port]   := 0
  word[readpos]   := 0
  byte[handleidx] := $FF
  password[0]     := 0
  nickname[0]     := 0
  username[0]     := 0
  channel[0]      := 0
  send_str[0]     := 0
  focus           := 3

  ios.start                                             'ios initialisieren
  ifnot (ios.admgetspec & LANMASK)
    ios.print(string(10,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",10,"Bitte admnet laden.",10))
    ios.stop
  setscreen
  conf_load
  if ip_addr == 0
    f_setconf

PRI conf_load | i

  ios.sddmset(ios#DM_USER)                                      'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                                    's-marker aktivieren

  ifnot ios.sdopen("R",@strConfFile)
    ip_addr := ios.sdgetc << 24
    ip_addr += ios.sdgetc << 16
    ip_addr += ios.sdgetc << 8
    ip_addr += ios.sdgetc
    ip_port := ios.sdgetc << 8
    ip_port += ios.sdgetc

    repeat i from 0 to LEN_PASS
      password[i] := ios.sdgetc
    repeat i from 0 to LEN_NICK
      nickname[i] := ios.sdgetc
    repeat i from 0 to LEN_USER
      username[i] := ios.sdgetc
    repeat i from 0 to LEN_CHAN
      channel[i] := ios.sdgetc

    ios.sdclose

  ios.sddmact(ios#DM_USER)                                      'u-marker aktivieren

PRI conf_save | i

  ios.sddmset(ios#DM_USER)                                      'u-marker setzen
  ios.sddmact(ios#DM_SYSTEM)                                    's-marker aktivieren

  ios.sdnewfile(@strConfFile)
  ifnot ios.sdopen("W",@strConfFile)
    ios.sdputc(ip_addr >> 24)
    ios.sdputc(ip_addr >> 16)
    ios.sdputc(ip_addr >>  8)
    ios.sdputc(ip_addr      )
    ios.sdputc(ip_port >>  8)
    ios.sdputc(ip_port      )

    repeat i from 0 to LEN_PASS
      ios.sdputc(password[i])
    repeat i from 0 to LEN_NICK
      ios.sdputc(nickname[i])
    repeat i from 0 to LEN_USER
      ios.sdputc(username[i])
    repeat i from 0 to LEN_CHAN
      ios.sdputc(channel[i])

    ios.sdclose

  ios.sddmact(ios#DM_USER)                                      'u-marker aktivieren

  ios.winset(2)
  ios.print(string(10,"Konfiguration gespeichert."))

PRI f_focus

  if ++focus == 4
    focus := 1
  win_redraw

PRI f_setconf | i,n

  if ip_addr == 0
    byte[temp_str][0] := 0
  else
    IpPortToStr(ip_addr, ip_port)
  input(string("IRC-Server angeben (IP:Port):"),@temp_str ,21)
  ifnot strToIpPort(@input_str, @ip_addr, @ip_port)
    ios.winset(2)
    ios.print(string(10,"Fehlerhafte Eingabe von IP-Adresse und Port des IRC-Servers."))

  input(string("Paßwort eingeben:"),@password,LEN_PASS)
  n := 1
  repeat i from 0 to LEN_PASS
    if n == 0
      byte[@password][i] := 0
    else
      n := byte[@input_str][i]
      byte[@password][i] := n

  input(string("Nickname eingeben:"),@nickname,LEN_NICK)
  n := 1
  repeat i from 0 to LEN_NICK
    if n == 0
      byte[@nickname][i] := 0
    else
      n := byte[@input_str][i]
      byte[@nickname][i] := n

  input(string("Username eingeben:"),@username,LEN_USER)
  n := 1
  repeat i from 0 to LEN_USER
    if n == 0
      byte[@username][i] := 0
    else
      n := byte[@input_str][i]
      byte[@username][i] := n

  input(string("Channel eingeben:"),@channel,LEN_CHAN)
  n := 1
  repeat i from 0 to LEN_CHAN
    if n == 0
      byte[@channel][i] := 0
    else
      n := byte[@input_str][i]
      byte[@channel][i] := n

  win_redraw

  conf_save

PRI f_connect | t

  ios.winset(2)
  ios.print(string(10,"Starte LAN..."))
  ios.lanstart
  delay_ms(800) 'nach ios.lanstart dauert es, bis der Stack funktioniert
  ios.print(string(10,"Verbinde mit IRC-Server..."))
  if (handleidx := ios.lan_connect(ip_addr, ip_port)) == $FF
    ios.print(string(10,"Kein Socket frei!"))
    return(-1)
  ifnot (ios.lan_waitconntimeout(handleidx, 2000))
    ios.print(string(10,"Verbindung mit IRC-Server konnte nicht aufgebaut werden."))
    f_close
    return(-1)
  ios.print(string(10,"Verbunden, warte auf Bereitschaft..."))

'  t := cnt
'  repeat until (cnt - t) / (clkfreq / 1000) > 5000
'    irc_getline

  irc_pass
  irc_join

PRI f_close

  ifnot handleidx == $FF
    ios.lan_close(handleidx)
    handleidx := $FF

PRI f_quit

  f_close
  ios.winset(0)
  ios.screeninit
  ios.stop

PRI f_input(key)| i

  i := strsize(@send_str)
  ios.winset(3)
  if key == $0d
    if sendStr(@send_str) || sendStr(string(13,10))
      ios.printcls
      ios.winset(1)
      ios.printchar(10)
      ios.print(@send_str)
      byte[@send_str][0] := 0
  if (key == ios#CHAR_BS)&(i>0)                             'backspace
    ios.printbs
    i--
    byte[@send_str][i] := 0
  elseif i < LEN_IRCLINE-2                                    'normales zeichen
    ios.printchar(key)
    byte[@send_str][i] := key
    i++
    byte[@send_str][i] := 0

PRI irc_pass

  ios.winset(2)
  ios.print(string(10,"Sende Paßwort..."))
  if sendStr(string("PASS ")) || sendStr(@password) || sendStr(string(13,10))
    ios.print(string(10,"Fehler beim Senden des Paßwortes"))
    return(-1)

PRI irc_join

  ios.winset(2)
  ios.print(string(10,"Sende Nickname"))
  if sendStr(string("NICK ")) || sendStr(@nickname) || sendStr(string(13,10))
    ios.print(string(10,"Fehler beim Senden des Nicknamens"))
    return(-1)

  ios.print(string(", Benutzerinformationen"))
  if sendStr(string("USER ")) || sendStr(@username) || sendStr(string(" 0 * :Hive #",13,10))
    ios.print(string(10,"Fehler beim Senden des Nicknamens"))
    return(-1)

  ifnot strsize(@channel) == 0
    ios.winset(2)
    ios.print(string(" und verbinde mit Channel"))
    if sendStr(string("JOIN ")) || sendStr(@channel) || sendStr(string(13,10))
      ios.print(string(10,"Fehler beim Verbinden mit dem Channel"))
      return(-1)

PRI irc_getLine

  if readLine(2000) 'vollständige Zeile empfangen

    if str.findCharacters(@receive_str, string("PING :")) == @receive_str
      ios.winset(2)
      ios.print(string(10,"PING erhalten, sende PONG"))
      receive_str[1] := "O"
      sendStr(@receive_str)
      sendStr(string(13,10))
    else
      ios.winset(1)
      ios.printchar(10)
      ios.print(@receive_str)

PRI frame_draw

  ios.winset(0)
  ios.curoff
  ios.printcls
  ios.cursetx(W0X_MENU)
  ios.cursety(W0Y_MENU)
  ios.setcolor(COL_MENU)
  ios.print(string(" IRC Client"))
  repeat cols-W0X_MENU-11
    ios.printchar(" ")
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
    if i == 3
      ios.curon
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
    if i == 3
      ios.curon
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
  ios.windefine(4,13,10,47,13)

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

PRI IpPortToStr(ip, port) | i,n,x,stradr
  ' IP-Adresse und Port stehen dann in temp_str

  n := 0
  repeat i from 3 to 0
    stradr := str.trimCharacters(num.ToStr(byte[@ip][i], num#DEC))
    x := 0
    repeat strsize(stradr)
      byte[@temp_str][n++] := byte[stradr][x++]
    if(i)
      byte[@temp_str][n++] := "."
  byte[@temp_str][n++] := ":"
  stradr := str.trimCharacters(num.ToStr(port, num#DEC))
  x := 0
  repeat strsize(stradr)
    byte[@temp_str][n++] := byte[stradr][x++]
  byte[@temp_str][n] := 0

PUB input(strdesc, strdef, input_len) | i,n

  input_str[0] := 0
  ios.winset(4)
  ios.printcls
  ios.winoframe
  ios.curhome
  ios.curoff
  ios.setcolor(COL_DEFAULT)
  ios.printchar(" ")
  ios.print(strdesc)
  ios.printnl
  ios.printnl
  ios.printchar(" ")
  repeat input_len
    ios.printchar("_")
  ios.curpos1
  ios.printchar(" ")
  i := 0
  repeat strsize(strdef)                                'Vorgabewert in strdef eintragen
    n := byte[strdef+i]
    ios.printchar(n)
    byte[@input_str][i] := n
    i++
  byte[@input_str][i] := 0
  ios.curon
  repeat                                                'entspricht ab hier ios.input
    n := ios.keywait                                        'auf taste warten
    if n == $0d
       quit
    if (n == ios#CHAR_BS)&(i>0)                             'backspace
       ios.printbs
       i--
       byte[@input_str][i] := 0
    elseif i < input_len                                      'normales zeichen
       ios.printchar(n)
       byte[@input_str][i] := n
       i++
       byte[@input_str][i] := 0
  ios.curoff

PRI readLine(timeout) : complete | ch

  complete := FALSE
  ifnot (ch := ios.lan_rxbyte(handleidx)) == -1
    if readpos == 0                                '1. Zeichen einer Zeile empfangen
      t1char := cnt
    if (ch == 10) and receive_str[readpos-1] == 13 'Zeilenende
      receive_str[readpos-1] := 0
      readpos := 0
      complete := TRUE
      return(complete)
    receive_str[readpos++] := ch
    if readpos == LEN_IRCLINE-1                    'max. Zeilenlänge
      receive_str[readpos] := 0
      readpos := 0
      complete := TRUE
      return(complete)
  if (readpos <> 0) and ((cnt - t1char) / (clkfreq / 1000) > timeout)     'Timeout seit Empfang 1. Zeichen
      receive_str[readpos] := 0
      readpos := 0
      complete := TRUE

PRI sendStr (strSend) : error

'  ios.print(string(" > "))
'  ios.print(strSend)
'  ios.printnl
  error := ios.lan_txdata(handleidx, strSend, strsize(strSend))

PRI delay_ms(Duration)
 waitcnt(clkfreq/1000*Duration + cnt)


DAT

strWin1     byte  "Chat",0
strWin2     byte  "Status",0
strWin3     byte  "Eingabe",0

strConfFile byte  "irc.cfg",0

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
