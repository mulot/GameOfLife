//
//  ContentView.swift
//  GameOfLife
//
//  Created by Julien Mulot on 18/12/2021.
//

import SwiftUI

let defaultSizeX = 100
let defaultSizeY = 70
let defaultBoxSpacing: CGFloat = 10
//let testGrid = randomGrid(sizeX: 10, sizeY: 10)

extension View {
    func size(size: Binding<CGSize>) -> some View {
        ChildSizeReader(size: size) {
            self
        }
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    
    let content: () -> Content
    var body: some View {
        content().background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: proxy.size
                )
            })
            .onPreferenceChange(SizePreferenceKey.self) { preferences in
                self.size = preferences
            }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

struct GameOfLifeView: View {
    @Binding var grid: [[Int]]
    @State private var pt: CGPoint = .zero
    var sizeX = defaultSizeX
    var sizeY = defaultSizeY
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let boxSpacing:CGFloat = min(geometry.size.height / CGFloat(sizeY), geometry.size.width / CGFloat(sizeX))
#if os(macOS)
            let myGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded({
                self.pt = $0.startLocation
                //print("Tapped at: \(pt.x), \(pt.y) Box X: \(Int(pt.x/boxSpacing)) Box Y: \(Int(pt.y/boxSpacing)) Box val: \(grid[Int(pt.y/boxSpacing)][Int(pt.x/boxSpacing)])")
                if (grid[Int(pt.y/boxSpacing)][Int(pt.x/boxSpacing)] == 0) {
                    grid[Int(pt.y/boxSpacing)][Int(pt.x/boxSpacing)] = 1
                }
                else {
                    grid[Int(pt.y/boxSpacing)][Int(pt.x/boxSpacing)] = 0
                }
                //print("new box val: \(grid[Int(pt.y/boxSpacing)][Int(pt.x/boxSpacing)])")
            })
#elseif os(tvOS)
#endif
            if (sizeX > 0 && sizeY > 0) {
            Path { path in
                for y in (0...sizeY-1) {
                    for x in (0...sizeX-1) {
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
            .fill(color)
#if os(macOS)
            .gesture(myGesture)
#elseif os(tvOS)
#endif
            }
            //.background(.red)
        }
    }
}

struct GridView: View {
    var sizeX = defaultSizeX
    var sizeY = defaultSizeY
    
    var body: some View {
        GeometryReader { geometry in
            let boxSpacing:CGFloat = min(geometry.size.height / CGFloat(sizeY), geometry.size.width / CGFloat(sizeX))
            let numberOfHorizontalGridLines = sizeY
            let numberOfVerticalGridLines = sizeX
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


struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(sizeX: 20, sizeY: 10)
    }
}


struct GameOfLife_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GridView(sizeX: 20, sizeY: 10)
            //GameOfLifeView(grid: testGrid, color: .black)
        }
    }
}

