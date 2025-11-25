import Foundation
import RevoFoundation

public class Http : NSObject {
    
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
    
    //MARK: - Call
    public func call(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    public func call(_ method:HttpRequest.Method, _ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, headers: headers)
        request.body = body
        call(request, then:then)
    }
    
    public func call<Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, headers: headers)
    
        guard let data = try? JSONEncoder().encode(json) else {
            return then(HttpResponse(failed: "Request not Encodable"))
        }
        guard let body = String(data:data, encoding: .utf8) else {
            return then(HttpResponse(failed: "Can't encode request data to string"))
        }
        request.body = body
                
        call(request, then: then)
    }
    
    public func call<T:Codable,Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:], then:@escaping(_ response:T?, _ error:String?) -> Void) {
        let request = HttpRequest(method: method, url: url, headers: headers)
    
        guard let data = try? JSONEncoder().encode(json) else {
            return then(nil, "Not encodable")
        }
        guard let body = String(data:data, encoding: .utf8) else {
            return then(nil, "Can't convert to string")
        }
        request.body = body
                
        call(request) { response in
            let result:T? = response.decoded()
            then(result, response.error?.localizedDescription)
        }
    }
    
    public func call<T:Codable>(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:T?, _ error:Error?) -> Void) {
        let request = HttpRequest(method: method, url: url, params: params, headers: headers)
        call(request) { response in
            let result:T? = response.decoded()
            then(result, response.error)
        }
    }
    
    public func get(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .get, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    public func post(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    public func post(_ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = body
        call(request, then:then)
    }
    
    public func put(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .put, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    public func patch(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .patch, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    public func delete(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .delete, url: url, params: params, headers: headers)
        call(request, then:then)
    }
    
    @objc dynamic public func call(_ request:HttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        debugIfNeeded(request)
        
        if let hmac = hmac {
            if let hash = request.buildBody().hmac256(hmac.privateKey) {
                request.headers[hmac.header] = hash
            }
        }
        
        if let timeout = timeout {
            request.timeout = TimeInterval(timeout)
        }
        
        guard let urlRequest  = request.generate() else {
            return then(HttpResponse(failed: "Invalid URL"))
        }
        let session     = urlSession
        let dataTask    = session.dataTask(with: urlRequest) { data, urlResponse, error in
            DispatchQueue.main.async {
                then(HttpResponse(data:data, response:urlResponse, error:error))
            }
        }
        dataTask.resume()
    }
    
    @objc dynamic public func callMultipart(_ request:MultipartHttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        debugIfNeeded(request)
        
        guard let urlRequest  = request.generate() else {
            return then(HttpResponse(failed: "Invalid URL"))
        }
        let session     = urlSession
        let dataTask    = session.uploadTask(with: urlRequest, from: request.generateData()) { responseData, urlResponse, error in
            DispatchQueue.main.async {
                then(HttpResponse(data:responseData, response:urlResponse, error:error))
            }
        }
        dataTask.resume()
    }
    
    //MARK: Crypto
    public func withHmacSHA256(header:String, privateKey:String) -> Self {
        hmac = Hmac(header: header, privateKey: privateKey)
        return self
    }
    
    //MARK: URLSession
    public func with(session: URLSession) -> Self {
        urlSession = session
        return self
    }
    
    public func allowUnsecureUrls() -> Self {
        insecureUrlSession = InsecureUrlSession()
        urlSession = insecureUrlSession!.session
        return self
    }
    
    public func withTimeout(seconds:Int) -> Self {
        self.timeout = seconds
        return self
    }
    
    private func debugIfNeeded(_ request: HttpRequest) {
        guard Self.debugMode else { return }
        debugPrint("****** HTTP DEBUG ***** " + request.toCurl())
    }
}


extension Http {
    public func call<T:Codable>(_ method:HttpRequest.Method, _ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws(HttpError) -> T {
        let response = await call(HttpRequest(method: method, url: url, params:params, headers: headers))
        print(response.toString)
        guard response.error == nil             else { throw .responseError }
        guard response.isSuccessful             else { throw .reponseStatusError(response: response) }
        guard let result:T = response.decoded() else { throw .undecodableResponse }
        return result
    }
    
    @objc dynamic public func call(_ request:HttpRequest) async -> HttpResponse {
        debugIfNeeded(request)
        
        if let hmac, let hash = request.buildBody().hmac256(hmac.privateKey) {
            request.headers[hmac.header] = hash
        }
        
        if let timeout {
            request.timeout = TimeInterval(timeout)
        }
        
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
        
        guard let urlRequest  = request.generate() else {
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
}
