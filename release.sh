#! /bin/sh

# Definitionen
VERSION="57"

# Pfade
ARCHIV="HIVE-TriOS-R${VERSION}"
MAKE="./make.sh"
BIN="Bin"

# ----------------------------------------------------------------
# Alte Versionen löschen

rm -rf ../${BIN}
rm -f "../${ARCHIV}-bin.zip"
rm -f "../${ARCHIV}-src.zip"

# ----------------------------------------------------------------
# Binaries erstellen

${MAKE}

# ----------------------------------------------------------------
# Archive erstellen

mkdir .tmp
for file in *.md ; do cp "$file" .tmp/"${file/.md}".txt ; done
cd .tmp
zip -r9 ../../${ARCHIV}-bin.zip *
zip -r9 ../../${ARCHIV}-src.zip *
cd ..
rm -rf .tmp

zip -r9 ../${ARCHIV}-src.zip flash forth lib system make*

cd ..
zip -r9 ${ARCHIV}-bin.zip ${BIN}
