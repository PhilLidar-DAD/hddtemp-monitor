# hddtemp-monitor

Instructions
============

If the storage provider is a Virtual Machine,it must also tell the proxmox  host to shutdown.

Configure the proxmox host:
1. Get the VM's root account public key
```root@storagevm$ cat /root/.ssh/id_rsa.pub
```

2. Add the public key to the proxmox host's root account authorized_keys file
```root@proxmox$ nano /root/.ssh/authorized_keys
```
3. deploy the script to the VM
```root@storagevm[/mnt/storage_pool/scripts/sysad-tools]$ git clone https://github.com/PhilLidar-DAD/hddtemp-monitor
```

4. Edit the script and assign the proxmox host's FQDN to the VM_HOST variable
```root@storagevm[/mnt/storage_pool/scripts/sysad-tools/hddtemp-monitor]$ nano hddtemp_monitor.sh
```

```hddtemp_monitor.sh

VM_HOST="proxmox.srv.dream.upd.edu.ph"
```

5. Add the script to the VM's crontab

```/mnt/storage_pool/scripts/sysad-tools/hddtemp-monitor/hddtemp_monitor.sh &>/dev/null
```

Otherwise, if the Storage Provider is bare metal:

1. Deploy the script
2. Add it to the crontab
