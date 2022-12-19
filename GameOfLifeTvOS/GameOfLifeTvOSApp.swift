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
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                print("longpress")
            }
    }
    
    var body: some Scene {
        WindowGroup {
            TvOSView(refresh: refresh)
                .focusable(true)
                .highPriorityGesture(longPress)
                .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }) {
                    refresh.toggle()
                }
        }
    }
}
