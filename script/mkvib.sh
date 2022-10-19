#!/bin/bash

PAYLOAD="${1}"
VERSION="${2}"
TARDISK="${3}"
TEMPLATE="${4}"

cd "${PAYLOAD}"
rm -f "${TARDISK}" sig.pkcs7 descriptor.xml *.vib

FILES="$(find * -type f | xargs -L 1 printf "<file>%s</file>")"

tar -cf - * | gzip -9 > "${TARDISK}"

SHA256="$(sha256sum -b "${TARDISK}" | cut -d' ' -f1)"
SHAGZ1="$(gzip -dc "${TARDISK}" | sha1sum -b | cut -d' ' -f1)"
SHAGZ256="$(gzip -dc "${TARDISK}" | sha256sum -b | cut -d' ' -f1)"
SIZE="$(wc -c "${TARDISK}" | cut -d' ' -f1)"
HARD="$(uname -i)"

TIMESTAMP="$(date +"%Y-%m-%dT%H:%M:%S.%6N%:z")"

sed -e "s!@VERSION@!${VERSION}!" \
    -e "s!@TIMESTAMP@!${TIMESTAMP}!" \
    -e "s!@SHAGZ1@!${SHAGZ1}!" \
    -e "s!@SHAGZ256@!${SHAGZ256}!" \
    -e "s!@SHA256@!${SHA256}!" \
    -e "s!@SIZE@!${SIZE}!" \
    -e "s!@FILES@!${FILES}!" "${TEMPLATE}" > "${PAYLOAD}/descriptor.xml"

touch sig.pkcs7

ar -qc "${TARDISK}-${VERSION}.${HARD}.vib" descriptor.xml sig.pkcs7 "${TARDISK}"
