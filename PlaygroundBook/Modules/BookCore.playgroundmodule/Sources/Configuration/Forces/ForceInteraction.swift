//
//  ForceInteraction.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation

public struct ForceInteraction: Codable, Hashable {
    let type: ForceType
    
    let teamID1: Team.ID
    let teamID2: Team.ID
    
    let configuration: ForceConfiguration
    
    init(type: ForceType, team1: Team, team2: Team, configuration: ForceConfiguration) {
        self.type = type
        self.teamID1 = team1.uuid
        self.teamID2 = team2.uuid
        self.configuration = configuration
    }
}

extension Team {
    /// Separate from neighboring fish
    public func flee(from other: Team, configuration: ForceConfiguration = ForceType.separation.defaultConfiguration) -> [ForceInteraction] {
        return [ForceInteraction(type: .separation, team1: self, team2: other, configuration: configuration)]
    }

    /// Follow neighboring fish
    public func chase(_ other: Team, configuration: ForceConfiguration = ForceType.cohesion.defaultConfiguration) -> [ForceInteraction] {
        return [ForceInteraction(type: .cohesion, team1: self, team2: other, configuration: configuration)]
    }

    /// Swim in the same direction
    public func align(with other: Team, configuration: ForceConfiguration = ForceType.alignment.defaultConfiguration) -> [ForceInteraction] {
        return [ForceInteraction(type: .alignment, team1: self, team2: other, configuration: configuration)]
    }

    /// Shortcut for all three forces
    public func flock() -> [ForceInteraction] {
        return self.flee(from: self) + self.chase(self) + self.align(with: self)
    }

    /// Chase other and make other flee
    public func becomePredator(of other: Team) -> [ForceInteraction] {
        return self.chase(other, configuration: .init(strength: 15, radius: 7, fieldOfView: 0.2))
            + other.flee(from: self, configuration: .init(strength: 30, radius: 4))
    }
}
