import Foundation

enum HttpError : Error {
    
    case invalidUrl
    case invalidParams
    case responseError
    case reponseStatusError(response:HttpResponse)
    case undecodableResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl: return "Malformed Url"
        case .invalidParams: return "Invalid input params"
        case .responseError: return "Response returned and error"
        case .reponseStatusError: return "Response returned a non 200 status"
        case .undecodableResponse: return "Undecodable response"
        
        }
    }
}
