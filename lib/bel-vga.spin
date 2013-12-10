{{
┌────────────────────────────────────────┬────────────────┬────────────────────────┬──────────────────┐
│ VGA 1024x768 Tile Driver v0.9          │ by Chip Gracey │ (C)2006 Parallax, Inc. │ 11 November 2006 │
├────────────────────────────────────────┴────────────────┴────────────────────────┴──────────────────┤
│                                                                                                     │
│ This object generates a 1024x768 VGA display from a 64x48 array of 16x16-pixel 4-color tiles.       │
│ It requires two cogs (or three with optional cursor enabled) and at least 80 MHz.                   │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
                        
}}

{{

01-02-2011-dr235      - erweiterung des treibers, um mit einem parameter den anfangszeiger
                        des bildwiederholspeichers dynamisch zu ändern; wichtig zur
                        verwaltung von mehreren screens

}}

CON

' 1024 x 768 @ 60Hz settings

  hp = 1024                     'horizontal pixels
  vp = 768                      'vertical pixels
  hf = 16                       'horizontal front porch pixels
  hs = 96                       'horizontal sync pixels
  hb = 176                      'horizontal back porch pixels
  vf = 1                        'vertical front porch lines
  vs = 3                        'vertical sync lines
  vb = 28                       'vertical back porch lines
  pr = 60                       'pixel rate in MHz at 80MHz system clock (5MHz granularity)

  ht = hp + hf + hs + hb        'total scan line pixels

' Tile array

  xtiles = hp / 16
  ytiles = vp / 16

VAR

  long cog[3]
  
  long dira_                    '9 contiguous longs
  long dirb_
  long vcfg_
  long cnt_
  long array_ptr_
  long color_ptr_
  long cursor_ptr_
  long sync_ptr_
  long mode_
  long scrind_                  'dr235: screenindex
  
DAT
'' Start driver - starts two or three cogs
'' returns false if cogs not available
''
''     base_pin = First of eight VGA pins, must be a multiple of eight (0, 8, 16, 24, etc):
''
''                    240Ω               240Ω                 240Ω                240Ω
''                +7 ───┳─ Red   +5 ───┳─ Green   +3 ───┳─ Blue   +1 ── H
''                    470Ω │             470Ω │               470Ω │              240Ω
''                +6 ───┘         +4 ───┘           +2 ───┘          +0 ── V
''
''    array_ptr = Pointer to 3,072 long-aligned words, organized as 64 across by 48 down,
''                which will serve as the tile array. Each word specifies a tile bitmap and
''                a color palette for its tile area. The top 10 bits of each word form the
''                base address of a 16-long tile bitmap, while the lower 6 bits select a
''                color palette for the bitmap. For example, $B2E5 would specify the tile
''                bitmap spanning $B2C0..$B2FF and color palette $25.
''
''    color_ptr = Pointer to 64 longs which will define the 64 color palettes. The RGB data
''                in each long is arranged as %%RGBx_RGBx_RGBx_RGBx with the sub-bytes 3..0
''                providing the color data for pixel values %11..%00, respectively:
''
''                %%3330_0110_0020_3300: %11=white, %10=dark cyan, %01=blue, %00=gold
''
''   cursor_ptr = Pointer to 4 longs which will control the cursor, or 0 to disable the
''                cursor. If a pointer is given, an extra cog will be started to generate
''                the cursor overlay. Here are the 4 longs that control the cursor:
''
''                cursor_x      - X position of cursor: ..0..1023.. (left to right)
''                cursor_y      - Y position of cursor: ..0..767.. (bottom to top)
''
''                cursor_color  - Cursor color to be OR'd to background color as %%RGBx:
''                                %%3330=white, %%2220 or %%1110=translucent, %%0000=off
''
''                cursor_shape  - 0 for arrow, 1 for crosshair, or pointer to a cursor
''                                definition. A cursor definition consists of 32 longs
''                                containing a 32x32 pixel cursor image, followed by two
''                                bytes which define the X and Y center-pixel offsets
''                                within the image.
''
''     sync_ptr = Pointer to a long which will be set to -1 after each refresh, or 0 to
''                disable this function. This is useful in advanced applications where
''                awareness of display timing is important.
''
''         mode = 0 for normal 16x16 pixel tiles or 1 for taller 16x32 pixel tiles. Mode 1
''                is useful for displaying the internal font while requiring half the array
''                memory; however, the 3-D bevel characters will not be usable because of
''                the larger vertical tile granularity of this mode.

PUB start(base_pin, array_ptr, color_ptr, cursor_ptr, sync_ptr, mode) : okay | i, j

  'If driver is already running, stop it
  stop

  'Ready i/o settings
  i := $FF << (base_pin & %011000)
  j := base_pin & %100000 == 0
  dira_ := i & j
  dirb_ := i & !j
  vcfg_ := $300000FF + (base_pin & %111000) << 6

  'Ready cnt value to sync cogs by
  cnt_ := cnt + $100000

  'Ready pointers and mode
  longmove(@array_ptr_, @array_ptr, 5)
  scrind_ := array_ptr_

  'Launch cogs, abort if error
  repeat i from 0 to 2
    if i == 2                   'cursor cog?
      ifnot cursor_ptr          'cursor enabled?
        quit                    'if not, quit loop
      waitcnt($2000 + cnt)      'cursor cog, allow prior cog to launch
      vcfg_ ^= $10000000        'set two-color mode
      array_ptr_~               'flag cursor function
    ifnot cog[i] := cognew(@entry, @dira_ + i << 15) + 1
      stop
      return {false}

  'Successful
  return true


PUB stop | i

'' Stop driver - frees cogs

  'If already running, stop any VGA cogs
  repeat i from 0 to 2
    if cog[i]
      cogstop(cog[i]~ - 1)              

PUB set_scrpointer(array_ptr)
' zeiger auf screenanfang wird neu gesetzt um mehrere screens verwalten zu können

  scrind_ := array_ptr

DAT

' ┌─────────────────────────────┐
' │  Initialization - all cogs  │
' └─────────────────────────────┘

                        org

' Move field loop into position

entry                   mov     field,field_code                                            
                        add     entry,d0s0_             
                        djnz    regs,#entry

' Acquire settings

                        mov     scrind,par              'dr235: adresse screenindex speichern
                        cmpsub  scrind,bit15            'dr235: bit15 ausblenden
                        add     scrind,#36              'dr235: adresse in scrind speichern


                        mov     regs,par                '00 dira_        ─  dira
                        cmpsub  regs,bit15      wc      '04 dirb_        ─  dirb
:next                   movd    :read,sprs              '08 vcfg_        ─  vcfg
                        or      :read,d8_d4             '12 cnt_         ─  cnt
                        shr     sprs,#4                 '16 array_ptr_   ─  ctrb
:read                   rdlong  dira,regs               '20 color_ptr_   ─  frqb
                        add     regs,#4                 '24 cursor_ptr_  ─  vscl
                        tjnz    sprs,#:next             '28 sync_ptr_    ─  phsb
                                                        '32 mode_
                                                        '36 scrind_      --> scrind

                        sumc    vf_lines,#2             'alter scan line settings by cog
                        sumnc   vb_lines,#2
                        sumnc   tile_line,#2 * 4

                        rdlong  regs,regs       wz      'if mode not 0, set tile size to 16 x 32 pixels
        if_nz           movs    tile_bytes,#32 * 4
        if_nz           shr     array_bytes,#1

                        mov     regs,vscl               'save cursor pointer
                                                                                
' Synchronize all cogs' video circuits so that waitvid's will be pixel-locked
                                                                                              
                        movi    frqa,#(pr / 5) << 2     'set pixel rate (VCO runs at 2x)                     
                        mov     vscl,#1                 'set video shifter to reload on every pixel
                        waitcnt cnt,d8_d4               'wait for sync count, add ~3ms - cogs locked!
                        movi    ctra,#%00001_110        'enable PLLs now - NCOs locked!
                        waitcnt cnt,#0                  'wait ~3ms for PLLs to stabilize - PLLs locked!
                        mov     vscl,#100               'subsequent WAITVIDs will now be pixel-locked!

' Determine if this cog is to perform one of two field functions or the cursor function
                        
                        tjnz    ctrb,#vsync             'if array ptr, jump to field function
                                                        'else, cursor function follows

' ┌─────────────────────────┐
' │  Cursor Loop - one cog  │
' └─────────────────────────┘

' Do vertical sync lines minus three

cursor                  mov     par,#vf + vs + vb - 6

:loop                   mov     vscl,vscl_line
:vsync                  waitvid ccolor,#0
                        djnz    par,#:vsync

' Do three lines minus horizontal back porch pixels to buy a big block of time

                        mov     vscl,vscl_three_lines_mhb
                        waitvid ccolor,#0   

' Get cursor data

                        rdlong  cx,regs                 'get cursor x
                        add     regs,#4
                        rdlong  cy,regs                 'get cursor y
                        add     regs,#4
                        rdlong  ccolor,regs             'get cursor color
                        add     regs,#4
                        rdlong  cshape,regs             'get cursor shape
                        sub     regs,#3 * 4

                        and     ccolor,#$FC             'trim and justify cursor color
                        shl     ccolor,#8

' Build cursor pixels

                        mov     par,#32                 'ready for 32 cursor segments
                        movd    :pix,#cpix
                        mov     cnt,cshape
                        
:pixloop                cmp     cnt,#1          wc, wz  'arrow, crosshair, or custom cursor?
        if_a            jmp     #:custom
        if_e            jmp     #:crosshair
        
                        cmp     par,#32         wz      'arrow
                        cmp     par,#32-21      wc      
        if_z            mov     cseg,h80000000
        if_nz_and_nc    sar     cseg,#1
        if_nz_and_c     shl     cseg,#2
                        mov     coff,#0
                        jmp     #:pix
                        
:crosshair              cmp     par,#32-15      wz      'crosshair
        if_ne           mov     cseg,h00010000
        if_e            neg     cseg,#2
                        cmp     par,#1          wz
        if_e            mov     cseg,#0
                        mov     coff,h00000F0F
                        jmp     #:pix
                        
:custom                 rdlong  cseg,cshape             'custom
                        add     cshape,#4
                        rdlong  coff,cshape
                        
:pix                    mov     cpix,cseg               'save segment into pixels
                        add     :pix,d0
                        
                        djnz    par,#:pixloop           'another segment?

' Compute cursor position

                        mov     cseg,coff               'apply cursor center-pixel offsets
                        and     cseg,#$FF
                        sub     cx,cseg
                        shr     coff,#8
                        and     coff,#$FF
                        add     cy,coff

                        cmps    cx,neg31        wc      'if x out of range, hide cursor via y
        if_nc           cmps    pixels_m1,cx    wc
        if_c            neg     cy,#1

                        mov     cshr,#0                 'adjust for left-edge clipping               
                        cmps    cx,#0           wc
        if_c            neg     cshr,cx
        if_c            mov     cx,#0
        
                        mov     cshl,#0                 'adjust for right-edge clipping
                        cmpsub  cx,pixels_m32   wc
        if_c            mov     cshl,cx
        if_c            mov     cx,pixels_m32

                        add     cx,#hb                  'bias x and y for display
                        sub     cy,lines_m1

' Do visible lines with cursor

                        mov     par,lines               'ready for visible scan lines

:line                   andn    cy,#$1F         wz, nr  'check if scan line in cursor range

        if_z            movs    :seg,cy                 'if in range, get cursor pixels
        if_z            add     :seg,#cpix
        if_nz           mov     cseg,#0                 'if out of range, use blank pixels
:seg    if_z            mov     cseg,cpix
        if_z            rev     cseg,#0                 'reverse pixels so they map sensibly
        if_z            shr     cseg,cshr               'perform any edge clipping on pixels
        if_z            shl     cseg,cshl

                        mov     vscl,cx                 'do left blank pixels (hb+cx)
                        waitvid ccolor,#0
                        
                        mov     vscl,vscl_cursor        'do cursor pixels (32)
                        waitvid ccolor,cseg
                        
                        mov     vscl,vscl_line_m32      'do right blank pixels (hp+hf+hs-32-cx)
                        sub     vscl,cx
                        waitvid ccolor,#0

                        add     cy,#1                   'another scan line?
                        djnz    par,#:line

' Do horizontal back porch pixels and loop

                        mov     vscl,#hb
                        waitvid ccolor,#0

                        mov     par,#vf + vs + vb - 3   'ready to do vertical sync lines
                        jmp     #:loop

' Cursor data

vscl_line               long    ht                      'total pixels per scan line
vscl_three_lines_mhb    long    ht * 3 - hb             'total pixels per three scan lines minus hb
vscl_line_m32           long    ht - 32                 'total pixels per scan line minus 32
vscl_cursor             long    1 << 12 + 32            '32 pixels per cursor with 1 clock per pixel
lines                   long    vp                      'visible scan lines
lines_m1                long    vp - 1                  'visible scan lines minus 1
pixels_m1               long    hp - 1                  'visible pixels minus 1
pixels_m32              long    hp - 32                 'visible pixels minus 32
neg31                   long    -31
                    
h80000000               long    $80000000               'arrow/crosshair cursor data
h00010000               long    $00010000
h00000F0F               long    $00000F0F

' Initialization data

d0s0_                   long    1 << 9 + 1              'd and s field increments
regs                    long    $1F0 - field            'number of registers in field loop space
sprs                    long    $DFB91E76               'phsb/vscl/frqb/ctrb/cnt/vcfg/dirb/dira nibbles
bit15                   long    $8000                   'bit15 mask used to differentiate cogs in par
d8_d4                   long    $0003E000               'bit8..bit4 mask for d field

field_code                                              'field loop code begins at this offset

' Undefined cursor data

cx                      res     1
cy                      res     1
ccolor                  res     1
cshape                  res     1
coff                    res     1
cseg                    res     1
cshr                    res     1
cshl                    res     1
cpix                    res     32


' ┌─────────────────────────┐
' │  Field Loop - two cogs  │
' └─────────────────────────┘

                        org

' Allocate buffers

palettes                res     64                      'palettes of colors
colors                  res     xtiles                  'colors for tile row
pixels0                 res     xtiles                  'pixels for tile row line +0
pixels1                 res     xtiles                  'pixels for tile row line +1
pixels2                 res     xtiles                  'pixels for tile row line +2
pixels3                 res     xtiles                  'pixels for tile row line +3

' Each cog alternately builds and displays four scan lines
                          
field                   mov     cnt,#ytiles * 4 / 2     'ready number of four-scan-line builds/displays
                        
' Build four scan lines

build_4y                movd    col0,#colors+0          'reset pointers for scan line buffers
                        movd    col1,#colors+1
                        movd    pix0,#pixels0+0        
                        movd    pix1,#pixels1+0        
                        movd    pix2,#pixels2+0
                        movd    pix3,#pixels3+0
                        movd    pix4,#pixels0+1
                        movd    pix5,#pixels1+1      
                        movd    pix6,#pixels2+1
                        movd    pix7,#pixels3+1

                        mov     ina,#2                  'four scan lines require two waitvid's

build_32x               mov     vscl,vscl_two_lines     'output lows for two scan lines so other cog
:zero                   waitvid :zero,#0                '..can display while this cog builds (twice)

                        mov     inb,#xtiles / 2 / 2     'build four scan lines for half a row

build_2x                rdlong  vscl,ctrb               'get pair of words from the tile array

                        movs    col0,vscl               'get color bits from even tile          
                        andn    col0,#$1C0                                       

                        andn    vscl,#$3F               'strip color bits and add tile line offset
                        add     vscl,tile_line                                   

col0                    mov     colors+0,palettes       'get even tile color
                        add     col0,d1

pix0                    rdlong  pixels0+0,vscl          'get line +0 even tile pixels
                        add     pix0,d1                                  
                        add     vscl,#4                                  
                                                                         
pix1                    rdlong  pixels1+0,vscl          'get line +1 even tile pixels            
                        add     pix1,d1                                  
                        add     vscl,#4                                  
                                                                         
pix2                    rdlong  pixels2+0,vscl          'get line +2 even tile pixels            
                        add     pix2,d1                                  
                        add     vscl,#4                                  
                                                                         
pix3                    rdlong  pixels3+0,vscl          'get line +3 even tile pixels            
                        add     pix3,d1

                        add     ctrb,#2 * 2             'point to next pair of tile words
                        shr     vscl,#16                'shift odd tile word into position

                        movs    col1,vscl               'get color bits from odd tile
                        andn    col1,#$1C0

                        andn    vscl,#$3F               'strip color bits and add tile line offset
                        add     vscl,tile_line         

col1                    mov     colors+1,palettes       'get odd tile color                
                        add     col1,d1                                                    
                                                                                           
pix4                    rdlong  pixels0+1,vscl          'get line +0 odd tile pixels       
                        add     pix4,d1                                                    
                        add     vscl,#4                                                    
                                                                                           
pix5                    rdlong  pixels1+1,vscl          'get line +1 odd tile pixels       
                        add     pix5,d1                                                    
                        add     vscl,#4                                                    
                                                                                           
pix6                    rdlong  pixels2+1,vscl          'get line +2 odd tile pixels       
                        add     pix6,d1                                                    
                        add     vscl,#4                                                    
                                                                                           
pix7                    rdlong  pixels3+1,vscl          'get line +3 odd tile pixels       
                        add     pix7,d1
                        djnz    inb,#build_2x           'loop for next tile pair (48 inst/loop)

                        djnz    ina,#build_32x          'if first half done, loop for 2nd waitvid
                        
                        sub     ctrb,#xtiles * 2        'back up to start of same row

' Display four scan lines

                        mov     inb,#4                  'ready for four scan lines
                        movs    :waitvid,#pixels0       'reset waitvid pixel pointer

:line                   mov     ina,#xtiles             'ready for tiles
                        movd    :waitvid,#colors        'reset waitvid color pointer
                        mov     vscl,vscl_tile          'set pixel rate for tiles

:tile                   cmp     ina,#1          wz      'check if last tile
                        add     :waitvid,d0s0           'advance pointers (waitvid already read)
:waitvid                waitvid colors,pixels0          'do tile slice
        if_nz           djnz    ina,#:tile              'strange loop allows hsync timing and ina=1

                        call    #hsync                  'do horizontal sync (ina=1)
                        
                        djnz    inb,#:line              'another scan line?

' Another four scan lines?
                             
                        add     tile_line,#8 * 4        'advance eight scan lines within tile row
tile_bytes              cmpsub  tile_line,#16 * 4 wc    'tile row done? (# doubled for mode 1)
        if_c            add     ctrb,#xtiles * 2        'if done, advance array pointer to next row

                        djnz    cnt,#build_4y           'another four scan lines?

' hier kann der index eingearbeitet werden
                        'sub     ctrb,array_bytes        'display done, reset array pointer to top row

                        rdlong  ctrb,scrind              'dr235: stelle pointer wieder auf screenanfang



' Visible section done, handle sync indicator

                        cmp     cnt,phsb        wz      'sync enabled? (cnt=0)
        if_nz           wrlong  neg1,phsb               'if so, write -1 to sync indicator

' Do vertical sync lines and loop
                        
vf_lines                mov     ina,#vf + 2             'do vertical front porch lines (adjusted ±2)
                        call    #blank

vsync                   mov     ina,#vs                 'do vertical sync lines
                        call    #blank_vsync

vb_lines                mov     ina,#vb - 2             'do vertical back porch lines (adjusted ±2)
                        movs    blank_vsync_ret,#field  '(loop to field, blank_vsync follows)

' Subroutine - do blank lines

blank_vsync             xor     hv_sync,#$0101          'flip vertical sync bits

blank                   mov     vscl,vscl_blank         'do horizontal blank pixels
                        waitvid hv_sync,#0

hsync                   mov     vscl,#hf                'do horizontal front porch pixels
                        waitvid hv_sync,#0

                        mov     vscl,#hs                'do horizontal sync pixels
                        waitvid hv_sync,#1

                        rdlong  vscl,frqb               'update another palette
                        and     vscl,color_mask
:palette                mov     palettes,vscl
                        add     :palette,d0
                        add     frqb,#4
                        add     par,count_64    wc      
        if_c            movd    :palette,#palettes
        if_c            sub     frqb,#64 * 4

                        mov     vscl,#hb                'do horizontal back porch pixels
                        waitvid hv_sync,#0
                        
                        djnz    ina,#blank              'another blank line?
hsync_ret               
blank_ret
blank_vsync_ret         ret

' Data

d0s0                    long    1 << 9 + 1              'd and s field increments
d0                      long    1 << 9                  'd field increment
d1                      long    2 << 9                  'd field double increment

tile_line               long    2 * 4                   'tile line offset (adjusted ±2 * 4)
array_bytes             long    xtiles * ytiles * 2     'number of bytes in tile array

vscl_two_lines          long    ht * 2                  'total pixels per two scan lines
vscl_tile               long    1 << 12 + 16            '16 pixels per tile with 1 clock per pixel
vscl_blank              long    hp                      'visible pixels per scan line

hv_sync                 long    $0200                   '+/-H,-V states
count_64                long    $04000000               'addend that sets carry every 64th addition
color_mask              long    $FCFCFCFC               'mask to isolate R,G,B bits from H,V
neg1                    long    $FFFFFFFF               'negative 1 to be written to sync indicator
scrind                  long    0                       'dr235: adresse des screenindex




