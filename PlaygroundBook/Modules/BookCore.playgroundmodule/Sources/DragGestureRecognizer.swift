//
//  DragGestureRecognizer.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 06.05.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation

protocol DragGestureRecognizerDelegate: class {
    func dragGestureRecognizer(_ gestureRecognizer: DragGestureRecognizer, didUpdateTouches: [CGPoint])
}

#if os(iOS)
import UIKit

class DragGestureRecognizer: UIGestureRecognizer {
    private var activeTouches: Set<UITouch> = Set()

    weak var touchDelegate: DragGestureRecognizerDelegate?

    private func transformCoordinateSpace(of location: CGPoint) -> CGPoint {
        guard let viewSize = self.view?.bounds.size else {
            return .zero
        }

        return CGPoint(x: (location.x / viewSize.width) * 2 - 1, y: -((location.y / viewSize.height) * 2 - 1))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.forEach {
            activeTouches.insert($0)
        }

        touchesChanged()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.forEach {
            activeTouches.update(with: $0)
        }

        touchesChanged()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.forEach {
            activeTouches.remove($0)
        }

        touchesChanged()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touchesEnded(touches, with: event)
    }

    func touchesChanged() {
        let normalizedTouches = activeTouches.map {
            transformCoordinateSpace(of: $0.location(in: self.view))
        }

        touchDelegate?.dragGestureRecognizer(self, didUpdateTouches: normalizedTouches)
    }
}

#else
import AppKit

class DragGestureRecognizer: NSGestureRecognizer {
    weak var touchDelegate: DragGestureRecognizerDelegate?

    var touch: CGPoint? {
        didSet {
            touchDelegate?.dragGestureRecognizer(self, didUpdateTouches: touch.flatMap { [$0] } ?? [])
        }
    }

    private func transformCoordinateSpace(of location: CGPoint) -> CGPoint {
        guard let viewSize = self.view?.bounds.size else {
            return .zero
        }

        return CGPoint(x: (location.x / viewSize.width) * 2 - 1, y: (location.y / viewSize.height) * 2 - 1)
    }

    override func mouseDown(with event: NSEvent) {
        touch = transformCoordinateSpace(of: event.locationInWindow)
    }

    override func mouseDragged(with event: NSEvent) {
        touch = transformCoordinateSpace(of: event.locationInWindow)
    }

    override func mouseUp(with event: NSEvent) {
        touch = nil
    }
}
#endif
