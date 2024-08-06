#!/bin/bash

# Lista de nomes dos canais
channel_names=("Caracol TV" "Ahora" "Blu Radio" "La Kalle" "Caracol Sports")

# Arquivo de saída
output_file="channels_info.txt"
echo "" > $output_file

# Função para criar canal e endpoints
create_channel_and_endpoints() {
    local channel_name="$1"
    local channel_id=$(echo "$channel_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    # Criar o canal
    aws mediapackage create-channel \
        --id $channel_id \
        --description "$channel_name" \
        --tags Key=Environment,Value=Dev

    # Verificar se o canal foi criado corretamente
    if [ $? -ne 0 ]; then
        echo "Erro ao criar o canal $channel_name"
        return 1
    fi

    # Criar o endpoint HLS
    aws mediapackage create-origin-endpoint \
        --id ${channel_id}-hls \
        --channel-id $channel_id \
        --manifest-name index \
        --startover-window-seconds 300 \
        --time-delay-seconds 0 \
        --hls-package "{
            \"SegmentDurationSeconds\": 6,
            \"PlaylistType\": \"VOD\",
            \"PlaylistWindowSeconds\": 60,
            \"AdMarkers\": \"PASSTHROUGH\",
            \"IncludeIframeOnlyStream\": false,
            \"UseAudioRenditionGroup\": false
        }" \
        --description "HLS Endpoint"

    # Verificar se o endpoint HLS foi criado corretamente
    if [ $? -ne 0 ]; then
        echo "Erro ao criar o endpoint HLS para o canal $channel_name"
        return 1
    fi

    # Criar o endpoint DASH
    aws mediapackage create-origin-endpoint \
        --id ${channel_id}-dash \
        --channel-id $channel_id \
        --manifest-name index \
        --startover-window-seconds 300 \
        --time-delay-seconds 0 \
        --dash-package "{
            \"SegmentDurationSeconds\": 6,
            \"ManifestWindowSeconds\": 60,
            \"Profile\": \"NONE\",
            \"PeriodTriggers\": [],
            \"SegmentTemplateFormat\": \"NUMBER_WITH_TIMELINE\"
        }" \
        --description "DASH Endpoint"

    # Verificar se o endpoint DASH foi criado corretamente
    if [ $? -ne 0 ]; then
        echo "Erro ao criar o endpoint DASH para o canal $channel_name"
        return 1
    fi

    # Obter detalhes do endpoint HLS
    hls_info=$(aws mediapackage describe-origin-endpoint --id ${channel_id}-hls 2>/dev/null)
    hls_url=$(echo $hls_info | jq -r '.Url')

    # Obter detalhes do endpoint DASH
    dash_info=$(aws mediapackage describe-origin-endpoint --id ${channel_id}-dash 2>/dev/null)
    dash_url=$(echo $dash_info | jq -r '.Url')

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
    create_channel_and_endpoints "$name"
done

echo "Informações dos canais salvas em $output_file"