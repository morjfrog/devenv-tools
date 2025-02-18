#!/bin/bash

print_color() {
    local color=$1
    local message=$2
    local reset_color='\033[0m' # ANSI escape code to reset color
    echo -e "${color}${message}${reset_color}"
}

info() {
    print_color "\033[32m" "INFO: $*"
}

warn() {
    print_color "\033[33m" "WARN: $*"
}

error() {
    print_color "\033[31m" "ERROR: $*"
}

read_char() {
  stty -icanon -echo
  eval "$1=\$(dd bs=1 count=1 2>/dev/null)"
  stty icanon echo
}

set +xe # Enable debugging and exit on failure

#if [[ -z $1 ]]; then
#    while true; do
#        info "Enter your CORP username (if you are not sure what it is, ask on #it_global_support):"
#        read -r USERNAME
#        if [ -n "$USERNAME" ]; then
#            break
#        fi
#    done
#fi
#
#if [[ -z $2 ]]; then
#    while true; do
#        info "Enter your Identity token.
#        Get your identity token from repo21:
#        1. Log in to repo21 using Okta - https://entplus.jfrog.io
#        2. On the top right click on your username.
#        3. Select: 'Edit Profile' and click 'Generate an Identity Token'
#        4. Copy your token"
#        read -r IDENTITY_TOKEN
#        if [ -n "$IDENTITY_TOKEN" ]; then
#            break
#        fi
#    done
#fi

# install Homebrew
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew"
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";then
        error "Failed to install Homebrew. Exiting"
        exit 1
    fi
    #  After brew was installed you will need to add it to PATH variable
    # shellcheck disable=SC2016
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    info "Homebrew installed"
else
    info "Homebrew already installed"
fi

# Install JDK
if ! java -version 2>&1 | grep -q "21"; then
    info "Installing JDK"
    brew tap homebrew/cask-versions
    brew install --cask temurin21
    info "JDK installed"
else
    info "JDK is already installed:"
    info "$(java -version)"
fi

# Install Rancher Desktop
if ! command -v docker &>/dev/null; then
    info "Installing Rancher Desktop"
    brew install --cask rancher
    info "Rancher desktop installed"
else
    info "Rancher is already installed"
fi

# Install git-lfs
if ! command -v git-lfs &>/dev/null; then
    info "Installing Git LFS"
    brew install git-lfs
    info "Git LFS installed"
else
    info "Git LFS is already installed"
fi

# Install jq
if ! command -v jq &>/dev/null; then
    info "Installing jq"
    brew install jq
    info "jq installed"

else
    info "jq is already installed"
fi

# Install JFrog CLI
if ! command -v jfrog &>/dev/null; then
    info "Installing JFrog CLI"
    brew install jfrog-cli
    info "JFrog CLI installed"
    jfrog -v

else
    info "JFrog CLI is already installed"
    jfrog -v
fi

output=$(jfrog config show 2>&1)

# Configure JFrog CLI to use repo21:
if echo "$output" | grep -q "repo21"; then
    info "JFrog CLI already configured for repo21"
else
    info "Configuring JFrog CLI for repo21 with user: $USERNAME and password: $IDENTITY_TOKEN"
    if ! jfrog config add repo21 --url=https://entplus.jfrog.io --user="$USERNAME" --password="$IDENTITY_TOKEN" --interactive=false; then
        error "Failed configuring JFrog CLI for repo21"
        exit 1
    fi
    info "JFrog CLI configured for repo21"
fi

#export JFDEV_TRACE=true
export CI=true

# Install jfdev
if ! command jfdev version >/dev/null 2>&1; then
    export PATH="$HOME/.jfdev/bin:$PATH"
    info "Installing jfdev"
    if ! jfrog rt curl 'npm-virtual/jfdev/download.sh' --server-id=repo21 | bash -s; then
        exit 1
    fi
    echo "source ${JFDEV_DIR}/scripts/.jfdevrc" >> ~/.bashrc # change to zshrc if needed
    info "jfdev installed"
else
    info "jfdev already exists"
fi

# Setup git
MY_EMAIL="$USERNAME@jfrog.com"
GIT_EMAIL=$(git config --get-all user.email)
if [ "$GIT_EMAIL" != "$MY_EMAIL" ]; then
    info "Setting up git"
    git config --global user.name "$USERNAME"
    git config --global user.email "$MY_EMAIL"
else
    info "Git already set up"
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    info "Generating SSH public key"
    ssh-keygen -t rsa -C "$MY_EMAIL" -f ~/.ssh/id_rsa -N ""
    info "Your SSH public key:"
    cat < ~/.ssh/id_rsa.pub
    info "Add the SSH public key to your BitBucket account:
    1. Go to https://git.jfrog.info/
    2. On the top right, click on your profile picture
    3. Select 'Manage Account'
    4. Click SSH keys -> Add key
    5. Paste your ssh key and click 'save'"
        info "Press Enter once the SSH public key is added to your BitBucket account to continue..."
        while true; do
            read_char key
            if [ -z "$key" ]; then
                break
            else
                info "You pressed '$key' key. Please press 'Enter' to confirm you added the SSH public key to your BitBucket account"
            fi
        done
else
    info "SSH public key already exists"
fi

# Clone the project
if ! git rev-parse --verify master >/dev/null 2>&1; then
    info "Cloning artifactory-service project"
    if ! GIT_LFS_SKIP_SMUDGE=true git clone ssh://git@git.jfrog.info/jfrog/artifactory-service.git; then
        error "Failed cloning artifactory-service project"
        exit 1
    fi
    cd "artifactory-service" || {
        error "Failed to change directory to artifactory-service"
        exit 1
    }
    jfdev init
else
    info "git artifactory-service project already cloned"
fi

# Perform Docker login
info "Performing Docker login"
if output=$(echo "$IDENTITY_TOKEN"| docker login docker.jfrog.io --username "$USERNAME" --password-stdin 2>&1); then
    info "Docker login succeeded"
else
    error "Docker login failed: $output"
    exit 1
fi

warn "From version 7.43 we are working with java 17,
    if you have created branch before (from when master was on java 11) and you rebased it after (from when master is on java 17)
    then you might have problems with the e2e tests due to full branch.
    You will need to re-trigger the build with FORCE_RUN=true env variable,
    or the artifactory_pro_docker_draft_image step with:
    RT_BASE_TAG=draft-full-7.x-SNAPSHOT-master-XXXX , XXXX the latest master version"

info "Devenv setup complete! Happy developing, and may the FROG be with you!"