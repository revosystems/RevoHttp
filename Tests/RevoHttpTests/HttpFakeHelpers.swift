import Foundation
@testable import RevoHttp

/// Runs the given closure with `HttpFake` enabled in the shared container.
/// The fake is always disabled after the closure completes or throws, so you get
/// teardown when needed without a separate tearDown method.
///
/// Swift Testing has no async tearDown (deinit cannot be async). Use this helper
/// in any test that needs the fake so the container is restored afterward:
///
/// ```swift
/// @Test func myTest() async throws {
///     let fake = HttpFake()
///     try await withHttpFake(fake) {
///         await fake.addResponse("ok")
///         let r = await Http.call(.get, "https://example.com")
///         #expect(r.toString == "ok")
///     }
/// }
/// ```
func withHttpFake(_ body: (_ fake: HttpFake) async throws -> Void) async throws {
    let fake = HttpFake()
    await fake.enable()
    do {
        try await body(fake)
    } catch {
        await fake.disable()
        throw error
    }
    await fake.disable()
}
