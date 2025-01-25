#!/bin/sh -e

# Enhanced script for configuring sayip/reboot/halt for AllStar Link (ASL3)
# Copyright (C) 2024 Jory A. Pratt - W5GLE
# Released under the GNU General Public License v2 or later.

LOG_FILE="/var/log/asl3_sayip_setup.log"
touch "$LOG_FILE"
exec >> "$LOG_FILE" 2>&1

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Validate input arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <NodeNumber>"
    exit 1
fi

NODE_NUMBER=$1
if ! echo "$NODE_NUMBER" | grep -qE '^[0-9]+$'; then
    echo "Error: NodeNumber must be a positive integer."
    exit 1
fi

CONF_FILE="/etc/asterisk/rpt.conf"
BASE_URL="https://dev.gentoo.org/~anarchy/asl3-scripts"
TARGET_DIR="/etc/asterisk/local"
FILES_TO_DOWNLOAD="halt.sh reboot.sh sayip.sh saypublicip.sh speaktext.sh halt.ulaw reboot.ulaw ip-address.ulaw public-ip-address.ulaw"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR" || {
    echo "Failed to create directory $TARGET_DIR"
    exit 1
}

# Download required files
cd "$TARGET_DIR" || {
    echo "Failed to change directory to $TARGET_DIR"
    exit 1
}

for FILE in $FILES_TO_DOWNLOAD; do
    if [ ! -f "$FILE" ]; then
        echo "Downloading $FILE..."
        if ! curl -s -O "$BASE_URL/$FILE"; then
            echo "Failed to download $FILE"
            exit 1
        fi
    else
        echo "$FILE already exists, skipping download."
    fi
done

# Set permissions for the downloaded files
chmod 750 *.sh
chmod 640 *.ulaw
chown root:asterisk *.sh *.ulaw 2>/dev/null || echo "Unable to set ownership (run as root for this step)"

# Create the environment configuration file
ENV_FILE="/etc/asterisk/local/allstar.env"
if [ ! -f "$ENV_FILE" ]; then
    cat <<EOF > "$ENV_FILE"
#!/bin/sh

# Defines the primary node (node) number
export NODE=$NODE_NUMBER

# Enable saying the local IP address at boot
# Default: "enabled"
export SAY_IP_AT_BOOT="enabled"
EOF
    chown root:root "$ENV_FILE"
    chmod 755 "$ENV_FILE"
else
    echo "$ENV_FILE already exists, skipping creation."
fi

# Ensure /etc/rc.local exists and starts with the shebang
RC_LOCAL="/etc/rc.local"
if [ ! -f "$RC_LOCAL" ]; then
    echo "Creating $RC_LOCAL..."
    echo "#!/bin/sh -e" > "$RC_LOCAL"
    chmod +x "$RC_LOCAL"
fi

# Add content to /etc/rc.local directly after the shebang
if ! grep -q "Source the AllStar variables" "$RC_LOCAL"; then
    echo "Adding configuration to $RC_LOCAL..."
    temp_content=$(mktemp)
    cat <<'RCLOCAL' > "$temp_content"
# Source the AllStar variables
if [ -f /etc/asterisk/local/allstar.env ]; then
    . /etc/asterisk/local/allstar.env
else
    echo "Unable to read /etc/asterisk/local/allstar.env file."
    echo "Asterisk will not start."
    exit 1
fi

if [ "$(echo "${SAY_IP_AT_BOOT}" | tr "[:upper:]" "[:lower:]")" = "enabled" ]; then
    sleep 12
    /etc/asterisk/local/sayip.sh "$NODE"
fi


RCLOCAL
    sed -i "2r $temp_content" "$RC_LOCAL"
    rm "$temp_content"
else
    echo "Configuration already exists in $RC_LOCAL, skipping modification."
fi

# Backup and modify the configuration file
if ! grep -q "cmd,/etc/asterisk/local/sayip.sh" "$CONF_FILE"; then
    echo "Backing up and modifying $CONF_FILE..."
    cp "$CONF_FILE" "${CONF_FILE}.bak"
    sed -i "/\[functions\]/a \\
A1 = cmd,/etc/asterisk/local/sayip.sh $NODE_NUMBER \\
A3 = cmd,/etc/asterisk/local/saypublicip.sh $NODE_NUMBER \\
B1 = cmd,/etc/asterisk/local/halt.sh $NODE_NUMBER \\
B3 = cmd,/etc/asterisk/local/reboot.sh $NODE_NUMBER \\
" "$CONF_FILE"
else
    echo "Commands already exist in $CONF_FILE, skipping modification."
fi

# Redirect final output to terminal (stdout)
{
    echo "ASL3 support for sayip/reboot/halt is configured for node $NODE_NUMBER."
    echo "Logs can be found in $LOG_FILE."
} > /dev/tty
