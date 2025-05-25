source "https://rubygems.org"

# Fastlane for iOS automation
gem "fastlane", "~> 2.217"

# CocoaPods for dependency management
gem "cocoapods", "~> 1.15"

# Additional gems for iOS development
gem "xcode-install", "~> 2.8"

# Plugins for Fastlane
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path) 