
public extension Http {
    
    static func call(_ method:HttpRequest.Method, _ url:String, body:String? = nil, headers:[String:String] = [:]) async -> HttpResponse {
        await withCheckedContinuation { continuation in
            if let body {
                return Self.call(method, url, body:body, headers: headers) { response in
                    continuation.resume(returning: response)
                }
            }
            Self.call(method, url:url, headers: headers) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    static func post(_ url:String, headers:[String:String] = [:]) async -> HttpResponse{
        await withCheckedContinuation { continuation in
            Self.post(url, headers: headers) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    static func post(_ url:String, body:String, headers:[String:String] = [:]) async -> HttpResponse{
        await withCheckedContinuation { continuation in
            Self.post(url, body: body, headers: headers) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    //TODO: add rest of methods if necessary
}
