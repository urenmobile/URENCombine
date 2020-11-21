//
//  Empty.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 20.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public struct Empty<Output, Failure>: Publisher where Failure: Error {
    
    public let completeImmediately: Bool
    
    init(completeImmediately: Bool = true) {
        self.completeImmediately = completeImmediately
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscriptions.empty)
        if completeImmediately {
            subscriber.receive(completion: .finished)
        }
    }
}
