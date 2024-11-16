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

3. Install Packages in Your Project:
```bash
# From your project directory
npm install <package-name> --offline
```

4. Create New Projects Offline:
```bash
# React project
npx create-react-app my-app

# Vue project
npx create-vue my-app

# Next.js project
npx create-next-app my-app

# Express project
npx express-generator my-app

# Vite project
npx create-vite my-app
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

## Best Practices

1. Before Going Offline:
   - Run full setup to cache all packages
   - Verify installations with check-versions
   - Test a sample project installation
   
2. Package Management:
   - Use specific versions for stability
   - Document any special package requirements
   - Keep package lists updated

3. Offline Usage:
   - Always use --offline flag
   - Keep setup-offline.sh results for reference
   - Maintain a list of frequently used packages

## Notes
- The tool maintains both global and local package caches
- Special handling is included for problematic packages
- Package lists are maintained in text files for easy editing
- Version checking utility helps verify cache status

## Support
For issues or questions:
1. Check troubleshooting section
2. Verify package exists in cache
3. Ensure correct Node.js version
4. Check npm cache integrity
