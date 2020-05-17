//#-hidden-code
simulation.configuration.compressionFactor = 1
simulation.configuration.scale = 0.5
//#-end-hidden-code
/*:
 As previously mentioned you can interact with your pet fish by touching them. By default, this attracts them with a moderate force. You can try to split a swarm into multiple individual schools of fish or change its direction!

 This force, like many other things, can be configured to behave differently! You can change its strength and radius like this (those are the defaults):
 ```
 touchStrength = 15
 touchRadius = 5
 ```
 Try adding those to the code and playing around with them!

 **Hint:** What do you expect a negative strength to do?
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
//#-code-completion(identifier, show, touchRadius, touchStrength)
//#-editable-code
let team1 = Team(of: 1500, coloration: .velocity)
add(team1)

addForces {
    team1.flock()
}
//#-end-editable-code

//: When you have played with your fish head to the [next page](@next) to learn more on how you can change the environment!
