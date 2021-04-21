#!/bin/bash

TMP_METADATA="tmp/metadata"
TMP_BUNDLE="tmp/bundle"

function replaceKeywords
{
    typeset TEMPLATE="${1}"
        
    sed -e "s!@VERSION@!${VERSION}!g" \
        -e "s!@TIMESTAMP@!${TIMESTAMP}!g" \
        -e "s!@SHA256@!${SHA256}!g" \
        -e "s!@NAME@!${NAME}!g" \
        -e "s!@SIZE@!${SIZE}!g" \
        -e "s!@LCNAME@!${LCNAME}!g" \
        -e "s!@SIZE@!${SIZE}!g" \
        -e "s!@DATE@!${DATE}!g" \
        -e "s!@VENDOR@!${VENDOR}!g" \
        -e "s!@VENDORCODE@!${VENDORCODE}!g" \
        -e "s!@VIBNAME@!${VIBNAME}!g" "${TEMPLATE}"
}

NAME="${1}"
VERSION="${2}"
VIBFILE="${3}"
VIBFILE="$(readlink -m ${VIBFILE})"
VENDOR=Margar
VENDORCODE=margar

DATADIR="$(readlink -m data)"

# Lowercase version of the name
LCNAME="$(echo ${NAME} | tr '[:upper:]' '[:lower:]')"

# Current time
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%S.000000")"
DATE="$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")"

# ViB size and checksum
VIBNAME="${VIBFILE##*/}"
SIZE="$(wc -c "${VIBFILE}" | awk '{print $1}')"
SHA256="$(sha256sum -b "${VIBFILE}" | cut -d' ' -f1)"

# =======  Clean before start
rm -rf "${TMP_BUNDLE}" "${TMP_METADATA}"
mkdir -p "${TMP_BUNDLE}/vib20/${LCNAME}" "${TMP_METADATA}/bulletins" "${TMP_METADATA}/vibs"

TMP_METADATA="$(readlink -m ${TMP_METADATA})"
TMP_BUNDLE="$(readlink -m ${TMP_BUNDLE})"
TARGET_DIR="$(readlink -m .)"

# Bulletin
BULLETIN="${NAME}-${VERSION}.xml"
replaceKeywords "${DATADIR}/bulletin.xml.template" | tr -d '\n' | sed -e 's/>  *</></g' > "${TMP_METADATA}/bulletins/${BULLETIN}"

# Vibs (only one vib in this bundle)
(
    VIBS="${LCNAME}-9999999990.xml"

    cd "${TMP_METADATA}/vibs"
    ar -x "${VIBFILE}" descriptor.xml

    grep -v '</vib>' descriptor.xml > "${VIBS}.1"
    grep '</vib>' descriptor.xml > "${VIBS}.3"
    replaceKeywords "${DATADIR}/vibs.xml.template" > "${VIBS}.2"
    cat "${VIBS}.1" "${VIBS}.2" "${VIBS}.3" > "${VIBS}"
    rm -f descriptor.xml "${VIBS}.1" "${VIBS}.2" "${VIBS}.3"
)

replaceKeywords "${DATADIR}/vendor-index.xml.template" > "${TMP_METADATA}/vendor-index.xml"
replaceKeywords "${DATADIR}/vmware.xml.template" > "${TMP_METADATA}/vmware.xml"

# Metadata zip
(
    cd "${TMP_METADATA}"
    zip -r "${TMP_BUNDLE}/${VENDOR}-${NAME}-${VERSION}-metadata.zip" *
)

cp "${VIBFILE}" "${TMP_BUNDLE}/vib20/${LCNAME}/${VIBNAME}"

replaceKeywords "${DATADIR}/vendor-index.xml.template" > "${TMP_BUNDLE}/vendor-index.xml"
replaceKeywords "${DATADIR}/index.xml.template" > "${TMP_BUNDLE}/index.xml"

# Depot zip

(
    cd "${TMP_BUNDLE}"
    zip -r "${TARGET_DIR}/${NAME}-ESXi-${VERSION}-offline_bundle.zip" *
)

# =======  Create the manitest
