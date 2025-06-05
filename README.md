# pfsense-parametros
Adiciona os parametros necessarios para que speedtest, temp e outros parametros funcionem.

Lembre-se de criar uma CRON!

*/15	*	*	*	*	root	/root/speedtest-to-csv.sh

Lembre-se de alterar os ips do getway no script! Para poder funcionar corretamente use os nomes iguais da interfaces que você colocou no inicio da página.

# Executa testes para cada link ip do getway da interface!

run_test "Vivo" "0.0.0.0"

run_test "Ligga" "0.0.0.0"

**ATENÇÂO**

Se você tiver exemplo Ligga como principal deverá inverter no script quem primeiro executa:

**run_test "Ligga" "0.0.0.0"**

run_test "Vivo" "0.0.0.0"


Dê permissoes para o arquivo:

chmod +x /root/scripts/last_login.sh

chmod +x /root/speedtest-to-csv.sh
