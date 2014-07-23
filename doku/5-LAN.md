################
# TriOS Netzwerk
################

Einleitung
==========

Diese Version von TriOS beinhaltet eine Implementierung von Netzwerk-
Funktionen. Als erste Anwendungen sind enthalten:
 - Ein FTP-Client, welcher Dateien von einem FTP-Server downloaden und in der
   RAM-Disk im eRAM oder auf SD-Card abspeichern kann.
 - Ein vollständiger IRC-Client
 - Die DEmo-Version eines Webservers
Zukünftige Erweiterungen, wie die Integration in Regime und direktes Starten
von Programmen aus dem Netzwerk sind geplant.


Implementierung
===============

Beim Compilieren mit make.bat/make.sh wird ein Administra-Code erstellt,
welcher direkt geflasht werden kann oder zur Laufzeit geladen wird
(admnet.bin). Grundlage ist eine Erweiterung um die unveränderten Netzwerk-
Treiber von Harrison Pham.

Für die Kommunikation über den Hive-Bus wurden die wesentlichen Funktionen
des Netzwerk-Treibers zur Verfügung gestellt. Die Implementierung weiterer
Funktionen des Original-Treibers ist bei Bedarf möglich.

Die IP-Konfiguration des Hive wird im NVRAM des RTC gespeichert. Das hat
den Vorteil, daß der Hive zukünftig auch ganz ohne SD-Card arbeiten kann,
also quasi aus dem Netzwerk bootet. Ist kein RTC vorhanden (wird automatisch
erkannt), erfolgt das Speichern der Konfiguration auf der SD-Card unter
/system/nvram.sav.


Nutzung
=======

Allgemeines
-----------

Der Netzwerk-Stack in Administra wird erst gestartet, wenn er benötigt wird.
Auch danach sollte man sich nicht wundern, daß der Hive nicht per Ping
angesprochen werden kann: Aus Platzgründen enthält der Netzwerk-Stack keinen
ICMP-Code. Dieser könnte auf Wunsch aber recht einfach hinzugefügt werden.


Administra
----------

Voraussetzung ist, daß Administra mit dem Netzwerk-Code läuft. Das geschieht
entweder durch direktes Flashen von admnet.bin oder durch Eingabe von
"admnet" am Regime-Prompt.


IP-Konfiguration
----------------

Mittels "ipconfig" wird die IP-Konfiguration im NVRAM oder als Datei abgelegt.
Folgende Parameter kennt ipconfig:

  /?           : Hilfe
  /l           : Konfiguration anzeigen
  /a <a.b.c.d> : IP-Adresse setzen
  /m <x.x.x.x> : Netzwerk-Maske setzen
  /g <e.f.g.h> : Gateway setzen
  /d <i.j.k.l> : DNS-Server setzen
  /b <m.n.o.p> : Boot-Server setzen
  /i <Id>      : Hive-Id setzen

Aus der Hive-Id wird eine eindeutige Mac-Adresse erzeugt.
DNS-Abfragen werden noch nicht unterstützt, deswegen muß man den DNS-Server
nicht konfigurieren. Der Boot-Server wird derzeit vom FTP-Client als Default-
Server genutzt (s.u.).


FTP-Client
----------

Der FTP-Client ist aktuell eine sehr einfache Implementierung und dient primär
zum Testen der Funktion des Netzwerk-Stacks.

Der Download funktioniert nur, wenn der FTP-Server das Kommando "SIZE"
versteht. Obwohl das kein Standard-Kommando ist, wird es von den meisten
FTP-Servern unterstützt. Außerdem wird nur passives FTP verwendet.

Folgende Parameter kennt der FTP-Client:

  /h <a.b.c.d>    : FTP-Server-Adresse (Host)
                    (default: mit ipconfig gesetzter Boot-Server)
  /d <verzeichnis>: in entferntes Verzeichnis wechseln
                    (default: /hive/sdcard/system)
  /f <dateiname>  : Download <dateiname> (/f optional)
  /u <username>   : Benutzername am FTP-Server
                    (default: anonymous)
  /p <password>   : Paßwort am FTP-Server
                    (default: anonymous@hive<Hive-Id>)
  /s              : Datei auf SD-Card speichern

Dabei ist zu beachten, daß auf Grund der fehlenden Namensauflösung die IP-
Adresse und nicht der Host-Name des Servers angegeben wird. Weitere
Einschränkungen ergeben sich durch die maximale Parameter-Länge von 64
Zeichen in Regime und maximal 12 Zeichen lange Dateinamen in der RAM-Disk.

Ein Beispiel:
Zum Download von ftp://1.2.3.4/verzeichnis/unterverzeichnis/datei.txt
verwendet man folgende Befehlszeile:

  ftp /h 1.2.3.4 /d /verzeichnis/unterverzeichnis /f datei.txt

Dabei erfolgt die Anmeldung wegen der fehlenden Parameter /u und /p als
"anonymous" mit dem Paßwort "anonymous@hivexxx" (xxx: mit ipconfig gesetzte
Hive-Id). Die Datei wird in der RAM-Disk gespeichert (s. Kommando "xdir")
und könnte mittels "xsave" auf SD-Card gespeichert werden.

Mit Nutzung aller Default-Werte genügt die Eingabe des folgenden Befehls:

  ftp /s ipconfig.bin

Damit wird die Datei "ipconfig.bin" vom FTP-Server mit der IP-Adresse
des mittels "ipconfig" konfigurierten Boot-Servers aus dem Verzeichnis
"/hive/sdcard/system" geladen und im aktuellen Verzeichnis auf der SD-Card
abgespeichert. Von dort könnte sie direkt gestartet werden.

IRC-Client
----------

siehe [6-IRC-CLIENT.md]

Webserver
---------

Der Webserver wird aus Regime ohne Parameter gestartet:

  websrv

Damit ist der Hive mittels Browser unter seiter mittels ipconfig eingestellten
Adresse erreichbar. Zur Demonstration wird die Hive-Id und eine sich ständig
ändernde Zufallszahl angezeigt.


Schlußbemerkung
===============

Fragen können im Hive-Forum (http://hive-project.de/board/) gestellt werden
oder direkt an joergd@bitquell.de


Viel Spaß - Jörg
