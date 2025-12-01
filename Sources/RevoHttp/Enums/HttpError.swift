import Foundation

public enum HttpError : Error {
    
    case invalidUrl
    case invalidParams
    case responseError
    case reponseStatusError(response:HttpResponse)
    case undecodableResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl:           "Malformed Url"
        case .invalidParams:        "Invalid input params"
        case .responseError:        "Response returned and error"
        case .reponseStatusError:   "Response returned a non 200 status"
        case .undecodableResponse:  "Undecodable response"
        
        }
    }
}
