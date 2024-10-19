//
//  ContentView.swift
//  GameOfLifeTvOS
//
//  Created by Julien Mulot on 22/12/2021.
//

import SwiftUI

let defaultDelay: TimeInterval = 0.5

struct TvOSView: View {
    @State var sizeX = defaultSizeX
    @State var sizeY = defaultSizeY
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    @State var viewGrid: Bool = false
    @State private var delay: TimeInterval = defaultDelay
    var refresh: Bool = false
    var reset: Bool = false
    private let timer = Timer.publish(every: defaultDelay, on: .main, in: .common).autoconnect()
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State var fgColor: Color = .black
    @State private var gridSize: CGSize = .zero
        
    var body: some View {
            ZStack {
                if (viewGrid) {
                    GridView(sizeX: sizeX, sizeY: sizeY)
                }
                GameOfLifeView(grid: $grid, sizeX: sizeX, sizeY: sizeY, color: fgColor)
                    .size(size: $gridSize)
                    .onReceive(timer) { _ in
                            let newgrid = evolve(grid)
                            if (!newgrid.elementsEqual(grid)) {
                                grid = newgrid
                            }
                        //print("reshesh: \(refresh)")
                    }
                    .onAppear() {
                        //print("Appear")
                        fgColor = colors.randomElement()!
                        if (gridSize != .zero) {
                            //print("Size is \(gridSize.width) x \(gridSize.height)")
                            sizeX = Int(gridSize.width / defaultBoxSpacing)
                            sizeY = Int(gridSize.height / defaultBoxSpacing)
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                        }
                    }
//                    .onLongPressGesture(minimumDuration: 0.01) {
//                        print("On Long Press Gesture")
//                        fgColor = colors.randomElement()!
//                    }
                    .onChange(of: refresh) { _ in
                        //print("reshesh: \(refresh)")
                        let index = ((colors.firstIndex(of: fgColor) ?? 0) + 1) >= colors.count ? 0 : ((colors.firstIndex(of: fgColor) ?? 0) + 1)
                        //fgColor = colors.randomElement()!
                        fgColor = colors[index]
                        //print("index: \(index) color: \(fgColor)")
                    }
                    .onChange(of: reset) { _ in
                        if (gridSize != .zero) {
                            //print("Size is \(gridSize.width) x \(gridSize.height)")
                            sizeX = Int(gridSize.width / defaultBoxSpacing)
                            sizeY = Int(gridSize.height / defaultBoxSpacing)
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                        }
                    }
            }
        }
}

struct TvOSView_Previews: PreviewProvider {
    static var previews: some View {
        TvOSView()
    }
}
