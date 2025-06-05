#!/bin/sh

CONF="/usr/local/etc/zabbix6/zabbix_agentd.conf"

cat <<EOF >> "$CONF"

UserParameter=temperature.zone0,sysctl -n hw.acpi.thermal.tz0.temperature | sed 's/C//'
UserParameter=temperature.zone1,sysctl -n hw.acpi.thermal.tz1.temperature | sed 's/C//'

UserParameter=speedtest.vivo.ping,sh /root/scripts/speedtest_csv_param.sh Vivo ping
UserParameter=speedtest.vivo.download,sh /root/scripts/speedtest_csv_param.sh Vivo download
UserParameter=speedtest.vivo.upload,sh /root/scripts/speedtest_csv_param.sh Vivo upload

UserParameter=speedtest.ligga.ping,sh /root/scripts/speedtest_csv_param.sh Ligga ping
UserParameter=speedtest.ligga.download,sh /root/scripts/speedtest_csv_param.sh Ligga download
UserParameter=speedtest.ligga.upload,sh /root/scripts/speedtest_csv_param.sh Ligga upload
EOF

echo "Parâmetros adicionados com sucesso!"
