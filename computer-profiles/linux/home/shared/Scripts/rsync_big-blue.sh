#!/bin/bash

#Sam Chambers 2011

#Source
SOURCE=/home

#Destination
DESTINATION=/mnt/home_backup

#Date
DATE=$(date +%F-%H-%M-%S)

#--hard-links for effciency, but t's somewhat expensive to check for the existence of hardlinks, as it has to keep track of the inode numbers
#Force file deletion
#--ignore-errors

sync

#Use Snapshot
#SOURCE=/mnt/home_snapshote
#lvcreate --size 2G --snapshot --name home_snapshot /dev/HOME/home
#mkdir -p /mnt/home_snapshot
#mount /dev/HOME/home_snapshot /mnt/home_snapshot

#Mount
mkdir -p $DESTINATION && \
mount /dev/HOME_BACKUP/home_backup $DESTINATION && echo "home_backup mounted"
wall "Backing up $SOURCE to $DESTINATION" && \
time /usr/bin/rsync --archive --acls --perms --one-file-system --hard-links --human-readable --verbose --stats --delete-before $SOURCE $DESTINATION >> /home/rsync_backup.log



#Clean up
sleep 3
umount $DESTINATION && rmdir $DESTINATION
#umount	/mnt/home_snapshot
#rmdir	/mnt/home_snapshot
#lvremove -f /dev/HOME/home_snapshot
sync

echo `date` DONE!
wall "BACKUP COMPLETE: `tail -n 2 /home/rsync_backup.log | head -n 1`  `tail -n 1 /home/rsync_backup.log`";




