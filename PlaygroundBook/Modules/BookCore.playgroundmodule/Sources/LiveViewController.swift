//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import SwiftUI
import PlaygroundSupport
import AVFoundation
import Combine

class AppState: ObservableObject {
    @Published var muted = false {
        didSet {
            PlaygroundKeyValueStore.current["muted"] = .boolean(muted)
        }
    }

    init() {
        if let keyValue = PlaygroundKeyValueStore.current["muted"], case .boolean(let muted) = keyValue {
            self.muted = muted
        }
    }
}

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    var state = AppState()

    let boidView = BoidMetalView()
    let parser = MessageParser()
    var controlView: some View {
        ControlView().environmentObject(state)
    }

    var player: AVAudioPlayer?
    var cancellable: AnyCancellable?

    /*
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    */

    /*
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    */

    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
        NSLog("Message: \(String(describing: message))")

        guard let value = parser.decode(message) else {
            return
        }

        switch value {
        case .configuration(let newConfig):
            push(configuration: newConfig)
            break
        case .interaction(let newInteraction):
            push(interaction: newInteraction)
            break
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(boidView)
        boidView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            boidView.topAnchor.constraint(equalTo: view.topAnchor),
            boidView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            boidView.leftAnchor.constraint(equalTo: view.leftAnchor),
            boidView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        let controlViewHost = UIHostingController(rootView: controlView)
        addChild(controlViewHost)
        view.addSubview(controlViewHost.view)
        controlViewHost.view.translatesAutoresizingMaskIntoConstraints = false
        controlViewHost.view.backgroundColor = .clear
        view.addConstraints([
            controlViewHost.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            controlViewHost.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            controlViewHost.view.widthAnchor.constraint(equalToConstant: 50),
            controlViewHost.view.heightAnchor.constraint(equalToConstant: 50)
        ])
        controlViewHost.didMove(toParent: self)

        loadSound()

        if !state.muted {
            player?.play()
        }

        cancellable = state.$muted.sink {
            if $0 {
                self.player?.setVolume(0, fadeDuration: 1)
            } else {
                self.player?.play()
                self.player?.setVolume(1, fadeDuration: 1)
            }
        }
    }

    public func push(configuration: SimulationConfiguration) {
        NSLog("Updating simulation configuration: \(configuration)")
        boidView.push(configuration: configuration)
    }

    public func push(interaction: InteractionConfiguration) {
        NSLog("Updating simulation interaction: \(interaction)")
        boidView.push(interaction: interaction)
    }

    func loadSound() {
        guard let url = Bundle.main.url(forResource: "Ambience", withExtension: "m4a") else {
            NSLog("Resource not found")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            player?.numberOfLoops = -1
            player?.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
}
