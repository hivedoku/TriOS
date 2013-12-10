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
Name            : VGA-Text-Treiber 1024x768 Pixel, 128x64 Zeichen
Chip            : Bellatrix
Typ             : Treiber
Version         : 00
Subversion      : 01
Funktion        : VGA-Text- und Tastatur-Treiber
Komponenten     : VGA 1024x768 Tile Driver v0.9   Chip Gracey        MIT
                  PS/2 Keyboard Driver v1.0.1     Chip Gracey, ogg   MIT

COG's           : MANAGMENT     1 COG
                  VGA           2 COG's
                  KEYB          1 COG
                  -------------------
                                4 COG's

Logbuch         :

23-10-2008-dr235  - erste funktionsfähige version erstellt
                  - cursor eingebaut
06-11-2008-dr235  - keyb auf deutsche zeichenbelegung angepasst (ohne umlaute)
24-11-2008-dr235  - tab, setcur, pos1, setx, sety, getx, gety, setcol, sline, screeninit
                    curon, curoff
                  - beltest
13-03-2009-dr235  - LF als Zeichencode ausgeblendet
22-03-2009-dr235  - abfrage für statustasten eingefügt
05-09-2009-dr235  - abfrage der laufenden cogs eingefügt
                  - deutschen tastaturtreiber mit vollständiger belegung! von ogg eingebunden
22-03-2010-dr235  - anpassung trios
01-05-2010-dr235  - scrollup/scrolldown eingebunden & getestet
03-05-2010-dr235  - settab/getcols/getrows/getresx/getresy eingefügt & getestet
                  - hive-logo eingefügt

Kommandoliste:

0       1                       Tastaturstatus abfragen
0       2                       Tastaturzeichen holen
0       3       n               Screensteuerzeichen
0       3       0               CLS
0       3       1               Home
0       3       2               Backspace
0       3       3               TAB
0       3       4   n           SETCUR Cursorzeichen auf n setzen
0       3       5               POS1
0       3       6   x           SETX
0       3       7   y           SETY
0       3       8  (x)          GETX
0       3       9  (y)          GETY
0       3       10  c           SETCOL
0       3       11  n           SLINE
0       3       13              SCREENINIT
0       3       14              CURON
0       3       15              CUROFF
0       3       16              SCROLLUP
0       3       17              SCROLLDOWN
0       3       18 n0..n7       SETTABS
0       4       (status)        Status der Sondertasten abfragen
0       5       x y             Hive-Logo ausgeben
0       90      cnr (c0) (c1)   Farbregister auslesen
0       91      cnr c0 c1       Farbregister setzen
0       92      (res-x)
0       93      (res-y)         
0       94      (cols)
0       95      (rows)
0       96      (cogs)          Status der belegten COG's abfragen
0       97      (spez)          Spezifikation abfragen
0       98      (ver)           Version abfragen
0       99                      Reboot und neuen Treiber laden


1..255                          Zeichenausgabe


Notizen:
- setheader

ACHTUNG: row ist nicht die Zeilenposition, da zwei tiles untereinander ein zeichen
bilden. vielmehr ist die reale zeilenposition row/2.


}}

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

'signaldefinitionen bellatrixix

#0,     D0,D1,D2,D3,D4,D5,D6,D7                         'datenbus
#8,     BEL_VGABASE                                     'vga-signale (8pin)
#16,    BEL_KEYBC,BEL_KEYBD                             'keyboard-signale
#18,    BEL_MOUSEC,BEL_MOUSED                           'maus-signale
#20,    BEL_VIDBASE                                     'video-signale(3pin)
#23,    BEL_SELECT                                      'belatrix-auswahlsignal
#24,    HBEAT                                           'front-led
        BUSCLK                                          'bustakt
        BUS_WR                                          '/wr - schreibsignal
        BUS_HS '                                        '/hs - quittungssignal

'                   +----------
'                   |  +------- system     
'                   |  |  +---- version    (änderungen)
'                   |  |  |  +- subversion (hinzufügungen)
CHIP_VER        = $00_01_01_01
'
'                                           +---------- 
'                                           | +-------- 
'                                           | |+------- vektor
'                                           | ||+------ grafik
'                                           | |||+----- text
'                                           | ||||+---- maus
'                                           | |||||+--- tastatur
'                                           | ||||||+-- vga
'                                           | |||||||+- tv
CHIP_SPEC       = %00000000_00000000_00000000_00010110

COLS         = VGA#cols                                         'anzahl der spalten
ROWS         = VGA#rows                                         'anzahl der zeilen
TILES        = COLS * ROWS
RESX         = 1024
RESY         = 768
COLORANZ     = 8

USERCHARS    = 16               '8x2 logo

TAB1         = 16
TAB2         = 32
TAB3         = 48
TABANZ       = 8
SPACETILE    = $8000 + $20 << 6

VGA_BASPORT  = 8                                       'vga startport
VGA_RESX     = COLS * 16                               'vga anzahl pixel x
VGA_RESY     = ROWS * 16                               'vga anzahl pixel y
KEYB_DPORT   = BEL_KEYBD                               'tastatur datenport
KEYB_CPORT   = BEL_KEYBC                               'tastatur taktport
CURSORCHAR   = $0E                                     'cursorzeichen

'          hbeat   --------+                            
'          clk     -------+|                            
'          /wr     ------+||                            
'          /hs     -----+||| +------------------------- /cs
'                       |||| |                 -------- d0..d7
DB_IN            = %00001001_00000000_00000000_00000000 'maske: dbus-eingabe
DB_OUT           = %00001001_00000000_00000000_11111111 'maske: dbus-ausgabe

M1               = %00000010_00000000_00000000_00000000
M2               = %00000010_10000000_00000000_00000000 'busclk=1? & /cs=0?

M3               = %00000000_00000000_00000000_00000000
M4               = %00000010_00000000_00000000_00000000 'busclk=0?


OBJ

  vga        : "bel-htext"
  keyb       : "bel-keyb"

VAR

  long  keycode                                         'letzter tastencode
  long  col, row, color                                 'spalten-, zeilenposition und zeichenfarbe
  byte  cursor                                          'cursorzeichen
  byte  curstat                                         'cursorstatus 1 = ein
  byte  sline                                           'startzeile des scrollfensters (0 = 1. zeile)
  byte  eline                                           'endzeile des scrollfensters (0 = 1. zeile)
  byte  tab[TABANZ]                                     'tabulatorpositionen
  word  user_charbase                                   'adresse der userzeichen

' htext-variablen
  byte array[TILES]                                     'bildschirmspeicher
  byte VGACogStatus                                     'status des vga-treiber-cogs
  byte cx0, cy0, cm0                                    'x, y, mode von cursor 0
  byte cx1, cy1, cm1                                    'x, y, mode von cursor 1
  word colors[rows]                                     'zeilenfarbenspeicher
  long ScreenIndex                                      'index im bildschirmspeicher
  long RowIndex                                         'zeilenindex
  long ColumnIndex                                      'spaltenindex
  long sync                                             'gets signal for vertical refresh sync

CON ''------------------------------------------------- BELLATRIX

PUB main | zeichen,n                                    'chip: kommandointerpreter
''funktionsgruppe               : chip
''funktion                      : kommandointerpreter
''eingabe                       : -
''ausgabe                       : -

  init_subsysteme                                       'bus/vga/keyboard/maus initialisieren
  repeat
    zeichen := bus_getchar                              '1. zeichen empfangen
    if zeichen > 0
      print_char(zeichen)
    else
      zeichen := bus_getchar                            '2. zeichen kommando empfangen
      case zeichen
        1: key_stat                                     '1: Tastaturstatus senden
        2: key_code                                     '2: Tastaturzeichen senden
        3: print_ctrl(bus_getchar)                      '3: Steuerzeichen ($100..$1FF) ausgeben
        4: key_spec                                     '4: Statustasten ($100..$1FF) abfragen
        5: print_logo                                   '5: hive-logo ausgeben
'       ----------------------------------------------  CHIP-MANAGMENT
        90: mgr_getcolor                                'farbregister auslesen
        91: mgr_setcolor                                'farbregister setzen
        92: mgr_getresx                                 'x-auflösung abfragen   
        93: mgr_getresy                                 'y-auflösung abfragen
        94: mgr_getcols                                 'spaltenanzahl abfragen
        95: mgr_getrows                                 'zeilenanzahl abfragen
        96: mgr_getcogs                                 'freie cogs abfragen
        97: mgr_getspec                                 'codeversion abfragen
        98: mgr_getver                                  '5: Belegte Cogs abfragen
        99: reboot                                      '99: bellatrix neu starten

PUB init_subsysteme|i                                   'chip: initialisierung des bellatrix-chips
''funktionsgruppe               : chip
''funktion                      : - initialisierung des businterface
''                              : - vga & keyboard-treiber starten
''eingabe                       : -
''ausgabe                       : -

  dira := db_in                                         'datenbus auf eingabe schalten
  outa[bus_hs] := 1                                     'handshake inaktiv
  keyb.start(keyb_dport, keyb_cport)                    'tastaturport starten
  start_htext(vga_basport, @sync)                       'vga-treiber starten
  print_char($100)                                      'bildschirm löschen
  cursor := CURSORCHAR                                  'cursorzeichen setzen
  curstat := 1                                          'cursor anschalten
  sline := 2                                            'startzeile des scrollbereichs setzen
  eline := rows                                         'enbdzeile des scrollbereichs setzen
  repeat i from 0 to TABANZ-1                           'tabulatoren setzen
    tab[i] := i * 4

  user_charbase := @uchar & $FFC0                       'berechnet die nächste 64-byte-grenze hinter dem zeichensatz
  longmove(user_charbase,@uchar,16*USERCHARS)           'verschiebt den zeichensatz auf die nächste 64-byte-grenze

PUB start_htext(BasePin,pSyncAddress)| ColorIndex
  vga.stop                                              'stopt ein bereits laufenden vga-task
  cm0 := %000                                           'cursor 0 aus
  cm1 := %110                                           'cursor 1 unterstrich blinkend
  print_char($0E)                                           'bildschirm löschen

  ColorIndex := 0                                       'graue balken auf scharzem grund
  repeat rows
    colors[ColorIndex++] := %00000100_01101000          'rrggbb00_rrggbb00

  VGACogStatus := VGA.Start(BasePin,@array, @colors, @cx0, pSyncAddress) 'startet vga-treiber (2cogs)

  return true

PUB bus_putchar(zeichen)                                'chip: ein byte an regnatix senden
''funktionsgruppe               : chip
''funktion                      : ein byte an regnatix senden
''eingabe                       : byte
''ausgabe                       : -

  waitpeq(M1,M2,0)                                      'busclk=1? & prop2=0?
  dira := db_out                                        'datenbus auf ausgabe stellen
  outa[7..0] := zeichen                                 'daten ausgeben
  outa[bus_hs] := 0                                     'daten gültig
  waitpeq(M3,M4,0)                                      'busclk=0?
  dira := db_in                                         'bus freigeben
  outa[bus_hs] := 1                                     'daten ungültig

PUB bus_getchar : zeichen                               'chip: ein byte von regnatix empfangen
''funktionsgruppe               : chip
''funktion                      : ein byte von regnatix empfangen
''eingabe                       : -
''ausgabe                       : byte

   waitpeq(M1,M2,0)                                     'busclk=1? & prop2=0?
   zeichen := ina[7..0]                                 'daten einlesen
   outa[bus_hs] := 0                                    'daten quittieren
   outa[bus_hs] := 1
   waitpeq(M3,M4,0)                                     'busclk=0?



CON ''------------------------------------------------- SUBPROTOKOLL-FUNKTIONEN

PUB sub_putlong(wert)                                   'sub: long senden       
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen long-wert an regnatix zu senden
''eingabe                       : 32bit wert der gesendet werden soll
''ausgabe                       : -
''busprotokoll                  : [put.byte1][put.byte2][put.byte3][put.byte4]
''                              : [  hsb    ][         ][         ][   lsb   ]

   bus_putchar(wert >> 24)                              '32bit wert senden hsb/lsb
   bus_putchar(wert >> 16)
   bus_putchar(wert >> 8)
   bus_putchar(wert)

PUB sub_getlong:wert                                    'sub: long empfangen    
''funktionsgruppe               : sub
''funktion                      : subprotokoll um einen long-wert von regnatix zu empfangen
''eingabe                       : -
''ausgabe                       : 32bit-wert der empfangen wurde
''busprotokoll                  : [get.byte1][get.byte2][get.byte3][get.byte4]
''                              : [  hsb    ][         ][         ][   lsb   ]

  wert :=        bus_getchar << 24                      '32 bit empfangen hsb/lsb
  wert := wert + bus_getchar << 16
  wert := wert + bus_getchar << 8
  wert := wert + bus_getchar

CON ''------------------------------------------------- CHIP-MANAGMENT-FUNKTIONEN

PUB mgr_getcolor|cnr                                    'cmgr: farbregister auslesen
''funktionsgruppe               : cmgr
''funktion                      : farbregister auslesen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][091][get.cnr][sub_putlong.color]
''                              : cnr   - nummer des farbregisters 0..15
''                              : color - erster wert

  cnr := bus_getchar
  sub_putlong(long[@vgacolors][cnr])

PUB mgr_setcolor|cnr                                    'cmgr: farbregister setzen
''funktionsgruppe               : cmgr
''funktion                      : farbregister setzen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][091][get.cnr][sub_getlong.color]
''                              : cnr   - nummer des farbregisters 0..15
''                              : color - farbwert

  cnr   := bus_getchar
  long[@vgacolors][cnr] := sub_getlong

PUB mgr_getresx                                         'cmgr: abfrage der x-auflösung
''funktionsgruppe               : cmgr
''funktion                      : abfrage der x-auflösung
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][092][put.resx]
''                              : resx - x-auflösung

  sub_putlong(RESX)

PUB mgr_getresy                                         'cmgr: abfrage der y-auflösung
''funktionsgruppe               : cmgr
''funktion                      : abfrage der y-auflösung
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][093][put.resy]
''                              : resy - y-auflösung

  sub_putlong(RESY)

PUB mgr_getcols                                         'cmgr: abfrage der Textspalten
''funktionsgruppe               : cmgr
''funktion                      : abfrage der textspalten
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][094][put.cols]
''                              : cols - anzahl der textspalten

  bus_putchar(COLS)
  
PUB mgr_getrows                                         'cmgr: abfrage der textzeilen
''funktionsgruppe               : cmgr
''funktion                      : abfrage der textzeilen
''eingabe                       : -
''ausgabe                       : -
''busprotokoll                  : [0][095][put.rows]
''                              : rows - anzahl der textzeilen

  bus_putchar(ROWS/2)
  
PUB mgr_getcogs: cogs |i,c,cog[8]                       'cmgr: abfragen wie viele cogs in benutzung sind
''funktionsgruppe               : cmgr
''funktion                      : abfrage wie viele cogs in benutzung sind
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [0][096][put.cogs]
''                              : cogs - anzahl der belegten cogs

  cogs := i := 0
  repeat 'loads as many cogs as possible and stores their cog numbers
    c := cog[i] := cognew(@entry, 0)
    if c=>0
      i++
  while c => 0
  cogs := i
  repeat 'unloads the cogs and updates the string
    i--
    if i=>0
      cogstop(cog[i])
  while i=>0
  bus_putchar(cogs)

PUB mgr_getspec                                         'cmgr: abfrage der spezifikation des chips
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [097][sub_putlong.spec]
''                              : spec - spezifikation
''
''
''                                          +---------- 
''                                          | +-------- 
''                                          | |+------- vektor
''                                          | ||+------ grafik
''                                          | |||+----- text
''                                          | ||||+---- maus
''                                          | |||||+--- tastatur
''                                          | ||||||+-- vga
''                                          | |||||||+- tv
''CHIP_SPEC     = %00000000_00000000_00000000_00010110

  sub_putlong(CHIP_SPEC)

PUB mgr_getver                                          'cmgr: abfrage der version 
''funktionsgruppe               : cmgr
''funktion                      : abfrage der version und spezifikation des chips
''eingabe                       : -
''ausgabe                       : cogs - anzahl der cogs
''busprotokoll                  : [098][sub_putlong.ver]
''                              : ver - version
''
''                  +----------
''                  |  +------- system     
''                  |  |  +---- version    (änderungen)
''                  |  |  |  +- subversion (hinzufügungen)
''CHIP_VER      = $00_01_01_01

  sub_putlong(CHIP_VER)

CON ''------------------------------------------------- KEYBOARD-FUNKTIONEN

PUB key_stat                                            'key: tastaturstatus abfragen

  bus_putchar(keyb.gotkey)

PUB key_code                                            'key: tastencode abfragen

  keycode := keyb.key
  bus_putchar(keycode)

PUB key_spec                                            'key: statustaten vom letzten tastencode abfragen

  bus_putchar(keycode >> 8)

CON ''------------------------------------------------- SCREEN-FUNKTIONEN

PUB print_char(c) | code,n                              'screen: zeichen auf bildschirm ausgeben
{{zeichen auf bildschirm ausgeben}}

  case c

    $0A:                                                'LF ausblenden
      return
      
    $00..$0C:
      schar(c)

    $0D:                                                'return?
      newline

    $0E..$FF:                                           'character?
      schar(c)

PUB home
'' move writing place to upper left without clearing screen
  SetXY(0,sline)

PUB SetXY(x,y)
  ColumnIndex := x <# cols                              'setzt spalte mit begrenzung auf spaltenzahl
  RowIndex := y <# rows                                 'setzt zeile mit begrenzung auf zeilenzahl
  ScreenIndex := ColumnIndex + (RowIndex * cols)        'berechnet bildschirmindex

PUB print_ctrl(c) | code,n,m                            'screen: steuerzeichen ausgeben

  case c

    $00:                                                'clear screen?
      ScreenIndex := 0
      n := sline * cols
      repeat TILES - n
        array[n + ScreenIndex++] := 32
      home
{
      if curstat == 1                                   'cursor ausschalten?
        schar($20)
      n := sline * cols
      'wordfill(@array + n, spacetile, tiles - n)
      wordfill(@array.word[n], spacetile, tiles-n)
      row := sline 
      col := 0
      if curstat == 1                                   'cursor einschalten
        schar(cursor)
}
    $01:                                                'home?
      row := sline
      col := 0

    $02:                                                'backspace?
      if col
        col--

    $03:                                                'tab
      repeat n from 0 to TABANZ-1
        if col < tab[n]
          col := tab[n]
          quit

    $04:                                                'setcur
      code := bus_getchar
      cursor := code

    $05:                                                'pos1
      col := 0

    $06:                                                'setx
      col := bus_getchar

    $07:                                                'sety
      row := bus_getchar * 2 + sline                    '2 tiles pro zeichen!

    $08:                                                'getx
      bus_putchar(col)

    $09:                                                'gety
      bus_putchar(row / 2)

    $10:                                                'setcolor
      color := bus_getchar

    $11:                                                'sline
      sline := bus_getchar * 2

    $12:                                                'eline
      eline := bus_getchar * 2

    $13:                                                'screeninit
      ScreenIndex := 0
      repeat TILES
        array[ScreenIndex++] := 32
      RowIndex := 0
      ColumnIndex := 0
      sline := 0
{
      wordfill(@array, spacetile, tiles)
      row := 0
      col := 0
      sline := 0
}
    $14:                                                'curon
      curstat := 1

    $15:                                                'curoff
      curstat := 0

    $16:                                                'scrollup
      scrollup

    $17:                                                'scrolldown
      scrolldown

    $18:                                                'tabulator setzen
        n := bus_getchar
        m := bus_getchar
        if n =< (TABANZ-1)
          tab[n] := m
    
PRI xschar(c)| i,k                                       'screen: schreibt zeichen an aktuelle position ohne cursor
  k := color << 1 + c & 1
  i := $8000 + (c & $FE) << 6 + k
  array.word[row * cols + col] := i                                             'oberes tile setzen
  array.word[(row + 1) * cols + col] := i | $40                                 'unteres tile setzen

PRI schar(c)                    'schreibt zeichen an aktuelle position ohne cursorposition zu verändern
array[RowIndex * cols + ColumnIndex] := c
if ++ColumnIndex == cols
  newline
cx1 := ColumnIndex
cy1 := RowIndex

PRI xpchar(c)                                            'screen: schreibt zeichen mit cursor an aktuelle position
  schar(c)
  if ++col == cols
    newline

PRI pchar(c)
'schreibt zeichen an aktuelle position z?hlt position weiter
  schar(c)
  if ++ColumnIndex == cols
    newline

PUB xnewline | i                                         'screen: zeilenwechsel, inkl. scrolling am screenende

  col := 0
  if (row += 2) => eline 
    row -= 2
    'scroll lines
    repeat i from sline to eline-3 

      wordmove(@array.word[i*cols], @array.word[(i+2)*cols], cols)              'wordmove(dest,src,cnt)
    'clear new line
    wordfill(@array.word[(eline-2)*cols], spacetile, cols<<1)

PUB newline | i

  ColumnIndex := 0
  if (RowIndex += 1) == rows
    RowIndex -= 1
    'scroll lines
    repeat i from sline to rows-2
      bytemove(@array[i*cols], @array[(i+1)*cols], cols)   'BYTEMOVE (DestAddress, SrcAddress, Count)

    'clear new line
'    bytefill(@array[(rows-1)*cols], 32, cols<<1)           'BYTEFILL (StartAddress, Value, Count)
'    code fehlerhaft, zähler ist falsch gesetzt!

    bytefill(@array[(rows-1)*cols], 32, cols)           'BYTEFILL (StartAddress, Value, Count)

PUB scrollup | i                                        'screen: scrollt den screen nach oben

    'scroll lines
    wordmove(@array.word[sline*cols],@array.word[(sline+2)*cols],(eline-1-sline)*cols) 'wordmove(dest,src,cnt)
    'clear new line
    wordfill(@array.word[(eline-2)*cols], spacetile, cols<<1)

PUB scrolldown | i                                      'screen: scrollt den screen nach unten
    'scroll lines
    i := eline - 1
    repeat eline-sline-1
      wordmove(@array.word[i*cols], @array.word[(i-2)*cols], cols)              'wordmove(dest,src,cnt)
      i--
    'clear new line
    wordfill(@array.word[(sline)*cols], spacetile, cols<<1)

PRI print_logo|padr,x,y                                                         'screen: hive-logo ausgeben

  x := bus_getchar
  y := bus_getchar
  padr := @hive+user_charbase-@uchar
  DrawBitmap(padr, x, y, 8, 2, 1)                       'logo zeichnen                 


PRI DrawBitmap(pBitmap, xPos, yPos, xSize, ySize, clr)|c,i,j,pcol,prow          'screen: zeichnet ein einzelnes tilefeld
{
- setzt in der tilemap des vga-treibers die adressen auf das entsprechende zeichen
- setzt mehrer tiles je nach xSize und ySize
- jedes tile besteht aus 16x16 pixel, weshalb die adresse jedes tiles mit c<<6 gebildet wird
- alle 64 byte (c<<6) beginnt im bitmap ein tile
}
  prow:=yPos
  pcol:=xPos
  c:=0
  repeat j from 0 to (ySize-1)
    repeat i from 0 to (xSize-1)
      array.word[prow * cols + pcol] := pBitmap + (c<<6) + clr
      c++
      pcol++
    prow++
    pcol:=xPos

DAT
{{

''    array_ptr = Pointer to 3,072 long-aligned words, organized as 64 across by 48 down,
''                which will serve as the tile array. Each word specifies a tile bitmap and
''                a color palette for its tile area. The top 10 bits of each word form the
''                base address of a 16-long tile bitmap, while the lower 6 bits select a
''                color palette for the bitmap. For example, $B2E5 would specify the tile
''                bitmap spanning $B2C0..$B2FF and color palette $25.

''    color_ptr = Pointer to 64 longs which will define the 64 color palettes. The RGB data
''                in each long is arranged as %%RGBx_RGBx_RGBx_RGBx with the sub-bytes 3..0
''                providing the color data for pixel values %11..%00, respectively:
''
''                %%3330_0110_0020_3300: %11=white, %10=dark cyan, %01=blue, %00=gold
''
        %% ist quaternary-darstellung; jedes digit von 0 bis 3, also 4-wertigkeit

        bildaufbau: 24 zeilen zu je 64 zeichen; jedes zeichen wird durch zwei tiles gebildet
        die ?bereinander liegen.
        jedes tile belegt ein word: 10 bit bitmap und 6 bit color. zwei tiles ein long.


'0     %%RGBx_RGBx_RGBx_RGBx
  long %%0330_0010_0330_0010
  long %%0330_0330_0010_0010


   long $3C043C04       'grau/blau erste -  hive-version
   long $3C3C0404

Color-Calculator:

http://www.rayslogic.com/propeller/Programming/Colors.htm

For the 1024x768 VGA tile driver:
2 longs are required for each text foreground/background color combo, arranged as:
        $ff_bb_ff_bb
        $ff_ff_bb_bb
        where 'ff' is the foreground color and 'bb' is the background color
        2 longs needed because characters are in an interleaved pair
        The first long is the color for the first character in a pair, the second long is for the second character in a pair.
        Demo routine "print()" only allows for 8 fore/back combinations (using longs 0 to 15)

1 long required for box colors,  arranged as:
        $tl_br_fi_bb
        where 'tl' is top-left edge, 'br' is bottom-right edge, 'fi' is focus indicators, and 'bb' is background color
        The demo "box()" procedure hardwired to add 16 to input color number to pick box color and adds 5 to input
        color number to pick text color for box...
        So, "box(left,top,clr,str)" uses color number 16+clr for box colors and 5+clr for text color.  You probably want
        the 'bb' background colors of these two to match! Note that this limits you to 4 box colors.

1 long used for graphics colors, arranged as
        $00_11_22_33
        where 00,11,22,33 are the selectable graphics colors 0,1,2,3
        Demo hardwired to use the 21st long (last one) for the graphics colors

The Propeller's "tile driver" video uses 32-bit (long) values to define a four color palette
The "color_ptr" parameter, given to the tile driver, specifies the location of the data block of up to 64 different
long palette values
Each long palette represents 4 different colors, one byte each.  Each color byte uses 2 bits for each primary colors,
RGB, arranged as RGBx.  The "x" represents the two least significant bits, which are ignored.
Parallax gives this example of a 32-bit long palette, represented as a 16-digit quaternary (2-bit) number:
 %%3330_0110_0020_3300 or $FC1408F0
The first byte, %%3330 (binary %11111100), is the color white
The second byte, %%0110, is the color dark cyan

}}

                        org
'
' Entry: dummy-assemblercode fuer cogtest
'
entry                   jmp     entry                   'just loops

vgacolors long                                  'farbpalette

'============================================================
'          v  h  v  h        ' v=Vordergrund, h=Hintergrund
'   long $ 3C 04 3C 04       'Muster
'          v  v  h  h
'   long $ 3C 3C 04 04       'Muster
'0     %%RGBx_RGBx_RGBx_RGBx
' long %%0330_0010_0330_0010
' long %%0330_0330_0010_0010
'============================================================

'set 1 - grau auf weiß

  long $54FC54FC       'grau/weiß
  long $5454FCFC
  long $58FC58FC       'hellblau/weiß
  long $5858FCFC
  long $64FC64FC       'hellgrün/weiß
  long $6464FCFC
  long $94FC94FC       'hellrot/weiß
  long $9494FCFC
  long $00FC00FC       'schwarz/weiß
  long $0000FCFC
  long $0CFC0CFC       'blau/weiß
  long $0C0CFCFC
  long $30FC30FC       'grün/weiß
  long $3030FCFC
  long $C0FCC0FC       'rot/weiß
  long $C0C0FCFC


  long $C0408080       'redbox
  long $CC440088       'magentabox
  long $3C142828       'cyanbox
  long $FC54A8A8       'greybox
  long $3C14FF28       'cyanbox+underscore
  long $F030C050       'graphics colors
  long $881430FC
  long $8008FCA4


'set 2 - weiß auf schwarz
{
  long $FC00FC00       'schwarz/weiß
  long $FCFC0000
  long $A800A800       'schwarz/hellgrau
  long $A8A80000
  long $54005400       'schwarz/dunkelgrau
  long $54540000
  long $30043004       'grün/blau
  long $30300404
  long $043C043C       'Color 0 reverse
  long $04043C3C 
  long $FC04FC04       'weiss/blau
  long $FCFC0404  
  long $FF80FF80       'red/white
  long $FFFF8080
  long $88048804       'magenta/blau
  long $88880404

  long $C0408080       'redbox
  long $CC440088       'magentabox
  long $3C142828       'cyanbox
  long $FC54A8A8       'greybox
  long $3C14FF28       'cyanbox+underscore
  long $F030C050       'graphics colors
  long $881430FC
  long $8008FCA4
}


'set 3 - hellblau auf dunkelblau
{
  long $3C043C04       'grau/blau erste -  hive-version
  long $3C3C0404
  long $F004F004       'yellow/blue
  long $F0F00404
  long $C004C004       'rot/blau
  long $C0C00404
  long $30043004       'grün/blau
  long $30300404
  long $043C043C       'Color 0 reverse
  long $04043C3C 
  long $FC04FC04       'weiss/blau
  long $FCFC0404  
  long $FF80FF80       'red/white
  long $FFFF8080
  long $88048804       'magenta/blau
  long $88880404

  long $C0408080       'redbox
  long $CC440088       'magentabox
  long $3C142828       'cyanbox
  long $FC54A8A8       'greybox
  long $3C14FF28       'cyanbox+underscore
  long $F030C050       'graphics colors
  long $881430FC
  long $8008FCA4
}

'set 4 - chess
{
'0..1:  text color 0:  
  long $F010F010                                '0: Yellow on Green  
  long $F0F01010 
'2..3:  text color 1: 
  long $C0FCC0FC                                '1: red on white   
  long $C0C0FCFC
'4..5:  text color 2:        
  long $00FC00FC                                '2: black on white  
  long $0000FCFC 

'6..7:  text color 3:     
  long $F010F010                                '3: Yellow on Green  
  long $F0F01010 

  long $043C043C       'Color 0 reverse
  long $04043C3C 
  long $FC04FC04       'weiss/blau
  long $FCFC0404  
  long $FF80FF80       'red/white
  long $FFFF8080
  long $88048804       'magenta/blau
  long $88880404

  long $C0408080       'redbox
  long $CC440088       'magentabox
  long $3C142828       'cyanbox
  long $FC54A8A8       'greybox
  long $3C14FF28       'cyanbox+underscore
  long $F030C050       'graphics colors
  long $881430FC
  long $8008FCA4
}

' alte definitionen
{
   long $F010F010        'yellow on dk green
   long $F0F01010
   long $C000C000       'red
   long $C0C00000
   long $30003000       'green
   long $30300000
   long $0C000C00       'blue
   long $0C0C0000
   long $FC04FC04       'white
   long $FCFC0404
   long $FF88FF88       'magenta/white
   long $FFFF8888

  long $C0408080       'redbox
  long $CC440088       'magentabox
  long $3C142828       'cyanbox
  long $FC54A8A8       'greybox
  long $3C14FF28       'cyanbox+underscore
  long $F030C050       'graphics colors
  long $881430FC
  long $8008FCA4
}
DAT

padding       long 1[16]        '64-byte raum für die ausrichtung des zeichensatzes     
uchar         long

hive    long
file "logo-hive-8x2.dat"         '8x2=16

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
