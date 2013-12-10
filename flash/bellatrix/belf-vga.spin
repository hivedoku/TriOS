{{ VGA-Spezifika für belflash

}}

CON

COLS         = 64
ROWS         = 48
TLINES_PER_ROW = 2
DEFAULT_Y0   = TLINES_PER_ROW  ' 1 Zeile Platz lassen für HIVE-Logo
COLORANZ     = 8
SPACETILE    = $8000 + $20 << 6

VGA_BASPORT  = 8                                       'vga startport

OBJ

  vga        : "bel-vga"

VAR

  long  vid_arr  ' Kopie des Pointers auf den "Bildwiederholspeicher"
  long  ccolor   ' aktuelle Anzeigefarbe

PUB start(array)
  vid_arr := array
  vga.start(VGA_BASPORT, array, @vgacolors, 0, 0, 0)   'vga-treiber starten

PUB set_dscr(scr_ptr)
    vga.set_scrpointer(scr_ptr)     'screenpointer für den displaytreiber neu setzen

PUB get_color(cnr)
  return long[@vgacolors][cnr]

PUB set_color(cnr, colr)
  long[@vgacolors][cnr] := colr

PUB set_ccolor(colr)
  ccolor := colr

PUB get_ccolor
  return ccolor

PUB schar(offset, c) | i
  i := $8000 + (c & $FE) << 6 + (ccolor << 1 + c & 1)
  word[vid_arr][offset] := i                            'oberes tile setzen
  word[vid_arr][offset + cols] := i | $40               'unteres tile setzen


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
{
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
}

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

'set 5 - grün auf schwarz
'          v  h  v  h        ' v=Vordergrund, h=Hintergrund
'   long $ 3C 04 3C 04       'Muster
'          v  v  h  h
'   long $ 3C 3C 04 04       'Muster

  long $30003000       'color 0: grün auf schwarz
  long $30300000

  long $C000C000       'color 1: rot auf schwarz
  long $C0C00000

  long $0C000C00       'color 2: blau auf schwarz
  long $0C0C0000

  long $E000E000       'color 3: gelb auf schwarz
  long $E0E00000

  long $D000D000       'color 4: orange auf schwarz
  long $D0D00000

  long $3C003C00       'color 5: cyan auf schwarz
  long $3C3C0000

  long $FC00FC00       'color 6: weiß auf schwarz
  long $FCFC0000

  long $C800C800       'color 7: magenta auf schwarz
  long $C8C80000


  long $00300030       'color 8: schwarz auf grün
  long $00003030

  long $00C000C0       'color 9: schwarz auf rot
  long $0000C0C0

  long $000C000C       'color 10: schwarz auf blau
  long $00000C0C

  long $00E000E0       'color 11: schwarz auf gelb
  long $0000E0E0

  long $00D000D0       'color 12: schwarz auf orange
  long $0000D0D0

  long $003C003C       'color 13: schwarz aufcyan
  long $00003C3C

  long $00FC00FC       'color 14: schwarz auf weiß
  long $0000FCFC

  long $00C800C8       'color 15: schwarz auf magenta
  long $0000C8C8


