import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpCallOverloadsTests {

    @Test("call returning (T?, String?) returns decoded value and nil error on success")
    func testCallTupleReturnsDecodedOnSuccess() async throws {
        struct Response: Codable {
            let id: Int
            let name: String
        }
        struct Body: Encodable {
            let q: String = "x"
        }
        try await withHttpFake() { fake in
            await fake.addResponse(encoded: Response(id: 1, name: "Test"))
            let (result, errorMessage): (Response?, String?) = await Http.call(.post, "https://example.com", json: Body(), headers: [:])
            #expect(result != nil)
            #expect(result?.id == 1)
            #expect(result?.name == "Test")
            #expect(errorMessage == nil)
        }
    }

    @Test("call returning (T?, String?) returns nil result when response is not decodable")
    func testCallTupleReturnsNilWhenNotDecodable() async throws {
        struct Response: Codable {
            let id: Int
        }
        struct Body: Encodable {}
        try await withHttpFake() { fake in
            await fake.addResponse(for: "https://example.com", "not found", status: 404)
            let (result, _): (Response?, String?) = await Http.call(.post, "https://example.com", json: Body(), headers: [:])
            #expect(result == nil)
        }
    }

    @Test("call throws returns decoded value on success")
    func testCallThrowsReturnsDecodedOnSuccess() async throws {
        struct Response: Codable {
            let value: String
        }
        try await withHttpFake() { fake in
            await fake.addResponse(encoded: Response(value: "ok"), status: 200)
            let result: Response = try await Http.call(.get, "https://example.com", params: [:], headers: [:])
            #expect(result.value == "ok")
        }
    }

    @Test("call throws HttpError.responseError when response has error")
    func testCallThrowsResponseError() async throws {
        // Invalid URL causes request.generate() to return nil, so makeCall returns HttpResponse(failed:)
        let http = Http()
        do {
            let _: EmptyResponse = try await http.call(.get, "", params: [:], headers: [:])
            #expect(Bool(false), "Should throw")
        } catch HttpError.responseError {
            // expected when response.error != nil
        } catch {
            #expect(Bool(false), "Expected responseError, got \(error)")
        }
    }

    @Test("call throws HttpError.undecodableResponse when body is not decodable")
    func testCallThrowsUndecodableResponse() async throws {
        struct Response: Codable {
            let required: Int
        }
        try await withHttpFake() { fake in
            await fake.addResponse(for: "https://example.com", "plain text", status: 200)
            do {
                let _: Response = try await Http.call(.get, "https://example.com", params: [:], headers: [:])
                #expect(Bool(false), "Should throw")
            } catch HttpError.undecodableResponse {
                // expected
            } catch {
                #expect(Bool(false), "Expected undecodableResponse, got \(error)")
            }
        }
    }

    @Test("call throws HttpError.reponseStatusError when status is not 2xx")
    func testCallThrowsStatusError() async throws {
        struct Response: Codable {
            let id: Int
        }
        try await withHttpFake() { fake in
            await fake.addResponse(for: "https://example.com", encoded: Response(id: 1), status: 404)
            do {
                let _: Response = try await Http.call(.get, "https://example.com", params: [:], headers: [:])
                #expect(Bool(false), "Should throw")
            } catch HttpError.reponseStatusError(let response) {
                #expect(response.statusCode == 404)
            } catch {
                #expect(Bool(false), "Expected reponseStatusError, got \(error)")
            }
        }
    }
}

private struct EmptyResponse: Codable {}
