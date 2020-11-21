//
//  Future.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 20.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

final public class Future<Output, Failure>: Publisher where Failure: Error {
    
    public typealias Promise = (Result<Output, Failure>) -> Void
    
    private var subscriptions = [SubscriptionChannel]()
    private var result: Result<Output, Failure>?
    private let cancelBag = CancelBag()
    private let lock = CombineRecursiveLock()
    
    public init(_ attemptToFulFill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void) {
        
        attemptToFulFill { result in
            self.lock.lock {
                self.result = result
                self.publish(result)
            }
        }
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = SubscriptionChannel(parent: self, downstream: AnySubscriber(subscriber))
        subscription.cancel(by: cancelBag) // when Future deinit then cancel subscriptions
        subscriptions.append(subscription)
        subscriber.receive(subscription: subscription)
    }
    
    private func publish(_ result: Result<Output, Failure>) {
        subscriptions.forEach {
            switch result {
            case .success(let output):
                $0.send(output)
                $0.send(completion: .finished)
            case .failure(let error):
                $0.send(completion: .failure(error))
            }
        }
    }
    
}

extension Future {
    final class SubscriptionChannel: Subscription {
        private var parent: Future<Output, Failure>?
        private let downstream: AnySubscriber<Output, Failure>
        
        private var isCompleted: Bool {
            return parent == nil
        }
        
        init(parent: Future<Output, Failure>, downstream: AnySubscriber<Output, Failure>) {
            self.parent = parent
            self.downstream = downstream
        }
        
        func request(_ demand: Subscribers.Demand) {
        }
        
        func cancel() {
            CombineUtility.printIfNeeded("Future.SubscriptionChannel.CANCEL")
            parent = nil
        }
        
        fileprivate func send(_ value: Output) {
            guard !isCompleted else { return }
            let _ = downstream.receive(value)
        }
        
        fileprivate func send(completion: Subscribers.Completion<Failure>) {
            guard !isCompleted else { return }
            parent = nil
            downstream.receive(completion: completion)
        }
    }
}

extension Future.SubscriptionChannel: CustomStringConvertible {
    var description: String {
        return "Future"
    }
}
