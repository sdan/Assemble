//
//  macOSInterface.swift
//  Shared
//
//  Created by Saagar Jha on 10/9/23.
//

import CoreMedia
import CryptoKit
import Foundation

protocol macOSInterface {
    typealias M = macOSInterfaceMessages

    func _handshake(parameters: M.VisionOSHandshake.Request) async throws -> M.VisionOSHandshake.Reply
    func _displays(parameters: M.Displays.Request) async throws -> M.Displays.Reply
    func _displayPreview(parameters: M.DisplayPreview.Request) async throws -> M.DisplayPreview.Reply
    func _startStreaming(parameters: M.StartStreaming.Request) async throws -> M.StartStreaming.Reply
    func _stopStreaming(parameters: M.StopStreaming.Request) async throws -> M.StopStreaming.Reply
    func _displaySettings(parameters: M.DisplaySettings.Request) async throws -> M.DisplaySettings.Reply
    func _startWatchingForDisplayChanges(parameters: M.StartWatchingForDisplayChanges.Request) async throws -> M.StartWatchingForDisplayChanges.Reply
    func _stopWatchingForDisplayChanges(parameters: M.StopWatchingForDisplayChanges.Request) async throws -> M.StopWatchingForDisplayChanges.Reply
    func _mouseMoved(parameters: M.MouseMoved.Request) async throws -> M.MouseMoved.Reply
    func _clicked(parameters: M.Clicked.Request) async throws -> M.Clicked.Reply
    func _scrollBegan(parameters: M.ScrollBegan.Request) async throws -> M.ScrollBegan.Reply
    func _scrollChanged(parameters: M.ScrollChanged.Request) async throws -> M.ScrollChanged.Reply
    func _scrollEnded(parameters: M.ScrollEnded.Request) async throws -> M.ScrollEnded.Reply
    func _dragBegan(parameters: M.DragBegan.Request) async throws -> M.DragBegan.Reply
    func _dragChanged(parameters: M.DragChanged.Request) async throws -> M.DragChanged.Reply
    func _dragEnded(parameters: M.DragEnded.Request) async throws -> M.DragEnded.Reply
    func _typed(parameters: M.Typed.Request) async throws -> M.Typed.Reply
}

struct Display: Codable, Identifiable {
    let displayID: CGDirectDisplayID
    let name: String?
    let frame: CGRect

    var id: CGDirectDisplayID {
        displayID
    }
}

enum macOSInterfaceMessages {
    struct VisionOSHandshake: Message {
        static let id = Messages.visionOSHandshake
        
        struct Request: Serializable, Codable {
            let version: Int
        }
        
        struct Reply: Serializable, Codable {
            let version: Int
            let name: String
        }
    }
    
    struct Displays: Message {
        static let id = Messages.displays
        
        typealias Request = SerializableVoid
        
        struct Reply: Serializable, Codable {
            let displays: [Display]
        }
    }
    
    struct DisplayPreview: Message {
        static let id = Messages.displayPreview
        static let previewSize = CGSize(width: 600, height: 400)
        
        struct Request: Serializable, Codable {
            let displayID: Display.ID
        }
        
        typealias Reply = Frame?
    }
    
    struct StartStreaming: Message {
        static let id = Messages.startStreaming
        
        struct Request: Serializable, Codable {
            let displayID: Display.ID
        }
        
        typealias Reply = SerializableVoid
    }
    
    struct StopStreaming: Message {
        static let id = Messages.stopStreaming
        
        struct Request: Serializable, Codable {
            let displayID: Display.ID
        }
        
        typealias Reply = SerializableVoid
    }
    
    struct DisplaySettings: Message {
        static let id = Messages.displaySettings
        
        struct Request: Serializable, Codable {
            let displayID: Display.ID
            let settings: CGVirtualDisplaySettings
        }
        
        typealias Reply = SerializableVoid
    }
    
    struct StartWatchingForDisplayChanges: Message {
        static let id = Messages.startWatchingForDisplayChanges
        
        struct Request: Serializable, Codable {
            let displayID: Display.ID
        }
        
        struct StopWatchingForDisplayChanges: Message {
        }
        
        struct StopWatchingForDisplayChanges: Message {
            static let id = Messages.stopWatchingForDisplayChanges
            
            struct Request: Serializable, Codable {
                let displayID: Display.ID
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct MouseMoved: Message {
            static let id = Messages.mouseMoved
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct Clicked: Message {
            static let id = Messages.clicked
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct ScrollBegan: Message {
            static let id = Messages.scrollBegan
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct ScrollChanged: Message {
            static let id = Messages.scrollChanged
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct ScrollEnded: Message {
            static let id = Messages.scrollEnded
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct DragBegan: Message {
            static let id = Messages.dragBegan
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct DragChanged: Message {
            static let id = Messages.dragChanged
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct DragEnded: Message {
            static let id = Messages.dragEnded
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                let x: CGFloat
                let y: CGFloat
            }
            
            typealias Reply = SerializableVoid
        }
        
        struct Typed: Message {
            static let id = Messages.typed
            
            struct Request: Serializable, Codable {
                let windowID: Window.ID
                
                let key: Key
                let down: Bool
            }
            
            typealias Reply = SerializableVoid
        }
    }
    
    
}
