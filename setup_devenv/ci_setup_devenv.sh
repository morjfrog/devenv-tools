#!/bin/bash

# Export the environment variable for use in the Expect script
export IDENTITY_TOKEN

# Create a temporary Expect script
cat << EOF > temp_expect_script.exp
#!/usr/bin/expect -f

set timeout 360

# Retrieve the identity token secret environment variable
set token "$IDENTITY_TOKEN"

# Spawn the process
spawn ./setup_devenv/setup_devenv.sh

## CORP username
expect "*Enter your CORP username*"
send "morm\r"

## Identity token
expect "*Enter your Identity token*"
send "\$token\r"

## SSH public key
expect "*Press Enter once the SSH public key is added to your BitBucket account to continue*"
send "\r"
## Git clone
expect "*Are you sure you want to continue connecting*"
send "yes\r"
EOF

# Change permissions to make the Expect script executable
chmod +x temp_expect_script.exp

# Run the Expect script
./temp_expect_script.exp

# Clean up (optional)
rm temp_expect_script.exp


##!/usr/bin/expect

#set timeout 360

# shellcheck disable=SC2121

#spawn ./setup_devenv/setup_devenv.sh
## CORP username
#expect "*Enter your CORP username*" { send "morm\r" }
## Identity token
#expect "*Enter your Identity token*" { send "${IDENTITY_TOKEN}\r" }
#expect "*Press Enter once the SSH public key is added to your BitBucket account to continue*" { send "\r" }
## Git clone
#expect "*Are you sure you want to continue connecting*" { send "yes\r" }
#expect eof

