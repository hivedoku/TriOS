r57-nw1.5 - 23-07-2014-joergd
=============================

Allgemein:
 - alle Spin-Dateien verwenden einheitlich UTF8-Kodierung und ein Zeilenende
   mit Linefeed (LF)

Administra:
 - nur eine Source-Datei für alle Binaries, Funktionsauswahl über Defines
 - DCF77 und Bluetooth aus Basic/Plexus hinzugefügt

Netzwerk-Clients:
 - ipconfig
 - FTP-Client
 - IRC-Client

Netzwerk-Server:
 - Webserver (Demo)

fm, man:
 - Textdateien mit unterschiedlichem Zeilenende (CR, LF) werden unterstützt

Lokalisierung:
 - mittels Defines kann beim Compilieren eine Sprache ausgewählt werden
   (s. ipconfig.spin, irc.spin, ftp.spin, make.sh, make.bat)

Make-Scripts:
 - Linux-Version (make.sh)
 - Erstellung verschiedener Anministra-Binaries per Defines
 - Erstellung beider Regime-Flash-Versionen (mit und ohne Forth)
 - Release-Script


r57 - 21-06-2014-dr235
======================

admflash:
 - Plexbusroutinen eingefügt
 - sd_del - Heartbeat-Sound angepasst

belflash:
 - per Compilerflag wählbare Monitorsettings eingefügt (57/60hz)

basic.mod (propforth):
 - Bei der Installation von TriOS mit Forth muss basic.mod nur noch eingefügt
   werden, damit wird automatisch geflasht und neu gestartet

lib:
 - adm-enc28j60 eingefügt, Treiber Netzwerkchip
 - adm-socket eingefügt, Netzwerksocket
 - adm-plx Code ausgebaut
 - bel-vga Monitorsettings
 - glob-con Plexbus/LAN-Konstanten eingefügt
 - glob-led-engine - neue lib für hbeat-led-pwm
 - gui-dlbox - Redraw beschleunigt
 - gui-wbox - Warnbox ist jetzt auch mit tab & esc bedienbar
 - m-glob-con - konstanten für sound und plexbus eingefügt

reg-ios:
 - Testfunktion für RTC
 - LAN-Funktionen eingefügt
 - Plexbus Funktionen eingefügt
 - printblk - Stringausgabe mit Längenangabe

system/administra:
 - admnet eingefügt

system/regnatix:
 - fm - Optimierungen und Detailverbesserungen
 - perplex - Plexbus Tool zugefügt
 - regime - sysinfo zeigt jetzt auch Devices am Plexbus an
 - man - Systemklänge angepasst, damit nicht ständig der Heartbeat beim Lesen
   läuft
 - ramtest - Anpassungen Maske/Farben

Dokumentation:
 - Neustrukturierung der Texte



r56 - 11-05-2013-dr235
======================

und weiter gehts mit dem Frühjahresputz:
 - umstellung Administra-Codes (admflash, admay, admsid) auf externe
   Konstantendefinitionen

belflash:
 - fehler im loader behoben

lib:
 - gui-objekte für textoberfläche eingefügt:

   gui-dlbox     - Listenbox für Dateien
   gui-input     - einfaches eingabefenster
   gui-pbar      - Hinweisdialog mit Progress-Bar (z.Bsp. für Kopieraktionen)
   gui-wbox      - Warnbox mit Auswahloptionen

system/regnatix:
 - Filemanager fm zugefügt
 - Mental-Loader m zugefügt
 - Tool zum erstellen von tapes (mental-containerdateien) zugefügt
 - wplay: kleinen Darstellungsfehler behoben
 - yplay: Konstanten ausgelagert

system/sonstiges:
 - Manual zugefügt: error, fm



r55 - 15-04-2013-dr235
======================

fällige Aufräumarbeitem im Quelltext:
 - Umstellung Bildschirmcodes/g0-Treiber auf externe Konstantendefinitionen
 - Umstellung Signaldefinitionen für belflash/g0key
 - alle Funktionsnummern für bella werden nun in lib\glob-con.spin verwaltet
   und gepflegt
 - screeninit gibt jetzt keine Kopfzeile mehr aus, geht jetzt über
   Fensterfunktionen
 - Anpassung div. Tools 

system\regnatix\regime:
 - leere Eingaben werden jetzt ignoriert
 - mit der Cursortaste kann jetzt der letzte Befehl wiederholt werden



r54 - 15-04-2013-dr235:
=======================

flash\admflash.spin
 - grundlegende com-Funktionen eingefügt

lib\reg-ios.spin
 - com-funktionen
 - ios.screeninit: kein Logo im TV-Modus

system\administra\admay\admay.spin
 - sd_dmput eingefügt
 - sd_eof eingefügt

system\regnatix\admtest.spin
 - Korrektur bei fehlerhaftem Screeninit

system\regnatix\beltest.spin
 - Menü eingefügt um einzelnen Test auszuführen
 - Anpassung an TV-Modus
 - neuer Test für Fensterfunktionen

system\regnatix
 - Tool man eingefügt
 - Umstrukturierung aller Tool-Hilfen an man
 - Anpassung der meisten Tools an TV-Modus

system\sonstiges
- man-Hilfetexte eingefügt


r53 - 20.02.2013 dr235/u-held:
==============================

flash\admflash.spin
 - scr-Funktionen ausgefügt

flash\belflash.spin:
 - Fehler im Loader behoben (cog0 wurde nicht in allen Fällen beendet) Dank
   dafür geht an pic :)
 - Farbtabellen auf 16 Farben ergänzt, Normalfarbe ist jetzt mal retro-green :)

flash\regflash.spin:
 - Pause für Slaves zur Initialisierung eingefügt, damit diese bei
   Installation ohne forth sauber starten

forth\bel.lib:
 - Korrektur wort bel:load

forth\sd0.lib:
 - div. fehlerhafte Stackkommentare korrigiert

forth\tools.lib:
 - Korrektur wort bel:load

forth\g0.lib: zugefügt
forth\tpix.f: zugefügt
forth\win.lib: zugefügt

lib\reg-ios.spin:
 - Fehler in g0 printdec behoben
 - neue sidcog-Funktion: sid_dmpreg

system\administra\admsid\admsid.spin:
 - Funktion sid_dmpreg eingefügt (für Triborg-Player)
 - Funktion sd_dmput aus Maincode übernommen
 - Funktion sd_eof aus Maincode übernommen

system\regnatix\g0test.spin:
 - neue Tests & Effekte eingefügt

system\regnatix\sysconf.spin:
 - "sysconf /ci" zeigt nun alle 16 Farben an

system\sonstiges\green.col:
 - grüne Retro-Farbtabelle eingefügt


r52:
====

g0key.spin    - Bug bei horizontaler Textzentrierung beseitigt
belflash.spin - Interface VGA/TV vereinheitlicht, umschaltbar beim Compilieren
                (siehe make.bat)
belf-tv.spin  - treiberspezifische Konstanten und Funktionen für belflash.spin
belf-vga.spin - treiberspezifische Konstanten und Funktionen für belflash.spin
bel-bus.spin  - Auslagerung der Bus-Routinen aus Bellatrix-Sicht
beltest.spin  - Anpassung an belflash.spin, auch im TV-Modus nutzbar
make.bat      - tv.bel wird jetzt aus belflash.spin erzeugt; Einführung einer
                Variablen für den Compiler-Aufruf
reg-ios.spin -  hmm... habsch vergessen, was da geändert wurde :-(

r51:
====

belflash.spin:
- verzögertes Scrolling bei abgeschaltetem Cursor
- Window-Funktionen

glob-con.spin:
 - Auslagerung von globalen Konstanten (ansatzweise)

reg-ios.spin:
 - Einbindung der neuen Bellatrix-Funktionen

beltest.spin:
 - sline/eline-Test entfernt, Window-Test eingefügt



27.11.2011-dr235
================

 - bellatrix-code für Grafikmodus 0 + keyboard hinzugefügt
 - g0test - Testprogramm für g0-Modus hinzugefügt
 - reg-ios - g0-Funktionen eingearbeitet
 - make.bat angepasst


13.11.2011-dr235
================

- rtc-routinen neu eingefügt
- admterm entfernt, hat im trios keine funktion


11.11.2011-dr235
================

 - umfangreicher Umbau der Verzeichnisstruktur: alle universellen Quellen wie
   Treiber oder klassische Bibliotheken werden nun im Verzeichnis "lib"
   gespeichert und können so an einer Stelle gepflegt werden.
 - alle Anwendungen die nichts mit TriOS zu tun haben werden nun aus dem
   Projekt entfernt und in einer Toolbox-Serie veröffentlicht. damit wird TriOS
   stark entschlackt und wieder übersichtlich.
 - Überarbeitung der make.bat; es werden nun auch die alternativen Slave-Codes
   wie zum Beispiel admsid erstellt.
 - in der Standardkonfiguration ist jetzt Forth deaktiviert - das ist einfacher
   für den Einsteiger. Forth ist dann "level 2".

WICHTIG: im bst muß nun der Compiler-Suchpfad für TriOS auf das Verzeichnis
"lib" eingestellt werden.


09.11.2011-dr235
================

 - Fehler in regflash.spin behoben, Konfiguration ohne Forth konnte nicht
   compiliert werden
 - Standartkonfiguration ist jetzt ohne Forth, ist einfacher für den Einstieg
 - div. Demos entfernt, diese werden später getrennt in einer Toolbox-Serie
   veröffentlicht


06.11.2011-dr235
================

 - Fehlersuche zum Problem mit dem neuen Bella-Loader: einige bel-Dateien
   (guidemo, 4-boing) wurden nicht korrekt initialisiert, also starteten nicht
   sauber. Parameter und Ladevorgang ist korrekt, Ursache ist wahrscheinlich
   eine falsche Initialisierung der Stackwerte im PASM-Teil des Loaders. Als
   Lösung kann man diese bel-Dateien als eeprom-image abspeichern, diese
   starten korrekt.


23.04.2011-dr235
================

 - Integration von PropForth in TriOS


15-04-2011-dr235
================
 - flash-tool/rom: damit kann unter anderem eine bin-Datei (z. bsp. Basic) in
   den Hi-ROM (64k eeprom erforderlich!) gespeichert und mit rom gestartet
   werden
 - Übernahme der RTC-Routinen von Stephan
 - time-Kommando: Anzeige/Änderung Datum/Zeit
 - perplex: experimentelles Tool für plexbus (scan/open/close/get/put)
 - fterm: Primitiv-Terminal für Forth-HIVE


18-09-2010-dr235
================

 - regime: free zeigt jetzt auch die Speicherbelegung des eRAM an
 - Speicherverwaltung/RAMDisk integriert (Beispielcode siehe eram.spin &
   regime.spin)
 - eram.bin kann jetzt auch mit RAMDisk umgehen
 - regime: neue Kommandos für RAMDisk
 - Egalisierung der Namen für den RAM-Zugriff (älterer code muß leicht
   angepasst werden)
 - User- und Systemmode für RAM-Zugriff eingefügt
 - erste Version einer make-Batch um das gesamte System zu kompilieren
   (nur Grundsystem)
 - Änderung zur ios: da bst eine pfadliste zu bibliotheksordnern unterstützt,
   liegt (soweit das möglich ist) die ios nun nur noch unter system\regnatix

WICHTIG: Pfad zur ios.spin im BST einstellen


23-08-2010-dr040
================

 - Integration ay-emulator (admay.adm) und yplay


19-07-2010-dr235
================

 - Booten eines alternativen Administra-Codes: befindet sich auf der Karte in
   der root eine Datei "adm.sys", so wird diese Datei automatisch in Administra
   geladen


11-07-2010-dr235
================

 - Integration sid1/2-Funktionen in admsid/ios
 - Anpassung sid-Demo von ahle2 als Regnatix-Code (Verzeichnis demo)
 - diverse Graphics-Spielereien (Verzeichnis demo)
 - sysconf /af - Administra neu booten (admflash.adm wird dadurch überflüssig)


27-06-2010-dr085/235
====================

 - admin mountet nun automatisch nach einem boot


26-06-2010-dr235
================

 - div. Demos zugefügt
 - Shooter angepasst und eingefügt


20-06-2010-dr235
================

 - erste lauffähige SID-Player-Version für die Kommandozeile (splay)


14-06-2010-dr085/235
====================

 - Semaphoren in FATEngine korrekt eingesetzt
 - Abfrage des Volume-Labels korrigiert


10-06-2010-dr235
================

 - Kommando "ramtest" zugefügt


09-06-2010-dr085
================

 - Fehler in Administra-Bootfunktion behoben


-------------------------------------------------------------------------------

23-04-2011-dr235
================

Ein neuer Meilenstein: PropForth ist jetzt in TriOS integriert. Als Nebeneffekt
starten nun wieder, wie bei meiner ersten SpinOS-Version, alle drei Chips ihren
initialen Code aus ihrem EEPROM und nicht mehr vom SD-Laufwerk. Damit gibt es
vom Einschalten bis zum Forth-Prompt quasi keine fühlbare Bootzeit mehr. So
gehört es sich für einen richtigen Homecomputer. Es ist nun möglich, unmittelbar
nach dem Einschalten sofort zu programmieren. Erst wenn man zu Regime wechselt
wird kurz reg.sys nachgeladen. Aber selbst die Ladezeiten sind nun durch
Verwendung des SD-Blocktransfer erfreulich kurz.

Obwohl das Grundsystem vom Forth den halben hRAM belegt, ist es als genormte
Sprache doch eine wunderbare Geschichte im Hive. Viele der Ressourcen sind jetzt
schon problemlos in Forth nutzbar und man kann sehr unkompliziert
experimentieren.


02-10-2010-dr235
================

Speicherverwaltung:
In dieser Version ist eine erste Beta-Version der Speicherverwaltung des
externen RAM's enthalten. Der Speicher kann dabei in einem einfachen oder
einem strukturierten Modus verwendet werden. Klingt kompliziert, ist aber
ganz einfach.

Einfacher Modus:
Hierbei kann ein Programm auf den eRAM über die IOS-Routinen ios.ram_*
zugreifen. Wahlweise kann der Speicher im Systemmode direkt von 0 bis
$07FFFF angesprochen werden, oder nur der Userbereich. Im Systemmodus ist
darauf zu achten, dass eine eventuell vorhandene Ramdisk und die
Systemvariablen nicht überschrieben werden, man sollte also wissen was man
tut... ;) Die Ramdisk wird ab der physischen Adresse 0 als verkettete Liste
verwaltet, die Systemvariablen befinden sich ab $07FFFF abwärts.

ios.ram_wrbyte(ios#sysmod,0,ios#MAGIC)
 - Schreibt den Wert 0 in die Systemvariable, um einen Kaltstart auszulösen.

ios.ram_wrbyte(ios#sysmod,$20,$100)
 - Schreibt den Wert $20 an die physische Adresse $100 im eRAM.

Da es nun mühsam ist in einem kleinen Code solche Konflikte mit dem
Systemspeicher zu vermeiden, gibt es den Usermodus.  Im Usermodus wird nur
genau jener freie Speicher adressiert, welcher sich zwischen Ramdisk und
Systemvariablen befindet. In diesem Fall ist die Adressierung also
virtualisiert.

ios.ram_wrbyte(ios#usrmod,0,$100)
 - Schreibt den Wert 0 an die Adresse $100 im Userspeicher!

In Regime kann man mit dem Kommando "free" jetzt auch die wichtigsten
Systemvariablen der Speicherverwaltung anzeigen.

RBAS
 - erste physische Adresse des Userspeichers

REND
 - Physische Adresse der letzten freien Speicherstelle des Userspeichers.

USER
 - Grösse des Userspeichers (REND - RBAS).

RAMDRV
 0 - Ramdisk ist nicht initialisiert
 1 - Ramdisk ist initialisiert

SYSVAR
 - Erste physische Adresse der Systemvariablen.

Noch genauer kann man sich die Speicherbelegung mit dem Tool "eram" anschauen.
Nur ein paar Beispiele:

"d" Anzeige des Speichers. Es werden zwei Adressspalten angezeigt. Die zweite
    schwarze Adresse in jeder Zeile zeigt die physische Adresse, die erste
    grüne Adresse die virtuelle Adresse im Userspeicher. Man kann sehr gut
    erkennen, ab welcher Adrese der Userbereich anfängt und wo er endet.

"d 100" Anzeige ab physischer Adresse $100

"d bas" Anzeige vom Start des Userspeichers.

"n" Anzeige inkrementell fortsetzen

Die Nutzung des Userspeichers ist sehr einfach. Es sind dabei nur folgende
Regeln zu beachten:

Man muss selbst darauf achten die Speichergrenzen nicht zu überschreiten. Bei
Überschreitung kann aber nichts passieren - die IOS-Routinen brechen einfach
ab, allerdings werden die eigenen Daten halt nicht korrekt verarbeitet. Es
werden also die Systemvariablen und die Daten in der Ramdisk geschützt.

Der Userbereich im eRAM ist nur zur Laufzeit der Anwendung gültig. Wird die
Anwendung beendet, so kann durch Regime oder eine andere Anwendung mit den
Daten der Ramdisk gearbeitet werden, wodurch sich der physische Bereich des
Userbereiches verändert. Wer also residente Daten über die Laufzeit der
Anwendung hinaus braucht, muss im strukturierten Modus mit der Ramdisk
arbeiten. In einer Anwendung nicht den einfachen oder strukturierten Modus
mischen - das gibt Chaos, wenn man nicht ganz genau aufpasst

Ansonsten kann man wie gehabt die schon bekannten IOS-Routinen verwenden,
einzig der Übergabeparameter zur Wahl des System- oder Usermodus sind
hinzugekommen. Als Beispiel kann man sich die Soundplayer anschauen, die ihre
Dateiliste im Userspeicher ablegen.

Strukturierter Modus:
Was ist aber, wenn wir einen kleinen Texteditor schreiben wollen, der seine
Textdaten resident im eRAM speichern kann? Ich möchte also den Texteditor
verlassen können, um in Regime zum Beispiel einen Assembler aufzurufen, welcher
den Text dann assembliert.  Darauf folgend möchte ich meinen Texteditor wieder
starten und an dem Text weiter arbeiten. Dafür muss es meiner Anwendung - dem
Textprogramm - möglich sein, einen Speicherbereich im eRAM zu reservieren, der
von System und anderen Anwendungen respektvoll behandelt wird.

Gedacht, getan: Im strukturierten Modus wird der Speicher in Form einer Ramdisk
verwaltet. Die Dateien/Daten können über ihren Namen angesprochen werden. Es
kann mit put & get sequentiell, oder mit read & write direkt adressierbar auf
die Daten in der Datei zugegriffen werden.

Als erstes praktisches Beispiel mögen die neuen Kommandos in Regime selbst
dienen, mit denen man die Ramdisk verwalten kann:

Neue Regime-Kommandos:

xload <sd:fn>           - Datei in RAM laden
xsave <x:fn>            - Datei aus RAM speichern
xdir                    - Verzeichnis im RAM anzeigen
xrename <x:fn1> <x:fn2> - Datei im RAM umbenennen
xdel <x:fn>             - Datei im RAM löschen
xtype <x:fn>            - Text im RAM anzeigen

So ist es also möglich, sich in der Kommandozeile anzuschauen, welche
residenten Daten die Programme aktuell angelegt haben. Sofern es Textdaten
sind, können diese Daten auch einfach angezeigt werden.

Die Speicherverwaltung ist allerdings noch sehr experimentell - was bedeutet,
dass wohl noch einige Bugs drin sein dürften. :)


MAKE.BAT

Diese Batchdatei im obersten Verzeichnis kompiliert das Grundsystem, bestehend
aus den drei Flashdateien und den grundlegenden Kommandos im Systemverzeichnis.
Ist ein erster Versuch. Was noch fehlt ist ein Fehlerlog und vielleicht noch
die anderen Programme.


09-06-2010-dr235
================
Nach nur zwei Tagen hat drohne085 (frida) das Geheimnis um die Bootroutine
gelöst: Die Ursache lag in einer von der FATEngine verwendeten Semaphore,
welche fest auf den Lock 0 "verdrahtet" war. Diese Semaphore wird an diversen
Stellen in der Engine verwendet, wurde aber beim Bootvorgang nicht gelöscht
oder freigegeben! Gedacht war sie, um den Bus zur SD-Card bei einem Zugriff zu
verriegeln, falls mehrere Instanzen der Engine laufen, und gleichzeitig
zugreifen wollen. Somit hat sich die Engine quasi selbst verriegelt und nach
dem Bootvorgang als "neue Instanz" nun auch keinen Zugriff mehr - so schön kann
praktische Parallelverarbeitung sein... ;)

Hier nun eine neue und aktuelle Version mit einer temporären funktionierenden
Lösung des Problems.

Im System-Ordner gibt es jetzt folgende ausführbare Administra-Dateien:

admflash.adm    Standard-Flash, welches auch im EEProm gespeichert ist
admini.adm      Mini-Flash ohne Sound, nor SDCard + Managment-Routinen
admled.adm      Das Heartbeat-LED-Testprogramm zum direkten laden
aterm96.adm     Die leicht modifizierte Kommandozeile vom Programmierer der
                FATEngine. Mit diesem Administra-Code kann man direkt über die
                Hostschnittstelle (9600 Baud) mit dem Chip kommunizieren.
                Dokumentation der Kommandos findet man im Verzeichnis 
                "komponenten/fat/fatengine beta"


07-06-2010-dr235
================

Hier der aktuelle Stand von TriOS. Momentan kämpfe ich an einem 
Komplexfehler mit dem Bootloader von Administra. Das Problem ist recht 
einfach zu reproduzieren, aber leider (für mich) nur schwer zu
erfasen: Die verwendete FATEngine besitzt eine Bootfunktion um einen
neuen BIN-Objektcode in den Propeller zu laden. Dieser Code funktioniert 
auch teilweise. So kann man das Administra-Bios selbst laden und dann
auch per Regime-Kommandos verwenden: Die Kommandos "cogs" und "sysinfo"
sprechen Administra-Funktionen an, welche auch korrekt ausgeführt werden.
Das Problem: Nach dem Bootprozess kann man keine SD-Card mehr mounten.

Es ist auch möglich den Fehler noch weiter einzugrenzen: Wenn man die 
originale FATEngine (im Verzeichnis komponenten/fat) vom Host direkt in  
Administra startet, meldet sich diese in Form einer einfachen Kommando-
zeile per Hostschnittstelle. Versucht man dort eine erzeugte BIN-Datei
genau dieser Kommandozeile (demo.spin) zu booten, so hat man das gleiche
Ergebnis.

Verzeichnisstruktur:

bin             - BIN-Dateien für die Flash's und die SD-Card
doku            - 
flash           - Quelltexte für die Software in den EEProms
system          - Quelltext für ausführbare BIN-Dateien
zubehör         - Kleine Zusatzprogramme (StarTracker, Boulder Dash...)
komponenten     - Div. verwendete Objekte (FATEngine, SIDCog...)

Installation:

1. Flashen der drei EEProms mit den BIN-Dateien aus  "bin/flash" oder
   über das Propellertool aus den Quellen "flash".

2. SD-Card erstellen: Einfach alles aus "bin/sd-card" auf eine FAT16/32
   Karte kopieren.

Das System bootet Regnatix und Bellatrix beim Systemstart aus den Dateien
"adm.sys", "reg.sys" bzw. "bel.sys". Diese Dateien können auch das Hidden-
Bit gesetzt haben. Externe Kommandos bzw. ausführbare BIN-Dateien werden
im aktuellen UND im System-Verzeichnis gesucht - alle Systemkommandos
können also in das System-Verzeichnis kopiert werden.

Hilfe gibt es meist über das Kommando "help" oder den Parameter "/h".
