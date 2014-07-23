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

beltest         - Testprogramm für Bellatrix-Funktionen
charmap         - Ausgabe des aktuellen nutzbaren Zeichensatzes
eram            - Debugtool für eRAM/Ramdisk
flash           - Flash-Tool für EEProms > 32 KByte
fm              - [F]ile [M]anager
fterm           - minimalstes Terminal für PropForth-Experimente
ftp             - FTP-Downloadprogramm
g0test          - Testprogramm der Grafikmodus 0 Funktionen (TV)
hplay           - HSS-Player
ipconfig        - Setup für Netzwerkparameter (IP/GW usw.)
irc             - IRC-Client
keycode         - Tastaturcodes anzeigen
m               - Startcode für mental unter TriOS (sofern installiert)
man             - Anzeige von Manual-Pages
perplex         - PlexBus-Tool
ramtest         - eRAM Testprogramm
rom             - startet ein Image aus dem EEPROM > 32 KByte
sfxtool         - HSS-Soundeffekte erstellen
splay           - SID-Player
sysconf         - Systemeinstellungen
tapecut         - Tool um eine Containerdatei (Tape) für mental zu erzeugen
time            - Zeit/Datum anzeigen bzw. im RTC setzen
websrv          - Webserver (Demo)
wplay           - WAV-Player
yplay           - Yamaha-Soundchip-Player

Bellatrix-Codes:

vga             - VGA 1024 x 768 Pixel, 64 x 24 Zeichen
htext           - VGA 1024 x 768 Pixel, 128 x 48 Zeichen
tv              - TV-Textmodus 40 x 13 Zeichen

Administra-Codes:

admay           - Yamaha-Soundchip-Emulation
admnet          - LAN + HSS-Light-Sound
admsid          - SID-Chip-Emulation
admsys          - HSS/WAV-Sound (Defaultcode)
