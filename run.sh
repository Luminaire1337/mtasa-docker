#!/bin/bash

ARCH=$(uname -m)
ARCH_TYPE=""
EXECUTABLE_NAME=""
PIPE_FILE="/tmp/mta_input_$$"

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

create_pipe() {
    [ -e "$PIPE_FILE" ] && rm -f "$PIPE_FILE"
    mkfifo "$PIPE_FILE" || {
        echo "Failed to create named pipe: $PIPE_FILE"
        exit 1
    }
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

    SERVER_STOP_DELAY="${SERVER_STOP_DELAY:-10}"
    create_pipe

    graceful_shutdown() {
        echo "Shutting down..."

        # Send shutdown command to server via pipe
        echo "shutdown" >&3 2>/dev/null || true

        # Wait for server to exit gracefully (max $SERVER_STOP_DELAY seconds)
        local elapsed=0
        while [ $elapsed -lt $SERVER_STOP_DELAY ] && kill -0 "$SERVER_PID" 2>/dev/null; do
            sleep 1
            elapsed=$((elapsed + 1))
        done

        # Force kill server if still running
        if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
            kill -TERM "$SERVER_PID" 2>/dev/null || true
            sleep 1
            kill -KILL "$SERVER_PID" 2>/dev/null || true
        fi

        # Clean up pipe
        exec 3>&- 2>/dev/null || true
        [ -p "$PIPE_FILE" ] && rm -f "$PIPE_FILE"

        save_databases
        exit 0
    }

    trap graceful_shutdown SIGTERM SIGINT

    echo "Starting MTA:SA Server.."

    # Check if executable exists
    if [ ! -f "multitheftauto_linux${ARCH_TYPE}/${EXECUTABLE_NAME}" ]; then
        echo "ERROR: Executable not found: multitheftauto_linux${ARCH_TYPE}/${EXECUTABLE_NAME}"
        exit 1
    fi

    # Use a minimal pipe keeper to prevent blocking (will be killed immediately)
    (exec 3>"$PIPE_FILE"; sleep 1) &
    PIPE_KEEPER_PID=$!

    # Start server with pipe input (won't block because pipe has a writer)
    stdbuf -oL "multitheftauto_linux${ARCH_TYPE}/${EXECUTABLE_NAME}" -t -n -u < "$PIPE_FILE" &
    SERVER_PID=$!

    # Kill the temporary pipe keeper and open our own connection
    kill "$PIPE_KEEPER_PID" 2>/dev/null || true
    exec 3>"$PIPE_FILE"

    # Verify server started
    sleep 1
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "ERROR: Server process died immediately"
        exit 1
    fi


    # Interactive command loop
    while kill -0 "$SERVER_PID" 2>/dev/null; do
        if read -r -t 1 line 2>/dev/null; then
            if [ "$line" = "shutdown" ] || [ "$line" = "quit" ] || [ "$line" = "exit" ]; then
                echo "$line" >&3 2>/dev/null || true
                break
            else
                echo "$line" >&3 2>/dev/null || true
            fi
        fi
    done

    wait "$SERVER_PID"
    SERVER_EXIT_CODE=$?

    # Clean up
    exec 3>&- 2>/dev/null || true
    [ -p "$PIPE_FILE" ] && rm -f "$PIPE_FILE"

    save_databases
    exit $SERVER_EXIT_CODE
}

save_data() {
    save_databases
}

main