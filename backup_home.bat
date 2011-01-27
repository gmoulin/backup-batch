::LMS DATABASE DUMP + COMPRESS + GIT + BACKUP ON DROPBOX / SUGARSYNC / USB
cls

::SETTINGS
SET MYSQLUSER=root
::SET MYSQLPASSWORD=
SET DBNAME=lms
SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
SET DUMPEXE="E:\wamp\bin\mysql\mysql5.1.41\bin\mysqldump.exe"
SET TOOLDIR=E:\wamp\backup_tool\
SET LMSDIR=E:\wamp\www\lms\
SET USBDIR=J:\
SET DROPBOXDIR="G:\My Dropbox\"
SET SUGARSYNCDIR="H:\sugarsync\"
SET d=%DATE:~6,4%%DATE:~0,2%%DATE:~3,2%
SET t=%TIME:~0,2%%TIME:~3,2%%DATE:~6,2%

::DUMP THE DATABASES
::-p%MYSQLPASSWORD%
%DUMPEXE% --opt -u%MYSQLUSER% --quote-names --extended-insert --quick --databases %DBNAME% > %TOOLDIR%%DBNAME%.sql

::CD
cd %TOOLDIR%

::COMPRESS DUMP
%ZIPEXE% a -t7z "%d%_%t%_database_%DBNAME%.7z" "%DBNAME%.sql" -mx9 -mmt=on -m0=PPMd > nul 2> nul

::MOVE DUMP (reduce upload time for online storage)
move /Y %TOOLDIR%"%DBNAME%.sql" %USBDIR%lms_backup\

::BACKUP COMPRESSED DUMP
xcopy %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %DROPBOXDIR%lms_backup\ /Y /R /E /H /Q
xcopy %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %SUGARSYNCDIR%lms_backup\ /Y /R /E /H /Q
move /Y %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %USBDIR%lms_backup\

::EMPTY COVER FOLDER
del %LMSDIR%covers\* /S /Q > nul 2> nul

::CD
cd %LMSDIR%

::COMMIT DUMP AND TOOL
CMD /C git add *
CMD /C git commit -a -m "lms sources backup"
CMD /C git gc

::COMPRESS LMS SOURCES
%ZIPEXE% a -t7z "%d%_%t%_site_lms.7z" %LMSDIR%* -mx9 -mmt=on -m0=PPMd > nul 2> nul

::BACKUP COMPRESSED SOURCES
xcopy %LMSDIR%"%d%_%t%_site_lms.7z" %DROPBOXDIR%lms_backup\ /Y /R /E /H /Q
xcopy %LMSDIR%"%d%_%t%_site_lms.7z" %SUGARSYNCDIR%lms_backup\ /Y /R /E /H /Q
move /Y %LMSDIR%"%d%_%t%_site_lms.7z" %USBDIR%lms_backup\

::EMPTY FOLDER
rmdir %DROPBOXDIR%lms /S /Q > nul 2> nul
cd %DROPBOXDIR%
mkdir lms
rmdir %SUGARSYNCDIR%lms /S /Q > nul 2> nul
cd %SUGARSYNCDIR%
mkdir lms
rmdir %USBDIR%lms /S /Q > nul 2> nul
cd %USBDIR%
mkdir lms

::BACKUP SOURCE
xcopy %LMSDIR%* %DROPBOXDIR%lms\ /Y /R /E /H /Q
xcopy %LMSDIR%* %SUGARSYNCDIR%lms\ /Y /R /E /H /Q
xcopy %LMSDIR%* %USBDIR%lms\ /Y /R /E /H /Q

::CD
cd %TOOLDIR%

::COMMIT DUMP AND TOOL
CMD /C git add *
CMD /C git commit -a -m "backup tools for %DBNAME% save"
CMD /C git gc

::EMPTY FOLDER
del %DROPBOXDIR%backup_tool\* /S /Q > nul 2> nul
del %SUGARSYNCDIR%backup_tool\* /S /Q > nul 2> nul
del %USBDIR%backup_tool\* /S /Q > nul 2> nul

::BACKUP DUMP TOOL
xcopy %TOOLDIR%* %DROPBOXDIR%backup_tool\ /Y /R /E /H /Q
xcopy %TOOLDIR%* %SUGARSYNCDIR%backup_tool\ /Y /R /E /H /Q
xcopy %TOOLDIR%* %USBDIR%backup_tool\ /Y /R /E /H /Q