
public extension Http {
    
    static func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], body: String? = nil, headers: [String:String] = [:], timeout: Int = 30) async -> HttpResponse {
        await withCheckedContinuation { continuation in
            Self.call(method, url: url, queryParams: queryParams, body: body, headers: headers, timeout: timeout) { response in
                continuation.resume(returning: response)
            }
        }
    }

    static func call(_ method: HttpRequest.Method, url: String, queryParams: [String:Codable] = [:], form: [String:Codable] = [:], headers: [String:String] = [:], timeout: Int = 30) async -> HttpResponse {
        await withCheckedContinuation { continuation in
            Self.call(method, url: url, queryParams: queryParams, form: form, headers: headers, timeout: timeout) { response in
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
