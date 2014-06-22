INHALT
======

1. Installations-Varianten
2. Installation des Grundsystems
3. Regime im Überblick
4. Forth im Überblick


1. Installations-Varianten
==========================

Zur Installation von TriOS auf dem Hive stehen 3 verschiedene Varianten zur
Verfügung, welche am Ende aber dasselbe Ergebnis erzielen:

Binäres Archiv: HIVE-TriOS-Rxx-bin.zip
Source-Archiv:  HIVE-TriOS-Rxx-src.zip
Git Repository: https://dev.bitquell.de/summary/HIVE/TriOS.git

Das binäre Archiv kann sofort installiert werden. Wer selbst an den Quellen
Änderungen vornehmen, sollte stattdessen das Source-Archiv nutzen oder gleich
das top-aktuelle Git Repository nutzen.

Bei Nutzung des Source-Archives oder des Git-Repository müssen die Quellen vor
der Installation noch compiliert werden.

WICHTIG: Das System kann nur mit Brat's Spin Tool - kurz BST - compiliert
werden. In den Einstellungen des Compilers
(Tools/Compiler Preferences/Search Paths) muss das lib-Verzeichnis eingetragen
werden.

Downloadlink BST: http://www.fnarfbargle.com/bst.html 

Zum einfachen Compilieren des Gesamtsystems steht für Windows die Batch-Datei
"make.bat" bzw. "makelog.bat" zur Verfügung, für Linux das Script "make.sh".
Voraussetzung ist, daß sich die Commandline-Version des Compilers (bstc) im
Pfad befindet.
Downloadlink BSTC: http://www.fnarfbargle.com/bst/bstc/Latest/


2. Installation des Grundsystems:
=================================

TriOS kann in zwei Versionen installiert werden: Mit oder ohne Forth als
integrierte Programmiersprache. Als Standard wird das System ohne Forth
installiert. Die Installation ist so für den Einsteiger einfacher. Möchte
man auch PropForth installieren, muß nur ein Basiswortschatz im Forth selbst
kompiliert werden.


Installation ohne Forth (Standard):
-----------------------------------

1. Mikrocontroller flashen:

\flash\administra\admflash.spin --> Administra
\flash\bellatrix\belflash.spin  --> Bellatrix
\flash\regnatix\regflash.spin   --> Regnatix


Installation mit Forth:
-----------------------

1. Mikrocontroller flashen:

\flash\administra\admflash.spin --> Administra
\flash\bellatrix\belflash.spin  --> Bellatrix
\flash\regnatix\regforth.spin   --> Regnatix

2. Der Schalter bleibt ab jetzt auf Regnatix stehen. Ein Terminalprogramm (ich
   verwende Tera Term) starten und 57600 Baud auf die Schnittstelle vom Hive
   (DIP steht auf Regnatix!) einstellen. Nach einem Reset meldet sich das
   Propforth im Terminalprogramm auf dem Hostcomputer. Datei "forth\basics.mod"
   in einem Editor öffnen, alles markieren, kopieren und im Terminal einfügen.
   Der Quelltext wird jetzt im Forth compiliert. 

3. Im Terminalfenster, also im Forth, dass Kommendo "saveforth" eingeben. Damit
   wird das gesamte Forthsystem mit der gerade neu compilierten Erweiterungen
   wieder im EEPROM als Image gespeichert. 

Nach einem Reset sollte sich das Forth jetzt komplett mit seinem Prompt sowohl
auf dem angeschlossenen VGA-Monitor, als auch im Terminal melden. Im Prinzip
benötigen wir nun das Terminalprogramm nicht mehr und können direkt am Hive
arbeiten. Später, wenn man in Forth programmiert, ist die vorhandene
Terminalschnittstelle aber manchmal sehr nützlich.



Erstellen der SDCard:
---------------------

Im Prinzip kann jede normale FAT16/32 Karte verwendet werden. Lange Dateinamen
werden nicht verwendet, Unterverzeichnisse sind kein Problem. Es ist sinnvoll,
alle Dateien aus dem Verzeichnis "bin\sd-card\" auf die SD-Karte zu kopieren.

Das Verzeichnis "system" hat eine besondere Bedeutung: Hier sollten sich die
Tools, Erweiterungen und Bibliotheken befinden. Im PropForth: Mit  dem Kommando
"sys name.f" kann aus jedem anderen Verzeichnis ohne Wechsel eine Datei name.f
im Verzeichnis System geladen und compiliert werden.



Systemstart:
------------

Beim Systemstart wird immer das Forth aus dem EEPROM gestartet. So kann, wie
mit den klassischen Homecomputern, sofort unkompliziert programmiert werden.
Neben dem Forth gibt es im TriOS noch ein in Spin programmiertes Betriebssystem,
welches sich dem Benutzer durch den Kommandointerpreter Regime präsentiert. Aus
dem Forth kann diese mit dem Kommando "regime" gestartet werden. Im Gegenzug
kann im laufenden Regime mit dem Kommando "forth" wieder zur integrierten
Programmiersprache gewechselt werden.

Wurde TriOS ohne Forth installiert, wird der Loader aus dem EEPROM gestartet und
sofort die Kommandozeile "Regime" aus der Datei reg.sys gestartet.




3. Regime im Überblick
======================

Da wir ja drei verschiedene Teilsystem in unserem Computer haben, muss Regime
wissen, für welchen Chip eine ausführbare Datei bestimmt ist. Den Typ
ausführbarer Dateien kann Regime automatisch anhand der Dateinamenserweiterung
unterscheiden:

*.bin   Regnatix-Code
*.bel   Bellatrix-Code
*.adm   Administra-Code

Dabei genügt es, den Namen ohne Erweiterung einzugeben. Dennoch kann es
vorkommen, das man eine normale Spin-Datei mit einer beliebigen Erweiterung
gespeichert hat. Diese Datei kann man dann mit den Kommandos rload, aload oder
bload ganz gezielt in einen Chip laden.

<dateiname>                     - bin/adm/bel-datei wird gestartet
mount                           - SD-aufwerk mounten
unmount                         - SD-Laufwerk freigeben
dir wh                          - Verzeichnis anzeigen
type <sd:fn>                    - Anzeige einer Textdatei
aload <sd:fn>                   - Administra-Code laden
bload <sd:fn>                   - Bellatrix-Code laden
rload <sd:fn>                   - Regnatix-Code laden
del <sd:fn>                     - Datei löschen
cls                             - Bildschirm löschen
free                            - Anzeige des freien Speichers auf SD-Card
attrib <sd:fn> ashr             - Dateiattribute ändern
cd <sd:dir>                     - Verzeichnis wechseln
mkdir <sd:dir>                  - Verzeichnis erstellen
rename <sd:fn1> <sd:fn2>        - datei/verzeichnis umbenennen
format <volname>                - SD-Laufwerk formatieren
reboot                          - Hive neu starten
sysinfo                         - Systeminformationen
ipconfig                        - Netzwerk-Konfiguration
color <0..7>                    - Farbe wählen
cogs                            - Belegung der COG's anzeigen
dmlist                          - Anzeige der Verzeichnis-Marker
dm <r/s/u/a/b/c>                - Marker-Verzeichnis wechseln
dmset <r/s/u/a/b/c>             - Marker setzen
dmclr <r/s/u/a/b/c>             - Marker löschen
forth                           - Forth starten

Marker:
r       - Marker für Root-Verzeichnis
s       - Marker für System-Verzeichnis
u       - Marker für User-Verzeichnis
a/b/c   - Benutzerdefinierte Verzeichnismarker

Die r, s, u-Marker werden vom System automatisch gesetzt und intern verwendet.

RAMDISK:

xload <sd:fn>                   - Datei von SD-Laufwerk in RAM laden
xsave <x:fn>                    - Datei aus RAM auf SD-Laufwerk speichern
xdir                            - Verzeichnis im RAM anzeigen
xrename <x:fn1> <x:fn2>         - Datei im RAM umbenennen
xdel <x:fn>                     - Datei im RAM löschen
xtype <x:fn>                    - Textdatei im RAM anzeigen



EXTERNE KOMMANDOS:
------------------

Die meisten Kommandozeilentools zeigen mit dem Parameter /? eine Liste der
Optionen an.

sysconf         - Systemeinstellungen
hplay           - HSS-Player
wplay           - WAV-Player
splay           - SID-Player
yplay           - Yamaha-Soundchip-Player
sfxtool         - HSS-Soundeffekte erstellen

ftp             - FTP-Client
irc             - IRC Client

vga.bin         - VGA 1024 x 768 Pixel, 64 x 24 Zeichen
htext.bin       - VGA 1024 x 768 Pixel, 128 x 48 Zeichen
tv.bin          - TV-Textmodus 40 x 13 Zeichen




4. Forth im Überblick:
======================

Einige nützliche Kommandos befinden sich in dem Modul tools.mod. In den meisten
Fällen ist es sinnvoll dieses Modul mit der Befehlssequenz
"sys tools.mod saveforth" fest im Forth einzubinden.



Wichtige Tastencodes:
---------------------

[ESC]-1         Screen 1, COG 1
[ESC]-2         Screen 2, COG 2
[ESC]-3         Screen 3, COG 3
[ESC]-b         Break, Reset der aktuellen COG
[ESC]-r         Reset, Neustart Regnatix



Wichtige Kommandos:
-------------------

load <name>     - Datei laden und comilieren, Ausgabe Screen 3
dload <name>    - wie load, aber Ausgabe aktueller Screen
sys <name>      - Datei aus sys-Verzeichnis laden und compilieren
ls              - Dateiliste
lsl             - Dateiliste- Long-Format
cd <name>       - in Verzeichniss wechseln
mount           - SD-Card einbinden
unmount         - SD-Card freigeben
words           - Anzeige Wöterbuch
mod?            - (tools.mod) Anzeige compilierter Erweiterungen
lib?            - (tools.mod) Anzeige compilierter Bibliotheken
cog?            - (tools.mod) Anzeige COG-Liste
cat <name>      - (tools.mod) Ausgabe einer Textdatei
less <name>     - (tools.mod) Zeilenweise Textausgabe
dm?             - (tools.mod) Anzeige der Systemverzeichnisse
regime          - CLI starten
aload <name>    - Adminsitra-Code laden
bload <name>    - Bellatrix-Code laden
spin <name>     - Spin-Programm starten



Wichtige Dateien:
-----------------

Die Dateien *.mod und *.lib enthalten ganz normale Forth-Quelltexte. Damit hat
man schnell eine Übersicht über die grobe Funktion dieser Quellen: Lib's sind
halt reine  Sammlungen von Worten zu einer bestimmten Funktionsgruppe und MOD's
sind mehr oder weniger fertige und abgeschlossene Programme. Ein Beispiel:

Die Datei hss.lib enthält Worte um die HSS-Funktionen von Administra
anzusprechen. Mit diesen Funktionen kann man nun ein Modul (Programm) wie einen
HSS-Soundplayer schreiben.

Im Gegensatz dazu die Datei splay.mod: Mit diesem Modul wird ein HSS-Soundplayer
ins System eingefügt, welcher Funktionen aus der hss.lib verwendet. 

Die Datei benötigt man aber mehr oder weniger nur zur  Entwicklung, ein fertiges
Modul wie splay.mod enthält dann  schon die die entsprechenden HSS-Worte die
benötigt werden. 

Die ifnot: ... Anweisung sorgt dabei dafür, dass keine Funktionen doppelt in das
Wörterbuch compiliert werden. Das ist quasi ein verteiltes und fein granuliertes
Konzept analog zu einer DLL. Die Forth-Version funktioniert dabei aber im
Gegensatz zu DLL's nicht auf Bibliotheks-, sondern auf Funktionsebene.

*.mod   Module, Forth-Erweiterungen für das System
*.lib   Bibliotheken, grundlegende Wortsammlungen
*.adm   Administra-Code (z.Bsp. admsid.adm für SIDCog-Code)
*.bel   Bellatrix-Code
*.bin   Spin-Code, im Normalfall zur Ausführung in Regnatix

basics.f        - (mod:basics) Hive-Core für PropForth
ari.lib         - (lib:ari) Zusätzliche arithmetische Funktionen
cog.lib         - (lib:cog) Zusätzliche COG-Funktionen
adm.lib         - (lib:adm) Administra-Chipmanagment-Funktionen
hss.lib         - (lib:hss) Bibliothek für Hydra-Sound-System
sfx.lib         - (lib:sfx) Soundeffekt-Bibliothek
wav.lib         - (lib:wav) Wave-Soundbibliothek

bel.lib         - (lib:bel) Bellatrix-Chipmanagment-Funktionen
key.lib         - (lib:key) Tastatur-Bibliothek
scr.lib         - (lib:scr) Screen-Bibliothek
sd0.lib         - (lib:sd0) SD-Card-Bibliothek

debug.f         - Nützliche Worte zur Fehlersuche und Entwicklung
rom.f           - EEPROM-Dateisystem
tools.f         - Nützliche Tools (cat, less, dm?...)
hplay.f         - HSS-Player
wplay.f         - WAV-Player
splay.f         - SID-Player

Administra-Codedateien im SYS-Verzeichnis:

admled.adm      Testprogramm - HBeat-LED blinken lassen
admnet.adm      Netzwerk-Version (wird von ftp und irc benötigt)
admsid.adm      SidCog-Version (wird von splay benötigt)
admsys.adm      Standardcode für ADM mit SD/HSS/WAV
admym.adm       Yamaha-Soundchip-Version
aterm96.adm     Mini-OS für Administra (Testzwecke)



Reset-Fehlercodes:
------------------

0011FFFF - stack overflow
0012FFFF - return stack overflow
0021FFFF - stack underflow
0022FFFF - return stack underflow
8100FFFF - no free cogs
8200FFFF - no free main memory
8400FFFF - fl no free main memory
8500FFFF - no free cog memory
8800FFFF - eeprom write error
9000FFFF - eeprom read error



.err-Fehlercodes:
-----------------

0    no error
1    fsys unmounted
2    fsys corrupted
3    fsys unsupported
4    not found
5    file not found
6    dir not found
7    file read only
8    end of file
9    end of directory
10   end of root
11   dir is full
12   dir is not empty
13   checksum error
14   reboot error
15   bpb corrupt
16   fsi corrupt
17   dir already exist
18   file already exist
19   out of disk free space
20   disk io error
21   command not found
22   timeout
23   parameter error
