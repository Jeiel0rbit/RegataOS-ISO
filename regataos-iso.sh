#!/usr/bin/env bash

#-------------------------------------------------------------------------------------------------------
# Author: Jeiel0rbit (Github).
# Description: Download da versão mais recente do RegataOS via terminal.
# Creation Date: 01/06/2024
# Update Date: 27/03/2025
# Version: 1.4
# Execute: ./regataos-iso.sh
#-------------------------------------------------------------------------------------------------------

# Verifica dependências
for cmd in wget dialog awk curl ping; do
    command -v "$cmd" &>/dev/null || { echo "Erro: $cmd não está instalado."; exit 1; }
done

# Verifica conexão
ping -c 1 sourceforge.net > /dev/null 2>&1 || { dialog --title "Erro" --msgbox "Sem conexão com a internet." 5 50; exit 1; }

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
        if grep -q "ERROR" "$progress_file"; then
            dialog --title "Erro" --msgbox "Falha no download. Verifique a conexão." 5 50
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

# Obtém o número da versão principal mais recente
main_version=$(curl -s "https://sourceforge.net/projects/regataos/files/" | grep -oE 'regataos-[0-9]+' | sort -Vr | head -n 1 | cut -d'-' -f2)
if [ -z "$main_version" ]; then
    dialog --title "Erro" --msgbox "Não foi possível encontrar a versão principal." 5 50
    exit 1
fi

# Obtém a versão completa mais recente do subdiretório
subdirectory="https://sourceforge.net/projects/regataos/files/regataos-${main_version}/"
full_version=$(curl -s "$subdirectory" | grep -oE "Regata_OS_${main_version}_en-US\.x86_64-[0-9]+\.[0-9]+\.[0-9]+" | sort -Vr | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+$')
if [ -z "$full_version" ]; then
    dialog --title "Erro" --msgbox "Não foi possível encontrar a versão completa." 5 50
    exit 1
fi

# Monta a URL final
download_link="https://cfhcable.dl.sourceforge.net/project/regataos/regataos-${main_version}/Regata_OS_${main_version}_en-US.x86_64-${full_version}.iso?viasf=1"
version_name="Regata_OS_${main_version}_en-US.x86_64-${full_version}"

# Confirmação do usuário
dialog --title "Download ISO" --yesno "Deseja baixar a versão mais recente (${version_name})?" 8 50
case $? in
    0)
        wget --progress=dot -L "$download_link" 2>&1 | grep -E "%|ERROR" > "$progress_file" &
        show_progress | dialog --title "Aguarde" --gauge "Baixando ${version_name}..." 7 50
        ;;
    1)
        clear && exit
        ;;
esac

clear
