//
//  CurrentValueSubject.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 17.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

final public class CurrentValueSubject<Output, Failure: Error>: Subject {
    
    private var subscriptions = [SubscriptionChannel]()
    private var privateValue: Output
    private var completion: Subscribers.Completion<Failure>?
    private let cancelBag = CancelBag()
    private var lock = CombineRecursiveLock()
    
    public var value: Output {
        get {
            return privateValue
        }
        set {
            send(newValue)
        }
    }
    
    deinit {
        CombineUtility.printIfNeeded("CurrentValueSubject deinit")
    }
    
    public init(_ value: Output) {
        privateValue = value
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        CombineUtility.printIfNeeded("CurrentValueSubject.receive(subscriber:) called, subscriber.recive(subscription:) will call")
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
            privateValue = value
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
}

extension CurrentValueSubject {
    class SubscriptionChannel: Subscription {
        private var parent: CurrentValueSubject?
        private let downstream: AnySubscriber<Output, Failure>
        
        private var isCompleted: Bool {
            return parent == nil
        }
        
        deinit {
            print("*** denit \(String(describing: self))")
        }
        init(parent: CurrentValueSubject, downstream: AnySubscriber<Output, Failure>) {
            self.parent = parent
            self.downstream = downstream
            CombineUtility.printIfNeeded("CurrentValueSubject.SubscriptionChannel was created")
        }
        
        public func request(_ demand: Subscribers.Demand) {
            CombineUtility.printIfNeeded("CurrentValueSubject.SubscriptionChannel.request( demand:) called, subscriber.receive(input:) will call")
            guard let parent = parent else { return }
            parent.lock.lock {
                send(parent.value)
            }
        }
        
        public func cancel() {
            CombineUtility.printIfNeeded("CurrentValueSubject.SubscriptionChannel.CANCEL")
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

extension CurrentValueSubject.SubscriptionChannel: CustomStringConvertible {
    var description: String {
        return "CurrentValueSubject"
    }
}
