#!/bin/sh -e

# This script installs all needed files for sayip/saypublicip/halt/reboot
# It will also create and modify /etc/rc.local so the IP is announced
# upon system boot.
# Copyright (C) 2024 Jory A. Pratt - W5GLE
# Released under the GNU General Public License v2 or later.

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
    if ! curl -s -O "$BASE_URL/$FILE"; then
        echo "Failed to download $FILE"
        exit 1
    fi
done

# Set permissions for the downloaded files
chmod 750 *.sh
chmod 640 *.ulaw
chown root:asterisk *.sh *.ulaw 2>/dev/null || echo "Unable to set ownership (run as root for this step)"

# Create the environment configuration file
cat <<EOF > /etc/asterisk/local/allstar.env
#!/bin/sh

# Defines the primary node (node) number
export NODE=$NODE_NUMBER

# Enable saying the local IP address at boot
# Default: "enabled"
export SAY_IP_AT_BOOT="enabled"
EOF

chown root:root /etc/asterisk/local/allstar.env
chmod 755 /etc/asterisk/local/allstar.env

# Ensure /etc/rc.local exists and starts with the shebang
if [ ! -f /etc/rc.local ]; then
    echo "#!/bin/sh -e" > /etc/rc.local
    chmod +x /etc/rc.local
fi

# Add content to /etc/rc.local directly after the shebang
if ! grep -q "Source the AllStar variables" /etc/rc.local; then
    if ! head -n 1 /etc/rc.local | grep -q "^#!/bin/sh -e"; then
        sed -i "1i#!/bin/sh -e" /etc/rc.local
    fi

    # Use a here document to safely append multi-line content
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

    # Insert the content directly after the shebang
    sed -i "2r $temp_content" /etc/rc.local
    rm "$temp_content"
fi

# Backup and modify the configuration file
cp "$CONF_FILE" "${CONF_FILE}.bak"
sed -i "/\[functions\]/a \\
A1 = cmd,/etc/asterisk/local/sayip.sh $NODE_NUMBER \\
A3 = cmd,/etc/asterisk/local/saypublicip.sh $NODE_NUMBER \\
B1 = cmd,/etc/asterisk/local/halt.sh $NODE_NUMBER \\
B3 = cmd,/etc/asterisk/local/reboot.sh $NODE_NUMBER \\
" "$CONF_FILE"

echo "ASL3 support for sayip/reboot/halt is configured for node $NODE_NUMBER."
