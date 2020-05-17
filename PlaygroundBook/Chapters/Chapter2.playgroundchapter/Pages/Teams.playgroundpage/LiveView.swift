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
config.compressionFactor = 0.5
config.scale = 0.75

config.visualiseForces = true
config.visualisationForces = [.separation]

var interaction = InteractionConfiguration()

let bigTeam = Team(of: 25, size: 0.75)
interaction.add(bigTeam)

// Team of fast fish
let fastFish = Team(of: 75, maximumVelocity: 50)
interaction.add(fastFish)

// Team of rainbow-fish (can you tell what the color indicates?)
// Try changing the color using auto-completion!
let geckoFish = Team(of: 45, coloration: .heading)
interaction.add(geckoFish)

// Team of super fast, small chameleon fish that don't vary in speed
let weirdFish = Team(of: 50, maximumVelocity: 75, size: 0.25, speedVariance: 0, coloration: .heading)
interaction.add(weirdFish)

interaction.teams.forEach {
    interaction.addForces($0.flock())
}

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(config, interaction)
