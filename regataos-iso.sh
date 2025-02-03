#!/bin/bash

#-------------------------------------------------------------------------------------------------------
# Author: Jeiel Miranda.
# Description: Download da versão mais recente do RegataOS via terminal.
# Creation Date: 01/06/2024
# Version: 0.2
# Execute: ./regataos-iso.sh
#-------------------------------------------------------------------------------------------------------

# Verifica dependências
for cmd in curl wget dialog awk; do
    command -v "$cmd" &>/dev/null || { echo "Erro: $cmd não está instalado."; exit 1; }
done

# Cria arquivo temporário para progresso
progress_file=$(mktemp /tmp/download_progress.XXXXXX)
trap 'rm -f "$progress_file"' EXIT

show_message() {
    dialog --title "Aviso" --infobox "$1" 5 50
    sleep 3
}

show_progress() {
    while :; do
        if grep -q "100%" "$progress_file"; then
            dialog --title "Download completo" --ok-label "OK" --msgbox "Download concluído." 5 50
            break
        fi
        if grep -q "%" "$progress_file"; then
            percent=$(grep "%" "$progress_file" | tail -n 1 | awk '{print $7}' | tr -d '()%')
            echo "$percent"
        fi
        sleep 1
    done
}

# Mensagem inicial
show_message "Bem-vindo! Assistente de Download RegataOS =}"

# URL da página principal
base_page="https://sourceforge.net/projects/regataos/files/regataos-23/"

# Obtém a versão mais recente
latest_version=$(curl -s "$base_page" | grep -o 'Regata_OS_23-nv_en-US[^"]*' | head -n 1)
if [ -z "$latest_version" ]; then
    dialog --title "Erro" --msgbox "Falha ao identificar a versão." 5 50
    exit 1
fi

base_download_url="https://sinalbr.dl.sourceforge.net/project/regataos/regataos-23/"
download_link="${base_download_url}${latest_version}"

# Confirmação do usuário
dialog --title "Download ISO" --yesno "Deseja baixar a versão mais recente?" 8 50
case $? in
    0)
        wget --progress=dot "$download_link" 2>&1 | grep "%" > "$progress_file" &
        show_progress | dialog --title "Aguarde" --gauge "Baixando..." 7 50
        ;;
    1)
        clear && exit
        ;;
esac

clear
