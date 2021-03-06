Forth im Überblick:
===================

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
