# Check if virtual environment is active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Move to the parent directory of the script
cd "$SCRIPT_DIR"/ && \

# Remove existing "caption" directory
rm -rf caption

# Create and activate virtual environment
python3 -m venv caption
source caption/bin/activate

# Install dependencies
pip install pywhispercpp

# Make run.sh executable and execute it
chmod +x run.sh
. run.sh
