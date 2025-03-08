#!/bin/bash

SERVER_DIR=~/nukkit-server
START_SCRIPT="$SERVER_DIR/start.sh"
PROPERTIES_FILE="$SERVER_DIR/server.properties"

# Function to get public IP (External)
get_public_ip() {
    PUBLIC_IP=$(curl -s ifconfig.me || echo "Unavailable")
}

# Function to get server port from properties
get_server_port() {
    SERVER_PORT=$(grep -E "^server-port=" "$PROPERTIES_FILE" 2>/dev/null | cut -d'=' -f2)
    SERVER_PORT=${SERVER_PORT:-19132}  # Default port if not found
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
    mkdir -p "$SERVER_DIR"
    wget --user-agent="Mozilla/5.0" -O "$SERVER_DIR/nukkit.jar" \
    "https://repo.opencollab.dev/api/maven/latest/file/maven-snapshots/cn/nukkit/nukkit/1.0-SNAPSHOT?extension=jar"

    if [ $? -eq 0 ]; then
        echo "✔ Nukkit downloaded successfully."
    else
        echo "❌ Error: Failed to download Nukkit!"
        read -p "⚠ Press Enter to return to the menu..."
        return
    fi

    # Create a start.sh script if not exists
    if [ ! -f "$START_SCRIPT" ]; then
        echo -e "#!/bin/bash\ncd \"$SERVER_DIR\"\njava -jar nukkit.jar" > "$START_SCRIPT"
        chmod +x "$START_SCRIPT"
        echo "✔ Created start.sh"
    fi

    echo "✔ Installation Complete!"
    read -p "Press Enter to return to the menu..."
}

# Function to start the server
start_server() {
    clear
    echo "🚀 Starting server..."

    # Ensure language is set to English
    if ! grep -q "^language=eng" "$PROPERTIES_FILE"; then
        echo "language=eng" >> "$PROPERTIES_FILE"
        echo "✔ Language set to English (eng)"
    fi

    # Ensure start script exists
    if [ ! -f "$START_SCRIPT" ]; then
        echo "❌ Error: start.sh not found!"
        read -p "⚠ Press Enter to return to the menu..."
        return
    fi

    # Ensure the script is executable
    chmod +x "$START_SCRIPT"

    # Start the server and show logs
    cd "$SERVER_DIR"
    bash "$START_SCRIPT" | tee "$SERVER_DIR/latest.log"
}

# Function to force stop the server
force_stop_server() {
    clear
    echo "🛑 Stopping server..."
    
    # Kill only Nukkit-related Java processes
    pkill -f "java -jar nukkit.jar"

    echo "✔ Server stopped."
    read -p "Press Enter to return to the menu..."
}

# Function to edit the server.properties file
edit_server_properties() {
    clear
    echo "🛠 Editing server.properties..."
    nano "$PROPERTIES_FILE"
}

# Display Menu
while true; do
    clear
    get_public_ip
    get_server_port
    echo "🎮 Minecraft Server Panel v3"
    echo "❗Created by: Mark Martinez"
    echo "==============================="
    echo "🏠 Local IP: 192.168.1.2 (Device/WiFi IP)"
    echo "🌍 Public IP: $PUBLIC_IP"
    echo "🔌 Server Port: $SERVER_PORT"
    echo "==============================="
    echo "1) Install Server (Shows Install Logs)"
    echo "2) Start Server (Shows Live Logs)"
    echo "3) Force Stop Server (Kill Process)"
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
