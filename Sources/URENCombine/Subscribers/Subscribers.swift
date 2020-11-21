//
//  Subscribers.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 9.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public enum Subscribers {
    
}

extension Subscribers {
    public enum Completion<Failure: Error> {
        case finished
        case failure(Failure)
    }
    
    public enum Demand {
        case none
        case unlimited
    }
    
    public enum State {
        case pending
        case connected(Subscription)
        case cancelled
    }
}

extension Subscribers.Completion {
    public var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
