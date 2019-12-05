import Foundation
import RevoFoundation

public class HttpRequest : NSObject {

    public enum Method {
        case get, post, patch, put, delete
    }
    
    var method:Method
    var url:String
    var params:[String:String]
    var headers:[String: String]
    var body:String?
    
    var timeout:TimeInterval?
    
    public init(method:Method, url:String, params:[String:String] = [:], headers:[String:String] = [:]){
        self.method  = method
        self.url     = url
        self.params  = params
        self.headers = headers
    }
    
    public func generate() -> URLRequest{
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "\(method)"
        
        if let timeout = self.timeout {
            request.timeoutInterval = timeout
        }
        
        if (method == .get){
            request.url = URL(string: buildUrl())
        } else {
            request.httpBody = (body ?? buildBody()).data(using: .utf8)
        }
        
        addHeaders(&request)
        
        return request
    }
    
    func buildBody(_ encoded:Bool = false) -> String {
        return params.map { key, value in
            encoded ? "\(key)=\(value.urlEncoded() ?? "")" : "\(key)=\(value)"
        }.implode("&")
    }
    
    
    private func buildUrl() -> String {
        url + "?" + buildBody(true)
    }
    
    private func addHeaders(_ request:inout URLRequest){
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    public func toCurl() -> String {
        var result = "curl "
        let p = params.map { key, value in
            "\(key)=\(value)"
        }.implode("&")
        
        if (p.count > 0) {
            result = result + "-d \(p)"
        }
        
        let h = headers.map { key, value in
            "-H \(key): \(value)"
        }.implode(" ")
        
        if (h.count > 0){
            result = result + " \(h)"
        }
        
        return result + " -X \(method) \(url)"
    }
    
    public func toString() -> String {
        return ""
    }
    
    
}
