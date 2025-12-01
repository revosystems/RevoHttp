import Foundation

actor HttpFakeState {
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
        guard let first = globalResponses.first else { return nil }
        if globalResponses.count > 1 {
            globalResponses.removeFirst()
        }
        return first
    }
    
    func addResponse(_ response: HttpResponse, for url: String?) {
        if let url {
            responses[url] = response
        } else {
            globalResponses.append(response)
        }
    }
}

public class HttpFake : Http, @unchecked Sendable {
        
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
    
    private let state = HttpFakeState()
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
        
        await ThreadSafeContainer.shared.unbind(Http.self)
        swizzled = false
    }
    
    public override func makeCall(_ request:HttpRequest) async -> HttpResponse {
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
        let data = try! JSONEncoder().encode(response)
        let httpResponse    = HTTPURLResponse(url: URL(string:"http://fakeUrl.com")!, statusCode: status, httpVersion: "1.0", headerFields: nil)
        let httpResponseObj = HttpResponse(data:data, response:httpResponse , error: nil)
        await state.addResponse(httpResponseObj, for: url)
    }
}
