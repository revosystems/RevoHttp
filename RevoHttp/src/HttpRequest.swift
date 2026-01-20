import Foundation
import RevoFoundation

public class HttpRequest : NSObject {

    public enum Method {
        case get, post, patch, put, delete
    }

    public enum BodyStruct {
        case form([HttpParam]?)
        case json(String?)
    }

    public var method: Method
    public var url: String
    public var queryParams: [HttpParam]
    public var bodyStruct: BodyStruct?
    public var headers: [String: String]

    public var body: String? { // deprecated
        get {
            switch bodyStruct {
            case .json(let string):
                return string
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                bodyStruct = .json(newValue)
            } else {
                bodyStruct = nil
            }
        }
    }

    public var timeout: TimeInterval?
    
    public init(
        method: Method,
        url: String,
        queryParams: HttpParamProtocol = [:],
        bodyStruct: BodyStruct? = nil,
        headers: [String: String] = [:]
    ) {
        self.method      = method
        self.url         = url
        self.queryParams = queryParams.createParams(nil)
        self.bodyStruct  = bodyStruct
        self.headers     = headers
    }

    convenience public init(method: Method, url: String) {
        self.init(method: method, url: url, queryParams: [:], bodyStruct: nil, headers: [:])
    }

    convenience public init(method: Method, url: String, headers: [String:String] = [:]) {
        self.init(method: method, url: url, queryParams: [:], bodyStruct: nil, headers: headers)
    }

    convenience public init(method: Method, url: String, queryParams: HttpParamProtocol = [:], headers: [String:String] = [:]) {
        self.init(method: method, url: url, queryParams: queryParams, bodyStruct: nil, headers: headers)
    }

    convenience public init(method: Method, url: String, queryParams: HttpParamProtocol = [:], body: String? = nil, headers: [String:String] = [:]) {
        self.init(method: method, url: url, queryParams: queryParams, bodyStruct: .json(body), headers: headers)
    }

    convenience public init(method: Method, url: String, queryParams: HttpParamProtocol = [:], form: HttpParamProtocol = [:], headers: [String: String] = [:]) {
        self.init(method: method, url: url, queryParams: queryParams, bodyStruct: .form(form.createParams(nil)), headers: headers)
    }

    @available(*, deprecated, message: "'params' is deprecated. Use 'queryParams' or body 'form' instead.")
    convenience public init(method: Method, url: String, params: HttpParamProtocol = [:], body: String? = nil, headers: [String:String] = [:]) {
        if method == .get {
            self.init(method: method, url: url, queryParams: params, bodyStruct: nil, headers: headers)
            return
        }
        self.init(method: method, url: url, queryParams: [:], bodyStruct: .form(params.createParams(nil)), headers: headers)
    }
    
    public func generate() -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "\(method)"
        
        if let timeout = self.timeout {
            request.timeoutInterval = timeout
        }

        request.url = URL(string: buildUrl())

        request.httpBody = bodyStruct.flatMap { body -> Data? in
            switch body {
            case .json(let string?) where !string.isEmpty && string != "{}":
                return string.data(using: .utf8)
            case .form(let params?) where !params.isEmpty:
                return buildFormBody()?.data(using: .utf8)
            default:
                return nil
            }
        }

        addHeaders(&request)
        
        return request
    }

    private func buildParams(_ params: [HttpParam]) -> String {
        params.map { param in
            param.encoded()
        }.implode("&")
    }

    private func buildUrl() -> String {
        queryParams.isEmpty
            ? url
            : "\(url)?\(buildQueryParams())"
    }

    private func buildQueryParams() -> String {
        buildParams(queryParams)
    }

    private func buildFormParams(_ params: [HttpParam]) -> String {
        params.map { param in
            param.formEncoded()
        }.implode("&")
    }

    private func buildFormBody() -> String? {
        guard case .form(let params?) = bodyStruct else {
            return nil
        }

        return buildFormParams(params)
    }

    private func addHeaders(_ request:inout URLRequest){
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    
    public func toCurl() -> String {
        var result = "curl "
        var parameters: [HttpParam] = []

        if case .form(let params?) = bodyStruct {
            parameters = params
        } else {
            parameters = queryParams
        }
        let p = parameters.map { param in
            param.encoded()
        }.implode("&")
        
        if (p.count > 0) {
            result = result + "-d \"\(p)\""
        }
        
        let h = headers.map { key, value in
            "-H \"\(key): \(value)\""
        }.implode(" ")
        
        if (h.count > 0){
            result = result + " \(h)"
        }
        
        return result + " -X \(methodUppercased) \(url)"
    }
    
    public func toString() -> String {
        return ""
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
        for (k, v) in self {
            if let nestedKey = k as? String {
                let useKey = key != nil ? "\(key!)[\(nestedKey)]" : nestedKey
                if let subParam = v as? HttpParamProtocol {
                    collect.append(contentsOf: subParam.createParams(useKey))
                } else {
                    collect.append(HttpParam(key: useKey, storedValue: v as AnyObject))
                }
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
        } else if let v = storedValue as? String {
            return v
        } else {
            return storedValue.description ?? ""
        }
    }
        
    fileprivate func encoded() -> String {
        "\(key)=\(value.urlEncoded() ?? "")"
    }

    fileprivate func formEncoded() -> String {
        "\(key)=\(value.formURLEncoded() ?? "")"
    }
}

extension String {
    func formURLEncoded() -> String {
        let unreserved = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*"
        var allowed = CharacterSet()
        allowed.insert(charactersIn: unreserved)

        var encoded = self.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        encoded = encoded.replacingOccurrences(of: " ", with: "+")
        return encoded
    }
}
