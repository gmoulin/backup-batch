::SITES DATABASE DUMP + COMPRESS + GIT + BACKUP ON DROPBOX / SUGARSYNC / USB
cls

::LOCATION PARAMETER
if (%1)==() goto fin

set DBNAMES=(lms suivfin)
SET SITEDIR=

::SETTINGS
if %1==HOME (

	SET MYSQLUSER=root
	::SET MYSQLPASSWORD=
	SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
	SET DUMPEXE="E:\wamp\bin\mysql\mysql5.1.41\bin\mysqldump.exe"
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


SET d=%DATE:~6,4%%DATE:~0,2%%DATE:~3,2%
SET t=%TIME:~0,2%%TIME:~3,2%%DATE:~6,2%

	::DUMP THE DATABASES
	::-p%MYSQLPASSWORD%
	::for %%i in %DBNAMES% do %DUMPEXE% --opt -u%MYSQLUSER% --quote-names --extended-insert --quick --databases %%i > %TOOLDIR%%%i.sql

	::CD
	::%TOOLDIR:~0,2%
	::cd %TOOLDIR%

	::COMPRESS DUMP
	::for %%i in %DBNAMES% do %ZIPEXE% a -t7z "%d%_%t%_database_%%i.7z" "%%i.sql" -mx9 -mmt=on -m0=PPMd

	::MOVE DUMP (reduce upload time for online storage)
	::for %%i in %DBNAMES% do move /Y %TOOLDIR%"%%i.sql" %USBDIR%%%i_backup\

	::BACKUP COMPRESSED DUMP
	::for %%i in %DBNAMES% do copy /V /Y %TOOLDIR%"%d%_%t%_database_%%i.7z" %DROPBOXDIR%%%i_backup\
	::for %%i in %DBNAMES% do copy /V /Y %TOOLDIR%"%d%_%t%_database_%%i.7z" %SUGARSYNCDIR%%%i_backup\
	::for %%i in %DBNAMES% do move /Y %TOOLDIR%"%d%_%t%_database_%%i.7z" %USBDIR%%%i_backup\

	::EMPTY COVER FOLDER (not needed for suivfin)
	::for %%i in %DBNAMES% do del %SITEDIR%%%i\covers\* /F /S /Q

	::TODO FACTORIZE
		::CD
		%SITEDIR:~0,2%
		cd %SITEDIR%lms\

		::COMMIT DUMP AND TOOL
		CMD /C git add * 
		CMD /C git commit -a -m "lms sources backup"
		CMD /C git gc

		::CD
		cd %SITEDIR%suivfin\

		::COMMIT DUMP AND TOOL
		CMD /C git add * 
		CMD /C git commit -a -m "suivfin sources backup"
		CMD /C git gc

	::COMPRESS SITE SOURCES
	for %%i in %DBNAMES% do %ZIPEXE% a -t7z "%d%_%t%_site_%%i.7z" %SITEDIR%%%i\* -mx9 -mmt=on -m0=PPMd

	::BACKUP COMPRESSED SOURCES
	for %%i in %DBNAMES% do copy /V /Y %SITEDIR%%%i\"%d%_%t%_site_%%i.7z" %DROPBOXDIR%%%i_backup\
	for %%i in %DBNAMES% do copy /V /Y %SITEDIR%%%i\"%d%_%t%_site_%%i.7z" %SUGARSYNCDIR%%%i_backup\
	for %%i in %DBNAMES% do move /Y %SITEDIR%%%i\"%d%_%t%_site_%%i.7z" %USBDIR%%%i_backup\

	::EMPTY FOLDER
	for %%i in %DBNAMES% do attrib -S -R -H %DROPBOXDIR%%%i\* /S
	for %%i in %DBNAMES% do rmdir %DROPBOXDIR%%%i /S /Q
	%DROPBOXDIR:~1,2%
	cd %DROPBOXDIR%
	for %%i in %DBNAMES% do mkdir %%i

	for %%i in %DBNAMES% do attrib -S -R -H %SUGARSYNCDIR%%%i\* /S
	for %%i in %DBNAMES% do rmdir %SUGARSYNCDIR%%%i /S /Q
	%SUGARSYNCDIR:~1,2%
	cd %SUGARSYNCDIR%
	for %%i in %DBNAMES% do mkdir %%i

	for %%i in %DBNAMES% do attrib -S -R -H %USBDIR%%%i\* /S
	for %%i in %DBNAMES% do rmdir %USBDIR%%%i /S /Q
	%USBDIR:~0,2%
	cd %USBDIR%
	for %%i in %DBNAMES% do mkdir %%i

	::BACKUP SOURCE
	for %%i in %DBNAMES% do xcopy %SITEDIR%%%i\* %DROPBOXDIR%%%i\ /Y /R /E /H /Q
	for %%i in %DBNAMES% do xcopy %SITEDIR%%%i\* %SUGARSYNCDIR%%%i\ /Y /R /E /H /Q
	for %%i in %DBNAMES% do xcopy %SITEDIR%%%i\* %USBDIR%%%i\ /Y /R /E /H /Q

	::CD
	%TOOLDIR:~0,2%
	cd %TOOLDIR%

	::COMMIT DUMP AND TOOL
	CMD /C git add *
	CMD /C git commit -a -m "backup tools save"
	CMD /C git gc

	::EMPTY FOLDER
	for %%i in %DBNAMES% do attrib -S -R -H %DROPBOXDIR%backup_tool\* /S
	for %%i in %DBNAMES% do del %DROPBOXDIR%backup_tool\* /F /S /Q

	for %%i in %DBNAMES% do attrib -S -R -H %SUGARSYNCDIR%backup_tool\* /S
	for %%i in %DBNAMES% do del %SUGARSYNCDIR%backup_tool\* /F /S /Q

	for %%i in %DBNAMES% do attrib -S -R -H %USBDIR%backup_tool\* /S
	for %%i in %DBNAMES% do del %USBDIR%backup_tool\* /F /S /Q

	::BACKUP DUMP TOOL
	for %%i in %DBNAMES% do xcopy %TOOLDIR%* %DROPBOXDIR%backup_tool\ /Y /R /E /H /Q
	for %%i in %DBNAMES% do xcopy %TOOLDIR%* %SUGARSYNCDIR%backup_tool\ /Y /R /E /H /Q
	for %%i in %DBNAMES% do xcopy %TOOLDIR%* %USBDIR%backup_tool\ /Y /R /E /H /Q

	goto end

:fin
	echo parameter missing
	pause

:fin2
	echo wrong location
	pause

:end
	pause