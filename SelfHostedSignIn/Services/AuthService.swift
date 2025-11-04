import Foundation
import AuthFoundation
import OktaDirectAuth
import Observation

protocol AuthServicing {
    var isAuthenticated: Bool { get }
    var currentToken: String? { get }
    var authenticationState: AuthService.AuthState { get }
    
    func authenticate(username: String, password: String) async throws
    func logout() async throws
    func refreshAccessToken() async throws
    func getCurrentUser() async throws -> UserInfo?
}

@Observable
final class AuthService: AuthServicing {
    
    // MARK: - Authentication States
    
    enum AuthState: Equatable {
        case notAuthenticated
        case authenticating
        case authenticated
        case error(String)
    }
    
    // MARK: - Properties
    
    private(set) var authenticationState: AuthState = .notAuthenticated
    
    private let directAuth: DirectAuthenticationFlow?
    
    var isAuthenticated: Bool {
        authenticationState == .authenticated
    }
    
    var currentToken: String? {
        Credential.default?.token.accessToken
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize DirectAuth with configuration from Okta.plist
        if let config = try? OAuth2Client.PropertyListConfiguration()  {
            self.directAuth = try? DirectAuthenticationFlow(client: OAuth2Client(config))
        } else {
            self.directAuth = try? DirectAuthenticationFlow()
        }
        
        // Check for existing credential
        if Credential.default?.token != nil {
            authenticationState = .authenticated
        }
    }
    
    // MARK: - Authentication Methods
    
    func authenticate(username: String, password: String) async throws {
        authenticationState = .authenticating
        
        do {
            // Perform password-based authentication
            let response = try await directAuth?.start(username, with: .password(password))
            
            // Handle the authentication response
            switch response {
            case .success(let token):
                // Store credential securely in keychain
                let credential = try Credential.store(token)
                Credential.default = credential
                authenticationState = .authenticated
                
            default:
                authenticationState = .error("Authentication failed")
            }
            
        } catch {
            authenticationState = .error(error.localizedDescription)
            throw error
        }
    }
    
    func logout() async throws {
        // Revoke tokens on the server
        if let credential = Credential.default {
            try? await credential.revoke()
        }
        
        // Clear local credential
        Credential.default = nil
        authenticationState = .notAuthenticated
    }
    
    func refreshAccessToken() async throws {
        guard let credential = Credential.default else {
            throw NSError(domain: "CredentialManager",
                         code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No credential available"])
        }
        
        try await credential.refresh()
    }
    
    func getCurrentUser() async throws -> UserInfo? {
        // Check for cached user info first
        if let cached = Credential.default?.userInfo {
            return cached
        }
        
        // Fetch from server if not cached
        return try await Credential.default?.userInfo()
    }
}
