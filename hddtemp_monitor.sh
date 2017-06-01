#!/bin/bash

VM_HOST=""
TEMP_THRESHOLD=45

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
			HOST="${VM_HOST:+$VM_HOST & }$(hostname)"
            title="Emergency shutdown on $HOST)!"

            hdd_info=$( echo "$smartctl_out" | egrep -i "device model:|product:|serial number:" )

            err_msg="$hdd_info\n\nHDD temp (${temp}C) is over ${TEMP_THRESHOLD}C! Initiating emergency \
poweroff..."

            # Log to stderr
            echo -e "\n${title}\n\n${err_msg}\n" >&2

            # Broadcast to wall
            echo -e "\n${title}\n\n${err_msg}\n" | wall

            # Send email
            (echo "Subject: $title"; echo; echo -e "$err_msg") | sendmail dad@dream.upd.edu.ph

			#shutdown the host
			if [[ -n $VM_HOST ]]; then
				ssh root@#VM_HOST poweroff
			fi
            poweroff
            break
        fi
    fi

done
