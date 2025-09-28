//
//  ListView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 9/19/25.
//

import SwiftUI

struct ListView: View {
    
    var userID: Int64
    @Binding var background: String
    @Binding var accent: String

    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    @State private var showLog: Bool = false
    
    var body: some View {
        
        NavigationStack {
            if showLog{
                LogView(userID: userID, background: $background, accent: $accent)
            }
            else{
                ZStack {
                    Color(hex: background).ignoresSafeArea()
                    
                    SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -375, rotation: 0, width:350, height:150)
                    SameAmplitudeBlob(waves: 4, amplitude: 20, accent: accent, x: 30, y: -270, rotation: 180, width:350, height:150)
                    
                    VStack {
                        HStack{
                            CustomText(
                                text: "List View",
                                color: accent,
                                width:100,
                                textAlignment: .leading,
                                multilineAlignment: .leading,
                                textSize: 43
                            )
                            .padding(.leading, 50)
                            Spacer()
                        }
                        ScrollableLogTable(userID: userID, background: background, accent: accent, width: screenWidth-30)
                        Spacer()
                    }
                    VStack{
                        Spacer()
                        HStack(spacing: 20){
                            Spacer()
                            Button(action: {
                                showLog = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: background))
                                    .frame(width: 40, height: 40)
                                    .background(Color(hex: accent))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                // Your action here
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: background))
                                    .frame(width: 40, height: 40)
                                    .background(Color(hex: accent))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 80)
                    
                    VStack {
                        Spacer()
                        NavBarView(
                            userID: userID,
                            background: $background,
                            accent: $accent
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .zIndex(1)
                }
            }
        }
    }
}

#Preview {
    ListView(userID: 1, background: .constant("#001d00"), accent: .constant("#b5c4b9"))
}

