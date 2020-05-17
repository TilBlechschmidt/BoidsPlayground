//
//  SimulationController.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

public struct InteractionConfiguration: Codable, Hashable {
    let forceTypes: [ForceType]
    public private(set) var teams: [Team] = []
    public private(set) var interactions: [ForceInteraction] = []
    
    public init() {
        self.init(forceTypes: ForceType.allCases)
    }
    
    public init(forceTypes: [ForceType]) {
        self.forceTypes = forceTypes
    }
}

extension InteractionConfiguration {
    public mutating func add(_ team: Team) {
        guard !teams.contains(team) else {
            fatalError("Team already added")
        }
        teams.append(team)
    }
    
    public mutating func addForce(_ interaction: ForceInteraction) {
        guard teams.contains(where: { $0.uuid == interaction.teamID1 }) && teams.contains(where: { $0.uuid == interaction.teamID2 }) else {
            fatalError("Referenced team unknown")
        }
        
        interactions.append(interaction)
    }
    
    public mutating func addForces(_ forces: [ForceInteraction]) {
        forces.forEach { addForce($0) }
    }
    
    public mutating func addForces(@ForceBuilder _ builder: () -> [ForceInteraction]) {
        addForces(builder())
    }
    
    public mutating func addForces(@ForceBuilder _ builder: () -> ForceInteraction) {
        addForce(builder())
    }
}

// MARK: - Serialization for computation
extension InteractionConfiguration {
    internal func createComputeConfiguration(on device: MTLDevice) -> ForceComputeConfiguration? {
        let forceMatrix: TeamForceMatrix<ForceConfiguration> = TeamForceMatrix(teamCount: teams.count, defaultValue: .disabled)
        
        interactions.forEach { interaction in
            let team1Index = teams.firstIndex { $0.uuid == interaction.teamID1 }
            let team2Index = teams.firstIndex { $0.uuid == interaction.teamID2 }
            forceMatrix[team1Index!, team2Index!, interaction.type.rawValue] = interaction.configuration
        }
        
        return forceMatrix.createBuffer(on: device).flatMap { ForceComputeConfiguration(forceMatrix: $0) }
    }
    
    internal func createBoidState(on device: MTLDevice) -> BoidState? {
        BoidState(teams: teams, forceCount: forceTypes.count, device: device)
    }
}

extension InteractionConfiguration {
    public static var example: InteractionConfiguration {
        let team1 = Team(of: 50, maximumVelocity: 25, size: 0.25, coloration: .velocity)
//        let team2 = Team(of: 2, maximumVelocity: 50, size: 0.5)

        var interactionConfiguration = InteractionConfiguration()

        interactionConfiguration.add(team1)
//        interactionConfiguration.add(team2)

//        interactionConfiguration.addForces {
//            team1.flock()
//            team2.becomePredator(of: team1)
//            team2.flee(from: team2, configuration: .init(strength: 10, radius: 5))
//        }

        return interactionConfiguration
    }
}
