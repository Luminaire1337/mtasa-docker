#!/bin/bash
readonly MTA_ROOT="/src/multitheftauto_linux_x64"

if ! [[ "$(ls -A shared-config)" ]]; then
    echo "Downloading base config.."

    wget -q http://linux.mtasa.com/dl/baseconfig.tar.gz -O /tmp/baseconfig.tar.gz
    tar -xzf /tmp/baseconfig.tar.gz -C /tmp
    mv /tmp/baseconfig/* shared-config
    rm -rf /tmp/baseconfig /tmp/baseconfig.tar.gz
fi

cp -r shared-config/* "${MTA_ROOT}/mods/deathmatch"

if [[ "$(ls -A shared-modules)" ]]; then
    cp -r shared-modules/* "${MTA_ROOT}/x64/modules"
fi

if ! [[ -d "${MTA_ROOT}/mods/deathmatch/resources" ]]; then
    mkdir -p "${MTA_ROOT}/mods/deathmatch/resources"
    ln -s /src/shared-resources "${MTA_ROOT}/mods/deathmatch/resources/[docker]"
fi

if ! [[ "$(ls -A shared-resources)" ]]; then
    echo "Downloading default resources.."

    wget -q http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip -O /tmp/mtasa-resources.zip
    unzip -qo /tmp/mtasa-resources.zip -d shared-resources
    rm -rf /tmp/mtasa-resources.zip
fi

## For external web server
# https://wiki.multitheftauto.com/wiki/Installing_and_Configuring_Nginx_as_an_External_Web_Server
if ! [[ -d "${MTA_ROOT}/mods/deathmatch/resource-cache" ]]; then
    mkdir -p "${MTA_ROOT}/mods/deathmatch/resource-cache"
    ln -s /src/shared-http-cache "${MTA_ROOT}/mods/deathmatch/resource-cache/http-client-files"
fi

echo "Starting MTA:SA Server.."
"${MTA_ROOT}/mta-server64"