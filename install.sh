deactivate && \
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Move to the parent directory of the script
cd "$SCRIPT_DIR"/ && \

rm -rf caption && \
python3 -m venv caption  && \
source caption/bin/activate  && \
pip install pywhispercpp && \
chmod +x run.sh && \
. run.sh
