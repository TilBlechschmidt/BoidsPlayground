//#-hidden-code
simulation.configuration.compressionFactor = 0
simulation.configuration.scale = 0.5
//#-end-hidden-code
/*:
 On the previous page, you have learned how to add different forces and how to make teams interact using said forces. However, there is more potential here! You can change some parameters on the forces you create like the strength and radius amongst others.
 ```
 team1.chase(team1, configuration: .init(strength: 5, radius: 5))
 ```
 - **strength** how potent the force is
 - **radius** range of the force in meters (a fish is ~0.5m big by default)
 - **speedLimit** limit the maximum acceleration the force can create
 - **fieldOfView** limits the vision (from 0 - 1)
 - **scaleWithPeers** whether or not the force scales with the number of fish it takes into account

 * Experiment: Add configurations with varying values to the forces and see how it affects the fish! Strength is usually between 3 - 6 and radius between 0.5 - 7 by default but you can try different values as you like.
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(identifier, show, .)
//#-code-completion(identifier, show, Team, init(of:), init(of:maximumVelocity:size:speedVariance:sizeVariance:coloration:))
//#-code-completion(identifier, show, add(:), addForces(:))
//#-code-completion(identifier, show, flock(), flee(from:), align(with:), chase(:))
//#-code-completion(identifier, show, flee(from:configuration:), align(with:configuration:), chase(:configuration:))
//#-code-completion(identifier, show, init(strength:radius:), init(strength:radius:speedLimit:fieldOfView:scaleWithPeers:))
//#-editable-code
let team1 = Team(of: 250)
add(team1)

addForces {
    team1.chase(team1)
    team1.flee(from: team1)
    team1.align(with: team1)
}
//#-end-editable-code


//: On the [next page](@next) you will learn how to change what happens when you touch your fish.
