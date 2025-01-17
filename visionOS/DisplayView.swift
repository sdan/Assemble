//
//  WindowView.swift
//  visionOS
//
//  Created by Saagar Jha on 10/10/23.
//

import SwiftUI

struct DisplayView: View {
	let remote: Remote
	let window: Display

	@State
	var frame: Frame?

	let eventView = EventView()
	let decoder = VideoDecoder()

	var body: some View {
		Group {
			if let frame {
				GeometryReader { geometry in
					FrameView(frame: frame)
						.overlay {
							eventView
								.task {
									do {
										for await event in eventView.coordinator.scrollStream {
											switch event {
												case .began:
													_ = try await remote._scrollBegan(parameters: .init(windowID: window.displayID))
												case .changed(let translation):
													_ = try await remote._scrollChanged(parameters: .init(windowID: window.displayID, x: translation.x, y: translation.y))
												case .ended:
													_ = try await remote._scrollEnded(parameters: .init(windowID: window.displayID))
											}
										}
									} catch {}
								}
								.task {
									do {
										for await event in eventView.coordinator.dragStream {
											switch event {
												case .began(let translation):
													_ = try await remote._dragBegan(parameters: .init(windowID: window.displayID, x: translation.x, y: translation.y))
												case .changed(let translation):
													_ = try await remote._dragChanged(parameters: .init(windowID: window.displayID, x: translation.x, y: translation.y))
												case .ended(let translation):
													_ = try await remote._dragEnded(parameters: .init(windowID: window.displayID, x: translation.x, y: translation.y))
											}
										}
									} catch {}
								}
								.task {
									do {
										for await (key, down) in eventView.view.keyStream {
											_ = try await remote._typed(parameters: .init(windowID: window.displayID, key: key, down: down))
										}
									} catch {}
								}
						}
						.onTapGesture { location in
							eventView.view.becomeFirstResponder()
							Task {
								_ = try await remote._clicked(parameters: .init(windowID: window.displayID, x: location.x / geometry.size.width, y: location.y / geometry.size.height))
							}
						}
						.onContinuousHover(coordinateSpace: .local) {
							switch $0 {
								case .active(let location):
									Task {
										do {
											_ = try await remote._mouseMoved(parameters: .init(windowID: window.displayID, x: location.x / geometry.size.width, y: location.y / geometry.size.height))
										} catch {}
									}
								default:
									break
							}
						}
						.onAppear {
							eventView.view.becomeFirstResponder()
						}
				}
			} else {
				Text("Loading…")
			}
		}
		.task {
			do {
				for await frame in try await remote.startCasting(for: window.displayID) {
					self.frame = frame
				}
			} catch {}
		}
	}
}
