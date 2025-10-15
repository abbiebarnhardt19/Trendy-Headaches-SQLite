//
//  Custom Analytics Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

struct HiddenChart: View {
    var bg: String
    var accent: String
    var chart: String
    var width: CGFloat
    @Binding var hideChart: Bool
    
    var body: some View {
        HStack {
            CustomButton( text: "Show \(chart) Visual",  bg: bg,  accent: accent,  height: 50, width: UIScreen.main.bounds.width -  30,   corner: 30, bold: false,  textSize: 22, action: { hideChart.toggle() } )
        }
        .frame(width: width)
    }
}
