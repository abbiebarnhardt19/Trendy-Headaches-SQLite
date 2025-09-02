//
//  BlobTestingView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/2/25.
//

import SwiftUI

extension CGPoint {
    func scale(x xScale: CGFloat, y yScale: CGFloat) -> CGPoint {
        CGPoint(x: self.x * xScale, y: self.y * yScale)
    }
}

struct BlobTestingView: View {
    @State private var controlPoints = BlobShape.createPoints(minGrowth: 5, edges: 20)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // background

            BlobShape(controlPoints: controlPoints)
                .fill(Color.purple.opacity(0.5))
                .overlay(
                    BlobShape(controlPoints: controlPoints)
                        .stroke(Color.black, lineWidth: 2)
                )
                .frame(width: 400, height: 300)
        }
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
    static let size = CGFloat(300)
    
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


#Preview {
    BlobTestingView()
}

