//
//  ForceConfiguration.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation

public struct ForceConfiguration: Codable, Hashable {
    let strength: Float
    let radius: Float
    let speedLimit: Float
    let falloff: Float
    let fieldOfView: Float
    let scaleWithPeers: Bool
    
    public static let disabled = ForceConfiguration(strength: 0, radius: 0, speedLimit: 0)
//    static let weak = ForceConfiguration(strength: 0.2, radius: 1, speedLimit: 0.5, falloff: 1)
//    static let normal = ForceConfiguration(strength: 1, radius: 1, speedLimit: 2, falloff: 1)
//    static let global = ForceConfiguration(strength: 0.1, radius: Float.infinity, speedLimit: 0.5, falloff: 0)

    /// Create a new force configuration
    public init(strength: Float, radius: Float, speedLimit: Float = 50, fieldOfView: Float = 1, scaleWithPeers: Bool = false) {
        self.strength = strength
        self.radius = radius
        self.speedLimit = speedLimit
        self.falloff = 1
        self.fieldOfView = fieldOfView
        self.scaleWithPeers = scaleWithPeers
    }
}
