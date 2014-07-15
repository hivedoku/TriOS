{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Jörg Deckert                                                                                  │
│ Copyright (c) 2014 Jörg Deckert                                                                      │
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
Funktion        : Webserver
Komponenten     : -
COG's           : -
Logbuch         :

23.06.2014-joergd - erste Version
                  - Parameter für Benutzer und Paßwort

Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        gc : "glob-con"
        str: "glob-string"
        num: "glob-numbers"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

CON 'NVRAM Konstanten --------------------------------------------------------------------------

#4,     NVRAM_IPADDR
#24,    NVRAM_HIVE       ' 4 Bytes

DAT

  strNVRAMFile byte  "nvram.sav",0                      'contains the 56 bytes of NVRAM, if RTC is not available


VAR

  byte    handleidx          'Handle web connection

  byte reqstr[32]            ' request string
  byte webbuff[128]          ' incoming header buffer

  byte rtcAvailable

  long hiveid

  long cog, random_value

PUB main | i

  rr_start

  ios.start
  ifnot (ios.admgetspec & gc#A_LAN)
    ios.sddmset(ios#DM_USER)                              'u-marker setzen
    ios.sddmact(ios#DM_SYSTEM)                            's-marker aktivieren
    ios.admload(string("admnet.adm"))                     'versuche, admnet zu laden
    ios.sddmact(ios#DM_USER)                              'u-marker aktivieren
    ifnot (ios.admgetspec & gc#A_LAN)                     'wenn Laden fehlgeschlagen
      ios.print(@strNoNetwork)
      ios.stop                                            'Ende
  ios.printnl

  ios.lanstart                                            'LAN-Treiber initialisieren (eigene IP-Adresse usw. setzen)
  handleidx := $FF

  getcfg
  ios.print(@strMsgEnd)

  i := 0
  repeat
    if ios.keystat > 0
      quit
    if (handleidx := ios.lan_listen(handleidx,80)) == $FF 'Empfangs-Socket auf Port 80 öffnen
      if i > 20
        ios.print(@strErrorNoSock)
        quit
      else
        i++
        next
    i := 0
    if ios.lan_isconnected(handleidx)                     'bei bestehender Verbindung...
      if webThread == 0
        ios.lan_txflush(handleidx)
      ios.lan_close(handleidx)
      handleidx := $FF

  ios.stop

PRI webThread | i, j, uri, args

  if webReadLine == 0                               ' read the first header, quit if it is empty
    return 0

  bytemove(@reqstr, @webbuff, 32)                   ' copy the header to a temporary request string for later processing

  ' obtain get arguments
  if (i := indexOf(@reqstr, string(".cgi?"))) <> -1 ' was the request for a *.cgi script with arguments?
    args := @reqstr[i + 5]                          ' extract the argument
    if (j := indexOf(args, string("="))) <> -1      ' find the end of the argument
      byte[args][j] := 0                            ' string termination

  ' read the rest of the headers
  repeat until webReadLine == 0                     ' read the rest of the headers, throwing them away

  sendStr(string("HTTP/1.0 200 OK",13,10,13,10))                            ' print the HTTP header

  if indexOf(@reqstr, string("ajax.js")) <> -1                              ' ajax.js
    sendStr(@ajaxjs)
  elseif indexOf(@reqstr, string("rand.cgi")) <> -1                         ' rand.cgi
    sendStr(str.trimCharacters(num.ToStr(long[rr_random_ptr], num#DEC)))
  elseif indexOf(@reqstr, string("id.cgi")) <> -1                           ' id.cgi
    sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC)))
  elseif indexOf(@reqstr, string("img.bin")) <> -1                          ' img.bin
    ios.lan_txdata(handleidx, 0, 32768)
  else
    ' default page
    sendStr(@strDefPage1)
    sendStr(str.trimCharacters(num.ToStr(hiveid, num#DEC)))
    sendStr(@strDefPage2)

  return 0

PRI webReadLine | i, ch
  repeat i from 0 to 126
    ch := ios.lan_rxtime(handleidx, 500)
    if ch == 13
      ch := ios.lan_rxtime(handleidx, 500)
    if ch == -1 or ch == 10
      quit
    webbuff[i] := ch

  webbuff[i] := 0

  return i

PRI sendStr (strSend) : error

#ifdef __DEBUG
  ios.print(string(" > "))
  ios.print(strSend)
  ios.printnl
#endif
  error := ios.lan_txdata(handleidx, strSend, strsize(strSend))

PRI indexOf(haystack, needle) | i, j
  '' Searches for a 'needle' inside a 'haystack'
  '' Returns starting index of 'needle' inside 'haystack'

  repeat i from 0 to strsize(haystack) - strsize(needle)
    repeat j from 0 to strsize(needle) - 1
      if byte[haystack][i + j] <> byte[needle][j]
        quit
    if j == strsize(needle)
      return i

  return -1

PRI getcfg                                          'nvram: IP-Konfiguration anzeigen

  if ios.rtcTest                                        'RTC chip available?
    rtcAvailable := TRUE
  else                                                  'use configfile
    rtcAvailable := FALSE
    ios.sddmset(ios#DM_USER)                            'u-marker setzen
    ios.sddmact(ios#DM_SYSTEM)                          's-marker aktivieren
    if ios.sdopen("R",@strNVRAMFile)
      ios.print(@strErrorOpen)
      ios.sddmact(ios#DM_USER)                          'u-marker aktivieren
      return

  ios.print(@strAddr)
  listaddr(NVRAM_IPADDR)
  ios.printnl

  if rtcAvailable
    hiveid := ios.getNVSRAM(NVRAM_HIVE)
    hiveid += ios.getNVSRAM(NVRAM_HIVE+1) << 8
    hiveid += ios.getNVSRAM(NVRAM_HIVE+2) << 16
    hiveid += ios.getNVSRAM(NVRAM_HIVE+3) << 24
  else
    ios.sdseek(NVRAM_HIVE)
    hiveid := ios.sdgetc
    hiveid += ios.sdgetc << 8
    hiveid += ios.sdgetc << 16
    hiveid += ios.sdgetc << 24

  ifnot rtcAvailable
    ios.sdclose
    ios.sddmact(ios#DM_USER)                            'u-marker aktivieren

PRI listaddr (nvidx) | count                            'IP-Adresse anzeigen

  ifnot rtcAvailable
    ios.sdseek(nvidx)

  repeat count from 0 to 3
    if(count)
      ios.print(string("."))
    if rtcAvailable
      ios.print(str.trimCharacters(num.ToStr(ios.getNVSRAM(nvidx+count), num#DEC)))
    else
      ios.print(str.trimCharacters(num.ToStr(ios.sdgetc, num#DEC)))

DAT ' Locale

#ifdef __LANG_EN
  'locale: english

  strNoNetwork      byte 13,"Administra doesn't provide network functions!",13,"Please load admnet.",13,0
  strWaitConnection byte "Waiting for client connection...",13,0
  strErrorNoSock    byte "No free socket.",13,0
  strErrorOpen byte "Can't open configuration file",13,0
  strAddr           byte 13,"Webserver startet, please use this URL to connect:",13,"  http://",0
  strDefPage1       byte "<html><body><script language=javascript src=ajax.js></script><b>It Works!<br><br>Hive-ID: ",0
  strDefPage2       byte "<br><br>Random Number:</b><div id=a></div><script language=javascript>ajax('rand.cgi', 'a', 10);</script></body></html>",0
  strMsgEnd         byte 13,13,"Press any key to quit",13,0


#else
  'default locale: german

  strNoNetwork      byte 13,"Administra stellt keine Netzwerk-Funktionen zur Verfügung!",13,"Bitte admnet laden.",13,0
  strWaitConnection byte "Warte auf Client-Verbindung...",13,0
  strErrorNoSock    byte "Kein Socket frei...",13,0
  strErrorOpen      byte "Kann Konfigurationsdatei nicht öffnen.",13,0
  strAddr           byte 13,"Webserver gestartet, zum Verbinden folgende URL verwenden:",13,"  http://",0
  strDefPage1       byte "<html><body><script language=javascript src=ajax.js></script><b>Es funktioniert!<br><br>Hive-ID: ",0
  strDefPage2       byte "<br><br>Zufallszahl:</b><div id=a></div><script language=javascript>ajax('rand.cgi', 'a', 10);</script></body></html>",0
  strMsgEnd         byte 13,13,"Zum Beenden beliebige Taste drücken",13,0

#endif

ajaxjs  byte  "var ajaxBusy=false;function ajax(a,b,c){if(ajaxBusy){return}ajaxBusy=true;var d;try{d=new XMLHttpRequest()}catch(e){d=new ActiveXObject('Microsoft.XMLHTTP')}var f=function(){if(d.readyState==4){if(b){document.getElementById(b).innerHTML=d.responseText}ajaxBusy=false;if(c>0){setTimeout('ajax(\''+a+'\',\''+b+'\','+c+')',c)}}};d.open('GET',a+'?'+(new Date()).getTime(),true);d.onreadystatechange=f;d.send(null)}"
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



DAT
{{
┌───────────────────────────────────────────┬────────────────┬────────────────────────┬───────────────┐
│ Real Random v1.2                          │ by Chip Gracey │ (C)2007 Parallax, Inc. │ 23 March 2007 │
├───────────────────────────────────────────┴────────────────┴────────────────────────┴───────────────┤
│                                                                                                     │
│ This object generates real random numbers by stimulating and tracking CTR PLL jitter. It requires   │
│ one cog and at least 20MHz.                                                                         │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                                              │
│                                                                                                     │
│ A real random number is impossible to generate within a closed digital system. This is because      │
│ there are no reliably-random states within such a system at power-up, and after power-up, it        │
│ behaves deterministically. Random values can only be 'earned' by measuring something outside of the │
│ digital system.                                                                                     │
│                                                                                                     │
│ In your programming, you might have used 'var?' to generate a pseudo-random sequence, but found the │
│ same pattern playing every time you ran your program. You might have then used 'cnt' to 'randomly'  │
│ seed the 'var'. As long as you kept downloading to RAM, you saw consistently 'random' results. At   │
│ some point, you probably downloaded to EEPROM to set your project free. But what happened nearly    │
│ every time you powered it up? You were probably dismayed to discover the same sequence playing each │
│ time! The problem was that 'cnt' was always powering-up with the same initial value and you were    │
│ then sampling it at a constant offset. This can make you wonder, "Where's the end to this madness?  │
│ And will I ever find true randomness?".                                                             │
│                                                                                                     │
│ In order to have real random numbers, either some external random signal must be input, or some     │
│ analog system must be used to generate random noise which can be measured. We're in luck here,      │
│ because it turns out that the Propeller does have sufficiently-analog subsystems which can be       │
│ exploited for this purpose -- each cog's CTR PLLs. These can be exercised internally to good        │
│ effect, without any I/O activity.                                                                   │
│                                                                                                     │
│ This object sets up a cog's CTRA PLL to run at the main clock's frequency. It then uses a pseudo-   │
│ random sequencer to modulate the PLL's target phase. The PLL responds by speeding up and slowing    │
│ down in a an endless effort to lock. This results in very unpredictable frequency jitter which is   │
│ fed back into the sequencer to keep the bit salad tossing. The final output is a truly-random       │
│ 32-bit unbiased value that is fully updated every ~100us, with new bits rotated in every ~3us. This │
│ value can be sampled by your application whenever a random number is needed.                        │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Revision History                                                        v1.0 released 21 March 2007 │
│                                                                                                     │
│ v1.1  Bias removal has been added to ensure true randomness. Released 22 March 2007.                │
│ v1.2  Assembly code made more efficient. Documentation improved. Released 23 March 2007.            │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘

}}
PUB rr_start : okay

'' Start real random driver - starts a cog
'' returns false if no cog available

  'Reset driver
  rr_stop

  'Launch real random cog
  return cog := cognew(@entry, @random_value) + 1

  'allow 5ms to launch and randomize
  waitcnt(clkfreq / 200 + cnt)

PUB rr_stop

'' Stop real random driver - frees a cog

  'If already running, stop real random cog
  if cog
    cogstop(cog~ -  1)


PUB rr_random_ptr : ptr

'' Returns the address of the long which receives the random value
''
'' A random bit is rotated into the long every ~3us, resuling in a
'' new long every ~100us, on average, at 80MHz. You may want to double
'' these times, though, to be sure that you are getting new bits. The
'' timing uncertainty comes from the unbiasing algorithm which throws
'' away identical bit pairs, and only outputs the different ones.

  return @random_value

DAT

' ┌─────────────────────────┐
' │  Real Random Generator  │
' └─────────────────────────┘

                        org

entry                   movi    ctra,#%00001_111        'set ctra to internal pll mode, select x16 tap
                        movi    frqa,#$020              'set frqa to system clock frequency / 16
                        movi    vcfg,#$040              'set vcfg to discrete output, but without pins
                        mov     vscl,#70                'set vscl to 70 pixel clocks per waitvid

:twobits                waitvid 0,0                     'wait for next 70-pixel mark ± jitter time
                        test    phsa,#%10111    wc      'pseudo-randomly sequence phase to induce jitter
                        rcr     phsa,#1                 '(c holds random bit #1)
                        add     phsa,cnt                'mix PLL jitter back into phase

                        rcl     par,#1          wz, nr  'transfer c into nz (par shadow register = 0)
                        wrlong  _random_value,par       'write random value back to spin variable

                        waitvid 0,0                     'wait for next 70-pixel mark ± jitter time
                        test    phsa,#%10111    wc      'pseudo-randomly sequence phase to induce jitter
                        rcr     phsa,#1                 '(c holds random bit #2)
                        add     phsa,cnt                'mix PLL jitter back into phase

        if_z_eq_c       rcl     _random_value,#1        'only allow different bits (removes bias)
                        jmp     #:twobits               'get next two bits


_random_value           res     1

