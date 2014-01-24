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

COL_DEFAULT     = 0    'default Schriftfarbe (Mitteilungstext und Eingabe)
COL_STDEFAULT   = 0    'default Schriftfarbe im Statusfenster
COL_FRAME       = 0    'Fensterrahmen (nicht ausgewählt)
COL_FOCUS       = 3    'Fensterrahmen (ausgewählt/Fokus)
COL_HEAD        = 8    'Titelzeile
COL_TIME        = 8    'aktuelle Zeit in Message-Zeile
COL_STTIME      = 8    'aktuelle Zeit im Status-Fenster
COL_CHAN        = 5    'Channel in Message-Zeile
COL_NICK        = 4    'Nickname in Message-Zeile
COL_MYNICK      = 2    'Nickname in selbst geschriebener Message-Zeile
COL_MSG         = 0    'Text der Message-Zeile
COL_MYMSG       = 6    'Text in selbst geschriebener Message-Zeile

LEN_PASS        = 32
LEN_NICK        = 32
LEN_USER        = 32
LEN_CHAN        = 32
LEN_IRCLINE     = 512

MAX_LINES_WIN1  = 1000  ' maximale Zeilenanzahl im Puffer für Fenster 1 (Chat)
MAX_LINES_WIN2  = 1000  ' maximale Zeilenanzahl im Puffer für Fenster 2 (Status)
MAX_LINES_WIN3  = 100   ' maximale Zeilenanzahl im Puffer für Fenster 3 (Eingabe)

CON 'NVRAM Konstanten --------------------------------------------------------------------------

#4,     NVRAM_IPADDR
#8,     NVRAM_IPMASK
#12,    NVRAM_IPGW
#16,    NVRAM_IPDNS
#20,    NVRAM_IPBOOT
#24,    NVRAM_HIVE       ' 4 Bytes

VAR

  long  t1char                                'Empfangs-Zeitpunkt des 1. Zeichen einer Zeile
  long  ip_addr
  long  hiveid
  long  bufstart[4]
  word  buflinenr[4]
  word  scrolllinenr[4]
  word  ip_port
  word  readpos
  word  sendpos
  byte  handleidx                             'Handle-Nummer IRC Verbindung
  byte  rows,cols,vidmod
  byte  x0[4], y0[4], xn[4], yn[4], hy[4], buflinelen, focus
  byte  password[LEN_PASS+1],nickname[LEN_NICK+1],username[LEN_USER+1],channel[LEN_CHAN+1]
  byte  input_str[64]
  byte  temp_str[256]
  byte  print_str[256]
  byte  print_str_ptr
  byte  send_str[LEN_IRCLINE]
  byte  receive_str[LEN_IRCLINE]

PUB main | key

  init

  repeat
    if ios.keystat > 0
      key := ios.key
      case key
        gc#KEY_TAB:     f_focus
        gc#KEY_CURUP:   f_scrolldown
        gc#KEY_CURDOWN: f_scrollup
        gc#KEY_F02:     f_setconf
        gc#KEY_F03:     f_connect
        gc#KEY_F09:     f_close
        gc#KEY_F10:     f_quit
        other:          if focus == 3
                          f_input(key)

    ifnot handleidx == $FF
      ircGetLine

PRI init

  ip_addr         := 0
  ip_port         := 0
  readpos         := 0
  sendpos         := 0
  handleidx       := $FF
  password[0]     := 0
  nickname[0]     := 0
  username[0]     := 0
  channel[0]      := 0
  send_str[0]     := 0
  focus           := 3

  ios.start                                             'ios initialisieren
  ifnot (ios.admgetspec & LANMASK)
    ios.print(string(13,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",13,"Bitte admnet laden.",13))
    ios.stop
  ios.print(string(13,"Initialisiere, bitte warten...",13))
  setscreen
  conf_load
  if ip_addr == 0
    f_setconf

PRI f_focus

  if ++focus == 4
    focus := 1

  scrolllinenr[1] := 0
  scrolllinenr[2] := 0
  scrolllinenr[3] := 0

  win_contentRefresh
  win_redraw

  ios.winset(3)
  if focus == 3        'Eingabefenster
    ios.curon
  else
    ios.curoff

PRI f_scrollup | lineAddr, lineNum, lineMax

  case focus
    1: lineMax := MAX_LINES_WIN1
    2: lineMax := MAX_LINES_WIN2
    3: lineMax := MAX_LINES_WIN3

  if scrolllinenr[focus] > 0
    ios.winset(focus)
    ios.scrollup
    ios.curpos1
    ios.cursety(yn[focus])

    lineNum := buflinenr[focus] - --scrolllinenr[focus] - 1                         'Nummer hereinngescrollte neue Zeile
    if lineNum < 0
      lineNum += lineMax
    lineAddr := bufstart[focus] + (lineNum * buflinelen)                            'Adresse im eRAM (Usermode)

    printBufWin(lineAddr)

PRI f_scrolldown | lineAddr, lineNum, lineMax

  case focus
    1: lineMax := MAX_LINES_WIN1
    2: lineMax := MAX_LINES_WIN2
    3: lineMax := MAX_LINES_WIN3

  if scrolllinenr[focus] < lineMax - yn[focus] + y0[focus] - 1
    ios.winset(focus)
    ios.scrolldown
    ios.curhome

    lineNum := buflinenr[focus] - ++scrolllinenr[focus] - yn[focus] + y0[focus] - 1 'Nummer hereinngescrollte neue Zeile
    if lineNum < 0
      lineNum += lineMax
    lineAddr := bufstart[focus] + (lineNum * buflinelen)                            'Adresse im eRAM (Usermode)

    printBufWin(lineAddr)

PRI f_setconf | i,n

  ifnot confServer
    return(TRUE)
  confPass
  confNick
  confUser
  confChannel

  win_contentRefresh
  confSave

PRI f_connect

  ircConnect
  ircPass
  ircReg
  ircJoin

PRI f_close

  ircClose

PRI f_quit

  f_close
  ios.winset(0)
  ios.screeninit
  ios.stop

PRI f_input(key)

  case key
    $0d:                if strsize(@send_str) > 0                          'Zeilenende, absenden
                          ircPutLine
                          ios.winset(3)
                          ios.printnl
                          sendpos := 0
                          send_str[0] := 0
    ios#CHAR_BS:        if sendpos > 0                                     'backspace
                          ios.winset(3)
                          ios.printbs
                          sendpos--
                          send_str[sendpos] := 0
    9 .. 13, 32 .. 255: if sendpos < LEN_IRCLINE-2                         'normales zeichen
                          ios.winset(3)
                          ios.printchar(key)
                          send_str[sendpos] := key
                          sendpos++
                          send_str[sendpos] := 0

PRI confServer

  if ip_addr == 0
    temp_str[0] := 0
  else
    IpPortToStr(ip_addr, ip_port)
  input(string("IRC-Server angeben (IP:Port):"),@temp_str ,21)
  ifnot strToIpPort(@input_str, @ip_addr, @ip_port)
    handleStatusStr(string("Fehlerhafte Eingabe von IP-Adresse und Port des IRC-Servers."), 2, TRUE)
    return (FALSE)
  return(TRUE)

PRI confPass | i,n

  input(string("Paßwort eingeben:"),@password,LEN_PASS)
  n := 1
  repeat i from 0 to LEN_PASS
    if n == 0
      password[i] := 0
    else
      n := input_str[i]
      password[i] := n

PRI confNick | i,n

  input(string("Nickname eingeben:"),@nickname,LEN_NICK)
  n := 1
  repeat i from 0 to LEN_NICK
    if n == 0
      nickname[i] := 0
    else
      n := input_str[i]
      nickname[i] := n

PRI confUser | i,n

  input(string("Username eingeben:"),@username,LEN_USER)
  n := 1
  repeat i from 0 to LEN_USER
    if n == 0
      username[i] := 0
    else
      n := input_str[i]
      username[i] := n

PRI confChannel | i,n

  input(string("Channel eingeben:"),@channel,LEN_CHAN)
  n := 1
  repeat i from 0 to LEN_CHAN
    if n == 0
      channel[i] := 0
    else
      n := input_str[i]
      channel[i] := n

PRI confSave | i

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

  handleStatusStr(string("Konfiguration gespeichert."), 2, TRUE)

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

  hiveid := ios.getNVSRAM(NVRAM_HIVE)
  hiveid += ios.getNVSRAM(NVRAM_HIVE+1) << 8
  hiveid += ios.getNVSRAM(NVRAM_HIVE+2) << 16
  hiveid += ios.getNVSRAM(NVRAM_HIVE+3) << 24

PRI ircConnect | t

  handleStatusStr(string("Verbinde mit IRC-Server..."), 2, TRUE)
  ios.lanstart
  if (handleidx := ios.lan_connect(ip_addr, ip_port)) == $FF
    handleStatusStr(string("Kein Socket frei!"), 2, TRUE)
    return(-1)
  ifnot (ios.lan_waitconntimeout(handleidx, 2000))
    handleStatusStr(string("Verbindung mit IRC-Server konnte nicht aufgebaut werden."), 2, TRUE)
    f_close
    return(-1)
  handleStatusStr(string("Verbunden, warte auf Bereitschaft..."), 2, TRUE)

  t := cnt
  repeat until (cnt - t) / clkfreq > 1    '1s lang Meldungen des Servers entgegennehmen
    ircGetline

PRI ircClose

  ifnot handleidx == $FF
    ios.lan_close(handleidx)
    handleidx := $FF
    handleStatusStr(string("Verbindung mit IRC-Server getrennt..."), 2, TRUE)

PRI ircPass

  handleStatusStr(string("Sende Paßwort..."), 2, TRUE)
  if sendStr(string("PASS ")) or sendStr(@password) or sendStr(string(13,10))
    handleStatusStr(string("Fehler beim Senden des Paßwortes"), 2, TRUE)
    return(-1)

PRI ircReg

  if strsize(@channel) == 0
    handleStatusStr(string("Sende Nickname und Benutzerinformationen..."), 2, TRUE)
  else
    handleStatusStr(string("Sende Nickname und Benutzer, verbinde mit Channel..."), 2, TRUE)

  if sendStr(string("NICK ")) or sendStr(@nickname) or sendStr(string(13,10))
    handleStatusStr(string("Fehler beim Senden des Nicknamens"), 2, TRUE)
    return(-1)

  if sendStr(string("USER ")) or sendStr(@username) or sendStr(string(" 8 * :Hive #")) or sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC))) or sendStr(string(13,10))
    handleStatusStr(string("Fehler beim Senden der Benutzerinformationen"), 2, TRUE)
    return(-1)

  waitcnt(cnt + clkfreq)        '1sek warten

PRI ircJoin

  ifnot strsize(@channel) == 0
    if sendStr(string("JOIN ")) or sendStr(@channel) or sendStr(string(13,10))
      handleStatusStr(string("Fehler beim Verbinden mit Channel"), 2, TRUE)
      return(-1)

PRI ircGetLine | i, x, prefixstr, nickstr, chanstr, msgstr, commandstr

  if readLine(2000) 'vollständige Zeile empfangen

    if receive_str[0] == ":"                                                  'Prefix folgt (sollte jede hereinkommende Message enthalten)
      prefixstr := @receive_str[1]
      ifnot (commandstr := str.replaceCharacter(prefixstr, " ", 0))           'nächstes Leerzeichen ist Ende des Prefix, dann folgt das Kommando
        return(FALSE)
    else                                                                      'kein Prefix
      prefixstr := 0
      commandstr := @receive_str                                              'es geht gleich mit dem Kommando los

    if str.findCharacters(commandstr, string("PRIVMSG ")) == commandstr       'Chat Message
      chanstr := commandstr + 8
      if (msgstr := str.replaceCharacter(chanstr, " ", 0))
        msgstr++
        nickstr := @receive_str[1]
          if str.replaceCharacter(nickstr, "!", 0)
            ' check for CTCP
            i := strsize(msgstr)
            if byte[msgstr] == 1 AND byte[msgstr][i - 1] == 1
              ' it's a CTCP msg
              byte[msgstr][i - 1] := 0                                        ' move string end up one spot
              msgstr++                                                        ' seek past the CTCP byte
              handleCTCPStr(nickstr, msgstr)
              if strcomp(msgstr, string("VERSION"))                           'Versions-Anfrage
                sendStr(string("NOTICE "))
                sendStr(nickstr)
                sendStr(string(" :VERSION HiveIRC 1.0.0 [P8X32A/80MHz] <http://hive-project.de/>",13,10))
            else
              if byte[chanstr] == "#"                                         'Message an Channel
                handleChatStr(chanstr, nickstr, msgstr, 0)
              else                                                            'Message an mich
                handleChatStr(string("<priv>"), nickstr, msgstr, 2)
    elseif str.findCharacters(commandstr, string("PING :")) == commandstr     'PING
      handleStatusStr(string("PING erhalten, sende PONG"), 2, TRUE)
      byte[commandstr][1] := "O"
      sendStr(commandstr)
      sendStr(string(13,10))
    elseif str.findCharacters(commandstr, string("JOIN :")) == commandstr     'JOIN
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := string(" hat den Kanal betreten")
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif str.findCharacters(commandstr, string("QUIT :")) == commandstr     'QUIT
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := string(" hat den Kanal verlassen")
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif byte[commandstr][3] == " "                                         'Kommando 3 Zeichen lang -> 3stelliger Returncode
      byte[commandstr][3] := 0
      nickstr := commandstr + 4
      msgstr := str.replaceCharacter(nickstr, " ", 0)
      case num.FromStr(commandstr, num#DEC)
        372:   handleStatusStr(msgstr + 3, 1, FALSE)                          'MOTD
        375..376:
        other:    repeat x from 0 to strsize(commandstr) - 1                  'unbehandelter Return-Code
                    temp_str[x] := byte[commandstr][x]
                  temp_str[x++] := ":"
                  temp_str[x++] := " "
                  repeat i from 0 to strsize(msgstr) - 1
                    temp_str[x++] := byte[msgstr][i]
                    if x == 127
                      quit
                  temp_str[x] := 0
                  handleStatusStr(@temp_str, 2, TRUE)
    else                                                                      'unbekanntes Kommando
      handleStatusStr(commandstr, 2, FALSE)

PRI ircPutLine | i

  if str.startsWithCharacters(@send_str, string("/set"))      'alle Einstellungen ändern und speichern
    f_setconf
  elseif str.startsWithCharacters(@send_str, string("/save")) 'Konfiguration speichern
    confSave
  elseif str.startsWithCharacters(@send_str, string("/srv"))  'mit Server verbinden
    if confServer                                             'wenn Eingabe IP und Port korrekt
      win_contentRefresh
      ircClose                                                'bei bestehender Verbindung diese beenden
      ircConnect
      ircPass
      ircReg
    else
      win_contentRefresh
  elseif str.startsWithCharacters(@send_str, string("/quit")) 'Verbindung mit Server trennen
    ircClose
  elseif str.startsWithCharacters(@send_str, string("/pass")) 'Paßwort ändern
    confPass
    win_contentRefresh
  elseif str.startsWithCharacters(@send_str, string("/nick")) 'Nickname ändern
    confNick
    win_contentRefresh
  elseif str.startsWithCharacters(@send_str, string("/user")) 'User ändern
    confUser
    win_contentRefresh
  elseif str.startsWithCharacters(@send_str, string("/join")) 'mit Channel verbinden
    confChannel
    win_contentRefresh
    ircJoin
  elseif str.startsWithCharacters(@send_str, string("/part")) 'Channel verlassen
    sendStr(string("PART "))
    sendStr(@channel)
    if send_str[5] == " "
      sendStr(@send_str[5])
    sendStr(string(13,10))
    channel[0] := 0
    handleChatStr(@channel, @nickname, @send_str, 1)
  elseif str.startsWithCharacters(@send_str, string("/msg"))  'Message an Nickname
    sendStr(string("PRIVMSG "))
    if (i := str.replaceCharacter(@send_str[5], " ", 0))
      sendStr(@send_str[5])
      sendStr(string(" :"))
      sendStr(i)
      sendStr(string(13,10))
      handleChatStr(@send_str[5], @nickname, i, 1)
  elseif send_str[0] == "/"                                   'anderes IRC-Kommando an Server
    sendStr(@send_str[1])
    sendStr(string(13,10))
    handleChatStr(@channel, @nickname, @send_str, 1)
  else                                                        'Message an Channel
    sendStr(string("PRIVMSG "))
    sendStr(@channel)
    sendStr(string(" :"))
    sendStr(@send_str)
    sendStr(string(13,10))
    handleChatStr(@channel, @nickname, @send_str, 1)

PRI frame_draw

  ios.winset(0)
  ios.curoff
  ios.printcls
  ios.cursetx(W0X_MENU)
  ios.cursety(W0Y_MENU)
  ios.setcolor(COL_HEAD)
  ios.print(string(" IRC Client"))
  repeat cols-W0X_MENU-11
    ios.printchar(" ")
  ios.printlogo(0,0)

PRI win_draw | i

  repeat i from 1 to 3
    ios.windefine(i,x0[i],y0[i],xn[i],yn[i])
    ios.winset(i)
    ios.curoff
    ios.printcls
    if i == focus
      ios.setcolor(COL_FOCUS)
    else
      ios.setcolor(COL_FRAME)
    ios.winoframe
    ios.winset(0)
    ios.cursetx(2)
    ios.cursety(hy[i])
    if i == focus
      ios.setcolor(COL_FOCUS)
    else
      ios.setcolor(COL_FRAME)
    case i
      1: ios.print(@strWin1)
      2: ios.print(@strWin2)
      3: ios.print(@strWin3)

  ios.winset(3)
    ios.curon

PRI win_redraw | i

  repeat i from 1 to 3
    ios.winset(i)
    if i == focus
      ios.setcolor(COL_FOCUS)
    else
      ios.setcolor(COL_FRAME)
    ios.winoframe
    ios.winset(0)
    ios.cursetx(2)
    ios.cursety(hy[i])
    if i == focus
      ios.setcolor(COL_FOCUS)
    else
      ios.setcolor(COL_FRAME)
    case i
      1: ios.print(@strWin1)
      2: ios.print(@strWin2)
      3: ios.print(@strWin3)

PRI win_contentRefresh | win, lines, lineNum
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Fensterinhalt neu aufbauen                                                                                               │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat win from 1 to 2
    lines := yn[win] - y0[win] + 1  '???
    if buflinenr[win] => lines
      lineNum := buflinenr[win] - lines                                 'Nummer erste anzuzeigende Zeile
    else
      case win
        1: lineNum := MAX_LINES_WIN1 + buflinenr[win] - lines
        2: lineNum := MAX_LINES_WIN2 + buflinenr[win] - lines
    ios.winset(win)
    ios.printcls
    printBufWin(bufstart[win] + (lineNum * buflinelen))
    repeat lines - 1
      lineNum++
      if lineNum == MAX_LINES_WIN1
        lineNum := 0
      ios.printnl
      printBufWin(bufstart[win] + (lineNum * buflinelen))

PRI setscreen | buflen[4], i

  vidmod     := ios.belgetspec & 1
  rows       := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols       := ios.belgetcols                                'spaltenzahl bei bella abfragen
  buflinelen := cols + 20                                     'Länge einer Zeile im Fensterpuffer

  print_str[0] := 0                                           'leerer print_str (zum Leeren Fensterpuffer)
  print_str[1] := 0
  print_str[2] := 0

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
  buflinenr[1]    := 0
  scrolllinenr[1] := 0
  bufstart[1]     := 0
  buflen[1]       := buflinelen * MAX_LINES_WIN1
  repeat i from 0 to MAX_LINES_WIN1 - 1             'Fensterpuffer leeren
    printStrBuf(1)

  'Status-Fenster (Nr. 2)
  x0[2] := 1
  y0[2] := rows-7
  xn[2] := cols-2
  yn[2] := rows-4
  hy[2] := rows-8
  buflinenr[2]    := 0
  scrolllinenr[2] := 0
  bufstart[2]     := bufstart[1] + buflen[1]
  buflen[2]       := buflinelen * MAX_LINES_WIN2
  repeat i from 0 to MAX_LINES_WIN2 - 1             'Fensterpuffer leeren
    printStrBuf(2)

  'Eingabe-Fenster (Nr. 3)
  x0[3] := 1
  y0[3] := rows-2
  xn[3] := cols-2
  yn[3] := rows-2
  hy[3] := rows-3
  buflinenr[3]    := 0
  scrolllinenr[3] := 0
  bufstart[3]     := bufstart[2] + buflen[2]
  buflen[3]       := buflinelen * MAX_LINES_WIN3
  repeat i from 0 to MAX_LINES_WIN3 - 1             'Fensterpuffer leeren
    printStrBuf(3)

  frame_draw
  win_draw

  'Eingabe-Fenster (Nr. 4)
  ios.windefine(4,13,10,47,13)

PRI printTime | timeStr, i
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ aktuelle Zeit in print_str schreiben                                                                                     │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  print_str[print_str_ptr++] := "["
  timeStr := str.trimCharacters(str.numberToDecimal(ios.getHours, 2))
  repeat i from 0 to 1
    print_str[print_str_ptr++] := byte[timeStr][i]
  print_str[print_str_ptr++] := ":"
  timeStr := str.trimCharacters(str.numberToDecimal(ios.getMinutes, 2))
  repeat i from 0 to 1
    print_str[print_str_ptr++] := byte[timeStr][i]
  print_str[print_str_ptr++] := "]"

PRI handleChatStr(chanstr, nickstr, msgstr, me) | i, channicklen, msglineend, ch, space
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Chat-Zeile erstellen, anzeigen und in Puffer schreiben                                                                   │
'' |                                                                                                                          |
'' | Aufbau: <Farbbyte1><String1>0<Farbbyte2><String2>0 ... <FarbbyteN><StringN>000                                           |
'' |                                                                                                                          |
'' |     me: 0 - nicht von mir / an mich                                                                                      |
'' |         1 - von mir                                                                                                      |
'' |         2 - an mich                                                                                                      |
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  ios.winset(1)
  print_str_ptr := 0         ' String neu beginnen

  '1. Teilstring: Zeit
  print_str[print_str_ptr++] := COL_TIME     'Farbbyte
  printTime
  print_str[print_str_ptr++] := 0

 '2. Teilstring: Channel
  if me == 2
    print_str[print_str_ptr++] := COL_MYNICK 'Farbbyte
  else
    print_str[print_str_ptr++] := COL_CHAN   'Farbbyte
  repeat i from 0 to strsize(chanstr)        'Länge Channel inkl. Abschluß-Null
    print_str[print_str_ptr++] := byte[chanstr][i]

 '3. Teilstring: Nickname
  if me == 1
    print_str[print_str_ptr++] := COL_MYNICK  'Farbbyte
  else
    print_str[print_str_ptr++] := COL_NICK    'Farbbyte
  print_str[print_str_ptr++] := ">"
  repeat i from 0 to strsize(nickstr)        'Länge Nickname inkl. Abschluß-Null
    print_str[print_str_ptr++] := byte[nickstr][i]

 '4. Teilstring: 1. Teil  der Mitteilung
  if me == 1
    print_str[print_str_ptr++] := COL_MYMSG   'Farbbyte
  else
    print_str[print_str_ptr++] := COL_MSG     'Farbbyte
  print_str[print_str_ptr++] := ":"
  print_str[print_str_ptr++] := " "
  channicklen := strsize(chanstr) + strsize(nickstr) + 10
  msglineend := cols - channicklen -2
  repeat
    if strsize(msgstr) =< msglineend          'msgline paßt auf Zeile
      repeat i from 0 to strsize(msgstr)      'Länge Mitteilung inkl. Abschluß-Null
        print_str[print_str_ptr++] := byte[msgstr][i]
      print_str[print_str_ptr++] := 0         'komplette Chat-Zeile fertig
      print_str[print_str_ptr] := 0
      print_str_ptr := 0
      if scrolllinenr[1] == 0                 'Chat-Fenster nicht gescrollt
        ios.printnl
        printStrWin(@print_str)
      printStrBuf(1)
      quit
    else                                      'msgline muß umgebrochen werden
      ch := byte[msgstr][msglineend]               'Zeichen am Zeilenende sichern
      byte[msgstr][msglineend] := 0                'Messagestring am Zeilenende abschließen
      if (space := findCharacterBack(msgstr, " ")) 'wenn letztes Leerzeichen in msgstr gefunden
        byte[msgstr][msglineend] := ch             'Zeichen am Zeilenende wieder einfügen
        byte[space] := 0                           'msgstr am letzten Leerzeichen abschließen
        repeat i from 0 to strsize(msgstr)         'und in print_str schreiben
          print_str[print_str_ptr++] := byte[msgstr][i]
        print_str[print_str_ptr++] := 0            'komplette Chat-Zeile fertig, weitere folgt
        print_str[print_str_ptr] := 0
        print_str_ptr := 0
        if scrolllinenr[1] == 0
          ios.printnl
          printStrWin(@print_str)
        printStrBuf(1)
      else                                         'kein einziges Leerzeichen
        repeat i from 0 to strsize(msgstr)         'in print_str schreiben
          print_str[print_str_ptr++] := byte[msgstr][i]
        print_str[print_str_ptr++] := 0            'komplette Chat-Zeile fertig, weitere folgt
        print_str[print_str_ptr] := 0
        print_str_ptr := 0
        if scrolllinenr[1] == 0
          ios.printnl
          printStrWin(@print_str)
        printStrBuf(1)
      if me == 1
        print_str[print_str_ptr++] := COL_MYMSG    'nach Zeilenumbruch beginnt neue Zeile wieder mit Farbbyte
      else
        print_str[print_str_ptr++] := COL_MSG
      repeat channicklen                           '"Tab" bis Ende Anzeige Channel + Nickname
        print_str[print_str_ptr++] := " "
      if space
        msgstr := space + 1
      else
        print_str[print_str_ptr++] := ch           'am Zeilenende entferntes Zeichen hier einfügen
        msgstr += msglineend + 1

PRI handleCTCPStr(nickstr, msgstr) | i, msglineend

  ios.winset(1)
  print_str_ptr := 0         ' String neu beginnen

  '1. Teilstring: Zeit
  print_str[print_str_ptr++] := COL_TIME     'Farbbyte
  printTime
  print_str[print_str_ptr++] := 0

 '3. Teilstring: Nickname
  print_str[print_str_ptr++] := COL_NICK     'Farbbyte
  print_str[print_str_ptr++] := ">"
  repeat i from 0 to strsize(nickstr)        'Länge Nickname inkl. Abschluß-Null
    print_str[print_str_ptr++] := byte[nickstr][i]

 '3. Teilstring: CTCP Mitteilung
  print_str[print_str_ptr++] := COL_DEFAULT 'Farbbyte
  print_str[print_str_ptr++] := ":"
  print_str[print_str_ptr++] := " "
  msglineend := cols - strsize(nickstr) - 8
  if strsize(msgstr) =< msglineend
    msglineend := strsize(msgstr)          'msgline kürzer wie restliche Zeile
  else
    byte[msgstr][msglineend] := 0          'länger, abschneiden
  repeat i from 0 to msglineend
    print_str[print_str_ptr++] := byte[msgstr][i]
  print_str[print_str_ptr++] := 0         'komplette Chat-Zeile fertig
  print_str[print_str_ptr] := 0
  print_str_ptr := 0
  if scrolllinenr[1] == 0
    ios.printnl
    printStrWin(@print_str)
  printStrBuf(1)

PRI handleStatusStr(statusstr, win, showtime) | i, statlineend
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Status-Zeile erstellen, anzeigen und in Puffer schreiben                                                                 │
'' |                                                                                                                          |
'' | Aufbau: <Farbbyte1><String1>0<Farbbyte2><String2>0 ... <FarbbyteN><StringN>000                                           |
'' |                                                                                                                          |
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  ios.winset(win)
  print_str_ptr := 0         ' String neu beginnen

  '1. Teilstring: Zeit
  if showtime
    print_str[print_str_ptr++] := COL_STTIME     'Farbbyte
    printTime
    print_str[print_str_ptr++] := " "
    print_str[print_str_ptr++] := 0

   '2. Teilstring: Status
  print_str[print_str_ptr++] := COL_STDEFAULT    'Farbbyte
  if showtime
    statlineend := cols - 10
  else
    statlineend := cols - 2
  if strsize(statusstr) > statlineend            'statusline länger wie restliche Zeile
    byte[statusstr][statlineend] := 0            'abschneiden
  repeat i from 0 to strsize(statusstr)
    print_str[print_str_ptr++] := byte[statusstr][i]
  print_str[print_str_ptr++] := 0                'komplette Status-Zeile fertig
  print_str[print_str_ptr] := 0
  print_str_ptr := 0
  if scrolllinenr[win] == 0
    ios.printnl
    printStrWin(@print_str)
  printStrBuf(win)

PRI printStrWin(printStr) | i
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Chat-Zeile in aktuellem Fenster zeigen                                                                                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  i := 0
  repeat
    if byte[printStr][i] == 0 and byte[printStr][i+1] == 0 'nichts mehr anzuzeigen, Ende
      quit
    ios.setcolor(byte[printStr][i++])                      'ersten Byte vom Teilstring ist die Farbe
    ios.print(printStr + i)                                'restlichen String anzeigen
    i += strsize(printStr + i) + 1                         'i zeigt auf nächsten Teilstring

  ios.curpos1                                              'ohne diesen befehl wird, wenn letztes Zeichen ganz am Ende steht
                                                           'bei einem ios.printnl eine zusätzliche Leerzeile angezeigt

PRI printStrBuf(win) | lineAddr, lineMax, i
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Chat-Zeile in Fenster-Puffer schreiben                                                                                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  case win
    1: lineMax := MAX_LINES_WIN1
    2: lineMax := MAX_LINES_WIN2
    3: lineMax := MAX_LINES_WIN3

  lineAddr := bufstart[win] + (buflinenr[win]++ * buflinelen)     'Adresse Zeilenbeginn im eRAM (Usermode)
  if buflinenr[win] == lineMax
    buflinenr[win] := 0

  i := 0
  repeat
    ios.ram_wrbyte(1,print_str[i],lineAddr++)
    if print_str[i] == 0 and print_str[i+1] == 0 and print_str[i+2] == 0    'Ende Teilstring und Ende Komplettstring
      ios.ram_wrbyte(1,0,lineAddr++)                                        'auch Abschluß-Nullen in Puffer schreiben
      ios.ram_wrbyte(1,0,lineAddr)
      quit
    i++

PRI printBufWin(lineAddr) | i

  repeat i from 0 to buflinelen
    if (temp_str[i] := ios.ram_rdbyte(1,lineAddr++)) == 0
      if i > 1
        if (temp_str[i-1] == 0) and (temp_str[i-2] == 0)
          quit

  printStrWin(@temp_str)

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

PRI readLine(timeout) : ch

  ifnot (ch := ios.lan_rxbyte(handleidx)) == -1
    if readpos == 0                                '1. Zeichen einer Zeile empfangen
      t1char := cnt
    if (ch == 10) and receive_str[readpos-1] == 13 'Zeilenende
      receive_str[readpos-1] := 0
      readpos := 0
      return(TRUE)
    receive_str[readpos++] := ch
    if readpos == LEN_IRCLINE-1                    'max. Zeilenlänge erreicht
      receive_str[readpos] := 0
      readpos := 0
      return(TRUE)

  if (readpos <> 0) and ((cnt - t1char) / (clkfreq / 1000) > timeout)     'Timeout seit Empfang 1. Zeichen
      receive_str[readpos] := 0
      readpos := 0
      return(TRUE)

  return(FALSE)

PRI sendStr (strSend) : error

'  ios.print(string(" > "))
'  ios.print(strSend)
'  ios.printnl
  error := ios.lan_txdata(handleidx, strSend, strsize(strSend))

PUB findCharacterBack(charactersToSearch, characterToFind) | i

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Searches a string of characters for the last occurence of the specified character.                                       │
'' │                                                                                                                          │
'' │ Returns the address of that character if found and zero if not found.                                                    │
'' │                                                                                                                          │
'' │ CharactersToSearch - A pointer to the string of characters to search.                                                    │
'' │ CharacterToFind    - The character to find in the string of characters to search.                                        │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  i := strsize(charactersToSearch)

  repeat i
    if(byte[charactersToSearch][--i] == characterToFind)
      return charactersToSearch + i

  return 0

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
