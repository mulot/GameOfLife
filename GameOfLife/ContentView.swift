//
//  ContentView.swift
//  GameOfLife
//
//  Created by Julien Mulot on 18/12/2021.
//

import SwiftUI

let defaultSizeX = 100
let defaultSizeY = 70
let boxSpacing: CGFloat = 20
let testGrid = randomGrid(sizeX: 10, sizeY: 10)

struct ContentView: View {
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var countGen = 0
    
    var body: some View {
        VStack {
            Text("Gen \(countGen)")
                .font(.title)
                .foregroundColor(.blue)
            ZStack {
                GridView()
                GameOfLifeView(grid: grid)
                    .onReceive(timer) { _ in
                        let newgrid = evolve(grid)
                        if (!newgrid.elementsEqual(grid)) {
                            grid = newgrid
                            countGen += 1
                        }
                    }
                    .onTapGesture {
                        print("Tap")
                    }
            }
        }
    }
}

struct GridView: View {
    var body: some View {
        GeometryReader { geometry in
            let boxSpacing:CGFloat = min(geometry.size.height / CGFloat(defaultSizeY), geometry.size.width / CGFloat(defaultSizeX))
            let numberOfHorizontalGridLines = defaultSizeY
            let numberOfVerticalGridLines = defaultSizeX
            let height = CGFloat(numberOfHorizontalGridLines) * boxSpacing
            let width = CGFloat(numberOfVerticalGridLines) * boxSpacing
            Path { path in
                
                for index in 0...numberOfVerticalGridLines {
                    let vOffset: CGFloat = CGFloat(index) * boxSpacing
                    path.move(to: CGPoint(x: vOffset, y: 0))
                    path.addLine(to: CGPoint(x: vOffset, y: height))
                }
                for index in 0...numberOfHorizontalGridLines {
                    let hOffset: CGFloat = CGFloat(index) * boxSpacing
                    path.move(to: CGPoint(x: 0, y: hOffset))
                    path.addLine(to: CGPoint(x: width, y: hOffset))
                }
            }
            .stroke(Color.black)
            //.background(Color.blue)
            /*
             .onAppear()
             {
             print("geo height: \(geometry.size.height) geo width: \(geometry.size.width) boxSpacing: \(boxSpacing) #H lines: \(numberOfHorizontalGridLines) #V lines: \(numberOfVerticalGridLines) height: \(height) width: \(width)")
             }
             */
        }
        
    }
}


struct GameOfLifeView: View {
    var grid: [[Int]]
    
    var body: some View {
        GeometryReader { geometry in
            let boxSpacing:CGFloat = min(geometry.size.height / CGFloat(defaultSizeY), geometry.size.width / CGFloat(defaultSizeX))
            Path { path in
                for y in (0...defaultSizeY-1) {
                    for x in (0...defaultSizeX-1) {
                        if (grid[y][x] == 1) {
                            let hOffset: CGFloat = CGFloat(x) * boxSpacing
                            let vOffset: CGFloat = CGFloat(y) * boxSpacing
                            path.move(to: CGPoint(x: 0 + hOffset, y: 0 + vOffset))
                            path.addLine(to: CGPoint(x: boxSpacing + hOffset, y: 0 + vOffset))
                            path.addLine(to: CGPoint(x: boxSpacing + hOffset, y: boxSpacing + vOffset))
                            path.addLine(to: CGPoint(x: 0 + hOffset, y: boxSpacing + vOffset))
                        }
                    }
                }
            }
            .fill(Color.black)
            //.background(.red)
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}


struct GameOfLife_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GridView()
            GameOfLifeView(grid: testGrid)
        }
    }
}

