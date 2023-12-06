deactivate && \
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Move to the parent directory of the script
cd "$SCRIPT_DIR"/ && \

if [ -d "caption" ]; then
    source caption/bin/activate
else
    python3 -m venv caption && source caption/bin/activate
fi

python3 caption.py
