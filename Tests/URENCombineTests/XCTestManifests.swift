import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PassthroughSubjectTests.allTests),
        testCase(CurrentValueSubjectTests.allTests),
    ]
}
#endif
