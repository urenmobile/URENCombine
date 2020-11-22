//
//  CurrentValueSubjectTests.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 11/22/20.
//  Copyright © 2020 Uren Mobile. All rights reserved.

import XCTest
import URENCombine

final class CurrentValueSubjectTests: XCTestCase {
    // MARK: - Subject Under Test
    private typealias Sut = CurrentValueSubject<Int, TestError>
    private var sut: Sut!
    
    // MARK: — Test Lifecycle
    override func setUp() {
        super.setUp()
        sut = Sut(10)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsAndInputsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        
        // Then
        XCTAssertEqual(subscriber.receivedSubscriptions.count, range.count)
        XCTAssertEqual(subscriber.receivedInputs.count, range.count)
        XCTAssertEqual(subscriber.receivedCompletions.count, .zero)
    }
    
    func test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsContainPreviousAndCurrent() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<3
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        sut.value = 12
        
        // Then
        XCTAssertEqual(subscriber.receivedInputs, [10, 10, 10, 12, 12, 12])
    }
    
    func test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsContainsPreviousAndCurrent() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<3
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        
        subscriber.receivedSubscriptions.last?.cancel()
        sut.send(11)
        
        // Then
        XCTAssertEqual(subscriber.receivedInputs, [10, 10, 10, 11, 11])
    }
    
    func test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount() {
        // Given
        let subscriber = TestSubscriber()
        let range = 0..<5
        
        // When
        range.forEach { _ in
            sut.subscribe(subscriber)
        }
        sut.value = 11
        
        sut.send(completion: .finished)
        
        // Then
        XCTAssertEqual(subscriber.receivedInputs, [10, 10, 10, 10, 10, 11, 11, 11, 11, 11])
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
        XCTAssertEqual(subscriber.receivedInputs.count, range.count)
        XCTAssertEqual(subscriber.receivedCompletions.count, range.count)
    }
    
}

// MARK: - Test Doubles
extension CurrentValueSubjectTests {
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
extension CurrentValueSubjectTests {
    private enum TestError: Error {
        case `default`
    }
}

// MARK: - All Tests
extension CurrentValueSubjectTests {
    static var allTests = [
        ("test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsAndInputsCount", test_whenMultiSubscribeWithSubscriber_thenEqualReceivedSubscriptionsAndInputsCount),
        ("test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsContainPreviousAndCurrent", test_whenSendValueToMultiSubscribe_thenEqualReceivedInputsContainPreviousAndCurrent),
        ("test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsContainsPreviousAndCurrent", test_whenSendValueAndCancelLastSubsription_thenEqualReceivedInputsContainsPreviousAndCurrent),
        ("test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount", test_whenSendValueAndComplete_thenEqualReceivedInputsAndCompletionsCount),
        ("test_whenSendCompletionFailure_thenEqualReceivedCompletionsCount", test_whenSendCompletionFailure_thenEqualReceivedCompletionsCount),
    ]
}
