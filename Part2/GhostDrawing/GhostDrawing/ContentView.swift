//
//  ContentView.swift
//  GhostDrawing
//
//  Created by Gyula Hatalyak on 2023. 09. 09..
//

import SwiftUI

struct ContentView: View {
    
    enum DrawingTool: CaseIterable, Identifiable {
        case red
        case blue
        case green
        case eraser
        var id: Self { self }
        
        // in sec
        var delay: Int {
            switch self {
            case .red:
                return 1
            case .blue:
                return 3
            case .green:
                return 5
            case .eraser:
                return 2
            }
        }
        
        var color: CGColor {
            switch self {
            case .red:
                return UIColor.red.cgColor
            case .blue:
                return UIColor.blue.cgColor
            case .green:
                return UIColor.green.cgColor
            case .eraser:
                return UIColor.lightGray.cgColor
            }
        }
    }
    
    @Environment(\.displayScale) var displayScale: CGFloat
    @State var scaleTransform: CGAffineTransform! // to scale up the point values to pixel values
    @State var canvasContainerSize: CGSize = .zero {
        didSet {
            print("new canvasContainerSize: \(canvasContainerSize)")
            createDrawingCanvas()
        }
    }
    @State private var selectedTool: DrawingTool = .red
    @StateObject private var drawingCanvas = DrawingCanvas()
    @State private var dragLocations = [(CGPoint, Date)]() // location-date pairs of a line (drag gesture)
    @GestureState private var isDragging = false // used to handle canceled drag gesture
    
    private func createDrawingCanvas() {
        let canvasPixelWidth = Int(canvasContainerSize.width * displayScale)
        drawingCanvas.createCanvas(pixelSize: CGSize(width: canvasPixelWidth,
                                                     height: canvasPixelWidth),
                                   bgColor: DrawingTool.eraser.color,
                                   lineWidth: 12)
    }
    
    func draw(_ dragLocations: [(CGPoint, Date)]) {
        let color = selectedTool.color
        Task {
            if dragLocations.count < 2 {
                return
            }
            for (index,dragLocation) in dragLocations.enumerated() {
                if index == 0 {
                    continue
                }
                let (location,date) = dragLocation
                let (prevLocation,prevDate) = dragLocations[index-1]
                let drawDelay = (index == 1) ? TimeInterval(selectedTool.delay) : date.timeIntervalSince(prevDate)
                // It is a suspension point that lets other line drawing to overlap.
                try? await Task.sleep(for:.seconds(drawDelay))
                drawingCanvas.addLine(startPoint: prevLocation.applying(scaleTransform), endPoint: location.applying(scaleTransform), color: color)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Ghost Drawing")
                .font(.title3)
            
            let dragGesture = DragGesture()
                .updating($isDragging, body: { value, state, transaction in
                    state = true
                })
                .onChanged({ value in
                    dragLocations.append((value.location, value.time))
                })
                // called only if gesture ended successfully
                .onEnded { value in
                    draw(dragLocations)
                }
            
            // Image to display the drawing canvas
            if let cgImage = drawingCanvas.cgImage {
                Image(decorative: cgImage, scale: displayScale)
                    .aspectRatio(contentMode: .fit)
                    .gesture(dragGesture)
                    // we are detecting canceled drag gesture this way to clean up the recorded drag locations
                    // called in case of both successful and canceled drag gesture
                    .onChange(of: isDragging) { newValue in
                        if newValue == false {
                            dragLocations.removeAll()
                        }
                    }
            }
            
            Picker("Color", selection: $selectedTool) {
                ForEach(DrawingTool.allCases) { tool in
                    Text(String(describing: tool).capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Button("Clear") {
                drawingCanvas.clear()
            }
            .padding()
            .buttonStyle(.bordered)
        }
        // measuring the container size the canvas should fit in
        .background(GeometryReader { proxy in
            Color.clear
                .onAppear {
                    canvasContainerSize = proxy.size
                }
        })
        .padding()
        .onAppear {
            scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, displayScale, displayScale)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
