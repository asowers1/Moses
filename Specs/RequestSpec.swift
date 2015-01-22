import Quick
import Nimble

import Moses

class RequestSpec : QuickSpec {
    override func spec() {

        describe("success") {
            it("calls the success closure") {
                let expectedCredential = OAuthCredential(accessToken: "", refreshToken: "", tokenType: "", expiration: NSDate())
                let expectation = self.expectationWithDescription("")

                var actualCredential: OAuthCredential? = nil
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    succeed(expectedCredential)
                }.success { (c) in
                    actualCredential = c
                    expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0.1) { (_) in
                    expect(actualCredential).to(equal(expectedCredential))
                }
            }

            it("does not call the failure") {
                var called = false

                let expectation = self.expectationWithDescription("Success closure was called")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    succeed(OAuthCredential(accessToken: "", refreshToken: "", tokenType: "", expiration: NSDate()))
                    }.failure { (error) in
                        called = true
                        expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0.1) { (_) in
                    if (called) { fail("Failure closure was called") }
                }
            }

            it("cannot succeed twice") {
                let expectation = self.expectationWithDescription("")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    succeed(OAuthCredential(accessToken: "", refreshToken: "", tokenType: "", expiration: NSDate()))

                    expect({
                        succeed(OAuthCredential(accessToken: "", refreshToken: "", tokenType: "", expiration: NSDate()))
                    }).to(raiseException(named: NSInternalInconsistencyException))
                }

                self.waitForExpectationsWithTimeout(0) {(_) in}
            }

            it("calls the success closure on the main thread") {
                let expectation = self.expectationWithDescription("")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    succeed(OAuthCredential(accessToken: "", refreshToken: "", tokenType: "", expiration: NSDate()))
                }
                request.success { (_) in
                    expect(NSThread.isMainThread()).to(beTrue())
                    expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0.1) {(_) in}
            }
        }

        describe("failure") {
            it("calls the failure closre") {
                var error: NSError? = nil
                let expectation = self.expectationWithDescription("Failure closure was called")

                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    fail(NSError())
                }.failure { (e: NSError) in
                    error = e
                    expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0.1) { (_) in
                    if (error == nil) { fail("Failure closure should be called with the error") }
                }
            }

            it("does not call the success closure") {
                var called = false

                let expectation = self.expectationWithDescription("Success closure was called")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    fail(NSError())
                }.success { (credential) in
                    called = true
                    expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0) { (_) in
                    if (called) { fail("Success closure was called") }
                }
            }

            it("cannot fail twice") {
                let expectation = self.expectationWithDescription("")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    fail(NSError())

                    expect({
                        fail(NSError())
                    }).to(raiseException(named: NSInternalInconsistencyException))
                }

                self.waitForExpectationsWithTimeout(0) { (error) in}
            }

            it("calls the failure closure on the main thread") {
                let expectation = self.expectationWithDescription("")
                let request = Request(url: "http://fake", parameters: [:]) { (succeed: (OAuthCredential) -> Void, fail: (NSError) -> Void) in
                    fail(NSError())
                }
                request.failure { (_) in
                    expect(NSThread.isMainThread()).to(beTrue())
                    expectation.fulfill()
                }

                self.waitForExpectationsWithTimeout(0.1) {(_) in}

            }
        }
    }
}