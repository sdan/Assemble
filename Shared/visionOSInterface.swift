//
//  visionOSInterface.swift
//  Shared
//
//  Created by Saagar Jha on 10/9/23.
//

import CoreMedia
import Foundation

protocol visionOSInterface {
	typealias M = visionOSMessages

	func _handshake(parameters: M.MacOSHandshake.Request) async throws -> M.MacOSHandshake.Reply
	func _displayFrame(parameters: M.DisplayFrame.Request) async throws -> M.DisplayFrame.Reply
	func _childDisplays(parameters: M.ChildDisplays.Request) async throws -> M.ChildDisplays.Reply
}

enum visionOSMessages {
	struct MacOSHandshake: Message {
		static let id = Messages.macOSHandshake

		struct Request: Serializable, Codable {
			let version: Int
		}

		struct Reply: Serializable, Codable {
			let version: Int
			let name: String
		}
	}

	struct DisplayFrame: Message {
		static let id = Messages.displayFrame

		struct Request: Serializable {
			let displayID: Display.ID
			let frame: Frame

			func encode() async throws -> Data {
				return try await displayID.uleb128 + frame.encode()
			}

			static func decode(_ data: Data) async throws -> Self {
				var data = data
				return try await self.init(displayID: .init(uleb128: &data), frame: .decode(data))
			}
		}

		typealias Reply = SerializableVoid
	}

	struct ChildDisplays: Message {
		static let id = Messages.childDisplays

		struct Request: Serializable, Codable {
			let parent: Display.ID
			let children: [Display.ID]
		}

		typealias Reply = SerializableVoid
	}
}
