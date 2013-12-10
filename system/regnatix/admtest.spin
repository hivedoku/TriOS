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
Name            : Administra-Test
Chip            : Regnatix
Typ             : Programm
Version         : 01
Subversion      : 01
Funktion        : Testroutinen für die Administra-Funktionen
Komponenten     : stringEngine  7/10/2009 Kwabena W. Agyeman    MIT Lizenz      
COG's           : -
Logbuch         :

21-03-2010-dr235  - erste version

Kommandoliste   :
Notizen         :

}}

OBJ
        ios: "reg-ios"
        str: "glob-string"

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000

VAR

  byte  tbuf[32]
  
PUB main | fnr

  ios.start

  repeat
    ios.screeninit
    ios.print(string("Hive: Administra-Test [Auswahl Funktionskomplex]"))
    ios.print(string(13,"1.  chip-managment"))
    ios.print(string(13,"2.  sd-laufwerksfunktionen"))
    ios.print(string(13,"3.  hss-funktionen"))
    ios.print(string(13,"4.  wav-funktionen",13))
    ios.print(string(13,"99  testprogramm beenden",13,13))
    fnr := str.decimalToNumber(fInput(string("Funktion wählen : ")))
    case fnr
      1: menu_mgr
      2: menu_sd
      3: menu_hss
      4: menu_wav
      99: ios.stop
      
PUB menu_mgr | fnr

  repeat
    ios.screeninit
    ios.print(string("▶ Hive: Administra-Test [Chip-Managment]"))
    ios.print(string(13,"1. getver, getspez, getcogs"))
    ios.print(string(13,"2. neuen administra-code booten (admled.adm)"))
    ios.print(string(13,"88 alle tests"))
    ios.print(string(13,"99 zurück",13,13))
    fnr := str.decimalToNumber(fInput(string("Funktion wählen : ")))
    case fnr
      1:  \fTest10
      2:  \fTest11
      88: 
      99: return
   

PUB menu_sd | fnr

  repeat
    ios.screeninit
    ios.print(string("▶ Hive: Administra-Test [SD-Laufwerksfunktionen]"))
    ios.print(string(13,"1. mount, volname, free, unused, checkmount"))
    ios.print(string(13,"2. daten schreiben + lesen"))
    ios.print(string(13,"3. block schreiben + lesen"))
    ios.print(string(13,"4. inhaltsverzeichnis"))
    ios.print(string(13,"5. dateien/verzeichnisse erzeugen, umbenennen, löschen"))
    ios.print(string(13,"6. positionieren in der datei"))
    ios.print(string(13,"7. dateiattribute verändern"))
    ios.print(string(13,"8. verzeichnis wechseln"))
    ios.print(string(13,"9. format + unmount",13))
    ios.print(string(13,"88 alle tests"))
    ios.print(string(13,"99 zurück",13,13))
    fnr := str.decimalToNumber(fInput(string("Funktion wählen : ")))
    case fnr
      1: \fTest1
      2: \fTest2
      3: \fTest3
      4: \fTest4
      5: \fTest5
      6: \fTest6
      7: \fTest7
      8: \fTest8
      9: \fTest9
      88: \loop_sd
      99: return

PUB menu_hss

PUB menu_wav

PUB loop_mgr

  repeat
    fTest10                     'getver,getspec,getcogs
    fTest11                     'administra-code booten
    
PUB loop_sd

  repeat
    fTest1                      'mount, volname, free, unused, checkmounted
    fTest2                      'daten schreiben + lesen
    fTest3                      'block schreiben + lesen
    fTest4                      'inhaltsverzeichnis
    fTest5                      'dateien erzeugen, umbenennen, löschen
    fTest6                      'seek
    fTest7                      'attribute ändern
    fTest8                      'cd
    fTest9                      'format + unmount

DAT                                                     'test 1: mount & unmount
t1_s1   byte  "Test1: Volume mounten",0
t1_s2   byte  "[sdmount]",0
t1_s3   byte  "[sdvolname] = ",0
t1_s4   byte  "[sdcheckmounted] = ",0
t1_s5   byte  "[sdcheckused] = ",0
t1_s6   byte  "[sdcheckfree] = ",0

PRI fTest1 | err
  
  fScreen(@t1_s1)
  repeat
    ios.print(@t1_s2)                                   'sdmount
    err := ios.sdmount
    fError(err)
    fPrintResultDec(@t1_s4,ios.sdcheckmounted)
    ifnot err
      fPrintResultStr(@t1_s3,ios.sdvolname)
      fPrintResultDec(@t1_s5,ios.sdcheckused)
      fPrintResultDec(@t1_s6,ios.sdcheckfree)
  until fAktion  


DAT                                                     'test 2: daten schreiben & lesen
t2_s1   byte  "Test2: Daten schreiben und lesen ",0
t2_s2   byte  "[sdopen-w]",0
t2_s3   byte  "[sdputc] = ",0
t2_s4   byte  "[sdclose]",0
t2_s5   byte  "[sdnewfile]",0
t2_s6   byte  "[sdgetc] = ",0
t2_s7   byte  "[sdopen-r]",0
t2_s8   byte  "Daten lesen...",0
t2_fn   byte  "admtest.dat",0

PRI fTest2 | err,i

  fScreen(@t2_s1)
  repeat

    ios.print(@t1_s2)                                   'sdmount
    err := ios.sdmount
    fError(err)

    ios.print(@t2_s5)                                   'sdnewfile
    err := ios.sdnewfile(@t2_fn)
    fError(err)

    ios.print(@t2_s2)
    err := ios.sdopen("W",@t2_fn)                       'sdopen
    fError(err)
    ifnot err
      ios.print(@t2_s3)
      ios.printnl
      i := 0
      repeat 256
        ios.printhex(i,2)
        ios.printchar(" ")
        ios.sdputc(i++)                                 'sdputc
      ios.printnl
      ios.print(@t2_s4)
      fError(ios.sdclose)                               'sdclose

    fPause(@t2_s8)

    ios.print(@t2_s7)
    err := ios.sdopen("R",@t2_fn)                       'sdopen
    fError(err)
    ifnot err
      ios.print(@t2_s6)
      ios.printnl
      repeat 256
        ios.printhex(ios.sdgetc,2)                       'sdgetc
        ios.printchar(" ")
      ios.printnl
      ios.print(@t2_s4)
      fError(ios.sdclose)                               'sdclose
        

    
  until fAktion  

DAT                                                     'test 3: Block schreiben & lesen
t3_s1   byte  "Test3: Block schreiben & lesen",0
t3_s2   byte  "[sdnewfile]",0
t3_s3   byte  "[sdopen-w]",0
t3_s4   byte  "[sdopen-r]",0
t3_s5   byte  "[sdclose]",0
t3_s6   byte  "[sdputblk]",0
t3_s7   byte  "[sdgetblk]",0
t3_s8   byte  "Puffer mit Werten füllen...",0
t3_s9   byte  "Puffer löschen...",0
t3_s10  byte  "Puffer = ",0
t3_fn   byte  "admtest.dat",0

CON
blkcount        = 256

VAR
byte    buffer[blkcount]

PRI fTest3 | i,err

  fScreen(@t3_s1)
  repeat

    i := 0
    ios.print(@t3_s8)                                   'puffer mit werten füllen
    ios.printnl
    repeat blkcount
      byte[@buffer][i++] := i

    i := 0
    ios.print(@t3_s10)                                  'puffer anzeigen
    repeat blkcount
      ios.printhex(byte[@buffer][i++],2)
      ios.printchar(":")

    fPause(@t3_s8)

    ios.print(@t3_s3)                                   'puffer --> datei
    err := ios.sdopen("W",@t3_fn)                       
    fError(err)
    ifnot err
      ios.print(@t3_s6)
      ios.printnl
      ios.sdputblk(blkcount,@buffer)
      ios.print(@t3_s5)
      ios.sdclose
      ios.printnl

    i := 0
    ios.print(@t3_s9)                                   'puffer löschen
    repeat blkcount
      byte[@buffer][i++] := 0

    ios.print(@t3_s4)                                   'puffer <-- datei
    err := ios.sdopen("R",@t3_fn)                       
    fError(err)
    ifnot err
      ios.print(@t3_s6)
      ios.printnl
      ios.sdgetblk(blkcount,@buffer)
      ios.print(@t3_s5)
      ios.sdclose
      ios.printnl

    i := 0
    ios.print(@t3_s10)                                  'puffer anzeigen
    repeat blkcount
      ios.printhex(byte[@buffer][i++],2)
      ios.printchar(":")
      
  until fAktion  

DAT                                                     'test 4: Inhaltsverzeichnis
t4_s1   byte  "Test4: Inhaltsverzeichnis (einfach)",0
t4_s2   byte  "[sddir] ",0
t4_s3   byte  "[sdnext] = ",0
t4_s4   byte  "Test4: Inhaltsverzeichnis (Attribute)",0
t4_s5   byte  "DIR ▶ ",0
t4_s6   byte  "      ",0

PRI fTest4 | stradr

  fScreen(@t4_s1)
  repeat
  
    fMount
    ios.print(@t4_s2)
    ios.sddir
     repeat while (stradr := ios.sdnext)
       ios.printnl
       ios.print(@t4_s3)
       ios.print(stradr)

    fPause(@t4_s4)
    ios.print(@t4_s2)
    ios.sddir
     repeat while (stradr := ios.sdnext)
       ios.printnl
       if ios.sdfattrib(ios#F_DIR)                                              'verzeichnisname
         ios.print(@t4_s5)
         ios.print(stradr)
       else                                                                     'dateiname
          ios.print(@t4_S6)
         ios.print(stradr)
       
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_SIZE),10))             'dateigröße

       ios.printchar(" ")                                                       'attribute
       if ios.sdfattrib(ios#F_READONLY)
          ios.printchar("r")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_HIDDEN)
          ios.printchar("h")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_SYSTEM)
          ios.printchar("s")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_ARCHIV)
          ios.printchar("a")
       else
          ios.printchar("-")

       ios.printchar(" ")                                                       'änderungsdatum
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CDAY),2))
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMONTH),2) + 1)
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CYEAR),4) + 1)
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CHOUR),2))
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMIN),2) + 1)
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CSEC),2) + 1)
       
    
  until fAktion

DAT                                                     'test 4: dateien/verzeichnisse erzeugen, umbenennen, löschen
t5_s1   byte  "Test5: Dateien/Verzeichnisse erzeugen, umbenennen, löschen ",0
t5_s2   byte  "[sdnewdir] : admtest",0
t5_s3   byte  "[sdnewfile] : admtest.dat",0
t5_s4   byte  "[sddel] : admtest + admtest.dat",0
t5_s5   byte  "[sdrename] admtest -> admtest2",0
t5_s6   byte  "admtest",0
t5_s7   byte  13,"pause ",0
t5_s8   byte  "admtest.dat",0
t5_s9   byte  "admtest2.dat",0
t5_s10  byte  "admtest2",0

PRI fTest5 | err

  fScreen(@t5_s1)
  repeat
    fMount
    fPause(@t5_s7)
    fDir

    fPause(@t5_s7)
    ios.print(@t5_s2)
    ios.printnl
    fError(ios.sdnewdir(@t5_s6))
    fPause(@t5_s7)
    fDir

    fPause(@t5_s7)
    ios.print(@t5_s3)
    ios.printnl
    fError(ios.sdnewfile(@t5_s8))
    fPause(@t5_s7)
    fDir

    fPause(@t5_s7)
    ios.print(@t5_s5)
    ios.printnl
    fError(ios.sdrename(@t5_s6,@t5_s10))
    fError(ios.sdrename(@t5_s8,@t5_s9))
    fPause(@t5_s7)
    fDir

    fPause(@t5_s7)
    ios.print(@t5_s4)
    ios.printnl
    fError(ios.sddel(@t5_s10))
    fError(ios.sddel(@t5_s9))
    fPause(@t5_s7)
    fDir
    
    
  until fAktion

DAT                                                     'test 6: seek
t6_s1   byte  "Test6: seek ",0
t6_s2   byte  "[sdopen] : test2.txt",0
t6_s3   byte  "test2.txt",0
t6_s4   byte  "Jetzt Test mit steigendem seek-Wert...",0
t6_s5   byte  "[seek] = ",0

PRI fTest6 | i

  fScreen(@t6_s1)
  repeat

    fMount

    fError(ios.sdopen("R",@t6_s3))
    repeat 128
      ios.printchar(ios.sdgetc)
    ios.sdclose

    ios.printnl
    fPause(@t6_s4)
    repeat i from 0 to 64
      ios.printcls
      ios.print(@t6_s5)
      ios.printdec(i)
      ios.printnl
      ios.printnl
      ios.sdopen("R",@t6_s3)
      ios.sdseek(i)
      repeat 128
        ios.printchar(ios.sdgetc)
      ios.sdclose
'     fWait(1)
      
  until fAktion


DAT                                                     'test 7: attribute ändern
t7_s1   byte  "Test7: Attribute ändern ",0
t7_s2   byte  "Testdatei [admtest.dat] erzeugen ",0
t7_s3   byte  "admtest.dat",0
t7_s4   byte  13,"Attributstring eingeben <ASHR> : ",0

PRI fTest7

  fScreen(@t7_s1)
  fMount
  ios.print(@t7_s2)
  ios.printnl
  fError(ios.sdnewfile(@t7_s3))

  repeat
    fDir
    fError(ios.sdchattrib(@t7_s3,fInput(@t7_s4)))
  until fAktion

  fError(ios.sddel(@t7_s3))
  
DAT                                                     'test 8: verzeichnis wechseln
t8_s1   byte  "Test8: Verzeichnis wechseln ",0
t8_s2   byte  "Testverzeichnis [admtest] erzeugen ",0
t8_s3   byte  "admtest",0
t8_s4   byte  13,"pause",13,0
t8_s5   byte  "..",0

PRI fTest8

  fScreen(@t8_s1)
  fMount                                                'medium mounten
  ios.print(@t8_s2)
  ios.printnl
  fError(ios.sdnewdir(@t8_s3))                          'testverzeichnis erzeugen
  repeat

    fDir
    fPause(@t8_s4)
    fError(ios.sdchdir(@t8_s3))                         'in testverzeichnis wechseln                                                
    fDir
    fPause(@t8_s4)
    fError(ios.sdchdir(@t8_s5))                         'und wieder zurück zur wurzel                                        
    fDir
    
  until fAktion
  fError(ios.sddel(@t8_s3))                             'testverzeichnis löschen

DAT                                                     'test 9: medium formatieren + abmelden
t9_s1   byte  "Test9: Medium formatieren + abmelden ",0
t9_s2   byte  "ACHTUNG: Medium wird jetzt formatiert!",13,"Testcard einlegen und bestätigen <JA> : ",0
t9_s3   byte  "JA",0
t9_s4   byte  "ADMTEST",0
t9_s5   byte  "[sdformat] ... ",13,0
t9_s6   byte  "[sdunmount] Medium wird jetzt abgemeldet...",13,0

PRI fTest9 | stradr

  fScreen(@t9_s1)
  repeat
    stradr := fInput(@t9_s2)
    fMount
    if strcomp(stradr, @t9_s3)
      ios.print(@t9_s5)
      fError(ios.sdformat(@t9_s4))
    ios.print(@t9_s6)
    fError(ios.sdunmount)  
  until fAktion

DAT                                                     'test 10: getver, getpsec, getcogs
t10_s1  byte  "Test10: getver, getspec, getcogs ",0
t10_s2  byte  13,"Version       : $",0
t10_s3  byte  13,"Specifikation : %",0
t10_s4  byte  13,"COGs          :  ",0

PRI fTest10

  fScreen(@t10_s1)
  repeat
    ios.print(@t10_s2)
    ios.printhex(ios.admgetver,8)
    ios.print(@t10_s3)
    ios.printbin(ios.admgetspec,32)
    ios.print(@t10_s4)
    ios.printhex(ios.admgetcogs,8)
    
  until fAktion

DAT                                                     'test 11: administra-code booten
t11_s1  byte  "Test11: administra-code booten ",0
t11_s2  byte  "admled.adm",0

PRI fTest11

  fScreen(@t11_s1)
  fMount
  repeat
  
    ios.admload(@t11_s2)

  until fAktion

DAT                                                     'test x:
tx_s1   byte  "Testx: Beschreibung ",0

PRI fTestx

  repeat

    fPause(@tx_s1)

  until fAktion

DAT                                                     'fInput: stringeingabe

PRI fInput(stradr1): stradr2

  ios.print(stradr1)
  ios.input(@tbuf,32)
  return @tbuf
  
DAT                                                     'fWait: wartet eine def.zeit

PUB fWait(sek)

  waitcnt(clkfreq * sek + cnt)
  
DAT                                                     'fDir: Verzeichnis anzeigen

PUB fDir | stradr

    ios.sddir
     repeat while (stradr := ios.sdnext)
       ios.printnl
       if ios.sdfattrib(ios#F_DIR)                                              'verzeichnisname
         ios.print(@t4_s5)
         ios.print(stradr)
       else                                                                     'dateiname
          ios.print(@t4_S6)
         ios.print(stradr)
       
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_SIZE),10))             'dateigröße

       ios.printchar(" ")                                                       'attribute
       if ios.sdfattrib(ios#F_READONLY)
          ios.printchar("r")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_HIDDEN)
          ios.printchar("h")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_SYSTEM)
          ios.printchar("s")
       else
          ios.printchar("-")
       if ios.sdfattrib(ios#F_ARCHIV)
          ios.printchar("a")
       else
          ios.printchar("-")

       ios.printchar(" ")                                                       'änderungsdatum
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CDAY),2))
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMONTH),2) + 1)
       ios.printchar(".")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CYEAR),4) + 1)
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CHOUR),2))
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CMIN),2) + 1)
       ios.printchar(":")
       ios.print(str.numberToDecimal(ios.sdfattrib(ios#F_CSEC),2) + 1)

DAT                                                     'fMount: Medium einbinden
i_s1    byte  13,"Medium wird eingebunden...",0

PRI fMount | err

    ios.print(@i_s1)                                    'sdmount
    err := ios.sdmount
    fError(err)
    ifnot err
      fPrintResultStr(@t1_s3,ios.sdvolname)


DAT                                                     'fAktion: Aktion abfragen
a_s1    byte  "<E>nde, <N>ochmal, <W>eiter : ",0

PRI fAktion: aktion

  ios.printnl
  ios.print(@a_s1)
  case ios.keywait
    "e":  abort
    "w":  aktion := 1
    "n":  aktion := 0

  ios.printnl
    
DAT                                                     'fPause: Printausgabe und Pause
p_s1   byte "Weiter? <*> :",0

PRI fPause(strptr)                                      

  ios.print(strptr)
  ios.printnl
  ios.print(@p_s1)
  ios.keywait
  ios.printnl

DAT                                                     'fScreen: Initialisierung neuer Test
s_s1   byte "Weiter? <*> :",0

PRI fScreen(strptr)                                      

  ios.screeninit
  ios.print(strptr)
  ios.print(@s_s1)
  ios.keywait
  ios.printnl

DAT                                                     'fPrintResultStr: Testanzeige von Stringresultaten
PRI fPrintResultStr(strptr1,strptr2)                    

  ios.print(strptr1)
  ios.print(strptr2)
  ios.printnl

DAT                                                     'fPrintResultDec: Testanzeige von Dezimalwerten 
PRI fPrintResultDec(strptr, wert)                       

  ios.print(strptr)
  ios.printdec(wert)
  ios.printnl

DAT                                                     'fError: Fehler ausgeben
f_s1    byte "Fehlernummer : ",0
f_s2    byte "Fehler       : ",0

err0    byte "no error",0
err1    byte "fsys unmounted",0
err2    byte "fsys corrupted",0
err3    byte "fsys unsupported",0
err4    byte "not found",0
err5    byte "file not found",0
err6    byte "dir not found",0
err7    byte "file read only",0
err8    byte "end of file",0
err9    byte "end of directory",0
err10   byte "end of root",0
err11   byte "dir is full",0
err12   byte "dir is not empty",0
err13   byte "checksum error",0
err14   byte "reboot error",0
err15   byte "bpb corrupt",0
err16   byte "fsi corrupt",0
err17   byte "dir already exist",0
err18   byte "file already exist",0
err19   byte "out of disk free space",0
err20   byte "disk io error",0
errx    byte "undefined",0


PRI fError(err)

  ios.printnl
  ios.print(@f_s1)
  ios.printdec(err)
  ios.print(string(" : $"))
  ios.printhex(err,2)
  ios.printnl
  ios.print(@f_s2)
  case err
    0:  ios.print(@err0)
    1:  ios.print(@err1)
    2:  ios.print(@err2)
    3:  ios.print(@err3)
    4:  ios.print(@err4)
    5:  ios.print(@err5)
    6:  ios.print(@err6)
    7:  ios.print(@err7)
    8:  ios.print(@err8)
    9:  ios.print(@err9)
    10: ios.print(@err10)
    11: ios.print(@err11)
    12: ios.print(@err12)
    13: ios.print(@err13)
    14: ios.print(@err14)
    15: ios.print(@err15)
    16: ios.print(@err16)
    17: ios.print(@err17)
    18: ios.print(@err18)
    19: ios.print(@err19)
    20: ios.print(@err20)
    OTHER: ios.print(@errx)
  ios.printnl


DAT

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
