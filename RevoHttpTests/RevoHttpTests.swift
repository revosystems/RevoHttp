import XCTest

@testable import RevoHttp

class RevoHttpTests: XCTestCase {

    override func setUp() {
     
    }

    override func tearDown() {
     
    }

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

}
