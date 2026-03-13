import Foundation


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
