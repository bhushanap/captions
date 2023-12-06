if [ -d "caption" ]; then
    source caption/bin/activate
else
    python3 -m venv caption && source caption/bin/activate
fi

python3 caption.py
