import Foundation
import Testing
@testable import RevoHttp
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Suite(.serialized)
struct MultipartHttpRequestTests {

    @Test("addMultipart sets properties and returns self for chaining")
    func testAddMultipartReturnsSelf() {
        let request = MultipartHttpRequest(method: .post, url: "https://example.com/upload")
        #if canImport(UIKit)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        #elseif canImport(AppKit)
        let image = NSImage(size: NSSize(width: 1, height: 1))
        image.lockFocus()
        NSColor.red.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: NSSize(width: 1, height: 1))).fill()
        image.unlockFocus()
        #endif
        let result = request.addMultipart(paramName: "file", fileName: "test.png", image: image)
        #expect(result === request)
    }

    @Test("generate returns POST with multipart Content-Type")
    func testGenerateReturnsPostWithMultipartContentType() {
        let request = MultipartHttpRequest(method: .get, url: "https://example.com/upload")
        let urlRequest = request.generate()
        #expect(urlRequest != nil)
        #expect(urlRequest?.httpMethod == "POST")
        let contentType = urlRequest?.value(forHTTPHeaderField: "Content-Type")
        #expect(contentType?.hasPrefix("multipart/form-data") == true)
        #expect(contentType?.contains("boundary=") == true)
    }

    @Test("generate returns nil for invalid URL")
    func testGenerateReturnsNilForInvalidURL() {
        let request = MultipartHttpRequest(method: .post, url: "")
        let urlRequest = request.generate()
        #expect(urlRequest == nil)
    }

    @Test("generateData returns empty when addMultipart not called")
    func testGenerateDataReturnsEmptyWhenNoMultipart() {
        let request = MultipartHttpRequest(method: .post, url: "https://example.com/upload")
        let data = request.generateData()
        #expect(data.isEmpty)
    }

    @Test("generateData returns non-empty body when addMultipart was called")
    func testGenerateDataReturnsBodyWhenMultipartSet() {
        #if canImport(UIKit)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        #elseif canImport(AppKit)
        let image = NSImage(size: NSSize(width: 1, height: 1))
        image.lockFocus()
        NSColor.red.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: NSSize(width: 1, height: 1))).fill()
        image.unlockFocus()
        #endif
        let request = MultipartHttpRequest(method: .post, url: "https://example.com/upload")
        _ = request.addMultipart(paramName: "photo", fileName: "image.png", image: image)
        let data = request.generateData()
        #expect(!data.isEmpty)
        // Data includes binary image bytes so check raw bytes for expected multipart headers
        let disposition = "Content-Disposition: form-data".data(using: .utf8)!
        let nameParam = "name=\"photo\"".data(using: .utf8)!
        let filenameParam = "filename=\"image.png\"".data(using: .utf8)!
        #expect(data.range(of: disposition) != nil)
        #expect(data.range(of: nameParam) != nil)
        #expect(data.range(of: filenameParam) != nil)
    }

    @Test("callMultipart returns failed response for invalid URL")
    func testCallMultipartReturnsFailedForInvalidURL() async {
        let request = MultipartHttpRequest(method: .post, url: "")
        let response = await Http().callMultipart(request)
        #expect(response.error != nil)
        #expect(response.data == nil)
    }
}
