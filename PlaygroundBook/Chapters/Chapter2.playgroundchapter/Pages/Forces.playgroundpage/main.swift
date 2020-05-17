//#-hidden-code
simulation.configuration.compressionFactor = 0
simulation.configuration.scale = 0.5
//#-end-hidden-code
/*:
 To start off you have a basic setup below with two teams. You can create a new force that acts upon a team by calling a corresponding function on the team.
 ```
 let cohesionForce = team1.chase(team2)
 let separationForce = team2.flee(from: team1)
 let alignmentForce = team1.align(with: team1)
 ```
 To keep your code clean there is an additional function called `.flock()` which adds all three rules to one team! You can add the forces you created to the simulation by passing them to the `addForces` function by either calling it for each force you created or by passing them all at once.
 ```
 addForces(cohesionForce)
 addForces(alignmentForce)
 // or
 addForces {
    cohesionForce
    alignmentForce
 }
 ```

 * Experiment: Try making the two teams flock and avoid each other to prevent them from swimming through each other!
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(identifier, show, .)
//#-code-completion(identifier, show, Team, init(of:), init(of:maximumVelocity:size:speedVariance:sizeVariance:coloration:))
//#-code-completion(identifier, show, add(:), addForces(:))
//#-code-completion(identifier, show, flock(), flee(from:), align(with:), chase(:))
//#-editable-code
let team1 = Team(of: 250)
add(team1)

let team2 = Team(of: 75, maximumVelocity: 50)
add(team2)

addForces {
    team1.flock()
    team2.flock()
}
//#-end-editable-code


//: On the [next page](@next) you will learn how to modify the ranges, strength, and various other parameters on the forces you add!
