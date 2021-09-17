#!/bin/sh
#
# distribute_jw.sh -- a wrapper to make inofficial distributions, from development branches.
# (C) 2020 juergen@fabmail.org, available under LGPLv3
#
set -e # exit 1 if any command fails
cd "$(dirname "$0")"
app_prop=../src/com/t_oster/visicut/gui/resources/VisicutApp.properties
if [ -f $app_prop.orig ]; then
  echo "ERROR: $app_prop.orig exists"
  exit 0
fi

ubuntu_builddeps="librsvg2-bin dpkg fakeroot checkinstall maven"
dpkg -l $ubuntu_builddeps > /dev/null || sudo apt install $ubuntu_builddeps

VERSION=$(sed -ne 's/Application.version\s*=\s*//p' $app_prop)
VERSION=1.8-310.1+20181009jw+1

VERSION="$(git describe --tags)+dev$(date +%Y%m%d)jw"
sed -i.orig -e "s@Application.version.*@Application.version = $VERSION@" $app_prop
echo "... temporarily patched $app_prop to say"
grep Application.version $app_prop
bash ../generatesplash.sh

ext_dir=../tools/inkscape_extension
if [ ! -d $ext_dir.orig ]; then
  echo "... creating backup-copy of $ext_dir"
  mv $ext_dir $ext_dir.orig
  mkdir -p $ext_dir

  wget="wget -r -nv --show-progress"
  dl_e=https://raw.githubusercontent.com/t-oster/VisiCut/master/tools/inkscape_extension/
  cd $ext_dir
    for file in visicut_export.inx visicut_export_replace.inx daemonize.py visicut_export.py; do
      $wget $dl_e/$file
    done
  cd "$(dirname "$0")"
fi


cleanup()
{
  trap - EXIT  # do not execut twice
  if [ -f "$app_prop.orig" ]; then
    echo "... restoring VisicutApp.properties ... (but saving the patch)"
    mv -f $app_prop $app_prop.jw
    mv $app_prop.orig $app_prop
    diff -u0 $app_prop $app_prop.jw || true
  fi
}

trap cleanup EXIT HUP INT TERM

test -f /usr/bin/visicut && sudo apt-get purge visicut
bash ./distribute.sh "$@"
