@echo on
%~d0
set projPath=%~d0%~p0
rem echo %projPath%
set dataPath=%projPath%Datas
set scriptPath=%projPath%Script


if exist %1  goto setwp

set curMap=%date%%time%
set curMap=%curMap::=_%
set curMap=%curMap:-=_%
set curMap=%curMap: =_%
set curMap=%curMap:.=_%
set workPath=%dataPath%\%curMap%
mkdir %workPath%

goto run

:setwp

set workPath=%1

:run

echo %workPath%


call %projPath%Script\Moving.bat

