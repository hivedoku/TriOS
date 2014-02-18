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
        led: "led-engine"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

CON

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
COL_PRIVNICK    = 7    'Nickname in privater Message-Zeile
COL_MSG         = 0    'Text der Message-Zeile
COL_MYMSG       = 6    'Text in selbst geschriebener Message-Zeile
COL_PRIVMSG     = 7    'Text in privater Message-Zeile

LEN_PASS        = 32
LEN_NICK        = 32
LEN_USER        = 32
LEN_CHAN        = 32
LEN_IRCLINE     = 512
LEN_IRCSRV      = 64

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

DAT

  strNVRAMFile byte  "nvram.sav",0                      'contains the 56 bytes of NVRAM, if RTC is not available

VAR

  long  t1char                                'Empfangs-Zeitpunkt des 1. Zeichen einer Zeile
  long  secsrvact                             'Sekunden seit letzter Server-Aktivität
  long  ip_addr
  long  hiveid
  long  ledcog
  long  bufstart[4]
  long  ledstack[30]                          'Stack für LED-Cog
  word  buflinenr[4]
  word  scrolllinenr[4]
  word  ip_port
  word  readpos
  word  sendpos
  byte  handleidx                             'Handle-Nummer IRC Verbindung
  byte  rows,cols,vidmod
  byte  reconnect
  byte  joined
  byte  x0[4], y0[4], xn[4], yn[4], buflinelen, focus
  byte  password[LEN_PASS+1],nickname[LEN_NICK+1],username[LEN_USER+1],channel[LEN_CHAN+1],ircsrv[LEN_IRCSRV+1]
  byte  input_str[64]
  byte  temp_str[256]
  byte  print_str[256]
  byte  print_str_ptr
  byte  send_str[LEN_IRCLINE]
  byte  receive_str[LEN_IRCLINE]
  byte  brightness
  byte  newMsg

PUB main | key, t

  init

  repeat
    if ios.keystat > 0
      if newMsg                        'neue Mitteilung wurde signalisiert
        newMsg := FALSE
        ledStop
      key := ios.key
      case key
        gc#KEY_TAB:     f_focus
        gc#KEY_CURUP:   f_scrolldown
        gc#KEY_CURDOWN: f_scrollup
        gc#KEY_F01:     f_help
        gc#KEY_F02:     f_setconf
        gc#KEY_F03:     f_connect
        gc#KEY_F04:     f_join
        gc#KEY_F05:     f_part
        gc#KEY_F06:     f_nick
        gc#KEY_F07:     f_user
        gc#KEY_F08:     f_pass
        gc#KEY_F09:     f_close
        gc#KEY_F10:     f_quit
        other:          if focus == 3
                          f_input(key)

    ifnot handleidx == $FF                    'bei bestehender Verbindung...
      if ((cnt - t) / clkfreq) > 1            'nach jeder Sekunde...
        t := cnt
        if secsrvact++ > 60                   'nach 60 Sekunden Inaktivität
          sendStr(string("PING HIVE"))
          sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC)))
          sendStr(string(13,10))
          secsrvact := 0                      'Sekunden seit letzter Serveraktivität zurücksetzen
      ircGetLine
    elseif reconnect                          'wenn Verbindung unterbrochen wurde
      if ((cnt - t) / clkfreq) > 1            'nach jeder Sekunde...
        t := cnt
        if secsrvact++ > 60                   'nach 60 Sekunden
          handleStatusStr(@strReconnect, 2, TRUE)
          f_connect
          secsrvact := 0                      'Sekunden zurücksetzen

PRI init

  ip_addr         := 0
  ip_port         := 0
  readpos         := 0
  sendpos         := 0
  ledcog          := 0
  handleidx       := $FF
  password[0]     := 0
  nickname[0]     := 0
  username[0]     := 0
  channel[0]      := 0
  send_str[0]     := 0
  ircsrv[0]       := 0
  focus           := 3
  reconnect       := FALSE
  joined          := FALSE
  newMsg          := FALSE

  ios.start                                             'ios initialisieren
  ifnot (ios.belgetspec & (gc#b_key|gc#b_txt|gc#b_win)) 'Wir brauchen Bellatrix mit Keyboard-, Text- und Fensterfunktionen
    ios.belreset                                        'Bellatrix neu starten (aus ROM laden)
    ios.print(@strInitWait)
    ifnot (ios.belgetspec & (gc#b_key|gc#b_txt|gc#b_win))
      ios.print(@strWrongBel)                           'Bellatrix-Flash enthält nicht die nötige Version
      ios.stop                                          'Ende
  else
    ios.print(@strInitWait)
  ios.sdmount
  ifnot (ios.admgetspec & gc#A_LAN)                     'Administra stellt kein Netzwerk zur Verfügung
    ios.sddmset(ios#DM_USER)                            'u-marker setzen
    ios.sddmact(ios#DM_SYSTEM)                          's-marker aktivieren
    ios.admload(string("admnet.adm"))                   'versuche, admnet zu laden
    ios.sddmact(ios#DM_USER)                            'u-marker aktivieren
    ifnot (ios.admgetspec & gc#A_LAN)                   'wenn Laden fehlgeschlagen
      ios.print(@strNoNetwork)
      ios.stop                                          'Ende
  setscreen
  conf_load
  if ip_addr == 0
    ifnot f_setconf
      handleStatusStr(@strRestartConf, 2, FALSE)

  'sfx-slots setzen
  ios.sfx_setslot(@soundNewMgs, 0)

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

  if (scrolllinenr[focus] > 0) and (focus <> 3)
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

  if (scrolllinenr[focus] < lineMax - yn[focus] + y0[focus] - 1) and (focus <> 3)
    ios.winset(focus)
    ios.scrolldown
    ios.curhome

    lineNum := buflinenr[focus] - ++scrolllinenr[focus] - yn[focus] + y0[focus] - 1 'Nummer hereinngescrollte neue Zeile
    if lineNum < 0
      lineNum += lineMax
    lineAddr := bufstart[focus] + (lineNum * buflinelen)                            'Adresse im eRAM (Usermode)

    printBufWin(lineAddr)

PRI f_help

  ios.winset(5)
  ios.printcls
  ios.winoframe
  ios.curhome
  ios.curoff
  ios.setcolor(COL_DEFAULT)
  ios.print(@strHelp)
  repeat until ios.keystat > 0
    waitcnt(cnt + clkfreq)        '1sek warten
  ios.key
  win_redraw
  win_contentRefresh

PRI f_setconf | i,n

  ifnot confServer
    win_contentRefresh
    return(FALSE)
  confPass
  confNick
  confUser
  confChannel

  win_contentRefresh
  confSave

PRI f_connect

  ircClose      'Falls bereits eine Verbindung besteht
  ircConnect
  ircPass
  ircReg
  ircJoin

PRI f_join

  if joined
    handleStatusStr(@strAlreadyJoined, 2, FALSE)
  else
    confChannel
    win_contentRefresh
    ircJoin

PRI f_part

  ircPart(0)
  handleChatStr(@channel, @nickname, string("/part"), 1)

PRI f_nick

  confNick
  win_contentRefresh
  ircNick

PRI f_user

  confUser
  win_contentRefresh
  handleStatusStr(@strUserChanged, 2, FALSE)

PRI f_pass

  confPass
  win_contentRefresh
  handleStatusStr(@strPassChanged, 2, FALSE)

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
                          sendpos := 0
                          send_str[0] := 0
                          if yn[3]-y0[3] > 0                               'if changed, reset window sizes
                            yn[1] := rows-9
                            y0[2] := rows-7
                            yn[2] := rows-4
                            y0[3] := rows-2
                            yn[3] := rows-2
                            ios.windefine(1,x0[1],y0[1],xn[1],yn[1])
                            ios.windefine(2,x0[2],y0[2],xn[2],yn[2])
                            ios.windefine(3,x0[3],y0[3],xn[3],yn[3])
                            win_redraw
                            win_contentRefresh
                          ios.winset(3)
                          ios.printcls
    ios#CHAR_BS:        if sendpos > 0                                     'backspace
                          sendpos--
                          send_str[sendpos] := 0
                          ios.winset(3)
                          if ios.curgetx == 1                              'cursor at the beginning of line
                            if yn[1] < rows-9                              'chat window is smaller
                              yn[1]++                                      'make chat window 1 line higher
                              ios.windefine(1,x0[1],y0[1],xn[1],yn[1])
                              y0[2]++
                              yn[2]++                                      'move status window 1 line down
                              ios.windefine(2,x0[2],y0[2],xn[2],yn[2])
                            else
                              yn[2]++                                      'make status window 1 line higher
                              ios.windefine(2,x0[2],y0[2],xn[2],yn[2])
                            y0[3]++                                        'make input window 1 line smaller
                            ios.windefine(3,x0[3],y0[3],xn[3],yn[3])
                            win_redraw
                            win_contentRefresh
                          else
                            ios.winset(3)
                            ios.printbs
    9 .. 13, 32 .. 255: if sendpos < LEN_IRCLINE-2                         'normales zeichen
                          send_str[sendpos] := key
                          sendpos++
                          send_str[sendpos] := 0
                          if ios.curgetx == cols - 2                       'cursor at line end
                            if yn[2]-y0[2] > 0                             'status window has more than 1 line
                              yn[2]--                                      'make status window 1 line smaller
                              ios.windefine(2,x0[2],y0[2],xn[2],yn[2])
                            else
                              yn[1]--                                      'make chat window 1 line smaller
                              ios.windefine(1,x0[1],y0[1],xn[1],yn[1])
                              y0[2]--
                              yn[2]--                                      'move status window 1 line up
                              ios.windefine(2,x0[2],y0[2],xn[2],yn[2])
                            y0[3]--                                        'make input window 1 line higher
                            ios.windefine(3,x0[3],y0[3],xn[3],yn[3])
                            win_redraw
                            win_contentRefresh
                          elseif (ios.curgetx == 1) and yn[3]-y0[3] > 0    'first char in next line
                            win_contentRefresh                             'word wrap
                          else
                            ios.winset(3)
                            ios.printchar(key)

PRI confServer

  if ip_addr == 0
    temp_str[0] := 0
  else
    IpPortToStr(ip_addr, ip_port)
  input(@strInputSrv,@temp_str ,21)
  ifnot strToIpPort(@input_str, @ip_addr, @ip_port)
    handleStatusStr(@strErrorAddr, 2, FALSE)
    return (FALSE)
  return(TRUE)

PRI confPass | i,n

  input(@strInputPass,@password,LEN_PASS)
  n := 1
  repeat i from 0 to LEN_PASS
    if n == 0
      password[i] := 0
    else
      n := input_str[i]
      password[i] := n

PRI confNick | i,n

  input(@strInputNick,@nickname,LEN_NICK)
  n := 1
  repeat i from 0 to LEN_NICK
    if n == 0
      nickname[i] := 0
    else
      n := input_str[i]
      nickname[i] := n

PRI confUser | i,n

  input(@strInputUser,@username,LEN_USER)
  n := 1
  repeat i from 0 to LEN_USER
    if n == 0
      username[i] := 0
    else
      n := input_str[i]
      username[i] := n

PRI confChannel | i,n

  input(@strInputChannel,@channel,LEN_CHAN)
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

  handleStatusStr(@strConfigSaved, 2, TRUE)

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

  if ios.rtcTest                                                'RTC chip available?
    hiveid := ios.getNVSRAM(NVRAM_HIVE)
    hiveid += ios.getNVSRAM(NVRAM_HIVE+1) << 8
    hiveid += ios.getNVSRAM(NVRAM_HIVE+2) << 16
    hiveid += ios.getNVSRAM(NVRAM_HIVE+3) << 24
  else
    ios.sddmset(ios#DM_USER)                                    'u-marker setzen
    ios.sddmact(ios#DM_SYSTEM)                                  's-marker aktivieren
    ifnot ios.sdopen("R",@strNVRAMFile)
      ios.sdseek(NVRAM_HIVE)
      hiveid := ios.sdgetc
      hiveid += ios.sdgetc << 8
      hiveid += ios.sdgetc << 16
      hiveid += ios.sdgetc << 24
      ios.sdclose
    ios.sddmact(ios#DM_USER)                                    'u-marker aktivieren

PRI ircConnect | t

  joined := FALSE

  handleStatusStr(@strConnect, 2, TRUE)
  ios.lanstart
  if (handleidx := ios.lan_connect(ip_addr, ip_port)) == $FF
    handleStatusStr(@strErrorNoSocket, 2, TRUE)
    return(-1)
  ifnot (ios.lan_waitconntimeout(handleidx, 2000))
    handleStatusStr(@@strErrorConnect, 2, TRUE)
    ircClose
    return(-1)
  handleStatusStr(@strWaitConnect, 2, TRUE)

  t := cnt
  repeat until (cnt - t) / clkfreq > 1    '1s lang Meldungen des Servers entgegennehmen
    ircGetline

PRI ircClose

  ifnot handleidx == $FF
    ios.lan_close(handleidx)
    handleidx := $FF
    handleStatusStr(@strDisconnect, 2, TRUE)

    title_draw

PRI ircPass

  if handleidx == $FF
    handleStatusStr(@strErrorPassConn, 2, FALSE)
    return(-1)
  else
    handleStatusStr(@strSendPass, 2, TRUE)
  if sendStr(string("PASS ")) or sendStr(@password) or sendStr(string(13,10))
    handleStatusStr(@strErrorSendPass, 2, TRUE)
    return(-1)

PRI ircNick

  if handleidx == $FF
    return(-1)
  if sendStr(string("NICK ")) or sendStr(@nickname) or sendStr(string(13,10))
    handleStatusStr(@strErrorSendNick, 2, TRUE)
    return(-1)

PRI ircReg | t

  if handleidx == $FF
    handleStatusStr(@strErrorRegConn, 2, FALSE)
    return(-1)

  handleStatusStr(@strSendNickReg, 2, TRUE)

  ircNick

  if sendStr(string("USER ")) or sendStr(@username) or sendStr(string(" 8 * :Hive #")) or sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC))) or sendStr(string(13,10))
    handleStatusStr(@strErrorSendReg, 2, TRUE)
    return(-1)

  t := cnt
  repeat until (cnt - t) / clkfreq > 3    '3s lang Meldungen des Servers entgegennehmen
    ircGetline

PRI ircJoin

  if strsize(@channel) > 0 and handleidx <> $FF
    if sendStr(string("JOIN ")) or sendStr(@channel) or sendStr(string(13,10))
      handleStatusStr(@strErrorSendJoin, 2, TRUE)
      return(-1)

    joined := TRUE
    title_draw

PRI ircPart(strMsg)

  if handleidx <> $FF
    sendStr(string("PART "))
    sendStr(@channel)
    if strMsg
      sendStr(strMsg)                               'optionale Mitteilung (Leerzeichen an erster Stelle)
    sendStr(string(13,10))
    channel[0] := 0

    joined := FALSE
    title_draw

PRI ircGetLine | i, x, prefixstr, nickstr, chanstr, msgstr, commandstr

  if readLine(2000) 'vollständige Zeile empfangen

    secsrvact := 0                                                            'Sekunden seit letzter Serveraktivität zurücksetzen
    if receive_str[0] == ":"                                                  'Prefix folgt (sollte jede hereinkommende Message enthalten)
      prefixstr := @receive_str[1]
      ifnot (commandstr := str.replaceCharacter(prefixstr, " ", 0))           'nächstes Leerzeichen ist Ende des Prefix, dann folgt das Kommando
        return(FALSE)
    else                                                                      'kein Prefix
      prefixstr := 0
      commandstr := @receive_str                                              'es geht gleich mit dem Kommando los

    if str.startsWithCharacters(commandstr, string("PRIVMSG "))               'Chat Message
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
              ifnot newMsg                                                    'neue Mitteilung noch nicht signalisiert
                newMsg := TRUE
                ledStart
                ios.sfx_fire($0, 1)                                           'play phone sound
              if byte[chanstr] == "#"                                         'Message an Channel
                handleChatStr(chanstr, nickstr, msgstr, 0)
              else                                                            'Message an mich
                msgstr -= 7                                                   '"[priv] " vor Message schreiben
                x := string("[priv] ")
                repeat i from 0 to 6
                  byte[msgstr][i] := byte[x][i]
                handleChatStr(string("<priv>"), nickstr, msgstr, 2)
    elseif str.startsWithCharacters(commandstr, string("PING :"))             'PING
#ifdef __DEBUG
      handleStatusStr(@strPingPong, 2, TRUE)
#endif
      byte[commandstr][1] := "O"
      sendStr(commandstr)
      sendStr(string(13,10))
    elseif str.startsWithCharacters(commandstr, string("JOIN "))              'JOIN
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := @strJoin
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif str.startsWithCharacters(commandstr, string("PART "))              'PART
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := @strPart
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif str.startsWithCharacters(commandstr, string("QUIT :"))             'QUIT
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := @strLeaveServer
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif str.startsWithCharacters(commandstr, string("NOTICE "))            'Notiz
#ifdef __DEBUG
      handleStatusStr(commandstr, 2, FALSE)
#endif
    elseif str.startsWithCharacters(commandstr, string("MODE "))              'Mode
#ifdef __DEBUG
      handleStatusStr(commandstr, 2, FALSE)
#endif
    elseif str.startsWithCharacters(commandstr, string("PONG "))              'PONG (Antwort auf eigenes PING)
#ifdef __DEBUG
      handleStatusStr(commandstr, 2, FALSE)
#endif
    elseif str.startsWithCharacters(commandstr, string("NICK "))              'Nick
      if (str.replaceCharacter(prefixstr, "!", 0))
        repeat x from 0 to strsize(prefixstr) - 1
          temp_str[x] := byte[prefixstr][x]
        msgstr := @strChangeNick
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        msgstr := commandstr + 5
        if byte[msgstr] == ":"
          msgstr++
        repeat i from 0 to strsize(msgstr) - 1
          temp_str[x++] := byte[msgstr][i]
        temp_str[x] := 0
        handleStatusStr(@temp_str, 2, TRUE)
    elseif byte[commandstr][3] == " "                                         'Kommando 3 Zeichen lang -> 3stelliger Returncode
      byte[commandstr][3] := 0
      nickstr := commandstr + 4
      msgstr := str.replaceCharacter(nickstr, " ", 0)
      case num.FromStr(commandstr, num#DEC)
        1:        if prefixstr
                    msgstr := @strConnected
                    repeat x from 0 to strsize(msgstr) - 1
                      temp_str[x] := byte[msgstr][x]
                    repeat i from 0 to LEN_IRCSRV
                      ircsrv[i] := byte[prefixstr][i]
                      temp_str[x++] := byte[prefixstr][i]
                      if byte[prefixstr][i] == 0
                        quit
                    ircsrv[LEN_IRCSRV] := 0
                    handleStatusStr(@temp_str, 2, TRUE)
                    title_draw
        372:      handleStatusStr(msgstr + 3, 1, FALSE)                       'MOTD
        375..376:
        451:
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
    ios.winset(3)
    ios.curon

PRI ircPutLine | i

  if str.startsWithCharacters(@send_str, string("/set"))      'alle Einstellungen ändern und speichern
    f_setconf
  elseif str.startsWithCharacters(@send_str, string("/save")) 'Konfiguration speichern
    confSave
  elseif str.startsWithCharacters(@send_str, string("/srv"))  'mit Server verbinden
    if send_str[4] == " " and send_str[5] <> " " and send_str[5] <> 0 'Nick als Parameter angegeben
      ifnot strToIpPort(@send_str[5], @ip_addr, @ip_port)
        handleStatusStr(@strErrorAddr, 2, TRUE)
        return (FALSE)
    else
      ifnot confServer                                      'Eingabefenster
        win_contentRefresh
        return(FALSE)
      else
        win_contentRefresh
    ircClose                                                'bei bestehender Verbindung diese beenden
    ircConnect
    ircPass
    ircReg
  elseif str.startsWithCharacters(@send_str, string("/quit")) 'Verbindung mit Server trennen
    ircClose
  elseif str.startsWithCharacters(@send_str, string("/pass")) 'Paßwort ändern
    confPass
    win_contentRefresh
    handleStatusStr(@strPassChanged, 2, FALSE)
  elseif str.startsWithCharacters(@send_str, string("/nick")) 'Nickname ändern
    if send_str[5] == " " and send_str[6] <> " " and send_str[6] <> 0 'Nick als Parameter angegeben
      repeat i from 0 to LEN_NICK
        nickname[i] := send_str[6+i]
        if send_str[6+i] == 0
          quit
      channel[LEN_NICK] := 0
    else
      confNick
      win_contentRefresh
    ircNick
  elseif str.startsWithCharacters(@send_str, string("/user")) 'User ändern
    confUser
    win_contentRefresh
    handleStatusStr(@strUserChanged, 2, FALSE)
  elseif str.startsWithCharacters(@send_str, string("/join")) 'mit Channel verbinden
    if joined
      handleStatusStr(@strAlreadyJoined, 2, FALSE)
    else
      if send_str[5] == " " and send_str[6] == "#"            'Channel als Parameter angegeben
        repeat i from 0 to LEN_CHAN
          channel[i] := send_str[6+i]
          if send_str[6+i] == 0
            quit
        channel[LEN_IRCSRV] := 0
      else
        confChannel
        win_contentRefresh
      ircJoin
  elseif str.startsWithCharacters(@send_str, string("/part")) 'Channel verlassen
    if handleidx == $FF
      handleStatusStr(@strNotConnected, 2, FALSE)
    else
      if send_str[5] == " "                                   'Mitteilung folgt
        ircPart(@send_str[5])                                 'Mitteilung mit Leerzeichen an erster Stelle
      else
        ircPart(0)
      handleChatStr(@channel, @nickname, @send_str, 1)
  elseif str.startsWithCharacters(@send_str, string("/msg"))  'Message an Nickname
    if handleidx == $FF
      handleStatusStr(@strNotConnected, 2, FALSE)
    else
      sendStr(string("PRIVMSG "))
      if (i := str.replaceCharacter(@send_str[5], " ", 0))
        sendStr(@send_str[5])
        sendStr(string(" :"))
        sendStr(i)
        sendStr(string(13,10))
        handleChatStr(@send_str[5], @nickname, i, 1)
  elseif send_str[0] == "/"                                   'anderes IRC-Kommando an Server
    if handleidx == $FF
      handleStatusStr(@strNotConnected, 2, FALSE)
    else
      sendStr(@send_str[1])
      sendStr(string(13,10))
      handleChatStr(@channel, @nickname, @send_str, 1)
  else                                                        'Message an Channel
    if strsize(@channel) == 0
      handleStatusStr(@strNotJoined, 2, FALSE)
    elseif handleidx == $FF
      handleStatusStr(@strNotConnected, 2, FALSE)
    else
      sendStr(string("PRIVMSG "))
      sendStr(@channel)
      sendStr(string(" :"))
      sendStr(@send_str)
      sendStr(string(13,10))
      handleChatStr(@channel, @nickname, @send_str, 1)

PRI title_draw | spaces, i

  ios.winset(0)
  ios.curoff
  ios.cursetx(W0X_MENU)
  ios.cursety(W0Y_MENU)
  ios.setcolor(COL_HEAD)
  spaces := cols-W0X_MENU
  ios.print(string(" IRC Client"))
  spaces -= 11
  ifnot handleidx == $FF           'wenn verbunden
    ios.print(string(" ("))
      spaces -= 2
    if joined
      ios.print(@channel)
      ios.printchar("@")
      spaces -= strsize(@channel)+1
    i := 0
    repeat spaces - 1
      if ircsrv[i] == 0          'Ende Servername erreicht
        ios.printchar(" ")
      else
        ios.printchar(ircsrv[i])
        if ircsrv[++i] == 0      'Ende Servername folgt
          ios.printchar(")")
  else
    repeat spaces
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
    ios.cursety(y0[i]-1)
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
    ios.cursety(y0[i]-1)
    if i == focus
      ios.setcolor(COL_FOCUS)
    else
      ios.setcolor(COL_FRAME)
    case i
      1: ios.print(@strWin1)
      2: ios.print(@strWin2)
      3: ios.print(@strWin3)

PRI win_contentRefresh | win, lines, lineNum, linePos, space, i
'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Fensterinhalt neu aufbauen                                                                                               │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  'chat and status window
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

  'input window
  ios.winset(3)
  ios.curoff
  ios.printcls
  ios.setcolor(COL_FOCUS)
  if strsize(@send_str) < cols - 1
    ios.print(@send_str)
  else
    linePos := 0
    space := 0
    repeat i from 0 to strsize(@send_str) - 1
      if send_str[i] == " "
        space := i                                               'save position of last space
      if (i - linePos == cols - 2)                               'end of current line
        repeat while linePos < i
          ios.printchar(send_str[linePos++])                     'print line
          if linePos == space                                    'last space
            linePos++                                            'omit
            quit                                                 'next line
        ios.curpos1
        ios.printnl
        space := 0
    ios.print(@send_str[linePos])                                'print remaining line
  ios.curon

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
  buflinenr[3]    := 0
  scrolllinenr[3] := 0
  bufstart[3]     := bufstart[2] + buflen[2]
  buflen[3]       := buflinelen * MAX_LINES_WIN3
  repeat i from 0 to MAX_LINES_WIN3 - 1             'Fensterpuffer leeren
    printStrBuf(3)

  ios.winset(0)
  ios.printcls
  title_draw
  win_draw

  'Konfigurations-Fenster (Nr. 4)
  ios.windefine(4,13,10,47,13)

  'Hilfe-Fenster (Nr. 5)
  ios.windefine(5,1,2,62,22)

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

PRI handleChatStr(chanstr, nickstr, msgstr, me) | i, timenicklen, msglineend, ch, space, lastline
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
  lastline := FALSE          'letzte der erstellten Zeilen?
  print_str_ptr := 0         'String neu beginnen

'1. Teilstring: Zeit
  print_str[print_str_ptr++] := COL_TIME     'Farbbyte
  printTime
  print_str[print_str_ptr++] := 0

'2. Teilstring: Nickname
  case me
    0: print_str[print_str_ptr++] := COL_NICK     'Farbbyte
    1: print_str[print_str_ptr++] := COL_MYNICK   'Farbbyte
    2: print_str[print_str_ptr++] := COL_PRIVNICK 'Farbbyte
  print_str[print_str_ptr++] := ">"
  repeat i from 0 to strsize(nickstr) - 1     'Länge Nickname ohne Abschluß-Null
    print_str[print_str_ptr++] := byte[nickstr][i]
  print_str[print_str_ptr++] := ":"
  print_str[print_str_ptr++] := " "
  print_str[print_str_ptr++] := 0

'3. Teilstring: 1. Teil  der Mitteilung
  case me
    0: print_str[print_str_ptr++] := COL_MSG     'Farbbyte
    1: print_str[print_str_ptr++] := COL_MYMSG   'Farbbyte
    2: print_str[print_str_ptr++] := COL_PRIVMSG 'Farbbyte
  timenicklen := strsize(nickstr) + 10
  msglineend := cols - timenicklen -2
  repeat until lastline
    if strsize(msgstr) =< msglineend               'msgline paßt auf Zeile
      lastline := TRUE
    else                                           'msgline muß umgebrochen werden
      ch := byte[msgstr][msglineend]               'Zeichen am Zeilenende sichern
      byte[msgstr][msglineend] := 0                'Messagestring am Zeilenende abschließen
      if (space := findCharacterBack(msgstr, " ")) 'wenn letztes Leerzeichen in msgstr gefunden
        byte[msgstr][msglineend] := ch             'Zeichen am Zeilenende wieder einfügen
        byte[space] := 0                           'msgstr am letzten Leerzeichen abschließen
    repeat i from 0 to strsize(msgstr)             'Länge Mitteilung inkl. Abschluß-Null
      print_str[print_str_ptr++] := byte[msgstr][i]
    print_str[print_str_ptr++] := 0                'komplette Chat-Zeile fertig
    print_str[print_str_ptr] := 0
    print_str_ptr := 0
    if scrolllinenr[1] == 0                        'Chatfenster nicht gescrollt
      ios.printnl
      printStrWin(@print_str)                      'im Chatfenster anzeigen
    printStrBuf(1)                                 'in Fensterpuffer schreiben
    ifnot lastline                                 'wenn noch eine zeile folgt, diese bereits beginnen
      case me
        0: print_str[print_str_ptr++] := COL_MSG     'Farbbyte
        1: print_str[print_str_ptr++] := COL_MYMSG   'Farbbyte
        2: print_str[print_str_ptr++] := COL_PRIVMSG 'Farbbyte
      repeat timenicklen                           '"Tab" bis Ende Anzeige Channel + Nickname
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
    print_str[print_str_ptr++] := 0

   '2. Teilstring: Status
  print_str[print_str_ptr++] := COL_STDEFAULT    'Farbbyte
  if showtime
    print_str[print_str_ptr++] := " "
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
    n := ios.keywait                                    'auf taste warten
    case n
      $0d:                quit                          'Enter, Eingabe beenden
      ios#CHAR_BS:        if i > 0                      'Zurück
                            ios.printbs
                            i--
                            byte[@input_str][i] := 0
      9 .. 13, 32 .. 255: if i < input_len              'normales zeichen
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

  ifnot ios.lan_isConnected(handleidx)             'Verbindung unterbrochen
    ircClose
    reconnect := TRUE                              'möglichst neu verbinden
    return(FALSE)

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
PRI ledStart

  ifnot ledcog
    ledcog := cognew(ledTwinkle(clkfreq/150), @ledstack)

PRI ledStop

  if ledcog
    cogstop(ledcog)
    ledcog := 0

PRI ledTwinkle(rate)

  repeat

    repeat brightness from 0 to 100
      led.LEDBrightness(brightness, gc#HBEAT)  'Adjust LED brightness
      waitcnt(rate + cnt)                      'Wait a moment

    repeat brightness from 100 to 0
      led.LEDBrightness(brightness,gc#HBEAT)   'Adjust LED brightness
      waitcnt(rate + cnt)                      'Wait a moment
DAT 'Sound

'                 Wav Len Fre Vol LFO LFW FMa AMa Att Dec Sus Rel
soundNewMgs  byte $00,$03,$FF,$0F,$08,$04,$05,$00,$FF,$00,$50,$11
             byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

DAT 'Locale

#ifdef __LANG_EN
  'locale: english

  strConfFile byte  "irc.cfg",0

  strWin1     byte  "Chat",0
  strWin2     byte  "State",0
  strWin3     byte  "Input",0

  strWrongBel      byte 13,"Bellatrix flash doesn't have the expected TriOS code.",13,0
  strNoNetwork     byte 13,"Administra doesn't provide network functions!",13,"Please load admnet.",13,0
  strInitWait      byte 13,"Initialiasing, please wait...",13,0
  strReconnect     byte "Try to reconnect",0
  strRestartConf   byte "Please restart configuration (F2)",0
  strAlreadyJoined byte "Already joined, please leave channel before with F5 (/part)",0
  strUserChanged   byte "User changed, please reconnect to use it",0
  strPassChanged   byte "Password changed, please reconnect to use it",0
  strInputSrv      byte "IRC-Server (ip:port):",0
  strErrorAddr     byte "Error in ip address or port of server.",0
  strInputPass     byte "Password:",0
  strInputNick     byte "Nickname:",0
  strInputUser     byte "Username:",0
  strInputChannel  byte "Channel:",0
  strConfigSaved   byte "Configuration saved.",0
  strConnect       byte "Connecting to IRC server...",0
  strErrorNoSocket byte "No free socket.",0
  strErrorConnect  byte "Error connecting to IRC server.",0
  strWaitConnect   byte "Connected, waiting for readyness...",0
  strDisconnect    byte "Disconnected from IRC server...",0
  strErrorPassConn byte "Error setting password (no connection)",0
  strSendPass      byte "Sending password...",0
  strErrorSendPass byte "Error sending password",0
  strErrorSendNick byte "Error sending nickname",0
  strErrorRegConn  byte "No registration possible (no connection)",0
  strSendNickReg   byte "Sending registration (nick, user, password)...",0
  strErrorSendReg  byte "Error sending user information",0
  strErrorSendJoin byte "Error joining to channel",0
  strPingPong      byte "PING received, send PONG",0
  strJoin          byte " has joined the channel",0
  strPart          byte " has leaved the channel",0
  strLeaveServer   byte " has leaved the server",0
  strChangeNick    byte " is now known as ",0
  strConnected     byte "Connected to ",0
  strNotConnected  byte "Not connected",0
  strNotJoined     byte "Not joined to channel",0

  '                  |------------------------------------------------------------|
  strHelp byte      "Internal commands:"
          byte  $0d,"================="
          byte  $0d
          byte  $0d,"F1        This Help"
          byte  $0d,"F2  /set  Edit and save all settings"
          byte  $0d,"F3        Connect to server, login and join"
          byte  $0d,"F4  /join Join to channel (/join #<channel>)"
          byte  $0d,"F5  /part Leave current channel (/part <message>)"
          byte  $0d,"F6  /nick Change nickname (/nick <new nickname>)"
          byte  $0d,"F7  /user Change username"
          byte  $0d,"F8  /pass Change password"
          byte  $0d,"F9  /quit Disconnect from server"
          byte  $0d,"F10       Exit irc client"
          byte  $0d,"    /msg  Private Message (/msg <recipient> <text>)"
          byte  $0d,"    /srv  connect to server and login (srv <ip:port>)"
          byte  $0d,"    /save Save settings"
          byte  $0d,"Tab       Switch windows, scroll with cursor up/down"
          byte  $0d
          byte  $0d,"All other input beginning with '/' is a direct command to the"
          byte  $0d,"server. All input that doesn't begin with '/' is a public"
          byte  $0d,"message to the current channel",$0

#else
  'default locale: german

  strConfFile byte  "irc.cfg",0

  strWin1     byte  "Chat",0
  strWin2     byte  "Status",0
  strWin3     byte  "Eingabe",0

  strWrongBel      byte 13,"Bellatrix-Flash enthält nicht den erforderlichen TriOS-Code.",13,0
  strNoNetwork     byte 13,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",13,"Bitte admnet laden.",13,0
  strInitWait      byte 13,"Initialisiere, bitte warten...",13,0
  strReconnect     byte "Versuche Neuverbindung",0
  strRestartConf   byte "Bitte Konfiguration neu starten (F2)",0
  strAlreadyJoined byte "Kanal bereits betreten, vorher mit F5 (/part) verlassen",0
  strUserChanged   byte "User geändert, zum Anwenden neu verbinden",0
  strPassChanged   byte "Paßwort geändert, zum Anwenden neu verbinden",0
  strInputSrv      byte "IRC-Server angeben (IP:Port):",0
  strErrorAddr     byte "Fehlerhafte Eingabe von IP-Adresse und Port des Servers.",0
  strInputPass     byte "Paßwort eingeben:",0
  strInputNick     byte "Nickname eingeben:",0
  strInputUser     byte "Username eingeben:",0
  strInputChannel  byte "Channel eingeben:",0
  strConfigSaved   byte "Konfiguration gespeichert.",0
  strConnect       byte "Verbinde mit IRC-Server...",0
  strErrorNoSocket byte "Kein Socket frei!",0
  strErrorConnect  byte "Verbindung mit IRC-Server konnte nicht aufgebaut werden.",0
  strWaitConnect   byte "Verbunden, warte auf Bereitschaft...",0
  strDisconnect    byte "Verbindung mit IRC-Server getrennt...",0
  strErrorPassConn byte "Kann Paßwort nicht setzen (keine Verbindung zum Server)",0
  strSendPass      byte "Sende Paßwort...",0
  strErrorSendPass byte "Fehler beim Senden des Paßwortes",0
  strErrorSendNick byte "Fehler beim Senden des Nicknamens",0
  strErrorRegConn  byte "Anmeldung nicht möglich (keine Verbindung zum Server)",0
  strSendNickReg   byte "Sende Nickname und Benutzerinformationen...",0
  strErrorSendReg  byte "Fehler beim Senden der Benutzerinformationen",0
  strErrorSendJoin byte "Fehler beim Verbinden mit Channel",0
  strPingPong      byte "PING erhalten, sende PONG",0
  strJoin          byte " hat den Kanal betreten",0
  strPart          byte " hat den Kanal verlassen",0
  strLeaveServer   byte " hat den Server verlassen",0
  strChangeNick    byte ":Nickname geändert in ",0
  strConnected     byte "Verbunden mit ",0
  strNotConnected  byte "Nicht verbunden",0
  strNotJoined     byte "Mit keinem Kanal verbunden",0

  '                  |------------------------------------------------------------|
  strHelp byte      "Interne Befehle:"
          byte  $0d,"================"
          byte  $0d
          byte  $0d,"F1        Diese Hilfe"
          byte  $0d,"F2  /set  Alle Einstellungen bearbeiten und abspeichern"
          byte  $0d,"F3        Mit Server verbinden, anmelden und Kanal betreten"
          byte  $0d,"F4  /join Kanal betreten (/join #<Kanal>)"
          byte  $0d,"F5  /part Aktuellen Kanal verlassen (/part <Mitteilung>)"
          byte  $0d,"F6  /nick Nicknamen ändern (/nick <neuer Nick>)"
          byte  $0d,"F7  /user Benutzernamen ändern"
          byte  $0d,"F8  /pass Paßwort ändern"
          byte  $0d,"F9  /quit Verbindung zu Server trennen"
          byte  $0d,"F10       Programm beenden"
          byte  $0d,"    /msg  Private Mitteilung (/msg <Empfänger> <Text>)"
          byte  $0d,"    /srv  Mit Server verbinden und anmelden (srv <IP:Port>)"
          byte  $0d,"    /save Einstellungen speichern"
          byte  $0d,"Tab       Fenster umschalten, scrollen mit Cursor hoch/runter"
          byte  $0d
          byte  $0d,"Alle anderen mit '/' beginnenden Eingaben sind Befehle an den"
          byte  $0d,"Server. Alle Eingaben, welche nicht mit '/' beginnen, sind"
          byte  $0d,"eine öffentliche Mitteilung an den aktuellen Kanal.",$0
#endif

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
