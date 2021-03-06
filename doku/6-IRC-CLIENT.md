
                                 IRC

                       IRC-Client für den Hive

              Author: Jörg Deckert (joergd@bitquell.de)

===============================================================================


Einleitung
==========

Dies ist ein IRC-Client für den Hive (http://hive-project.de). Er sollte auf
jedem Hive mit bestücktem Netzwerk-Interface funktionieren.

Die Idee des IRC-Clients stammt von PropIRC, einem Projekt von Harrison Pham,
welches aus einer Propeller-basierten Hardware ausschließlich für diesen Zweck
besteht (http://classic.parallax.com/tabid/701/Default.aspx). Der Administra-
Netzwerk-Stack nutzt darüber hinaus die Treiber von Harrison Pham.

Der vorliegende IRC-Client hat mit PropIRC ansonsten nicht viel gemein, sondern
stellt einen ausgewachsenen IRC-Client mit den meisten der üblichen
Funktionalitäten dar.


Installation
============

Der Hive IRC-Client ist Bestandteil von TriOS und wird bei dessen Installation
ins System-Verzeichnis der SD-Karte installiert.


Empfohlener Server
==================

Auf German-Elite existiert ein IRC-Channel für den Hive. Dieser kann wie folgt
erreicht werden:

  IRC-Server (Hostname:Port):   irc.german-elite.net:6667
  nutzbarer Channel:            #hive


Nutzung
=======

Start
-----

Der IRC-Client benötigt den Netzwerk-Code in Administra. Dieser kann direkt in
Administra geflasht oder durch Eingabe von "admnet" geladen werden. Beim Start
prüft der IRC-Client das Vorhandensein der Netzwerk-Funktionalitäten. Sind
diese nicht vorhanden, wird automatisch versucht, "/system/admnet.adm" von der
SD-Card zu laden.

Außerdem muß der Hive natürlich an ein Netzwerk mit Internet-Verbindung
angeschlossen sein und mittels "ipconfig" entsprechend konfiguriert werden.

Der Start erfolgt dann einfach durch Eingabe von "irc" am Regime-Prompt. Beim
ersten Start wird automatisch die Konfiguration aufgerufen. Nach Eingabe der
erforderlichen Parameter (s.u.) werden diese gespeichert. Nun kann mittels
Drücken von "F3" die Verbindung zum Server aufgebaut werden.


Bedienung
---------

Der IRC-Client besteht aus 3 Fenstern. Im großen oberen werden die Chat-
Mitteilungen ausgegeben. Im mittleren erscheinen verschiedene Statusmeldungen.
Im untersten Fenster werden die Mitteilungen und Befehle eingegeben.

Das aktive Fenster wird jeweils hervorgehoben und kann mittels Tabulator-Taste
umgeschalten werden. Im aktiven Fenster kann mittels Cursor hoch/runter
gescrollt werden (außer im Eingabefenster).

Die Bedienung erfolgt durch Betätigung der Funktionstasten oder die Eingabe
von Befehlen im EingabeFenster (s.u.). Alle Befehle beginnen mit einem
Schrägstrich (/).

Beim Erscheinen einer neuen Mitteilung im aktuellen Kanal blinkt die Regnatix-
LED so lange, bis eine beliebige Taste gedrückt wird. Außerdem wird ein Sound
abgespielt.


Befehlsübersicht
----------------

  Funktionstaste Eingabe 
  --------------+-------+-------------------------------------------------
  F1                     Hilfe
  F2             /set    Alle Einstellungen bearbeiten und abspeichern
  F3                     Mit Server verbinden, anmelden und Kanal betreten
  F4             /join   Kanal betreten (/join #<Kanal>)
  F5             /part   Aktuellen Kanal verlassen (/part <Mitteilung>)
  F6             /nick   Nicknamen ändern (/nick <neuer Nick>)
  F7             /user   Username ändern
  F8             /pass   Paßwort ändern
  F9             /quit   Verbindung zu Server trennen
  F10                    Programm beenden
                 /msg    Private Mitteilung (/msg <Empfänger> <Text>)
                 /me     eigenen Status/Aktion senden (/me <Aktion>)
                 /ctcp   Client-to-Client (/ctcp <Empfänger> <Kommando>)
                 /srv    Mit Server verbinden und anmelden (srv <IP:Port>)
                 /save   Einstellungen speichern
  Tab                    Fenster umschalten, Scrollen mit Cursor hoch/runter

Alle anderen mit '/' beginnenden Eingaben sind Befehle an den Server. Alle
Eingaben, welche nicht mit '/' beginnen, sind eine öffentliche Mitteilung an
den aktuellen Kanal.


Einstellungen
-------------

Durch Drücken von "F2" oder Eingabe von "/set" werden alle notwendigen
Einstellungen (Server, Paßwort, Nickname, Username, Channel) abgefragt und
gespeichert. Zur Erstkonfiguration sollten in jedem Fall alle Parameter
mittels "F2" oder "/set" gesetzt werden.

Die Einstellungen sind auch einzeln über die in der Befehls-Übersicht
angegebenen Funktionstasten bzw. Befehle erreichbar. Mittel Eingabe
über Befehle kann die gewünschte Einstellung meist auch als Parameter
mitgegeben werden. Im Gegensatz zu "F2" bzw. "/set" werden hier teilweise
auch gleich online die entsprechenden Änderungen vorgenommen ("F6" bzw. "/nick"
ändert z.B. sofort den aktuellen Nicknamen).

Da der Hive derzeit keine Namensauflösung unterstützt, muß der Server mit IP-
Adresse und Port angegeben werden. Die IP-Adresse kann an einem PC mittels
Ping oder NSLookup ermittelt werden, der Port ist meist 6667.

Der Nickname ist der Name, unter welchem man aktuell seine Mitteilungen
schreibt. Dieser kann jederzeit geändert werden. Demgegenüber ist der Username
der Name, mit welchem man sich beim Server anmeldet. Dessen Änderung wirkt sich
nur bei einer erneuten Anmeldung aus. Nickname und Username können auch
identisch sein.

Bei der Anmeldung am Server wird auch ein vollständiger Name übertragen. Da es
unüblich ist, hier seinen richtigen Namen anzugeben, wird stattdessen ein Name
in der Form "Hive #<HiveId>" generiert. <HiveId> ist der mittels "ipconfig /i"
definierte Wert.

TODO
====

- Support für mehrere gleichzeitige Channel
