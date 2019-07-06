#!/bin/bash

TEMP_THRESHOLD=45
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo "$SCRIPT_DIR"

echo -e "Checking HDD temps..." | logger

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

    smartctl_out=$( smartctl -a /dev/$hdd )

    # ATA
    temp=$( echo "$smartctl_out" | grep "Temperature_Celsius" | \
awk '{print $10}' )

    # SCSI
    if [[ $temp == "" ]]; then
        temp=$( echo "$smartctl_out" | grep "Current Drive Temperature" | \
awk '{print $(( NF - 1 ))}' )
    fi

    if [[ $temp != "" ]]; then
        echo "$hdd: ${temp}C"

        if [[ $temp -gt $TEMP_THRESHOLD ]]; then

            title="Emergency shutdown on $( hostname )!"

            hdd_info=$( echo "$smartctl_out" | egrep -i "device model:|product:|serial number:" )

            err_msg="$hdd_info\n\nHDD temp (${temp}C) is over ${TEMP_THRESHOLD}C! Initiating emergency \
poweroff..."

            # Log to stderr
            echo -e "\n${title}\n\n${err_msg}\n" >&2

            # Log to syslog
            echo -e "\n${title}\n\n${err_msg}\n" | logger

            # Broadcast to wall
            echo -e "\n${title}\n\n${err_msg}\n" | wall

            # Send to slack
            (echo "$title"; echo; echo -e "$err_msg") | ${SCRIPT_DIR}/slacktee.sh -e "Date and Time" "$(date)" -u "$(hostname)" -a "good" -o "danger" "^Emergency" > /dev/null

            # Send email
            (echo "Subject: $title"; echo; echo -e "$err_msg") | sendmail dad@dream.upd.edu.ph

            # Allow message to be sent
            sleep 60

            poweroff
            break
        fi
    fi

done
