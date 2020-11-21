//
//  Locker.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 14.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

protocol Locker {
    func lock()
    func unlock()
}

extension Locker {
    public func lock<T>(task: () throws -> T) rethrows -> T {
        CombineUtility.printIfNeeded("Lock block Start")
        lock()
        defer {
            unlock()
            CombineUtility.printIfNeeded("Lock block End")
        }
        return try task()
    }
}
