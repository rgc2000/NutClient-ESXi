#!/bin/sh
# Rene GARCIA (rene@margar.fr)
# Script executed on ups event

SHUDOWN_PID_FILE="/var/run/ups_shutdown.pid"

. /opt/nut/etc/notify.conf

# Delayed shutdown if running on battery
if [ "${NOTIFYTYPE}" = "ONBATT" -a "${ONBATT_DELAY}" -gt 0 ]
then
  if [ ! -f "${SHUDOWN_PID_FILE}" ]
  then
    (
      # seconds to wait
      sleep "${ONBATT_DELAY}"
      # force shutdown
      rm "${SHUDOWN_PID_FILE}"
      /opt/nut/sbin/upsmon -c fsd
      exit 0
    ) &
    echo $! > "${SHUDOWN_PID_FILE}"
  fi
fi

# Abort delayed shutdown if UPS is back ONLINE or SHUTDOWN requested immediately
if [ \( "${NOTIFYTYPE}" = "ONLINE" -o "${NOTIFYTYPE}" = "SHUTDOWN" \) -a -f "${SHUDOWN_PID_FILE}" ]
then
  kill $(cat "${SHUDOWN_PID_FILE}")
  rm "${SHUDOWN_PID_FILE}"
fi

# End here if no mail to send
[ "${SEND_MAIL}" = 1 ] || exit 0

DOMAIN="$(hostname -d)"
FROM="$(hostname -s)@${DOMAIN}"
FROMHEADER="${FROM} (ESXi on $(hostname -s))"
[ -z "${TO}" ] && TO="root@${DOMAIN}"
HOSTNAME="`hostname`"
MESSAGE="$1"
DATE="`date +"%d/%m/%Y %k:%M:%S %Z"`"
DATE_SMTP="`date --rfc-2822`"
(
  echo "From: ${FROMHEADER}"
  echo "Date: ${DATE_SMTP}"
  echo "To: Admin <${TO}>"
  echo "Subject: UPS Notification ${NOTIFYTYPE}"
  echo ""
  echo "$DATE - UPS event on ${HOSTNAME} : ${MESSAGE}"
) | \
/opt/nut/bin/smtpblast -f "${FROM}" -t "${TO}"

exit 0
