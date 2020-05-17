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
config.compressionFactor = 1
config.scale = 0.5

var interaction = InteractionConfiguration()
let team1 = Team(of: 1500, coloration: .velocity)
interaction.add(team1)

interaction.addForces {
    team1.flock()
}

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
