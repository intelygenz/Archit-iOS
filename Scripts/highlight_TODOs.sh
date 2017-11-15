#!/bin/sh

TAGS="\/\/( )*TODO:|\/\/( )*FIXME:|\/\/( )*\?\?\?:"
ERRORTAG="\/\/( )*ERROR:|\/\/( )*\!\!\!:"
FILE_EXTENSIONS="h|m|mm|c|cpp|swift"
find -E "${SRCROOT}/${TARGET_NAME}" \( -regex ".*\.($FILE_EXTENSIONS)$" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($TAGS).*\$|($ERRORTAG).*\$" | perl -p -e "s/($TAGS)/ warning: \$1/" | perl -p -e "s/($ERRORTAG)/ error: \$1/"
