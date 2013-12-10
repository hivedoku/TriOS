{{ LAN-Funktionen für Administra }}

CON 'Signaldefinitionen --------------------------------------------------------------------------

'signaldefinitionen administra (todo: nach glob-con.spin auslagern!!!)

#14,     A_NETCS,A_NETSCK,A_NETSI,A_NETSO              'Pins zum ENC28J60

CON 'NVRAM Konstanten --------------------------------------------------------------------------

' todo: nach glob-con.spin auslagern!!!

#4,     NVRAM_IPADDR
#8,     NVRAM_IPMASK
#12,    NVRAM_IPGW
#16,    NVRAM_IPDNS
#20,    NVRAM_IPBOOT
#24,    NVRAM_HIVE       ' 4 Bytes

CON

  ' buffer sizes, must be a power of 2
  rxlen = 2048
  txlen = 128

VAR

  byte ftp_bufrx1[rxlen]            ' buffers for connection to server
  byte ftp_buftx1[txlen]

  byte ftp_bufrx2[rxlen]            ' buffers for connection from server
  byte ftp_buftx2[txlen]

  byte strTemp[128]

OBJ

  gc         : "glob-con"          'globale konstanten
  num        : "glob-numbers"      'Number Engine
  rtc        : "adm-rtc"           'RTC-Engine
  com        : "adm-com"           'serielle schnittstelle (nur zum Debugging genutzt)
  sock       : "api_telnet_serial" 'TCP Socket Funktionen

PUB start | hiveid, hivestr, strpos, macpos

  ip_addr := rtc.getNVSRAM(NVRAM_IPADDR)
  ip_addr[1] := rtc.getNVSRAM(NVRAM_IPADDR+1)
  ip_addr[2] := rtc.getNVSRAM(NVRAM_IPADDR+2)
  ip_addr[3] := rtc.getNVSRAM(NVRAM_IPADDR+3)

  ip_subnet := rtc.getNVSRAM(NVRAM_IPMASK)
  ip_subnet[1] := rtc.getNVSRAM(NVRAM_IPMASK+1)
  ip_subnet[2] := rtc.getNVSRAM(NVRAM_IPMASK+2)
  ip_subnet[3] := rtc.getNVSRAM(NVRAM_IPMASK+3)

  ip_gateway := rtc.getNVSRAM(NVRAM_IPGW)
  ip_gateway[1] := rtc.getNVSRAM(NVRAM_IPGW+1)
  ip_gateway[2] := rtc.getNVSRAM(NVRAM_IPGW+2)
  ip_gateway[3] := rtc.getNVSRAM(NVRAM_IPGW+3)

  ip_dns := rtc.getNVSRAM(NVRAM_IPDNS)
  ip_dns[1] := rtc.getNVSRAM(NVRAM_IPDNS+1)
  ip_dns[2] := rtc.getNVSRAM(NVRAM_IPDNS+2)
  ip_dns[3] := rtc.getNVSRAM(NVRAM_IPDNS+3)

  hiveid :=          rtc.getNVSRAM(NVRAM_HIVE)
  hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+1) << 8
  hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+2) << 16
  hiveid := hiveid + rtc.getNVSRAM(NVRAM_HIVE+3) << 24
  hivestr := num.ToStr(hiveid, num#DEC)
  strpos := strsize(hivestr)
  macpos := 5
  repeat while (strpos AND macpos)
    strpos--
    if(strpos)
      strpos--
    mac_addr[macpos] := num.FromStr(hivestr+strpos, num#HEX)
    byte[hivestr+strpos] := 0
    macpos--

  sock.start(A_NETCS,A_NETSCK,A_NETSI,A_NETSO, -1, @mac_addr, @ip_addr)

PUB stop

  sock.stop

PUB ftpOpen(addr) : connected            'FTP-Verbindung öffnen

  com.str(string("ftpOpen Start",13,10))
  repeat 5                     'mehrmals probieren, falls z.B. TCP-Engine-Cog noch nicht bereit
    sock.connect(addr, 21, @ftp_bufrx1, rxlen, @ftp_buftx1, txlen)
    'sock.resetBuffers
    if connected := sock.waitConnectTimeout(1500)
      'todo: einfügen? if getResponse(string("220"))
      if getResponse(string("220 "))
        com.str(string("Send: USER anonymous",13,10))
        sock.str(string("USER anonymous",13,10))
        if getResponse(string("230 "))
          quit
    else
      sock.close

PUB ftpClose                  'FTP-Verbindung schließen

  com.str(string("Send: QUIT",13,10))
  sock.str(string("QUIT",13,10))
  getResponse(string("221 "))
  sock.close

PUB ftpOpenData(addr,port) : connected

PUB ftpCloseData

PUB ftpBoot                   'zum Boot-Server verbinden

  ip_boot := rtc.getNVSRAM(NVRAM_IPBOOT) << 24
  ip_boot := ip_boot + rtc.getNVSRAM(NVRAM_IPBOOT+1) << 16
  ip_boot := ip_boot + rtc.getNVSRAM(NVRAM_IPBOOT+2) << 8
  ip_boot := ip_boot + rtc.getNVSRAM(NVRAM_IPBOOT+3)

  if ip_boot
    if ftpOpen(ip_boot)
      ftpClose

PUB ftpListName               'Verzeichniseintrag lesen

  return

PRI getResponse (strOk) : respOk | len

  respOk := FALSE

  repeat
    readLine
    com.str(@strTemp)
    com.str(string(13,10))
    if strsize(@strTemp) == 0
      quit
    'byte[@strTemp+strsize(strOk)] := 0
    strTemp[strsize(strOk)] := 0
    com.str(string("StrOk: "))
    com.str(strOk)
    com.str(string("StrComp: "))
    com.str(@strTemp)
    com.str(string(13,10))
    if strcomp(@strTemp, strOk)
      respOk := TRUE

  return respOk

PRI readLine | i, ch

  repeat i from 0 to 126
    ch := sock.rxtime(500)
    if ch == 13
      ch := sock.rxtime(500)
    if ch == -1 or ch == 10
      quit
    strTemp[i] := ch

  strTemp[i] := 0

  return i

DAT
                long                                    ' long alignment for addresses
  ip_addr       byte    10,  1, 1, 1                    'ip
  ip_subnet     byte    255, 255, 255, 0                'subnet-maske
  ip_gateway    byte    10,  1, 1, 254                  'gateway
  ip_dns        byte    10,  1, 1, 254                  'dns
  ip_boot       long    0                               'boot-server (IP address in long)
  mac_addr      byte    $c0, $de, $ba, $be, $00, $00    'mac-adresse

