import SwiftUI
import AuthFoundation

struct TokenDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    private var credential: Credential? {
        Credential.default
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let token = credential?.token {
                        tokenSection(title: "Token Type", value: token.tokenType)
                        
                        tokenSection(title: "Access Token",
                                   value: token.accessToken,
                                   monospaced: true)
                        
                        if let scopes = token.scope {
                            tokenSection(title: "Scopes",
                                       value: scopes.joined(separator: ", "))
                        }
                        
                        if let idToken = token.idToken?.rawValue {
                            tokenSection(title: "ID Token",
                                       value: idToken,
                                       monospaced: true)
                        }
                        
                        if let refreshToken = token.refreshToken {
                            tokenSection(title: "Refresh Token",
                                       value: refreshToken,
                                       monospaced: true)
                        }
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("Token Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func tokenSection(title: String, value: String, monospaced: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(value)
                .font(monospaced ? .system(.caption, design: .monospaced) : .caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Token Available")
                .font(.headline)
            Text("Please sign in to view token details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

