import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpResponseTests {
    
    @Test("Can decode JSON response")
    func testCanDecodeJsonResponse() {
        let jsonData = """
        {"name": "Jordi", "age": 30}
        """.data(using: .utf8)!
        
        struct Response: Codable {
            let name: String
            let age: Int
        }
        
        let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let response = HttpResponse(data: jsonData, response: httpResponse)
        
        let decoded: Response? = response.decoded()
        #expect(decoded?.name == "Jordi")
        #expect(decoded?.age == 30)
    }
    
    @Test("Can get status code from response")
    func testCanGetStatusCodeFromResponse() {
        let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let response = HttpResponse(data: nil, response: httpResponse)
        
        #expect(response.statusCode == 404)
    }
    
    @Test("Can check if response is successful")
    func testCanCheckIfResponseIsSuccessful() {
        let httpResponse200 = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let response200 = HttpResponse(data: nil, response: httpResponse200)
        #expect(response200.isSuccessful == true)
        
        let httpResponse201 = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 201, httpVersion: nil, headerFields: nil)
        let response201 = HttpResponse(data: nil, response: httpResponse201)
        #expect(response201.isSuccessful == true)
        
        let httpResponse404 = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let response404 = HttpResponse(data: nil, response: httpResponse404)
        #expect(response404.isSuccessful == false)
    }
    
    @Test("Can get response as string")
    func testCanGetResponseAsString() {
        let data = "Hello World".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let response = HttpResponse(data: data, response: httpResponse)
        
        #expect(response.toString == "Hello World")
    }
    
    @Test("Can handle response with error")
    func testCanHandleResponseWithError() {
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let response = HttpResponse(data: nil, response: nil, error: error)
        
        #expect(response.error != nil)
        #expect(response.toString.contains("RevoHttp Error"))
    }
    
    @Test("Can handle response with no data")
    func testCanHandleResponseWithNoData() {
        let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 204, httpVersion: nil, headerFields: nil)
        let response = HttpResponse(data: nil, response: httpResponse)
        
        #expect(response.toString.contains("No Data"))
    }
    
    @Test("Can handle invalid URL error")
    func testCanHandleInvalidUrlError() {
        let response = HttpResponse(failed: "Invalid URL")
        
        #expect(response.error != nil)
        #expect(response.data == nil)
    }
    
    @Test("Can handle decoding error")
    func testCanHandleDecodingError() {
        let invalidJson = "not json".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let response = HttpResponse(data: invalidJson, response: httpResponse)
        
        struct ExpectedType: Codable {
            let name: String
        }
        
        let decoded: ExpectedType? = response.decoded()
        #expect(decoded == nil)
    }
}

