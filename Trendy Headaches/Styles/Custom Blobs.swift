//
//  Blobs.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI
import Foundation

struct SameAmplitudeBlob: View {
    var waves: Int
    var amplitude: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    let seed = 4
    var width: CGFloat? = 700
    var height: CGFloat? = 500

    var body: some View {
        BlobShape(waves: waves, amplitude: amplitude, seed: seed)
            .fill(Color(hex: accent))
            .frame(width: width ?? 700, height: height ?? 500)
            .offset(x:x, y:y)
            .rotationEffect(.degrees(rotation))
    }

    private struct BlobShape: Shape {
        var waves: Int
        var amplitude: CGFloat
        var seed: Int

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let step = rect.width / CGFloat(waves)
            var rng = SeededGenerator(seed: seed)

            path.move(to: .zero)

            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step

                let midX = (startX + endX) / 2
                let midY = midX * (rect.height / rect.width)

                let controlAmp1 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let controlAmp2 = amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng))
                let direction: CGFloat = (i % 2 == 0 ? -1 : 1)

                let controlX1 = startX + step * 0.25
                let controlY1 = midY + direction * controlAmp1

                let controlX2 = startX + step * 0.75
                let controlY2 = midY + direction * controlAmp2

                path.addCurve(to: CGPoint(x: endX, y: endX * (rect.height / rect.width)), control1: CGPoint(x: controlX1, y: controlY1),  control2: CGPoint(x: controlX2, y: controlY2))
            }
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
            return path
        }
    }
}

struct WavyTopBottomRectangle: View {
    var waves: Int
    var amplitude: CGFloat
    var accent: String
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    let seed = 4

    var body: some View {
        let path: Path = {
            var path = Path()
            let step = width / CGFloat(waves)
            
            var rng = SeededGenerator(seed: seed)
            let topAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }
            let bottomAmps = (0..<waves).map { _ in amplitude * CGFloat(Double.random(in: 0.7...1.3, using: &rng)) }

            path.move(to: CGPoint(x: 0, y: height))

            for i in 0..<waves {
                let startX = CGFloat(i) * step
                let endX = startX + step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX + step * 0.25
                let controlY1 = height + direction * bottomAmps[i]

                let controlX2 = startX + step * 0.75
                let controlY2 = height + direction * bottomAmps[i]

                path.addCurve( to: CGPoint(x: endX, y: height), control1: CGPoint(x: controlX1, y: controlY1), control2: CGPoint(x: controlX2, y: controlY2))
            }

            path.addLine(to: CGPoint(x: width, y: 0))

            for i in (0..<waves).reversed() {
                let startX = CGFloat(i+1) * step
                let endX = startX - step
                let direction: CGFloat = (i % 2 == 0 ? 1 : -1)

                let controlX1 = startX - step * 0.25
                let controlY1 = 0 + direction * topAmps[i]

                let controlX2 = startX - step * 0.75
                let controlY2 = 0 + direction * topAmps[i]

                path.addCurve(to: CGPoint(x: endX, y: 0), control1: CGPoint(x: controlX1, y: controlY1), control2: CGPoint(x: controlX2, y: controlY2))
            }

            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
            
            return path
        }()

        return path
            .fill(Color(hex: accent))
            .frame(width: width, height: height)
            .offset(x: x, y: y)
    }
}

struct ParametricBlob: View {
    var points: Int = 20
    var amplitude: CGFloat
    var x: CGFloat
    var y: CGFloat
    var rotation: CGFloat
    var accent: String
    var width: CGFloat? = 500
    var height: CGFloat? = 600
    
    var body: some View {
        let rect = CGRect(x: 0, y: 0, width: width ?? 500, height: height ?? 600)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        
        let blobPath: Path = {
            var path = Path()
            var blobPoints: [CGPoint] = []
            
            for i in 0..<points {
                let angle = 2 * CGFloat.pi * CGFloat(i) / CGFloat(points)
                let offset = sin(CGFloat(i) * 2) * amplitude
                
                let x = center.x + (radiusX * (1 + offset)) * cos(angle)
                let y = center.y + (radiusY * (1 + offset)) * sin(angle)
                blobPoints.append(CGPoint(x: x, y: y))
            }
            
            if let first = blobPoints.first {
                path.move(to: first)
            }
            
            for i in 0..<points {
                let next = blobPoints[(i + 1) % points]
                let midX = (blobPoints[i].x + next.x) / 2
                let midY = (blobPoints[i].y + next.y) / 2
                let mid = CGPoint(x: midX, y: midY)
                
                path.addQuadCurve(to: mid, control: blobPoints[i])
            }
            
            path.closeSubpath()
            return path
        }()
        
        return blobPath
            .fill(Color(hex: accent))
            .frame(width: 400, height: 300)
            .offset(x: x, y: y)
            .rotationEffect(.degrees(rotation))
    }
}

// Reproducible random generator
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Int) { self.state = UInt64(seed) }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
