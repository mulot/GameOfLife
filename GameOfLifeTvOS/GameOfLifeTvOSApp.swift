//
//  GameOfLifeTvOSApp.swift
//  GameOfLifeTvOS
//
//  Created by Julien Mulot on 22/12/2021.
//

import SwiftUI

@main
struct GameOfLifeTvOSApp: App {
    @State var refresh: Bool = false
    @State var reset: Bool = false
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .onEnded { _ in
                print("longpress")
                reset.toggle()
            }
    }
    
    var body: some Scene {
        WindowGroup {
            TvOSView(refresh: refresh, reset: reset)
                .focusable(true)
                .highPriorityGesture(longPress)
                .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }) {
                    refresh.toggle()
                }
        }
    }
}
