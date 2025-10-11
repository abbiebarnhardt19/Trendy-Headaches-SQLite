//
//  Custom Background Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/10/25.
//

import SwiftUI

struct AnalyticsBackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 12, amplitude: 20, accent: accent,  x: 100, y: -350, rotation: -50)
            SameAmplitudeBlob(waves: 13, amplitude: 15, accent: accent, x: 70, y: -300, rotation: 130)
        }
    }
}

struct ListBackgroundComponents: View {
    var background: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 90, y: -382, rotation: -10, width:screenWidth, height:180)
            SameAmplitudeBlob(waves: 4, amplitude: 16, accent: accent, x: 60, y: -285, rotation: 170, width:screenWidth, height:180)
        }
    }
}

struct LogBackgroundComponents: View {
    var background: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 7, amplitude: 8, accent: accent, x: 0, y: -430, width: screenWidth, height: 80)
                .zIndex(1)
            WavyTopBottomRectangle(waves: 7, amplitude: 8, accent: accent, x: 0, y: 355, width: screenWidth, height: 80)
                .zIndex(1)
        }
    }
}

struct ProfileBackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 15, amplitude: 11, accent: accent, x: 100, y: -395, rotation: -35)
                .zIndex(1)
            SameAmplitudeBlob(waves: 15, amplitude: 11, accent: accent, x: 265, y: -180, rotation: 145)
                .zIndex(1)
        }
    }
}

struct Create1BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 20, amplitude: 10, accent: accent, x: 300, y: -630, width: 1000, height: 400)
            WavyTopBottomRectangle(waves: 20, amplitude: 10, accent: accent, x: 300, y: 600, width: 1000, height: 400)
        }
    }
}

struct Create2BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 100, y: -220, rotation: -180)
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 100, y: -220, rotation: 360)
        }
    }
}

struct Create3BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 20, amplitude: 10, accent: accent, x: 300, y: -575, width: 1000, height: 400)
            WavyTopBottomRectangle(waves: 20, amplitude: 8, accent: accent, x: 300, y: 550, width: 1000, height: 400)
        }
    }
}

struct Forgot1BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 140, y: -200, rotation: 110)
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 280, y: -120, rotation: 290)
        }
    }
}

struct Forgot2BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            ParametricBlob(points: 40, amplitude: 0.075, x: -140, y: 270, rotation: 210, accent: accent)
            ParametricBlob(points: 40, amplitude: 0.075, x: 10, y: 500, rotation: 17, accent: accent)
        }
    }
}

struct Forgot3BackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            ParametricBlob(points: 45, amplitude: 0.075, x: -160, y: 440, rotation: 335, accent: accent)
            ParametricBlob(points: 45, amplitude: 0.075, x: 25, y: 350, rotation: 160, accent: accent)
        }
    }
}

struct InitialViewBackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 140, y: -220, rotation: 120)
            SameAmplitudeBlob(waves: 10, amplitude: 20, accent: accent, x: 140, y: -220, rotation: 295)
        }
    }
}

struct LoginBackgroundComponents: View {
    var background: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: background).ignoresSafeArea()
            ParametricBlob(points: 45, amplitude: 0.075, x: -100, y: 425, rotation: 195, accent: accent)
            ParametricBlob(points: 45, amplitude: 0.075, x: -30, y: 425, rotation: 30, accent: accent)
        }
    }
}
