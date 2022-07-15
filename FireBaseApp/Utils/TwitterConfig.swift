import Foundation

class TwitterConfig {
    
    static func getConsumerKey() -> String {
        if let info = Bundle(identifier: "com.bugsoft.Firebaseapp")?.infoDictionary, let url: String = info["TwitterKey"] as? String {
            return url
        } else {
            return "no-Key"
        }
    }
    
    static func getConsumerSecret() -> String {
        if let info = Bundle(identifier: "com.bugsoft.Firebaseapp")?.infoDictionary, let url: String = info["TwitterSecret"] as? String {
            return url
        } else {
            return "no-secret"
        }
    }
    
}
