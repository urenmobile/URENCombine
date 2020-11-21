//
//  Subscriptions.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 18.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public enum Subscriptions {
    
}

private protocol EmptySubs {
    static var empty: Subscription { get }
}

extension Subscriptions: EmptySubs {
    public static var empty: Subscription {
        return EmptySubscription()
    }
}

extension Subscriptions {
    private struct EmptySubscription: Subscription {
        func request(_ demand: Subscribers.Demand) { }
        func cancel() { }
    }
}
