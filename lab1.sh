#!/bin/bash
LOG_DIR="$HOME/log"
LIMIT_MB=10
echo "enter an integet from 1 to 100"
read N
if ! [[ "$N" =~ [0-9]+$ ]]; then
    echo "error: enter an integer"
    exit 1
fi
if [ ! -d "$LOG_DIR" ]; then
    echo "error: the folder '$LOG_DIR' not found"
    echo "first, run test.sh to create the file"
    exit 1
fi
SIZE_MB=$(du -sm "$LOG_DIR" | awk '{print $1}')
PERCENT=$(awk -v size="$SIZE_MB" -v limit="$LIMIT_MB" 'BEGIN { printf "%.2f", (size / limit) * 100 }')
echo ""
echo "the folder size: $SIZE_MB mb, percentage of the limit: $PERCENT%"
echo "max: $N%"
echo ""

