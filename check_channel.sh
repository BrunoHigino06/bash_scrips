#!/bin/bash

# Lista de IDs dos canais
channel_ids=("Ahora" "Blu-Radio" "Caracol-Sports" "Caracol-TV" "La-Kalle")

# Arquivo de saída
output_file="channels_info.txt"
echo "" > $output_file

# Função para verificar informações do canal
check_channel() {
    local channel_id="$1"
    
    # Obter detalhes de ingest do canal
    ingest_endpoints=$(aws mediapackage describe-channel --id $channel_id | jq -r '.HlsIngest.IngestEndpoints')
    
    if [ $? -ne 0 ]; then
        echo "Erro ao descrever o canal $channel_id" >> $output_file
        return 1
    fi

    username=$(echo $ingest_endpoints | jq -r '.[0].Username')
    password=$(echo $ingest_endpoints | jq -r '.[0].Password')
    ingest_url_1=$(echo $ingest_endpoints | jq -r '.[0].Url')
    ingest_url_2=$(echo $ingest_endpoints | jq -r '.[1].Url')

    # Salvar informações no arquivo de saída
    echo "$channel_id" >> $output_file
    echo "Option 01" >> $output_file
    echo "URL: $ingest_url_1" >> $output_file
    echo "User: $username" >> $output_file
    echo "Password: $password" >> $output_file
    echo "" >> $output_file
    echo "Option 02" >> $output_file
    echo "URL: $ingest_url_2" >> $output_file
    echo "User: $username" >> $output_file
    echo "Password: $password" >> $output_file
    echo "" >> $output_file
}

# Loop através dos IDs dos canais e verifica informações
for channel_id in "${channel_ids[@]}"; do
    check_channel "$channel_id"
done

echo "Informações dos canais salvas em $output_file"
