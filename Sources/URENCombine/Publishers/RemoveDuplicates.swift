//
//  RemoveDuplicates.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 26.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher where Self.Output: Equatable {
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        return Publishers.RemoveDuplicates(upstream: self, predicate: ==)
    }
}

extension Publishers {
    public struct RemoveDuplicates<Upstream>: Publisher where Upstream: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        public let predicate: (Upstream.Output, Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Upstream.Output, Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            upstream.subscribe(SubscriberHolder(downstream: subscriber, transform: predicate))
        }
    }
}

extension Publishers.RemoveDuplicates {
    final class SubscriberHolder<Downstream>: BaseProducer<Downstream,
                                                           Upstream.Output,
                                                           Upstream.Output,
                                                           Upstream.Failure,
                                                           (Output, Output) -> Bool>
    where Downstream: Subscriber, Downstream.Input == Upstream.Output {
        
        private var previousValue: Upstream.Output?
        
        override func receive(newValue: Upstream.Output) -> ConvertCompletion<Upstream.Output?, Downstream.Failure> {
            let prev = previousValue
            self.previousValue = newValue
            guard let previous = prev else { return .continue(newValue) }
            return transform(previous, newValue) ? .continue(nil) : .continue(newValue)
        }
    }
}

extension Publishers.RemoveDuplicates.SubscriberHolder: CustomStringConvertible, CustomReflectable {
    var description: String {
        return "RemoveDuplicates"
    }
    
    var customMirror: Mirror {
        let children: [Mirror.Child] = [("downstream", downstream), ("previousValue", previousValue as Any) ]
        return Mirror(self, children: children)
    }
}
