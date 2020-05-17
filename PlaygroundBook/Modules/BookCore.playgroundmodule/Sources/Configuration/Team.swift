//
//  Team.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation

private var identifierSeed: Team.ID = 42

fileprivate func generateID() -> Team.ID {
    defer {
        identifierSeed += 1
    }
    return identifierSeed
}

public enum BoidColoration: String, Codable, CaseIterable {
    /// Random, fixed color
    case fixedColor = "boid_fragment_color"
    /// Deviation of current acceleration from the velocity
    case angleOfAttack = "boid_fragment_angleOfAttack"
    /// Velocity direction interpreted as hue
    case heading = "boid_fragment_heading"
    /// Current speed
    case velocity = "boid_fragment_acceleration"
}

public struct Team: Codable, Hashable {
    typealias ID = Int

    let uuid: ID
    let boidCount: Int
    let maximumVelocity: Float
    let size: Float
    
    let speedVariance: Float
    let sizeVariance: Float
    
    let coloration: BoidColoration
    
    public init(of boidCount: Int, maximumVelocity: Float = 35, size: Float = 0.5, speedVariance: Float = 0.25, sizeVariance: Float = 0.25, coloration: BoidColoration = .fixedColor) {
        self.uuid = generateID()
        self.boidCount = boidCount
        self.maximumVelocity = maximumVelocity
        self.size = size
        self.speedVariance = speedVariance
        self.sizeVariance = sizeVariance
        self.coloration = coloration
    }
}
