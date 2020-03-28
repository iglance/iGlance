//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
