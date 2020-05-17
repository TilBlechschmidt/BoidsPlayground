//
//  Matrix.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation

struct Matrix<T> {
    let rows: Int, columns: Int
    private(set) var grid: [T]
    
    init(rows: Int, columns: Int, initialValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: initialValue, count: rows * columns)
    }
    
    private func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
