//
//  Filter.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 27.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> Publishers.Filter<Self> {
        return Publishers.Filter(upstream: self, isIncluded: isIncluded)
    }
}

extension Publishers {
    public struct Filter<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        public let isIncluded: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.isIncluded = isIncluded
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream.subscribe(SubscriberHolder(downstream: subscriber, transform: isIncluded))
        }
        
    }
}

extension Publishers.Filter {
    final class SubscriberHolder<Downstream>: BaseProducer<Downstream,
                                                           Upstream.Output,
                                                           Upstream.Output,
                                                           Upstream.Failure,
                                                           (Output) -> Bool>
    where Downstream: Subscriber, Upstream.Output == Downstream.Input {
        
        override func receive(newValue: Upstream.Output) -> ConvertCompletion<Upstream.Output?, Downstream.Failure> {
            return transform(newValue) ? .continue(newValue) : .continue(nil)
        }
    }
}

extension Publishers.Filter.SubscriberHolder: CustomStringConvertible {
    var description: String {
        return "Filter"
    }
}
