#!/bin/bash

# Version
VERSION="2.6"

# Variables
INSTALL_DIR="$HOME/nukkit-server"
NUKKIT_JAR="$INSTALL_DIR/nukkit.jar"
START_SCRIPT="$INSTALL_DIR/start.sh"
MC_SERVER_LOG="$INSTALL_DIR/latest.log"
MC_SERVER_PID_FILE="$INSTALL_DIR/mcserver.pid"
NUKKIT_URL="https://repo.opencollab.dev/api/maven/latest/file/maven-snapshots/cn/nukkit/nukkit/1.0-SNAPSHOT?extension=jar"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

# Function to check server status
server_status() {
    if pgrep -f "start.sh" > /dev/null || pgrep -f "java" > /dev/null; then
        echo "[RUNNING]"
    else
        echo "[STOPPED]"
    fi
}

# Function to install dependencies in Termux
install_dependencies() {
    echo "Checking for required packages..."
    pkg install -y openjdk-21 wget || {
        echo "❌ Error: Failed to install dependencies!"
        read -p "⚠ Press Enter to return to the menu..."
        clear
        return
    }
}

# Function to install the server
install_server() {
    clear  # Clears the screen before installation
    echo "==============================="
    echo "🚀 Installing Nukkit Server..."
    echo "==============================="

    install_dependencies  # Ensure dependencies are installed

    mkdir -p "$INSTALL_DIR"

    echo "⬇ Downloading NukkitX..."
    wget --user-agent="$USER_AGENT" -O "$NUKKIT_JAR" "$NUKKIT_URL" --no-check-certificate || {
        echo "❌ Error: Failed to download Nukkit!"
        read -p "⚠ Press Enter to return to the menu..."
        clear
        return
    }

    echo "✔ Download complete: $NUKKIT_JAR"

    # Create start.sh script
    echo "⚙ Creating start.sh..."
    cat <<EOF > "$START_SCRIPT"
#!/bin/bash
cd "$INSTALL_DIR"
java -jar nukkit.jar
EOF
    chmod +x "$START_SCRIPT"

    echo "✔ Installation complete!"
    read -p "⚠ Press Enter to return to the menu..."
    clear  # Clears the screen after pressing Enter
}

# Function to start the server and show logs
start_server() {
    if pgrep -f "start.sh" > /dev/null || pgrep -f "java" > /dev/null; then
        echo "✔ Server is already running. Showing logs..."
    else
        echo "🚀 Starting server..."
        cd "$INSTALL_DIR" || exit
        nohup ./start.sh >> "$MC_SERVER_LOG" 2>&1 &
        echo $! > "$MC_SERVER_PID_FILE"
        echo "✔ Server started!"
    fi

    echo "⚡ Press Ctrl+B to exit logs and return to menu."
    trap 'kill $LOG_PID; echo; read -p "⚠ Press Enter to return to menu..."; clear' SIGINT
    tail -f "$MC_SERVER_LOG" &
    LOG_PID=$!
    wait $LOG_PID
}

# Function to force stop all running servers
force_stop_server() {
    echo "⛔ Stopping all running servers..."
    pkill -f "start.sh"
    pkill -f "java"
    rm -f "$MC_SERVER_PID_FILE"
    echo "✔ All servers stopped."
    read -p "⚠ Press Enter to return to the menu..."
    clear
}

# Function to display server info
server_info() {
    echo "============================"
    echo "  🌍 Minecraft Server Info"
    echo "============================"
    if pgrep -f "start.sh" > /dev/null || pgrep -f "java" > /dev/null; then
        PID=$(pgrep -f "start.sh")
        echo "✔ Status     : Running"
        echo "⚙ Process ID : $PID"
        if [ -f "$MC_SERVER_LOG" ]; then
            echo "📜 Last Log Update: $(ls -l --time-style=+"%Y-%m-%d %H:%M:%S" "$MC_SERVER_LOG" | awk '{print $6, $7}')"
        fi
    else
        echo "❌ Status     : Not Running"
    fi
    read -p "⚠ Press Enter to return to the menu..."
    clear
}

# Function to display menu
show_menu() {
    echo "================================="
    echo "  🎮 Minecraft Server Panel v$VERSION"
    echo "================================="
    echo "1️⃣  Install Server (Shows Install Logs)"
    echo "2️⃣  Start Server $(server_status) (Shows Live Logs)"
    echo "3️⃣  Server Info"
    echo "4️⃣  Force Stop Server (Kill All)"
    echo "0️⃣  Exit"
    echo "================================="
}

# Main menu loop
while true; do
    show_menu
    read -p "🔹 Select an option: " option
    case $option in
        1) install_server ;;  # Clears menu before install, waits after install
        2) start_server ;;  # Starts the server and shows logs
        3) server_info ;;  # Waits for Enter before returning
        4) force_stop_server ;; # Stops all running instances
        0) echo "👋 Exiting..."; exit 0 ;;
        *) echo "❌ Invalid option, please try again." ;;
    esac
done
