# Check if virtual environment is active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Move to the parent directory of the script
cd "$SCRIPT_DIR"/ && \

sudo snap install yq && \

# Remove existing "caption" directory
rm -rf caption && \

# Create and activate virtual environment
python3 -m venv caption && \
source caption/bin/activate && \

# Install dependencies
pip install pywhispercpp && \
sudo apt install python3 python3-pip libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-3.0 python3-gi python3-gi-cairo && \
python3 -m pip install --upgrade pyonfx && \

# Make run.sh executable and execute it
chmod +x run.sh && \
. run.sh
