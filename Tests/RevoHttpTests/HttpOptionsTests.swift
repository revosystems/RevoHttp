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
        
        let response = await Http.withOptions(.hmacSHA256(header: "X-Header-Sha", privateKey: "PRVIATE_KEY")).get("https://httpbin.org/get", queryParams: ["name": "Jordi"], headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
        #expect(json.headers["X-Header"] == "header-value")
        #expect(json.headers["X-Header-Sha"] == "7f2d061df8af79d74afb651641bd1b15a38ae8d22aed75120c4c020ab844da18")
        #expect(json.url == "https://httpbin.org/get?name=Jordi")
    }
    
    @Test("Can set timeout on Http instance")
    func testCanSetTimeoutOnHttpInstance() async throws {
        try await withHttpFake() { fake in
            let _ = await Http.withOptions(.timeout(seconds: 10)).get("https://httpbin.org/get", queryParams: [:])
            let request = try #require(await fake.calls.first)
            #expect(request.timeout == 10.0)
        }
    }
    
    @Test("Can allow unsecure urls")
    func testCanAllowUnsecureUrls() async throws {
        try await withHttpFake() { fake in
            let _ = await Http.withOptions(.allowUnsecureUrls).get("https://httpbin.org/get", queryParams: [:])
            let insecureUrlSession = try #require(fake.insecureUrlSession)
            #expect(fake.urlSession == insecureUrlSession.session)
        }
    }
    
    @Test("Can use custom session")
    func testCanUseCustomSession() async throws {
        try await withHttpFake() { fake in
            let customSession = URLSession(configuration: .ephemeral)
            let _ = await Http.withOptions(.session(customSession)).get("https://httpbin.org/get", queryParams: [:])
            #expect(fake.urlSession == customSession)
        }
    }
    
    @Test("Can combine multiple options")
    func testCanCombineMultipleOptions() async throws {
        try await withHttpFake() { fake in
            let _ = await Http.withOptions(
                .timeout(seconds: 10),
                .hmacSHA256(header: "X-Auth", privateKey: "key")
            ).get("https://httpbin.org/get", queryParams: ["test": "value"])
            let request = try #require(await fake.calls.first)
            #expect(request.timeout == 10.0)
            #expect(request.headers["X-Auth"] != nil)
        }
    }
}

