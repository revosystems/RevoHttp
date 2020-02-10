import Foundation

enum HttpError : Error {
    case invalidUrl
}

public class HttpResponse : NSObject {
    
    public let data:Data?
    public let response:URLResponse?
    public let error:Error?
    
    public init(data:Data?, response:URLResponse?, error:Error?){
        self.data       = data
        self.response   = response
        self.error      = error
    }
    
    public init(failed:String){
        self.data       = nil
        self.response   = nil
        self.error      = HttpError.invalidUrl
    }
    
    public var statusCode:Int{
        (response as? HTTPURLResponse)?.statusCode ?? 0
    }
    
    public var errorMessage:String? {
        guard let error = error else { return nil }
        return error.localizedDescription
    }
    
    public var toString:String {
        guard error == nil      else { return "RevoHttp Error: \(errorMessage ?? "")" }
        guard let data = data   else { return "RevoHttp Error: No Data" }
        return String(data:data, encoding:.utf8) ?? "RevoHttp Error: Data non convertible to string"
    }
    
    public func decoded<T:Codable>() -> T? {
        guard let data = data else { return nil }
        do {
            return try T.decode(from: data)
        } catch {
            debugPrint("** Can't decode HttpResponse:" + error.localizedDescription)
            return nil
        }
    }
    
}
