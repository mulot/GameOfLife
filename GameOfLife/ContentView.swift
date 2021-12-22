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

struct ContentView: View {
    @State var sizeX = defaultSizeX
    @State var sizeY = defaultSizeY
    @State private var strX: String = String(defaultSizeX)
    @State private var strY: String = String(defaultSizeY)
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State var fgColor: Color = .black
    @State private var countGen = 0
    @State private var play: Bool = true
    @State var gridSize: CGSize = .zero
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Button( action: { play = !play }) {
                        Label("Play/Pause", systemImage: "playpause.fill")
                    }
                    Button(action: {
                        grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                        countGen = 0
                    }) {
                        Label("Reset", systemImage: "restart")
                    }
                    TextField("Size X", text: $strX)
                        .fixedSize()
                        .onSubmit {
                            sizeX = Int(strX) ?? defaultSizeX
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                            countGen = 0
                        }
                    Text("x")
                    TextField("Size Y", text: $strY)
                        .fixedSize()
                        .onSubmit {
                            sizeY = Int(strY) ?? defaultSizeY
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                            countGen = 0
                        }
                    Button( action: {
                        if (gridSize != .zero) {
                            //print("Size is \(gridSize.width) x \(gridSize.height)")
                            sizeX = Int(gridSize.width / defaultBoxSpacing)
                            sizeY = Int(gridSize.height / defaultBoxSpacing)
                            strX = String(sizeX)
                            strY = String(sizeY)
                            grid = randomGrid(sizeX: sizeX, sizeY: sizeY)
                            countGen = 0
                        }
                    }) {
                        Label("Adapt", systemImage: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
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
                GridView(sizeX: sizeX, sizeY: sizeY)
                GameOfLifeView(grid: $grid, sizeX: sizeX, sizeY: sizeY, color: fgColor)
                    .size(size: $gridSize)
                    .onReceive(timer) { _ in
                        if (play) {
                            let newgrid = evolve(grid)
                            if (!newgrid.elementsEqual(grid)) {
                                grid = newgrid
                                countGen += 1
                            }
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
                    for y in (0...sizeY-1) {
                        for x in (0...sizeX-1) {
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
                        let yTabs = savedString.split(separator: "\n")
                        sizeY = yTabs.count
                        if (sizeY > 0) {
                            sizeX = yTabs[0].split(separator: ";").count
                        }
                        grid = [[Int]].init(repeating: [Int].init(repeating: 0, count: sizeX), count: sizeY)
                        countGen = 0
                        print("Tab by \(sizeX)x\(sizeY) loaded")
                        //print(savedString)
                        var y = 0
                        for line in yTabs {
                            //print("\(y)#: \(line)")
                            if (y > sizeY-1) {
                                print("Y:\(y) y overflows")
                                break
                            }
                            var x = 0
                            let xTabs = line.split(separator: ";")
                            for cell in xTabs {
                                //print("Y:\(y) X:\(x)#: \(cell)")
                                if (x > sizeX-1) {
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
    @State private var pt: CGPoint = .zero
    var sizeX = defaultSizeX
    var sizeY = defaultSizeY
    var color: Color
    
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

