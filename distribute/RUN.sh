# the distibute script was hacked, so that it cannot build all platforms in one anymore.
# Thus we now need a wrapper.

# the last version we got was 1.9-171-ga45332c3-1
# let us check, what happens now, when we do bash ./distribute.sh linux-checkinstall
# -> it says Building VisiCut 1.9-SNAPSHOT
#  > but then it builds version v1.8-310.1+20181009+1jw-118-gbaeb9a62+devel
#    > that comes from git describe --tags, whatever that does.
#  -> tat needs a fix.

# Manually do:
# - make sure, the latest tags from t-oster/Visicut are also here. (Currently the latest is 3 year old 1.9 tag, 195 commits ago.
# - patch distribute.sh to retrive not only 
#   git describe --tags from visicut master, but also the latest commit timestamp from LibLasercut as 
#	llc_tstamp=$(git log --max-count=1 --format="%cs" | tr -d -)
#	

top=$(readlink -f $(dirname $0)/..)
# format is <nearest-tag>-<commits-count>-g<commit-hash>
vc_vers=$(git describe --tags)
# format of %cs is only a YYYY-MM-DD timestamp, we strip the dashes (-)
llc_vers=$(cd LibLaserCut; git log --max-count=1 --format="%cs" | tr -d -)
VERSION="$vc_vers-l$llc_vers-jw"
echo $VERSION

# We rely on 4 space indentation here. Hack.
sed -i.orig -e "s@^    <version>[^<]*</version>@    <version>$VERSION</version>@" pom.xml
sed -i.orig -e "s@^    <version>[^<]*</version>@    <version>$VERSION</version>@" LibLaserCut/pom.xml
# both pom.xml must match in their versions, otherwise we get a dependency error. nice!

# Now we can do and this regenerates all src/main/resources/de/thomas_oster/visicut/gui/resources/splash*.png to include the version string.
env VERSION=$VERSION make clean jar
