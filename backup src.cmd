set exename=DateConverter
set release=1.0

@echo off
set h=%TIME:~0,2%
set m=%TIME:~3,2%
if %m% leq 9 set m=0%m:~1,1%
if %h% leq 9 set h=0%h:~1,1%
set datestr=%date:~6,4%_%date:~3,2%_%date:~0,2%_%h%%m%
set /p vers=<"BuildNo.inc"
set arc=%exename%_sources_%datestr%_%vers%.rar

"C:\Program Files\WinRAR\WinRAR.exe" a "%arc%" *.* C:\Comp\DeaTools\*.* -r -ed -v1G -m3 -ms ^
  -x*.abs -x*.tmp -x*.exe -x"*\for-client\*.*" -x"\data\" -x"*\__history\*" -x"*\__recovery\*" ^
  -xlog*.txt -x*.local -x"Dcu" 

if %errorlevel%==0 (
   echo %TIME% Архивирование успешно завершено

  gh release upload %release% %arc% --clobber

   move  %arc% for-client\src\
  ) else (
   echo ----------------------------------
   echo %TIME% Архивирование не было завершено!
  )