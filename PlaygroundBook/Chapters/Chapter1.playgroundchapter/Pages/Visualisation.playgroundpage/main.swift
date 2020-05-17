//#-hidden-code
simulation.configuration.compressionFactor = 0
simulation.configuration.scale = 0.5

let team1 = Team(of: 250, maximumVelocity: 25, size: 0.5)
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
/*:
 On the previous page, we introduced some new rules. But as you might have guessed your fish, much like their real-life counterparts, don't have a global vision. In fact, fish have a special organ that helps them sense the movement of other fish nearby!

 The rules we previously applied have a limited range and each individual fish can only interact with its immediate neighbors, yet the swarm manages to stay together since every fish follows the same rules! The fact that these three rules make the fish move much like one big fluid entity even though every individual fish only interacts with its close friends is called **emergent behaviour**. We will take a look at more behavioral patterns in a later chapter!

 For now, let's visualize how far each rule is actually reaching! First off we add our three rules from before and then choose which forces we want to show by setting `visualisedForces`.

 * Experiment:
 Try visualizing different forces by adding `.separation`, `.cohesion` and `.alignment` to the array (you can add multiple by putting a comma in between)!
*/
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, separation, cohesion, alignment)
//#-code-completion(identifier, show, separate(), follow(), align())
//#-editable-code
follow()
separate()
align()

visualisedForces = [.separation]
//#-end-editable-code


/*:
 In the [next chapter](@next) we will take a look at more ways to manipulate our simulation!
*/
