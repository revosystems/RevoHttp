import Foundation


public class HttpFake : NSObject {
    
    static var calls:[HttpRequest]              = []
    static var responses:[String:HttpResponse]  = [:]
    static var globalResponses:[HttpResponse]   = []
    
    static var swizzled = false
    
    static func enable(){
        Self.calls = []
        if (swizzled) { return }
        
                
        guard let originalMethod = class_getClassMethod(Http.self,     #selector(call(_:then:))),
            let newMethod        = class_getClassMethod(HttpFake.self, #selector(call(_:then:))) else {
                return
        }
        
        method_exchangeImplementations(originalMethod, newMethod)
        swizzled = true
    }
    
    static func disable(){
        if (!swizzled) { return }
        swizzled = false
        Self.enable()
        swizzled = false
    }
    
    @objc dynamic public class func call(_ request:HttpRequest, then:@escaping(_ response:HttpResponse)->Void) {
        calls.append(request)
        
        if let toRespond = responses[request.url] {
            return then(toRespond)
        }
        
        if (globalResponses.count == 1) {
            return then(globalResponses.first!)
        }
        
        if let toRespond = globalResponses.pop() {
            return then(toRespond)
        }
        
        then(HttpResponse(data: nil, response: nil, error: nil))
    }
    
    public static func addResponse(_ response:String, status:Int = 200) {
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let globalResponse  = HttpResponse(data:response.data(using: .utf8), response:httpResponse , error: nil)
        Self.globalResponses.append(globalResponse)
    }
    
    public static func addEncodedResponse<T:Codable>(_ response:T, status:Int = 200) {
        let data = try! response.encode()
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let globalResponse  = HttpResponse(data:data, response:httpResponse , error: nil)
        Self.globalResponses.append(globalResponse)
    }
}
