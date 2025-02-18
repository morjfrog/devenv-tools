#!/usr/bin/expect

#exp_internal 1



# shellcheck disable=SC2121
set timeout 360
spawn ./setup_devenv/setup_devenv.sh
# CORP username
#expect "*Enter your CORP username*" { send "morm\r" }
# Identity token
#expect "*Enter your Identity token*" { send "cmVmdGtuOjAxOjE3NzEyMzExMjc6bG5FZnhYQjdldHV6bWJJNUJUUXdTS1doenhm\r" }
expect "*Press Enter once the SSH public key is added to your BitBucket account to continue*" { send "\r" }
# Git clone
expect "*Are you sure you want to continue connecting*" { send "yes\r" }
expect eof