#!/usr/bin/env bash

GITHUB_WORKSPACE="$1"

set -e

#create tmp directory
tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'rclone-install.XXXXXXXXXX')
cd "$tmp_dir"

# Make sure we don't create a root owned .config/rclone directory #2127
export XDG_CONFIG_HOME=config
rclone_zip="rclone_binary_v1.64.2.zip"
unzip_dir="tmp_unzip_dir_for_rclone"

unzip -a "$GITHUB_WORKSPACE"/tools/"$rclone_zip" -d "$unzip_dir"
cd $unzip_dir/*

cp rclone /usr/bin/rclone.new
chmod 755 /usr/bin/rclone.new
chown root:root /usr/bin/rclone.new
mv /usr/bin/rclone.new /usr/bin/rclone
if ! [ -x "$(command -v mandb)" ]; then
  echo 'mandb not found. The rclone man docs will not be installed.'
else
  mkdir -p /usr/local/share/man/man1
  cp rclone.1 /usr/local/share/man/man1/
  mandb
fi
version=$(rclone --version 2>>errors | head -n 1)

printf "\n${version} has successfully installed."
printf '\nNow run "rclone config" for setup. Check https://rclone.org/docs/ for more details.\n\n'
exit 0
