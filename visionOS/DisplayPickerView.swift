//
//  DisplayPickerView.swift
//  visionOS
//
//  Created by Saagar Jha on 10/10/23.
//

import SwiftUI

struct DisplayPickerView: View {
	let remote: Remote

	@State
	var displays: [Display]?

	@Binding
	var selectedDisplay: Display?

	var body: some View {
		NavigationStack {
			if let displays {
				ScrollView {
					LazyVGrid(
						columns: [GridItem(), GridItem()],
						spacing: 20,
						content: {
							ForEach(displays) { display in
								DisplayPreviewView(remote: remote, display: display, selectedDisplay: $selectedDisplay)
							}
						}
					)
					.padding(20)
				}
				.navigationTitle("Select a display.")
			} else {
				Text("Loading displays…")
			}
		}
		.task {
			do {
				while true {
					displays = try await remote.displays.filter {
						!($0.title?.isEmpty ?? true) && $0.displayLayer == 0 /* NSWindow.Level.normal */
					}.sorted {
						$0.displayID < $1.displayID
					}
					try await Task.sleep(for: .seconds(1))
				}
			} catch {}
		}
	}
}
