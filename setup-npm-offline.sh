#!/bin/bash

# Create and use npm-offline-cache directory
mkdir -p npm-offline-cache
cd npm-offline-cache

# Create a basic package.json with newer versions
echo '{
  "name": "npm-offline-cache",
  "version": "1.0.0",
  "description": "Offline development packages",
  "private": true,
  "engines": {
    "node": ">=18.0.0"
  }
}' > package.json

# Function to download packages with error handling
download_package() {
    local package=$1
    echo "📦 Downloading $package..."
    
    # Special handling for problematic packages
    if [[ $package == "vite@"* || $package == "cypress@"* || $package == "gatsby@"* ]]; then
        npm install "$package" \
            --save-exact \
            --legacy-peer-deps \
            --ignore-scripts \
            --no-bin-links \
            --no-audit \
            --no-fund \
            --loglevel=error
    elif [[ $package == "@"* ]]; then
        # Simple installation for scoped packages
        npm install "$package" --save --legacy-peer-deps
    else
        # Normal package installation - simple and clean
        npm install "$package" --save --legacy-peer-deps
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Package $package downloaded and cached"
        return 0
    else
        echo "❌ Failed to download $package"
        return 1
    fi
}

# Function to download global packages with error handling
download_global_package() {
    local package=$1
    echo "🌍 Downloading global package $package..."
    
    # Special handling for problematic global packages
    if [[ $package == "create-vite" || $package == "create-react-app" ]]; then
        npm install -g "$package" \
            --legacy-peer-deps \
            --ignore-scripts \
            --no-audit \
            --no-fund
    else
        npm install -g "$package" --legacy-peer-deps
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Global package $package downloaded and cached"
        return 0
    else
        echo "❌ Failed to download global package $package"
        return 1
    fi
}

# Create temporary npmrc with necessary settings
echo "legacy-peer-deps=true
engine-strict=false
ignore-scripts=true
audit=false
fund=false
loglevel=error" > .npmrc

echo "🚀 Starting package downloads..."

# Define packages by category
FRONTEND_PACKAGES=(
    "react@latest"
    "react-dom@latest"
    "react-router-dom@latest"
    "vue@latest"
    "vue-router@latest"
    "vuex@latest"
    "@vitejs/plugin-vue@4.5.0"     # Fixed version to match vite
    "next@latest"
    "gatsby@5.14.0"
    "bootstrap@latest"
    "tailwindcss@latest"
    "jquery@latest"
)

BACKEND_PACKAGES=(
    "express@latest"
    "express-session@latest"
    "ejs@latest"
    "hbs@latest"
    "pug@latest"
    "body-parser@latest"
)

DEV_TOOLS=(
    "typescript@latest"
    "eslint@latest"
    "prettier@latest"
    "cypress@12.17.4"
    "axios@latest"
    "vite@4.5.0"
    "laravel-mix@latest"
    "@babel/core@7.23.9"          # Fixed version
    "@babel/preset-env@7.23.9"    # Fixed version
)

# Ensure clean slate for problematic packages
rm -rf node_modules/vite node_modules/cypress node_modules/gatsby || true

# Download frontend packages
echo "📦 Installing Frontend Packages..."
for package in "${FRONTEND_PACKAGES[@]}"; do
    download_package "$package" || echo "⚠️ Continuing despite error with $package"
    # Small delay to prevent race conditions
    sleep 1
done

# Download backend packages
echo "📦 Installing Backend Packages..."
for package in "${BACKEND_PACKAGES[@]}"; do
    download_package "$package" || echo "⚠️ Continuing despite error with $package"
    sleep 1
done

# Download development tools
echo "🛠️ Installing Development Tools..."
for package in "${DEV_TOOLS[@]}"; do
    download_package "$package" || echo "⚠️ Continuing despite error with $package"
    sleep 1
done

# Download global packages
GLOBAL_PACKAGES=(
    "create-react-app"
    "create-vue"
    "create-vite"
    "create-next-app"
    "express-generator"
)

echo "🌍 Installing Global Packages..."
for package in "${GLOBAL_PACKAGES[@]}"; do
    download_global_package "$package" || echo "⚠️ Continuing despite error with $package"
    sleep 1
done

# Download Laravel and related packages via Composer
echo "🎼 Installing Laravel Packages..."
if command -v composer &> /dev/null; then
    composer create-project --prefer-dist laravel/laravel laravel-latest
    cd laravel-latest
    composer require laravel/sanctum
    composer require barryvdh/laravel-debugbar --dev
    cd ..
    echo "✅ Laravel packages downloaded and cached"
else
    echo "❌ Composer not found. Laravel packages not downloaded"
fi

# Create setup script for offline machine
cat > setup-offline.sh << 'EOL'
#!/bin/bash

# Configure npm for offline use
npm config set offline true
npm config set cache "$(pwd)/.npm-cache"
npm config set prefer-offline true

# Create temporary npmrc for installation
echo "legacy-peer-deps=true
engine-strict=false" > .npmrc

echo "✅ NPM configured for offline use"

# Function to verify cache
verify_cache() {
    echo "🔍 Verifying npm cache..."
    npm cache verify
    echo "✅ Cache verification complete"
}

verify_cache
EOL

# Make setup script executable
chmod +x setup-offline.sh

# Create comprehensive README
cat > README.md << 'EOL'
# NPM and Composer Offline Cache

## Prerequisites
- Node.js >= 18.0.0
- NPM >= 8.0.0
- Composer (for Laravel packages)

## Setup Instructions
1. Copy this entire directory to your offline machine
2. Navigate to the directory
3. Run: `./setup-offline.sh`

# Before starting downloads, clean npm cache
echo "🧹 Cleaning npm cache..."
npm cache clean --force

## Installing Packages Offline

### NPM Packages
```bash
npm install <package-name> --offline
```

### Laravel/Composer Packages
```bash
composer create-project --prefer-dist laravel/laravel project-name
composer require laravel/sanctum
composer require barryvdh/laravel-debugbar --dev
```

### Creating New Projects
```bash
# React
npx create-react-app my-app

# Vue
npx create-vue my-app

# Next.js
npx create-next-app my-app

# Express
npx express-generator my-app

# Vite
npx create-vite my-app

# Laravel
composer create-project --prefer-dist laravel/laravel my-app
```

## Included Packages

### Frontend
- React + Router
- Vue + Router + Vuex
- Next.js, Gatsby
- jQuery
- Bootstrap, Tailwind CSS

### Backend
- Express + Session
- Template Engines (EJS, HBS, Pug)
- Laravel + Sanctum
- Laravel Debugbar

### Development Tools
- TypeScript
- ESLint, Prettier
- Cypress
- Laravel Mix
- Babel Core & Preset ENV
- Vite

## Troubleshooting
- If you see peer dependency warnings, use `--legacy-peer-deps` flag
- Run `npm cache verify` to check npm cache integrity
- Run `composer diagnose` to check composer cache
- Check .npm-cache directory exists and has content
- Ensure you're running compatible Node.js version (>=18.0.0)
EOL

echo "✨ Setup complete! Transfer this directory to your offline machine"
echo "📝 Check README.md for usage instructions"