import Foundation

enum StorageKeys: String {
    case hasSeenOnboarding
}

final class OnboardingStorage {
    
    // MARK: - Shared Instance
    static let shared = OnboardingStorage()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Private Properties
    private let storage: UserDefaults = .standard
    
    // MARK: - Public Properties
    var hasSeenOnboarding: Bool {
        get {
            storage.bool(forKey: StorageKeys.hasSeenOnboarding.rawValue)
        }
        set {
            storage.set(newValue, forKey: StorageKeys.hasSeenOnboarding.rawValue)
        }
    }
}
