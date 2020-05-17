/*:
 You have learned how to modify the teams, forces, and even your interaction with the fish. One thing that's left in your toolbox is a way to modify the environment!

 On the previous pages, you may have noticed that the size of the ocean changed or fish behaved slightly differently. This page tells you how to change these things yourself!

 On every page, there is an object called `simulation` which has a `.configuration` property with various variables that you can tweak! Here are some examples:
 - **compressionFactor** how close fish can get to each other (0 - 1)
 - **scale** modifier for the size of the simulation
 - **simulationSpeed** multiplier for the speed of the simulation

 You already learned about some others like `touchRadius`, `touchStrength`, and various visualisation flags on previous pages and have used shorthands to access them!
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
//#-code-completion(identifier, show, simulation, configuration, simulationSpeed, scale, visualiseForces, visualisationBoidID, visualisationForces, compressionFactor, touchRadius, touchStrength)
//#-editable-code
let team1 = Team(of: 1500, coloration: .velocity)
add(team1)

addForces {
    team1.flock()
}

simulation.configuration.compressionFactor = 1
simulation.configuration.scale = 0.5
//#-end-editable-code


//: When you are done experimenting with some of the simulation parameters head over to the [next chapter](@next) to put all your new tools to use! You will learn more about **emerging behavior** 🥳
