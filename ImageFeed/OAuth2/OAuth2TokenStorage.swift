import Foundation

protocol TokenStorage {
    var token: String? { get set }
}

final class OAuth2TokenStorage: TokenStorage {
    static let shared = OAuth2TokenStorage()

    private let userDefaults: UserDefaults
    private let key = "OAuthToken"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var token: String? {
        get {
            userDefaults.string(forKey: key)
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}
