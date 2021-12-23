//
//  GameOfLifeMacOSView.swift
//  GameOfLife
//
//  Created by Julien Mulot on 22/12/2021.
//

import SwiftUI
import UniformTypeIdentifiers

let defaultDelay: TimeInterval = 1

struct macOSView: View {
    @State var sizeX = defaultSizeX
    @State var sizeY = defaultSizeY
    @State var grid = randomGrid(sizeX: defaultSizeX, sizeY: defaultSizeY)
    @State private var strX: String = String(defaultSizeX)
    @State private var strY: String = String(defaultSizeY)
    @State private var delay: TimeInterval = defaultDelay
    let colors: [Color] = [.black, .gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State var fgColor: Color = .black
    @State private var countGen = 0
    @State private var play: Bool = true
    @State private var gridSize: CGSize = .zero
    
    var body: some View {
      let timer = Timer.publish(every: delay, on: .main, in: .common).autoconnect()
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
                    Button(action: save2CSV) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    Button(action: loadCSV) {
                        Label("Load", systemImage: "square.and.arrow.up")
                    }
                    Slider(value: $delay, in: 0.01...2) {
                        Text("Delay: \(String(format: "%.2f", delay))s")
                    } minimumValueLabel: {
                        Text("0.01")
                    } maximumValueLabel: {
                        Text("2")
                    }
                }
                .padding()
                Spacer()
                HStack {
                    Text("Gen \(countGen)")
                        .font(.title)
                        .foregroundColor(fgColor)
                        .onTapGesture {
                            fgColor = colors.randomElement()!
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
