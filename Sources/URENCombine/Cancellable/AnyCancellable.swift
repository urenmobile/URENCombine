//
//  AnyCancellable.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 2.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

final public class AnyCancellable: Cancellable {
    typealias CancelAction = () -> Void
    
    private var cancelAction: CancelAction?
    
    deinit {
        CombineUtility.printIfNeeded("*** deinit \(String(describing: self))")
    }
    init(_ cancel: @escaping CancelAction) {
        self.cancelAction = cancel
    }
    
    init<C>(_ canceller: C) where C: Cancellable {
        self.cancelAction = canceller.cancel
    }
    
    public func cancel() {
        if let action = cancelAction {
            action()
            cancelAction = nil
        }
    }
}
