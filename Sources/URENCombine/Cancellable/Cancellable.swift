//
//  Cancellable.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 24.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Cancellable {
    func cancel()
}

extension Cancellable {
    public func cancel(by bag: CancelBag) {
        bag.store(self)
    }
}
