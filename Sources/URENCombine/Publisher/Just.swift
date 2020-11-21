//
//  Just.swift
//  TTIOSCombine
//
//  Created by Remzi YILDIRIM on 7/18/20.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public struct Just<Output>: Publisher {
    
    public typealias Failure = Never
    
    public let output: Output
    
    public init(_ output: Output) {
        self.output = output
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: SubscriptionChannel(value: output, downstream: subscriber))
    }
}

extension Just {
    fileprivate final class SubscriptionChannel<Downstream: Subscriber>: Subscription where Downstream.Input == Output {
        
        private let value: Output
        private var downstream: Downstream?
        
        init(value: Output, downstream: Downstream) {
            self.value = value
            self.downstream = downstream
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard let downstream = downstream else { return }
            _ = downstream.receive(value)
            downstream.receive(completion: .finished)
            cancel()
        }
        
        func cancel() {
            downstream = nil
        }
    }
}

extension Just.SubscriptionChannel : CustomStringConvertible {
    var description: String {
        return "Just"
    }
}
