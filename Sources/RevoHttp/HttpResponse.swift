import Foundation

public final class HttpResponse : NSObject, Sendable {
    
    public let data:Data?
    public let response:URLResponse?
    public let error:Error?
    
    public init(data:Data? = nil, response:URLResponse? = nil, error:Error? = nil) {
        self.data       = data
        self.response   = response
        self.error      = error
    }
    
    public init(failed:String) {
        self.data       = nil
        self.response   = nil
        self.error      = HttpError.invalidUrl
    }
    
    public var statusCode:Int {
        (response as? HTTPURLResponse)?.statusCode ?? 0
    }
    
    public var errorMessage:String? {
        error?.localizedDescription
    }
    
    public var toString:String {
        guard error == nil      else { return "RevoHttp Error: \(errorMessage ?? "")" }
        guard let data          else { return "RevoHttp Error: No Data" }
        return String(data:data, encoding:.utf8) ?? "RevoHttp Error: Data non convertible to string"
    }
    
    public var isSuccessful:Bool {
        statusCode >= 200 && statusCode < 300
    }
    
    public func decoded<T:Codable>() -> T? {
        guard let data else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            debugPrint("** Can't decode HttpResponse:" + error.localizedDescription)
            return nil
        }
    }
    
}
