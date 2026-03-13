import Foundation

extension Http {

    public static func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], body: String? = nil, headers: [String:String] = [:], timeout: Int = 30, then:@escaping(_ response:HttpResponse) -> Void) {
        Http().call(method, url: url, queryParams: queryParams, body: body, headers: headers, timeout: timeout, then: then)
    }

    public static func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], form: [String:Codable] = [:], headers: [String:String] = [:], timeout: Int = 30, then:@escaping(_ response:HttpResponse) -> Void) {
        Http().call(method, url: url, queryParams: queryParams, form: form, headers: headers, timeout: timeout, then: then)
    }

    public static func call(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        Http().call(method, url:url, params:params, headers:headers, then:then)
    }
    
    public static func call(_ method:HttpRequest.Method, _ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        Http().call(method, url, body: body, headers: headers, then: then)
    }
    
    public static func call<Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        Http().call(method, url, json:json, headers:headers, then:then)
    }
    
    public static func call<T:Codable,Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:], then:@escaping(_ response:T?, _ error:String?) -> Void) {
        Http().call(method, url, json:json, headers:headers, then:then)
    }
    
    public static func get(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .get, url: url, params: params, headers: headers)
        Http().call(request, then:then)
    }
    
    public static func post(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, params: params, headers: headers)
        Http().call(request, then:then)
    }
    
    public static func post(_ url:String, body:String, headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = body
        Http().call(request, then:then)
    }
    
    public static func put(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .put, url: url, params: params, headers: headers)
        Http().call(request, then:then)
    }
    
    public static func patch(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .patch, url: url, params: params, headers: headers)
        Http().call(request, then:then)
    }
    
    public static func delete(_ url:String, params:[String:Codable] = [:], headers:[String:String] = [:], then:@escaping(_ response:HttpResponse) -> Void) {
        let request = HttpRequest(method: .delete, url: url, params: params, headers: headers)
        Http().call(request, then:then)
    }
}
