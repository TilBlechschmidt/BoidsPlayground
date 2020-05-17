//#-hidden-code
simulation.configuration.compressionFactor = 0

let team1 = Team(of: 50, maximumVelocity: 25, size: 0.5)
add(team1)

/// Move towards nearby fish
func follow() {
    addForces(team1.chase(team1))
}

/// Keep a distance from nearby fish
func separate() {
    addForces(team1.flee(from: team1))
}

/// Swim in the same direction as nearby fish
func align() {
    addForces(team1.align(with: team1))
}
//#-end-hidden-code
//#-code-completion(everything, hide)
/*:
 To give the fish on the right some purpose in life lets provide them with some more rules!

 Below are some rules you can experiment with - try enabling different ones and look at the result. Remember that you can slowly step through your code to enable the rules one after another by pressing the gauge on the bottom left of the fish tank!

*/

/*:
 ## Cohesion

 First and foremost lets keep the fish together in one place!

 `
 if a fish is nearby { move towards it }
 `

 You can enable it with the command `follow()` - try typing it below!
*/
//#-code-completion(identifier, show, follow())
//#-editable-code

//#-end-editable-code

/*:
 ## Separation

 You might notice that your fish are now clumped together in a little blob. You can use a second rule to keep a distance to their neighbors and make the swarm a bit more spread out and realistic!

 `
 if a fish is too close { move away from it }
 `

 You can enable it with the command `separate()`!
*/
//#-code-completion(identifier, show, separate())
//#-editable-code

//#-end-editable-code

/*:
 ## Alignment

 Now you have a swarm of fish but they are just staying in one place and are still not behaving quite like the real deal. Let's add one final rule to unleash the magic and create a beautiful school!

 `
 swim in the same direction as my neighbor
 `

 You can enable it with the command `align()`!
*/
//#-code-completion(identifier, show, align())
//#-editable-code

//#-end-editable-code

//: When you have finished playing around with these rules you can turn to the [next page](@next) to visualize some of the rules that we added!
