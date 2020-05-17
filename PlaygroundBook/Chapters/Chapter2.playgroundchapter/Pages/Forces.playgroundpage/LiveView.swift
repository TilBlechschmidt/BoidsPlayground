//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import BookCore
import PlaygroundSupport

var config = SimulationConfiguration()
config.compressionFactor = 0
config.scale = 0.5

var interaction = InteractionConfiguration()
let team1 = Team(of: 250)
interaction.add(team1)

let team2 = Team(of: 75, maximumVelocity: 50)
interaction.add(team2)

interaction.addForces {
    team1.flock()
    team2.flock()
}

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
