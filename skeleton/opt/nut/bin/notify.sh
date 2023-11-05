#!/bin/sh
# Rene GARCIA (rene@margar.fr)
# Script executed on ups event

SHUDOWN_PID_FILE="/var/run/ups_shutdown.pid"

. /opt/nut/etc/notify.conf

# count how many UPSes are still online
NB_UPS_ONLINE=$(for UPS in ${UPS_LIST}; do /opt/nut/bin/upsc "${UPS}" ups.status; done | grep -c OL)

# Delayed shutdown if running on battery with less than minsupplies online
if [ "${NOTIFYTYPE}" = "ONBATT" -a "${NB_UPS_ONLINE}" -lt "${MINSUPPLIES}" -a "${ONBATT_DELAY}" -gt 0 ]
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

# Abort delayed shutdown if online UPS counter is greater or equal to minsupplies or SHUTDOWN requested immediately
if [ \( "${NB_UPS_ONLINE}" -ge "${MINSUPPLIES}" -o "${NOTIFYTYPE}" = "SHUTDOWN" \) -a -f "${SHUDOWN_PID_FILE}" ]
then
  kill $(cat "${SHUDOWN_PID_FILE}")
  rm "${SHUDOWN_PID_FILE}"
fi

# End here if no mail to send
[ "${SEND_MAIL}" = 1 ] || exit 0

# Send an email
[ -n "${SMTP_RELAY}" ] && RELAY_OPTION="-r ${SMTP_RELAY}" || RELAY_OPTION=""
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
/opt/nut/bin/smtpblast -f "${FROM}" -t "${TO}" ${RELAY_OPTION}

exit 0
