#! /bin/sh

# Definitionen
##D="-D __DEBUG -D __LANG_EN"
##D="-D __LANG_EN"
D="-D __LANG_DE"

# Pfade
##bin="../Bin"
bin="/home/ftp/hive"
sd="${bin}/sdcard"
sdsys="${bin}/sdcard/system"
flash="${bin}/flash"
libpath="lib"
BSTC="bstc"

# ----------------------------------------------------------------
# Alte Versionen löschen

rm -rf ${bin}
mkdir -p ${sdsys}
mkdir ${flash}

# ----------------------------------------------------------------
# Flashdateien erzeugen
# --> bin/flash

${BSTC} -L ${libpath} ${D} -D __ADM_FAT -D __ADM_HSS -D __ADM_HSS_PLAY -D __ADM_WAV -D __ADM_RTC -D __ADM_COM -b -O a flash/administra/admflash.spin
cp admflash.binary ${flash}
mv admflash.binary ${sdsys}/admsys.adm

${BSTC} -L ${libpath} ${D} -D __VGA -b -O a flash/bellatrix/belflash.spin
cp belflash.binary ${flash}
mv belflash.binary ${sdsys}/vga.bel

${BSTC} -L ${libpath} ${D} -D __TV -b -O a flash/bellatrix/belflash.spin
mv belflash.binary ${sdsys}/tv.bel

${BSTC} -L ${libpath} ${D} -b -O a flash/regnatix/regflash.spin
mv regflash.binary ${flash}

# ----------------------------------------------------------------
# Startdateie erzeugen
# reg.sys	(Regime)
# --> bin/sdcard\

${BSTC} -L ${libpath} ${D} -b -O a system/regnatix/regime.spin
mv regime.binary ${sd}/reg.sys

# ----------------------------------------------------------------
# Slave-Dateien erzeugen
# admsid, admay, admnet
# htxt, g0key

${BSTC} -L ${libpath} ${D} -D __ADM_FAT -D __ADM_SID -b -O a flash/administra/admflash.spin
mv admflash.binary ${sdsys}/admsid.adm
${BSTC} -L ${libpath} ${D} -D __ADM_FAT -D __ADM_AYS -b -O a flash/administra/admflash.spin
mv admflash.binary ${sdsys}/admay.adm
${BSTC} -L ${libpath} ${D} -D __ADM_FAT -D __ADM_HSS -D __ADM_LAN -D __ADM_RTC -D __ADM_COM -b -O a flash/administra/admflash.spin
mv admflash.binary ${sdsys}/admnet.adm

${BSTC} -L ${libpath} ${D} -b -O a system/bellatrix/bel-htext/htext.spin
mv htext.binary ${sdsys}/htext.bel
${BSTC} -L ${libpath} ${D} -b -O a system/bellatrix/bel-g0/g0key.spin
mv g0key.binary ${sdsys}/g0key.bel

# ----------------------------------------------------------------
# Systemdateien erzeugen
# - div. externe Kommandos
# - div. Systemdateien (Farbtabellen usw.)
# --> bin/sdcard/system/

for FILE in system/regnatix/*.spin ; do 
    ${BSTC} -L ${libpath} ${D} -b -O a ${FILE}
    BASE="`basename ${FILE} .spin`"
    mv "${BASE}.binary" "${sdsys}/${BASE}.bin"
done
cp forth/* ${sdsys}
cp system/sonstiges/* ${sdsys}
