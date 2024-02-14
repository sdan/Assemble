//
//  Remote.swift
//  macOS
//
//  Created by Saagar Jha on 10/9/23.
//

import AppleConnect
import CoreGraphics
import CoreMedia

struct Remote: visionOSInterface {
	let connection: Multiplexer
	var name: String!

	init(connection: Connection) {
		let local = Local()
		self.connection = Multiplexer(connection: connection, localInterface: local)
		local.remote = self
	}

	mutating func handshake() async throws -> Bool {
		let handshake = try await _handshake(parameters: .init(version: Messages.version))
		guard handshake.version == Messages.version else {
			return false
		}
		name = handshake.name
		return true
	}

	func _handshake(parameters: M.MacOSHandshake.Request) async throws -> M.MacOSHandshake.Reply {
		try await M.MacOSHandshake.send(parameters, through: connection)
	}

	func displayFrame(forDisplayID displayID: CGDirectDisplayID, frame: Frame) async throws {
		_ = try await _displayFrame(parameters: .init(displayID: displayID, frame: frame))
	}

	func _displayFrame(parameters: M.DisplayFrame.Request) async throws -> M.DisplayFrame.Reply {
		try await M.DisplayFrame.send(parameters, through: connection)
	}

	func childDisplays(parent: CGDirectDisplayID, children: [CGDirectDisplayID]) async throws {
		_ = try await _childDisplays(parameters: .init(parent: parent, children: children))
	}

	func _childDisplays(parameters: M.ChildDisplays.Request) async throws -> M.ChildDisplays.Reply {
		try await M.ChildDisplays.send(parameters, through: connection)
	}
}
