//
//  ReceiveOn.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 17.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func receive<S>(on scheduler: S) -> Publishers.ReceiveOn<Self, S> where S: Scheduler {
        return Publishers.ReceiveOn(upstream: self, scheduler: scheduler)
    }
}

extension Publishers {
    public struct ReceiveOn<Upstream, Context>: Publisher where Upstream: Publisher, Context: Scheduler {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        public let scheduler: Context

        public init(upstream: Upstream, scheduler: Context) {
            self.upstream = upstream
            self.scheduler = scheduler
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            upstream.subscribe(SubscriberHolder(self, downstream: subscriber))
        }
    }
}

extension Publishers.ReceiveOn {
    fileprivate class SubscriberHolder<Downstream: Subscriber>: Subscriber, Subscription where Downstream.Input == Upstream.Output, Downstream.Failure == Upstream.Failure  {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        typealias ReceiveOn = Publishers.ReceiveOn<Upstream, Context>
        
        private let receiveOn: ReceiveOn
        private let downstream: Downstream
        private var state: Subscribers.State = .pending
        private let lock = CombineLock()
        private let downstreamLock = CombineLock()
        
        init(_ receiveOn: ReceiveOn, downstream: Downstream) {
            self.receiveOn = receiveOn
            self.downstream = downstream
        }
        
        func receive(subscription: Subscription) {
            lock.lock()
            guard case .pending = state else {
                lock.unlock()
                return
            }
            state = .connected(subscription)
            lock.unlock()
            
            downstreamLock.lock { [unowned self] in
                downstream.receive(subscription: self)
            }
        }
        
        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            lock.lock()
            let downstreamSafe = downstream
            let receiveOnSafe = receiveOn
            lock.unlock()
            receiveOnSafe.scheduler.schedule { [weak self] in
                self?.downstreamLock.lock()
                let _ = downstreamSafe.receive(input)
                self?.downstreamLock.unlock()
            }
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            lock.lock()
            let downstreamSafe = downstream
            let receiveOnSafe = receiveOn
            lock.unlock()
            receiveOnSafe.scheduler.schedule { [weak self] in
                self?.downstreamLock.lock()
                downstreamSafe.receive(completion: completion)
                self?.downstreamLock.unlock()
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            guard case let .connected(subscription) = state else {
                lock.unlock()
                return
            }
            lock.unlock()
            subscription.request(demand)
        }
        
        func cancel() {
            lock.lock()
            guard case let .connected(subscription) = state else {
                lock.unlock()
                return
            }
            state = .cancelled
            lock.unlock()
            subscription.cancel()
        }
    }
}

extension Publishers.ReceiveOn.SubscriberHolder: CustomStringConvertible {
    var description: String {
        return "ReceiveOn"
    }
}
