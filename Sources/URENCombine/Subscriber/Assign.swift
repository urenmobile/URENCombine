//
//  Assign.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 24.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Subscribers {
    final public class Assign<Root, Input>: Subscriber, Cancellable {
        public typealias Failure = Never
        
        final public private(set) var object: Root?

        final public let keyPath: ReferenceWritableKeyPath<Root, Input>
        
        private var subscription: Subscription?
        private let state: State = .pending
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }

        public func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }
        
        public func receive(_ input: Input) -> Subscribers.Demand {
            object?[keyPath: keyPath] = input
            return .none
        }
        
        public func receive(completion: Subscribers.Completion<Never>) {
            cancel()
        }
        
        public func cancel() {
            object = nil
            subscription?.cancel()
            subscription = nil
        }
    }
}

extension Subscribers.Assign: CustomStringConvertible, CustomReflectable {
    public var description: String {
        return "Assign \(Root.self)"
    }
    
    public var customMirror: Mirror {
        let children: [Mirror.Child] = [("object", object as Any), ("keyPath", keyPath)]
        
        return Mirror(self, children: children)
    }
}

extension Publisher where Self.Failure == Never {
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable {
        CombineUtility.printIfNeeded("Publisher.assign(to:) called, subscribe will call")
        let subscriber = Subscribers.Assign(object: object, keyPath: keyPath)
        subscribe(subscriber)
        
        return AnyCancellable(subscriber)
    }
}
