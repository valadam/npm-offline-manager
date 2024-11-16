#!/bin/bash

#
# NPM Offline Package Manager
# Copyright (c) 2024 Val Adam
# All rights reserved.
#
# Created by Val Adam
# Version: 1.0.0
# Last Updated: 2024-11-16
#############################################

# Set text colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Checking core installed package versions...${NC}\n"

# Function to get package version from package.json
get_version() {
    local package_name=$1
    
    # Handle scoped packages differently
    if [[ $package_name == @* ]]; then
        # Split scope and package name
        local scope=$(echo $package_name | cut -d'/' -f1)
        local name=$(echo $package_name | cut -d'/' -f2)
        if [ -f "node_modules/$scope/$name/package.json" ]; then
            version=$(cat "node_modules/$scope/$name/package.json" | grep '"version":' | head -1 | awk -F'"' '{print $4}')
            echo $version
        else
            echo "Not found"
        fi
    else
        if [ -f "node_modules/$package_name/package.json" ]; then
            version=$(cat "node_modules/$package_name/package.json" | grep '"version":' | head -1 | awk -F'"' '{print $4}')
            echo $version
        else
            echo "Not found"
        fi
    fi
}

# Function to display category header
print_category() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check and display package version
check_package() {
    local package=$1
    local base_name="$package"  # Keep the full name for scoped packages
    local version=$(get_version "$base_name")
    if [ "$version" != "Not found" ]; then
        echo -e "${GREEN}✓${NC} $base_name: ${GREEN}v$version${NC}"
    else
        echo -e "❌ $base_name: Not installed"
    fi
}

cd npm-offline-cache

# Check Frontend Packages
print_category "Frontend Packages"
check_package "react"
check_package "react-dom"
check_package "react-router-dom"
check_package "vue"
check_package "vue-router"
check_package "vuex"
check_package "@vitejs/plugin-vue"  # Keep full package name
check_package "next"
check_package "gatsby"
check_package "bootstrap"
check_package "tailwindcss"
check_package "jquery"

# Check Backend Packages
print_category "Backend Packages"
check_package "express"
check_package "express-session"
check_package "ejs"
check_package "hbs"
check_package "pug"
check_package "body-parser"

# Check Development Tools
print_category "Development Tools"
check_package "typescript"
check_package "eslint"
check_package "prettier"
check_package "cypress"
check_package "axios"
check_package "vite"
check_package "laravel-mix"
check_package "@babel/core"        # Keep full package name
check_package "@babel/preset-env"  # Keep full package name

# Check Global Packages
print_category "Global Packages"
echo -e "\nGlobal packages (run 'npm list -g' for complete list):"
npm list -g --depth=0 create-react-app create-vue create-vite create-next-app express-generator

# Check Laravel Version if exists
print_category "Laravel Packages"
if [ -d "laravel-latest" ]; then
    cd laravel-latest
    if [ -f "composer.json" ]; then
        laravel_version=$(cat composer.json | grep '"laravel/framework"' -A 1 | grep 'version' | awk -F'"' '{print $4}')
        echo -e "${GREEN}✓${NC} Laravel: ${GREEN}v$laravel_version${NC}"
    fi
    cd ..
else
    echo "❌ Laravel: Not installed"
fi

# Function for animated progress indicator
animate_progress() {
    local pid=$1  # Process ID to monitor
    local delay=0.5
    while kill -0 $pid 2>/dev/null; do
        echo -ne "${YELLOW}Scanning in progress   \r${NC}"
        sleep $delay
        echo -ne "${YELLOW}Scanning in progress.  \r${NC}"
        sleep $delay
        echo -ne "${YELLOW}Scanning in progress.. \r${NC}"
        sleep $delay
        echo -ne "${YELLOW}Scanning in progress...\r${NC}"
        sleep $delay
    done
    echo -ne "\r\033[K"  # Clear the line
}

# Prompt for additional packages scan
echo -e "\n${BLUE}Additional packages might be available in this installation.${NC}"
echo -e "${YELLOW}Note: The additional packages scan might take several minutes to complete."
echo -e "Please be patient and wait until the scan ends.${NC}"
read -p "Do you want to scan for additional packages? (y/N): " scan_choice

if [[ $scan_choice =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}📦 Starting additional packages scan...${NC}"
    echo -e "${YELLOW}Scanning node_modules directory. Please wait...${NC}"
    
    # Array of core packages to exclude
    declare -A core_pkgs=(
        ["react"]=1 ["react-dom"]=1 ["react-router-dom"]=1 ["vue"]=1 
        ["vue-router"]=1 ["vuex"]=1 ["@vitejs/plugin-vue"]=1 ["next"]=1 
        ["gatsby"]=1 ["bootstrap"]=1 ["tailwindcss"]=1 ["jquery"]=1
        ["express"]=1 ["express-session"]=1 ["ejs"]=1 ["hbs"]=1 ["pug"]=1 
        ["body-parser"]=1 ["typescript"]=1 ["eslint"]=1 ["prettier"]=1 
        ["cypress"]=1 ["axios"]=1 ["vite"]=1 ["laravel-mix"]=1
        ["@babel/core"]=1 ["@babel/preset-env"]=1
    )
    
    # Temporary file to store results
    tmp_file=$(mktemp)
    
    # Start the find command in background and capture its PID
    {
        find "node_modules" -maxdepth 2 -name "package.json" | while read package_json; do
            dir=$(dirname "$package_json")
            pkg_name=$(basename "$dir")
            parent_dir=$(basename $(dirname "$dir"))
            
            # Handle scoped packages
            if [ "$parent_dir" != "node_modules" ]; then
                pkg_name="@$parent_dir/$pkg_name"
            fi
            
            # Skip if it's a core package
            if [ "${core_pkgs[$pkg_name]}" == "1" ]; then
                continue
            fi
            
            # Get version and save to temp file
            version=$(cat "$package_json" | grep '"version":' | head -1 | awk -F'"' '{print $4}')
            echo "$pkg_name|$version" >> "$tmp_file"
        done
    } &

    # Capture the background process ID
    scan_pid=$!

    # Start the animation in background
    animate_progress $scan_pid &
    animation_pid=$!

    # Wait for scan to complete
    wait $scan_pid
    
    # Kill the animation process
    kill $animation_pid 2>/dev/null
    
    echo -e "\n${GREEN}Scan completed!${NC}"
    
    # Count and display additional packages
    count=$(wc -l < "$tmp_file")
    
    if [ $count -gt 0 ]; then
        print_category "Additional Packages"
        sort "$tmp_file" | while IFS="|" read -r pkg_name version; do
            echo -e "${GREEN}✓${NC} $pkg_name: ${GREEN}v$version${NC}"
        done
        echo -e "\n${BLUE}Total additional packages: $count${NC}"
    else
        echo -e "\n${BLUE}No additional packages found.${NC}"
    fi
    
    # Cleanup
    rm -f "$tmp_file"
fi

echo -e "\n${BLUE}✨ Version check complete!${NC}"