import Foundation
import Testing
@testable import RevoHttp

@Suite()
struct HttpMethodsTests {
    
    @Test("Can perform GET request")
    func testCanGet() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.get("https://httpbin.org/get", params: ["name": "Jordi"], headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
        #expect(json.headers["X-Header"] == "header-value")
        #expect(json.url == "https://httpbin.org/get?name=Jordi")
    }
    
    @Test("Can perform POST request")
    func testCanPost() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.post("https://httpbin.org/post", params: ["name": "Jordi"], headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.form["name"] == "Jordi")
        #expect(json.headers["X-Header"] == "header-value")
        #expect(json.url == "https://httpbin.org/post")
    }
    
    @Test("Can perform PUT request")
    func testCanPut() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let url: String
        }
        
        let response = await Http.put("https://httpbin.org/put", params: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.form["name"] == "Jordi")
        #expect(json.url == "https://httpbin.org/put")
    }
    
    @Test("Can perform PATCH request")
    func testCanPatch() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let url: String
        }
        
        let response = await Http.patch("https://httpbin.org/patch", params: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.form["name"] == "Jordi")
        #expect(json.url == "https://httpbin.org/patch")
    }
    
    @Test("Can perform DELETE request")
    func testCanDelete() async throws {
        struct HttpBinResponse: Codable {
            let args: [String: String]
            let url: String
        }
        
        let response = await Http.delete("https://httpbin.org/delete", params: ["name": "Jordi"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.args["name"] == "Jordi")
        #expect(json.url == "https://httpbin.org/delete?name=Jordi")
    }
    
    @Test("Can POST with body string")
    func testCanPostWithBody() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.post("https://httpbin.org/post", body: "name=Jordi", headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.form["name"] == "Jordi")
        #expect(json.headers["X-Header"] == "header-value")
        #expect(json.url == "https://httpbin.org/post")
    }
    
    @Test("Can POST with JSON body")
    func testCanPostWithJson() async throws {
        struct RequestBody: Codable {
            let name: String
            let age: Int
        }
        
        struct HttpBinResponse: Codable {
            let json: RequestBody
            let url: String
        }
        
        let requestBody = RequestBody(name: "Jordi", age: 30)
        let response = await Http().call(.post, "https://httpbin.org/post", json: requestBody)
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.json.name == "Jordi")
        #expect(json.json.age == 30)
    }
    
    @Test("Can send numbers as parameters")
    func testCanSendNumbersAsParameters() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let headers: [String: String]
            let url: String
        }
        
        let response = await Http.post("https://httpbin.org/post", params: ["name": 12, "age": 30], headers: ["X-Header": "header-value"])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(json.form["name"] == "12")
        #expect(json.form["age"] == "30")
        #expect(json.headers["X-Header"] == "header-value")
    }
    
    @Test("Can send boolean as parameters")
    func testCanSendBooleanAsParameters() async throws {
        struct HttpBinResponse: Codable {
            let form: [String: String]
            let url: String
        }
        
        let response = await Http.post("https://httpbin.org/post", params: ["active": true, "inactive": false])
        
        let json: HttpBinResponse = try #require(response.decoded())
        #expect(["true", "1"].contains(json.form["active"]))
        #expect(["false", "0"].contains(json.form["inactive"]))
    }
}

