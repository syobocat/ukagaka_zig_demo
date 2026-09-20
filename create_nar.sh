#!/usr/bin/env bash

# - - - - - - - - - -

NAME="demo_ghost"

# - - - - - - - - - -

set -e

dir=$(dirname "${0}")
pushd "${dir}" > /dev/null

# Build
zig build -Drelease

# Create updates.txt
pushd 'public' > /dev/null
echo 'charset,UTF-8' > updates.txt
while IFS= read -r -d '' f
do
    echo -e "file,${f#./}\x01$(md5sum "${f}" | awk '{print $1}')\x01size=$(wc -c "${f}" | awk '{print $1}')\x01" >> updates.txt
done < <(find . -type f -print0)
cp 'updates.txt' 'ghost/master/'

# Create .nar
zip -r9 "../${NAME}.nar" .

popd > /dev/null
popd > /dev/null
