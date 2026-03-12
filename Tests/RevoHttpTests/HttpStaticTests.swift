import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpStaticTests {
    
    @Test("Can use static call method")
    func testCanUseStaticCallMethod() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let url: String
        }
        
        let response = await Http.call(.get, url: "https://httpbin.org/get", params: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
    }
    
    @Test("Can use static call with request object")
    func testCanUseStaticCallWithRequestObject() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let url: String
        }
        
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", queryParams: ["name": "Jordi"])
        let response = await Http.call(request)
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
    }
    
    @Test("Can use static PUT method")
    func testCanUseStaticPutMethod() async throws {
        struct HttpBinResponse: Codable {
            let data: String
            let url: String
        }
        
        let response = await Http.put("https://httpbin.org/put", form: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.data == "name=Jordi")
    }
    
    @Test("Can use static PATCH method")
    func testCanUseStaticPatchMethod() async throws {
        struct HttpBinResponse: Codable {
            let data: String
            let url: String
        }
        
        let response = await Http.patch("https://httpbin.org/patch", form: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.data == "name=Jordi")
    }
    
    @Test("Can use static DELETE method")
    func testCanUseStaticDeleteMethod() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let url: String
        }
        
        let response = await Http.delete("https://httpbin.org/delete", queryParams: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
    }

    @Test("Static call throwing overload returns decoded value on success")
    func testStaticCallThrowsReturnsDecodedOnSuccess() async throws {
        struct Response: Codable {
            let ok: Bool
        }
        try await withHttpFake() { fake in
            await fake.addResponse(encoded: Response(ok: true), status: 200)
            let result: Response = try await Http.call(.get, "https://example.com", params: [:], headers: [:])
            #expect(result.ok == true)
        }
    }
}

