/*:
 Previously **emergent behavior** was mentioned. Let's have a look at a specific example. Picture a big school of fish and a predator. When the predator gets close to the fish only a small amount of fish can actually see him and take evasive actions. Now think about how their neighbors in the swarm react to this. After a bit of time, the whole swarm changes direction and even splits to avoid the predator.

 Below you can find such a scenario with a predator and prey and the corresponding forces. To visualize the direction change of the swarm the coloration was set to `.velocity`.

 * Experiment:
 Try using touch interaction to make the predator attack the swarm head-on to see the "wave" of direction-change propagating through the swarm best. Make sure to also try changing the coloration to `.heading`!
*/
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(identifier, show, Team, init(of:), init(of:maximumVelocity:size:speedVariance:sizeVariance:coloration:))
//#-code-completion(identifier, show, add(:), addForces(:))
//#-code-completion(identifier, show, flock(), flee(from:), align(with:), chase(:))
//#-code-completion(identifier, show, flee(from:configuration:), align(with:configuration:), chase(:configuration:), becomePredator(of:))
//#-code-completion(identifier, show, init(strength:radius:), init(strength:radius:speedLimit:fieldOfView:scaleWithPeers:))
//#-code-completion(identifier, show, simulation, configuration, simulationSpeed, scale, visualiseForces, visualisationBoidID, visualisationForces, compressionFactor, touchRadius, touchStrength)
//#-code-completion(identifier, show, heading, velocity, fixedColor, angleOfAttack)
//#-editable-code
simulation.configuration.compressionFactor = 1
simulation.configuration.scale = 0.5

let prey = Team(of: 2500, maximumVelocity: 25, size: 0.25, coloration: .velocity)
let predator = Team(of: 1, maximumVelocity: 50, size: 0.5)

add(prey)
add(predator)

addForces {
    prey.flock()
    predator.becomePredator(of: prey)
}
//#-end-editable-code


//: Head over to the [next page](@next) to learn a different example of emergent behaviour
