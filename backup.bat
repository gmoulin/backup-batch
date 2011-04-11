::SITES DATABASE DUMP + COMPRESS + BACKUP ON DROPBOX / SUGARSYNC / USB
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
	SET DUMPEXE="E:\wamp\bin\mysql\mysql5.5.8\bin\mysqldump.exe"
	SET TOOLDIR=E:\wamp\backup_tool\
	SET SITEDIR=E:\wamp\www\
	SET USBDIR=J:\
	SET DROPBOXDIR="G:\My Dropbox\"
	SET SUGARSYNCDIR="H:\sugarsync\"

) else (

	SET MYSQLUSER=root
	::SET MYSQLPASSWORD=
	SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
	SET DUMPEXE="D:\amp\MySQL5.1.52\bin\mysqldump.exe"
	SET TOOLDIR=D:\amp\backup_tool\
	SET SITEDIR=D:\amp\www\
	SET USBDIR=F:\
	SET DROPBOXDIR="D:\dropbox\My Dropbox\"
	SET SUGARSYNCDIR="D:\sugarsync\"
)

if (%SITEDIR%)==() goto fin2
if (%TARGET%)==() goto fin2


SET d=%DATE:~6,4%%DATE:~0,2%%DATE:~3,2%
SET t=%TIME:~0,2%%TIME:~3,2%%DATE:~6,2%

::DUMP THE DATABASES
::-p%MYSQLPASSWORD%
%DUMPEXE% --opt -u%MYSQLUSER% --quote-names --extended-insert --quick --databases %TARGET% > %TOOLDIR%%TARGET%.sql

::CD
%TOOLDIR:~0,2%
cd %TOOLDIR%

::COMPRESS DUMP
%ZIPEXE% a -t7z "%d%_%t%_database_%TARGET%.7z" "%TARGET%.sql" -mx9 -mmt=on -m0=PPMd

::MOVE DUMP (reduce upload time for online storage)
move /Y %TOOLDIR%"%TARGET%.sql" %USBDIR%%TARGET%_backup\

::BACKUP COMPRESSED DUMP
copy /V /Y %TOOLDIR%"%d%_%t%_database_%TARGET%.7z" %DROPBOXDIR%%TARGET%_backup\
copy /V /Y %TOOLDIR%"%d%_%t%_database_%TARGET%.7z" %SUGARSYNCDIR%%TARGET%_backup\
move /Y %TOOLDIR%"%d%_%t%_database_%TARGET%.7z" %USBDIR%%TARGET%_backup\

::EMPTY COVER FOLDER (not needed for suivfin)
if %TARGET%==lms ( del %SITEDIR%%TARGET%\covers\* /F /S /Q )

::CD
%SITEDIR:~0,2%
cd %SITEDIR%%TARGET%\

::COMPRESS SITE SOURCES
%ZIPEXE% a -t7z "%d%_%t%_site_%TARGET%.7z" %SITEDIR%%TARGET%\* -mx9 -mmt=on -m0=PPMd -x!publish -x!stash

::BACKUP COMPRESSED SOURCES
copy /V /Y %SITEDIR%%TARGET%\"%d%_%t%_site_%TARGET%.7z" %DROPBOXDIR%%TARGET%_backup\
copy /V /Y %SITEDIR%%TARGET%\"%d%_%t%_site_%TARGET%.7z" %SUGARSYNCDIR%%TARGET%_backup\
move /Y %SITEDIR%%TARGET%\"%d%_%t%_site_%TARGET%.7z" %USBDIR%%TARGET%_backup\

::CD
%TOOLDIR:~0,2%
cd %TOOLDIR%

::EMPTY FOLDER
attrib -S -R -H %DROPBOXDIR%backup_tool\* /S
del %DROPBOXDIR%backup_tool\* /F /S /Q

attrib -S -R -H %SUGARSYNCDIR%backup_tool\* /S
del %SUGARSYNCDIR%backup_tool\* /F /S /Q

attrib -S -R -H %USBDIR%backup_tool\* /S
del %USBDIR%backup_tool\* /F /S /Q

::BACKUP DUMP TOOL
xcopy %TOOLDIR%* %DROPBOXDIR%backup_tool\ /Y /R /E /H /Q
xcopy %TOOLDIR%* %SUGARSYNCDIR%backup_tool\ /Y /R /E /H /Q
xcopy %TOOLDIR%* %USBDIR%backup_tool\ /Y /R /E /H /Q

goto end

:fin
	echo parameter missing
	pause

:fin2
	echo wrong parameter value
	pause

:end
	pause