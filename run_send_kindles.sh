#!/bin/bash
# Linux/macOS
set -a
source .env
set +a

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

python3 send_kindles.py \
    --folder "$CBZ_FOLDER" \
    --profile "$KCC_PROFILE" \
    --kcc-cmd "$KCC_CMD" \
    --kindle-address "$KINDLE_ADDRESS" \
    >> "$LOG_DIR/send_kindles.log" 2>&1