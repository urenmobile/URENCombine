//
//  Publisher.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 9.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Publisher {
    associatedtype Output
    associatedtype Failure: Error
    
    /// The publisher acknowledges the subscription request. It calls receive(subscription:) on the subscriber.
    /// - Parameter subscriber:
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input
}

extension Publisher {
    
    /// Subscribe a subscriber on itself. The publisher acknowledges the subscription request.
    /// - Parameter subscriber:
    public func subscribe<S>(_ subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        CombineUtility.printIfNeeded("Publisher.subscribe called, receive will call")
        receive(subscriber: subscriber)
    }
}
