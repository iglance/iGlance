//
//  Queue.swift
//  iGlance
//
//  Created by Dominik on 10.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation

public struct Queue<T>: Sequence {
    fileprivate var array = [T]()

    var count: Int {
        array.count
    }

    var front: T? {
        // if the array is empty this will return nil
        return array.first
    }

    public mutating func enqueue(_ value: T) {
        array.append(value)
    }

    public mutating func dequeue() -> T {
        array.removeFirst()
    }

    public func makeIterator() -> IndexingIterator<[T]> {
        array.makeIterator()
    }
}
