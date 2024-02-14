//
//  ScreenRecorder.swift
//  macOS
//
//  Created by Saagar Jha on 10/21/23.
//

import AVFoundation
import ScreenCaptureKit

actor ScreenRecorder {
	static let cacheDuration = Duration.seconds(1)

	var _displays = [UUID: SCDisplay]() // SCDisplay uses UUIDs for identification
    var _lastDisplayFetch = ContinuousClock.Instant.now.advanced(by: ScreenRecorder.cacheDuration * -2)

	func _updateDisplays(force: Bool = false) async throws {
        guard ContinuousClock.Instant.now - _lastDisplayFetch > Self.cacheDuration || force else {
            return
        }

//		 try await _windows = Dictionary(
//		 	uniqueKeysWithValues: SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: false).windows.map {
//		 		($0.windowID, $0)
//		 	})
//		 _lastWindowFetch = ContinuousClock.Instant.now
//
        
        let content = try await SCShareableContent.getShareableContent()
            _displays = Dictionary(uniqueKeysWithValues: content.displays.map { (generateUUID(for: $0), $0) })
            _lastDisplayFetch = ContinuousClock.Instant.now



	}

    // Change: Expose displays instead of windows
        var displays: [SCDisplay] {
            get async throws {
                try await _updateDisplays()
                return Array(_displays.values)
            }
        }
    
    // Change: Adapted method to look up displays by UUID
        func lookup(displayUUID: UUID) async throws -> SCDisplay? {
            if let display = _displays[displayUUID] {
                return display
            } else {
                try await _updateDisplays(force: true)
                return _displays[displayUUID]
            }
        }
    
    func generateUUID(for display: SCDisplay) -> UUID {
       // Simple Approach (Assumes displayIDs don't change during runtime)
       return UUID(uuidString: display.displayID.description)! // Or some other display-derived identity
    }
    
	static func streamConfiguration() -> SCStreamConfiguration {
		let configuration = SCStreamConfiguration()
		configuration.pixelFormat = kCVPixelFormatType_32BGRA
		return configuration
	}

    // Change: Method to take a screenshot of a display
    nonisolated func screenshot(display: SCDisplay, size: CGSize) async throws -> CMSampleBuffer? {
        let filter = SCContentFilter(display: display, excludingWindows: []) // Assuming you want to exclude no windows
        let configuration = Self.streamConfiguration()
        // Assuming full display size for simplicity; adjust as needed
        configuration.width = display.width
        configuration.height = display.height
        configuration.captureResolution = .nominal
        configuration.showsCursor = false
        
        // This call is made outside of the actor's isolated context
        return try await SCScreenshotManager.captureSampleBuffer(contentFilter: filter, configuration: configuration)
    }


	struct Stream {
		class Output: NSObject, SCStreamOutput {
			let continuation: AsyncStream<CMSampleBuffer>.Continuation

			init(continuation: AsyncStream<CMSampleBuffer>.Continuation) {
				self.continuation = continuation
			}

			func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
				continuation.yield(sampleBuffer)
			}
		}

		let (frames, continuation) = AsyncStream.makeStream(of: CMSampleBuffer.self, bufferingPolicy: .bufferingNewest(1))
		let output: Output
		let stream: SCStream

		init(window: SCWindow) async throws {
			let filter = SCContentFilter(desktopIndependentWindow: window)

			let configuration = ScreenRecorder.streamConfiguration()
			configuration.width = Int(window.frame.width * CGFloat(filter.pointPixelScale))
			configuration.height = Int(window.frame.height * CGFloat(filter.pointPixelScale))
			if #available(macOS 14.2, *) {
				configuration.includeChildWindows = SLSCopyAssociatedWindows == nil
			}
			configuration.showsCursor = false

			stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
			output = Output(continuation: continuation)
			try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: nil)
			try await stream.startCapture()
		}

		func stop() async {
			// This will throw an error if the window doesn't exist anymore
			try? await stream.stopCapture()
		}
	}

	var streams = [CGWindowID: Stream]()

	func stream(window: SCWindow) async throws -> AsyncStream<CMSampleBuffer> {
		let stream = try await Stream(window: window)
		streams[window.windowID] = stream
		return stream.frames
	}

	func stopStream(for windowID: CGWindowID) async {
		await streams.removeValue(forKey: windowID)!.stop()
	}

//	var childObservers = Set<CGWindowID>()
//
//	func watchForChildren(windowID: CGWindowID) -> AsyncStream<[CGWindowID]> {
//		let (stream, continuation) = AsyncStream.makeStream(of: [CGWindowID].self)
//		childObservers.insert(windowID)
//		Task {
//			while childObservers.contains(windowID) {
//				try await Task.sleep(for: .seconds(1))
//				var childWindows =
//					if let SLSCopyAssociatedWindows,
//						let SLSMainConnectionID
//					{
//						Set(SLSCopyAssociatedWindows(SLSMainConnectionID(), windowID) as? [CGWindowID] ?? [])
//					} else {
//						Set<CGWindowID>()
//					}
//				childWindows.remove(windowID)
//
//				let root = try await lookup(displayID: displayID)!
//				let overlays = try await windows.filter {
//					$0.owningApplication == root.owningApplication && $0.windowLayer > NSWindow.Level.normal.rawValue && $0.frame.intersects(root.frame)
//				}.map(\.windowID)
//
//				continuation.yield(Array(childWindows) + overlays)
//			}
//			continuation.finish()
//		}
//		return stream
//	}
//
//	func stopWatchingForChildren(windowID: CGWindowID) {
//		let result = childObservers.remove(windowID)
//		assert(result != nil)
//	}
}


extension SCShareableContent {
    static func getShareableContent() async throws -> SCShareableContent {
        try await withCheckedThrowingContinuation { continuation in
            SCShareableContent.getWithCompletionHandler { content, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let content = content {
                    continuation.resume(returning: content)
                } else {
                    // Consider creating a specific error for this case
                    continuation.resume(throwing: NSError(domain: "ScreenCaptureKitError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}
