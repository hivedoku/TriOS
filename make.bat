echo on
date /T
time /T

REM # Definitionen
REM set D="-D __DEBUG -D __LANG_EN"
REM set D="-D __LANG_EN"
set D="-D __LANG_DE"


REM # Pfade
set bin="..\Bin"
REM bin="\home\ftp\hive"
set sd="%bin%\sdcard"
set sdsys="%sd%\system"
set flash="%bin%\flash"
set libpath="lib"
set BSTC=bstc.exe

REM ----------------------------------------------------------------
REM Alte Versionen löschen

rmdir %bin% /S /Q
mkdir %sdsys%
mkdir %flash%

REM ----------------------------------------------------------------
REM Flashdateien erzeugen
REM --> \bin\flash

%BSTC% -L %libpath% %D% -D __ADM_FAT -D __ADM_HSS -D __ADM_HSS_PLAY -D __ADM_WAV -D __ADM_RTC -D __ADM_COM -D __ADM_PLX -b -O a .\flash\administra\admflash.spin
copy admflash.binary %flash%
move admflash.binary %sdsys%\admsys.adm

%BSTC% -L %libpath% %D% -D __VGA -b -O a .\flash\bellatrix\belflash.spin
copy belflash.binary %flash%
move belflash.binary %sdsys%\vga.bel

%BSTC% -L %libpath% %D% -D __TV -b -O a .\flash\bellatrix\belflash.spin
move belflash.binary %sdsys%\tv.bel

%BSTC% -L %libpath% %D% -D regime -b -O a .\flash\regnatix\regflash.spin
move regflash.binary %flash%

%BSTC% -L %libpath% %D% -D forth -b -O a .\flash\regnatix\regflash.spin
move regflash.binary %flash%\regforth.binary

REM ----------------------------------------------------------------
REM Startdateie erzeugen
REM reg.sys	(Regime)
REM --> \bin\sdcard\

%BSTC% -L %libpath% %D% -b -O a .\system\regnatix\regime.spin 
move regime.binary %sd%\reg.sys


REM ----------------------------------------------------------------
REM Slave-Dateien erzeugen
REM admsid, admay, admterm
REM htxt, g0key

%BSTC% -L %libpath% %D% -D __ADM_FAT -D __ADM_SID -b -O a .\flash\administra\admflash.spin
move admflash.binary %sdsys%\admsid.adm
%BSTC% -L %libpath% %D% -D __ADM_FAT -D __ADM_AYS -b -O a .\flash\administra\admflash.spin
move admflash.binary %sdsys%\admay.adm
%BSTC% -L %libpath% %D% -D __ADM_FAT -D __ADM_HSS -D __ADM_LAN -D __ADM_RTC -D __ADM_COM -b -O a .\flash\administra\admflash.spin
move admflash.binary %sdsys%\admnet.adm

%BSTC% -L %libpath% %D% -b -O a .\system\bellatrix\bel-htext\htext.spin
move htext.binary %sdsys%\htext.bel
%BSTC% -L %libpath% %D% -b -O a .\system\bellatrix\bel-g0\g0key.spin
move g0key.binary %sdsys%\g0key.bel

REM ----------------------------------------------------------------
REM Systemdateien erzeugen
REM - div. externe Kommandos
REM - div. Systemdateien (Farbtabellen usw.)
REM --> \bin\sdcard\system\

for %%x in (.\system\regnatix\*.spin) do %BSTC% -L %libpath% %D% -b -O a %%x 
rename *.binary *.bin
move *.bin %sdsys% 
copy .\forth\*.* %sdsys%
copy .\system\sonstiges %sdsys%

echo off
