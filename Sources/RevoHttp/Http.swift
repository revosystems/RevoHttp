import Foundation

public class Http : NSObject, Resolvable, @unchecked Sendable {
    
    nonisolated(unsafe) public static var debugMode = false
    var insecureUrlSession:InsecureUrlSession?
    var timeout:Int?
    var hmac:Hmac?
    
    lazy var urlSession:URLSession = {
        URLSession.shared
    }()
    
    struct Hmac {
        let header:String
        let privateKey:String
    }
    
    override public required init() {}
    
    //MARK: - Call
    public func call(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: method, url: url, params: params, headers: headers))
    }
    
    public func call(_ method:HttpRequest.Method, _ url:String, body:String, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: method, url: url, headers: headers)
        request.body = body
        return await call(request)
    }
    
    public func call<Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: method, url: url, headers: headers)
    
        guard let data = try? JSONEncoder().encode(json) else {
            return HttpResponse(failed: "Request not Encodable")
        }
        guard let body = String(data:data, encoding: .utf8) else {
            return HttpResponse(failed: "Can't encode request data to string")
        }
        request.body = body
                
        return await call(request)
    }
    
    public func call<T:Codable,Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:]) async -> (T?, String?) {
        let response = await call(method, url, json: json, headers: headers)
        let result:T? = response.decoded()
        return (result, response.error?.localizedDescription)
    }
    
    public func call<T:Codable>(_ method:HttpRequest.Method, _ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws(HttpError) -> T {
        let response = await call(HttpRequest(method: method, url: url, params:params, headers: headers))
        print(response.toString)
        guard response.error == nil             else { throw .responseError }
        guard response.isSuccessful             else { throw .reponseStatusError(response: response) }
        guard let result:T = response.decoded() else { throw .undecodableResponse }
        return result
    }
    
    public func call(_ request:HttpRequest) async -> HttpResponse {
        debugIfNeeded(request)
        
        if let hmac, let hash = request.buildBody().hmac256(hmac.privateKey) {
            request.headers[hmac.header] = hash
        }
        
        if let timeout {
            request.timeout = TimeInterval(timeout)
        }
        
        return await makeCall(request)
    }
    
    @objc dynamic public func makeCall(_ request:HttpRequest) async -> HttpResponse {
        guard let urlRequest = request.generate() else {
            return HttpResponse(failed: "Invalid URL")
        }
        
        do {
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            return HttpResponse(data:data, response:urlResponse)
        } catch {
            return HttpResponse(error: error)
        }
    }
    
    @objc dynamic public func callMultipart(_ request:MultipartHttpRequest) async -> HttpResponse {
        debugIfNeeded(request)
        
        guard let urlRequest = request.generate() else {
            return HttpResponse(failed: "Invalid URL")
        }
        
        do {
            let (data, urlResponse) = try await urlSession.upload(for: urlRequest, from: request.generateData())
            return HttpResponse(data:data, response:urlResponse)
        } catch {
            return HttpResponse(error: error)
        }
    }
    
    public func get(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: .get, url: url, params: params, headers: headers))
    }
    
    public func post(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: .post, url: url, params: params, headers: headers))
    }
    
    public func post(_ url:String, body:String, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = body
        return await call(request)
    }
    
    public func put(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: .put, url: url, params: params, headers: headers))
    }
    
    public func patch(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: .patch, url: url, params: params, headers: headers))
    }
    
    public func delete(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await call(HttpRequest(method: .delete, url: url, params: params, headers: headers))
    }
    
    public func withOptions(_ options: [HttpOption]) -> Self {
        for option in options {
            switch option {
            case .hmacSHA256(let header, let privateKey):
                hmac = Hmac(header: header, privateKey: privateKey)
            case .timeout(let seconds):
                timeout = seconds
            case .session(let session):
                urlSession = session
            case .allowUnsecureUrls:
                insecureUrlSession = InsecureUrlSession()
                urlSession = insecureUrlSession!.session
            }
        }
        return self
    }
    
    private func debugIfNeeded(_ request: HttpRequest) {
        guard Self.debugMode else { return }
        debugPrint("****** HTTP DEBUG ****** " + request.toCurl())
    }
}


import CryptoKit
extension String {
    func hmac256(_ key:String) -> String? {
        guard let messageData = self.data(using: .utf8), let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        let code = HMAC<SHA256>.authenticationCode(for: messageData, using: SymmetricKey(data: keyData))
        return Data(code).map { String(format: "%02hhx", $0) }.joined()
    }
}
