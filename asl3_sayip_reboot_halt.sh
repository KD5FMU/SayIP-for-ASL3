#!/bin/sh

# This script installs all needed files for sayip/saypublicip/halt/reboot
# It will also create and or modify /etc/rc.local so ip is announced upon
# the system booting.
# Copyright (C) 2024 Jory A. Pratt - W5GLE
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <NodeNumber>"
    exit 1
fi

NODE_NUMBER=$1

CONF_FILE="/etc/asterisk/rpt.conf"
BASE_URL="https://dev.gentoo.org/~anarchy/asl3-scripts"
TARGET_DIR="/etc/asterisk/local"
FILES_TO_DOWNLOAD="halt.sh reboot.sh sayip.sh saypublicip.sh speaktext.sh halt.ulaw reboot.ulaw ip-address.ulaw public-ip-address.ulaw"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR" || {
        echo "Failed to create directory $TARGET_DIR"
        exit 1
    }
fi

cd "$TARGET_DIR" || {
    echo "Failed to change directory to $TARGET_DIR"
    exit 1
}

for FILE in $FILES_TO_DOWNLOAD; do
    curl -O "$BASE_URL/$FILE" > /dev/null 2>&1 || {
        echo "Failed to download $FILE"
        exit 1
    }
done

chmod +x *.sh

chown root:asterisk *.sh *.ulaw 2>/dev/null || echo "Unable to set ownership (run as root for this step)"
chmod 750 *.sh
chmod 640 *.ulaw

cat <<EOF > /etc/asterisk/local/allstar.env
#!/bin/sh

# defines the primary node (node) number
export NODE=$NODE

# Defines saying of local IP address at boot (enabled or disabled)
# Default: "enabled"
export SAY_IP_AT_BOOT="enabled"
EOF

chown root:root /etc/asterisk/local/allstar.env
chmod 755 /etc/asterisk/local/allstar.env

CONTENT="
# Source the allstar variables
if [ -f /etc/asterisk/local/allstar.env ]; then
    . /etc/asterisk/local/allstar.env
else
    echo \"Unable to read /etc/asterisk/local/allstar.env file.\"
    echo \"Asterisk will not start.\"
    exit 1
fi

if [ \"\$(echo \"\${SAY_IP_AT_BOOT}\" | tr \"[:upper:]\" \"[:lower:]\")\" = \"enabled\" ]; then
    sleep 12
    /etc/asterisk/local/sayip.sh \"$NODE\"
fi
"

if [ -f /etc/rc.local ]; then
    if ! head -n 1 /etc/rc.local | grep -q "^#!/bin/sh"; then
        { echo "#!/bin/sh"; cat /etc/rc.local; } > /tmp/rc.local.tmp
        mv /tmp/rc.local.tmp /etc/rc.local
    fi
    if ! grep -q "Source the allstar variables" /etc/rc.local; then
        printf "%s\n" "$CONTENT" >> /etc/rc.local
    fi
else
    {
        echo "#!/bin/sh"
        printf "%s\n" "$CONTENT"
    } > /etc/rc.local
    chmod +x /etc/rc.local
fi

cp "$CONF_FILE" "${CONF_FILE}.bak"
sed -i "/\\[functions\\]/a \\
A1 = cmd,/etc/asterisk/local/sayip.sh $NODE_NUMBER \\
A3 = cmd,/etc/asterisk/local/saypublicip.sh $NODE_NUMBER \\
B1 = cmd,/etc/asterisk/local/halt.sh $NODE_NUMBER \\
B3 = cmd,/etc/asterisk/local/reboot.sh $NODE_NUMBER \\
" "$CONF_FILE"

echo "ASL3 now has support for sayip/reboot/halt configured for node $NODE_NUMBER..."
