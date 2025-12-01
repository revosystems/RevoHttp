import Foundation
import Testing
@testable import RevoHttp

@Suite()
struct HttpEdgeCasesTests {
    
    @Test("Can handle empty headers")
    func testCanHandleEmptyHeaders() async throws {
        struct HttpBinResponse: Codable {
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.get("https://httpbin.org/get", params: [:], headers: [:])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.url == "https://httpbin.org/get")
    }
    
    @Test("Can handle multiple headers")
    func testCanHandleMultipleHeaders() async throws {
        struct HttpBinResponse: Codable {
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.get("https://httpbin.org/get", headers: [
            "X-Header1": "Value1",
            "X-Header2": "Value2",
            "X-Header3": "Value3"
        ])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.headers["X-Header1"] == "Value1")
        #expect(json.headers["X-Header2"] == "Value2")
        #expect(json.headers["X-Header3"] == "Value3")
    }
}

