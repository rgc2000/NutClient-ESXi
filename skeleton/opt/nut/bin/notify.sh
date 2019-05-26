#!/bin/sh
# Rene GARCIA (rene@margar.fr)
# Script executed on ups event

. /opt/nut/etc/notify.conf
[ "${SEND_MAIL}" = 1 ] || exit 0

DOMAIN="$(hostname -d)"
FROM="$(hostname -s)@${DOMAIN} (ESXi on $(hostname -s))"
[ -z "${TO}" ] && TO="root@${DOMAIN}"
HOSTNAME="`hostname`"
MESSAGE="$1"
DATE="`date +"%d/%m/%Y %k:%M:%S %Z"`"
DATE_SMTP="`date --rfc-2822`"
(
  echo "From: ${FROM}"
  echo "Date: ${DATE_SMTP}"
  echo "To: Admin <${TO}>"
  echo "Subject: UPS Notification ${NOTIFYTYPE}"
  echo ""
  echo "$DATE - UPS event on ${HOSTNAME} : ${MESSAGE}"
) | \
/opt/nut/bin/smtpblast -f "${FROM}" -t "${TO}"

exit 0
