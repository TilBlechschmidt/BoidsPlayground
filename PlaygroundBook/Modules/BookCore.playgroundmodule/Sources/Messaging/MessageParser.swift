//
//  MessageParser.swift
//  BookCore
//
//  Created by Til Blechschmidt on 10.05.20.
//

import Foundation
import PlaygroundSupport

struct MessageParser {
    let decoder = JSONDecoder()

    func decode(_ value: PlaygroundValue) -> MessageValue? {
        guard let dict = unwrapDictionary(from: value), let type = decodeType(from: dict), let data = dict["data"].flatMap({ unwrapData(from: $0) }) else {
            return nil
        }

        switch type {
        case .configuration:
            let config = try? decoder.decode(SimulationConfiguration.self, from: data)
            return config.flatMap { MessageValue.configuration($0) }

        case .interaction:
            let interaction = try? decoder.decode(InteractionConfiguration.self, from: data)
            return interaction.flatMap { MessageValue.interaction($0) }
        }
    }

    func decodeType(from dict: [String : PlaygroundValue]) -> MessageType? {
        guard let rawType = dict["type"] else {
            return nil
        }

        switch rawType {
        case .string(let rawType):
            return MessageType(rawValue: rawType)
        default:
            return nil
        }
    }

    func unwrapDictionary(from value: PlaygroundValue) -> [String : PlaygroundValue]? {
        switch value {
        case .dictionary(let dict):
            return dict
        default:
            return nil
        }
    }

    func unwrapData(from value: PlaygroundValue) -> Data? {
        switch value {
        case .data(let data):
            return data
        default:
            return nil
        }
    }
}
