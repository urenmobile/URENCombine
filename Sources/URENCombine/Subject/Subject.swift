//
//  Subject.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 11.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Subject: AnyObject, Publisher {
    func send(_ value: Self.Output)
    func send(completion: Subscribers.Completion<Self.Failure>)
    // No need 
//    func send(subscription: Subscription)
}

extension Subject where Output == Void {

    public func send() {
        send(())
    }
}
