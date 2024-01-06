#!/bin/bash

#-------------------------------------------------------------------------------------------------------
# Author: Jeiel Miranda.
# Description: The program quickly downloads the latest version of the ENGLISH version via the terminal.
# Creation Date: 01/06/2024
# Version: 0.1
# Execute: ./regataos-iso.sh
# Mail: t9crw9cj@duck.com
# Origin: Brazil.
#-------------------------------------------------------------------------------------------------------

# Função para exibir mensagem por 3 segundos
show_message() {
    dialog --title "Aviso" --infobox "$1" 5 50
    sleep 3
}

# Função para exibir a porcentagem do download
show_progress() {
    while :; do
        if grep -q "100%" "download_progress"; then
            dialog --title "Download completed" --ok-label "OK" --msgbox "Download completed." 5 50
            break
        fi
        if grep -q "%" "download_progress"; then
            percent=$(grep "%" "download_progress" | tail -n 1 | awk '{print $7}' | tr -d '()%')
            echo "$percent"
        fi
        sleep 1
    done
}

# Exibe a mensagem por 3 segundos
show_message "Welcome! RegataOS Download Assistant =}"

# URL da página principal
base_page="https://sourceforge.net/projects/regataos/files/regataos-23/"

# Obtém o termo da versão mais recente Regata_OS_23-nv_en-US
latest_version=$(curl -s "$base_page" | grep -o 'Regata_OS_23-nv_en-US[^"]*' | head -n 1)

# URL base do download
base_download_url="https://sinalbr.dl.sourceforge.net/project/regataos/regataos-23/"

# Constrói a URL completa substituindo o termo da versão
download_link="${base_download_url}${latest_version}"

# Pergunta se deseja fazer o download da ISO mais recente
dialog --title "Download ISO" --yesno "Do you want to download the latest version?" 8 50

# Verifica a resposta do usuário
response=$?
case $response in
    0) # Se o usuário escolher "Yes" (código 0)
        # Inicia o download em segundo plano e captura o progresso
        wget --progress=dot "$download_link" 2>&1 | grep "%" > download_progress &

        # Exibe a porcentagem do download no dialog "Aguarde"
        show_progress | dialog --title "Aguarde" --gauge "Download..." 7 50
        ;;
    1) # Se o usuário escolher "No" (código 1)
        clear && exit
        ;;
esac

# Limpa arquivos temporários
rm -f download_progress
clear
