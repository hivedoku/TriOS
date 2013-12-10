{{ TV-Spezifika für belflash

}}

CON

COLS         = 40
ROWS         = 13
TLINES_PER_ROW = 1
DEFAULT_Y0   = 0  ' bei 13 Zeilen ist kein Platz für eine dauerhafte Überschrift
SPACETILE    = $220

TV_BASPORT = 23

OBJ

  tv         : "bel-tv"

CON

TV_COUNT = 14  ' Anzahl der long-Variablen ab tv_status

VAR

  long  colors[8 * 2]

  long  tv_status     '0/1/2 = off/invisible/visible              read-only   (14 longs)
  long  tv_enable     '0/non-0 = off/on                           write-only
  long  tv_pins       '%pppmmmm = pin group, pin group mode       write-only
  long  tv_mode       '%tccip = tile,chroma,interlace,ntsc/pal    write-only
  long  tv_screen     'pointer to screen (words)                  write-only
  long  tv_colors     'pointer to colors (longs)                  write-only
  long  tv_ht         'horizontal tiles                           write-only
  long  tv_vt         'vertical tiles                             write-only
  long  tv_hx         'horizontal tile expansion                  write-only
  long  tv_vx         'vertical tile expansion                    write-only
  long  tv_ho         'horizontal offset                          write-only
  long  tv_vo         'vertical offset                            write-only
  long  tv_broadcast  'broadcast frequency (Hz)                   write-only
  long  tv_auralcog   'aural fm cog                               write-only

  long  vid_arr  ' Kopie des Pointers auf den "Bildwiederholspeicher"
  long  ccolor   ' aktuelle Anzeigefarbe

PUB start(array)
  vid_arr := array
  start_tv(TV_BASPORT, array)

PUB start_tv(basepin, array) : okay

'' Start terminal - starts a cog
'' returns false if no cog available

  setcolors(@palette)
  'out(0)

  longmove(@tv_status, @tv_params, TV_COUNT)
  tv_pins := (basepin & $38) << 1 | (basepin & 4 == 4) & %0101
  tv_screen := array
  tv_colors := @colors

  okay := tv.start(@tv_status)

PUB setcolors(colorptr) | i, fore, back

'' Override default color palette
'' colorptr must point to a list of up to 8 colors
'' arranged as follows:
''
''               fore   back
''               ------------
'' palette  byte color, color     'color 0
''          byte color, color     'color 1
''          byte color, color     'color 2
''          ...

  repeat i from 0 to 7
    fore := byte[colorptr][i << 1]
    back := byte[colorptr][i << 1 + 1]
    colors[i << 1]     := fore << 24 + back << 16 + fore << 8 + back
    colors[i << 1 + 1] := fore << 24 + fore << 16 + back << 8 + back


PUB set_dscr(scr_ptr)
  tv_screen := scr_ptr

PUB get_color(cnr)
  return long[colors][cnr & $F]

PUB set_color(cnr, colr)
  long[colors][cnr & $F] := colr

PUB set_ccolor(colr)
  ccolor := colr

PUB get_ccolor
  return ccolor

PUB schar(offset, c)
  word[vid_arr][offset] := (ccolor << 1 + c & 1) << 10 + $200 + c & $FE


DAT

tv_params               long    0               'status
                        long    1               'enable
                        long    0               'pins
                        long    %10010          'mode
                        long    0               'screen
                        long    0               'colors
                        long    cols            'hc
                        long    rows            'vc
                        long    4               'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog


                        '       fore   back
                        '       color  color
palette                 byte    $07,   $0A    '0    white / dark blue
                        byte    $07,   $BB    '1    white / red
                        byte    $9E,   $9B    '2   yellow / brown
                        byte    $04,   $07    '3     grey / white
                        byte    $3D,   $3B    '4     cyan / dark cyan
                        byte    $6B,   $6E    '5    green / gray-green
                        byte    $BB,   $CE    '6      red / pink
                        byte    $3C,   $0A    '7     cyan / blue


