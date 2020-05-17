//#-hidden-code
import BookCore
//#-end-hidden-code

let smallTeam = Team(of: 25)
let largeTeam = Team(of: 2000)

let preyTeam = Team(of: 500, maximumVelocity: 25, size: 0.25)
let predatorTeam = Team(of: 2, maximumVelocity: 50, size: 0.5)
