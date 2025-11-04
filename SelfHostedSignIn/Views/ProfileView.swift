import SwiftUI
import AuthFoundation

struct ProfileView: View {
    
    let viewModel: LoginViewModel
    @Environment(\.dismiss) var dismiss
    @State private var userInfo: UserInfo?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let user = userInfo {
                    profileContent(user: user)
                } else {
                    errorContent
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                userInfo = await viewModel.fetchUserProfile()
                isLoading = false
            }
        }
    }
    
    private func profileContent(user: UserInfo) -> some View {
        List {
            Section("User Information") {
                ProfileRow(label: "Name", value: user.name ?? "Not provided")
                ProfileRow(label: "Email", value: user.email ?? "Not provided")
                ProfileRow(label: "Username", value: user.preferredUsername ?? "Not provided")
                ProfileRow(label: "User ID", value: user.subject ?? "Unknown")
            }
            
            if let updatedAt = user.updatedAt {
                Section("Metadata") {
                    ProfileRow(label: "Last Updated",
                             value: updatedAt.formatted(date: .long, time: .shortened))
                }
            }
        }
    }
    
    private var errorContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Unable to load profile")
                .font(.headline)
            Text("Please try again later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}
