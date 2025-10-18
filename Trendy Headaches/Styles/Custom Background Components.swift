//
//  Custom bg Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/10/25.
//

import SwiftUI

struct AnalyticsBGComps: View {
    var bg: String
    var accent: String

    var body: some View {
            Color(hex: bg).ignoresSafeArea()
//            SameAmplitudeBlob(waves: 12, amp: 15, accent: accent,  x: 100, y: -380, rotation: -48)
        SameAmplitudeBlob(waves: 10, amp: 20, accent: accent,  x: UIScreen.main.bounds.height * 0.425, y: -UIScreen.main.bounds.width * 0.32, rotation:295, width: UIScreen.main.bounds.width)
            .zIndex(5)
        SameAmplitudeBlob(waves: 10, amp: 20, accent: accent,  x: UIScreen.main.bounds.height * 0.29, y: -UIScreen.main.bounds.width * 0.25, rotation:117, width: UIScreen.main.bounds.width)
            .zIndex(5)
    }
}

struct ListBGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
//            SameAmplitudeBlob(waves: 4, amp: 20, accent: accent, x: 90, y: -382, rotation: -10, width:screenWidth, height:180)
//            SameAmplitudeBlob(waves: 4, amp: 16, accent: accent, x: 60, y: -285, rotation: 170, width:screenWidth, height:180)
            
            SameAmplitudeBlob(waves: 5, amp: 12, accent: accent, x: -UIScreen.main.bounds.width * 0.1, y: -UIScreen.main.bounds.height * 0.47, rotation: 0, width:UIScreen.main.bounds.width+70, height:UIScreen.main.bounds.height*0.15)
            
            SameAmplitudeBlob(waves: 5, amp: 15, accent: accent, x: -UIScreen.main.bounds.width * 0.1, y: -UIScreen.main.bounds.height * 0.335, rotation: 180, width:UIScreen.main.bounds.width+70, height:UIScreen.main.bounds.height*0.125)
        }
    }
}

struct LogBGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        Color(hex: bg).ignoresSafeArea()
        WavyTopBottomRectangle(waves: 7, amp: 10, accent: accent, x: 0, y: -UIScreen.main.bounds.height * 0.64, width: screenWidth, height: UIScreen.main.bounds.height * 0.35)
                .zIndex(5)
            WavyTopBottomRectangle(waves: 7, amp: 8, accent: accent, x: 0, y: UIScreen.main.bounds.height * 0.41, width: screenWidth, height: 80)
                .zIndex(1)
    }
}

struct ProfileBGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 7, amp: 10, accent: accent, x: 0, y: -UIScreen.main.bounds.height * 0.625, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
                    .zIndex(5)
                WavyTopBottomRectangle(waves: 7, amp: 8, accent: accent, x: 0, y: UIScreen.main.bounds.height * 0.395, width: UIScreen.main.bounds.width, height: 80)
                    .zIndex(1)
        }
    }
}

struct Create1BGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 8, amp: 8, accent: accent, x: 0, y: -430, width: screenWidth, height: 80)
            WavyTopBottomRectangle(waves: 8, amp: 8, accent: accent, x: 0, y: 420, width: screenWidth, height: 80)
        }
    }
}

struct Create2BGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 100, y: -220, rotation: -180)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 100, y: -220, rotation: 360)
        }
    }
}

struct Create3BGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 20, amp: 10, accent: accent, x: 300, y: -575, width: 1000, height: 400)
            WavyTopBottomRectangle(waves: 20, amp: 8, accent: accent, x: 300, y: 550, width: 1000, height: 400)
        }
    }
}

struct Forgot1BGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -200, rotation: 110)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 280, y: -120, rotation: 290)
        }
    }
}

struct Forgot2BGComps: View {
    var bg: String
    var accent: String
    var screenWidth = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 5, amp: 20, accent: accent, x: -40, y: -362, rotation: 10, width: screenWidth, height:260)
            SameAmplitudeBlob(waves: 5, amp: 16, accent: accent, x: 0, y: -325, rotation: 180, width: screenWidth, height:180)
        }
    }
}

struct Forgot3BGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -220, rotation: 120)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -220, rotation: 295)
        }
    }
}

struct InitialViewBGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -220, rotation: 120)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -220, rotation: 295)
        }
    }
}

struct LoginBGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 4, amp: 20, accent: accent, x: 0, y: -342, rotation: 0, width:screenWidth, height:220)
            SameAmplitudeBlob(waves: 5, amp: 16, accent: accent, x: 0, y: -325, rotation: 180, width:screenWidth, height:220)
        }
    }
}
