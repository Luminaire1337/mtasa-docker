#!/bin/bash

ARCH=$(uname -m)
ARCH_TYPE=""
EXECUTABLE_NAME=""

get_architecture() {
    case "$ARCH" in
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

save_config() {
    echo "Saving config files.."

    if [ ! -d "shared-config" ]; then
        mkdir -p shared-config
    fi

    # Save server config files to shared-config
    for file in acl.xml mtaserver.conf vehiclecolors.conf server-id.keys banlist.xml settings.xml; do
        if [ -f "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/${file}" ]; then
            cp -f "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/${file}" shared-config/
        fi
    done
}

save_databases() {
    echo "Saving databases.."

    if [ ! -d "shared-databases" ]; then
        mkdir -p shared-databases
    fi

    # Save internal.db and registry.db to shared-databases
    for file in internal.db registry.db; do
        if [ -f "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/${file}" ]; then
            cp -f "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/${file}" shared-databases/
        fi
    done

    # Save 'databases' directory to shared-databases
    if [ -d "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/databases" ]; then
        cp -rf "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/databases" shared-databases/
    fi
}

main() {
    get_architecture
    get_executable_name

    # 10 seconds by default to wait for the server to exit
    SERVER_STOP_DELAY="${SERVER_STOP_DELAY:-10}"

    graceful_shutdown() {
        # Send shutdown command to server and wait
        echo "shutdown" > /proc/$$/fd/0
        echo "Waiting for server to shutdown..."
        sleep "$SERVER_STOP_DELAY"
        save_data
        exit 0
    }
    
    # Trap on `docker stop` for example
    trap graceful_shutdown SIGTERM SIGINT
    
    echo "Starting MTA:SA Server.."
    
    # Start server in foreground with STDIN/TTY preserved
    stdbuf -oL "multitheftauto_linux${ARCH_TYPE}/${EXECUTABLE_NAME}" -t -n -u
    SERVER_EXIT_CODE=$?

    save_data

    exit $SERVER_EXIT_CODE
}


save_data() {
    save_config
    save_databases
}

main