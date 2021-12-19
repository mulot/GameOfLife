//
//  ContentView.swift
//  GameOfLife
//
//  Created by Julien Mulot on 18/12/2021.
//

import SwiftUI

let sizeX = 60
let sizeY = 40
let initGrid = [[Int]].init(repeating: [Int].init(repeating: 0, count: sizeX), count: sizeY)
let testGrid = randomizeGrid(initGrid)

struct ContentView: View {
    @State var grid = randomizeGrid(initGrid)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var countGen = 0
    
    var body: some View {
        Text("\(countGen)")
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
        }
    }
}

struct GridView: View {
    var horizontalSpacing: CGFloat = 20
    var verticalSpacing: CGFloat = 20
    //var numberOfVerticalGridLines = 15
    //var numberOfHorizontalGridLines = 10
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let numberOfHorizontalGridLines = Int(geometry.size.height / self.verticalSpacing)
                 let numberOfVerticalGridLines = Int(geometry.size.width / self.horizontalSpacing)
                for index in 0...numberOfVerticalGridLines {
                    let vOffset: CGFloat = CGFloat(index) * self.horizontalSpacing
                    path.move(to: CGPoint(x: vOffset, y: 0))
                    path.addLine(to: CGPoint(x: vOffset, y: geometry.size.height))
                }
                for index in 0...numberOfHorizontalGridLines {
                    let hOffset: CGFloat = CGFloat(index) * self.verticalSpacing
                    path.move(to: CGPoint(x: 0, y: hOffset))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: hOffset))
                }
            }
            .stroke(Color.black)
        }
    }
}


struct GameOfLifeView: View {
    var grid: [[Int]]
    var horizontalSpacing: CGFloat = 20
    var verticalSpacing: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let sizeY = grid.count
                let sizeX = grid[0].count
                for y in (0...sizeY-1) {
                    for x in (0...sizeX-1) {
                        if (grid[y][x] == 1) {
                            let hOffset: CGFloat = CGFloat(x) * horizontalSpacing
                            let vOffset: CGFloat = CGFloat(y) * verticalSpacing
                            path.move(to: CGPoint(x: 0 + hOffset, y: 0 + vOffset))
                            path.addLine(to: CGPoint(x: horizontalSpacing + hOffset, y: 0 + vOffset))
                            path.addLine(to: CGPoint(x: horizontalSpacing + hOffset, y: verticalSpacing + vOffset))
                            path.addLine(to: CGPoint(x: 0 + hOffset, y: verticalSpacing + vOffset))
                        }
                    }
                }
            }
            .fill(Color.black)
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

