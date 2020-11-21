//
//  Sink.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 18.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Subscribers {
    /// Used for store action and cancel when needed
    final public class Sink<Input, Failure>: Subscriber, Cancellable where Failure: Error {
        
        public let receiveValue: (Input) -> Void
        public let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
        private var state: Subscribers.State = .pending
        
        public init(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void, receiveValue: @escaping (Input) -> Void) {
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
            CombineUtility.printIfNeeded("Subscribers.Sink was created")
        }
        
        public func receive(subscription: Subscription) {
            CombineUtility.printIfNeeded("Subscribers.receive(subscription:) called, subscription.request(demand) will call")
            guard case .pending = state else {
                return
            }
            state = .connected(subscription)
            subscription.request(.unlimited)
        }
        
        public func receive(_ input: Input) -> Subscribers.Demand {
            CombineUtility.printIfNeeded("Subscribers.receive(input:) called, receiveValue closure will trigger")
            receiveValue(input)
            return .none
        }
        
        public func receive(completion: Subscribers.Completion<Failure>) {
            CombineUtility.printIfNeeded("Subscribers.receive(completion:) called, receiveCompletion closure will trigger. Finally cancelled")
            receiveCompletion(completion)
        }
        
        public func cancel() {
            guard case let .connected(subscription) = state else {
                return
            }
            state = .cancelled
            subscription.cancel()
        }
    }
}

extension Subscribers.Sink: CustomStringConvertible {
    public var description: String {
        return "Sink"
    }
}

extension Publisher {
    /// Create a subsriber and store in Publisher via subscribe
    public func sink(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void, receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        let subscriber = Subscribers.Sink<Output, Failure>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
    }
}

extension Publisher where Failure == Never {
    /// Create a subsriber and store in Publisher via subscribe
    public func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        CombineUtility.printIfNeeded("Publisher.sink(receiveValue:) called, subscribe will call")
        let subscriber = Subscribers.Sink<Output, Failure>(receiveCompletion: { _ in }, receiveValue: receiveValue)
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
    }
}
