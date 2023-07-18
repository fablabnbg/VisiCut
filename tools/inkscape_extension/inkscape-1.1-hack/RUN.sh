#! /bin/sh

wget="wget -nv --show-progress -c"
dl_o=https://github.com/fablabnbg/VisiCut/releases/download/v1.8-310.1%2B20181009jw/
vers_o=1.8-310.1+20181009jw
vers_n=1.8-310.1+20181009+1jw

mkdir -p 2018
cd 2018
$wget $dl/VisiCut-1.8-310.1+20181009jw-Windows-Installer.exe
$wget $dl/visicut_1.8-310.1+20181009jw-1_all.deb
$wget $dl/VisiCutMac-1.8-310.1+20181009jw.zip
cd ..
mkdir -p ext-1.1
cd ext-1.1
dl_e=https://raw.githubusercontent.com/t-oster/VisiCut/master/tools/inkscape_extension/
$wget $dl_e/daemonize.py
$wget $dl_e/visicut_export.py
cd ..

mkdir -p mac
cd mac
unzip -n ../2018/*Mac*.zip
cp ../ext-1.1/* VisiCut.app/Contents/Resources/Java/inkscape_extension/
sed -i -e "s/$vers_o/$vers_n/" VisiCut.app/Contents/Info.plist
zip -r ../VisiCutMac-$vers_n.zip VisiCut.app
cd ..

mkdir -p lin
dpkg-deb -R 2018/*.deb lin
sed -i -e "s/$vers_o/$vers_n/" lin/DEBIAN/control
cp ext-1.1/* lin/usr/share/visicut/inkscape_extension/
dpkg-deb --build lin visicut_$vers_n-1_all.deb 

mkdir -p win
cd win
7z x ../2018/*.exe
cp ../ext-1.1/* inkscape_extension/
cp ../2018/*.exe ../VisiCut-$vers_n-Windows-Installer.exe
7z u ../VisiCut-$vers_n-Windows-Installer.exe inkscape_extension/daemonize.py  inkscape_extension/visicut_export.py
####### ERROR:
# Path = ../VisiCut-1.8-310.1+20181009+1jw-Windows-Installer.exe
# Type = Nsis
# Physical Size = 14745102
# Method = Deflate
# Solid = -
# Headers Size = 59395
# Embedded Stub Size = 88064
# SubType = NSIS-2 BadCmd=11
# 
# System ERROR:
# E_NOTIMPL
####### ERROR:
