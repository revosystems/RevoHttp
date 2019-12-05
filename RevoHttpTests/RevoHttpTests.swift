import XCTest

@testable import RevoHttp

class RevoHttpTests: XCTestCase {

    override func setUp()    {}
    override func tearDown() {}

    func test_can_get() {
        
        let expectation = XCTestExpectation(description: "Http request")
        
        struct HttpBinResponse: Codable {
            let args:[String:String]
            let headers:[String:String]
            let url:String
        }
        
        Http.get("https://httpbin.org/get", params:["name" : "Jordi"], headers:["X-Header": "header-value"]) { response in
            
            print(response.toString)
            let json:HttpBinResponse = response.decoded()!
            XCTAssertEqual("Jordi",                                 json.args["name"])
            XCTAssertEqual("header-value",                          json.headers["X-Header"])
            XCTAssertEqual("https://httpbin.org/get?name=Jordi",    json.url)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_can_post(){
        
        let expectation = XCTestExpectation(description: "Http request")
        
        struct HttpBinResponse: Codable {
            let form:[String:String]
            let headers:[String:String]
            let url:String
        }
        
        Http.post("https://httpbin.org/post", params:["name" : "Jordi"], headers:["X-Header": "header-value"]) { response in
            
            print(response.toString)
            let json:HttpBinResponse = response.decoded()!
            XCTAssertEqual("Jordi",                                 json.form["name"])
            XCTAssertEqual("header-value",                          json.headers["X-Header"])
            XCTAssertEqual("https://httpbin.org/post",              json.url)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
        
    }
    
    func test_can_post_with_body(){
        
        let expectation = XCTestExpectation(description: "Http request")
        
        struct HttpBinResponse: Codable {
            let form:[String:String]
            let headers:[String:String]
            let url:String
        }
        
        Http.post("https://httpbin.org/post", body:"name=Jordi", headers:["X-Header": "header-value"]) { response in
            
            print(response.toString)
            let json:HttpBinResponse = response.decoded()!
            XCTAssertEqual("Jordi",                                 json.form["name"])
            XCTAssertEqual("header-value",                          json.headers["X-Header"])
            XCTAssertEqual("https://httpbin.org/post",              json.url)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
        
    }
    
    func test_can_convert_request_to_curl() {
        
        let request = HttpRequest(method: .get, url: "https://httpbin.org/get", params: ["name" : "Jordi", "lastName" : "Puigdellívol"], headers: ["X-Header" : "Value1", "X-Header2": "Value2"])
        
        let result = request.toCurl()
        XCTAssertEqual("curl -d lastName=Puigdellívol&name=Jordi -H X-Header: Value1 -H X-Header2: Value2 -X get https://httpbin.org/get", result)
    }

}
