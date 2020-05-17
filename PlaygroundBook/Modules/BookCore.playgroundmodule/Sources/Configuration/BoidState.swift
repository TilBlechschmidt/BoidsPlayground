//
//  BoidState.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

struct BoidConfiguration {
    let team: Int32
    let size: Float
    let maximumVelocity: Float
    
    // TODO:
    // Color (maybe per-team?)
    // Local goal
    // Speed modifier
    
    init(_ team: Team, id: Int) {
        self.team = Int32(id)
        self.size = team.size * Float.random(in: (1-team.sizeVariance)...(1+team.sizeVariance))
        self.maximumVelocity = team.maximumVelocity * Float.random(in: (1-team.speedVariance)...(1+team.speedVariance))
    }
}

struct BoidState {
    let teams: [Team]
    
    let boidCount: Int
    let forceCount: Int
    let teamCount: Int
    
    /// Array of `boidCount` BoidConfigurations.
    let configurationBuffer: MTLBuffer
    
    /// Array of `boidCount * 3` floats where each boid has a 3D position vector.
    /// Calculation of the 3D position vector index: `index = boidIndex * 3`
    let positionBuffer: MTLBuffer
    
    /// Array of `teamCount * forceCount * boidCount * 3` floats where each boid has a 3D vector for each team and force combination.
    ///
    /// Calculation of the 3D acceleration vector index:
    /// ```
    /// let forceSliceSize = 3
    /// let teamSliceSize = forceCount * forceSliceSize
    /// let boidSliceSize = teamCount * teamSliceSize
    /// let index = boidSliceSize * boidIndex + teamSliceSize * teamIndex + forceSliceSize * forceIndex
    /// ```
    ///
    ///
    /// Format of array (b = boid, t = team, f = force, xyz = packed_float3):
    /// ```
    /// |b0             |b1             |
    /// |t0     |t1     |t0     |t1     |
    /// |f0 |f1 |f0 |f1 |f0 |f1 |f0 |f1 |
    /// |xyz|xyz|xyz|xyz|xyz|xyz|xyz|xyz|
    /// ```
    let accelerationBuffer: MTLBuffer
    
    /// Array of `boidCount * 3` floats containing 3D velocity vectors for each boid.
    let velocityBuffer: MTLBuffer
    
    /// Array of `boidCount * 3` floats containing 3D accumulated acceleration vectors for each boid.
    /// Populated by tick shader and used for visualization purposes
    let summedAccelerationBuffer: MTLBuffer
    
    /// Array of `teamCount * forceCount * boidCount` uint32_t containing the number of boids this force has been applied to
    ///
    /// Necessary for intermediate calculations.
    /// Format of array (b = boid, t = team, i = uint32_t):
    /// ```
    /// |b0             |b1             |
    /// |t0     |t1     |t0     |t1     |
    /// |i0 |i1 |i0 |i1 |i0 |i1 |i0 |i1 |
    /// ```
    let interactionCountBuffer: MTLBuffer
    
    /// Array of `boidCount` uint8_t containing the bitmask of forces applied between the "special boid" and the one at the index
    let interactionVisualizationBuffer: MTLBuffer
    
    init?(teams: [Team], forceCount: Int, device: MTLDevice) {
        self.teams = teams;
        
        let spawnDelta: Float = 0.25
        
        self.boidCount = teams.reduce(0) { $0 + $1.boidCount }
        self.forceCount = forceCount
        self.teamCount = teams.count
        
        let configurationBufferSize = boidCount * MemoryLayout<BoidConfiguration>.stride
        let positionBufferSize = boidCount * 3 * MemoryLayout<Float>.stride
        let accelerationBufferSize = teamCount * forceCount * boidCount * 3 * MemoryLayout<Float>.stride
        let velocityBufferSize = boidCount * 3 * MemoryLayout<Float>.stride
        let interactionCountBufferSize = teamCount * forceCount * boidCount * MemoryLayout<UInt32>.stride
        let interactionVisualizationBufferSize = boidCount * MemoryLayout<UInt8>.stride
        
        let positionBufferData: [Float] = (0..<boidCount).reduce(into: []) { accumulator, _ in
            let coordinate = [Float.random(in: -spawnDelta..<spawnDelta), Float.random(in: -spawnDelta..<spawnDelta), 0]
            accumulator.append(contentsOf: coordinate)
        }
        
        let configurationBufferData: [BoidConfiguration] = teams.enumerated().reduce(into: []) { accumulator, content in
            let (teamIndex, team) = content
            let configurations = (0..<team.boidCount).map { _ in BoidConfiguration(team, id: teamIndex) }
            accumulator.append(contentsOf: configurations)
        }
        
        let storageOptions: MTLResourceOptions = [.storageModePrivate]
        
        guard let configurationBuffer = device.makeBuffer(bytes: configurationBufferData, length: configurationBufferSize, options: []),
            let positionBuffer = device.makeBuffer(bytes: positionBufferData, length: positionBufferSize, options: []),
            let accelerationBuffer = device.makeBuffer(length: accelerationBufferSize, options: storageOptions),
            let velocityBuffer = device.makeBuffer(length: velocityBufferSize, options: storageOptions),
            let summedAccelerationBuffer = device.makeBuffer(length: velocityBufferSize, options: storageOptions),
            let interactionCountBuffer = device.makeBuffer(length: interactionCountBufferSize, options: storageOptions),
            let interactionVisualizationBuffer = device.makeBuffer(length: interactionVisualizationBufferSize, options: storageOptions)
        else {
            return nil
        }
        
        self.configurationBuffer = configurationBuffer
        self.positionBuffer = positionBuffer
        self.accelerationBuffer = accelerationBuffer
        self.velocityBuffer = velocityBuffer
        self.summedAccelerationBuffer = summedAccelerationBuffer
        self.interactionCountBuffer = interactionCountBuffer
        self.interactionVisualizationBuffer = interactionVisualizationBuffer
    }
}
