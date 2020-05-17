//#-hidden-code
simulation.configuration.compressionFactor = 0.5
simulation.configuration.scale = 0.75
//#-end-hidden-code
/*:
 Having one group of fish is nice and lends itself to observing the school's behavior. But having more fish with even more variety equals more fun, so let's add some more!

 In the previous chapter a default team has been added for you to keep things simple. The code for that looks a little bit like this:
 ```
 let team1 = Team(of: 250)
 add(team1)
 ```
 You can repeat this with different names multiple times and get multiple teams! In addition to the number of fish, there is a variety of other parameters that can be tweaked. Have a play with them below!

 * Note: All teams you add will have the three rules we previously used enabled by default on this page. You will learn how to do this yourself in a bit.
*/
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(identifier, show, .)
//#-code-completion(identifier, show, Team, init(of:), init(of:maximumVelocity:size:speedVariance:sizeVariance:coloration:))
//#-code-completion(description, show, "add(team: Team)")
//#-code-completion(identifier, show, heading, velocity, fixedColor, angleOfAttack)
//#-editable-code
// Team of really big fish
let bigTeam = Team(of: 25, size: 0.75)
add(bigTeam)

// Team of fast fish
let fastFish = Team(of: 75, maximumVelocity: 50)
add(fastFish)

// Team of rainbow-fish (can you tell what the color indicates?)
// Try changing the color using auto-completion!
let geckoFish = Team(of: 45, coloration: .heading)
add(geckoFish)

// Team of super fast, small chameleon fish that don't vary in speed
let weirdFish = Team(of: 50, maximumVelocity: 75, size: 0.25, speedVariance: 0, coloration: .heading)
add(weirdFish)
//#-end-editable-code


/*:
 You may notice that your teams of fish are currently not interacting with each other. They are not even moving out of the way of the other fish when they pass through them! That happens because all rules we added only affect fish in the same team. Let's change that on the [next page](@next)!

 * Important: You should **not** create teams bigger than 5.000 fish (it fries the simulation)!
*/
//#-hidden-code
simulation.interaction.teams.forEach {
    addForces($0.flock())
}
//#-end-hidden-code
