//
//  AnySubscriber.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 11.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public struct AnySubscriber<Input, Failure>: Subscriber where Failure: Error {
    
    private var subscriber: AnySubscriberHolderBase<Input, Failure>
    
    init<S>(_ subscriber: S) where S: Subscriber, Input == S.Input, Failure == S.Failure {
        CombineUtility.printIfNeeded("AnySubscriber was created")
        self.subscriber = AnySubscriberHolder(subscriber)
    }
    
    public func receive(subscription: Subscription) {
        CombineUtility.printIfNeeded("AnySubscriber.receive(subscription:) called, subscriber.receive(subscription:) will call")
        subscriber.receive(subscription: subscription)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        CombineUtility.printIfNeeded("AnySubscriber.receive(input:) called, subscriber.receive(input:) will call")
        return subscriber.receive(input)
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        subscriber.receive(completion: completion)
    }
}

// MARK: - AnySubscriberHolderBase
class AnySubscriberHolderBase<Input, Failure>: Subscriber where Failure: Error {
    
    init() { }
    
    func receive(subscription: Subscription) {
        CombineUtility.notImplementedError()
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        CombineUtility.notImplementedError()
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        CombineUtility.notImplementedError()
    }
}

// MARK: - AnySubscriberHolder
final class AnySubscriberHolder<SubscriberType>: AnySubscriberHolderBase<SubscriberType.Input, SubscriberType.Failure> where SubscriberType: Subscriber   {

    let subscriber: SubscriberType

    init(_ subscriber: SubscriberType) {
        self.subscriber = subscriber
    }

    override func receive(subscription: Subscription) {
        subscriber.receive(subscription: subscription)
    }

    override func receive(_ input: Input) -> Subscribers.Demand {
        subscriber.receive(input)
    }

    override func receive(completion: Subscribers.Completion<Failure>) {
        subscriber.receive(completion: completion)
    }
}
