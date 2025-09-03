//
//  BlobTestingView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/2/25.
//

//code from
// BlobMaker. (2021). GitHub  https: //github[dot]com/alldritt/BlobMaker/blob/main/Shared/ContentView.swift



import SwiftUI

extension CGPoint {
    func scale(x xScale: CGFloat, y yScale: CGFloat) -> CGPoint {
        CGPoint(x: self.x * xScale, y: self.y * yScale)
    }
}

struct BlobTestingView: View {
    @State private var controlPoints = BlobShape.createPoints(minGrowth: 8, edges: 80)

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlobShape(controlPoints: controlPoints)
                .fill(Color.green.opacity(0.6))
                .frame(width: 1000, height: 900)
                .offset(x: -200, y: -550)
            
            BlobShape(controlPoints: controlPoints)
                .fill(Color.green.opacity(0.6))
                .frame(width: 1000, height: 900)
                .offset(x: 200, y: 550)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        
        
    }
}



// MARK: - Shape Logic

struct AnimatableCGPointVector: VectorArithmetic {
    var values: [CGPoint]

    // Required by VectorArithmetic
    static var zero: AnimatableCGPointVector {
        AnimatableCGPointVector(values: [])
    }

    static func + (lhs: AnimatableCGPointVector, rhs: AnimatableCGPointVector) -> AnimatableCGPointVector {
        let values = zip(lhs.values, rhs.values).map { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return AnimatableCGPointVector(values: values)
    }

    static func - (lhs: AnimatableCGPointVector, rhs: AnimatableCGPointVector) -> AnimatableCGPointVector {
        let values = zip(lhs.values, rhs.values).map { CGPoint(x: $0.x - $1.x, y: $0.y - $1.y) }
        return AnimatableCGPointVector(values: values)
    }

    mutating func scale(by rhs: Double) {
        values = values.map { CGPoint(x: $0.x * rhs, y: $0.y * rhs) }
    }

    var magnitudeSquared: Double {
        values.reduce(0) { $0 + Double($1.x * $1.x + $1.y * $1.y) }
    }

    // Needed for SwiftUI to know how many points exist
    var count: Int { values.count }
}


struct BlobShape: Shape {
    static let size = CGFloat(1000)
    
    var controlPoints: AnimatableCGPointVector
    
    var animatableData: AnimatableCGPointVector {
        get { controlPoints }
        set { controlPoints = newValue }
    }

    static func createPoints(minGrowth: Int, edges: Int) -> AnimatableCGPointVector {
        func toRad(deg: CGFloat) -> CGFloat { deg * (.pi / 180) }
        func divide(count: Int) -> [CGFloat] {
            let deg = 360 / CGFloat(count)
            return (0..<count).map { CGFloat($0) * deg }
        }
        func magicPoint(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
            let radius = min + value * (max - min)
            if radius > max { return radius - min }
            if radius < min { return radius + min }
            return radius
        }
        func point(origin: CGFloat, radius: CGFloat, degree: CGFloat) -> CGPoint {
            let x = (origin + radius * cos(toRad(deg: degree))).rounded()
            let y = (origin + radius * sin(toRad(deg: degree))).rounded()
            return CGPoint(x: x, y: y)
        }

        let outerRad = Self.size / 2
        let innerRad = CGFloat(minGrowth) * (outerRad / 10)
        let center = Self.size / 2
        let slices = divide(count: edges)
        let points = slices.map { degree in
            let O = magicPoint(value: .random(in: 0...1),
                               min: innerRad,
                               max: outerRad)
            return point(origin: center, radius: O, degree: degree)
        }

        return AnimatableCGPointVector(values: points)
    }

    func path(in rect: CGRect) -> Path {
        let count = controlPoints.count
        guard count > 1 else { return Path() }
        let xScale = rect.width / Self.size
        let yScale = rect.height / Self.size
        let scaledPoints = controlPoints.values.map { p in
            p.scale(x: xScale, y: yScale)
        }

        var p = Path()
        p.move(to: CGPoint(x: (scaledPoints[0].x + scaledPoints[1].x) / 2,
                           y: (scaledPoints[0].y + scaledPoints[1].y) / 2))
        
        (0..<count).forEach { i in
            let p1 = scaledPoints[(i + 1) % count]
            let p2 = scaledPoints[(i + 2) % count]
            let midX = (p1.x + p2.x) / 2
            let midY = (p1.y + p2.y) / 2
            p.addQuadCurve(to: CGPoint(x: midX, y: midY), control: p1)
        }

        return p
    }

    
}

struct CornerBlobShape: Shape {
    static let size = CGFloat(1000)
    
    var controlPoints: AnimatableCGPointVector
    
    var animatableData: AnimatableCGPointVector {
        get { controlPoints }
        set { controlPoints = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let count = controlPoints.count
        guard count > 1 else { return Path() }
        
        let xScale = rect.width / Self.size
        let yScale = rect.height / Self.size
        let scaledPoints = controlPoints.values.map { p in
            p.scale(x: xScale, y: yScale)
        }
        
        var p = Path()
        
        // Start in top-left corner
        p.move(to: .zero)
        
        // Top edge (straight line)
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        // ---- Right + Bottom edges = wavy like BlobShape ----
        for i in 0..<count {
            let p1 = scaledPoints[(i + 1) % count]
            let p2 = scaledPoints[(i + 2) % count]
            let midX = (p1.x + p2.x) / 2
            let midY = (p1.y + p2.y) / 2
            p.addQuadCurve(to: CGPoint(x: midX, y: midY), control: p1)
        }
        
        // ---- Left edge (straight line back up) ----
        p.addLine(to: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: .zero)
        
        return p
    }
}


struct CornerWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start in the top-left
        path.move(to: .zero)
        
        // Top edge (straight line)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        // Right edge (curvy wave)
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4),
            control1: CGPoint(x: rect.maxX, y: rect.maxY * 0.1),
            control2: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.2)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY),
            control1: CGPoint(x: rect.maxX * 1.2, y: rect.maxY * 0),
            control2: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.9)
        )
        
        // Left edge (straight back up)
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: .zero)
        
        return path
    }
}

struct CornerMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start top-left
        path.move(to: .zero)
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom edge
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        // Left edge
        path.addLine(to: .zero)
        
        return path
    }
}




#Preview {
    BlobTestingView()
}

