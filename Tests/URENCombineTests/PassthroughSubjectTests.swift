//
//  PassthroughSubjectTests.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 11/22/20.
//  Copyright © 2020 Uren Mobile. All rights reserved.

import XCTest
import URENCombine

final class PassthroughSubjectTests: XCTestCase {
    // MARK: - Subject Under Test
    private typealias Sut = PassthroughSubject<Int, TestError>
    private var sut: Sut!
    
    // MARK: — Test Lifecycle
    override func setUp() {
        super.setUp()
        sut = Sut()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs.count, .zero)
        XCTAssertEqual(subscriber.receivedCompletions.count, .zero)
    }
    
    func test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsAndZeroCompletionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        sut.send(1)
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs, [1, 1, 1, 1, 1])
        XCTAssertEqual(subscriber.receivedCompletions.count, .zero)
    }
    
    func test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsAndZeroCompletionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        sut.send(1)
        
        subscriber.receivedSubscriptions.last?.cancel()
        
        sut.send(2)
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs, [1, 1, 1, 1, 1, 2, 2, 2, 2])
        XCTAssertEqual(subscriber.receivedCompletions.count, .zero)
    }
    
    func test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        sut.send(3)
        
        sut.send(completion: .finished)
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs, [3, 3, 3, 3, 3])
        XCTAssertEqual(subscriber.receivedCompletions.count, range.count)
    }
    
    func test_whenSendCompletionFailure_thenEqualReceivedCompletionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<3
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        
        sut.send(completion: .failure(TestError.default))
        
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs.count, .zero)
        XCTAssertEqual(subscriber.receivedCompletions.count, range.count)
    }
    
}

// MARK: - Test Doubles
extension PassthroughSubjectTests {
    // MARK: TestSubscriber
    private final class TestSubscriber: Subscriber {
        typealias Input = Sut.Output
        
        typealias Failure = Sut.Failure
        
        var receivedSubscriptions: [Subscription] = []
        var receivedInputs: [Input] = []
        var receivedCompletions: [Subscribers.Completion<Failure>] = []
        
        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
            receivedSubscriptions.append(subscription)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            receivedInputs.append(input)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            receivedCompletions.append(completion)
        }
    }
}

// MARK: - TestError
extension PassthroughSubjectTests {
    private enum TestError: Error {
        case `default`
    }
}

// MARK: - All Tests
extension PassthroughSubjectTests {
    static var allTests = [
        ("test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsCount", test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsCount),
        ("test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsAndZeroCompletionsCount", test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsAndZeroCompletionsCount),
        ("test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsAndZeroCompletionsCount", test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsAndZeroCompletionsCount),
        ("test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount", test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount),
        ("test_whenSendCompletionFailure_thenEqualReceivedCompletionsCount", test_whenSendCompletionFailure_thenEqualReceivedCompletionsCount),
    ]
}
