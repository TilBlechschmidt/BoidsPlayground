//#-hidden-code
simulation.configuration.simulationSpeed = 0.75
//#-end-hidden-code
/*:
 The final showcase of emergent behavior will be obstacle avoidance! In the case of this simulation, the walls (and waves) are obstacles that have to be avoided. Below is an example of a **very** big swarm of fish that barely fits into the given space. Look closely how the swarm moves towards one corner of the tank and as the pressure increases a critical point is reached where seemingly the whole swarm changes direction at once. This happens even though some fish are far away from the wall and don't even know why they are changing direction!
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
//#-editable-code
let fish = Team(of: 2500, coloration: .heading)
add(fish)

addForces {
    fish.flock()
}

// Try playing with these parameters
simulation.configuration.compressionFactor = 0
simulation.configuration.scale = 0.85
//#-end-editable-code


//: When you got dizzy watching at the 🌈🐡 you can continue to the [last page](@next) of this playground!
