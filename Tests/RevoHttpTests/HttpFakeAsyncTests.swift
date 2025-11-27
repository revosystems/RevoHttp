import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized) // HttpFakeAsync instances are not isolated !!
struct HttpFakeAsyncTests {
    
    @Test("HttpFakeAsync can be enabled and disabled safely")
    func testEnableDisable() async throws {
        let fake = HttpFakeAsync()
        
        await fake.enable()
        await fake.disable()
        await fake.disable()
        await fake.enable()
        await fake.enable()
        await fake.disable()
    }
    
    @Test("HttpFakeAsync resets state when enabled")
    func testResetOnEnable() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        // Add some responses and make calls
        await fake.addResponse("test1")
        await fake.addResponse("test2")
        await fake.addResponse(for: "https://example.com", "test3")
        
        #expect(await fake.calls.count == 0)
        #expect(await fake.globalResponses.count == 2)
        #expect(await fake.responses.count == 1)
        
        await Http.call(HttpRequest(method: .get, url: "https://example.com"))
        await Http.call(HttpRequest(method: .get, url: "https://hello.com"))
        
        #expect(await fake.calls.count == 2)
        #expect(await fake.globalResponses.count == 1)
        #expect(await fake.responses.count == 1)
        
        await fake.enable()
        #expect(await fake.calls.count == 0)
        #expect(await fake.globalResponses.count == 0)
        #expect(await fake.responses.count == 0)
    }
    
    @Test("HttpFakeAsync resets state when disabled")
    func testResetOnDisable() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        // Add some responses and make calls
        await fake.addResponse("test1")
        await fake.addResponse("test2")
        await fake.addResponse(for: "https://example.com", "test3")
        
        #expect(await fake.calls.count == 0)
        #expect(await fake.globalResponses.count == 2)
        #expect(await fake.responses.count == 1)
        
        await Http.call(HttpRequest(method: .get, url: "https://example.com"))
        await Http.call(HttpRequest(method: .get, url: "https://hello.com"))
        
        #expect(await fake.calls.count == 2)
        #expect(await fake.globalResponses.count == 1)
        #expect(await fake.responses.count == 1)
        
        await fake.disable()
        #expect(await fake.calls.count == 0)
        #expect(await fake.globalResponses.count == 0)
        #expect(await fake.responses.count == 0)
    }
    
    @Test("HttpFakeAsync tracks calls correctly")
    func testCallTracking() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        let request1 = HttpRequest(method: .get, url: "https://example.com/1")
        let request2 = HttpRequest(method: .post, url: "https://example.com/2")
        
        await Http.call(request1)
        await Http.call(request2)
        
        #expect(await fake.calls.count == 2)
        #expect(await fake.calls[0].url == "https://example.com/1")
        #expect(await fake.calls[1].url == "https://example.com/2")
    }
    
    @Test("HttpFakeAsync returns URL-specific response when available")
    func testUrlSpecificResponse() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        await fake.addResponse(for: "https://example.com/specific", "specific response")
        await fake.addResponse("global response")
        
        let specificRequest = HttpRequest(method: .get, url: "https://example.com/specific")
        let specificResponse: String? = await Http.call(specificRequest).toString
        
        #expect(specificResponse == "specific response")
    }
    
    @Test("HttpFakeAsync returns global response when no URL-specific response")
    func testGlobalResponse() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        await fake.addResponse("first global")
        await fake.addResponse("second global")
        
        let request = HttpRequest(method: .get, url: "https://example.com/unknown")
        
        let response1 = await Http.call(request).toString
        #expect(response1 == "first global")
        
        let response2 = await Http.call(request).toString
        #expect(response2 == "second global")
    }
    
    @Test("HttpFakeAsync reuses single global response")
    func testSingleGlobalResponseReuse() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        await fake.addResponse("single response")
        
        let request1 = HttpRequest(method: .get, url: "https://example.com/1")
        let request2 = HttpRequest(method: .get, url: "https://example.com/2")
        
        let response1 = await Http.call(request1).toString
        #expect(response1 == "single response")
        
        let response2 = await Http.call(request2).toString
        #expect(response2 == "single response")
    }
    
    @Test("HttpFakeAsync returns empty response when no responses configured")
    func testEmptyResponseWhenNoResponses() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        let request = HttpRequest(method: .get, url: "https://example.com")
        
        let response = await Http.call(request)
        
        #expect(response.data == nil)
        #expect(response.response == nil)
        #expect(response.error == nil)
    }
    
    @Test("HttpFakeAsync can add encoded responses")
    func testEncodedResponse() async throws {
        struct TestResponse: Codable {
            let name: String
            let value: Int
        }
        
        let fake = HttpFakeAsync()
        await fake.enable()
        
        let testData = TestResponse(name: "test", value: 42)
        await fake.addResponse(encoded: testData)
        
        let request = HttpRequest(method: .get, url: "https://example.com")
        let decodedResponse: TestResponse = try #require(await Http.call(request).decoded())
        
        #expect(decodedResponse.name == "test")
        #expect(decodedResponse.value == 42)
    }
    
    @Test("HttpFakeAsync can add URL-specific encoded responses")
    func testUrlSpecificEncodedResponse() async throws {
        struct TestResponse: Codable {
            let id: Int
        }
        
        let fake = HttpFakeAsync()
        await fake.enable()
        
        await fake.addResponse(for: "https://api.example.com/user/1", encoded: TestResponse(id: 1))
        await fake.addResponse(for: "https://api.example.com/user/2", encoded: TestResponse(id: 2))
        
        let request1 = HttpRequest(method: .get, url: "https://api.example.com/user/1")
        let request2 = HttpRequest(method: .get, url: "https://api.example.com/user/2")
        
        let response1: TestResponse = try #require(await Http.call(request1).decoded())
        let response2: TestResponse = try #require(await Http.call(request2).decoded())
        
        #expect(response1.id == 1)
        #expect(response2.id == 2)
    }
    
    @Test("HttpFakeAsync can handle custom status codes")
    func testCustomStatusCodes() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        await fake.addResponse(for: "https://example.com/404", "not found", status: 404)
        await fake.addResponse(for: "https://example.com/500", "server error", status: 500)
        
        let request1 = HttpRequest(method: .get, url: "https://example.com/404")
        let request2 = HttpRequest(method: .get, url: "https://example.com/500")
        
        let status1 = await Http.call(request1).statusCode
        let status2 = await Http.call(request2).statusCode
        
        #expect(status1 == 404)
        #expect(status2 == 500)
    }
    
    @Test("HttpFakeAsync can be safely used in parallel test scenarios")
    func testParallelUsage() async throws {
        let fake = HttpFakeAsync()
        await fake.enable()
        
        // Add enough responses for concurrent calls
        let concurrentCalls = 10000
        for i in 1...concurrentCalls {
            await fake.addResponse("response\(i)")
        }
        
        #expect(await fake.calls.count == 0)
        #expect(await fake.globalResponses.count == concurrentCalls)
        
        await withTaskGroup(of: Void.self) { group in
            for i in 1...concurrentCalls {
                group.addTask {
                    let request = HttpRequest(method: .get, url: "https://example.com/\(i)")
                    await Http.call(request)
                }
            }
        }
        
        // All calls should be tracked
        #expect(await fake.calls.count == concurrentCalls)
        #expect(await fake.globalResponses.count == 1)
    }
}

