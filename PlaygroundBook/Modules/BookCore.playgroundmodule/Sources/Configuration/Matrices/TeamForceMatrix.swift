//
//  TeamForceMatrix.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

class TeamForceMatrix<T> {
    typealias Index = (team1: Int, team2: Int, force: Int)
    
    let forceCount = ForceType.allCases.count
    let teamCount: Int
    
    private lazy var teamMatrixLength = teamCount * teamCount
    private(set) var storage: [T]
    
    init(teamCount: Int, defaultValue: T) {
        self.teamCount = teamCount
        storage = Array(repeating: defaultValue, count: teamCount * teamCount * forceCount)
    }
    
    private func indexIsValid(_ index: Index) -> Bool {
        return index.team1 < teamCount
            && index.team2 < teamCount
            && index.force < forceCount
    }
    
    private func calculateIndex(_ index: Index) -> Int {
        // Calculate the location of the 2D team matrix in the storage
        let teamMatrixStartIndex = teamMatrixLength * index.force
        
        // Calculate the array index in the 2D matrix (team * team)
        let row = index.team1
        let column = index.team2
        let matrixIndex = teamCount * row + column
        
        // Calculate the storage index
        return teamMatrixStartIndex + matrixIndex
    }
    
    subscript(team1: Int, team2: Int, force: Int) -> T {
        get {
            let index = (team1: team1, team2: team2, force: force)
            assert(indexIsValid(index), "Index out of range")
            return storage[calculateIndex(index)]
        }
        set(newValue) {
            let index = (team1: team1, team2: team2, force: force)
            assert(indexIsValid(index), "Index out of range")
            storage[calculateIndex(index)] = newValue
        }
    }
    
    func createBuffer(on device: MTLDevice) -> MTLBuffer? {
        let length = storage.count * MemoryLayout<T>.stride
        return device.makeBuffer(bytes: storage, length: length, options: [])
    }
}

//class TeamForceMatrix<T> {
//    typealias Index = (team1: Int, team2: Int, force: Int)
//
//    let forceCount = ForceType.allCases.count
//    let teamCount: Int
//
//    private lazy var teamMatrixLength = teamCount * (teamCount + 1) / 2
//    private(set) var storage: [T] = []
//
//    init(teamCount: Int) {
//        self.teamCount = teamCount
//    }
//
//    private func indexIsValid(_ index: Index) -> Bool {
//        return index.team1 < teamCount
//            && index.team2 < teamCount
//            && index.force < forceCount
//    }
//
//    private func calculateIndex(_ index: Index) -> Int {
//        // Calculate the location of the RMULTM matrix in the storage
//        let teamMatrixStartIndex = teamMatrixLength * index.force
//
//        // Calculate the array index in the 2D RMULTM matrix (team * team)
//        let row = min(index.team1, index.team2)
//        let column = max(index.team1, index.team2)
//        let matrixIndex = (teamCount * row) + column - ((row * (row + 1)) / 2)
//
//        // Calculate the storage index
//        return teamMatrixStartIndex + matrixIndex
//    }
//
//    subscript(team1: Int, team2: Int, force: Int) -> T {
//        get {
//            let index = (team1: team1, team2: team2, force: force)
//            assert(indexIsValid(index), "Index out of range")
//            return storage[calculateIndex(index)]
//        }
//        set(newValue) {
//            let index = (team1: team1, team2: team2, force: force)
//            assert(indexIsValid(index), "Index out of range")
//            storage[calculateIndex(index)] = newValue
//        }
//    }
//
//    func createBuffer(on device: MTLDevice) -> MTLBuffer? {
//        let length = storage.count * MemoryLayout<T>.stride
//        return device.makeBuffer(bytes: storage, length: length, options: [])
//    }
//}
