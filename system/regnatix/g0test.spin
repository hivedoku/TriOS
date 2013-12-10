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
Name            : g0test
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

}}

OBJ
        ios: "reg-ios"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

XMAX    = 256
YMAX    = 192

x_tiles       = 16
y_tiles       = 12

bit_base      = $2000
disp_base     = $5000
len_colblk      = (x_tiles * y_tiles) * 2 + 256

'ademo1
lines           = 5
thickness       = 2
s_obj           = 200           'scale
d_obj           = 64            'durchmesser
r_obj           = d_obj/2       'radius
rotvar          = 14            'rotationsvarianz

VAR

  'achtung, folgende reihenfolge darf nicht verändert werden!
  word              screen[x_tiles * y_tiles]         'tilemap
  long              colortab[64]                      'farbregister

  long  heap_len
  long  heap_use

PUB main|i,x,y,n,len

  ios.start

  'g0-code laden
  ios.g0_load

  screenset1                                            'farben und tiles setzen

  ios.g0_static
  heap_len := ios.g0_datlen
  heap_use := @grdatend - @grdat
  ios.g0_datblk(@grdat,0,heap_len)                      'heapdaten senden
  repeat

' -------------------------------------------------------------------------- heap
    ios.g0_static
    ios.g0_clear
    ios.g0_colorwidth(2,0)
    ios.g0_textmode(2,2,6,0)
    ios.g0_text(10,100,@string3 - @grdat)
    ios.g0_printdec(150,100,heap_len,4,@strstart,@strstart - @grdat)
    ios.g0_text(10, 70,@string4 - @grdat)
    ios.g0_printdec(150, 70,heap_use,4,@strstart,@strstart - @grdat)
    esc_key
    waitcnt(cnt+clkfreq*5)

' -------------------------------------------------------------------------- plot
    ios.g0_clear
    repeat 2000
      ios.g0_width(?n&%11111)
      ios.g0_color(?n&%0011)
      ios.g0_plot(?n&$ff,?n&$ff)
      esc_key

' -------------------------------------------------------------------------- line
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000
      ios.g0_color(?n&%0011)
      ios.g0_line(?n&$ff,?n&$ff)
      esc_key

' -------------------------------------------------------------------------- arc
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000
      ios.g0_color(?n&%0011)
     'ios.g0_arc(x,y,xr,yr,angle,anglestep,steps,arcmode)
      ios.g0_arc(?n&$ff,?n&$ff,?n&$1f,?n&$1f,?n&$1fff,?n&$1fff,?n&$1f,?n&%0011)
      esc_key

' -------------------------------------------------------------------------- tri
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000
      ios.g0_colorwidth(?n&%0011,?n&%11111)
      ios.g0_tri(?n&$ff,?n&$ff,?n&$ff,?n&$ff,?n&$ff,?n&$ff)
      esc_key

' -------------------------------------------------------------------------- box
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000
      ios.g0_colorwidth(?n&%0011,?n&%11111)
      ios.g0_box(?n&$ff,?n&$ff,?n&$ff,?n&$ff)
      esc_key

' -------------------------------------------------------------------------- vec
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000                                                    'stern
      ios.g0_color(?n&%0011)
     'ios.g0_vec(x, y, vecscale, vecangle, vecdef_ptr)
      ios.g0_vec(?n&$ff,?n&$ff,?n&$ff,cnt>>14,@star - @grdat)
     'ios.g0_vec(100,100,200,0,0)
      esc_key

    ios.g0_clear
    repeat 2000                                                     'rombus
      ios.g0_color(?n&%0011)
      ios.g0_vec(?n&$ff,?n&$ff,?n&$ff,cnt>>14,@rombus - @grdat)
      esc_key

' -------------------------------------------------------------------------- vecarc
    ios.g0_clear
    ios.g0_width(0)
    repeat 2000
      ios.g0_color(?n&%0011)
     'vecarc(x, y, xr, yr, angle, vecscale, vecangle, vecdef_ptr)
      ios.g0_vecarc(XMAX/2,YMAX/2,70,70,cnt>>4,100,cnt>>14,@rombus - @grdat )
      esc_key

' -------------------------------------------------------------------------- pix
    ios.g0_clear
    ios.g0_colorwidth(2,1)
    ios.g0_pix(XMAX/2,YMAX/2,0,@oldbit1 - @grdat)
    waitcnt(cnt+clkfreq*2)
    ios.g0_colorwidth(2,0)
    repeat x from 0 to 7
      repeat y from 0 to 5
       'ios.g0_pix(x, y, pixrot, pixdef_ptr)
       ios.g0_pix(x*30+10,y*30+10,0,@oldbit1 - @grdat)
    esc_key
    waitcnt(cnt+clkfreq*2)


    ios.g0_dynamic
    n := 0
    repeat 400
      ios.g0_clear
      ios.g0_colorwidth(2,1)
      ios.g0_pixarc(XMAX/2,YMAX/2,50,50,cnt>>14,0,@oldbit1 - @grdat)
      'ios.g0_pix(XMAX/2,YMAX/2,0,@oldbit1 - @grdat)
      ios.g0_colorwidth(2,0)
      repeat x from 0 to 7
        repeat y from 0 to 5
         'ios.g0_pix(x, y, pixrot, pixdef_ptr)
         ios.g0_pix(x*30+10+n*y,y*30+10,0,@oldbit1 - @grdat)
      ios.g0_copy
      n++
      esc_key



    ios.g0_dynamic
    ios.g0_colorwidth(2,1)
    repeat 10
      ios.g0_clear
      repeat x from 0 to 7
        repeat y from 0 to 5
         'ios.g0_pix(x, y, pixrot, pixdef_ptr)
         ios.g0_pix(x*30+10,y*30+10,0,@monkey1 - @grdat)
      ios.g0_copy
      esc_key
      waitcnt(cnt+clkfreq/3)
      ios.g0_clear
      repeat x from 0 to 7
        repeat y from 0 to 5
         'ios.g0_pix(x, y, pixrot, pixdef_ptr)
         ios.g0_pix(x*30+10,y*30+10,0,@monkey2 - @grdat)
      ios.g0_copy
      esc_key
      waitcnt(cnt+clkfreq/3)

    repeat i from 0 to 31
      ios.g0_clear
      ios.g0_colorwidth(1,i)
     'ios.g0_pix(x, y, pixrot, pixdef_ptr)
      ios.g0_pix(60,70,0,@monkey1 - @grdat)
      ios.g0_copy
      esc_key
      waitcnt(cnt+clkfreq/7)

    ios.g0_static

' -------------------------------------------------------------------------- pixarc
    ios.g0_dynamic
    ios.g0_colorwidth(2,1)
    repeat 1000
      ios.g0_clear
      'ios.g0_pixarc(x, y, xr, yr, angle, pixrot, pixdef_ptr)
      ios.g0_pixarc(XMAX/2,YMAX/2,50,50,cnt>>14,0,@monkey1 - @grdat)
      ios.g0_copy
      ios.g0_clear
      'ios.g0_pixarc(x, y, xr, yr, angle, pixrot, pixdef_ptr)
      ios.g0_pixarc(XMAX/2,YMAX/2,50,50,cnt>>14,0,@monkey2 - @grdat)
      ios.g0_copy
      esc_key
    ios.g0_static

' -------------------------------------------------------------------------- text
    ios.g0_dynamic
   'ios.g0_textmode(x_scale, y_scale, spacing, justification)
    repeat 150
      ios.g0_clear
      ios.g0_colorwidth(2,1)
      repeat x from 0 to 7
        repeat y from 0 to 3
         'ios.g0_pix(x, y, pixrot, pixdef_ptr)
         ios.g0_pix(x*30+10,y*30+70,0,@monkey1 - @grdat)
      ios.g0_colorwidth(2,8)
      ios.g0_textmode(5,5,6,0)
      ios.g0_text(700 - (cnt>>20 & $fff),60,@string1 - @grdat)
      ios.g0_colorwidth(1,6)
      ios.g0_textmode(5,4,6,0)
      ios.g0_text(700 - (cnt>>24 & $fff),0,@string2 - @grdat)
      ios.g0_copy
      esc_key
    ios.g0_static

' -------------------------------------------------------------------------- textarc
    ios.g0_dynamic
    ios.g0_colorwidth(2,1)
    repeat 150
      ios.g0_clear
      ios.g0_colorwidth(2,1)
      repeat x from 0 to 7
        repeat y from 0 to 5
         'ios.g0_pix(x, y, pixrot, pixdef_ptr)
         ios.g0_pix(x*30+10,y*30+10,0,@monkey1 - @grdat)
      ios.g0_colorwidth(0,8)
      ios.g0_textmode(5,5,6,0)
      'ios.g0_textarc(x, y, xr, yr, angle, string_ptr)
      ios.g0_textarc(XMAX/4,YMAX/4,50,50,cnt>>14,@string1 - @grdat)
      ios.g0_copy
      esc_key
    ios.g0_static

' -------------------------------------------------------------------------- animation
    ademo1
    ademo2

' -------------------------------------------------------------------------- colorset
    ios.g0_clear
    screenset2

    'draw color samples
    ios.g0_width(29)'(29)

    'draw saturated samples
    ios.g0_color(3)
    repeat x from 0 to 15
      ios.g0_plot(x << 4 + 7, 183)

    'draw gradient samples
    repeat y from 2 to 6
      ios.g0_color(y & 1 | 2)
      repeat x from 0 to 15
        ios.g0_plot(x << 4 + 7, 183 - y << 4)

    'draw monochrome samples
    ios.g0_color(3)
    repeat x from 5 to 10
      ios.g0_plot(x << 4 + 7, 55)

    esc_key
    waitcnt(cnt + clkfreq * 2)
    screenset1
PUB esc_key

  if ios.g0_keystat
    ios.g0_reboot
    ios.stop
    repeat

PUB screenset1|i,tx,ty

  'tilescreen setzen
  repeat tx from 0 to x_tiles - 1
    repeat ty from 0 to y_tiles - 1
      screen[ty * x_tiles + tx] := disp_base >> 6 + ty + tx * y_tiles + ((ty & $3F) << 10)

  'farbtabelle füllen
  repeat i from 0 to 63
    colortab[i] := $00001010 * (i<<1+4) & $F + $0D060D02

  ios.g0_colortab(@colortab)
  ios.g0_screen(@screen)

PUB screenset2|x, y, i, c

  'init colors
  repeat i from $00 to $0F
    case i
      5..10 : c := $01000000 * (i - 5) + $02020507
      other  : c := $07020504
    colortab[i] := c
  repeat i from $10 to $1F
    colortab[i] := $10100000 * (i & $F) + $0B0A0507
  repeat i from $20 to $2F
    colortab[i] := $10100000 * (i & $F) + $0D0C0507
  repeat i from $30 to $3F
    colortab[i] := $10100000 * (i & $F) + $080E0507

  'init tile screen
  repeat x from 0 to x_tiles - 1
    repeat y from 0 to y_tiles - 1
      case y
        0, 2 : i := $30 + x
        3..4 : i := $20 + x
        5..6 : i := $10 + x
        8    : i := x
        other:  i := 0
      screen[x + y * x_tiles] := i << 10 + disp_base >> 6 + x * y_tiles + y

  ios.g0_colortab(@colortab)
  ios.g0_screen(@screen)


PUB ademo1 | x,y,i,j,k,kk,dx,dy,pp,pq,rr,numx,numchr

  x   := XMAX/2
  y   := YMAX/2
  dx  := 1
  dy  := 1
  k   := 0

  ios.g0_dynamic

  repeat 500

    'clear bitmap
    ios.g0_clear

    'draw spinning triangles
    ios.g0_colorwidth(1,0)
    repeat i from 1 to 16
      ios.g0_vec(XMAX/2 + k & $FF, YMAX/2, s_obj-i*60, k << 6 + i << 8, @triangle - @grdat)

    'draw expanding pixel halo
    ios.g0_colorwidth(1,k)
    ios.g0_arc(XMAX/2, YMAX/2,80,30,-k<<5,$2000/9,10,0)

    'draw boing-star
    ios.g0_colorwidth(1, 1)
    repeat j from 0 to 5
      ios.g0_vec(x+j*2, y+j*5, s_obj-j*40, cnt>>rotvar,@star - @grdat)

      'kollisionsabfrage
      if (x + dx - r_obj) < 0
        dx := dx * -1
      else
        if (x + dx + r_obj + 5) > XMAX
          dx := dx * -1
      if (y + dy - r_obj) < 0
        dy := dy * -1
      else
        if (y + dy + r_obj + 5) > YMAX
          dy := dy * -1

      x   += dx
      y   += dy


    'draw spinning stars and revolving crosshairs and dogs
    ios.g0_colorwidth(2,0)
    repeat i from 0 to 7
      ios.g0_vecarc(40,50,30,30,-(i<<10+k<<6),$40,-(k<<7),@star - @grdat)
      ios.g0_pixarc(190,140,30,30,i<<10+k<<6,0,@monkey1 - @grdat)
      ios.g0_pixarc(190,140,20,20,-(i<<10+k<<6),0,@monkey1 - @grdat)

    'draw text
    ios.g0_textmode(5,5,6,0)
    ios.g0_colorwidth(1,8)
    ios.g0_text(5,120,@string1  - @grdat)

    'draw text
    'ios.g0_colorwidth(2,0)
    'ios.g0_textmode(5,5,6,0)
    'ios.g0_text(150,5,@string1  - @grdat)

    'draw counter
    ios.g0_colorwidth(2,16-k&$f)
    ios.g0_textmode(3,3,6,0)
    ios.g0_printdec(160,10,k,4,@strstart,@strstart - @grdat)

    'copy bitmap to display
    ios.g0_copy

    'increment counter that makes everything change
    k++
    esc_key

  ios.g0_static

PUB ademo2 | i,k,x,y,dx,dy,rad

  x     := XMAX/2
  y     := YMAX/2
  dx    := 6
  dy    := 6
  rad   := 8
  k     := 0

  ios.g0_dynamic

  repeat 500

    'clear bitmap
    ios.g0_clear

    'draw spinning triangles
    ios.g0_colorwidth(1,0)
    repeat i from 1 to 8
      ios.g0_vec(k       & $FF, 32+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k +  64 & $FF, 32+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 128 & $FF, 32+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 192 & $FF, 32+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
    repeat i from 1 to 8
      ios.g0_vec(k +  32 & $FF, 96+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k +  96 & $FF, 96+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 160 & $FF, 96+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 224 & $FF, 96+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
    repeat i from 1 to 8
      ios.g0_vec(k       & $FF,160+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k +  64 & $FF,160+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 128 & $FF,160+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)
      ios.g0_vec(k + 192 & $FF,160+k, s_obj-i*60, k << 6 + i << 8, @star - @grdat)

    ios.g0_colorwidth(2,15)
    ios.g0_plot(x,y)

    'kollisionsabfrage
    if (x + dx - rad) < 0
      dx := dx * -1
      ios.sfx_fire($f1,0)
    else
      if (x + dx + rad + 5) > XMAX
        dx := dx * -1
        ios.sfx_fire($f1,0)
    if (y + dy - rad) < 0
      dy := dy * -1
      ios.sfx_fire($f1,0)
    else
      if (y + dy + rad + 5) > YMAX
        dy := dy * -1
        ios.sfx_fire($f1,0)

    x   += dx
    y   += dy

    'copy bitmap to display
    ios.g0_copy

    'increment counter that makes everything change
    k++
    esc_key

  ios.g0_static


DAT 'heap-daten

grdat

strstart                        'stringpuffer für zahlenausgabe
byte "00000000",0               '8 digits
byte 0                          'wichtig: auf wortgrenze auffüllen!
strend

star
byte word  $4000+$2000/12*0        'star
byte word  50
byte word  $8000+$2000/12*1
byte word  20
byte word  $8000+$2000/12*2
byte word  50
byte word  $8000+$2000/12*3
byte word  20
byte word  $8000+$2000/12*4
byte word  50
byte word  $8000+$2000/12*5
byte word  20
byte word  $8000+$2000/12*6
byte word  50
byte word  $8000+$2000/12*7
byte word  20
byte word  $8000+$2000/12*8
byte word  50
byte word  $8000+$2000/12*9
byte word  20
byte word  $8000+$2000/12*10
byte word  50
byte word  $8000+$2000/12*11
byte word  20
byte word  $8000+$2000/12*0
byte word  50
byte word  0

triangle
byte word    $4000+$2000/3*0         'triangle
byte word    50
byte word    $8000+$2000/3*1+1
byte word    50
byte word    $8000+$2000/3*2-1
byte word    50
byte word    $8000+$2000/3*0
byte word    50
byte word    0

rombus
byte word    $4000+$2000/4*0         'rombus
byte word    50
byte word    $8000+$2000/4*1
byte word    30
byte word    $8000+$2000/4*2
byte word    50
byte word    $8000+$2000/4*3
byte word    30
byte word    $8000+$2000/4*0
byte word    50
byte word    0

oldbit1
byte     3,24,12,12
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%12121212
byte word %%12121212
byte word %%12222212
byte word %%12121212
byte word %%12121212
byte word %%12222212
byte word %%12121212
byte word %%12121212
byte word %%12222212
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%00110000
byte word %%00000111
byte word %%11110000
byte word %%00110000
byte word %%00111001
byte word %%12330000
byte word %%00110001
byte word %%11113300
byte word %%11120000
byte word %%00100011
byte word %%11111230
byte word %%11110000
byte word %%00100011
byte word %%11111120
byte word %%00010000
byte word %%00100011
byte word %%11111110
byte word %%13000000
byte word %%00100011
byte word %%11001110
byte word %%11013233
byte word %%00100011
byte word %%00110110
byte word %%11011111
byte word %%00100011
byte word %%00230110
byte word %%11000000
byte word %%00100011
byte word %%00110110
byte word %%00010000
byte word %%00100011
byte word %%10000110
byte word %%11110000
byte word %%00110001
byte word %%11111100
byte word %%11110000
byte word %%00110000
byte word %%00111001
byte word %%11110000
byte word %%00110000
byte word %%00000011
byte word %%11110000
byte word %%00000000
byte word %%00000000
byte word %%00000000
byte word %%12121212
byte word %%12121212
byte word %%22121212
byte word %%12121212
byte word %%12121212
byte word %%22121212
byte word %%12121212
byte word %%12121212
byte word %%22121212

monkey1
'byte    2,11,3,3
'word    %%00011111,%%00000000
'word    %%00321112,%%23000000
'word    %%00322112,%%21110000
'word    %%02222211,%%11111000
'word    %%03222111,%%11111100
'word    %%00000111,%%11111110
'word    %%00000111,%%11111110
'word    %%00000111,%%11111110
'word    %%00000111,%%11111110
'word    %%00002120,%%01111200
'word    %%00001220,%%22222100

byte    2,11,3,3
byte word    %%00011111
byte word    %%00000000
byte word    %%00321112
byte word    %%23000000
byte word    %%00322112
byte word    %%21110000
byte word    %%02222211
byte word    %%11111000
byte word    %%03222111
byte word    %%11111100
byte word    %%00000111
byte word    %%11111110
byte word    %%00000111
byte word    %%11111110
byte word    %%00000111
byte word    %%11111110
byte word    %%00000111
byte word    %%11111110
byte word    %%00002120
byte word    %%01111200
byte word    %%00001220
byte word    %%22222100

monkey2
'byte    2,11,3,3
'word    %%00011111,%%00000000
'word    %%00321112,%%23000000
'word    %%00322112,%%21110000
'word    %%02222211,%%11111000
'word    %%03222111,%%11111100
'word    %%00000111,%%11111110
'word    %%00000111,%%11111110
'word    %%00000111,%%11111110
'word    %%00001110,%%11111110
'word    %%00021200,%%01111200
'word    %%00122000,%%00222220

byte    2,11,3,3
byte word    %%00011111
byte word    %%00000000
byte word    %%00321112
byte word    %%23000000
byte word    %%00322112
byte word    %%21110000
byte word    %%02222211
byte word    %%11111000
byte word    %%03222111
byte word    %%11111100
byte word    %%00000111
byte word    %%11111110
byte word    %%00000111
byte word    %%11111110
byte word    %%00000111
byte word    %%11111110
byte word    %%00001110
byte word    %%11111110
byte word    %%00021200
byte word    %%01111200
byte word    %%00122000
byte word    %%00222220

string1
byte "HIVE",0

string2
byte "abcdefghijklmnopqrstuvwxyz 0123456789",0

string3
byte "heap-len : ",0

string4
byte "heap-use : ",0

grdatend



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
