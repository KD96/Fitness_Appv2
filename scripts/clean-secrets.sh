#!/bin/bash

# Clean Secrets from Git History
# This script removes API keys and secrets from git history

set -e

echo "🧹 Cleaning secrets from git history..."

# Check if git-filter-repo is available
if ! command -v git-filter-repo &> /dev/null; then
    echo "📦 Installing git-filter-repo..."
    pip3 install git-filter-repo
fi

# Create backup
echo "💾 Creating backup..."
git tag backup-before-cleanup

# Remove specific files from history
echo "🗑️ Removing APIConfig.swift from history..."
git filter-repo --path Fitness_Appv2/Networking/APIConfig.swift --invert-paths --force

# Remove any remaining API key patterns
echo "🔍 Removing API key patterns..."
git filter-repo --replace-text <(echo "***REMOVED***") --force

echo "✅ Cleanup complete!"
echo "📝 Next steps:"
echo "   1. Configure your API keys using the new secure method"
echo "   2. Test the app to ensure everything works"
echo "   3. Force push to remote: git push origin main --force-with-lease"
echo "   4. Notify team members to re-clone the repository"

echo ""
echo "🔧 To configure API keys:"
echo "   1. Copy: cp Fitness_Appv2/Config/Secrets.xcconfig.template Fitness_Appv2/Config/Secrets.xcconfig"
echo "   2. Edit Secrets.xcconfig with your actual API keys"
echo "   3. Add to Xcode project configuration" 