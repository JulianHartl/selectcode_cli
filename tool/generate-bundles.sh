#!/bin/bash
# Runs `mason bundle` to generate bundles for all bricks within the respective templates directories.

bricks=(flutter)
cd ..
for brick in "${bricks[@]}"
do
    echo "bundling $brick..."
    mason bundle -s git "https://github.com/JulianHartl/${brick}_template" --git-path brick -t dart -o "lib/src/commands/create/templates/$brick"
done

dart format .