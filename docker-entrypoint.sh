#!/bin/bash

TARGET_DIR="/var/www/html"
TEMP_DIR="/tmp/html-temp"

PROTECTED_PATHS=(
    "application/database.php"
    "application/route.php"
    "application/extra"
    "application/data"
    "runtime"
    "upload"
)

copy_if_not_exists() {
    local src=$1
    local dst=$2
    if [ -e "$dst" ]; then
        for protected in "${PROTECTED_PATHS[@]}"; do
            if [[ "$dst" == "$TARGET_DIR/$protected"* ]]; then
                echo "$dst is protected, skipping copy."
                return
            fi
        done
        echo "$dst exists, but not protected. Overwriting."
    fi
    cp -r "$src" "$dst"
}

for path in $(find $TEMP_DIR -mindepth 1 -maxdepth 1); do
    file_or_dir=$(basename "$path")
    copy_if_not_exists "$TEMP_DIR/$file_or_dir" "$TARGET_DIR/$file_or_dir"
done

chown -R www-data:www-data $TARGET_DIR

exec apache2-foreground
