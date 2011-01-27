::LMS DATABASE AND SITE DEPLOY
cls

::SETTINGS
SET MYSQLUSER=root
::SET MYSQLPASSWORD=
SET DBNAME=lms
SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
SET TOOLDIR=D:\amp\backup_tool\
SET DBEXE="D:\amp\MySQL5.1.52\bin\mysql.exe"

SET SITEDIR=D:\amp\www\lms\
SET SITEPARENTDIR=D:\amp\www\
SET SITEFOLDER=lms

SET DROPBOXDIR="D:\dropbox\My Dropbox\"
SET SUGARSYNCDIR="D:\sugarsync\"
SET USBDIR=F:\
SET BACKUPDIR=%USBDIR%lms_backup\

::FIND LAST BACKUP FOR DATABASE DUMP
for /f "tokens=*" %%a in ('dir %BACKUPDIR%*_database_%DBNAME%.7z /b /a-d /o:n') do (SET lfile=%%a)
copy /y %BACKUPDIR%%lfile% %TOOLDIR%database.7z

::DECOMPRESS DUMP
%ZIPEXE% x %TOOLDIR%database.7z -o%TOOLDIR% -y > nul 2> nul

::REPLACE THE DATABASE WITH DUMP
::-p%MYSQLPASSWORD%
%DBEXE% -u%MYSQLUSER% --database %DBNAME% < %TOOLDIR%%DBNAME%.sql

::DELETE DUMP AND BACKUP
del %TOOLDIR%%DBNAME%.sql /S /Q
del %TOOLDIR%database.7z /S /Q


::FIND LAST BACKUP FOR SITE DUMP
for /f "tokens=*" %%a in ('dir %BACKUPDIR%*_site_%DBNAME%.7z /b /a-d /o:n') do (SET lfile=%%a)
copy /y %BACKUPDIR%%lfile% %TOOLDIR%site.7z

::EMPTY SITE FOLDER
rmdir %SITEDIR% /S /Q
cd %SITEPARENTDIR%
mkdir %SITEFOLDER%

::DECOMPRESS SITE DUMP
%ZIPEXE% x %TOOLDIR%site.7z -o%SITEDIR% -y > nul 2> nul
	
::DELETE SITE BACKUP
del %TOOLDIR%site.7z /S /Q > nul 2> nul
