import Foundation

public enum HttpError : Error {
    
    case invalidUrl
    case invalidParams
    case responseError(errorMessage:String? = nil)
    case responseStatusError(response:HttpResponse)
    case undecodableResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl: return "Malformed Url"
        case .invalidParams: return "Invalid input params"
        case .responseError: return "Response returned and error"
        case .responseStatusError: return "Response returned a non 200 status"
        case .undecodableResponse: return "Undecodable response"
        
        }
    }
}
