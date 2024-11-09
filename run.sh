#!/bin/bash

ARCH=$(uname -m)
ARCH_TYPE=""
EXECUTABLE_NAME=""

get_architecture() {
    case "$ARCH" in
        "i386")
            ARCH_TYPE=""
            ;;
        "x86_64")
            ARCH_TYPE="_x64"
            ;;
        "aarch64")
            ARCH_TYPE="_arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
}

get_executable_name() {
    case "$ARCH" in
        "i386")
            EXECUTABLE_NAME="mta-server"
            ;;
        "x86_64")
            EXECUTABLE_NAME="mta-server64"
            ;;
        "aarch64")
            EXECUTABLE_NAME="mta-server-arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
}

main() {
    get_architecture
    get_executable_name
    
    echo "Starting MTA:SA Server.."
    exec "multitheftauto_linux${ARCH_TYPE}/${EXECUTABLE_NAME}" -t -n -u
}

main