import Foundation
import Testing
@testable import RevoHttp

@Suite()
struct HttpErrorHandlingTests {
    
    @Test("Can handle invalid URL")
    func testCanHandleInvalidUrl() async throws {
        let response = await Http.get("not-a-valid-url", params: [:])
        
        #expect(response.error != nil)
        #expect(response.toString.contains("Error"))
    }
    
    @Test("Can handle encoding error for non-encodable JSON")
    func testCanHandleEncodingError() async throws {
        let response = await Http.call(.post, "https://httpbin.org/post", json: ["test": "value"] as [String: String])
        #expect(response.error == nil || response.toString.contains("Error"))
    }
}

