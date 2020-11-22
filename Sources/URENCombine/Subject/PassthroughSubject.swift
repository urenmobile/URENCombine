//
//  PassthroughSubject.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 1.06.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

final public class PassthroughSubject<Output, Failure: Error>: Subject {
    
    private var subscriptions = [SubscriptionChannel]()
    private var completion: Subscribers.Completion<Failure>?
    private let cancelBag = CancelBag()
    private var lock = CombineRecursiveLock()
    
    deinit {
        CombineUtility.printIfNeeded("PassthroughSubject deinit")
    }
    
    public init() { }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        CombineUtility.printIfNeeded("PassthroughSubject.receive(subscriber:) called, subscriber.recive(subscription:) will call")
        // create own subscription and store subscriber in it then call subscriber's receive(subscriprion:)
        lock.lock {
            if let completion = completion {
                subscriber.receive(subscription: Subscriptions.empty)
                subscriber.receive(completion: completion)
            } else {
                let subscription = SubscriptionChannel(parent: self, downstream: AnySubscriber(subscriber))
                subscription.cancel(by: cancelBag) // when subject deinit then cancel subscriptions
                subscriptions.append(subscription)
                subscriber.receive(subscription: subscription)
            }
        }
    }
    
    public func send(_ value: Output) {
        lock.lock {
            subscriptions.forEach {
                $0.send(value)
            }
        }
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.completion = completion
        lock.lock {
            subscriptions.forEach {
                $0.send(completion: completion)
            }
        }
    }
    
    private func remove(subscription: SubscriptionChannel) {
        lock.lock {
            guard let index = subscriptions.firstIndex(where: {$0 === subscription}) else {
                return
            }
            subscriptions.remove(at: index)
        }
    }
}

extension PassthroughSubject {
    class SubscriptionChannel: Subscription {
        private var parent: PassthroughSubject?
        private let downstream: AnySubscriber<Output, Failure>
        
        private var isCompleted: Bool {
            return parent == nil
        }
        
        deinit {
            CombineUtility.printIfNeeded("*** denit \(String(describing: self))")
        }
        init(parent: PassthroughSubject, downstream: AnySubscriber<Output, Failure>) {
            self.parent = parent
            self.downstream = downstream
            
            CombineUtility.printIfNeeded("PassthroughSubject.SubscriptionChannel was created")
        }
        
        public func request(_ demand: Subscribers.Demand) {
            CombineUtility.printIfNeeded("PassthroughSubject.SubscriptionChannel.request( demand:) called, subscriber.receive(input:) will call")
            // No need action
        }
        
        public func cancel() {
            CombineUtility.printIfNeeded("PassthroughSubject.SubscriptionChannel.CANCEL")
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

extension PassthroughSubject.SubscriptionChannel: CustomStringConvertible {
    var description: String {
        return "PassthroughSubject"
    }
}
