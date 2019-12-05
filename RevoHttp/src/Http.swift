import Foundation

public class Http : NSObject {
    
    static var debugMode = false
    
    public static func call(_ method:HttpRequest.Method, url:String, params:[String:String] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {        
        let request = HttpRequest(method: method, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func get(_ url:String, params:[String:String] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .get, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func post(_ url:String, params:[String:String] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, params: params, headers: headers)
        Self.call(request, then:then)
    }
    
    public static func post(_ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = body
        Self.call(request, then:then)
    }
    
    public static func call(_ request:HttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        if (Self.debugMode) {
            debugPrint("****** HTTP DEBUG ***** " + request.toCurl())
        }
        
        let urlRequest  = request.generate()
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
