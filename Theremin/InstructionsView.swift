//
//  InstructionsView.swift
//  Theremin
//
//  Created by Elena Hertel on 5/21/24.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Mobile Theremin!")
                    .font(.largeTitle)
                    .padding()
                
                Text("Rotate your wrist to control frequency and change the distance from your hand to the phone to control volume.")
                    .padding()
                
                Text("Choose View 1 for a simulated Theremin or choose View 2 to see the rotation and horizontal movement.")
                    .padding()
                    .foregroundColor(Color.blue) // To differentiate it
                
                NavigationLink(destination: HandView()) {
                    Text("View 1")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.bottom, 10)
                NavigationLink(destination: TechnicalView()) {
                    Text("View 2")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.bottom, 10)
            }
            .padding()
        }
    }
}
