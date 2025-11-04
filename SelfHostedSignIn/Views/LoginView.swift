import SwiftUI
import AuthFoundation

struct LoginView: View {
    
    @State private var viewModel = LoginViewModel()
    @State private var showingProfile = false
    @State private var showingTokenInfo = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.authState {
                case .notAuthenticated, .error:
                    loginFormView
                    
                case .authenticating:
                    loadingView
                    
                case .authenticated:
                    authenticatedView
                }
            }
            .navigationTitle("Okta DirectAuth")
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTokenInfo) {
            TokenDetailsView()
        }
    }
}

// MARK: - Login Form

private extension LoginView {
    
    var loginFormView: some View {
        VStack(spacing: 24) {
            headerView
            
            VStack(spacing: 16) {
                usernameField
                passwordField
            }
            .padding(.horizontal)
            
            loginButton
            
            if let error = viewModel.errorMessage {
                errorView(message: error)
            }
            
            Spacer()
        }
        .padding()
    }
    
    var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Sign in with your Okta credentials")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    var usernameField: some View {
        TextField("Email or Username", text: $viewModel.username)
            .textFieldStyle(.roundedBorder)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.emailAddress)
            .textContentType(.username)
    }
    
    var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .textFieldStyle(.roundedBorder)
            .textContentType(.password)
            .onSubmit {
                if viewModel.canSubmit {
                    Task { await viewModel.login() }
                }
            }
    }
    
    var loginButton: some View {
        Button(action: { Task { await viewModel.login() } }) {
            Text("Sign In")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canSubmit ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.horizontal)
    }
    
    func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(.footnote)
        }
        .foregroundColor(.red)
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Loading View

private extension LoginView {
    
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Signing in...")
                .font(.headline)
        }
    }
}

// MARK: - Authenticated View

private extension LoginView {
    
    var authenticatedView: some View {
        VStack(spacing: 24) {
            successHeader
            
            tokenPreview
            
            actionButtons
            
            Spacer()
        }
        .padding()
    }
    
    var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)
            
            Text("Successfully Authenticated")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You're now signed in to your account")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    var tokenPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Access Token")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView {
                Text(viewModel.token)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
            }
            .frame(height: 120)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingProfile = true }) {
                Label("View Profile", systemImage: "person.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: { showingTokenInfo = true }) {
                Label("Token Details", systemImage: "key.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: { Task { await viewModel.refreshToken() } }) {
                Label("Refresh Token", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
            
            Button(action: { Task { await viewModel.logout() } }) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
        }
    }
}
