#!/bin/sh

GATEWAY="$1"
METRIC="$2"
CSV_FILE="/root/speedtest-data.csv"

# Verifica se os parâmetros foram fornecidos
if [ -z "$GATEWAY" ] || [ -z "$METRIC" ]; then
    echo "Usage: $0 <GatewayName> <ping|download|upload>"
    exit 1
fi

# Verifica se o arquivo existe
if [ ! -f "$CSV_FILE" ]; then
    echo "0"
    exit 0
fi

# Usa tail -r para ler o arquivo de trás pra frente (substituindo tac)
LINE=$(tail -r "$CSV_FILE" | grep -m 1 ",$GATEWAY,")

# Verifica se encontrou a linha
if [ -z "$LINE" ]; then
    echo "0"
    exit 0
fi

# Extrai a métrica desejada
case "$METRIC" in
    download)
        echo "$LINE" | awk -F',' '{print $3}'
        ;;
    upload)
        echo "$LINE" | awk -F',' '{print $4}'
        ;;
    ping)
        echo "$LINE" | awk -F',' '{print $5}'
        ;;
    *)
        echo "Invalid metric"
        exit 2
        ;;
esac
