#!/bin/bash

TEMP_THRESHOLD=40

# Get list of hdds
if [[ $OSTYPE == "linux-gnu" ]]; then
    hdds=($( ls -ahl /dev/disk/by-id/ | egrep "ata|scsi" | grep -v "part" | \
awk -F "/" '{print $NF}'))
elif [[ $OSTYPE == "FreeBSD" ]]; then
    hdds=($( camcontrol devlist | grep ",da" | \
awk -F "[,)]" '{print $(( NF - 1 ))}' ))
fi
# echo "hdds: $hdds"

for hdd in "${hdds[@]}"; do

    smartctl_out=$( smartctl -A /dev/$hdd )

    # ATA
    temp=$( echo "$smartctl_out" | grep "Temperature_Celsius" | \
awk '{print $10}' )

    # SCSI
    if [[ $temp == "" ]]; then
        # echo "trying scsi..."
        temp=$( echo "$smartctl_out" | grep "Current Drive Temperature" | \
awk '{print $(( NF - 1 ))}' )
    fi

    if [[ $temp != "" ]]; then
        echo "$hdd: ${temp}C"

        temp=40
        if [[ $temp -ge $TEMP_THRESHOLD ]]; then
            echo "HDD temp is over ${TEMP_THRESHOLD}C! Initiating emergency \
poweroff..." >&2
            echo "poweroff"
            break
        fi
    fi

done
