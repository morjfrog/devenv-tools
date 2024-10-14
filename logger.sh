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