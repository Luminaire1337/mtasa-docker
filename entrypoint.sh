#!/bin/bash

ARCH=$(uname -m)
ARCH_TYPE=""
BASE_URL="https://linux.multitheftauto.com/dl"
BASE_DIR="/src"

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

download_server() {
    echo "Downloading MTA:SA Server.."
    
    wget -q "${BASE_URL}/multitheftauto_linux${ARCH_TYPE}.tar.gz" -O "multitheftauto_linux${ARCH_TYPE}.tar.gz" \
    && tar -xzf "multitheftauto_linux${ARCH_TYPE}.tar.gz" \
    && rm -f "multitheftauto_linux${ARCH_TYPE}.tar.gz" \
    || { echo "Failed to download or extract MTA:SA Server"; exit 1; }
}

check_config() {
    echo "Checking config.."

    if [ ! "$(ls -A shared-config)" ]; then
        echo "Could not find base config, downloading.."

        wget -q "${BASE_URL}/baseconfig.tar.gz" -O /tmp/baseconfig.tar.gz \
        && tar -xzf /tmp/baseconfig.tar.gz -C /tmp \
        && mv /tmp/baseconfig/* shared-config \
        && rm -rf /tmp/baseconfig /tmp/baseconfig.tar.gz \
        || { echo "Failed to download or extract baseconfig"; exit 1; }
    fi

    cp -r shared-config/* "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch"
}

link_modules() {
    echo "Linking modules.."

    if [ -d "shared-modules" ] && [ "$(ls -A shared-modules)" ]; then
        case "$ARCH" in
            "i386")
                rm -rf "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/modules"
                mkdir -p "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/modules"
                cp -r shared-modules/* "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/modules"
                ;;
            "x86_64")
                rm -rf "multitheftauto_linux${ARCH_TYPE}/x64/modules"
                mkdir -p "multitheftauto_linux${ARCH_TYPE}/x64/modules"
                cp -r shared-modules/* "multitheftauto_linux${ARCH_TYPE}/x64/modules"
                ;;
        esac
    fi
}

install_resources() {
    if [ ! -L "${BASE_DIR}/multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/resources" ]; then
        ln -s "${BASE_DIR}/shared-resources" "${BASE_DIR}/multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/resources"
    fi

    if [[ "${INSTALL_DEFAULT_RESOURCES,,}" != "false" ]]; then
        echo "INSTALL_DEFAULT_RESOURCES was not set to false, installing resources.."

        if [ ! "$(ls -A shared-resources)" ]; then
            echo "Downloading default resources.."

            wget -q "http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip" -O /tmp/mtasa-resources.zip \
            && unzip -qo /tmp/mtasa-resources.zip -d shared-resources \
            && rm -f /tmp/mtasa-resources.zip \
            || { echo "Failed to download or unzip resources"; exit 1; }
        fi
    fi
}

setup_http_cache() {
    echo "Setting up HTTP cache.."

    mkdir -p "multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/resource-cache"

    if [ ! -L "${BASE_DIR}/multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/resource-cache/http-client-files" ]; then
        ln -s "${BASE_DIR}/shared-http-cache" "${BASE_DIR}/multitheftauto_linux${ARCH_TYPE}/mods/deathmatch/resource-cache/http-client-files"
    fi
}

main() {
    get_architecture
    download_server
    check_config
    link_modules
    install_resources
    setup_http_cache
}

main
exec "$@"