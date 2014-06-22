{{      Bellatrix-Code
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Autor: Ingo Kripahle                                                                                 │
│ Copyright (c) 2012 Ingo Kripahle                                                                     │
│ See end of file for terms of use.                                                                    │
│ Die Nutzungsbedingungen befinden sich am Ende der Datei                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘

Informationen   : hive-project.de
Kontakt         : drohne235@googlemail.com
System          : mental
Name            :
Chip            : global
Typ             : Konstanten


}}

con     ' signaldefinitionen

'signaldefinitionen global

#0,     D0,D1,D2,D3,D4,D5,D6,D7                         'datenbus
#24,    HBEAT                                           'front-led
        BUSCLK                                          'bustakt
        BUS_WR                                          '/wr - schreibsignal
        BUS_HS '                                        '/hs - quittungssignal
        I2C_SCL
        I2C_SDA
        SER_TX
        SER_RX


'signaldefinitionen bellatrix

#8,     BEL_VGABASE                                     'vga-signale (8pin)
#16,    BEL_KEYBC,BEL_KEYBD                             'keyboard-signale
#18,    BEL_MOUSEC,BEL_MOUSED                           'maus-signale
#20,    BEL_VIDBASE                                     'video-signale(3pin)
#23,    BEL_SELECT                                      'belatrix-auswahlsignal


'signaldefinitionen administra

#8,     ADM_SOUNDL,ADM_SOUNDR                           'sound (stereo 2 pin)
#10,    ADM_SDD0,ADM_SDCLK,ADM_SDCMD,ADM_SDD3           'sd-cardreader (4 pin)
#23,    ADM_SELECT                                      'administra-auswahlsignal

'plexbus
adm_sda  = 19                                           'i2c-datenpin
adm_scl  = 20                                           'i2c-clockpin
adm_int1 = 21                                           'interrupt port 1&2
adm_int2 = 22                                           'interrupt port 3

con     ' administra-funktionen

ADM_OPT              = 0

'sdcard-funktionen
ADM_SD_MOUNT         = 1
ADM_SD_CHECKMOUNTED  = 2
ADM_SD_UNMOUNT       = 3
ADM_SD_OPEN          = 4
ADM_SD_CLOSE         = 5
ADM_SD_GETC          = 6
ADM_SD_PUTC          = 7
ADM_SD_EOF           = 8
ADM_SD_GETBLK        = 9

ADM_SCR_FILL    = 11                                    'screenpuffer mit zeichen füllen
ADM_SCR_READ    = 12                                    'screen in den puffer laden
ADM_SCR_WRITE   = 13                                    'screen auf disk schreiben
ADM_SCR_GETNR   = 14                                    'nummer des aktuellen screens abfragen
ADM_SCR_SETPOS  = 15                                    'zeiger auf position im puffer setzen
ADM_SCR_GETPOS  = 16                                    'aktuelle position im puffer abfragen
ADM_SCR_GETC    = 17                                    'zeichen wird aus dem puffer gelesen
ADM_SCR_PUTC    = 18                                    'zeichen wird in den puffer geschrieben
ADM_SCR_ERR     = 19                                    'fehlerstatus abfragen
ADM_SCR_MAXSCR  = 20                                    'anzahl screens des containers abfragen
ADM_SCR_EOS     = 21                                    'end of screen abfragen
ADM_SCR_CALL    = 22                                    'subscreen aufrufen
ADM_SCR_RET     = 23                                    'subscreen beenden
ADM_SCR_USE     = 24                                    'tape öffnen
ADM_SCR_TAPES   = 25                                    'tapeliste abfragen

ADM_M_PARSE     = 30                                    'nächstes token aus screen parsen
ADM_M_SETBASE   = 31                                    'zahlenbasis setzen

ADM_COM_TX      = 40                                    'com: zeichen senden
ADM_COM_RX      = 41                                    'com: zeichen empfangen

adm_m_run       = 50                                    'plx: polling aktivieren
adm_m_halt      = 51                                    'plx: polling anhalten
adm_m_in        = 52
adm_m_out       = 53
adm_m_adch      = 54
adm_m_getreg    = 55
adm_m_setreg    = 56
adm_m_start     = 57
adm_m_stop      = 58
adm_m_write     = 59
adm_m_read      = 60
adm_m_ping      = 61
adm_m_setadr    = 62
adm_m_joy       = 63
adm_m_paddle    = 64
adm_m_pad       = 65
adm_m_setjoy    = 66
adm_m_setpad    = 67

adm_m_chan      = 70
adm_m_regclr    = 71
adm_m_setvol    = 72
adm_m_play      = 73
adm_m_noteon    = 74
adm_m_noteoff   = 75
adm_m_setfreq   = 76
adm_m_setwave   = 77
adm_m_setpw     = 78
adm_m_setadsr   = 79
adm_m_setres    = 80
adm_m_setcoff   = 81
adm_m_setfmask  = 82
adm_m_setftype  = 83
adm_m_ringmod   = 84
adm_m_sync      = 85

adm_m_getspec   = 97                                    'spezifikation abfragen
adm_m_getver    = 98                                    'codeversion abfragen
adm_m_reboot    = 99                                    'neu starten



con     ' bellatrix-funktionen

'       ----------------------------------------------  FUNKTIONEN

bel_key_stat    = 1             'tastaturstatus abfragen
bel_key_code    = 2             'tastaturzeichen abfragen
bel_key_spec    = 3             'sondertasten abfragen
bel_key_wait    = 4             'auf tastaturzeichen warten
bel_pchar       = 5             'zeichen ohne steuerzeichen augeben
bel_setx        = 6             'x-position setzen
bel_sety        = 7             'y-position setzen
bel_getx        = 8             'x-position abfragen
bel_gety        = 9             'y-position abfragen
bel_color       = 10            'farbe setzen
bel_sline       = 11            'startzeile scrollbereich
bel_eline       = 12            'endzeile scrollbereich
bel_settab      = 13            'tabulatorposition setzen

bel_cls         = 1
bel_home        = 2
bel_pos1        = 3
bel_curon       = 4
bel_curoff      = 5
bel_up          = 6
bel_down        = 7
bel_bs          = 8
bel_tab         = 9
bel_nl          = 13

'       ----------------------------------------------  M-FUNKTIONEN

bel_m_parse     = 20            'nächstes token von eingabezeile parsen
bel_m_setbase   = 21            'base setzen
bel_m_dot       = 22            'formatierte ausgabe eines zahlenwertes
bel_m_error     = 23            'm fehlermeldung

'       ----------------------------------------------  SCREENEDITOR

bel_scr_edit    = 24            'screeneditor
bel_scr_put     = 25            'screen empfangen
bel_scr_get     = 26            'screen senden
bel_scr_setnr   = 27            'screennummer setzen

'       ----------------------------------------------  CHIP-MANAGMENT

bel_mgr_setcolor= 97            'neuen bellatrix-code laden
bel_mgr_load    = 98            'farbregister setzen
bel_reboot      = 99            'bellatrix neu starten

con     ' color-tags

  M_C_TAG1        = $16           'wort ausführen
  M_C_TAG2        = $17           'wort definieren
  M_C_TAG3        = $18           'wort compilieren
  M_C_TAG4        = $19           'zahl
  M_C_TAG5        = $1A           'zahl literal
  M_C_TAG6        = $1B           'string
  M_C_TAG7        = $1C           'string literal
  M_C_TAG8        = $1D           'data
  M_C_TAG9        = $1E           'kommentar
  M_C_TAG10       = $1F           'eos/cursor


  M_C_EXECUTE     = M_C_TAG1
  M_C_CREATE      = M_C_TAG2
  M_C_COMPILE     = M_C_TAG3
  M_C_NUMBER      = M_C_TAG4
  M_C_NUMBERLIT   = M_C_TAG5
  M_C_STRING      = M_C_TAG6
  M_C_STRINGLIT   = M_C_TAG7
  M_C_DATA        = M_C_TAG8
  M_C_REMARK      = M_C_TAG9

  M_C_MAX         = M_C_TAG9      ' tag mit höchstem wert

  M_C_EOS         = M_C_TAG10     ' end of screen tag für den adm-parser

con     ' farbzuordnung
  C_EXECUTE       = 0
  C_CREATE        = 1
  C_COMPILE       = 2
  C_NUMBER        = 3
  C_NUMBERLIT     = 4
  C_STRING        = 5
  C_STRINGLIT     = 6
  C_DATA          = 7
  C_REMARK        = 8

  C_CURSOR        = 15          ' cursorfarbe
  C_NORMAL        = 0           ' normale ausgabefarbe
  C_INFO          = 8           ' farbe für infos
  C_ATTENTION     = 1           ' farbe für hinweise

con     ' fehlercodes

M_ERR_NO          = 0     ' kein fehler
M_ERR_RS          = 1     ' returnstack fehler
M_ERR_DS          = 2     ' datenstack fehler
M_ERR_IN          = 3     ' fehler interpreter
M_ERR_CP          = 4     ' fehler compiler
M_ERR_SI          = 5     ' strukturfehler
M_ERR_SD          = 6     ' datenträgerfehler
M_ERR_RW          = 7     ' schreib/lesefehler
M_ERR_NF          = 8     ' not found
M_ERR_ST          = 9     ' stackfehler


pub dummy

' diese routine muss vorhanden sein,
' da sonst kein objekt erzeugt und eingebunden wird

