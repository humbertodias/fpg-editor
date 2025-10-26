svn commit
svn update
svn2revisioninc .
lazbuild -B --bm=DefaultQT pfpgeditor.lpi
PVERSION=$(svnversion -n)
#tar -cvzf fpg-editor_r${PVERSION}_i386lin.tgz fpg-editor languages/*.po

wine $HOME/.wine/drive_c/lazarus/lazbuild.exe -B --bm=DefaultWin32 pfpgeditor.lpi
tar -cvzf fpg-editor_r${PVERSION}_linux_and_win32.tgz fpg-editor fpg-editor.exe zlib/zlib.exe languages/*.po

#python googlecode_upload.py -s "r${PVERSION} linx and windows binaries" -p "fpg-editor" fpg-editor_r${PVERSION}_linux_and_win32.tgz
