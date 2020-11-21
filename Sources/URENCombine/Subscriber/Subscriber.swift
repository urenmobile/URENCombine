//
//  Subscriber.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 9.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Subscriber {
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(subscription: Subscription)
    func receive(_ input: Self.Input) -> Subscribers.Demand
    func receive(completion: Subscribers.Completion<Self.Failure>)
}
