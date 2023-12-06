rm -rf caption && \
python3 -m venv caption  && \
source caption/bin/activate  && \
pip install pywhispercpp && \
chmod +x run.sh && \
. run.sh
