#!/usr/bin/expect

#exp_internal 1



# shellcheck disable=SC2121
set timeout 360
spawn /Users/morm/setup_devenv.sh
expect "*to continue or any other key to abort*" { send "\r" } # Homebrew install
expect "Press Enter once the SSH public key is added to your BitBucket account to continue..." { send "\r" } # SSH public key bitbucket setup
expect "*Are you sure you want to continue connecting*" { send "yes\r" } # Git clone
expect eof