//
//  CombineLock.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 21.11.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public class CombineLock: Locker {
    private let locker = NSLock()
    // Semaphore Block the main thread when calling in main thread
//    private let semaphore = DispatchSemaphore(value: 1)

    func lock() {
        locker.lock()
//        semaphore.wait()
    }

    func unlock() {
        locker.unlock()
//        semaphore.signal()
    }
}
