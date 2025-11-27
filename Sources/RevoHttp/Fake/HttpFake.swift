import Foundation
import RevoFoundation

public class HttpFake : NSObject {
    
    public static var calls:[HttpRequest]       = []
    static var responses:[String:HttpResponse]  = [:]
    static var globalResponses:[HttpResponse]   = []
    
    static var swizzled = false
    
    public static func enable(){
        Self.responses = [:]
        Self.globalResponses = []
        Self.calls = []
        if (swizzled) { return }
        
                
        guard let originalMethod = class_getInstanceMethod(Http.self,     #selector(call(_:then:))),
            let newMethod        = class_getInstanceMethod(HttpFake.self, #selector(call(_:then:))) else {
                return
        }
        
        method_exchangeImplementations(originalMethod, newMethod)
        swizzled = true
    }
    
    public static func disable(){
        if (!swizzled) { return }
        swizzled = false
        Self.enable()
        swizzled = false
    }
    
    @objc dynamic public func call(_ request:HttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        Self.calls.append(request)
        
        if let toRespond = Self.responses[request.url] {
            return then(toRespond)
        }
        
        if (Self.globalResponses.count == 1) {
            return then(Self.globalResponses.first!)
        }
        
        if let toRespond = Self.globalResponses.pop() {
            return then(toRespond)
        }
        
        then(HttpResponse(data: nil, response: nil, error: nil))
    }
    
    public static func addResponse(_ response:String, status:Int = 200) {
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let globalResponse  = HttpResponse(data:response.data(using: .utf8), response:httpResponse , error: nil)
        Self.globalResponses.append(globalResponse)
    }
        
    public static func addResponse<T:Codable>(encoded response:T, status:Int = 200) {
        let data = try! response.encode()
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let globalResponse  = HttpResponse(data:data, response:httpResponse , error: nil)
        Self.globalResponses.append(globalResponse)
    }
    
    public static func addResponse(for url:String, _ response:String, status:Int = 200) {
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let concreteResponse  = HttpResponse(data:response.data(using: .utf8), response:httpResponse , error: nil)
        Self.responses[url]   = concreteResponse
    }
    
    public static func addResponse<T:Codable>(for url:String, encoded response:T, status:Int = 200) {
        let data = try! response.encode()
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let concreteResponse  = HttpResponse(data:data, response:httpResponse , error: nil)
        Self.responses[url]   = concreteResponse
    }
}


actor HttpFake2State {
    var calls: [HttpRequest] = []
    var responses: [String: HttpResponse] = [:]
    var globalResponses: [HttpResponse] = []
    
    func reset() {
        calls = []
        responses = [:]
        globalResponses = []
    }
    
    func addCall(_ request: HttpRequest) {
        calls.append(request)
    }
    
    func getResponse(for url: String) -> HttpResponse? {
        responses[url]
    }
    
    func getGlobalResponse() -> HttpResponse? {
        if globalResponses.count == 1 {
            return globalResponses.first
        }
        return globalResponses.pop()
    }
    
    func addResponse(_ response: HttpResponse, for url: String?) {
        if let url {
            responses[url] = response
        } else {
            globalResponses.append(response)
        }
    }
}

public class HttpFakeAsync : Http, @unchecked Sendable {
        
    public var calls: [HttpRequest] {
        get async {
            await state.calls
        }
    }
    
    public var globalResponses: [HttpResponse] {
        get async {
            await state.globalResponses
        }
    }
    
    public var responses: [String: HttpResponse] {
        get async {
            await state.responses
        }
    }
    
    private let state = HttpFake2State()
    var swizzled = false
    
    public func enable() async {
        await state.reset()
        guard !swizzled else { return }
        
        await ThreadSafeContainer.shared.bind(instance: Http.self, self)
        swizzled = true
    }
    
    public func disable() async {
        guard swizzled else { return }
        await state.reset()
        
        // Unbind from ThreadSafeContainer to allow other tests to bind their own instances
        await ThreadSafeContainer.shared.unbind(Http.self)
        swizzled = false
    }
    
    @discardableResult
    public override func call(_ request:HttpRequest) async -> HttpResponse {
        await state.addCall(request)
                
        if let urlResponse = await state.getResponse(for: request.url) {
            return urlResponse
        }
        if let globalResponse = await state.getGlobalResponse() {
            return globalResponse
        }
        return HttpResponse(data: nil, response: nil, error: nil)
    }
    
    public func addResponse(for url:String? = nil, _ response:String, status:Int = 200) async {
        let httpResponse = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let httpResponseObj = HttpResponse(data:response.data(using: .utf8), response:httpResponse , error: nil)
        await state.addResponse(httpResponseObj, for: url)
    }
        
    public func addResponse<T:Codable>(for url:String? = nil, encoded response:T, status:Int = 200) async {
        let data = try! response.encode()
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let httpResponseObj = HttpResponse(data:data, response:httpResponse , error: nil)
        await state.addResponse(httpResponseObj, for: url)
    }
}
