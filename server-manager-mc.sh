#!/bin/bash

SERVER_DIR=~/nukkit-server
START_SCRIPT="$SERVER_DIR/start.sh"
PROPERTIES_FILE="$SERVER_DIR/server.properties"


# Function to get public IP (External)
get_public_ip() {
    PUBLIC_IP=$(curl -s ifconfig.me)
    [ -z "$PUBLIC_IP" ] && PUBLIC_IP="Unavailable"
}

# Function to get server port from properties
get_server_port() {
    if [ -f "$PROPERTIES_FILE" ]; then
        SERVER_PORT=$(grep -E "^server-port=" $PROPERTIES_FILE | cut -d'=' -f2)
        [ -z "$SERVER_PORT" ] && SERVER_PORT="19132"
    else
        SERVER_PORT="19132"
    fi
}

# Function to install the Nukkit server
install_server() {
    clear
    echo "🚀 Installing Nukkit Server..."
    echo "==============================="

    # Install Java (if needed)
    if ! command -v java > /dev/null 2>&1; then
        echo "⚡ Installing OpenJDK 17..."
        pkg update && pkg install -y openjdk-17
        echo "✔ Java installed successfully."
    fi

    # Download Nukkit
    echo "📥 Downloading Nukkit..."
    mkdir -p $SERVER_DIR
    wget --user-agent="Mozilla/5.0" -O $SERVER_DIR/nukkit.jar \
    "https://repo.opencollab.dev/api/maven/latest/file/maven-snapshots/cn/nukkit/nukkit/1.0-SNAPSHOT?extension=jar"

    if [ $? -eq 0 ]; then
        echo "✔ Nukkit downloaded successfully."
    else
        echo "❌ Error: Failed to download Nukkit!"
        read -p "⚠ Press Enter to return to the menu..."
        return
    fi

    echo "✔ Installation Complete!"
    read -p "Press Enter to return to the menu..."
}

# Function to start the server
start_server() {
    clear
    echo "🚀 Starting server..."
    
    # Ensure language is set to English
    if ! grep -q "^language=eng" $PROPERTIES_FILE; then
        echo "language=eng" >> $PROPERTIES_FILE
        echo "✔ Language set to English (eng)"
    fi

    # Start the server and show logs
    bash $START_SCRIPT | tee $SERVER_DIR/latest.log
}

# Function to force stop the server
force_stop_server() {
    clear
    echo "🛑 Stopping all server processes..."
    pkill -f nukkit.jar
    echo "✔ Server stopped."
    read -p "Press Enter to return to the menu..."
}

# Function to edit the server.properties file
edit_server_properties() {
    clear
    echo "🛠 Editing server.properties..."
    nano $PROPERTIES_FILE
}

# Display Menu
while true; do
    clear
    get_public_ip
    get_server_port
    echo "🎮 Minecraft Server Panel v3"
    echo "❗created by: Mark Martinez"
    echo "==============================="
    echo "🏠 Local Ip: 192.168.1.2 (ip you using same device or wifi)"
    echo "🌍 Public IP: $PUBLIC_IP"
    echo "🔌 Server Port: $SERVER_PORT"
    echo "==============================="
    echo "1) Install Server (Shows Install Logs)"
    echo "2) Start Server [STOPPED] (Shows Live Logs)"
    echo "3) Force Stop Server (Kill All)"
    echo "4) Edit Server Properties"
    echo "5) Exit"
    echo "==============================="
    read -p "• Select an option: " choice

    case $choice in
        1) install_server ;;
        2) start_server ;;
        3) force_stop_server ;;
        4) edit_server_properties ;;
        5) exit ;;
        *) echo "❌ Invalid option! Try again." ;;
    esac
done
