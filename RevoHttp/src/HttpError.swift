import Foundation

enum HttpError : Error {
    
    case invalidUrl
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl: return "Malformed Url"
        }
    }
}
