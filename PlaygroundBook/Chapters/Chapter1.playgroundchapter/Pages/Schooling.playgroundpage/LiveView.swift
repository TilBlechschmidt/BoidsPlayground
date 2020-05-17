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

var interaction = InteractionConfiguration()
let team1 = Team(of: 50, maximumVelocity: 25, size: 0.5)
interaction.add(team1)

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
