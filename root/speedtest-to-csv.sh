#!/bin/sh

# Configurações
OUT="/root/speedtest-data.csv"
HEADER="Timestamp,Gateway,Download(Mbps),Upload(Mbps),Ping(ms)"
MAX_RECORDS=1000
TEMP_FILE="/tmp/speedtest-temp.csv"

# Cria o arquivo se não existir
[ ! -f "$OUT" ] && echo "$HEADER" > "$OUT"

run_test() {
    GW_NAME=$1
    GW_IP=$2

    echo "=== Testando $GW_NAME ($GW_IP) ==="

    # Verifica se o gateway está acessível antes de mudar rota
    ping -c 1 -t 1 "$GW_IP" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[AVISO] Gateway $GW_NAME ($GW_IP) inacessível. Pulando teste."
        return
    fi

    # Salva rota default atual
    OLDGW=$(netstat -rn | grep '^default' | awk '{print $2}')
    echo "[INFO] Gateway atual: $OLDGW"

    # Troca a rota default para o gateway desejado
    route delete default
    route add default "$GW_IP"
    echo "[INFO] Rota alterada para $GW_NAME ($GW_IP)"

    # Executa o teste de velocidade
    DATA=$(/usr/local/bin/speedtest --accept-license --accept-gdpr --format=json)
    TEST_OK=$?

    # Restaura a rota default original
    route delete default
    route add default "$OLDGW"
    echo "[INFO] Rota restaurada para $OLDGW"

    # Processa dados se o teste foi bem-sucedido
    if [ $TEST_OK -eq 0 ]; then
        UTC_TIMESTAMP=$(echo "$DATA" | jq -r '.timestamp')
        DATE_PART=$(echo "$UTC_TIMESTAMP" | cut -d'T' -f1)
        TIME_PART=$(echo "$UTC_TIMESTAMP" | cut -d'T' -f2 | sed 's/Z//')
        HOUR=$(echo "$TIME_PART" | cut -d':' -f1)
        MINUTE=$(echo "$TIME_PART" | cut -d':' -f2)
        SECOND=$(echo "$TIME_PART" | cut -d':' -f3)

        HOUR=$((HOUR - 3))
        if [ $HOUR -lt 0 ]; then
            HOUR=$((HOUR + 24))
        fi
        HOUR=$(printf "%02d" $HOUR)
        TIMESTAMP="${DATE_PART} ${HOUR}:${MINUTE}:${SECOND}"

        DOWNLOAD=$(echo "$DATA" | jq '.download.bandwidth' | awk '{printf "%.2f", $1 * 8 / 1000000}')
        UPLOAD=$(echo "$DATA" | jq '.upload.bandwidth' | awk '{printf "%.2f", $1 * 8 / 1000000}')
        PING=$(echo "$DATA" | jq '.ping.latency' | awk '{printf "%.2f", $1}')

        echo "$TIMESTAMP,$GW_NAME,$DOWNLOAD,$UPLOAD,$PING" >> "$OUT"
        echo "[OK] Teste de $GW_NAME salvo: $DOWNLOAD ↓ / $UPLOAD ↑ / $PING ms"
    else
        echo "[ERRO] Teste de velocidade falhou para $GW_NAME"
    fi
}

# Executa testes para cada link
run_test "Vivo" "177.16.8.129"
run_test "Ligga" "200.195.177.161"

# Limita número de registros no CSV
{ echo "$HEADER"; tail -n $MAX_RECORDS "$OUT" | sed '1d'; } > "$TEMP_FILE"
mv "$TEMP_FILE" "$OUT"

# Copia arquivo para o webserver
cp "$OUT" /usr/local/www/speedtest.csv
chmod 644 /usr/local/www/speedtest.csv
