@echo off
set /p vers=<"BuildNo.inc"
set exename=DateConverter
set release=1.0
set arc=%exename%_%vers%.rar
"C:\Program Files\WinRAR\WinRAR.exe" a "%arc%" %exename%.exe 

gh release upload %release% %arc% --clobber

move %arc% for-client\ > nul

rem сообщение поместить в буфер обмена
nircmd.exe clipboard set "https://github.com/Phidel/%exename%/releases/download/%release%/%arc%"
echo ok - https://github.com/Phidel/%exename%/releases/download/%release%/%arc%