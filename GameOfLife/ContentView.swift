//
//  ContentView.swift
//  GameOfLife
//
//  Created by Julien Mulot on 18/12/2021.
//

import SwiftUI
import UniformTypeIdentifiers

let defaultSizeX = 100
let defaultSizeY = 70
//let testGrid = randomGrid(sizeX: 10, sizeY: 10)

struct ContentView: View {
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State var fgColor: Color = .black
    @State private var countGen = 0
    @State private var play: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Button( action: { play = !play }) {
                        Label("Play/Pause", systemImage: "playpause.fill")
                    }
                    Button(action: {
                        grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
                        countGen = 0
                    }) {
                        Label("Reset", systemImage: "restart")
                    }
                }
                .padding()
                Spacer()
            Text("Gen \(countGen)")
                .font(.title)
                .foregroundColor(fgColor)
                .onTapGesture {
                    fgColor = colors.randomElement()!
                }
                Spacer()
                HStack {
                    Button(action: save2CSV) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    Button(action: loadCSV) {
                        Label("Load", systemImage: "square.and.arrow.up")
                    }
                }
                .padding()
            }
            ZStack {
                GridView()
                GameOfLifeView(grid: $grid, color: fgColor)
                    .onAppear {
                        fgColor = colors.randomElement()!
                    }
                    .onReceive(timer) { _ in
                        if (play) {
                        let newgrid = evolve(grid)
                        if (!newgrid.elementsEqual(grid)) {
                            grid = newgrid
                            countGen += 1
                        }
                        }
                            else {
                                play = false
                            }
                        }
            }
        }
    }
    
    func save2CSV() {
       let panel = NSSavePanel()
        panel.allowedContentTypes = { [UTType.commaSeparatedText] }()
        panel.begin(completionHandler: { (result) in
            if (result == NSApplication.ModalResponse.OK && panel.url != nil) {
                var fileMgt: FileManager
                if #available(OSX 10.14, *) {
                    fileMgt = FileManager(authorization: NSWorkspace.Authorization())
                } else {
                    // Fallback on earlier versions
                    fileMgt = FileManager.default
                }
                fileMgt.createFile(atPath: panel.url!.path, contents: nil, attributes: nil)
                //var cvsData = NSMutableData.init(capacity: Constants.BUFFER_LINES)
                var cvsData = Data(capacity: 200000000)
                let cvsFile = FileHandle(forWritingAtPath: panel.url!.path)
                if (cvsFile != nil) {
                    var cvsStr = String()
                    for y in (0...defaultSizeY-1) {
                        for x in (0...defaultSizeX-1) {
                            cvsStr.append("\(grid[y][x]);")
                        }
                        cvsStr.append("\n")
                    }
                    cvsData.append(cvsStr.data(using: String.Encoding.ascii)!)
                    cvsFile!.write(cvsData)
                    cvsFile!.synchronizeFile()
                    cvsFile!.closeFile()
                }
            }
        }
        )
    }
    
    func loadCSV() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = { [UTType.commaSeparatedText] }()
        panel.begin(completionHandler: { (result) in
            if (result == NSApplication.ModalResponse.OK && panel.url != nil) {
                //print("open \(String(describing: panel.url))")
                do {
                    let savedData = try Data(contentsOf: panel.url!)
                    if let savedString = String(data: savedData, encoding: .ascii) {
                        grid = [[Int]].init(repeating: [Int].init(repeating: 0, count: defaultSizeX), count: defaultSizeY)
                        countGen = 0
                        //print(savedString)
                        var y = 0
                        for line in savedString.split(separator: "\n") {
                            //print("\(y)#: \(line)")
                            if (y > defaultSizeY-1) {
                                print("Y:\(y) y overflows")
                                break
                            }
                            var x = 0
                            for cell in line.split(separator: ";") {
                                //print("Y:\(y) X:\(x)#: \(cell)")
                                if (x > defaultSizeX-1) {
                                    print("X:\(x) Y:\(y) x overflows")
                                    break
                                }
                                grid[y][x] = Int(cell) ?? 0
                                x += 1
                                
                            }
                            y += 1
                        }
                    }
                }
                catch { print(error) }
            }
        })
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


struct GameOfLifeView: View {
    @Binding var grid: [[Int]]
    var color: Color
    @State private var pt: CGPoint = .zero
    var sizeX = defaultSizeX
    var sizeY = defaultSizeY
    
    var body: some View {
        
        GeometryReader { geometry in
            let boxSpacing:CGFloat = min(geometry.size.height / CGFloat(sizeY), geometry.size.width / CGFloat(sizeX))
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
            .gesture(myGesture)
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
            //GameOfLifeView(grid: testGrid, color: .black)
        }
    }
}

