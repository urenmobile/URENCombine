//
//  Scheduler.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 16.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public protocol Scheduler {
    func schedule(_ action: @escaping () -> Void)
}

extension DispatchQueue: Scheduler {
    public func schedule(_ action: @escaping () -> Void) {
        async(execute: action)
    }
}
