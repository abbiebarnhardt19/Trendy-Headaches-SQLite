//
//  TempView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/24/25.
//

import SwiftUI

struct TempView: View {
    let userId: Int64   // 👈 Accept userId

    @State private var firstName: String = ""

    var body: some View {
        VStack {
            Text("Hello \(firstName)") // 👈 show first name
                .font(.largeTitle)
                .padding()
        }
        .onAppear {
            fetchFirstName()
        }
    }

    private func fetchFirstName() {
        do {
            if let name = try DatabaseManager.shared.getFirstName(for: userId) {
                firstName = name
            }
        } catch {
            print("Error fetching first name: \(error)")
        }
    }
}
