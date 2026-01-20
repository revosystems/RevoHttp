import Foundation
import RevoFoundation

public class Http : NSObject {
    
    public static var debugMode = false
    var insecureUrlSession:InsecureUrlSession?
    var timeout:Int?
    var hmac:Hmac?
    
    lazy var urlSession:URLSession = {
        URLSession.shared
    }()
    
    typealias Hmac = HttpRequest.Hmac

    //MARK: - Call
    public func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], body: String? = nil, headers: [String:String] = [:], timeout: Int = 30, then:@escaping(_ response: HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, queryParams: queryParams, body: body, headers: headers)
        request.timeout = TimeInterval(timeout)
        call(request, then:then)
    }

    public func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], form: [String:Codable] = [:], headers: [String:String] = [:], timeout: Int = 30, then:@escaping(_ response: HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, queryParams: queryParams, form: form, headers: headers)
        request.timeout = TimeInterval(timeout)
        call(request, then:then)
    }

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
    
    //MARK: Async call
    public func call<T:Codable>(_ method:HttpRequest.Method, _ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            let request = HttpRequest(method: method, url: url, params:params, headers: headers)
                    
            call(request) { response in
                print(response.toString)
                guard response.error == nil else {
                    return continuation.resume(throwing: HttpError.responseError)
                }
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    return continuation.resume(throwing: HttpError.reponseStatusError(response: response))
                }
                guard let result:T = response.decoded() else {
                    return continuation.resume(throwing: HttpError.undecodableResponse)
                }
                return continuation.resume(returning:result)
            }
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
        if (Self.debugMode) {
            debugPrint("****** HTTP DEBUG ***** " + request.toCurl())
        }
        
        if let hmac = hmac {
            request.withHmacHeader(hmac)
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
        if (Self.debugMode) {
            debugPrint("****** HTTP DEBUG ***** " + request.toCurl())
        }
        
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
}
