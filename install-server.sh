#!/bin/bash

# Variables
NUKKIT_URL="https://repo.opencollab.dev/api/maven/latest/file/maven-snapshots/cn/nukkit/nukkit/1.0-SNAPSHOT?extension=jar"
NUKKIT_JAR="nukkit.jar"
INSTALL_DIR="$HOME/nukkit-server"
START_SCRIPT="start.sh"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Update package list
echo "Updating package list..."
sudo apt update -y

# Install OpenJDK 21
echo "Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jdk

# Create server directory
echo "Creating server directory at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

# Download NukkitX JAR with user agent for error handling
echo "Downloading NukkitX..."
curl -A "$USER_AGENT" -L "$NUKKIT_URL" -o "$NUKKIT_JAR"

# Check if the download was successful
if [ ! -f "$NUKKIT_JAR" ]; then
    echo "Error: Failed to download NukkitX."
    exit 1
fi

# Create start script
echo "Creating start script..."
cat <<EOF > "$START_SCRIPT"
#!/bin/bash
java -Xms512M -Xmx1024M -jar $NUKKIT_JAR nogui
EOF

# Make start script executable
chmod +x "$START_SCRIPT"

# Done
echo "Installation complete. To start the server, run:"
echo "cd $INSTALL_DIR && ./start.sh"
