import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpOptionsTests {
    
    @Test("Can add an HMAC header")
    func testCanAddAnHmacHeader() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.withOptions(.hmacSHA256(header: "X-Header-Sha", privateKey: "PRVIATE_KEY")).get("https://httpbin.org/get", params: ["name": "Jordi"], headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
        #expect(json.headers["X-Header"] == "header-value")
        #expect(json.headers["X-Header-Sha"] == "7f2d061df8af79d74afb651641bd1b15a38ae8d22aed75120c4c020ab844da18")
        #expect(json.url == "https://httpbin.org/get?name=Jordi")
    }
    
    @Test("Can set timeout on Http instance")
    func testCanSetTimeoutOnHttpInstance() async throws {
        let fake = HttpFake()
        await fake.enable()
        let _ = await Http.withOptions(.timeout(seconds: 10)).get("https://httpbin.org/get", params: [:])
        
        let request = try #require(await fake.calls.first)
        #expect(request.timeout == 10.0)
    }
    
    @Test("Can combine multiple options")
    func testCanCombineMultipleOptions() async throws {
        let fake = HttpFake()
        await fake.enable()
        
        let _ = await Http.withOptions(
            .timeout(seconds: 10),
            .hmacSHA256(header: "X-Auth", privateKey: "key")
        ).get("https://httpbin.org/get", params: ["test": "value"])
        
        let request = try #require(await fake.calls.first)
        #expect(request.timeout == 10.0)
        // Verify HMAC header was added by setOptions
        #expect(request.headers["X-Auth"] != nil)
    }
}

