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
config.simulationSpeed = 0.75
config.compressionFactor = 0
config.scale = 0.85

var interaction = InteractionConfiguration()
let fish = Team(of: 2500, coloration: .heading)
interaction.add(fish)

interaction.addForces {
    fish.flock()
}

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
