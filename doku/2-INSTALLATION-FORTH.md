Installation mit FORTH
======================

Grundinstallation:
------------------

1. Mikrocontroller flashen:

\flash\administra\admflash.spin --> Administra
\flash\bellatrix\belflash.spin  --> Bellatrix
\flash\regnatix\regforth.spin   --> Regnatix

2. Der Schalter bleibt ab jetzt auf Regnatix stehen. Ein Terminalprogramm (ich
   verwende Tera Term) starten und 57600 Baud auf die Schnittstelle vom Hive
   (DIP steht auf Regnatix!) einstellen. Nach einem Reset meldet sich das
   Propforth im Terminalprogramm auf dem Hostcomputer. Datei "forth\basics.mod"
   in einem Editor öffnen, alles markieren, kopieren und im Terminal einfügen.
   Der Quelltext wird jetzt im Forth compiliert. Sind alle Erweiterungen
   compiliert, wird automatisch das Forth in den Flash geschrieben.

Nach einem automatischen Reset sollte sich das Forth jetzt komplett mit seinem
Prompt sowohl auf dem angeschlossenen VGA-Monitor, als auch im Terminal melden.
Im Prinzip benötigen wir nun das Terminalprogramm nicht mehr und können direkt
am Hive arbeiten. Später, wenn man in Forth programmiert, ist die vorhandene
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
