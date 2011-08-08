#!/bin/sh
# backup script

#check parameters
if [ $# -ne 2 ]; then
	echo "Missing parameters, usage: backup.sh environnement project."
	exit 1
fi

ENV=$1
PROJECT=$2
D=$(date +%Y%m%d_%H%M%S)

#check ENV
if [ ${ENV} != 'home' -a ${ENV} != 'work' ]; then
	echo "unknown environnement"
	exit 1
fi

if [ ${ENV} = 'work' ]; then
	DROPBOXDIR=/home/gmoulin/Dropbox/
	USBDIR=/media/WARP/gmoulin/
else
	DROPBOXDIR=""
	USBDIR=""
fi

#check DROPBOXDIR
if [ ! -d ${DROPBOXDIR} ]; then
	echo "dropbox directory not found"
	exit 1
fi

#check USBDIR
if [ ! -d ${USBDIR} ]; then
	echo "usb key mount directory not found"
	exit 1
fi

#check PROJECT
if [ ${PROJECT} != 'lms' -a ${PROJECT} != 'suivfin' ]; then
	echo "unknown project"
	exit 1
fi

#folder for the uploads
echo "preparing upload temp folder (/tmp/upload/)"
cd /tmp/
if [ -d upload ]; then
	rm -rf upload/* upload/.??*
else
	mkdir upload
fi

#EMPTY COVER FOLDER (not needed for suivfin)
if [ ${PROJECT} = 'lms' ]; then
	echo "cleaning covers (/var/www/${PROJECT}/covers/)"
	rm -rf /var/www/${PROJECT}/covers/* /var/www/${PROJECT}/covers/.??*
fi

#COMPRESS SITE SOURCES
cd /var/www/
#chech if project folder exists
if [ -d ${PROJECT} ]; then
	echo "creating archive (/tmp/upload/${D}_${PROJECT}_site.tar.gz)"
	tar -zcf /tmp/upload/${D}_${PROJECT}_site.tar.gz ${PROJECT}/ --exclude 'intermediate' --exclude 'publish' --exclude 'stash' --exclude 'smarty/templates_c/*' --exclude 'smarty/cache/*'
else
	echo "project folder not found (/var/www/${PROJECT})"
	exit 1
fi

#::BACKUP COMPRESSED SOURCES
echo "copy archive to dropbox (${DROPBOXDIR}${PROJECT}_backup/)"
cp -rf /tmp/upload/${D}_${PROJECT}_site.tar.gz ${DROPBOXDIR}${PROJECT}_backup/
echo "copy archive to usb key (${USBDIR}${PROJECT}_backup/)"
cp -rf /tmp/upload/${D}_${PROJECT}_site.tar.gz ${USBDIR}${PROJECT}_backup/

#BACKUP backup-batch
echo "copy backup batches to dropbox (${DROPBOXDIR}backup_tool/)"
cp -rf /home/gmoulin/backup-batch/* ${DROPBOXDIR}backup_tool/
echo "copy backup batches to usb key (${USBDIR}backup_tool/)"
cp -rf /home/gmoulin/backup-batch/* ${USBDIR}backup_tool/

#GIT
git config --global http.proxy ''
echo "Git commit and push project"
cd /var/www/${PROJECT}/
git add .
git commit -a -m "automatic commit from backup script"
git gc
git push https://gmoulin@github.com/gmoulin/${PROJECT}.git

#GIT
echo "Git commit and push backup batches"
cd /home/gmoulin/backup-batch/
git add .
git commit -a -m "automatic commit from backup script"
git gc
git push https://gmoulin@github.com/gmoulin/backup-batch.git

#FTP
#http://manpages.ubuntu.com/manpages/natty/man1/ftp-upload.1p.html
echo "send archive to FTP server (/tmp/upload/${D}_${PROJECT}_site.tar.gz -> ftp.drivehq.com in /My Documents/dev_backup/)"
ftp-upload -v --user gmoulin --password b4cKup5 --host ftp.drivehq.com --dir "/My Documents/dev_backup/" /tmp/upload/${D}_${PROJECT}_site.tar.gz

#CLEANING
echo "cleaning upload temp folder"
rm -rf /tmp/upload/* /tmp/upload/.??*

echo "backup done"
exit 0

