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
let prey = Team(of: 2500, maximumVelocity: 25, size: 0.25, coloration: .velocity)
let predator = Team(of: 1, maximumVelocity: 50, size: 0.5)

interaction.add(prey)
interaction.add(predator)

interaction.addForces {
    prey.flock()
    predator.becomePredator(of: prey)
}

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
