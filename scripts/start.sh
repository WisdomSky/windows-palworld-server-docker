#!/bin/bash
source /init.sh
source /scripts/config.sh

# Declare directories


echo ">>> Server Dir: ${serverDir}"

serverExe="$serverDir/Pal/Binaries/Win64/PalServer-Win64-Shipping-Cmd.exe"

function startServer() {
    setupServerSettings
    installMods

    startSettings=""
    if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then
        echo "Setting Community-Mode to enabled"
        startSettings="$startSettings EpicApp=PalServer"
    fi
    if [[ -n $MULTITHREAD_ENABLED ]] && [[ $MULTITHREAD_ENABLED == "true" ]]; then
        echo "Setting Multi-Core-Enchancements to enabled"
        startSettings="$startSettings -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
    fi
#    if [[ -n $WEBHOOK_ENABLED ]] && [[ $WEBHOOK_ENABLED == "true" ]]; then
#        send_start_notification
#    fi
    echo -e "\033[32;1m>>> Starting Palworld Server <<<\033[0m"
    cd "${serverDir}/Pal/Binaries/Win64"
    $PROTON run ./PalServer-Win64-Shipping-Cmd.exe $startSettings
    echo ">>> Palworld server stopping"
}

function bootManager() {
    checkSettings
    setupCron
    if [ ! -f ${serverExe} ]; then
        installServer
    fi
    startServer
}

bootManager