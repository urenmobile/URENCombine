//
//  Subscription.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 10.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Subscription: Cancellable {
    func request(_ demand: Subscribers.Demand)
}
