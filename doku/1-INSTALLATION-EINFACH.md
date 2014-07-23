Installation einfach (ohne FORTH)
=================================

Mikrocontroller flashen:
------------------------

\flash\administra\admflash.spin --> Administra
\flash\bellatrix\belflash.spin  --> Bellatrix
\flash\regnatix\regflash.spin   --> Regnatix



Erstellen der SDCard:
---------------------

Im Prinzip kann jede normale FAT16/32 Karte verwendet werden. Lange Dateinamen
werden nicht verwendet, Unterverzeichnisse sind kein Problem. Es ist sinnvoll,
alle Dateien aus dem Verzeichnis "bin\sd-card\" auf die SD-Karte zu kopieren.

Das Verzeichnis "system" hat eine besondere Bedeutung: Hier sollten sich die
Tools, Erweiterungen und Bibliotheken befinden.



Systemstart:
------------

Aus dem EEPROM wird der Loader gestartet und sofort die Kommandozeile "Regime"
aus der Datei reg.sys ausgeführt.
