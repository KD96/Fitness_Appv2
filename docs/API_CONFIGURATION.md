# API Configuration Guide

This guide explains how to securely configure API keys for the Fitness App.

## 🔐 Security Overview

The app uses multiple APIs that require secure key management:
- **OpenAI API**: For AI-powered workout and nutrition recommendations
- **Supabase**: For backend database and authentication
- **Analytics**: For crash reporting and performance monitoring

## 📋 Setup Instructions

### Method 1: Build Settings (Recommended for Production)

1. **Open Xcode project**
2. **Select your target** → **Build Settings**
3. **Add User-Defined Settings**:
   - Key: `OPENAI_API_KEY`
   - Value: Your actual OpenAI API key

4. **Update Info.plist**:
   ```xml
   <key>OPENAI_API_KEY</key>
   <string>$(OPENAI_API_KEY)</string>
   ```

### Method 2: Configuration File (Recommended for Development)

1. **Copy the template**:
   ```bash
   cp Fitness_Appv2/Config/Secrets.xcconfig.template Fitness_Appv2/Config/Secrets.xcconfig
   ```

2. **Edit Secrets.xcconfig** with your actual API keys:
   ```
   OPENAI_API_KEY = sk-your-actual-openai-key-here
   ```

3. **Add to Xcode project**:
   - Right-click project → Add Files
   - Select `Secrets.xcconfig`
   - In Build Settings, set Configuration File to `Secrets.xcconfig`

### Method 3: Environment Variables (Development Only)

1. **Set environment variable**:
   ```bash
   export OPENAI_API_KEY="sk-your-actual-openai-key-here"
   ```

2. **Run Xcode from terminal**:
   ```bash
   open Fitness_Appv2.xcodeproj
   ```

## 🔑 Getting API Keys

### OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/account/api-keys)
2. Create account or log in
3. Generate new API key
4. Copy the key (starts with `sk-`)

### Supabase Keys
1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to Settings → API
4. Copy the keys you need:
   - **URL**: `https://your-project-id.supabase.co`
   - **Anon Key**: For client-side operations
   - **Service Role Key**: For admin operations (GitHub Actions)

## ✅ Verification

The app will automatically validate your configuration:

```swift
// Check if OpenAI is configured
print(APIConfig.configurationStatus)

// Check if Supabase is configured  
print("Supabase configured: \(SupabaseConfig.isAuthenticated)")
```

## 🚨 Security Best Practices

### ✅ DO:
- Use build settings for production
- Keep API keys in `.gitignore`
- Use different keys for development/production
- Rotate keys regularly
- Monitor API usage

### ❌ DON'T:
- Commit API keys to git
- Share keys in plain text
- Use production keys in development
- Hardcode keys in source code
- Store keys in user defaults

## 🔧 Troubleshooting

### "API Key not configured" error
1. Check that your key is properly set
2. Verify the key format (OpenAI keys start with `sk-`)
3. Ensure no extra spaces or characters
4. Restart Xcode after configuration changes

### Build settings not working
1. Clean build folder (⌘+Shift+K)
2. Check that Info.plist has the correct variable reference
3. Verify the build setting name matches exactly

### Environment variables not working
1. Ensure Xcode was launched from terminal with variables set
2. Check that variable name matches exactly
3. Restart Xcode after setting variables

## 📱 Production Deployment

For App Store releases:
1. Use build settings method
2. Set different keys for different environments
3. Use Xcode's configuration files for staging/production
4. Never include development keys in production builds

## 🔄 Key Rotation

When rotating API keys:
1. Generate new key in provider dashboard
2. Update configuration (build settings/xcconfig)
3. Test thoroughly
4. Revoke old key
5. Update team members

## 📞 Support

If you encounter issues:
1. Check the console logs for configuration status
2. Verify your API key is valid in the provider dashboard
3. Ensure all team members have their own keys configured
4. Contact the development team for assistance 