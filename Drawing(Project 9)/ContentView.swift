//
//  ContentView.swift
//  Drawing(Project 9)
//
//  Created by mac on 04.04.2023.
//

import SwiftUI

struct Arrow: Shape {
    var amount: Double
    var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX+amount/2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX-amount/2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX-amount/2, y: rect.maxY/3*2))
        path.addLine(to: CGPoint(x: rect.midX-amount*3/2, y: rect.maxY/3*2))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY+amount*3/2))
        path.addLine(to: CGPoint(x: rect.midX+amount*3/2, y: rect.maxY/3*2))
        path.addLine(to: CGPoint(x: rect.midX+amount/2, y: rect.maxY/3*2))

        return path
    }
}

struct Arc: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var insetAmount = 0.0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

struct Flower: Shape {
    
    var petalOffset: Double = -20

    
    var petalWidth: Double = 100

    func path(in rect: CGRect) -> Path {
     
        var path = Path()

        
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8) {
          
            let rotation = CGAffineTransform(rotationAngle: number)

            
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))

            
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width / 2))

            
            let rotatedPetal = originalPetal.applying(position)

        
            path.addPath(rotatedPetal)
        }

    
        return path
    }
}

struct FlowerContentView: View {
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0

    var body: some View {
        VStack {
            Flower(petalOffset: petalOffset, petalWidth: petalWidth)
                .fill(.red, style: FillStyle(eoFill: true))

            Text("Offset")
            Slider(value: $petalOffset, in: -40...40)
                .padding([.horizontal, .bottom])

            Text("Width")
            Slider(value: $petalWidth, in: 0...100)
                .padding(.horizontal)
        }
    }
}


struct BlendModesContentView: View {
    @State private var amount = 0.0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(.red)
                    .frame(width: 200 * amount)
                    .offset(x: -50, y: -80)
                    .blendMode(.screen)

                Circle()
                    .fill(.green)
                    .frame(width: 200 * amount)
                    .offset(x: 50, y: -80)
                    .blendMode(.screen)

                Circle()
                    .fill(.blue)
                    .frame(width: 200 * amount)
                    .blendMode(.screen)
            }
            .frame(width: 300, height: 300)

            Slider(value: $amount)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .ignoresSafeArea()
    }
}

struct Trapezoid: Shape {
    var insetAmount: Double

    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))

        return path
   }
}

struct TrapezoidContentView: View {
    @State private var insetAmount = 50.0

    var body: some View {
        Trapezoid(insetAmount: insetAmount)
            .frame(width: 200, height: 100)
            .onTapGesture {
                withAnimation {
                    insetAmount = Double.random(in: 10...90)
                }
            }
    }
}

struct Checkerboard: Shape {
    var rows: Int
    var columns: Int

    var animatableData: AnimatablePair<Double, Double> {
        get {
           AnimatablePair(Double(rows), Double(columns))
        }

        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // figure out how big each row/column needs to be
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)

        // loop over all rows and columns, making alternating squares colored
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    // this square should be colored; add a rectangle here
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)

                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }

        return path
    }
}

struct CheckerboardContentView: View {
    @State private var rows = 4
    @State private var columns = 4

    var body: some View {
        Checkerboard(rows: rows, columns: columns)
            .onTapGesture {
                withAnimation(.linear(duration: 3)) {
                    rows = 8
                    columns = 16
                }
            }
    }
}

struct Spirograph: Shape {
    let innerRadius: Int
    let outerRadius: Int
    let distance: Int
    let amount: Double

    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b

        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }

        return a
    }

    func path(in rect: CGRect) -> Path {
        let divisor = gcd(innerRadius, outerRadius)
        let outerRadius = Double(self.outerRadius)
        let innerRadius = Double(self.innerRadius)
        let distance = Double(self.distance)
        let difference = innerRadius - outerRadius
        let endPoint = ceil(2 * Double.pi * outerRadius / Double(divisor)) * amount

        var path = Path()

        for theta in stride(from: 0, through: endPoint, by: 0.01) {
            var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
            var y = difference * sin(theta) - distance * sin(difference / outerRadius * theta)

            x += rect.width / 2
            y += rect.height / 2

            if theta == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path

    }
}

struct ArowContentView: View {
    @State private var amount: Double = 50.0

 var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Arrow(amount: amount)
                .frame(width: 300, height: 300)
               .onTapGesture {
                    withAnimation {
                        amount = Double.random(in: 50...130)
                    }
                }
            
        }
    }
}
struct ColorCyclingRectangle: View {
    var bottom = 0.2
    var top = 0.2
    var left = 0.2
    var right = 0.2
    var steps = 100
    var amount = 0.0
    var amount1 = 0.0
 
    var body: some View {
        ZStack {
            
                Rectangle()
                    .inset(by: Double())
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: color(brightness: 1), location: 1),
                                
                                    .init(color: color1(brightness: 1), location: 0)
                                      ],
                            startPoint: UnitPoint(x: top, y: left),
                            endPoint: UnitPoint(x: bottom, y: right)
                        )
                        
                    )
            
        }
        .drawingGroup()
    }

    func color(brightness: Double) -> Color {
        var targetHue = Double() / Double(steps) + amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
    func color1(brightness: Double) -> Color {
        var targetHue = Double() / Double(steps) + amount1

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct ContentView: View {
    @State private var colorCycle = 0.0
    @State private var colorCycle1 = 0.0
    @State private    var bottom = 0.2
    @State private   var top = 0.2
    @State private var left = 0.2
    @State private  var right = 0.2
    
    var body: some View {
        VStack {
            ColorCyclingRectangle(bottom: bottom, top: top, left: left, right: right, amount: colorCycle, amount1: colorCycle1   )
                .frame(width: 300, height: 300)

            Slider(value: $colorCycle)
            Slider(value: $colorCycle1)
            Slider(value: $top)
            Slider(value: $left)
            Slider(value: $bottom)
            Slider(value: $right)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

