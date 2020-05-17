//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Contains classes/structs/enums/functions which are part of a module that is
//  automatically imported into user-editable code.
//

import BookCore

// Implement any classes/structs/enums/functions in the BookAPI module which you
// want to be automatically imported and visible for users on playground pages
// and in user modules.
//
// This is controlled via the book-level `UserAutoImportedAuxiliaryModules`
// Manifest.plist key.

// MARK: - Exposed types
/// Group of fish
public typealias Team = BookCore.Team

// MARK: - Constants
/// Object that controls the simulation
public var simulation = Simulation()

// MARK: - Functions
/// Add team to the simulation
public func add(_ team: Team) {
    simulation.interaction.add(team)
}

/// Add force to the simulation
public func addForces(_ forces: [ForceInteraction]) {
    simulation.interaction.addForces(forces)
}

/// Add multiple forces from a function builder
public func addForces(@ForceBuilder _ builder: () -> [ForceInteraction]) {
    simulation.interaction.addForces(builder())
}

/// Add single force from a function builder
public func addForces(@ForceBuilder _ builder: () -> ForceInteraction) {
    simulation.interaction.addForce(builder())
}

// MARK: - Variable shorthands
/// Forces that are visualised with red lines
public var visualisedForces: VisualisationForces {
    get {
        return simulation.configuration.visualisationForces
    }
    set {
        simulation.configuration.visualiseForces = true
        simulation.configuration.visualisationForces = newValue
    }
}

/// Strength of touch interaction
public var touchStrength: Float {
    get {
        return simulation.configuration.touchStrength
    }
    set {
        simulation.configuration.touchStrength = newValue
    }
}

/// Radius of touch interaction
public var touchRadius: Float {
    get {
        return simulation.configuration.touchRadius
    }
    set {
        simulation.configuration.touchRadius = newValue
    }
}
