//
//  MessageType.swift
//  BookCore
//
//  Created by Til Blechschmidt on 10.05.20.
//

import Foundation

public enum MessageType: String {
    case configuration
    case interaction
}

internal enum MessageValue {
    case configuration(SimulationConfiguration)
    case interaction(InteractionConfiguration)
}
