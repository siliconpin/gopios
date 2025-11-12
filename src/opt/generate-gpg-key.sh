#!/bin/bash
set -e  # Exit on any error

BATCH_FILE=$(mktemp)
cat > "$BATCH_FILE" << 'EOF'
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: REPLACE_NAME
Name-Email: REPLACE_EMAIL
Expire-Date: 0
%no-protection
%commit
EOF

# Get user info safely
USER_NAME=$(getent passwd "$(whoami)" | cut -d: -f5 | cut -d, -f1)
USER_EMAIL="$(whoami)@$(hostname)"

# Sanitize inputs (basic sanitization)
USER_NAME=${USER_NAME:-$(whoami)}
USER_EMAIL=$(echo "$USER_EMAIL" | tr -d '\n' | cut -c-100)

# Replace placeholders
sed -i "s/REPLACE_NAME/$USER_NAME/g" "$BATCH_FILE"
sed -i "s/REPLACE_EMAIL/$USER_EMAIL/g" "$BATCH_FILE"

gpg --batch --generate-key "$BATCH_FILE"
gpg --armor --export "$USER_EMAIL" > "$HOME/Desktop/$USER_NAME-gpg_public-key.asc"

# Cleanup
rm -f "$BATCH_FILE"
rm ~/.config/autostart/gpg-first-run.desktop
# echo "✓ Temporary files cleaned up"