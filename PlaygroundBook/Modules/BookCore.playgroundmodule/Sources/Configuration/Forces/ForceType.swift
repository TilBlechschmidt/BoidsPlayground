//
//  Force.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 04.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation

public enum ForceType: Int, CaseIterable, Codable, Hashable {
    case separation = 0
    case cohesion = 1
    case alignment = 2
    
    public var defaultConfiguration: ForceConfiguration {
        switch self {
        case .separation:
            return .init(strength: 6, radius: 0.5, scaleWithPeers: true)
        case .cohesion:
            return .init(strength: 5, radius: 5)
        case .alignment:
            return .init(strength: 3, radius: 7)
        }
        
//        case .separation:
//            return .init(strength: 6, radius: 0.5, scaleWithPeers: true)
//        case .cohesion:
//            return .init(strength: 5, radius: 2)
//        case .alignment:
//            return .init(strength: 1, radius: 2.5)
    }
}
