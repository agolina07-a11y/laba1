#!/bin/bash
LOG_DIR="$HOME/log"
LIMIT_MB=10
echo "start"
STEP=1
    PERCENT=$(( RANDOM % 100 + 1)) 
    mkdir -p "$LOG_DIR"
    TARGET_KB=$((LIMIT_MB * PERCENT * 1024 / 100))
    CURRENT_KB=0
    FILE_NUM=1
    while [ "$CURRENT_KB" -lt "$TARGET_KB" ]; do
      dd if=/dev/zero of="$LOG_DIR/file_${FILE_NUM}.bin" bs=100K count=1 2>/dev/null
      CURRENT_KB=$((CURRENT_KB + 100 ))
      FILE_NUM=$((FILE_NUM + 1))
    done
    echo "files have been created: $((FILE_NUM - 1)) total: $CURRENT_KB kb"
    echo ""
    STEP=$((STEP +1))
echo "finish. folder: $LOG_DIR"
