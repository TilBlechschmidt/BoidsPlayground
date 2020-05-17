/*:
 You made it to the end! 🎉

 Thanks for having a look at my playground! I hope you learned something about fish, birds, humans and their behavior and think about it the next time you see some starlings overhead or while scuba diving in the deep sea 🤿

 Below you have a clean slate to explore the behavior of fish even further! Note that almost all commands you learned throughout the book can be used on previous pages (although auto-completion may be disabled for introductory purposes). Make sure to use Modules (📄 in the top left) if you want to write more complex simulations or even combine them!

 **Hint:** You might want to expand the view on the right to embrace its 🌈 glory :D

 If you are interested in the topic and would like to read more about it you can read/watch the resources below.

 - Original research by [Craig Reynolds](http://www.red3d.com/cwr/boids/) from 1986
 - Recent video by [SmarterEveryDay](https://www.youtube.com/watch?v=4LWmRuB-uNU) on the topic
*/
//#-editable-code
let fish = Team(of: 5000, coloration: .heading)
add(fish)

addForces {
    fish.flock()
}

simulation.configuration.simulationSpeed = 0.5
simulation.configuration.scale = 0.4
simulation.configuration.compressionFactor = 0
//#-end-editable-code
