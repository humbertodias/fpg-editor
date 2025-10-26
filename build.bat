svn commit
svn update
c:\lazarus\tools\svn2revisioninc.exe .
for /f "delims=" %%a in ('svnversion -n') do @set PVERSION=%%a
c:\lazarus\lazbuild.exe -B pfpgeditor.lpi
"c:\Program Files\7-Zip\7z.exe" a -t7z -mx9 fpg-editor_r%PVERSION%_win32.7z fpg-editor.exe languages\*.* zlib\*.*
if ERRORLEVEL 1  (
"C:\Program Files\WinRAR\WinRAR.exe" a fpg-editor_r%PVERSION%_win32.rar fpg-editor.exe languages\*.* zlib\*.*
)

