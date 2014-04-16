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
Name            : Filemanager
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        :
Komponenten     : -
COG's           : -
Logbuch         :
Kommandoliste   :
Notizen         :

- view nach f9
- tab in wbox

}}

OBJ

  ios      : "reg-ios"
  dlbox[2] : "gui-dlbox"
  pbar     : "gui-pbar"
  wbox     : "gui-wbox"
  input    : "gui-input"
  fm       : "fm-con"
  gc       : "glob-con"
  str      : "glob-string"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

  byte  rows,cols,vidmod
  byte  fname[fm#MAX_LEN+1]
  byte  dir                     'richtung der cursorbewegung
  byte  fl_mounted              '1 = sd mounted
  byte  fl_full                 '1 = linkes fenster maximiert
  byte  w_sel                   'nr des fokusierten fensters
  byte  w_pos[2]                'positionen im fenster
  byte  w_view[2]               'startposition des fensters
  byte  w_cols[2]               'anzahl der spalten im fenster
  byte  w_drives[2]             'zugeordnete drives

  byte  w0_list[fm#MAX_BUFFER]  'aktuelles verzeichnis
  byte  w0_flags[fm#MAX_FILES]  'selected, directory usw.
  long  w0_len[fm#MAX_FILES]    'dateilängen
  byte  w0_number               'anzahl der files

  byte  w1_list[fm#MAX_BUFFER]
  byte  w1_flags[fm#MAX_FILES]
  long  w1_len[fm#MAX_FILES]
  byte  w1_number

PUB main | key

  init
  dlbox[0].focus
  dlbox[0].draw
  dlbox[1].draw
  info_print

  repeat
    key := ios.keywait
    case key
      gc#KEY_CURUP:             f_curup
      gc#KEY_CURDOWN:           f_curdown
      gc#KEY_CURLEFT:           f_curleft
      gc#KEY_CURRIGHT:          f_curright
      gc#KEY_PAGEUP:            f_pageup
      gc#KEY_PAGEDOWN:          f_pagedown
      gc#KEY_RETURN:            f_open
      gc#KEY_BS:                f_back
      gc#KEY_SPACE:             f_select
      gc#KEY_ESC:
      gc#KEY_TAB:               f_focus
      gc#KEY_POS1:              f_pos1
      gc#KEY_F01:               f_view
      gc#KEY_F02:               f_del
      gc#KEY_F03:               f_load
      gc#KEY_F04:               f_save
      gc#KEY_F05:               f_empty
      gc#KEY_F06:               f_mount
      gc#KEY_F07:               f_mkdir
      gc#KEY_F08:               f_selall
      gc#KEY_F09:               f_full
      gc#KEY_F10:               f_quit

PRI init

  ios.start
  testvideo

  dir := 1
  fl_mounted := 1
  fl_full := 0
  w_sel := 0
  w_pos[0] := w_pos[1] := 0
  w_view[0] := w_view[1] := 0
  w_cols[0] := (fm#W1X2-fm#W1X1)/(fm#MAX_LEN+2)
  w_cols[1] := (fm#W2X2-fm#W2X1)/(fm#MAX_LEN+2)
  w_drives[0] := fm#DR_SD
  w_drives[1] := fm#DR_RAM
  fname[0] := 0

  frame_draw
  w0_clrlist
  w1_clrlist
  w0_readdir
  w1_readdir
  dlbox[0].define(1,fm#W1X1,fm#W1Y1,fm#W1X2,fm#W1Y2,@w0_list,@w0_flags,0,fm#MAX_FILES) 'linkes fenster
  dlbox[1].define(2,fm#W2X1,fm#W2Y1,fm#W2X2,fm#W2Y2,@w1_list,@w1_flags,0,fm#MAX_FILES) 'rechtes fenster
  ios.windefine(3,fm#W3X1,fm#W3Y1,fm#W3X2,fm#W3Y2)                                     'logfenster
  pbar.define(4,fm#W4X1,fm#W4Y1,fm#W4X2,fm#W4Y2)
  wbox.define(5,fm#W4X1,fm#W4Y1,fm#W4X2,fm#W4Y2)
  input.define(6,fm#W4X1,fm#W4Y1,fm#W4X2,fm#W4Y2,12)


PRI f_mount

  if fl_mounted
    ios.sdunmount
    repeat
      wbox.draw(@str5,@str2,@str3) == 1
    while ios.sdmount
  dlbox[0].draw
  dlbox[1].draw
  info_print

PRI f_mkdir

  ios.sdnewdir(input.draw(string("Name eingeben : ")))
  w0_clrlist
  w0_readdir
  dlbox[0].draw
  dlbox[1].draw
  info_print

PRI f_selall | i

  i := 0
  case w_sel
    0: repeat w0_number
         w0_flags[i++] ^= fm#FL_SEL
    1: repeat w1_number
         w1_flags[i++] ^= fm#FL_SEL
  dlbox[w_sel].redraw

PRI f_pos1

  w_pos[w_sel] := 0
  dlbox[w_sel].setpos(w_pos[w_sel])

PRI f_full

  if w_sel
    dlbox[1].defocus

  case fl_full
    0:  fl_full := 1
        dlbox[0].define(1,fm#W1X1,fm#W1Y1,fm#W2X2,fm#W1Y2,@w0_list,@w0_flags,0,fm#MAX_FILES) 'volles fenster
        dlbox[0].focus
        w_cols[0] := (fm#W2X2-fm#W1X1)/(fm#MAX_LEN+2)
    1:  fl_full := 0
        dlbox[0].define(1,fm#W1X1,fm#W1Y1,fm#W1X2,fm#W1Y2,@w0_list,@w0_flags,0,fm#MAX_FILES) 'linkes fenster
        w_cols[0] := (fm#W1X2-fm#W1X1)/(fm#MAX_LEN+2)
        dlbox[0].focus
        dlbox[1].draw
  w_sel := 0

PRI f_open

  'nur fenster 1 und verzeichnisse
  if (w_sel == 0) & (w0_flags[w_view[w_sel] + w_pos[w_sel]] & fm#FL_DIR)
    ios.sdchdir(get_fname(w_view[w_sel] + w_pos[w_sel]))
    w0_clrlist
    w0_readdir
    dlbox[w_sel].draw
    info_print

PRI f_back

  ios.sdchdir(string(".."))
  w0_clrlist
  w0_readdir
  dlbox[w_sel].redraw
  info_print

PRI f_curup

  if w_pos[w_sel] > 1
    w_pos[w_sel] -= dlbox[w_sel].getcols
  dlbox[w_sel].setpos(w_pos[w_sel])
  info_print
  dir := 0

PRI f_curdown

  if w_pos[w_sel] < (fm#WROWS * w_cols[w_sel] - dlbox[w_sel].getcols)
    w_pos[w_sel] += dlbox[w_sel].getcols
  dlbox[w_sel].setpos(w_pos[w_sel])
  info_print
  dir := 1

PRI f_curleft

  if w_pos[w_sel]
    w_pos[w_sel]--
  dlbox[w_sel].setpos(w_pos[w_sel])
  info_print
  dir := 0

PRI f_curright

  if w_pos[w_sel] < (fm#WROWS * w_cols[w_sel] - 1)
    w_pos[w_sel]++
  dlbox[w_sel].setpos(w_pos[w_sel])
  info_print
  dir := 1

PRI f_pageup

  if (w_view[w_sel] - fm#WROWS * w_cols[w_sel]) => 0
    w_view[w_sel] -= fm#WROWS * w_cols[w_sel]
  dlbox[w_sel].setview(w_view[w_sel])
  info_print
  w_pos[w_sel] := fm#WROWS * w_cols[w_sel] - 1
  dlbox[w_sel].setpos(w_pos[w_sel])

PRI f_pagedown | number

  case w_sel
    0: number := w0_number
    1: number := w1_number
  if (w_view[w_sel] + fm#WROWS * w_cols[w_sel]) =< number '(fm#MAX_FILES)
    w_view[w_sel] += fm#WROWS * w_cols[w_sel]
  dlbox[w_sel].setview(w_view[w_sel])
  info_print
  w_pos[w_sel] := 0
  dlbox[w_sel].setpos(w_pos[w_sel])

PRI f_select | i

  i := w_view[w_sel] + w_pos[w_sel]
  case w_sel
    0: w0_flags[i] ^= fm#FL_SEL
    1: w1_flags[i] ^= fm#FL_SEL
  dlbox[w_sel].redraw
  case dir
    0: f_curleft
    1: f_curright

PRI f_focus

ifnot fl_full
  dlbox[w_sel].defocus
  if w_sel == 1
    w_sel := 0
  else
    w_sel := 1
  dlbox[w_sel].focus
  info_print

PRI f_quit

  ios.sddmset(ios#DM_USER)  'regime soll in diesem verzeichnis landen
  ios.winset(0)
  ios.screeninit
  ios.stop

PRI f_load | i

  pbar.setmaxbar(w0_number)
  i := 0
  repeat w0_number
    if w0_flags[i] & fm#FL_SEL
      pbar.draw(string("Lade Datei : "),get_fname(i),i)
      load(get_fname(i))
      w0_flags[i] ^= fm#FL_SEL
      info_print
    i++
    pbar.update(i)
  w1_readdir
  dlbox[0].draw
  dlbox[1].draw

PRI f_save | i

  pbar.setmaxbar(w1_number)
  i := 0
  repeat w1_number
    if w1_flags[i] & fm#FL_SEL
      pbar.draw(string("Speichere Datei : "),get_fname(i),i)
      save(get_fname(i))
      w1_flags[i] ^= fm#FL_SEL
    i++
    pbar.update(i)
  w0_clrlist
  w0_readdir
  dlbox[0].draw
  dlbox[1].draw

PRI f_del | i

if wbox.draw(@str1,@str2,@str3) == 1
  pbar.setmaxbar(w0_number)
  i := 0
  repeat w0_number
    if w0_flags[i] & fm#FL_SEL
      pbar.draw(string("Lösche Datei : "),get_fname(i),i)
      ios.sddel(get_fname(i))
      w0_flags[i] ^= fm#FL_SEL
    i++
    pbar.update(i)
  w0_clrlist
  w0_readdir
dlbox[0].draw
dlbox[1].draw
info_print

PRI f_empty

if wbox.draw(@str4,@str2,@str3) == 1
  ios.ram_wrlong(ios#sysmod,ios#SYSVAR,ios#RAMEND)                'Zeiger auf letzte freie Speicherzelle setzen
  ios.ram_wrlong(ios#sysmod,0,ios#RAMBAS)                         'Zeiger auf erste freie Speicherzelle setzen
  ios.ram_wrbyte(ios#sysmod,0,ios#RAMDRV)                         'Ramdrive ist abgeschaltet
  ios.rd_init
  w1_clrlist
  w1_readdir
dlbox[0].draw
w_pos[1] := 0
w_view[1] := 0
dlbox[1].setpos(w_pos[1])
dlbox[w_sel].setview(w_view[1])
info_print


PRI f_view | n,stradr,ch,lch

  ios.winset(3)
  ios.curoff
  ios.printcls

  stradr := get_fname(w_view[w_sel] + w_pos[w_sel])
  n := 1
  lch := 0
  ifnot ios.os_error(ios.sdopen("r",stradr))            'datei öffnen
    repeat                                              'text ausgeben
      ch := ios.sdgetc
      if ch == ios#CHAR_NL OR ch == $0a                 'CR or NL
        if ch == lch OR (lch <> ios#CHAR_NL AND lch <> $0a)
          ios.printnl
          lch := ch
          if ++n == (fm#W3Y2 - 2)
            n := 1
            if ios.keywait == "q"
              ios.sdclose
              ios.printcls
              dlbox[0].redraw
              dlbox[1].redraw
              return
        else
          lch := 0
      else
        ios.printchar(ch)
        lch := ch
    until ios.sdeof                                     'ausgabe bis eof
  ios.print(string(13,"[EOF]"))
  ios.keywait
  ios.sdclose                                           'datei schließen

  ios.printcls
  dlbox[0].draw
  dlbox[1].draw
  info_print

PRI w0_clrlist | i

  i := 0
  repeat fm#MAX_FILES
    w0_flags[i] := 0
    w0_len[i] := 0
    i++
  i := 0
  repeat fm#MAX_BUFFER
    w0_list[i] := " "
    i++


PRI w1_clrlist | i

  i := 0
  repeat fm#MAX_FILES
    w1_flags[i] := 0
    w1_len[i] := 0
    i++
  i := 0
  repeat fm#MAX_BUFFER
    w1_list[i] := " "
    i++

PRI w0_readdir | stradr,i,j

  i := 0
  ios.sddir
  repeat while (stradr := ios.sdnext)
    if ios.sdfattrib(ios#F_DIR)
      w0_flags[i] := fm#FL_DIR
    j := 0
    repeat fm#MAX_LEN
      w0_list[i*fm#MAX_LEN+j] := byte[stradr+j]
      j++
    w0_len[i] := ios.sdfattrib(ios#F_SIZE)
    if i++ => fm#MAX_FILES - 1
      return

  w0_number := i

PRI w1_readdir | stradr,i,j

  i := 0
  ios.rd_dir
  repeat while (stradr := ios.rd_next)
    j := 0
    repeat fm#MAX_LEN
      w1_list[i*fm#MAX_LEN+j] := byte[stradr+j]
      j++
    i++
    w1_len[i] := ios.rd_dlen
  w1_number := i

PRI get_fname(fnr):adrdat | i,stradr

  i := fm#MAX_LEN * fnr
  case w_sel
    0: stradr := @w0_list + i
    1: stradr := @w1_list + i
  i := 0
  repeat
    fname[i] := byte[stradr+i]
    i++
  until byte[stradr+i] == " " OR i == fm#MAX_LEN
  fname[i] := 0
  return @fname

PRI load(stradr) | len,fnr,i

  ifnot ios.sdopen("r",stradr)            'datei öffnen
    len := ios.sdfattrib(ios#F_SIZE)
    ios.rd_newfile(stradr,len)                          'datei erzeugen
    fnr := ios.rd_open(stradr)
    ios.rd_seek(fnr,0)
    i := 0
    ios.sdxgetblk(fnr,len)                              'daten als block direkt in ext. ram einlesen
    ios.sdclose
    ios.rd_close(fnr)

PRI save(stradr) | fnr,len,i

  fnr := ios.rd_open(stradr)
  ifnot fnr == -1
    len := ios.rd_len(fnr)
    ifnot ios.sdnewfile(stradr)
      ifnot ios.sdopen("W",stradr)
        i := 0
        ios.sdxputblk(fnr,len)                          'daten als block schreiben
        ios.sdclose
    ios.rd_close(fnr)


PRI frame_draw

  ios.winset(0)
  ios.curoff
  ios.printcls
  ios.cursetx(fm#W0X_MENU)
  ios.cursety(fm#W0Y_MENU)
  ios.setcolor(fm#COL_MENU)
' ios.print(string("                                                        "))
  ios.print(string(" 6: Mount | 7: MkDir | 8: ALL | 9: Full | 10: Quit      "))
  ios.printlogo(0,0)
  ios.cursetx(fm#W0X_STAT)
  ios.cursety(fm#W0Y_STAT)
  ios.setcolor(fm#COL_STAT)
  ios.printq(string(" 1: View | 2: Del | 3: SD>>RAM ◀▶ 4: SD<<RAM | 5: RAM Clear     "))
  ios.setcolor(fm#COL_DEFAULT)

PRI info_print | pos,len

  pos := w_view[w_sel] + w_pos[w_sel]
  case w_sel
    0: len := w0_len[pos]
    1: len := w1_len[pos]
  ios.winset(0)
  ios.curoff
  ios.cursetx(fm#W0X_INFO)
  ios.cursety(fm#W0Y_INFO)
  ios.print(string("                                                              "))
  ios.cursetx(fm#W0X_INFO)
  ios.print(get_fname(pos))
  if len
    ios.print(string(" : "))
    ios.printdec(len)
    ios.print(string(" Bytes"))

  ios.cursetx(fm#W1X_INFO)
  ios.print(string("RAM : "))
  ios.printdec(ios.ram_getfree)
  ios.print(string(" Bytes free"))

PRI testvideo                                          'passt div. variablen an videomodus an

  vidmod := ios.belgetspec & 1
  rows := ios.belgetrows                                'zeilenzahl bei bella abfragen
  cols := ios.belgetcols                                'spaltenzahl bei bella abfragen

PRI pause(sec)

  waitcnt(cnt+clkfreq*sec)

DAT

str1    byte  "Dateien löschen?",0
str2    byte  "Ja",0
str3    byte  "Nein",0
str4    byte  "RAMDrive löschen?",0
str5    byte  "SD-Card mounten?",0

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
