import Foundation

enum ProviderType: String {
    case Basic
    case Google
    case Facebook
    case Apple
    case Twiiter
}

struct Usuario {
    var email: String
    var provedor: ProviderType
}
