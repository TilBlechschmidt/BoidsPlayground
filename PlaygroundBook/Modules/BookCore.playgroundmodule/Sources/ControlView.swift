//
//  ControlView.swift
//  BookCore
//
//  Created by Til Blechschmidt on 15.05.20.
//

import SwiftUI

struct ControlView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: toggleMute) {
            Circle()
                .fill(Color.clear)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: appState.muted ? "speaker.slash.fill" : "speaker.3.fill").foregroundColor(Color.blue)
                )
        }
            .background(Blur())
            .padding()
    }

    func toggleMute() {
        appState.muted = !appState.muted
    }
}
