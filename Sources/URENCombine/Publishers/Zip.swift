//
//  Zip.swift
//  TTIOSCombine
//
//  Created by Remzi YILDIRIM on 7/26/20.
//  Copyright © 2020 Uren Mobile. All rights reserved.
//

import Foundation

extension Publisher {
    public func zip<P>(_ publisher1: P) -> Publishers.Zip<Self, P> where P: Publisher, Self.Failure == P.Failure {
        return Publishers.Zip(self, publisher1)
    }
}

extension Publishers {
    /// A publisher created by applying the zip function to four upstream publishers.
    public struct Zip<A, B>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure {

        public typealias Output = (A.Output, B.Output)
        public typealias Failure = A.Failure

        public let a: A
        public let b: B

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, B.Failure == S.Failure, S.Input == Output {
            a.zip(b)
                .map {
                    ($0.0, $0.1)
            }.receive(subscriber: subscriber)
        }
    }
}

extension Publishers {
    /// A publisher created by applying the zip function to four upstream publishers.
    public struct Zip3<A, B, C> : Publisher where A : Publisher, B : Publisher, C : Publisher, A.Failure == B.Failure, B.Failure == C.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, C.Failure == S.Failure, S.Input == Publishers.Zip3<A, B, C>.Output {
            a.zip(b).zip(c)
                .map {
                    ($0.0, $0.1, $1)
            }.receive(subscriber: subscriber)
        }
    }
}

extension Publishers {
    /// A publisher created by applying the zip function to four upstream publishers.
    public struct Zip4<A, B, C, D> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output, D.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public let c: C

        public let d: D

        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, D.Failure == S.Failure, S.Input == Publishers.Zip4<A, B, C, D>.Output {
            a.zip(b).zip(c).zip(d)
                .map {
                    ($0.0.0, $0.0.1, $0.1, $1)
            }.receive(subscriber: subscriber)
        }
    }
}
