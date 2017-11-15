#!/bin/sh
set -eu

CRASH_FOLDER=$1
SYMBOLICATE_CRASH="/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash"

cd "$CRASH_FOLDER"
tar -xf *.ipa
tar -xf dSYMs.tar.gz
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

for crash in *.crash
do
	echo "Symbolicating $crash"
	$SYMBOLICATE_CRASH "$crash" >"${crash}_symbolicated.crash"
	open "${crash}_symbolicated.crash"
done
