#!/usr/bin/env bash
echo "Checking for magick..."
if command -v magick >/dev/null 2>&1
then
	echo "found magick."
else
	echo "no magick found. skipping generation of splash" >&2
	cp src/main/resources/de/thomas_oster/visicut/gui/resources/splash{-fallback,}.png
	rm -f src/main/resources/de/thomas_oster/visicut/gui/resources/splash@{2,3}x.png
	exit
fi
cd "$(dirname $0)"
VERSION=$(./versionnumber.sh)
echo "Version is: \"$VERSION\" (override with VERSION environment variable)"
echo "Generating SVG"
cat splashsource.svg|sed s#insert#$VERSION#g# > splash.svg
echo "Converting to png"
magick -background none splash.svg -resize 514x444 src/main/resources/de/thomas_oster/visicut/gui/resources/splash.png
# high-dpi variants (see https://docs.oracle.com/javase/10/docs/api/java/awt/SplashScreen.html )
magick -background none splash.svg -resize 1028x888 src/main/resources/de/thomas_oster/visicut/gui/resources/splash@2x.png
magick -background none splash.svg -resize 1542x1332 src/main/resources/de/thomas_oster/visicut/gui/resources/splash@3x.png
echo "cleaning..."
rm splash.svg
echo "done."
