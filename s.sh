#!/bin/bash
log_dir="$1"

if [ ! -d "$log_dir" ]; then 
	echo "Log_dir not found"
	exit 1
fi

limit_kb="$2"
size_l_d=$(du -sk "$papka" | awk -v lim="$limit_kb" '{print ($1/lim) * 100}')

percent_l_d="$3"
files_del="$4"

s=$(awk -v r="$size_l_d" -v p="$percent_l_d" 'BEGIN {print (r > p) ? 1 : 0}')

if [ "$s" -eq 0 ]; then
	echo "all okay"
	exit 0
else
	sudo mkdir -p backup
	find "$log_dir" -maxdepth 1 -type f -printf "%T@ %p\n" | sort -n | head -n "$files" | awk '{print $2}' | \
	tar -czf "backup/backup_$(date +%Y%m%d_%H%M%S).tar.gz" -T - --remove-files
fi
