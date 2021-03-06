//
//  ContentView.swift
//  GameOfLifeTvOS
//
//  Created by Julien Mulot on 22/12/2021.
//

import SwiftUI

let defaultDelay: TimeInterval = 1

struct TvOSView: View {
    @State var sizeX = defaultSizeX
    @State var sizeY = defaultSizeY
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    @State private var delay: TimeInterval = defaultDelay
    private let timer = Timer.publish(every: defaultDelay, on: .main, in: .common).autoconnect()
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State var fgColor: Color = .black
    @State private var gridSize: CGSize = .zero
    
    var body: some View {
            ZStack {
                GridView(sizeX: sizeX, sizeY: sizeY)
                GameOfLifeView(grid: $grid, sizeX: sizeX, sizeY: sizeY, color: fgColor)
                    .size(size: $gridSize)
                    .onReceive(timer) { _ in
                            let newgrid = evolve(grid)
                            if (!newgrid.elementsEqual(grid)) {
                                grid = newgrid
                            }
                    }
                    .onAppear() {
                        fgColor = colors.randomElement()!
                        if (gridSize != .zero) {
                            //print("Size is \(gridSize.width) x \(gridSize.height)")
                            sizeX = Int(gridSize.width / defaultBoxSpacing)
                            sizeY = Int(gridSize.height / defaultBoxSpacing)
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.01) {
                        fgColor = colors.randomElement()!
                    }
            }
        }
}

struct TvOSView_Previews: PreviewProvider {
    static var previews: some View {
        TvOSView()
    }
}
