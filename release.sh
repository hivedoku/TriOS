#! /bin/sh

# Definitionen
VERSION="57-Network-1.5"

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

mkdir -p .tmp/doku
for file in *.md ; do cp "$file" .tmp/"${file/.md}".txt ; done
for file in doku/*.md ; do cp "$file" .tmp/"${file/.md}".txt ; done
cd .tmp
zip -r9 ../../${ARCHIV}-bin.zip *
zip -r9 ../../${ARCHIV}-src.zip *
cd ..
rm -rf .tmp

zip -r9 ../${ARCHIV}-src.zip flash forth lib system make*

cd ..
zip -r9 ${ARCHIV}-bin.zip ${BIN}
