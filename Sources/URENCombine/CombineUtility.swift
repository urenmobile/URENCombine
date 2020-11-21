//
//  CombineUtility.swift
//  URENCombine
//
//  Created by Remzi YILDIRIM on 24.05.2020.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

public class CombineUtility {
    
    class func notImplementedError(file: StaticString = #file, line: UInt = #line) -> Never {
        fatalError("Base class function not implemented", file: file, line: line)
    }
}

// MARK: - Logging
extension CombineUtility {
    public typealias LoggingFunction = (Any) -> Void

    /// Usable for printing event flow in Subject, Publisher, Subscriber, Cancellable and deinit
    public static var loggingFunction: LoggingFunction?
    
    /// Printing event flow in Subject, Publisher, Subscriber, Cancellable and deinit
    class func printIfNeeded(_ items: Any) {
        loggingFunction?(items)
    }
}
