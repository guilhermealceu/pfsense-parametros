#!/bin/sh

CONF="/usr/local/etc/zabbix6/zabbix_agentd.conf"

cat <<EOF >> "$CONF"

UserParameter=temperature.zone0,sysctl -n hw.acpi.thermal.tz0.temperature | sed 's/C//'
UserParameter=temperature.zone1,sysctl -n hw.acpi.thermal.tz1.temperature | sed 's/C//'
UserParameter=speedtest.vivo.ping,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY ping
UserParameter=speedtest.vivo.download,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY download
UserParameter=speedtest.vivo.upload,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY upload
UserParameter=speedtest.ligga.ping,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY ping
UserParameter=speedtest.ligga.download,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY download
UserParameter=speedtest.ligga.upload,sh /root/scripts/speedtest_param.sh SUBSTITUA-IP-DO-GETWAY upload
UserParameter=pfSense.lastlogin,/root/scripts/last_login.sh
EOF

echo "Parâmetros adicionados com sucesso! Lembre-se de substituir ip do getway e outras coisas se precisar!"
