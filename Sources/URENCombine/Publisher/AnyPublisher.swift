//
//  AnyPublisher.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 11.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure> {
        return AnyPublisher(self)
    }
}


public struct AnyPublisher<Output, Failure> where Failure: Error {
    
    private let publisher: AnyPublisherHolderBase<Output, Failure>
    
    public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P: Publisher {
        self.publisher = AnyPublisherHolder(publisher)
    }
}

extension AnyPublisher: Publisher {
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        publisher.subscribe(subscriber)
    }
}


// MARK: - AnyPublisherHolderBase
class AnyPublisherHolderBase<Output, Failure>: Publisher where Failure: Error {
    
    init() {  }
    
    /// Implement receive function for Subscriber
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        CombineUtility.notImplementedError()
    }
}

// MARK: - AnyPublisherHolder
final class AnyPublisherHolder<PublisherType>: AnyPublisherHolderBase<PublisherType.Output, PublisherType.Failure> where PublisherType: Publisher {
    let publisher: PublisherType
    
    init(_ publisher: PublisherType) {
        self.publisher = publisher
        super.init()
    }
    
    override func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        publisher.subscribe(subscriber)
    }
}
