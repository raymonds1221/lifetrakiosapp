#!/bin/sh -e

# Make sure we're in the correct working directory
cd "`dirname $0`"

# Config
base_dir="`pwd`"
build_dir="$base_dir/build"
profile_dir="$HOME/Library/MobileDevice/Provisioning Profiles"

# Read local config
[ -r local.conf ] && . local.conf
# Fallback value for BUILD_NUMBER
[ -n "$BUILD_NUMBER" ] || BUILD_NUMBER=1

# Start clean
rm -rf "$build_dir"
mkdir -p "$build_dir"

# Dump build config and source into the environment
build_conf="$build_dir/build_${BUILD_NUMBER}.conf"
xcodebuild $@ -showBuildSettings SYMROOT="$build_dir" OBJROOT="$build_dir" |
grep -v UID | sed -n "s/^ *\([A-Z_]*\) = \(.*\)$/export \1='\2'/p" > "$build_conf"
. "$build_conf"
gzip -f "$build_conf"

# $1 - suffix, $2 - provisioning profile filename
function package {
xcrun -sdk $SDK_NAME PackageApplication -v "$CODESIGNING_FOLDER_PATH" \
-o "$build_dir/${PRODUCT_NAME}_${BUILD_NUMBER}-$1.ipa" \
--sign "iPhone Distribution" --embed "$profile_dir/$2"
}

# Setup keychain
keychain="`mktemp $build_dir/keychain.XXXXXX`"
# Delete the temporary file, we only need the filename
rm $keychain
security -v create-keychain -p temporary-password $keychain
security import "$CERTIFICATE_PATH" -k $keychain -P "$CERTIFICATE_PASSWD" -T /usr/bin/codesign
security -v list-keychains -s $keychain
security -v unlock-keychain -p temporary-password $keychain

# Set build number
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$INFOPLIST_FILE"

PROVISIONING_PROFILE="`grep --text -E '[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}' "$profile_dir/$ADHOC_PROVISION_FILENAME" | sed 's|.*>\(.*\)<.*|\1|'`"

# Build
xcodebuild $@ clean build SYMROOT="$build_dir" OBJROOT="$build_dir" OTHER_CODE_SIGN_FLAGS="--keychain $keychain" PROVISIONING_PROFILE="$PROVISIONING_PROFILE"

# Package IPAs
package AdHoc "$ADHOC_PROVISION_FILENAME"
package AppStore "$APPSTORE_PROVISION_FILENAME"

# Archive dSYM
pushd "$DWARF_DSYM_FOLDER_PATH"
zip -r "$build_dir/${PRODUCT_NAME}_${BUILD_NUMBER}-dSYM.zip" "$DWARF_DSYM_FILE_NAME"
popd