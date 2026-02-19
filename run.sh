#!/bin/bash

ARCH=$(uname -m)
EXECUTABLE_NAME=""

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
        if [ -f "server/mods/deathmatch/${file}" ]; then
            cp -f "server/mods/deathmatch/${file}" shared-config/
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
        if [ -f "server/mods/deathmatch/${file}" ]; then
            cp -f "server/mods/deathmatch/${file}" shared-databases/
        fi
    done

    # Save "databases" directory to shared-databases
    if [ -d "server/mods/deathmatch/databases" ]; then
        cp -rf "server/mods/deathmatch/databases" shared-databases/
    fi
}

main() {
    get_executable_name
    
    echo "Starting MTA:SA Server.."
    "server/${EXECUTABLE_NAME}" -n -u &
    wait $!
}

save_data() {
    save_config
    save_databases
}

trap save_data SIGTERM SIGINT EXIT
main