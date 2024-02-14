//
//  Messages.swift
//  Shared
//
//  Created by Saagar Jha on 10/9/23.
//

import Foundation

enum Messages: UInt8, CaseIterable {
    static let version = Bundle.main.version
    case visionOSHandshake
    case macOSHandshake
    case displays
    case displayPreview
    case startStreaming
    case stopStreaming
    case displayFrame
    case displayMask
    case startWatchingForChildDisplays
    case stopWatchingForChildDisplays
    case childDisplays
    case mouseMoved
    case clicked
    case scrollBegan
    case scrollChanged
    case scrollEnded
    case dragBegan
    case dragChanged
    case dragEnded
    case typed
}

protocol Message {
    static var id: Messages { get }
    associatedtype Request: Serializable
    associatedtype Reply: Serializable
}

extension Message {
    static func send(_ parameters: Request, through connection: Multiplexer) async throws -> Reply {
        print("Sending message with ID: \(Self.id)")
        let reply = try await .decode(connection.sendWithReply(message: Self.id, data: parameters.encode()))
        print("Received reply for message with ID: \(Self.id)")
        return reply
    }
}

