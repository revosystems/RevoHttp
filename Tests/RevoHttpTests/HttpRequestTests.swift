import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpRequestTests {
    
    @Test("Can convert request to curl")
    func testCanConvertRequestToCurl() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: ["name": "Jordi", "lastName": "Puigdellívol"], headers: ["X-Header": "Value1", "X-Header2": "Value2"])
        
        let result = request.toCurl()
        #expect(result == "curl -d \"lastName=Puigdellívol&name=Jordi\" -H \"X-Header: Value1\" -H \"X-Header2: Value2\" -X GET https://httpbin.org/get")
    }
    
    @Test("Can convert POST request to curl")
    func testCanConvertPostRequestToCurl() {
        let request = HttpRequest(method: .post, url: "https://httpbin.org/post", params: ["name": "Jordi"], headers: ["Content-Type": "application/json"])
        
        let result = request.toCurl()
        #expect(result == "curl -d \"name=Jordi\" -H \"Content-Type: application/json\" -X POST https://httpbin.org/post")
    }
    
    @Test("Can generate URLRequest from HttpRequest")
    func testCanGenerateURLRequest() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: ["name": "Jordi"], headers: ["X-Header": "Value1"])
        
        let urlRequest = request.generate()
        #expect(urlRequest != nil)
        #expect(urlRequest?.httpMethod == "GET")
        #expect(urlRequest?.url?.absoluteString.contains("name=Jordi") == true)
    }
    
    @Test("Can generate URLRequest with timeout")
    func testCanGenerateURLRequestWithTimeout() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get")
        request.timeout = 30.0
        
        let urlRequest = request.generate()
        #expect(urlRequest?.timeoutInterval == 30.0)
    }
    
    @Test("Can generate POST request with body")
    func testCanGeneratePostRequestWithBody() {
        let request = HttpRequest(method: .post, url: "https://httpbin.org/post")
        request.body = "name=Jordi&age=30"
        
        let urlRequest = request.generate()
        #expect(urlRequest?.httpMethod == "POST")
        #expect(urlRequest?.httpBody != nil)
        let bodyString = String(data: urlRequest!.httpBody!, encoding: .utf8)
        #expect(bodyString == "name=Jordi&age=30")
    }
    
    @Test("Can handle nested parameters")
    func testCanHandleNestedParameters() {
        let nestedParams = [
            "user": [
                "name": "Jordi",
                "age": 30
            ]
        ]
        
        let request = HttpRequest(method: .post, url: "https://httpbin.org/post", params: nestedParams)
        let body = request.buildBody()
        
        #expect(body.contains("user[name]"))
        #expect(body.contains("user[age]"))
    }
    
    @Test("Can handle empty parameters")
    func testCanHandleEmptyParameters() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: [:])
        let body = request.buildBody()
        
        #expect(body.isEmpty)
    }
    
    @Test("Can handle special characters in parameters")
    func testCanHandleSpecialCharactersInParameters() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: ["name": "Jordi & Co", "email": "test@example.com"])
        let url = request.buildUrl()
        
        #expect(url.contains("name="))
        #expect(url.contains("email="))
    }
    
    @Test("Can handle NSNull in parameters")
    func testCanHandleNSNullInParameters() {
        let request = HttpRequest(method: .post, url: "https://httpbin.org/post", params: ["nullValue": NSNull()])
        let body = request.buildBody()
        
        // NSNull should be converted to empty string
        #expect(body.contains("nullValue="))
    }
    
    @Test("Can handle URL encoding in parameters")
    func testCanHandleUrlEncodingInParameters() {
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: ["name": "Jordi Puigdellívol"])
        let url = request.buildUrl()
        
        // URL should be properly encoded
        #expect(url.contains("name="))
    }
    
    @Test("Can handle request with body overriding params")
    func testCanHandleRequestWithBodyOverridingParams() {
        let request = HttpRequest(method: .post, url: "https://httpbin.org/post", params: ["param1": "value1"])
        request.body = "body=value"
        
        let urlRequest = request.generate()
        let bodyString = String(data: urlRequest!.httpBody!, encoding: .utf8)
        #expect(bodyString == "body=value")
    }
}

