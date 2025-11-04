import Foundation
import AppMetricaCore

enum Event: String {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Screen: String  {
    case main = "main"
    case statistics = "statistics"
    case createTracker = "create_tracker"
    case createCategory = "create_category"
    case editCategory = "edit_category"
    case editTracker = "edit_tracker"
}

enum Item: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    
    // MARK: - Public Static Methods
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "f5a7529f-39b2-45cf-8dde-aae907ab7183") else { return }
        
        AppMetrica.activate(with: configuration)
    }
    
    static func openScreen(name: String) {
        report(event: Event.open.rawValue, params: ["screen": name])
    }
    
    static func closeScreen(name: String) {
        report(event: Event.close.rawValue, params: ["screen": name])
    }
    
    static func clickOnScreen(screenName: String, item: String) {
        report(event: Event.close.rawValue, params: ["screen": screenName, "item": item])
    }
    
    // MARK: - Private Methods
    private static func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

