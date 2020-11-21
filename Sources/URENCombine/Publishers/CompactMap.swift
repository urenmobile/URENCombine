//
//  CompactMap.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 20.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T> {
        return Publishers.CompactMap(upstream: self, transform: transform)
    }
}

extension Publishers {
    public struct CompactMap<Upstream, Output>: Publisher where Upstream: Publisher {
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        public let transform: (Upstream.Output) -> Output?
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output?) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Output == S.Input {
            upstream.subscribe(SubscriberHolder(downstream: subscriber, transform: transform))
        }
    }
}

extension Publishers.CompactMap {
    final class SubscriberHolder<Downstream>: BaseProducer<Downstream,
                                                           Upstream.Output,
                                                           Output,
                                                           Upstream.Failure,
                                                           (Upstream.Output) -> Output?>
    where Downstream: Subscriber, Downstream.Input == Output, Downstream.Failure == Upstream.Failure {
        
        override func receive(newValue: Input) -> ConvertCompletion<Output?, Downstream.Failure> {
            return .continue(transform(newValue))
        }
    }
}

extension Publishers.CompactMap.SubscriberHolder: CustomStringConvertible {
    var description: String {
        return "CompactMap"
    }
}

enum ConvertCompletion<Value, Failure: Error> {
    case `continue`(Value)
    case finished
    case failure(Failure)
}

class BaseProducer<Downstream,
                   Input,
                   Output,
                   Failure,
                   Transform>
where Downstream: Subscriber, Downstream.Input == Output, Failure: Error  {
    
    final let downstream: Downstream
    final let transform: Transform
    private var state: Subscribers.State = .pending
    private let lock = CombineLock()
    
    init(downstream: Downstream, transform: Transform) {
        self.downstream = downstream
        self.transform = transform
    }
    
    func receive(newValue: Input) -> ConvertCompletion<Output?, Downstream.Failure> {
        CombineUtility.notImplementedError()
    }
}

extension BaseProducer: Subscription {
    func request(_ demand: Subscribers.Demand) {
        lock.lock()
        switch state {
        case .pending:
            lock.unlock()
            fatalError("Subscription state is invalid. Send subscription before request demand.")
        case .connected(let subscription):
            lock.unlock()
            subscription.request(demand)
        case .cancelled:
            lock.unlock()
        }
    }
    
    func cancel() {
        lock.lock()
        guard case let .connected(subscription) = state else {
            state = .cancelled
            lock.unlock()
            return
        }
        state = .cancelled
        lock.unlock()
        subscription.cancel()
    }
}

extension BaseProducer: Subscriber {
    func receive(subscription: Subscription) {
        lock.lock()
        guard case .pending = state  else {
            lock.unlock()
            return
        }
        state = .connected(subscription)
        lock.unlock()
        downstream.receive(subscription: self)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        lock.lock()
        switch state {
        case .pending:
            lock.unlock()
            fatalError("Input state is invalid. Received value before receiving subscription")
        case .connected(let subscription):
            lock.unlock()
            switch receive(newValue: input) {
            case .continue(let output?):
                return downstream.receive(output)
            case .continue(nil):
                return .none
            case .finished:
                lock.lock()
                state = .cancelled
                lock.unlock()
                subscription.cancel()
                downstream.receive(completion: .finished)
            case .failure(let error):
                lock.lock()
                state = .cancelled
                lock.unlock()
                subscription.cancel()
                downstream.receive(completion: .failure(error))
            }
        case .cancelled:
            lock.unlock()
        }
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        lock.lock()
        switch state {
        case .pending:
            lock.unlock()
            fatalError("Completion state is invalid. Received completion before receiving subscription")
        case .cancelled:
            lock.unlock()
        case .connected(let subscription):
            state = .cancelled
            lock.unlock()
            subscription.cancel()
            switch completion {
            case .finished:
                downstream.receive(completion: .finished)
            case .failure(let error):
                downstream.receive(completion: .failure(error as! Downstream.Failure))
            }
        }
    }
}
