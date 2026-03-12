
import Foundation

extension Http {
    private static func httpInstance() async -> Http {
        await ThreadSafeContainer.shared.resolve(Http.self)!
    }
    
    // MARK: Generic methods
    
    public static func call(_ method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(method, url: url, params:params, headers:headers)
    }
    
    public static func call(_ method:HttpRequest.Method, _ url:String, body:String, headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(method, url, body: body, headers: headers)
    }
    
    public static func call<Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(method, url, json:json, headers:headers)
    }
    
    public static func call<T:Codable,Z:Encodable>(_ method:HttpRequest.Method, _ url:String, json:Z, headers:[String:String] = [:]) async -> (T?, String?) {
        await httpInstance().call(method, url, json:json, headers:headers)
    }
    
    public static func call<T:Codable>(_ method:HttpRequest.Method, _ url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws(HttpError) -> T {
        try await httpInstance().call(method, url, params:params, headers:headers)
    }
    
    @discardableResult
    public static func call(_ request:HttpRequest) async -> HttpResponse {
        await httpInstance().call(request)
    }
    
    
    // MARK: GET methods
    
    public static func get(_ url:String, queryParams:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .get, url: url, queryParams: queryParams, headers: headers))
    }
    
    
    // MARK: POST methods
    
    public static func post(_ url:String, queryParams:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .post, url: url, queryParams: queryParams, headers: headers))
    }
    
    public static func post(_ url:String, form:[String:Codable], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .post, url: url, form: form, headers: headers))
    }
    
    public static func post(_ url:String, body:String, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = .string(body)
        return await httpInstance().call(request)
    }
    
    public static func post<Z:Encodable>(_ url:String, json:Z, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: .post, url: url, headers: headers)
        request.body = .json(json)
        return await httpInstance().call(request)
    }
    
    
    // MARK: PUT methods
    
    public static func put(_ url:String, queryParams:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .put, url: url, queryParams: queryParams, headers: headers))
    }
    
    public static func put(_ url:String, form:[String:Codable], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .put, url: url, form: form, headers: headers))
    }
    
    public static func put<Z:Encodable>(_ url:String, json:Z, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: .put, url: url, headers: headers)
        request.body = .json(json)
        return await httpInstance().call(request)
    }
    
    
    // MARK: PATCH methods
    
    public static func patch(_ url:String, queryParams:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .patch, url: url, queryParams: queryParams, headers: headers))
    }
    
    public static func patch(_ url:String, form:[String:Codable], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .patch, url: url, form: form, headers: headers))
    }
    
    public static func patch<Z:Encodable>(_ url:String, json:Z, headers:[String:String] = [:]) async -> HttpResponse {
        let request = HttpRequest(method: .patch, url: url, headers: headers)
        request.body = .json(json)
        return await httpInstance().call(request)
    }
    
    
    // MARK: DELETE methods
    
    public static func delete(_ url:String, queryParams:[String:Codable] = [:], headers:[String:String] = [:]) async -> HttpResponse {
        await httpInstance().call(HttpRequest(method: .delete, url: url, queryParams: queryParams, headers: headers))
    }
    
    
    // MARK: With Options
    
    public static func withOptions(_ options: HttpOption...) async -> Http {
        let instance = await httpInstance()
        return instance.withOptions(options) // options is already an array when variadic
    }
}
