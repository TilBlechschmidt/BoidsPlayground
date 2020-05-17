//
//  SimulationConfiguration.swift
//  BookCore
//
//  Created by Til Blechschmidt on 10.05.20.
//

import Foundation
import Combine

public struct VisualisationForces: OptionSet {
    public let rawValue: UInt8

    /// Visualise avoidance of neighbors
    public static let separation   = VisualisationForces(rawValue: 1 << 0)
    /// Visualise attraction to neighbors
    public static let cohesion     = VisualisationForces(rawValue: 1 << 1)
    /// Visualise alignment with neighbors
    public static let alignment    = VisualisationForces(rawValue: 1 << 2)

    public static let all: VisualisationForces = [.cohesion, .alignment, .separation]

    public init(rawValue: UInt8)  {
        self.rawValue  = rawValue
    }
}

/// Parameters that determine the simulation environment
public struct SimulationConfiguration: Codable, Hashable {
    /// Multiplicator for the speed of the environment
    public var simulationSpeed: Float = 1
    internal var metersPerPixel: Float = 0.01
    /// Determines the scaling of the environment
    public var scale: Float {
        get {
            return 1 / (metersPerPixel / 0.01)
        }
        set {
            metersPerPixel = (1 / newValue) * 0.01
        }
    }

    /// Enables the rule visualisation
    public var visualiseForces: Bool = false
    /// Sets which boid should be visualised
    public var visualisationBoidID: UInt = 0
    internal var visualisationBitmask: UInt8 = 0b11111111
    /// Sets which forces should be visualised
    public var visualisationForces: VisualisationForces {
        get {
            return VisualisationForces(rawValue: visualisationBitmask)
        }
        set {
            visualisationBitmask = newValue.rawValue
        }
    }


    /// How close fish can get to each other.
    /// A factor of 0 makes them keep a distance relative to their body size
    /// while a factor of 1 allows them to close in on each other further
    public var compressionFactor: Float = 1

    /// Effect radius of touch interaction
    public var touchRadius: Float = 5
    /// Strength of the touch interaction. Negative values reverse the effect!
    public var touchStrength: Float = 15

    public init() {}
}
