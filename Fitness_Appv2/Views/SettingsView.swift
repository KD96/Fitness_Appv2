import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Appearance Section
                Section(header: Text("Appearance")) {
                    // Color Scheme Picker
                    Picker("Theme", selection: $dataStore.currentUser.userPreferences.userAppearance) {
                        ForEach(UserPreferences.AppearanceMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                    
                    Toggle("Enable Notifications", isOn: $dataStore.currentUser.userPreferences.receiveNotifications)
                }
                
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dataStore.currentUser.name)
                            .font(.headline)
                        
                        Text("Member since \(dateFormatter.string(from: dataStore.currentUser.joinDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    NavigationLink(destination: ProfileEditView()) {
                        Text("Edit Profile")
                    }
                }
                
                // MARK: - Fitness Goals Section
                Section(header: Text("Fitness")) {
                    Picker("Primary Goal", selection: $dataStore.currentUser.userPreferences.fitnessGoal) {
                        ForEach(UserPreferences.FitnessGoal.allCases, id: \.self) { goal in
                            Label(goal.rawValue, systemImage: goal.icon)
                                .tag(goal)
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                    }
                }
                
                // MARK: - Logout Section
                Section {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
                
                // Save preferences to UserDefaults
                dataStore.saveData()
            })
            .background(PureLifeColors.adaptiveBackground(scheme: colorScheme).edgesIgnoringSafeArea(.all))
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout? This will reset your session."),
                    primaryButton: .destructive(Text("Logout")) {
                        logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .accentColor(PureLifeColors.logoGreen)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    // MARK: - Logout Function
    private func logout() {
        // Reset onboarding flag in UserDefaults to trigger onboarding flow
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Reset user data or create a new user
        dataStore.resetUserData()
        
        // If there's a central authentication system, log the user out
        
        // Notify the system to show onboarding
        NotificationCenter.default.post(name: Notification.Name("LogoutAndShowOnboarding"), object: nil)
        
        // Dismiss the settings view
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: AppDataStore
    @State private var name: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                TextField("Full Name", text: $name)
                    .padding(.vertical, 10)
            }
            
            Button(action: {
                // Update user data
                if !name.isEmpty {
                    dataStore.currentUser.name = name
                }
                
                // Save data
                dataStore.saveData()
                
                // Dismiss view
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(PureLifeColors.logoGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .navigationBarTitle("Edit Profile", displayMode: .inline)
        .onAppear {
            name = dataStore.currentUser.name
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("PureLife is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by PureLife.")
                    .font(.body)
                
                Text("Information We Collect")
                    .font(.headline)
                
                Text("We collect information that you provide directly to us, such as when you create an account, update your profile, use the interactive features of our app, request customer support, or otherwise communicate with us.")
                    .font(.body)
                
                // Additional privacy policy content would go here
            }
            .padding()
        }
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("By using PureLife, you agree to these terms. Please read them carefully.")
                    .font(.body)
                
                Text("1. Using Our Services")
                    .font(.headline)
                
                Text("You must follow any policies made available to you within the Services. You may use our Services only as permitted by law. We may suspend or stop providing our Services to you if you do not comply with our terms or policies or if we are investigating suspected misconduct.")
                    .font(.body)
                
                // Additional terms of service content would go here
            }
            .padding()
        }
        .navigationBarTitle("Terms of Service", displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppDataStore())
    }
} 