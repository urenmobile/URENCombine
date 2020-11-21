//
//  CancelBag.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 21.11.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public final class CancelBag {
    private var cancellables = [Cancellable]()
    
    deinit {
        cancel()
    }
    
    public init() { }
    
    func store(_ cancellable: Cancellable) {
        cancellables.append(cancellable)
    }
    
    private func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll(keepingCapacity: false)
    }
}
