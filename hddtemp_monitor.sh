#!/bin/bash

TEMP_THRESHOLD=40

# Get list of hdds
if [[ $OSTYPE == "linux-gnu" ]]; then
    HDDS=$( ls /dev/disk/by-id/ | egrep "ata|scsi" | grep -v "part" )
elif [[ $OSTYPE == "FreeBSD" ]]; then
    HDDS=$( camcontrol devlist | grep ",da" | \
awk -F "[,)]" '{print $(( NF - 1 ))}' )
fi
# echo "HDDS: $HDDS"

for HDD in "${HDDS[@]}"; do
    echo "$HDD"
    smartctl=$( smartctl /dev/$HDD )

done
