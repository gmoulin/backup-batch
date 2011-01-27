::LMS DATABASE DUMP + COMPRESS + GIT + BACKUP ON DROPBOX / SUGARSYNC / USB
cls

::SETTINGS
SET MYSQLUSER=root
::SET MYSQLPASSWORD=
SET DBNAME=lms
SET ZIPEXE="C:\Program Files\7-Zip\7z.exe"
SET DUMPEXE="D:\amp\MySQL5.1.52\bin\mysqldump.exe"
SET TOOLDIR=D:\amp\backup_tool\
SET LMSDIR=D:\amp\www\lms\
SET USBDIR=F:\
SET DROPBOXDIR="D:\dropbox\My Dropbox\"
SET SUGARSYNCDIR="D:\sugarsync\"
SET d=%DATE:~6,4%%DATE:~0,2%%DATE:~3,2%
SET t=%TIME:~0,2%%TIME:~3,2%%DATE:~6,2%

::DUMP THE DATABASES
::-p%MYSQLPASSWORD%
%DUMPEXE% --opt -u%MYSQLUSER% --quote-names --extended-insert --quick --databases %DBNAME% > %TOOLDIR%%DBNAME%.sql

::CD
%TOOLDIR:~0,2%
cd %TOOLDIR%

::COMPRESS DUMP
%ZIPEXE% a -t7z "%d%_%t%_database_%DBNAME%.7z" "%DBNAME%.sql" -mx9 -mmt=on -m0=PPMd

::MOVE DUMP (reduce upload time for online storage)
move /Y %TOOLDIR%"%DBNAME%.sql" %USBDIR%lms_backup\

::BACKUP COMPRESSED DUMP
copy /V /Y %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %DROPBOXDIR%lms_backup\
copy /V /Y %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %SUGARSYNCDIR%lms_backup\
move /Y %TOOLDIR%"%d%_%t%_database_%DBNAME%.7z" %USBDIR%lms_backup\

::EMPTY COVER FOLDER
del %LMSDIR%covers\* /F /S /Q

::CD
%LMSDIR:~0,2%
cd %LMSDIR%

::COMMIT DUMP AND TOOL
CMD /C git add *
CMD /C git commit -a -m "lms sources backup"
CMD /C git gc

::COMPRESS LMS SOURCES
%ZIPEXE% a -t7z "%d%_%t%_site_lms.7z" %LMSDIR%* -mx9 -mmt=on -m0=PPMd

::BACKUP COMPRESSED SOURCES
copy /V /Y %LMSDIR%"%d%_%t%_site_lms.7z" %DROPBOXDIR%lms_backup\
copy /V /Y %LMSDIR%"%d%_%t%_site_lms.7z" %SUGARSYNCDIR%lms_backup\
move /Y %LMSDIR%"%d%_%t%_site_lms.7z" %USBDIR%lms_backup\

::EMPTY FOLDER
attrib -S -R -H %DROPBOXDIR%lms\* /S
rmdir %DROPBOXDIR%lms /S /Q
%DROPBOXDIR:~1,2%
cd %DROPBOXDIR%
mkdir lms

attrib -S -R -H %SUGARSYNCDIR%lms\* /S
rmdir %SUGARSYNCDIR%lms /S /Q
%SUGARSYNCDIR:~1,2%
cd %SUGARSYNCDIR%
mkdir lms

attrib -S -R -H %USBDIR%lms\* /S
rmdir %USBDIR%lms /S /Q
%USBDIR:~0,2%
cd %USBDIR%
mkdir lms

::BACKUP SOURCE
xcopy %LMSDIR%* %DROPBOXDIR%lms\ /Y /R /E /H /Q
xcopy %LMSDIR%* %SUGARSYNCDIR%lms\ /Y /R /E /H /Q
xcopy %LMSDIR%* %USBDIR%lms\ /Y /R /E /H /Q

::CD
%TOOLDIR:~0,2%
cd %TOOLDIR%

::COMMIT DUMP AND TOOL
CMD /C git add *
CMD /C git commit -a -m "backup tools for %DBNAME% save"
CMD /C git gc

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

