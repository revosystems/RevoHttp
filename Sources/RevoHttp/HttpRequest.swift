import Foundation

public class HttpRequest : NSObject, @unchecked Sendable {

    public enum Method {
        case get, post, patch, put, delete
    }

    public enum BodyStruct {
        case form([HttpParam]?)
        case string(String?)
        case json(Encodable?)
    }
    
    public struct Hmac {
        let header:String
        let privateKey:String
    }

    public var method: Method
    public var url: String
    public var queryParams: [HttpParam]
    public var headers: [String: String]
    public var body: BodyStruct? {
        didSet {
            if case .json = body {
                headers["Content-Type"] = "application/json"
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
        self.body  = bodyStruct
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

        request.httpBody = body.flatMap { body -> Data? in
            switch body {
            case .json(let encodable?):
                try? JSONEncoder().encode(encodable)
            case .string(let string?):
                string.data(using: .utf8)
            case .form(let params?) where !params.isEmpty:
                buildFormBody()?.data(using: .utf8)
            default:
                nil
            }
        }

        addHeaders(&request)
        
        return request
    }

    public func withHmacHeader(_ hmac: Hmac) {
        let payload = switch body {
        case .json(let encodable?):      String(data: try! JSONEncoder().encode(encodable), encoding: .utf8)!
            case .string(let string?): string
            case .form:              buildFormBody() ?? ""
            default:                 buildQueryParams()
        }
        if let hash = payload.hmac256(hmac.privateKey) {
            headers[hmac.header] = hash
        }
    }
        
    private func buildParams(_ params: [HttpParam]) -> String {
        params.map { param in
            param.encoded()
        }.joined(separator: "&")
    }

    func buildUrl() -> String {
        queryParams.isEmpty
            ? url
            : "\(url)?\(buildQueryParams())"
    }

    func buildQueryParams() -> String {
        buildParams(queryParams)
    }

    private func buildFormParams(_ params: [HttpParam]) -> String {
        params.map { param in
            param.formEncoded()
        }.joined(separator: "&")
    }

    func buildFormBody() -> String? {
        guard case .form(let params?) = body else {
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

        if case .form(let params?) = body {
            parameters = params
        } else {
            parameters = queryParams
        }
        let p = parameters.map { param in
            param.encoded()
        }.joined(separator: "&")
        
        if (p.count > 0) {
            result += "-d \"\(p)\""
        }
        
        let h = headers.keys.sorted().compactMap { key in
            guard let value = headers[key] else { return nil }
            return "-H \"\(key): \(value)\""
        }.joined(separator: " ")
        
        if (h.count > 0){
            result += " \(h)"
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
        
    fileprivate func encoded() -> String {
        "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
    }

    fileprivate func formEncoded() -> String {
        "\(key)=\(value.formURLEncoded())"
    }
}

import CryptoKit
extension String {
    func formURLEncoded() -> String {
        let unreserved = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*"
        var allowed = CharacterSet()
        allowed.insert(charactersIn: unreserved)

        var encoded = self.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        encoded = encoded.replacingOccurrences(of: " ", with: "+")
        return encoded
    }
    
    func hmac256(_ key:String) -> String? {
        guard let messageData = self.data(using: .utf8), let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        let code = HMAC<SHA256>.authenticationCode(for: messageData, using: SymmetricKey(data: keyData))
        return Data(code).map { String(format: "%02hhx", $0) }.joined()
    }
}
