import Foundation
import AuthFoundation
import Observation

@Observable
final class LoginViewModel {
    
    // MARK: - Dependencies
    
    private let authService: AuthServicing
    
    // MARK: - UI State
    
    var username: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    var authState: AuthService.AuthState {
        authService.authenticationState
    }
    
    var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }
    
    var token: String {
        authService.currentToken ?? "No Token"
    }
    
    // MARK: - Initialization
    
    init(authService: AuthServicing = AuthService()) {
        self.authService = authService
    }
    
    // MARK: - Actions
    
    @MainActor
    func login() async {
        errorMessage = nil
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await authService.authenticate(username: username, password: password)
            // Clear password after successful login
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func logout() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.logout()
            username = ""
            password = ""
            errorMessage = nil
        } catch {
            errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func refreshToken() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.refreshAccessToken()
        } catch {
            errorMessage = "Token refresh failed: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchUserProfile() async -> UserInfo? {
        do {
            return try await authService.getCurrentUser()
        } catch {
            errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
            return nil
        }
    }
}
