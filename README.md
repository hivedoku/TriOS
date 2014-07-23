HIVE TriOS
==========

Beschreibung
------------

TriOS ist ein in SPIN geschriebenes Betriebssystem für den HIVE Computer.
Für weitere Informationen wird auf die Webseite des Projektes verwiesen:
http://hive-project.de



Installations-Varianten
-----------------------

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

Genaue Installation-Anleitungen und Einführungen befinden sich im Verzeichnis
"doku".
