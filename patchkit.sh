#!/bin/bash

AWXKIT_DIR="/usr/local/lib/python3.12/site-packages/awxkit"
CLIENT_FILE="$AWXKIT_DIR/cli/client.py"
UTILS_FILE="$AWXKIT_DIR/cli/utils.py"

echo "[+] Patching awxkit for Python 3.12 compatibility..."

###########################
# 1) Patch client.py (remove pkg_resources, add importlib.metadata)
###########################

echo "[+] Updating client.py imports..."

# Remove old pkg_resources import
sed -i '/import pkg_resources/d' "$CLIENT_FILE"

# Insert importlib.metadata above __version__
sed -i '1a \
try:\n    from importlib.metadata import version as pkg_version\nexcept ImportError:\n    from importlib_metadata import version as pkg_version\n' "$CLIENT_FILE"

# Replace __version__ assignment
sed -i "s/__version__ = .*/__version__ = pkg_version('awxkit')/" "$CLIENT_FILE"

###########################
# 2) Patch HelpfulArgumentParser in utils.py
###########################

echo "[+] Fixing HelpfulArgumentParser for Python 3.12..."

# Replace entire _parse_known_args() with compatibility shim
sed -i '/def _parse_known_args/,/return/ c\
    def _parse_known_args(self, args, ns, intermixed=False):\n\
        \"\"\"\n\
        Compatibility shim for Python 3.12.8+ and 3.13.1+ argparse changes.\n\
        \"\"\"\n\
        super__parse_known_args = super(HelpfulArgumentParser, self)._parse_known_args\n\
        if super__parse_known_args.__code__.co_argcount == 3:\n\
            return super__parse_known_args(args, ns)\n\
        return super__parse_known_args(args, ns, intermixed)\n' "$UTILS_FILE"

echo "Patch complete!"
echo "Test with:  awx --help"
