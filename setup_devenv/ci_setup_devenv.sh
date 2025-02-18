#!/usr/bin/expect

#exp_internal 1



# shellcheck disable=SC2121
set timeout 360
spawn ./setup_devenv/setup_devenv.sh
# Homebrew install
expect "*to continue or any other key to abort*" { send "\r" }
# SSH public key bitbucket setup
expect "Press Enter once the SSH public key is added to your BitBucket account to continue..." { send "\r" }
# Git clone
expect "*Are you sure you want to continue connecting*" { send "yes\r" }
expect eof