import Foundation
import RevoFoundation

public class HttpRequest : NSObject, @unchecked Sendable {

    public enum Method {
        case get, post, patch, put, delete
    }
    
    public var method  :Method
    public var url     :String
    public var params  :[HttpParam]
    public var headers :[String: String]
    public var body    :String?
    
    public var timeout:TimeInterval?
    
    public init(method:Method, url:String, params:HttpParamProtocol = [:], headers:[String:String] = [:]){
        self.method  = method
        self.url     = url
        self.params  = params.createParams(nil)
        self.headers = headers
    }
    
    public func generate() -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        
        var request = URLRequest(url: url)
        
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
        return params.map { param in
            param.encoded(urlEncoded: encoded)
        }.implode("&")
    }
    
    
    func buildUrl() -> String {
        url + "?" + buildBody(true)
    }
    
    private func addHeaders(_ request:inout URLRequest){
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    
    public func toCurl() -> String {
        var result = "curl "
        let p = params.map { param in
            param.encoded()
        }.implode("&")
        
        if (p.count > 0) {
            result = result + "-d \"\(p)\""
        }
        
        let h = headers.keys.sorted().compactMap { key in
            guard let value = headers[key] else { return nil }
            return "-H \"\(key): \(value)\""
        }.implode(" ")
        
        if (h.count > 0){
            result = result + " \(h)"
        }
        
        return result + " -X \(methodUppercased) \(url)"
    }
    
    public func toString() -> String {
        ""
    }
    
    var methodUppercased: String {
        "\(method)".uppercased()
    }
}

public protocol HttpParamProtocol {
    func createParams(_ key: String?) -> [HttpParam]
}

extension Dictionary : HttpParamProtocol{
    public func createParams(_ key: String?) -> [HttpParam] {
        var collect = [HttpParam]()
        for k in self.keys.compactMap({ $0 as? String }).sorted() {
            guard let k = k as? Key else { continue }
            let useKey = key != nil ? "\(key!)[\(k)]" : "\(k)"
            if let subParam = self[k] as? HttpParamProtocol {
                collect.append(contentsOf: subParam.createParams(useKey))
            } else {
                collect.append(HttpParam(key: useKey, storedValue: self[k] as AnyObject))
            }
        }
        return collect
    }
}

public struct HttpParam{
    var key: String
    let storedValue: AnyObject
    
    var value: String {
        if storedValue is NSNull {
            return ""
        }
        return storedValue as? String ?? storedValue.description ?? ""
    }
        
    public func encoded(urlEncoded:Bool = false) -> String {
        "\(key)=\(urlEncoded ? value.urlEncoded() ?? "" : value)"
    }
}
