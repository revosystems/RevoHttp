import Foundation

public class Http : NSObject {
    
    public static var debugMode = false
    
    public static func call(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: method, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func call<T:Codable>(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:T?, _ error:Error?) -> Void) {
        let request = HttpRequest(method: method, url: url, params: params, headers: headers)
        Self.call(request) { response in
            let result:T? = response.decoded()
            then(result, response.error)
        }
    }
    
    public static func get(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .get, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func post(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func post(_ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = body
        Self.call(request, then:then)
    }
    
    public static func put(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .put, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func patch(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .patch, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func delete(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .delete, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    @objc dynamic public class func call(_ request:HttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        if (Self.debugMode) {
            debugPrint("****** HTTP DEBUG ***** " + request.toCurl())
        }
        
        guard let urlRequest  = request.generate() else {
            return then(HttpResponse(failed: "Invalid URL"))
        }
        let session     = Self.getUrlSession()
        let dataTask    = session.dataTask(with: urlRequest) { data, urlResponse, error in
            DispatchQueue.main.async {
                then(HttpResponse(data:data, response:urlResponse, error:error))
            }
        }
        dataTask.resume()
    }
    
    public static func getUrlSession() -> URLSession {
        URLSession.shared
    }
}
