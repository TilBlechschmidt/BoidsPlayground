//
//  Simulation.swift
//  BookCore
//
//  Created by Til Blechschmidt on 10.05.20.
//

import Foundation
import PlaygroundSupport
import BookCore

public class Simulation {
    private let encoder = JSONEncoder()
    private let remoteView: PlaygroundRemoteLiveViewProxy

    /// Parameters that determine the simulation environment
    public var configuration = SimulationConfiguration() {
        didSet {
            push(.configuration, data: try! encoder.encode(configuration))
        }
    }

    /// Contains teams and their interaction
    public var interaction = InteractionConfiguration() {
        didSet {
            push(.interaction, data: try! encoder.encode(interaction))
        }
    }

    internal init() {
        guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
            fatalError("Always-on live view not configured in this page's LiveView.swift.")
        }

        self.remoteView = remoteView
    }

    private func push(_ type: MessageType, data: Data) {
        let payload = [
            "type": PlaygroundValue.string(type.rawValue),
            "data": PlaygroundValue.data(data)
        ]

        NSLog("Pushing \(type.rawValue): \(String(data: data, encoding: .utf8) ?? "-")")

        remoteView.send(.dictionary(payload))
    }
}
