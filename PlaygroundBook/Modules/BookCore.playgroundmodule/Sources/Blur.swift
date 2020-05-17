//
//  Blur.swift
//  BookCore
//
//  Created by Til Blechschmidt on 15.05.20.
//

import SwiftUI

struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        effectView.layer.cornerRadius = 25;
        effectView.layer.masksToBounds = true;
        return effectView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
