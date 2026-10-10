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
if awk -v p="$PERCENT" -v n="$N" 'BEGIN {exit !(p <= n)}'; then
	echo "Everything is fine, folder isn't exceeding the $N% limit."
else
	echo "Limit excedeed! Strartig acrhiving..."

	DIFF_PERCENT=$(awk -v p="$PERCENT" -v n="$N" 'BEGIN{ printf "%2.f", p - n}')
	LIMIT_KB=$((LIMIT_MB * 1024))
	DIFF_KB=$(awk -v limit="$LIMIT_KB" -v diff_percent="$DIFF_PERCENT" \
	 'BEGIN{printf "%d", (limit * diff_percent) / 100 }')

	FREED_KB=0
	FILES_TO_ARCHIVE=""
	COUNT=0

	while IFS= read -r FILE; do
		FILE_SIZE=$(du -k "$FILE" | cut -f1)
		FILES_TO_ARCHIVE="$FILES_TO_ARCHIVE $FILE"
		FREED_KB=$(( FREED_KB + FILE_SIZE ))
		COUNT=$(( COUNT + 1 ))

		if [ "$FREED_KB" -ge "$DIFF_KB" ]; then
			break
		fi

	done < <(find "$LOG_DIR" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)

	if [ "$COUNT" -eq 0 ]; then
		echo "Nothing to archive."
	else
		mkdir -p "$HOME"/backup
		ARCHIVE="$HOME/backup/log_archive.tar.gz"

		if tar -czf "$ARCHIVE" $FILES_TO_ARCHIVE; then
			rm $FILES_TO_ARCHIVE
			echo "Archived $COUNT files"
			echo "$FREED_KB KB freed"
			echo "Archive $ARCHIVE writed"
		else
			echo "ERROR of ARHIVATION, files didn't deleted"
			exit 1
		fi
	fi	
fi
