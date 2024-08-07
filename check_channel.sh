#!/bin/bash

# Lista de nomes dos canais
channel_names=("Caracol TV" "Ahora" "Blu Radio" "La Kalle" "Caracol Sports")

# Arquivo de saída
output_file="channels_info.txt"
echo "" > $output_file

# Função para criar canal e endpoints
check_channel() {
    local channel_name="$1"
    local channel_id=$(echo "$channel_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    # Obter detalhes de ingest do canal
    ingest_endpoints=$(aws mediapackage describe-channel --id $channel_id | jq -r '.HlsIngest.IngestEndpoints')
    username=$(echo $ingest_endpoints | jq -r '.[0].Username')
    password=$(echo $ingest_endpoints | jq -r '.[0].Password')
    ingest_url_1=$(echo $ingest_endpoints | jq -r '.[0].Url')
    ingest_url_2=$(echo $ingest_endpoints | jq -r '.[1].Url')

    # Salvar informações no arquivo de saída
    echo "$channel_name" >> $output_file
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

# Loop através dos nomes dos canais e cria canais e endpoints
for name in "${channel_names[@]}"; do
    check_channel "$name"
done

echo "Informações dos canais salvas em $output_file"