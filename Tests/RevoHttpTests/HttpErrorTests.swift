import Foundation
import Testing
@testable import RevoHttp

@Suite(.serialized)
struct HttpErrorTests {

    @Test("HttpError.invalidUrl has expected localized description")
    func testInvalidUrlDescription() {
        let error = HttpError.invalidUrl
        #expect(error.localizedDescription == "Malformed Url")
    }

    @Test("HttpError.invalidParams has expected localized description")
    func testInvalidParamsDescription() {
        let error = HttpError.invalidParams
        #expect(error.localizedDescription == "Invalid input params")
    }

    @Test("HttpError.responseError has expected localized description")
    func testResponseErrorDescription() {
        let error = HttpError.responseError
        #expect(error.localizedDescription == "Response returned and error")
    }

    @Test("HttpError.reponseStatusError has expected localized description")
    func testReponseStatusErrorDescription() {
        let response = HttpResponse(data: nil, response: nil, error: nil)
        let error = HttpError.reponseStatusError(response: response)
        #expect(error.localizedDescription == "Response returned a non 200 status")
    }

    @Test("HttpError.undecodableResponse has expected localized description")
    func testUndecodableResponseDescription() {
        let error = HttpError.undecodableResponse
        #expect(error.localizedDescription == "Undecodable response")
    }
}
