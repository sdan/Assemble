//
//  WindowPreviewView.swift
//  visionOS
//
//  Created by Saagar Jha on 10/10/23.
//

import SwiftUI

struct DisplayPreviewView: View {
	let remote: Remote
	let display: Display

	@Binding
	var selectedDisplay: Display?

	@State
	var preview: Frame?

	var body: some View {
		Button(action: {
			selectedDisplay = display
		}) {
			VStack(alignment: .leading) {
				let size = macOSInterface.M.WindowPreview.previewSize
				Group {
					if let preview {
						FrameView(frame: preview)
					} else {
						ProgressView {
							Text("Loading Preview…")
						}
					}
				}.frame(width: size.width, height: size.height)
                Text(display.name ?? "Unknown")
					.font(.title)
					.lineLimit(1)
                Text(display.name!)
					.lineLimit(1)
			}
		}
		.buttonBorderShape(.roundedRectangle)
		.task {
			do {
				// while true {
				guard let preview = try await remote.windowPreview(for: display.displayID) else {
					return
				}
				self.preview = preview
				// try await Task.sleep(for: .seconds(1))
				// }
			} catch {}
		}
	}
}
