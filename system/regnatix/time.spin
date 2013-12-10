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
Name            : flash
Chip            : Regnatix
Typ             : Programm
Version         : 
Subversion      : 
Funktion        : RTC-Funktionen Date/Time
Komponenten     : -
COG's           : -
Logbuch         :

05.12.2010-stephan - DateTime Funktionen
09-04-2011-dr235   - auskopplung aus regime

Kommandoliste   :


Notizen         :


}}

OBJ
        ios: "reg-ios"
        str: "glob-string"
        num: "glob-numbers"        'Number Engine

CON

_CLKMODE     = XTAL1 + PLL16X
_XINFREQ     = 5_000_000



VAR

byte    parastr[64]

PUB main

  ios.start                                             'ios initialisieren
  ios.parastart                                         'parameterübergabe starten
  repeat while ios.paranext(@parastr)                   'parameter einlesen
    if byte[@parastr][0] == "/"                         'option?
      case byte[@parastr][1]
        "?": ios.print(@help)
        "d": cmd_date
        "l": cmd_date_long
        "t": cmd_time
        "s": cmd_setDateTime
        other: ios.print(@help)
  ios.stop

CON ''------------------------------------------------- DATE TIME FUNKTIONEN

PUB cmd_date | stringpointer, format                    'rtc: aktuelles Datum zurückgeben

  format := ios.getNVSRAM(ios#NVRAM_DATEFORMAT)

  case format
    ios#DATEFORMAT_DE:          'YYYY-MM-DD
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getDate, 2)))
      ios.print(string("."))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMonth, 2)))
      ios.print(string("."))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getYear, 4)))
      ios.printnl

    ios#DATEFORMAT_UK:          'DD/MM/YYYY
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getDate, 2)))
      ios.print(string("/"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMonth, 2)))
      ios.print(string("/"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getYear, 4)))
      ios.printnl

    ios#DATEFORMAT_US:          'MM/DD/YYYY
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMonth, 2)))
      ios.print(string("/"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getDate, 2)))
      ios.print(string("/"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getYear, 4)))
      ios.printnl

    other: 'DATEFORMAT_CANONICAL  'YYYY-MM-DD
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getYear, 4)))
      ios.print(string("-"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMonth, 2)))
      ios.print(string("-"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getDate, 2)))
      ios.printnl

PRI cmd_date_long | stringpointer, month, weekday       'rtc: aktuelles Datum zurückgeben

  case ios.getNVSRAM(ios#NVRAM_LANG)
    ios#LANG_EN:
      weekday := lookup(ios.getDay: string("Sunday"), string("Monday"), string("Tuesday"), string("Wednesday"), string("Thursday"), string("Friday"), string("Saturday"))
      month   := lookup(ios.getMonth: string("January"), string("February"), string("March"), string("April"), string("May"), string("June"), string("July"), string("August"), string("September"), string("October"), string("November"), string("December"))
    other:
      weekday := lookup(ios.getDay: string("Montag"), string("Dienstag"), string("Mittwoch"), string("Donnerstag"), string("Freitag"), string("Samstag"), string("Sonntag"))
      month   := lookup(ios.getMonth: string("Januar"), string("Februar"), string("März"), string("April"), string("Mai"), string("Juni"), string("Juli"), string("August"), string("September"), string("Oktober"), string("November"), string("Dezember"))

  case ios.getNVSRAM(ios#NVRAM_DATEFORMAT)
    ios#DATEFORMAT_DE:          'YYYY-MM-DD
      ios.print(weekday)
      ios.print(string(", "))
      ios.print(str.trimCharacters(num.ToStr(ios.getDate, num#DEC)))
      ios.print(string(". "))
      ios.print(month)
      ios.print(string(" "))
      ios.print(str.trimCharacters(num.ToStr(ios.getYear, num#DEC)))
      ios.print(string(" "))
      cmd_time

    ios#DATEFORMAT_UK:          'DD/MM/YYYY
      ios.print(weekday)
      ios.print(string(", "))
      ios.print(str.trimCharacters(num.ToStr(ios.getDate, num#DEC)))
      ios.print(string(" "))
      ios.print(month)
      ios.print(string(" "))
      ios.print(str.trimCharacters(num.ToStr(ios.getYear, num#DEC)))
      ios.print(string(" "))
      cmd_time

    ios#DATEFORMAT_US:          'MM/DD/YYYY
      ios.print(weekday)
      ios.print(string(", "))
      ios.print(month)
      ios.print(string(" "))
      ios.print(str.trimCharacters(num.ToStr(ios.getDate, num#DEC)))
      ios.print(string(", "))
      ios.print(str.trimCharacters(num.ToStr(ios.getYear, num#DEC)))
      ios.print(string(" "))
      cmd_time

PUB cmd_time | stringpointer, value, suffix             'rtc: aktuelle Zeit zurückgeben
                                                        'time - aktuelle Zeit

  case ios.getNVSRAM(ios#NVRAM_TIMEFORMAT)
    ios#TIMEFORMAT_12:  'HH:MM:SS[PM|AM]
      value := ios.getHours
      if(value > 12)
        suffix := string("PM")
        value -= 12
      else
        suffix := string("AM")
      ios.print(str.trimCharacters(str.numberToDecimal(value, 2)))
      ios.print(string(":"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMinutes, 2)))
      ios.print(string(":"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getSeconds, 2)))
      ios.print(suffix)

    ios#TIMEFORMAT_12UK:  'HH.MM.SS[PM|AM]
      value := ios.getHours
      if(value > 12)
        suffix := string("PM")
        value -= 12
      else
        suffix := string("AM")
      ios.print(str.trimCharacters(str.numberToDecimal(value, 2)))
      ios.print(string("."))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMinutes, 2)))
      ios.print(string("."))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getSeconds, 2)))
      ios.print(suffix)

    other: 'ios#TIMEFORMAT_24: 'HH:MM:SS
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getHours, 2)))
      ios.print(string(":"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getMinutes, 2)))
      ios.print(string(":"))
      ios.print(str.trimCharacters(str.numberToDecimal(ios.getSeconds, 2)))

  ios.printnl

PRI cmd_setDateTime | buffer, changed                   'rtc: Datum/Zeit setzen

  buffer := string("        ")

  'bytefill(buffer, 0, 5)

  ios.print(string("aktuelles Datum: "))
  cmd_Date_long

  ios.print(string("neues Datum eingeben? (j/n): "))
  if ios.keywait == "j"
    ios.printnl
    ios.print(string("Jahr (2000 - 2127): "))
    ios.input(buffer, 4)
    ios.setYear(num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Monat (1 - 12): "))
    ios.input(buffer, 2)
    ios.setMonth(num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Wochentag (1(Mo) - 7(So)): "))
    ios.input(buffer, 1)
    ios.setDay(num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Tag (1 - 31): "))
    ios.input(buffer, 2)
    ios.setDate(num.FromStr(buffer, num#DEC))
    changed := 1

  ios.printnl
  ios.print(string("neue Uhrzeit eingeben? (j/n): "))
  if ios.keywait == "j"
    ios.printnl
    ios.print(string("Stunden (0 - 23): "))
    ios.input(buffer, 2)
    ios.setHours(num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Minuten (0 - 59): "))
    ios.input(buffer, 2)
    ios.setMinutes(num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Sekunden (0 - 59): "))
    ios.input(buffer, 2)
    ios.setSeconds(num.FromStr(buffer, num#DEC))
    changed := 1

  ios.printnl
  ios.print(string("Datumsformat ändern? (j/n): "))
  if ios.keywait == "j"
    ios.printnl
    ios.print(string("Datumsformat (0-DE, 1-Canonical, 2-UK, 3-US): "))
    ios.input(buffer, 1)
    ios.setNVSRAM(ios#NVRAM_DATEFORMAT, num.FromStr(buffer, num#DEC))
    ios.printnl
    ios.print(string("Zeitformat (0-24, 1-12, 2-12UK): "))
    ios.input(buffer, 2)
    ios.setNVSRAM(ios#NVRAM_TIMEFORMAT, num.FromStr(buffer, num#DEC))
    changed := 1

  if changed == 1
    ios.printnl
    ios.print(string("neues Datum: "))
    cmd_Date_long
  ios.printnl

DAT                                                     'sys: helptext


help          byte  "/?  : Hilfe",13
              byte  "/d  : Datum anzeigen",13
              byte  "/l  : Datum Langformat anzeigen",13
              byte  "/t  : Zeit anzeigen",13
              byte  "/s  : Datum/Zeit stellen",13
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
