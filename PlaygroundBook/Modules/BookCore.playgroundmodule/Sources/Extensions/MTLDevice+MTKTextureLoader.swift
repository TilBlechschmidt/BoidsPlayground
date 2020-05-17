//
//  MTLDevice+MTKTextureLoader.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 17.02.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation
import MetalKit

extension MTLDevice {
    func makeTexture(from imageURL: URL) throws -> MTLTexture {
        let loader = MTKTextureLoader(device: self)
        
        let options: [MTKTextureLoader.Option : Any] = [
            MTKTextureLoader.Option.generateMipmaps: NSNumber(booleanLiteral: false),
            MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically,
            MTKTextureLoader.Option.SRGB: NSNumber(booleanLiteral: true)
        ]
        
        return try loader.newTexture(URL: imageURL, options: options)
    }
}
