::LMS DATABASE AND SITE DEPLOY
cls

::LOCATION PARAMETER
if (%1)==() goto fin

::SITE PARAMETER
if (%2)==() goto fin

set TARGET=%2
SET SITEDIR=

::SETTINGS
if %1==HOME (
	SET MYSQLUSER=root
	::SET MYSQLPASSWORD=
	SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
	SET TOOLDIR=E:\wamp\backup_tool\
	SET DBEXE="E:\wamp\bin\mysql\mysql5.1.41\bin\mysql.exe"

	SET SITEDIR=E:\wamp\www\

	SET DROPBOXDIR="G:\My Dropbox\"
	SET SUGARSYNCDIR="H:\sugarsync\"

) else (

	SET MYSQLUSER=root
	::SET MYSQLPASSWORD=
	SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
	SET TOOLDIR=D:\amp\backup_tool\
	SET DBEXE="D:\amp\MySQL5.1.52\bin\mysql.exe"

	SET SITEDIR=D:\amp\www\

	SET DROPBOXDIR="D:\dropbox\My Dropbox\"
	SET SUGARSYNCDIR="D:\sugarsync\"
	SET USBDIR=F:\
)

SET BACKUPDIR=%DROPBOXDIR%%TARGET%_backup\


if (%SITEDIR%)==() goto fin2
if (%TARGET%)==() goto fin2
if not exist %BACKUPDIR% goto fin2

::FIND LAST BACKUP FOR DATABASE DUMP
for /f "tokens=*" %%a in ('dir %BACKUPDIR%*_database_%TARGET%.7z /b /a-d /o:n') do (SET lfile=%%a)
copy /y %BACKUPDIR%%lfile% %TOOLDIR%database.7z

::DECOMPRESS DUMP
%ZIPEXE% x %TOOLDIR%database.7z -o%TOOLDIR% -y > nul 2> nul

::REPLACE THE DATABASE WITH DUMP
::-p%MYSQLPASSWORD%
%DBEXE% -u%MYSQLUSER% --database %TARGET% < %TOOLDIR%%TARGET%.sql

::DELETE DUMP AND BACKUP
del %TOOLDIR%%TARGET%.sql /S /Q
del %TOOLDIR%database.7z /S /Q


::FIND LAST BACKUP FOR SITE DUMP
for /f "tokens=*" %%a in ('dir %BACKUPDIR%*_site_%TARGET%.7z /b /a-d /o:n') do (SET lfile=%%a)
copy /y %BACKUPDIR%%lfile% %TOOLDIR%site.7z

::EMPTY SITE FOLDER
rmdir %SITEDIR%%TARGET%\ /S /Q
%SITEDIR:~0,2%
cd %SITEDIR%
mkdir %TARGET%

::DECOMPRESS SITE DUMP
%ZIPEXE% x %TOOLDIR%site.7z -o%SITEDIR%%TARGET%\ -y > nul 2> nul
	
::DELETE SITE BACKUP
del %TOOLDIR%site.7z /S /Q > nul 2> nul

::EMPTY STASH
%SITEDIR:~0,2%
cd %SITEDIR%%TARGET%\
rmdir %SITEDIR%%TARGET%\stash /S /Q

::RUN ANT BUILD
%SITEDIR:~0,2%
cd %SITEDIR%%TARGET%\build\
CMD /C ant text

goto end

:fin
	echo parameter missing
	pause

:fin2
	echo wrong parameter value
	pause

:end
