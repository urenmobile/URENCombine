//
//  Map.swift
//  TTIOSCombine
//
//  Created by Remzi YILDIRIM on 7/30/20.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
        return Publishers.Map(upstream: self, transform: transform)
    }
}

extension Publishers {
    public struct Map<Upstream, Output>: Publisher where Upstream: Publisher {
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let transform: (Upstream.Output) -> Output
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Output == S.Input {
            upstream.subscribe(SubscriberHolder(downstream: subscriber, transform: transform))
        }
    }
}

extension Publishers.Map {
    final class SubscriberHolder<Downstream>: BaseProducer<Downstream,
                                                           Upstream.Output,
                                                           Output,
                                                           Upstream.Failure,
                                                           (Upstream.Output) -> Output>
    where Downstream: Subscriber, Downstream.Input == Output {
        
        override func receive(newValue: Input) -> ConvertCompletion<Output?, Downstream.Failure> {
            return .continue(transform(newValue))
        }
    }
}

extension Publishers.Map.SubscriberHolder: CustomStringConvertible {
    var description: String {
        return "Map"
    }
}
