#!/bin/sh
#
# distribute_jw.sh -- a wrapper to make inofficial distributions, from development branches.
# (C) 2020 juergen@fabmail.org, available under LGPLv3
#
set -e # exit 1 if any command fails

cd "$(dirname "$0")/.."

if ! grep 'VERSION="18.04' /etc/os-release ; then
  echo "Must run 18.04";
  echo "Try:"
  echo " docker build -t visibuild ."
  echo " docker run --rm -ti -u$(id -u):$(id -g) -v$(pwd -P):/v visibuild bash /v/distribute/$(basename $0)"
  echo ""
  exit 1
fi

app_prop=src/com/t_oster/visicut/gui/resources/VisicutApp.properties
if [ -f $app_prop.orig ]; then
  echo "ERROR: $app_prop.orig exists"
  exit 0
fi

ubuntu_builddeps="librsvg2-bin dpkg fakeroot checkinstall ant nsis zip"
dpkg -l $ubuntu_builddeps > /dev/null || sudo apt install $ubuntu_builddeps || apt install $ubuntu_builddeps

VERSION=$(sed -ne 's/Application.version\s*=\s*//p' $app_prop)
VERSION=1.8-310.1+20181009jw+1
# VERSION="$(git describe --tags)+dev$(date +%Y%m%d)jw"

cleanup()
{
  trap - EXIT  # do not execut twice
  cd "$(dirname "$0")/.."
  if [ -f "$app_prop.orig" ]; then
    echo "... restoring VisicutApp.properties ... (but saving the patch)"
    mv -f $app_prop $app_prop.jw
    mv $app_prop.orig $app_prop
    diff -u0 $app_prop $app_prop.jw || true
  fi
  if [ -d "$ext_dir.orig" ]; then
    rm -rf $ext_dir.2018
    mv $ext_dir $ext_dir.2018
    mv $ext_dir.orig $ext_dir
    md5sum $ext_dir.2018/*
  fi
}

trap cleanup EXIT HUP INT TERM

sed -i.orig -e "s@Application.version.*@Application.version = $VERSION@" $app_prop
echo "... temporarily patched $app_prop to say"
grep Application.version $app_prop

rm -f splashsource.svg.orig
sed -i.orig -e 's@x="126.71354"@x="66.71354"@' splashsource.svg
bash generatesplash.sh
mv splashsource.svg.orig splashsource.svg

ext_dir=tools/inkscape_extension
if [ ! -d $ext_dir.orig ]; then
  echo "... creating backup-copy of $ext_dir"
  cp -a $ext_dir $ext_dir.orig
  cd $ext_dir

  wget="wget -nv --show-progress"
  dl_e=https://raw.githubusercontent.com/t-oster/VisiCut/master/tools/inkscape_extension/
  for file in visicut_export.inx visicut_export_replace.inx daemonize.py visicut_export.py; do
    $wget $dl_e/$file -O $file
  done
  sed -i -e 's@get("SESSIONNAME")@get("SESSIONNAME_NOT_USED_IN_1_8")@' visicut_export.py	# always use port 6543 on win10 with visicut1.8
  sed -i -e 's@s.send(\(.*\)@s.send(str(\1.encode("utf-8"))@' visicut_export.py			# make s.send compatible with both python2 and 3
  sed -i -e 's/^if IMPORT:/if IMPORT and False:  # --add is not implemented in old 1.8.x/' visicut_export.py
  sed -i -e 's/>Add to VisiCut</>Add, if VisiCut is running</' visicut_export.inx		# discourage this rarely-used option
fi
cd "$(dirname "$0")"

if [ -f /usr/bin/visicut ]; then
  echo "Uninstalling visicut"
  dpkg -l visicut | cat
  sudo apt-get purge visicut
fi
bash ./distribute.sh "$@"
ls -l *$VERSION*
