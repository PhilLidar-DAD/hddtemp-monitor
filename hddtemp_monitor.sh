#!/bin/bash

# Get list of hdds
if [[ $OSTYPE == "linux-gnu" ]]; then
    HDDS=$( ls /dev/disk/by-id/ | egrep "ata|scsi" | grep -v part )
elif [[ $OSTYPE == "FreeBSD" ]]; then
fi
echo "HDDS: $HDDS"
