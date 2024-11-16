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

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to create README
create_readme() {
    cat > README.md << 'EOL'
# NPM Offline Package Manager

## Overview
This tool helps you manage NPM packages for offline use by:
- Downloading and caching packages while online
- Managing package lists by categories
- Installing individual new packages
- Using cached packages in offline environments

## Directory Structure
```
npm-offline-cache/
├── package-lists/       # Package category lists
│   ├── frontend.txt     # Frontend packages
│   ├── backend.txt      # Backend packages
│   ├── devtools.txt     # Development tools
│   └── global.txt       # Global packages
├── node_modules/        # Cached packages
├── manage-packages.sh   # Interactive package manager
├── setup-npm-offline.sh     # Offline setup script
├── check-versions.sh    # Version checking utility
└── README.md           # This file
```

## Prerequisites
- Node.js >= 18.0.0
- NPM >= 8.0.0
- Bash shell
- Internet connection (for initial setup and adding new packages)

## Usage Instructions

### Online Environment (Setting Up Cache)

1. Initial Setup:
```bash
# Make scripts executable
chmod +x manage-packages.sh setup-npm-offline.sh check-versions.sh

# Start the package manager
./manage-packages.sh
```

2. Using Package Manager Menu:
- Show installed packages
- Install new individual package
- Check installed versions
- Run full setup (all packages)

3. Adding New Packages:
```bash
# Using interactive menu:
1. Select "Install new package"
2. Enter package name (e.g., lodash@latest)
3. Optionally add to category list
```

### Offline Environment

1. Transfer Files:
   - Copy entire `npm-offline-cache` directory to offline machine

2. Setup on Offline Machine:
```bash
# Navigate to npm-offline-cache directory
cd npm-offline-cache

# Run offline setup
./setup-offline.sh
```

## Package Categories

### Frontend Packages
- React ecosystem (react, react-dom, react-router-dom)
- Vue ecosystem (vue, vue-router, vuex)
- Next.js, Gatsby
- UI frameworks (Bootstrap, Tailwind CSS)
- jQuery

### Backend Packages
- Express and middleware
- Template engines (EJS, HBS, Pug)
- Body parser

### Development Tools
- TypeScript, ESLint, Prettier
- Testing tools (Cypress)
- Build tools (Vite, Laravel Mix)
- Babel

## Troubleshooting

1. Package Not Found Offline:
```bash
# Verify package is in cache
./check-versions.sh

# If missing, download while online using
./manage-packages.sh  # Option: Install new package
```

2. Dependency Issues:
```bash
# Use legacy peer deps flag
npm install <package> --offline --legacy-peer-deps
```

3. Cache Verification:
```bash
# Verify npm cache
npm cache verify
```

## Support
For issues or questions:
1. Check troubleshooting section
2. Verify package exists in cache
3. Ensure correct Node.js version
4. Check npm cache integrity
EOL

    echo -e "${GREEN}✅ README.md created successfully${NC}"
}

# Function to check if it's a fresh installation
check_fresh_install() {
    if [ ! -d "npm-offline-cache" ] || [ ! -d "npm-offline-cache/node_modules" ]; then
        echo -e "${YELLOW}====================================================${NC}"
        echo -e "${YELLOW}  Welcome to NPM Offline Package Manager${NC}"
        echo -e "${YELLOW}  This appears to be a fresh installation.${NC}"
        echo -e "${YELLOW}  No packages are currently installed.${NC}"
        echo -e "${YELLOW}  Please use option 4 to run the full setup.${NC}"
        echo -e "${YELLOW}====================================================${NC}"
        echo
        
        # Create README for fresh installation
        create_readme
        return 0
    fi
    return 1
}

# Function to install a single package
install_single_package() {
    local package=$1
    echo -e "${YELLOW}Installing single package: $package${NC}"
    
    # Check if npm-offline-cache exists
    if [ ! -d "npm-offline-cache" ]; then
        echo -e "${RED}Error: npm-offline-cache directory not found${NC}"
        echo -e "${YELLOW}Please run full setup (option 4) first${NC}"
        return 1
    fi
    
    cd npm-offline-cache || return 1
    
    if [[ $package == "vite@"* || $package == "@vitejs/"* || $package == "cypress@"* || $package == "gatsby@"* ]]; then
        echo "📦 Special installation for $package..."
        npm install "$package" \
            --save-exact \
            --legacy-peer-deps \
            --ignore-scripts \
            --no-bin-links \
            --no-audit \
            --no-fund \
            --loglevel=error
    elif [[ $package == "@"* ]]; then
        npm install "$package" --save --legacy-peer-deps
    else
        npm install "$package" --save --legacy-peer-deps
    fi
    
    local result=$?
    cd ..
    return $result
}

# Main menu loop
while true; do
    # Check for fresh installation
    check_fresh_install
    
    echo -e "\n${YELLOW}=== NPM Package Manager ===${NC}"
    echo "1. Show installed packages"
    echo "2. Install new package"
    echo "3. Check installed versions"
    echo "4. Run full setup (all packages)"
    echo "q. Quit"
    
    read -p "Choose an option: " choice
    
    case $choice in
        1)  # Show installed packages
            if [ ! -d "npm-offline-cache/node_modules" ]; then
                echo -e "${RED}No packages installed yet.${NC}"
                echo -e "${YELLOW}Please run full setup (option 4) first${NC}"
            else
                ./check-versions.sh
            fi
            ;;
            
        2)  # Install new package
            if [ ! -d "npm-offline-cache/node_modules" ]; then
                echo -e "${RED}Error: No packages installed yet.${NC}"
                echo -e "${YELLOW}Please run full setup (option 4) first${NC}"
                continue
            fi
            echo -e "\nEnter package details:"
            read -p "Package name (e.g., lodash@latest or @types/node@latest): " package_name
            
            if [ ! -z "$package_name" ]; then
                install_single_package "$package_name"
                if [ $? -eq 0 ]; then
                    echo -e "\nDo you want to add this package to a category list for future installations?"
                    echo "1. Frontend"
                    echo "2. Backend"
                    echo "3. Development Tools"
                    echo "4. Global Packages"
                    echo "5. Skip"
                    read -p "Choose category (1-5): " category_choice
                    
                    case $category_choice in
                        1) echo "$package_name" >> npm-offline-cache/package-lists/frontend.txt ;;
                        2) echo "$package_name" >> npm-offline-cache/package-lists/backend.txt ;;
                        3) echo "$package_name" >> npm-offline-cache/package-lists/devtools.txt ;;
                        4) echo "$package_name" >> npm-offline-cache/package-lists/global.txt ;;
                        *) echo "Package not added to any category" ;;
                    esac
                fi
            else
                echo -e "${RED}Invalid package name${NC}"
            fi
            ;;
            
        3)  # Check versions
            if [ ! -d "npm-offline-cache/node_modules" ]; then
                echo -e "${RED}No packages installed yet.${NC}"
                echo -e "${YELLOW}Please run full setup (option 4) first${NC}"
            else
                ./check-versions.sh
            fi
            ;;
            
        4)  # Full setup
            echo -e "${YELLOW}Starting full package installation...${NC}"
            ./setup-npm-offline.sh
            ;;
            
        q|Q)
            echo "Goodbye!"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
done