//
//  CombineRecursiveLock.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 21.11.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public class CombineRecursiveLock: Locker {
    private let locker = NSRecursiveLock()

    func lock() {
        locker.lock()
    }

    func unlock() {
        locker.unlock()
    }
}
