# 🍎 App Store Submission Guide

## PureLife Fitness App - Complete Submission Process

### 🚀 **Quick Start**

```bash
# 1. Run the setup script
./scripts/setup-appstore.sh

# 2. Configure your Team IDs
export TEAM_ID="YOUR_APPLE_DEVELOPER_TEAM_ID"
export ITC_TEAM_ID="YOUR_APP_STORE_CONNECT_TEAM_ID"

# 3. Build and upload to TestFlight
bundle exec fastlane beta
```

---

## 📋 **Step-by-Step Process**

### **Phase 1: Apple Developer Portal Setup**

#### **A. Create App ID and Enable Capabilities**

1. **Go to Apple Developer Portal** → Certificates, Identifiers & Profiles
2. **Create new App ID**:
   - Bundle ID: `com.purelife.fitness`
   - Description: "PureLife Fitness Tracker"
3. **Enable Capabilities**:
   - ✅ HealthKit
   - ✅ Sign in with Apple
   - ✅ Push Notifications
   - ✅ Background Modes
   - ✅ App Groups
   - ✅ Associated Domains

#### **B. Create Certificates**

1. **Development Certificate**:
   - Certificate Signing Request (CSR) from Keychain Access
   - Download and install in Keychain
2. **Distribution Certificate**:
   - Same process for App Store distribution
   - Download and install in Keychain

#### **C. Create Provisioning Profiles**

1. **Development Profile**:
   - Select App ID: `com.purelife.fitness`
   - Select Development Certificate
   - Select test devices
2. **App Store Profile**:
   - Select App ID: `com.purelife.fitness`
   - Select Distribution Certificate

---

### **Phase 2: Xcode Configuration**

#### **A. Project Settings**

```bash
# Open project in Xcode
open Fitness_Appv2.xcworkspace
```

1. **General Tab**:
   - Bundle Identifier: `com.purelife.fitness`
   - Version: `1.0.0`
   - Build: `1` (will be auto-incremented)
   - Deployment Target: `iOS 13.0`

2. **Signing & Capabilities**:
   - Team: Select your Apple Developer Team
   - Provisioning Profile: Automatic (Xcode Managed)
   - Add Capabilities:
     - HealthKit
     - Sign in with Apple
     - Push Notifications
     - Background Modes
     - App Groups

#### **B. Build Settings**

1. **Code Signing**:
   - Code Signing Identity: Apple Distribution
   - Provisioning Profile: Automatic
2. **Build Options**:
   - Enable Bitcode: NO (deprecated)
   - Strip Debug Symbols: YES (Release)
   - Symbols Hidden by Default: YES (Release)

---

### **Phase 3: App Store Connect Setup**

#### **A. Create App Record**

1. **Go to App Store Connect** → My Apps → ➕
2. **App Information**:
   - Name: "PureLife - Fitness Tracker"
   - Bundle ID: `com.purelife.fitness`
   - SKU: `purelife-fitness-001`
   - Primary Language: English (U.S.)

#### **B. App Information**

1. **Category**: Health & Fitness
2. **Content Rights**: Check if you own or have licensed all content
3. **Age Rating**: Complete questionnaire (likely 4+)
4. **App Review Information**:
   - Contact: Your email and phone
   - Demo Account: Not required for this app
   - Notes: "Fitness tracking app with HealthKit integration"

---

### **Phase 4: Fastlane Configuration**

#### **A. Update Configuration Files**

1. **Edit `fastlane/Appfile`**:
```ruby
app_identifier("com.purelife.fitness")
apple_id("your-apple-id@example.com")
itc_team_id("YOUR_ITC_TEAM_ID")
team_id("YOUR_TEAM_ID")
```

2. **Set Environment Variables**:
```bash
export TEAM_ID="YOUR_APPLE_DEVELOPER_TEAM_ID"
export ITC_TEAM_ID="YOUR_APP_STORE_CONNECT_TEAM_ID"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="your-app-specific-password"
```

#### **B. Install Dependencies**

```bash
# Install Ruby dependencies
bundle install

# Install CocoaPods (if needed)
pod install
```

---

### **Phase 5: Screenshots and Assets**

#### **A. App Icon Requirements**

- **1024x1024** pixels for App Store
- **PNG format**, no transparency
- **No text** or UI elements
- **Consistent branding**

#### **B. Screenshot Requirements**

**Device Sizes Required**:
- iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max, etc.)
- iPhone 6.1" (iPhone 15 Pro, 14 Pro, etc.)  
- iPhone 5.5" (iPhone 8 Plus, 7 Plus, 6s Plus)

**For Each Device**:
- Light mode screenshots
- Dark mode screenshots
- 3-5 screenshots showing key features

#### **C. Automated Screenshots**

```bash
# Take screenshots automatically
bundle exec fastlane screenshots

# Or manually capture and place in:
# screenshots/en-US/iPhone67-1.png
# screenshots/en-US/iPhone67-2.png
# etc.
```

---

### **Phase 6: Build and Upload**

#### **A. Test Build Locally**

```bash
# Run tests
bundle exec fastlane test

# Build for testing
bundle exec fastlane build_for_testing
```

#### **B. Upload to TestFlight**

```bash
# Build and upload beta
bundle exec fastlane beta
```

**What this does**:
1. Increments build number
2. Downloads certificates/profiles
3. Builds the app for App Store
4. Uploads to TestFlight
5. Commits version bump
6. Creates git tag

#### **C. Monitor Upload**

1. **Check App Store Connect** → TestFlight
2. **Wait for processing** (usually 1-2 hours)
3. **Test the build** with internal testers
4. **Review crash reports** if any

---

### **Phase 7: App Store Metadata**

#### **A. App Store Listing**

1. **App Name**: "PureLife - Fitness Tracker"
2. **Subtitle**: "Health, Workouts & Rewards"
3. **Keywords**: `fitness,health,workout,tracker,rewards,nutrition,healthkit`

#### **B. Description**

```
Transform your fitness journey with PureLife - the comprehensive fitness tracker that rewards your progress!

🏃‍♀️ TRACK YOUR WORKOUTS
• Seamlessly integrate with Apple Health
• Monitor runs, walks, strength training, and more
• Real-time performance metrics and progress tracking

🎯 EARN REWARDS
• Unique token-based reward system
• Unlock achievements and milestones
• Stay motivated with gamified fitness goals

📊 COMPREHENSIVE ANALYTICS
• Detailed workout history and trends
• Performance insights and recommendations
• Track your fitness journey over time

🥗 NUTRITION GUIDANCE
• AI-powered meal recommendations
• Personalized nutrition plans
• Track your dietary goals alongside workouts

👥 SOCIAL FEATURES
• Connect with friends and fitness enthusiasts
• Share achievements and progress
• Join challenges and stay accountable

🔒 PRIVACY FIRST
• Your health data stays secure and private
• Full control over data sharing
• Transparent privacy practices

Whether you're a beginner starting your fitness journey or an athlete pushing your limits, PureLife adapts to your needs and helps you achieve your goals.

Download PureLife today and start earning rewards for every step, rep, and healthy choice!
```

#### **C. What's New**

```
Welcome to PureLife 1.0! 

🎉 Initial release featuring:
• Complete workout tracking with HealthKit integration
• Token-based reward system for motivation
• AI-powered fitness and nutrition recommendations
• Social features to connect with friends
• Comprehensive analytics and progress tracking
• Beautiful, intuitive interface with dark mode support

Start your fitness journey today and earn rewards for every workout!
```

---

### **Phase 8: Privacy and Compliance**

#### **A. Privacy Policy**

Create and host a privacy policy at: `https://purelife-fitness.app/privacy`

**Required sections**:
- Data collection practices
- HealthKit data usage
- Third-party services (Supabase, OpenAI)
- User rights and controls
- Contact information

#### **B. App Privacy Labels**

In App Store Connect → App Privacy:

1. **Data Collection**: Yes
2. **Data Types**:
   - Health and Fitness ✅
   - Identifiers (User ID) ✅
   - Usage Data ✅
   - Diagnostics ✅

3. **Data Usage**:
   - App Functionality ✅
   - Analytics ✅
   - Personalization ✅

4. **Data Sharing**: No (unless using third-party analytics)

---

### **Phase 9: Final Submission**

#### **A. Pre-Submission Checklist**

Use the comprehensive checklist: `Docs/AppStoreChecklist.md`

#### **B. Submit for Review**

1. **Select Build** in App Store Connect
2. **Complete all metadata** sections
3. **Upload screenshots** for all device sizes
4. **Set pricing** (Free)
5. **Configure release** (Manual or Automatic)
6. **Submit for Review** 🚀

#### **C. Review Process**

- **Timeline**: 24-48 hours typically
- **Status**: Monitor in App Store Connect
- **Communication**: Respond promptly to reviewer feedback

---

## 🛠 **Troubleshooting**

### **Common Issues**

#### **Build Errors**

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean CocoaPods
pod deintegrate && pod install

# Reset Fastlane
bundle exec fastlane certificates
```

#### **Code Signing Issues**

1. **Check certificates** in Keychain Access
2. **Verify provisioning profiles** in Xcode
3. **Use Automatic signing** in Xcode
4. **Clear derived data** and rebuild

#### **Upload Failures**

```bash
# Check Fastlane logs
bundle exec fastlane beta --verbose

# Verify App Store Connect credentials
bundle exec fastlane spaceauth

# Check network connectivity
ping itunesconnect.apple.com
```

### **Rejection Reasons**

#### **Privacy Issues**
- Incomplete privacy manifest
- Incorrect privacy labels
- Missing privacy policy

#### **HealthKit Issues**
- Improper HealthKit usage description
- Requesting unnecessary health permissions
- Not following HealthKit guidelines

#### **Performance Issues**
- App crashes on launch
- Slow performance
- Memory leaks

---

## 📞 **Support**

### **Resources**

- **Apple Developer Documentation**: https://developer.apple.com/documentation/
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Fastlane Documentation**: https://docs.fastlane.tools/
- **HealthKit Guidelines**: https://developer.apple.com/health-fitness/

### **Contact**

- **Developer Support**: Use Apple Developer Forums
- **App Review**: Contact through App Store Connect
- **Technical Issues**: Submit feedback through Xcode

---

**Last Updated**: May 25, 2025  
**Version**: 1.0.0  
**Fastlane Version**: 2.217+ 